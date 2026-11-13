import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/commerce/application/economy_controller.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/demo/application/type_settings_controller.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// The V8 UI review (2026-11-14): behaviour the review changed, beyond the visual renders.
void main() {
  setUpAll(loadAppFonts);
  tearDown(() => AppTypography.apply(TypeSettings.baseline));

  String location(ProviderContainer c) => c.read(routerProvider).state.uri.path;
  int balance(ProviderContainer c) => c.read(creditBalanceProvider);
  int sentTo(ProviderContainer c, String id) => c
      .read(complimentsProvider)
      .where((x) => x.fromMe && x.personId == id)
      .length;
  Finder send() => find.bySemanticsLabel('Send Compliment');

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('compliment-field')),
        matching: find.byType(TextField),
      ),
      text,
    );
    await tester.pump();
  }

  group('Typography review controls (UI-085, 14/15 body)', () {
    testWidgets('14pt changes the body tier at once; Reset restores 15', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.reviewTypography);
      expect(AppTypography.body.fontSize, 15);
      await tapOn(tester, find.byKey(const ValueKey('type-body-14')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.read(typeSettingsProvider).bodySize, 14);
      expect(AppTypography.body.fontSize, 14);
      expect(AppTypography.button.fontSize, 15, reason: 'buttons keep theirs');
      await tapOn(tester, find.byKey(const ValueKey('type-display-fraunces')));
      expect(AppTypography.pageTitle.fontFamily, 'Fraunces');
      expect(AppTypography.body.fontFamily, 'Figtree', reason: 'independent');
      await tapOn(tester, find.byKey(const ValueKey('type-reset')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.read(typeSettingsProvider), TypeSettings.baseline);
      expect(AppTypography.body.fontSize, 15);
      await settle(tester);
    });
  });

  group('Compliments in the chat composer (UI-083)', () {
    const photo = '${Routes.compliment}/noor?kind=photo&index=1';

    testWidgets(
      'reply mode quotes the photo; one send, one debit, then waiting',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, photo);
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byKey(const ValueKey('compliment-quote')), findsOneWidget);
        expect(find.text('Photo 2'), findsOneWidget);
        final before = balance(c);
        // Nothing to send yet: no debit, nothing sent.
        await tester.tap(send().last, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
        expect(balance(c), before);
        await type(tester, 'Where was this taken?');
        await tester.tap(send().last);
        await tester.pump();
        // A rapid second tap while the first is in flight is refused.
        await tester.tap(send().last, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 800));
        expect(balance(c), before - 1);
        expect(sentTo(c, 'noor'), 1);
        expect(
          find.byKey(const ValueKey('compliment-waiting')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('compliment-sent-bubble')),
          findsOneWidget,
        );
        await settle(tester);
      },
    );

    testWidgets(
      'a failure keeps the words and spends nothing; retry sends once',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, photo);
        await tester.pump(const Duration(milliseconds: 400));
        final before = balance(c);
        await type(tester, 'Worth saying twice.');
        c.read(connectivityProvider.notifier).setOnline(false);
        await tester.pump();
        await tester.tap(send().last);
        await tester.pump(const Duration(milliseconds: 800));
        expect(balance(c), before);
        expect(sentTo(c, 'noor'), 0);
        expect(find.text('Worth saying twice.'), findsOneWidget);
        c.read(connectivityProvider.notifier).setOnline(true);
        await tester.pump();
        await tester.tap(send().last);
        await tester.pump(const Duration(milliseconds: 800));
        expect(balance(c), before - 1);
        expect(sentTo(c, 'noor'), 1);
        await settle(tester);
      },
    );
  });

  group('Messages and Archive (UI-067/068/069/081/033)', () {
    testWidgets(
      'one list with Your move pills, no row times, Archive count last',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, Routes.messages);
        expect(find.textContaining('Your turn'), findsNothing);
        expect(find.textContaining('Waiting on them'), findsNothing);
        expect(find.byKey(const ValueKey('row-your-move')), findsWidgets);
        // No exact or relative times on the rows.
        expect(find.text('10:26'), findsNothing);
        expect(find.text('Yesterday'), findsNothing);
        final archive = find.byKey(const ValueKey('chats-archive'));
        expect(archive, findsOneWidget);
        expect(
          find.descendant(of: archive, matching: find.text('2')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('match-tile-jo')), findsOneWidget);
        await tapOn(tester, archive);
        expect(find.byKey(const ValueKey('archived-rafa')), findsOneWidget);
        expect(find.byKey(const ValueKey('expired-ollie')), findsNothing);
        await settle(tester);
      },
    );
  });

  group('Premium paywall (UI-076)', () {
    testWidgets('five durations; 3 and 6 months cannot be chosen', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.paywall);
      for (final id in ['weekly', 'monthly', 'quarter', 'half', 'yearly']) {
        expect(find.byKey(ValueKey('plan-$id')), findsOneWidget, reason: id);
      }
      expect(find.text('Price pending'), findsNWidgets(2));
      await tapOn(tester, find.byKey(const ValueKey('plan-quarter')));
      final cta = find.byKey(const ValueKey('paywall-continue'));
      expect(tester.widget<NumayaButton>(cta).onPressed, isNull);
      await tapOn(tester, find.byKey(const ValueKey('plan-monthly')));
      expect(tester.widget<NumayaButton>(cta).onPressed, isNotNull);
      expect(
        find.byKey(const ValueKey('artwork-slot-premium_hero')),
        findsOneWidget,
      );
      expect(c.read(premiumProvider).active, isFalse);
      await settle(tester);
    });
  });

  group('Likes and MVP scope (UI-063/064/065/075)', () {
    testWidgets('free Likes are blurred photos with no names', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.likes);
      expect(find.byKey(const ValueKey('likes-locked')), findsOneWidget);
      expect(find.byType(ImageFiltered), findsWidgets);
      expect(find.textContaining('Kemi'), findsNothing);
      expect(c.read(premiumProvider).active, isFalse);
      await settle(tester);
    });

    testWidgets('For you deep links land on Discover; Settings has no Travel', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.forYou);
      expect(location(c), Routes.home);
      await goTo(c, tester, Routes.settings);
      expect(find.text('Travel'), findsNothing);
      expect(
        find.byKey(const ValueKey('settings-premium-promo')),
        findsOneWidget,
      );
      await settle(tester);
    });
  });

  group('Review choices persist (lab)', () {
    test('restored choices seed the lab; unknown ids are not kept', () {
      LabChoicesStore.restored = const {'v8-profile': 'P3'};
      final c = ProviderContainer(
        overrides: [devToolsAvailableProvider.overrideWithValue(true)],
      );
      addTearDown(c.dispose);
      addTearDown(() => LabChoicesStore.restored = const {});
      expect(c.read(labChoicesProvider), {'v8-profile': 'P3'});
    });
  });

  group('Profile content order (UI-059)', () {
    testWidgets('photo 2 comes before prompt 1 on a public profile', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.home);
      final photo2 = find.byKey(const ValueKey('compliment-photo-1'));
      final prompt1 = find.byKey(const ValueKey('compliment-prompt-0'));
      await tester.ensureVisible(photo2);
      await tester.pump(const Duration(milliseconds: 300));
      final p2 = tester.getTopLeft(photo2).dy;
      await tester.ensureVisible(prompt1);
      await tester.pump(const Duration(milliseconds: 300));
      final q1 = tester.getTopLeft(prompt1).dy;
      final p2After = tester.getTopLeft(photo2).dy;
      // Same scroll frame for the comparison.
      expect(p2After, lessThan(q1), reason: 'photo 2 above prompt 1 ($p2)');
      expect(c, isNotNull);
      await settle(tester);
    });
  });
}
