import 'package:flutter/foundation.dart';

import 'phone_number.dart';

/// Why the person is verifying: creating an account or signing back in.
enum AuthIntent { signUp, signIn }

/// A code has been sent to [phone]; verify it with [AuthRepository.verifyCode].
@immutable
class VerificationRequest {
  const VerificationRequest({
    required this.id,
    required this.phone,
    required this.intent,
    required this.resendAvailableAt,
  });

  /// Opaque id from the auth service.
  final String id;
  final PhoneNumber phone;
  final AuthIntent intent;
  final DateTime resendAvailableAt;
}

/// A verified session.
@immutable
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.phone,
    required this.hasProfile,
    this.restorableUntil,
  });

  /// Opaque account id. Never shown or logged.
  final String userId;
  final PhoneNumber phone;

  /// Whether this account already finished profile setup (a returning member).
  final bool hasProfile;

  /// Set when this number's account was deleted less than 28 days ago and can still be restored
  /// (B-75, F27).
  final DateTime? restorableUntil;
}

/// Typed failures the screens turn into copy. No raw server text reaches the UI.
sealed class AuthFailure implements Exception {
  const AuthFailure();
}

/// The number can't be used (malformed, unsupported or blocked).
class InvalidPhoneNumber extends AuthFailure {
  const InvalidPhoneNumber();
}

/// The code doesn't match the latest one sent.
class IncorrectCode extends AuthFailure {
  const IncorrectCode();
}

/// The code expired or too many attempts were made; a new code is needed.
class CodeExpired extends AuthFailure {
  const CodeExpired();
}

/// Resend asked for before the cooldown ended.
class ResendTooSoon extends AuthFailure {
  const ResendTooSoon(this.availableAt);
  final DateTime availableAt;
}

/// The device is offline or the service didn't answer.
class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure();
}

/// This build has no sign-in service configured.
class AuthUnavailable extends AuthFailure {
  const AuthUnavailable();
}

/// Phone-number authentication. Implementations: [DemoAuthRepository] (development builds only)
/// and [UnconfiguredAuthRepository] (until a real provider is chosen; see
/// docs/mobile/PRODUCTION_READINESS.md).
abstract interface class AuthRepository {
  /// Sends a code by SMS. Throws [AuthFailure].
  Future<VerificationRequest> requestCode(PhoneNumber phone, AuthIntent intent);

  /// Sends a fresh code; the previous one stops working. Throws [AuthFailure].
  Future<VerificationRequest> resendCode(VerificationRequest request);

  /// Checks [code] against the latest code for [request]. Throws [AuthFailure].
  Future<AuthSession> verifyCode(VerificationRequest request, String code);

  /// Records that the account finished profile setup.
  Future<void> markProfileComplete(AuthSession session);

  /// Deletes the account and ends the session.
  Future<void> deleteAccount(AuthSession session);

  Future<void> signOut();

  /// Brings back an account deleted within the restore window.
  Future<AuthSession> restoreAccount(AuthSession session);

  /// Gives up a deleted account for good, so the number starts a new one.
  Future<void> purgeAccount(AuthSession session);
}
