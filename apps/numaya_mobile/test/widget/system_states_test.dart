import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/auth/application/session_expiry.dart';
import 'package:numaya_mobile/features/auth/presentation/verify_screen.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/events/application/events_controller.dart';
import 'package:numaya_mobile/features/events/domain/event.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// System states from states-and-recovery §3 that the demo can simulate.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'offline: a banner on every screen, messages wait and send on reconnect, joins fail safely',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      expect(find.byType(ConnectionBanner), findsNothing);

      c.read(connectivityProvider.notifier).setOnline(false);
      await tester.pump();
      expect(
        find.textContaining('You’re offline. We’ll keep trying.'),
        findsOneWidget,
      );

      // Chat: the message waits, then goes out when the connection is back.
      await goTo(c, tester, '${Routes.chat}/priya');
      expect(find.byType(ConnectionBanner), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'See you there');
      await tester.pump();
      await tapOn(tester, find.bySemanticsLabel('Send'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.text(
          'Waiting for a connection. It’ll send when you’re back online.',
        ),
        findsOneWidget,
      );
      expect(
        c.read(datingProvider).threads['priya']!.last.status,
        MessageStatus.waiting,
      );

      c.read(connectivityProvider.notifier).setOnline(true);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(ConnectionBanner), findsNothing);
      expect(
        c.read(datingProvider).threads['priya']!.last.status,
        MessageStatus.onDevice,
      );
      expect(
        find.text('Demo · saved on this device, not sent'),
        findsOneWidget,
      );

      // Events: a join needs the service's answer, so offline it fails and nothing changes.
      c.read(connectivityProvider.notifier).setOnline(false);
      await goTo(c, tester, '${Routes.event}/e-jazz');
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Join'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Couldn’t save that'), findsOneWidget);
      expect(
        c.read(eventsProvider).byId('e-jazz')!.participation,
        Participation.none,
      );
      c.read(connectivityProvider.notifier).setOnline(true);
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Try again'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        c.read(eventsProvider).byId('e-jazz')!.participation,
        Participation.going,
      );
      await settle(tester);
    },
  );

  testWidgets(
    'session expired: sign in again over the current screen and return to it',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.editProfile);
      final before = c.read(routerProvider).state.uri.path;

      c.read(sessionExpiryProvider.notifier).expire();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Please sign in again'), findsOneWidget);

      // Back can't skip it.
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Please sign in again'), findsOneWidget);

      // A wrong code is refused; the demo message fills the right one.
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Send code'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), '000000');
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.read(sessionExpiryProvider), isTrue);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.byType(DemoMessageBanner));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.read(sessionExpiryProvider), isFalse);
      expect(find.text('Please sign in again'), findsNothing);
      expect(find.text('You’re signed in again'), findsOneWidget);
      expect(c.read(routerProvider).state.uri.path, before);
      await settle(tester);
    },
  );

  testWidgets('session expired: signing out instead returns to Welcome', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    c.read(sessionExpiryProvider.notifier).expire();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Sign out instead'));
    await tester.pump(const Duration(milliseconds: 600));
    await settle(tester);
    expect(c.read(sessionProvider), isNull);
    expect(c.read(sessionExpiryProvider), isFalse);
    expect(c.read(routerProvider).state.uri.path, Routes.welcome);
  });
}
