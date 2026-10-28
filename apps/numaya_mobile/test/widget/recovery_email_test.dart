import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/settings/application/account_prefs.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(loadAppFonts);

  test('email check: plausible addresses only', () {
    expect(isValidEmail('alex@example.com'), isTrue);
    expect(isValidEmail('  a.b+c@mail.co.uk '), isTrue);
    for (final bad in [
      '',
      'alex',
      'alex@',
      '@example.com',
      'a b@x.com',
      'a@x.c',
      'a@x',
    ]) {
      expect(isValidEmail(bad), isFalse, reason: bad);
    }
  });

  test('removing the email turns email notifications off', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final prefs = c.read(accountPrefsProvider.notifier)
      ..setRecoveryEmail('alex@example.com')
      ..setChannel(
        NotificationCategory.messages,
        NotificationChannel.email,
        true,
      );
    expect(
      c
          .read(accountPrefsProvider)
          .isOn(NotificationCategory.messages, NotificationChannel.email),
      isTrue,
    );
    prefs.setRecoveryEmail(null);
    expect(c.read(accountPrefsProvider).recoveryEmail, isNull);
    expect(
      c
          .read(accountPrefsProvider)
          .isOn(NotificationCategory.messages, NotificationChannel.email),
      isFalse,
    );
    // Push stays as it was.
    expect(
      c
          .read(accountPrefsProvider)
          .isOn(NotificationCategory.messages, NotificationChannel.push),
      isTrue,
    );
  });

  testWidgets('Settings: add a recovery email, fix a typo, then remove it', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.settings);
    await tapOn(tester, find.text('Recovery email'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.textContaining('No email is sent and it isn’t verified'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'alex@example');
    await tester.pump();
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Save'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Enter an email address like name@example.com'),
      findsOneWidget,
    );
    expect(c.read(accountPrefsProvider).recoveryEmail, isNull);

    await tester.enterText(find.byType(TextField), 'alex@example.com');
    await tester.pump();
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Save'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(accountPrefsProvider).recoveryEmail, 'alex@example.com');
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(
      find.text('Not verified: no email service in this build'),
      findsOneWidget,
    );

    await tapOn(tester, find.text('alex@example.com'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Remove email'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(accountPrefsProvider).recoveryEmail, isNull);
    await settle(tester);
  });
}
