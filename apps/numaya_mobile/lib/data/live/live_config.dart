import 'package:flutter/foundation.dart';

/// The live backend this build talks to, from `--dart-define` (backend V1).
///
/// Only the project URL and the **publishable** key are ever bundled. The secret key, database
/// password and service credentials never reach the app. When either value is missing the app
/// keeps its existing demo / unconfigured behaviour: it never silently mixes demo data into a
/// live build, and a live build never falls back to demo data after a failure.
abstract final class LiveConfig {
  static const String url = String.fromEnvironment('NUMAYA_SUPABASE_URL');
  static const String publishableKey = String.fromEnvironment(
    'NUMAYA_SUPABASE_PUBLISHABLE_KEY',
  );

  /// Shown on the Demo Hub and in logs: `development`, `staging` or `production`.
  static const String label = String.fromEnvironment(
    'NUMAYA_BACKEND_LABEL',
    defaultValue: 'development',
  );

  static bool get enabled => url.isNotEmpty && publishableKey.isNotEmpty;

  /// Chat photos and voice notes on the server. Off until verified on the real project
  /// (ACTIVATION_RUNBOOK); `--dart-define=NUMAYA_LIVE_ATTACHMENTS=true` turns them on.
  static const bool attachmentsEnabled = bool.fromEnvironment(
    'NUMAYA_LIVE_ATTACHMENTS',
  );

  /// Release guard: a release build must never point at a development backend.
  static void assertSafeForThisBuild() {
    if (kReleaseMode && enabled && label == 'development') {
      throw StateError(
        'Release builds cannot use the development backend (NUMAYA_BACKEND_LABEL).',
      );
    }
  }

  /// Signed URLs for photos live this long (seconds). Already-issued URLs cannot be revoked
  /// early, so this is kept short (THREAT_MODEL: residual access after a block).
  static const int signedUrlSeconds = 300;
}
