import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../features/auth/data/demo_auth_repository.dart';
import '../features/auth/data/unconfigured_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/onboarding/data/in_memory_profile_repository.dart';
import '../features/onboarding/domain/profile_repository.dart';
import 'release_scope.dart';

/// App-wide dependencies. Tests override these with fakes (ProviderScope overrides).

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

/// Current time, injectable for tests (age checks, resend countdown).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The demo auth service, or null when demo sign-in is not allowed (release / production).
final demoAuthProvider = Provider<DemoAuthRepository?>((ref) {
  if (!AppConfig.demoAuthAllowed ||
      !ref.watch(appConfigProvider).demoAuthEnabled) {
    return null;
  }
  final repo = DemoAuthRepository(clock: ref.watch(clockProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.watch(demoAuthProvider) ?? const UnconfiguredAuthRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => InMemoryProfileRepository(),
);

/// Whether Events is available in this build (MVP: no). Defaults to the compile-time
/// [ReleaseScope.events]; the router, the tab bar and every entry point read it, so one switch
/// hides or restores the whole feature, and tests can turn Events on to keep its own suite running.
final eventsAvailableProvider = Provider<bool>((ref) => ReleaseScope.events);

/// Whether chat attachments are offered (MVP: no, text and emoji only). Defaults to the
/// compile-time [ReleaseScope.chatAttachments]; tests of the dormant attachment code turn it on.
final chatAttachmentsProvider = Provider<bool>(
  (ref) => ReleaseScope.chatAttachments,
);
