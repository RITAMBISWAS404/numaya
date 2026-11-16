import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/presentation/v10_person_sections.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// V10 People-first direction (docs/v10/DESIGN_CONTRACT.md): the contract rows that are not
/// covered by the older suites.
void main() {
  // Real fonts: text-scale layout is judged with the app's type, as in large_text_regression_test.
  setUpAll(loadAppFonts);

  test('V10 A is what ordinary launches render', () {
    final g = kLabGroups.firstWhere((g) => g.id == 'v10-direction');
    expect(g.proposed, 'A');
    expect(g.variants.map((v) => v.id), containsAll(['O', 'A', 'C']));
  });

  group('C-6 received Compliment', () {
    testWidgets('a sender block, a visible reply tray and a Dismiss link', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, '${Routes.chat}/sam');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('v10-sender-avatar')), findsOneWidget);
      expect(find.text('Sam sent you a Compliment'), findsOneWidget);
      // DEF-V10-01: the reply field sits on a white tray, not page-on-page.
      final tray = find.byKey(const ValueKey('compliment-reply-tray'));
      expect(tray, findsOneWidget);
      expect(tester.widget<ColoredBox>(tray).color, AppColors.surface);
      final link = find.byKey(const ValueKey('compliment-dismiss-link'));
      expect(link, findsOneWidget);
      expect(tester.getSize(link).height, greaterThanOrEqualTo(44));
      final before = c.read(complimentsProvider.notifier).requests().length;
      await tapOn(tester, link);
      await tester.pump(const Duration(milliseconds: 600));
      // Dismiss still asks first (V8 rule); cancelling keeps the request.
      expect(find.byKey(const ValueKey('dismiss-confirm')), findsOneWidget);
      await tapOn(tester, find.byKey(const ValueKey('dismiss-confirm')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        c.read(complimentsProvider.notifier).requests().length,
        before - 1,
      );
      await settle(tester);
    });
  });

  group('C-5 own Profile', () {
    testWidgets(
      'Premium stays in Your profile; the prompt card has a chevron',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        c.read(onboardingProvider.notifier).loadSample();
        await goTo(c, tester, Routes.profile);
        await settle(tester);
        final premium = find.text('Numaya Premium');
        await tester.scrollUntilVisible(
          premium,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        // D7: no orphaned, headerless Premium card; it is a row of the Your profile group.
        expect(find.byKey(const ValueKey('v10-premium-group')), findsNothing);
        final group = find.ancestor(
          of: premium,
          matching: find.byType(ListGroup),
        );
        expect(
          find.descendant(of: group, matching: find.text('Verify my profile')),
          findsOneWidget,
        );
        // The prompt opens its editor from the whole card, with no text link.
        expect(find.text('Edit your prompt'), findsNothing);
        final card = find.byType(V10PromptCard);
        expect(card, findsOneWidget);
        // Read once: one node carries the question and answer (DEF-V10-03).
        final handle = tester.ensureSemantics();
        expect(
          tester
              .getSemantics(
                find
                    .descendant(of: card, matching: find.byType(Semantics))
                    .first,
              )
              .label,
          'A perfect first date. A record shop, a long walk, and nowhere to be after.',
        );
        handle.dispose();
        await tester.scrollUntilVisible(
          card,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tapOn(tester, card);
        await settle(tester);
        expect(c.read(routerProvider).state.matchedLocation, Routes.editPrompt);
      },
    );
  });

  // PR-004 (partial): the SDK text-contrast guideline on Discover scrolled to the About sheet
  // (everything else on screen is measured too). Text over the hero photo is not covered here.
  testWidgets(
    'PR-004: Discover About sheet meets the text contrast guideline',
    (tester) async {
      await usePhoneSize(tester);
      final handle = tester.ensureSemantics();
      await quickStartApp(tester);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -560));
      await settle(tester);
      expect(
        tester.getRect(find.byKey(const ValueKey('v10-about-sheet'))).top,
        lessThan(200),
      );
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    },
  );

  testWidgets(
    'C-6 at 200% text the sender photo shows once (header only), the Compliment stays in view',
    (tester) async {
      await usePhoneSize(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, '${Routes.chat}/sam');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('v10-sender-avatar')), findsNothing);
      expect(find.text('Sam sent you a Compliment'), findsOneWidget);
      await settle(tester);
    },
  );
}
