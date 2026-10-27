import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../features/auth/data/demo_auth_repository.dart';
import '../features/auth/data/unconfigured_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/onboarding/data/in_memory_profile_repository.dart';
import '../features/onboarding/domain/profile_repository.dart';

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
