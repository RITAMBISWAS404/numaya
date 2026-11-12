import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'live_config.dart';

/// Initialises Supabase once, before `runApp`, when this build is configured for a live backend.
/// The publishable key is the only key in the app; RLS and the RPCs enforce every rule.
Future<void> initLiveBackend() async {
  if (!LiveConfig.enabled) return;
  LiveConfig.assertSafeForThisBuild();
  await Supabase.initialize(
    url: LiveConfig.url,
    publishableKey: LiveConfig.publishableKey,
    // The refresh token is kept by supabase_flutter's session storage.
  );
}

/// The Supabase client. Only read in live mode (LiveConfig.enabled).
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
