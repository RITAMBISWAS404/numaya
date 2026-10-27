import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/logging/app_logger.dart';
import '../../dating/application/dating_controller.dart';
import '../../home/application/discovery_filters.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../settings/application/account_prefs.dart';
import '../../verification/application/verification_controller.dart';
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

  /// Deletes the account. The demo keeps the saved profile for the 28-day restore window (F27);
  /// "Start over" or the end of the window removes it.
  Future<void> deleteAccount() async {
    final session = state;
    if (session != null) {
      await ref.read(authRepositoryProvider).deleteAccount(session);
    }
    _clear();
    _log.info('Account deleted');
  }

  /// Restores a deleted account (from the restore screen after verification).
  Future<void> restoreAccount() async {
    final session = state;
    if (session == null || session.restorableUntil == null) return;
    final restored = await ref
        .read(authRepositoryProvider)
        .restoreAccount(session);
    state = restored;
    await ref.read(onboardingProvider.notifier).restore();
    _log.info('Account restored');
  }

  /// Gives up the deleted account and starts a new profile on the same number.
  Future<void> startOver() async {
    final session = state;
    if (session == null) return;
    await ref.read(authRepositoryProvider).purgeAccount(session);
    await ref.read(profileRepositoryProvider).delete(session.userId);
    state = AuthSession(
      userId: session.userId,
      phone: session.phone,
      hasProfile: false,
    );
  }

  /// Demo Hub: sign in to a sample account with a finished profile.
  Future<void> quickStart() async {
    final demo = ref.read(demoAuthProvider);
    if (demo == null) return;
    _clear();
    final session = demo.quickStart();
    ref.read(onboardingProvider.notifier).loadSample();
    state = session;
    await ref.read(onboardingProvider.notifier).finish();
  }

  /// Demo Hub: back to the starting demo data (matches, messages, filters, premium, verification,
  /// profile details, settings) without signing out.
  void resetDemoData() {
    ref.invalidate(datingProvider);
    ref.invalidate(discoveryFiltersProvider);
    ref.invalidate(premiumProvider);
    ref.invalidate(profileDetailsProvider);
    ref.invalidate(accountPrefsProvider);
    ref.invalidate(photoVerificationProvider);
    _log.info('Demo data reset');
  }

  void _clear() {
    state = null;
    ref.invalidate(phoneEntryProvider);
    ref.invalidate(verificationProvider);
    ref.invalidate(onboardingProvider);
    ref.invalidate(datingProvider);
    ref.invalidate(discoveryFiltersProvider);
    ref.invalidate(premiumProvider);
    ref.invalidate(profileDetailsProvider);
    ref.invalidate(accountPrefsProvider);
    ref.invalidate(photoVerificationProvider);
  }
}

final sessionProvider = NotifierProvider<SessionController, AuthSession?>(
  SessionController.new,
);
