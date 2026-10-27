import 'package:flutter/foundation.dart';

/// Build environment, chosen at compile time:
///
///     flutter run --dart-define=NUMAYA_ENV=development   (default)
///     flutter run --dart-define=NUMAYA_ENV=production
enum AppEnvironment { development, production }

/// Compile-time configuration. Nothing here is a secret: real credentials never live in the app
/// (see docs/mobile/PRODUCTION_READINESS.md).
@immutable
class AppConfig {
  const AppConfig({required this.environment, required this.demoAuthEnabled});

  /// Reads `--dart-define` values. Constant, so the compiler removes unused branches.
  factory AppConfig.fromEnvironment() {
    const env = String.fromEnvironment(
      'NUMAYA_ENV',
      defaultValue: 'development',
    );
    final environment = env == 'production'
        ? AppEnvironment.production
        : AppEnvironment.development;
    return AppConfig(
      environment: environment,
      demoAuthEnabled: demoAuthAllowed,
    );
  }

  /// Demo sign-in (a code shown on screen instead of a real SMS) exists only in debug and profile
  /// builds of the development environment. In a release build `kReleaseMode` is a compile-time
  /// `true`, so this is `false` and the demo service is tree-shaken out of the binary.
  static const bool demoAuthAllowed =
      !kReleaseMode &&
      String.fromEnvironment('NUMAYA_ENV', defaultValue: 'development') !=
          'production';

  final AppEnvironment environment;
  final bool demoAuthEnabled;

  bool get isProduction => environment == AppEnvironment.production;
}
