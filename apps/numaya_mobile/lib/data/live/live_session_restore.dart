import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logging/app_logger.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/country.dart';
import '../../features/auth/domain/phone_number.dart';
import 'live_config.dart';

/// Cold-start session restore (backend V1). supabase_flutter keeps the refresh token in its
/// session storage; at start the app asks the server for `account_state` and, for an active
/// account, starts the session as the verify screen would. A deleted, restricted or unreachable
/// account starts signed out (the member signs in again) — never a half-loaded app.
abstract final class LiveSessionRestore {
  static const _log = AppLogger('LiveSession');
  static AuthSession? restored;

  static Future<void> tryRestore() async {
    if (!LiveConfig.enabled) return;
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;
    try {
      final state =
          (await client
                      .rpc<dynamic>('account_state')
                      .timeout(const Duration(seconds: 8))
                  as Map)
              .cast<String, dynamic>();
      if (state['status'] != 'active' && state['status'] != 'onboarding') {
        _log.info('Stored session not restored (${state['status']})');
        return;
      }
      restored = AuthSession(
        userId: user.id,
        phone: phoneFromE164(user.phone ?? ''),
        hasProfile: state['has_profile'] == true,
      );
      _log.info('Session restored (returning: ${restored!.hasProfile})');
    } on Object catch (e) {
      _log.warning('Session restore skipped: ${e.runtimeType}');
    }
  }

  /// Rebuilds the number from Supabase's E.164 digits (no "+"), longest dial code first.
  static PhoneNumber phoneFromE164(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final sorted = [...kCountries]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final c in sorted) {
      if (digits.startsWith(c.dialCode)) {
        return PhoneNumber(
          country: c,
          digits: digits.substring(c.dialCode.length),
        );
      }
    }
    return PhoneNumber(country: kCountries.first, digits: digits);
  }
}
