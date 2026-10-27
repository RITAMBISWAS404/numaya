import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/logging/app_logger.dart';
import '../domain/auth_repository.dart';
import '../domain/country.dart';
import '../domain/phone_number.dart';

/// A "text message" the demo service would have sent. Shown in the in-app demo banner, never
/// logged and never sent anywhere.
@immutable
class DemoMessage {
  const DemoMessage({required this.requestId, required this.code});
  final String requestId;
  final String code;
}

/// DEVELOPMENT ONLY. Simulates phone verification so the onboarding flow can be exercised without a
/// backend. It is created only when [AppConfig.demoAuthAllowed] is true, which is a compile-time
/// `false` in release builds, so this class is not part of a release binary.
///
/// Behaviour:
/// - Each request gets a fresh random 6-digit code, delivered to [inbox] (the demo banner).
/// - A number whose digits are all the same (e.g. 000 000 0000) is rejected as unusable, to
///   exercise the error state.
/// - Five wrong attempts expire the code. Resend has a 30 second cooldown.
/// - "Accounts" live in memory for this app session only. Nothing is persisted.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository({
    Random? random,
    DateTime Function()? clock,
    this.latency = const Duration(milliseconds: 1100),
    this.resendCooldown = const Duration(seconds: 30),
  }) : _random = random ?? Random.secure(),
       _clock = clock ?? DateTime.now;

  final Random _random;
  final DateTime Function() _clock;
  final Duration latency;
  final Duration resendCooldown;

  static const _log = AppLogger('DemoAuth');
  static const _maxAttempts = 5;

  final _inbox = StreamController<DemoMessage>.broadcast();
  final Map<String, ({String code, int attempts})> _codes = {};

  /// e164 → account id, for numbers that finished profile setup this session.
  final Map<String, String> _accounts = {};

  /// e164 → (account id, deleted at): deleted accounts can be restored for [restoreWindow].
  final Map<String, ({String userId, DateTime at})> _deleted = {};
  static const restoreWindow = Duration(days: 28);
  DemoMessage? _latest;

  /// Codes the demo "sent", for the on-screen banner.
  Stream<DemoMessage> get inbox => _inbox.stream;

  /// The most recent message, so a banner opened late can still show it.
  DemoMessage? get latestMessage => _latest;

  String _newCode() => List.generate(6, (_) => _random.nextInt(10)).join();

  String _newId() =>
      List.generate(16, (_) => _random.nextInt(16).toRadixString(16)).join();

  Future<void> _wait() =>
      latency == Duration.zero ? Future.value() : Future.delayed(latency);

  VerificationRequest _issue(PhoneNumber phone, AuthIntent intent) {
    final id = _newId();
    final code = _newCode();
    _codes[id] = (code: code, attempts: 0);
    _latest = DemoMessage(requestId: id, code: code);
    _inbox.add(_latest!);
    _log.info('Demo code issued (${intent.name})');
    return VerificationRequest(
      id: id,
      phone: phone,
      intent: intent,
      resendAvailableAt: _clock().add(resendCooldown),
    );
  }

  @override
  Future<VerificationRequest> requestCode(
    PhoneNumber phone,
    AuthIntent intent,
  ) async {
    await _wait();
    final digits = phone.digits;
    if (!phone.isComplete || RegExp(r'^(\d)\1*$').hasMatch(digits)) {
      _log.info('Demo number rejected');
      throw const InvalidPhoneNumber();
    }
    return _issue(phone, intent);
  }

  @override
  Future<VerificationRequest> resendCode(VerificationRequest request) async {
    if (_clock().isBefore(request.resendAvailableAt)) {
      throw ResendTooSoon(request.resendAvailableAt);
    }
    await _wait();
    _codes.remove(request.id);
    return _issue(request.phone, request.intent);
  }

  @override
  Future<AuthSession> verifyCode(
    VerificationRequest request,
    String code,
  ) async {
    await _wait();
    final entry = _codes[request.id];
    if (entry == null) throw const CodeExpired();
    if (entry.code != code) {
      final attempts = entry.attempts + 1;
      if (attempts >= _maxAttempts) {
        _codes.remove(request.id);
        throw const CodeExpired();
      }
      _codes[request.id] = (code: entry.code, attempts: attempts);
      throw const IncorrectCode();
    }
    _codes.remove(request.id);
    final existing = _accounts[request.phone.e164];
    final deleted = _deleted[request.phone.e164];
    if (existing == null && deleted != null) {
      final until = deleted.at.add(restoreWindow);
      if (_clock().isBefore(until)) {
        return AuthSession(
          userId: deleted.userId,
          phone: request.phone,
          hasProfile: false,
          restorableUntil: until,
        );
      }
      _deleted.remove(request.phone.e164);
    }
    return AuthSession(
      userId: existing ?? 'demo-${_newId()}',
      phone: request.phone,
      hasProfile: existing != null,
    );
  }

  @override
  Future<void> markProfileComplete(AuthSession session) async {
    _accounts[session.phone.e164] = session.userId;
  }

  @override
  Future<void> deleteAccount(AuthSession session) async {
    _accounts.remove(session.phone.e164);
    _deleted[session.phone.e164] = (userId: session.userId, at: _clock());
  }

  @override
  Future<AuthSession> restoreAccount(AuthSession session) async {
    await _wait();
    final deleted = _deleted.remove(session.phone.e164);
    if (deleted == null) throw const CodeExpired();
    _accounts[session.phone.e164] = deleted.userId;
    return AuthSession(
      userId: deleted.userId,
      phone: session.phone,
      hasProfile: true,
    );
  }

  @override
  Future<void> purgeAccount(AuthSession session) async {
    _deleted.remove(session.phone.e164);
  }

  /// Demo Hub "quick start": a signed-in sample account with a finished profile, so every screen
  /// can be explored without going through sign-up. Uses a fictional 555 number.
  AuthSession quickStart() {
    final phone = PhoneNumber(country: kCountries.first, digits: '4155550100');
    final id = _accounts[phone.e164] ?? 'demo-${_newId()}';
    _accounts[phone.e164] = id;
    _log.info('Demo quick start');
    return AuthSession(userId: id, phone: phone, hasProfile: true);
  }

  @override
  Future<void> signOut() async {}

  void dispose() => _inbox.close();
}
