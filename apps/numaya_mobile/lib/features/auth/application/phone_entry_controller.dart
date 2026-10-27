import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/auth_repository.dart';
import '../domain/country.dart';
import '../domain/phone_number.dart';
import 'verification_controller.dart';

@immutable
class PhoneEntryState {
  const PhoneEntryState({
    required this.phone,
    this.intent = AuthIntent.signUp,
    this.submitting = false,
    this.failure,
  });

  final PhoneNumber phone;
  final AuthIntent intent;
  final bool submitting;
  final AuthFailure? failure;

  bool get canSubmit => phone.isComplete && !submitting;

  PhoneEntryState copyWith({
    PhoneNumber? phone,
    AuthIntent? intent,
    bool? submitting,
    AuthFailure? failure,
    bool clearFailure = false,
  }) {
    return PhoneEntryState(
      phone: phone ?? this.phone,
      intent: intent ?? this.intent,
      submitting: submitting ?? this.submitting,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// View model of the phone step. Kept alive so "Change number" returns with the number intact.
class PhoneEntryController extends Notifier<PhoneEntryState> {
  static const _log = AppLogger('PhoneEntry');

  @override
  PhoneEntryState build() => const PhoneEntryState(
    phone: PhoneNumber(country: kDefaultCountry, digits: ''),
  );

  void setIntent(AuthIntent intent) {
    if (state.intent != intent) {
      state = state.copyWith(intent: intent, clearFailure: true);
    }
  }

  void setDigits(String raw) {
    if (state.submitting) return;
    state = state.copyWith(
      phone: state.phone.withDigits(raw),
      clearFailure: true,
    );
  }

  void setCountry(Country country) {
    if (state.submitting) return;
    state = state.copyWith(
      phone: state.phone.withCountry(country),
      clearFailure: true,
    );
  }

  /// Requests a code. Returns true when the verify step should open.
  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    state = state.copyWith(submitting: true, clearFailure: true);
    try {
      final request = await ref
          .read(authRepositoryProvider)
          .requestCode(state.phone, state.intent);
      if (!ref.mounted) return false;
      ref.read(verificationProvider.notifier).begin(request);
      state = state.copyWith(submitting: false);
      return true;
    } on AuthFailure catch (failure) {
      _log.info('Code request failed: ${failure.runtimeType}');
      if (ref.mounted) {
        state = state.copyWith(submitting: false, failure: failure);
      }
      return false;
    } catch (error, stack) {
      _log.error('Code request crashed', error, stack);
      if (ref.mounted) {
        state = state.copyWith(
          submitting: false,
          failure: const AuthNetworkFailure(),
        );
      }
      return false;
    }
  }
}

final phoneEntryProvider =
    NotifierProvider<PhoneEntryController, PhoneEntryState>(
      PhoneEntryController.new,
    );
