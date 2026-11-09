import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// MVP Focus V5 (docs/product/mvp-focus-v5/SCOPE_DELTA.md): Events and Health are deferred. They
/// must be absent from the UI and unreachable from any saved link.
void main() {
  setUpAll(loadAppFonts);

  const deferredEvents = [
    Routes.events,
    '${Routes.events}?view=mine',
    Routes.evMine,
    '${Routes.evEvent}/ev-board-games-bandra',
    '${Routes.evEvent}/ev-board-games-bandra/reserve',
    '${Routes.evReservation}/ev-cycle-ride',
    '${Routes.evNotice}/n-walk-v2',
    '${Routes.evMet}/ev-book-swap',
    Routes.evProposals,
    '${Routes.evPropose}/p-chess',
    Routes.staff,
    '${Routes.staffProposal}/p-chess',
    '${Routes.staffEvent}/ev-board-games-bandra',
    Routes.event,
    Routes.eventNew,
    '${Routes.event}/old-id',
  ];
  const retiredHealth = [
    Routes.health,
    Routes.healthAbout,
    Routes.insights,
    Routes.visibility,
    Routes.visibilityAbout,
  ];

  String at(ProviderContainer c) =>
      c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;

  testWidgets('the bar has four destinations, each selecting correctly', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await quickStartApp(tester);
    final bar = find.byType(NumayaTabBar);
    expect(
      find.descendant(of: bar, matching: find.byTooltip('Events')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('tab-tile-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-tile-4')), findsNothing);
    for (final (label, index) in [
      ('Likes', 1),
      ('Messages', 2),
      ('Profile', 3),
      ('Home', 0),
    ]) {
      await openTab(tester, label);
      expect(
        tester.widget<NumayaTabBar>(bar).currentIndex,
        index,
        reason: label,
      );
    }
    await settle(tester);
  });

  testWidgets('every deferred Events link lands on Discover, without a crash', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    for (final path in deferredEvents) {
      await goTo(c, tester, Routes.profile);
      await goTo(c, tester, path);
      expect(at(c), Routes.home, reason: path);
      expect(tester.takeException(), isNull, reason: path);
    }
    await settle(tester);
  });

  testWidgets('every retired Health link lands on Profile, with no note', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    for (final path in retiredHealth) {
      await goTo(c, tester, Routes.home);
      await goTo(c, tester, path);
      expect(at(c), Routes.profile, reason: path);
      expect(tester.takeException(), isNull, reason: path);
    }
    expect(find.textContaining('Insights'), findsNothing);
    await settle(tester);
  });

  testWidgets('signed out, a deferred link ends on Welcome without a loop', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp(auth: testAuth()));
    await tester.pump();
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    expect(c.read(sessionProvider), isNull);
    await goTo(c, tester, '${Routes.evEvent}/ev-board-games-bandra');
    expect(at(c), Routes.welcome);
    expect(tester.takeException(), isNull);
    await settle(tester);
  });

  testWidgets(
    'no Events or Health copy on the screens that used to link them',
    (tester) async {
      await usePhoneSize(tester, size: const Size(393, 3200));
      final c = await quickStartApp(tester);
      for (final path in [
        Routes.profile,
        Routes.settings,
        Routes.premium,
        Routes.paywall,
        '${Routes.paywall}?feature=insights',
        Routes.notifications,
        Routes.help,
      ]) {
        await goTo(c, tester, path);
        for (final word in ['Events', 'Profile Health', 'Insights']) {
          expect(
            find.textContaining(word),
            findsNothing,
            reason: '$path $word',
          );
        }
      }
      await settle(tester);
    },
  );

  testWidgets('an empty Chats tab does not offer events', (tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, Routes.messages);
    expect(find.text('Find an event'), findsNothing);
    await settle(tester);
  });
}
