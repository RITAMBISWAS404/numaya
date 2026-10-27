import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/logging/app_logger.dart';
import '../../dating/application/dating_controller.dart';
import '../../home/application/discovery_filters.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../domain/auth_repository.dart';
import 'phone_entry_controller.dart';
import 'verification_controller.dart';

/// The signed-in session, or null when signed out. Held in memory: a real build stores the
/// provider's refresh token in the platform keystore (see PRODUCTION_READINESS.md), never in
/// plain preferences.
class SessionController extends Notifier<AuthSession?> {
  static const _log = AppLogger('Session');

  @override
  AuthSession? build() => null;

  void start(AuthSession session) {
    state = session;
    _log.info('Session started (returning: ${session.hasProfile})');
  }

  Future<void> markProfileComplete() async {
    final session = state;
    if (session == null) return;
    await ref.read(authRepositoryProvider).markProfileComplete(session);
    state = AuthSession(
      userId: session.userId,
      phone: session.phone,
      hasProfile: true,
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    _clear();
    _log.info('Signed out');
  }

  /// Drops a verified session that hasn't been used (sign-in found no account and the person chose
  /// another number). Keeps the phone step's state so they can edit the number.
  void discardUnfinished() {
    state = null;
    ref.invalidate(verificationProvider);
  }

  Future<void> deleteAccount() async {
    final session = state;
    if (session != null) {
      await ref.read(profileRepositoryProvider).delete(session.userId);
      await ref.read(authRepositoryProvider).deleteAccount(session);
    }
    _clear();
    _log.info('Account deleted');
  }

  void _clear() {
    state = null;
    ref.invalidate(phoneEntryProvider);
    ref.invalidate(verificationProvider);
    ref.invalidate(onboardingProvider);
    ref.invalidate(datingProvider);
    ref.invalidate(discoveryFiltersProvider);
  }
}

final sessionProvider = NotifierProvider<SessionController, AuthSession?>(
  SessionController.new,
);
