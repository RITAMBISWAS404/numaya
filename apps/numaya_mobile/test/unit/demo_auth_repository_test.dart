import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/features/auth/data/demo_auth_repository.dart';
import 'package:numaya_mobile/features/auth/domain/auth_repository.dart';
import 'package:numaya_mobile/features/auth/domain/country.dart';
import 'package:numaya_mobile/features/auth/domain/phone_number.dart';

void main() {
  var now = DateTime(2026, 10, 27, 12);
  late DemoAuthRepository repo;
  const phone = PhoneNumber(country: kDefaultCountry, digits: '4155550132');

  setUp(() {
    now = DateTime(2026, 10, 27, 12);
    repo = DemoAuthRepository(
      random: Random(7),
      clock: () => now,
      latency: Duration.zero,
    );
  });
  tearDown(() => repo.dispose());

  test('issues a 6-digit code to the demo inbox only', () async {
    final request = await repo.requestCode(phone, AuthIntent.signUp);
    expect(repo.latestMessage!.requestId, request.id);
    expect(repo.latestMessage!.code, matches(RegExp(r'^\d{6}$')));
  });

  test('rejects incomplete numbers and all-same-digit numbers', () async {
    await expectLater(
      repo.requestCode(
        const PhoneNumber(country: kDefaultCountry, digits: '415'),
        AuthIntent.signUp,
      ),
      throwsA(isA<InvalidPhoneNumber>()),
    );
    await expectLater(
      repo.requestCode(
        const PhoneNumber(country: kDefaultCountry, digits: '0000000000'),
        AuthIntent.signUp,
      ),
      throwsA(isA<InvalidPhoneNumber>()),
    );
  });

  test(
    'a wrong code fails; the right one creates a new account session',
    () async {
      final request = await repo.requestCode(phone, AuthIntent.signUp);
      final code = repo.latestMessage!.code;
      final wrong = code == '000000' ? '111111' : '000000';
      await expectLater(
        repo.verifyCode(request, wrong),
        throwsA(isA<IncorrectCode>()),
      );
      final session = await repo.verifyCode(request, code);
      expect(session.hasProfile, isFalse);
      expect(session.phone, phone);
    },
  );

  test('five wrong attempts expire the code', () async {
    final request = await repo.requestCode(phone, AuthIntent.signUp);
    final wrong = repo.latestMessage!.code == '000000' ? '111111' : '000000';
    for (var i = 0; i < 4; i++) {
      await expectLater(
        repo.verifyCode(request, wrong),
        throwsA(isA<IncorrectCode>()),
      );
    }
    await expectLater(
      repo.verifyCode(request, wrong),
      throwsA(isA<CodeExpired>()),
    );
    await expectLater(
      repo.verifyCode(request, repo.latestMessage!.code),
      throwsA(isA<CodeExpired>()),
    );
  });

  test('resend waits 30 seconds and replaces the code', () async {
    final first = await repo.requestCode(phone, AuthIntent.signUp);
    final firstCode = repo.latestMessage!.code;
    await expectLater(repo.resendCode(first), throwsA(isA<ResendTooSoon>()));
    now = now.add(const Duration(seconds: 30));
    final second = await repo.resendCode(first);
    expect(second.id, isNot(first.id));
    await expectLater(
      repo.verifyCode(first, firstCode),
      throwsA(isA<CodeExpired>()),
    );
    final session = await repo.verifyCode(second, repo.latestMessage!.code);
    expect(session.phone, phone);
  });

  test('an account that finished setup is recognised on sign-in', () async {
    final signUp = await repo.requestCode(phone, AuthIntent.signUp);
    final session = await repo.verifyCode(signUp, repo.latestMessage!.code);
    await repo.markProfileComplete(session);

    final signIn = await repo.requestCode(phone, AuthIntent.signIn);
    final again = await repo.verifyCode(signIn, repo.latestMessage!.code);
    expect(again.hasProfile, isTrue);
    expect(again.userId, session.userId);
  });

  test('a deleted account is new again on the next sign-in', () async {
    final signUp = await repo.requestCode(phone, AuthIntent.signUp);
    final session = await repo.verifyCode(signUp, repo.latestMessage!.code);
    await repo.markProfileComplete(session);
    await repo.deleteAccount(session);

    final signIn = await repo.requestCode(phone, AuthIntent.signIn);
    final again = await repo.verifyCode(signIn, repo.latestMessage!.code);
    expect(again.hasProfile, isFalse);
  });
}
