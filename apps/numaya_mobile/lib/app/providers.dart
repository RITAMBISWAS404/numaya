import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../data/live/live_config.dart';
import '../data/live/live_profile_repository.dart';
import '../data/live/live_providers.dart';
import '../data/live/supabase_auth_repository.dart';
import '../features/auth/data/demo_auth_repository.dart';
import '../features/auth/data/unconfigured_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/onboarding/data/in_memory_profile_repository.dart';
import '../features/onboarding/domain/profile_repository.dart';
import '../features/profile/application/profile_details_controller.dart';
import 'release_scope.dart';

/// App-wide dependencies. Tests override these with fakes (ProviderScope overrides).

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

/// Current time, injectable for tests (age checks, resend countdown).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The demo auth service, or null when demo sign-in is not allowed (release / production).
final demoAuthProvider = Provider<DemoAuthRepository?>((ref) {
  // A live-backend build never offers demo sign-in (backend V1).
  if (LiveConfig.enabled ||
      !AppConfig.demoAuthAllowed ||
      !ref.watch(appConfigProvider).demoAuthEnabled) {
    return null;
  }
  final repo = DemoAuthRepository(clock: ref.watch(clockProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => LiveConfig.enabled
      ? SupabaseAuthRepository(ref.watch(supabaseClientProvider))
      : ref.watch(demoAuthProvider) ?? const UnconfiguredAuthRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => LiveConfig.enabled
      ? LiveProfileRepository(
          ref.watch(supabaseClientProvider),
          extras: () {
            final d = ref.read(profileDetailsProvider);
            return (bio: d.bio, heightCm: d.heightCm);
          },
        )
      : InMemoryProfileRepository(),
);

/// Whether Events is available in this build (MVP: no). Defaults to the compile-time
/// [ReleaseScope.events]; the router, the tab bar and every entry point read it, so one switch
/// hides or restores the whole feature, and tests can turn Events on to keep its own suite running.
/// Events MVP (co-founder PRD, 2026-11-08): Events is in scope, as the fourth tab. The old
/// dormant module in `lib/features/events/` stays unrouted.
final eventsAvailableProvider = Provider<bool>((ref) => ReleaseScope.events);

/// Whether development controls exist in this build (compile-time [ReleaseScope.devTools]).
final devToolsAvailableProvider = Provider<bool>(
  (ref) => ReleaseScope.devTools,
);

/// Whether chat attachments are offered (MVP: no, text and emoji only). Defaults to the
/// compile-time [ReleaseScope.chatAttachments]; tests of the dormant attachment code turn it on.
final chatAttachmentsProvider = Provider<bool>(
  // Live builds: attachments have no server storage yet (docs/backend/PROVIDER_STATUS.md).
  (ref) =>
      ReleaseScope.chatAttachments &&
      (!LiveConfig.enabled || LiveConfig.attachmentsEnabled),
);
