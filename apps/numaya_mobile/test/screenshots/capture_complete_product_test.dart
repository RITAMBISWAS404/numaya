@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/application/session_expiry.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Screens and states added by the complete-product pass, into goldens/pNN-*.png, for
/// docs/mobile/MASTER_QA_REPORT.md. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture complete-product states', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester);

    Future<void> shot(String name) async {
      await tester.pump(const Duration(milliseconds: 700));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/p$name.png'),
      );
    }

    // Offline: the banner over Home and a waiting message in a chat.
    c.read(connectivityProvider.notifier).setOnline(false);
    await tester.pump();
    await shot('01-offline-home');
    await goTo(c, tester, '${Routes.chat}/priya');
    await tester.enterText(find.byType(TextField), 'See you at the market');
    await tester.pump();
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await shot('02-offline-chat-waiting');
    c.read(connectivityProvider.notifier).setOnline(true);
    await tester.pump(const Duration(seconds: 1));

    // Share Date.
    await tapOn(tester, find.bySemanticsLabel('Conversation options'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('Share date details'));
    await tester.pump(const Duration(milliseconds: 600));
    Finder field(int i) => find.descendant(
      of: find.byType(NumayaTextField).at(i),
      matching: find.byType(TextField),
    );
    await tester.enterText(field(0), 'Columbia Road Flower Market');
    await tester.enterText(field(1), 'Sunday, 10am');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('03-share-date');
    await tester.tap(find.widgetWithText(NumayaButton, 'Share'));
    await tester.pump(const Duration(seconds: 4));

    // Recovery email in Settings.
    await goTo(c, tester, Routes.settings);
    await tapOn(tester, find.text('Recovery email'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField), 'alex@example');
    await tester.pump();
    await tester.tap(find.widgetWithText(NumayaButton, 'Save'));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('04-recovery-email-error');
    await tester.enterText(find.byType(TextField), 'alex@example.com');
    await tester.pump();
    await tester.tap(find.widgetWithText(NumayaButton, 'Save'));
    await tester.pump(const Duration(seconds: 4));
    await shot('05-settings-recovery-email');

    // Session expired, over Settings.
    c.read(sessionExpiryProvider.notifier).expire();
    await tester.pump();
    await shot('06-sign-in-again');
    await tester.tap(find.widgetWithText(NumayaButton, 'Send code'));
    await tester.pump(const Duration(milliseconds: 600));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('07-sign-in-again-code');
    await settle(tester);
  });
}
