import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// A backend refusal with the stable code from the RPC (docs/backend/API_CONTRACT.md), e.g.
/// `quota_exhausted`, `no_credits`, `unavailable`, `match_expired`, `rate_limited`.
class LiveFailure implements Exception {
  const LiveFailure(this.code);
  final String code;

  bool get offline => code == 'offline';
  bool get sessionExpired => code == 'session_expired';

  @override
  String toString() => 'LiveFailure($code)';
}

/// Runs a backend call and turns transport and server errors into [LiveFailure] codes. Server
/// text never reaches the UI; only the code does.
Future<T> guardLive<T>(Future<T> Function() call) async {
  try {
    return await call().timeout(const Duration(seconds: 20));
  } on PostgrestException catch (e) {
    if (e.code == 'P0001') throw LiveFailure(e.message);
    if (e.code == 'PGRST301' || e.code == '401' || e.message.contains('JWT')) {
      throw const LiveFailure('session_expired');
    }
    if (e.code == '42501') throw const LiveFailure('forbidden');
    throw const LiveFailure('server_error');
  } on StorageException catch (e) {
    throw LiveFailure(
      e.statusCode == '413' ? 'size_not_allowed' : 'upload_failed',
    );
  } on AuthException {
    throw const LiveFailure('session_expired');
  } on SocketException {
    throw const LiveFailure('offline');
  } on TimeoutException {
    throw const LiveFailure('offline');
  } on HttpException {
    throw const LiveFailure('offline');
  }
}
