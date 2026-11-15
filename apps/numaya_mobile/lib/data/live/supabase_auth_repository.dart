import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logging/app_logger.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/phone_number.dart';

/// Phone OTP through Supabase Auth (backend V1). Real SMS needs the project's SMS provider; until
/// one is funded, only the test numbers configured on the dev project receive a (fixed) code.
/// Nothing here bypasses verification: the code is always checked by Supabase Auth.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final SupabaseClient _client;
  final DateTime Function() _clock;
  static const _log = AppLogger('LiveAuth');

  /// Supabase's default minimum gap between codes for one number.
  static const _resendGap = Duration(seconds: 60);

  @override
  Future<VerificationRequest> requestCode(
    PhoneNumber phone,
    AuthIntent intent,
  ) async {
    await _guard(
      () => _client.auth.signInWithOtp(
        phone: phone.e164,
        // A sign-in never creates an account; the flow offers sign-up instead.
        shouldCreateUser: intent == AuthIntent.signUp,
      ),
    );
    return VerificationRequest(
      id: phone.e164,
      phone: phone,
      intent: intent,
      resendAvailableAt: _clock().add(_resendGap),
    );
  }

  @override
  Future<VerificationRequest> resendCode(VerificationRequest request) =>
      requestCode(request.phone, request.intent);

  @override
  Future<AuthSession> verifyCode(
    VerificationRequest request,
    String code,
  ) async {
    final res = await _guard(
      () => _client.auth.verifyOTP(
        phone: request.phone.e164,
        token: code,
        type: OtpType.sms,
      ),
    );
    final user = res.user;
    if (user == null) throw const IncorrectCode();
    return _sessionFor(user.id, request.phone);
  }

  Future<AuthSession> _sessionFor(String userId, PhoneNumber phone) async {
    final state = await _rpc('account_state');
    final restorable = state['restorable_until'] as String?;
    _log.info('Signed in (returning: ${state['has_profile']})');
    return AuthSession(
      userId: userId,
      phone: phone,
      hasProfile: state['has_profile'] == true && state['status'] != 'deleted',
      restorableUntil: restorable == null ? null : DateTime.parse(restorable),
    );
  }

  /// Onboarding completion is recorded by `complete_onboarding` (LiveProfileRepository), which
  /// checks age and consents on the server; nothing to do here.
  @override
  Future<void> markProfileComplete(AuthSession session) async {}

  @override
  Future<void> deleteAccount(AuthSession session) async {
    await _rpc('request_account_deletion');
    await signOut();
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on Object catch (e) {
      // A local sign-out still clears the session even if the network call fails.
      _log.warning('Sign-out did not reach the server: ${e.runtimeType}');
    }
  }

  @override
  Future<AuthSession> restoreAccount(AuthSession session) async {
    await _rpc('restore_account');
    return _sessionFor(session.userId, session.phone);
  }

  @override
  Future<void> purgeAccount(AuthSession session) async {
    await _rpc('purge_account');
    await signOut();
  }

  Future<Map<String, dynamic>> _rpc(String fn) async {
    final r = await _guard(() => _client.rpc<dynamic>(fn));
    return (r as Map).cast<String, dynamic>();
  }

  /// Maps transport and Auth errors to the typed failures the screens already handle.
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 20));
    } on AuthException catch (e) {
      final code = (e.code ?? '').toLowerCase();
      final status = e.statusCode ?? '';
      _log.warning('Auth error ${e.code ?? status}');
      if (code.contains('otp_expired') || code.contains('expired')) {
        throw const CodeExpired();
      }
      if (code.contains('invalid') && code.contains('otp') ||
          code == 'invalid_credentials') {
        throw const IncorrectCode();
      }
      if (status == '429' || code.contains('rate_limit')) {
        throw ResendTooSoon(_clock().add(_resendGap));
      }
      if (code.contains('phone') || code == 'validation_failed') {
        throw const InvalidPhoneNumber();
      }
      if (code.contains('provider_disabled') || code.contains('sms_send')) {
        throw const AuthUnavailable();
      }
      throw const IncorrectCode();
    } on SocketException {
      throw const AuthNetworkFailure();
    } on TimeoutException {
      throw const AuthNetworkFailure();
    } on PostgrestException catch (e) {
      _log.warning('Account state error ${e.code}');
      throw const AuthNetworkFailure();
    } on AuthFailure {
      rethrow;
    }
  }
}
