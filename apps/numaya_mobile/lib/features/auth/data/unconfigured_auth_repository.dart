import '../domain/auth_repository.dart';
import '../domain/phone_number.dart';

/// Used whenever demo sign-in is not allowed (release and production builds) until a real auth
/// provider is integrated. Every call fails with [AuthUnavailable], which the phone screen shows as
/// "Sign-in isn't available in this build". It never pretends to send a code.
class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  @override
  Future<VerificationRequest> requestCode(
    PhoneNumber phone,
    AuthIntent intent,
  ) async => throw const AuthUnavailable();

  @override
  Future<VerificationRequest> resendCode(VerificationRequest request) async =>
      throw const AuthUnavailable();

  @override
  Future<AuthSession> verifyCode(
    VerificationRequest request,
    String code,
  ) async => throw const AuthUnavailable();

  @override
  Future<void> markProfileComplete(AuthSession session) async {}

  @override
  Future<void> deleteAccount(AuthSession session) async =>
      throw const AuthUnavailable();

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthSession> restoreAccount(AuthSession session) async =>
      throw const AuthUnavailable();

  @override
  Future<void> purgeAccount(AuthSession session) async {}
}
