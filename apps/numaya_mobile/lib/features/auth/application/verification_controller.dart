import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/auth_repository.dart';
import 'session_controller.dart';

enum VerificationStatus { entering, checking, incorrect, expired, success }

@immutable
class VerificationState {
  const VerificationState({
    this.request,
    this.status = VerificationStatus.entering,
    this.resending = false,
    this.failure,
    this.session,
  });

  final VerificationRequest? request;
  final VerificationStatus status;
  final bool resending;

  /// Network or availability problems (wrong codes use [status]).
  final AuthFailure? failure;

  /// Set once verified.
  final AuthSession? session;

  VerificationState copyWith({
    VerificationRequest? request,
    VerificationStatus? status,
    bool? resending,
    AuthFailure? failure,
    bool clearFailure = false,
    AuthSession? session,
  }) {
    return VerificationState(
      request: request ?? this.request,
      status: status ?? this.status,
      resending: resending ?? this.resending,
      failure: clearFailure ? null : (failure ?? this.failure),
      session: session ?? this.session,
    );
  }
}

/// View model of the verify step.
class VerificationController extends Notifier<VerificationState> {
  static const _log = AppLogger('Verification');

  @override
  VerificationState build() => const VerificationState();

  void begin(VerificationRequest request) {
    state = VerificationState(request: request);
  }

  /// The person edited the code after an error: back to entering.
  void editing() {
    if (state.status == VerificationStatus.incorrect) {
      state = state.copyWith(
        status: VerificationStatus.entering,
        clearFailure: true,
      );
    }
  }

  /// Checks a complete code. Returns the session on success.
  Future<AuthSession?> verify(String code) async {
    final request = state.request;
    if (request == null ||
        state.status == VerificationStatus.checking ||
        state.status == VerificationStatus.success ||
        state.status == VerificationStatus.expired) {
      return null;
    }
    state = state.copyWith(
      status: VerificationStatus.checking,
      clearFailure: true,
    );
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .verifyCode(request, code);
      if (!ref.mounted) return null;
      state = state.copyWith(
        status: VerificationStatus.success,
        session: session,
      );
      ref.read(sessionProvider.notifier).start(session);
      return session;
    } on IncorrectCode {
      if (ref.mounted) {
        state = state.copyWith(status: VerificationStatus.incorrect);
      }
    } on CodeExpired {
      if (ref.mounted) {
        state = state.copyWith(status: VerificationStatus.expired);
      }
    } on AuthFailure catch (failure) {
      _log.info('Verify failed: ${failure.runtimeType}');
      if (ref.mounted) {
        state = state.copyWith(
          status: VerificationStatus.entering,
          failure: failure,
        );
      }
    } catch (error, stack) {
      _log.error('Verify crashed', error, stack);
      if (ref.mounted) {
        state = state.copyWith(
          status: VerificationStatus.entering,
          failure: const AuthNetworkFailure(),
        );
      }
    }
    return null;
  }

  /// Sends a new code. Returns true when one was sent.
  Future<bool> resend() async {
    final request = state.request;
    if (request == null || state.resending) return false;
    state = state.copyWith(resending: true, clearFailure: true);
    try {
      final next = await ref.read(authRepositoryProvider).resendCode(request);
      if (!ref.mounted) return false;
      state = VerificationState(request: next);
      return true;
    } on AuthFailure catch (failure) {
      if (ref.mounted) {
        state = state.copyWith(resending: false, failure: failure);
      }
    } catch (error, stack) {
      _log.error('Resend crashed', error, stack);
      if (ref.mounted) {
        state = state.copyWith(
          resending: false,
          failure: const AuthNetworkFailure(),
        );
      }
    }
    return false;
  }
}

final verificationProvider =
    NotifierProvider<VerificationController, VerificationState>(
      VerificationController.new,
    );
