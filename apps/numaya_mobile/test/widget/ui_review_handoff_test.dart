import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/onboarding/domain/height_units.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/features/profile/domain/profile_details.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// The onboarding UI review handoff (UI-001 to UI-012, NUMAYA_UI_REVIEW.md): behaviour the review
/// changed, checked by issue ID.
void main() {
  setUpAll(loadAppFonts);

  Future<ProviderContainer> newAccount(WidgetTester tester) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp());
    await tester.pump();
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    c.read(sessionProvider.notifier).quickStartOnboarding();
    await goTo(c, tester, Routes.setup);
    return c;
  }

  group('UI-006: height units', () {
    test('one rounding rule both ways, inside the limits', () {
      expect(HeightUnits.inchesFromCm(170), 67); // 66.9 → 67
      expect(HeightUnits.cmFromInches(67), 170); // 170.18 → 170
      for (final cm in HeightUnits.cmOptions) {
        final back = HeightUnits.cmFromInches(HeightUnits.inchesFromCm(cm));
        expect((back - cm).abs(), lessThanOrEqualTo(1), reason: '$cm cm');
      }
      for (final i in HeightUnits.inchOptions) {
        final cm = HeightUnits.cmFromInches(i);
        expect(
          cm,
          inInclusiveRange(DetailRules.minHeight, DetailRules.maxHeight),
        );
      }
      expect(HeightUnits.cmOptions.first, DetailRules.minHeight);
      expect(HeightUnits.cmOptions.last, DetailRules.maxHeight);
    });
  });

  group('UI-006: inline height wheel', () {
    testWidgets('usable on arrival; opening and continuing records nothing', (
      tester,
    ) async {
      final c = await newAccount(tester);
      await goTo(c, tester, Routes.setupHeight);
      expect(find.text('Add my height'), findsNothing);
      expect(find.byType(CupertinoPicker), findsOneWidget);
      // The wheel rests on 170 cm, but nothing is saved for just looking.
      expect(find.text('170 cm'), findsOneWidget);
      expect(c.read(profileDetailsProvider).heightCm, isNull);
      await tapNext(tester);
      expect(c.read(profileDetailsProvider).heightCm, isNull);
      await settle(tester);
    });

    testWidgets('scrolling records whole centimetres; ft/in keeps the height', (
      tester,
    ) async {
      final c = await newAccount(tester);
      await goTo(c, tester, Routes.setupHeight);
      // Up by three rows.
      await tester.drag(find.byType(CupertinoPicker), const Offset(0, -132));
      await tester.pumpAndSettle();
      expect(c.read(profileDetailsProvider).heightCm, 173);
      // ft/in shows the same height, and switching units saves nothing new.
      await tapOn(tester, find.text('ft / in'));
      await tester.pumpAndSettle();
      expect(find.text('5′ 8″'), findsWidgets); // 173 cm = 68.1 in → 68
      expect(c.read(profileDetailsProvider).heightCm, 173);
      // One inch up in ft/in: 69 in → 175 cm.
      await tester.drag(find.byType(CupertinoPicker), const Offset(0, -44));
      await tester.pumpAndSettle();
      expect(c.read(profileDetailsProvider).heightCm, 175);
      await settle(tester);
    });

    testWidgets('Skip leaves height unset; a saved height is kept on return', (
      tester,
    ) async {
      final c = await newAccount(tester);
      c.read(profileDetailsProvider.notifier).setHeight(181);
      await goTo(c, tester, Routes.setupHeight);
      // Reopening shows the saved value, not the default.
      expect(find.text('181 cm'), findsOneWidget);
      await tapOn(tester, find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.read(profileDetailsProvider).heightCm, isNull);
      await settle(tester);
    });
  });

  group('UI-004/UI-005: age range', () {
    testWidgets('label, read-out and slider share one card', (tester) async {
      final c = await newAccount(tester);
      await goTo(c, tester, Routes.setupMeet);
      final card = find.byKey(const ValueKey('age-range-card'));
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.byType(RangeSlider)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('Their age')),
        findsOneWidget,
      );
      await settle(tester);
    });

    testWidgets('each thumb shows its own exact age while it moves', (
      tester,
    ) async {
      var values = const RangeValues(26, 38);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: StatefulBuilder(
                  builder: (context, set) => AgeRangeSlider(
                    values: values,
                    min: 18,
                    max: 80,
                    onChanged: (v) => set(() => values = v),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      // At rest, neither thumb shows a pop-up.
      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.labels!.start, '');
      expect(slider.labels!.end, '');
      final theme = SliderTheme.of(tester.element(find.byType(RangeSlider)));
      expect(theme.showValueIndicator, ShowValueIndicator.onDrag);

      final rect = tester.getRect(find.byType(RangeSlider));
      // Track geometry: the overlay padding sits at each end of the track.
      double xFor(double v) {
        const pad = 24.0;
        return rect.left + pad + (rect.width - 2 * pad) * (v - 18) / (80 - 18);
      }

      // Lower thumb: drag right by a few years; its label follows the value.
      final lower = await tester.startGesture(Offset(xFor(26), rect.center.dy));
      await lower.moveBy(const Offset(30, 0));
      await tester.pump();
      final movedLower = values.start.round();
      expect(movedLower, greaterThan(26));
      // Only the active (lower) thumb has a label.
      final whileLower = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(whileLower.labels!.start, '$movedLower');
      expect(whileLower.labels!.end, '');
      await lower.up();
      await tester.pump();

      // Upper thumb: drag left; the upper label follows.
      final upper = await tester.startGesture(Offset(xFor(38), rect.center.dy));
      await upper.moveBy(const Offset(-20, 0));
      await tester.pump();
      final movedUpper = values.end.round();
      expect(movedUpper, lessThan(38));
      final whileUpper = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(whileUpper.labels!.end, '$movedUpper');
      expect(whileUpper.labels!.start, '');
      await upper.up();
      await tester.pump(const Duration(milliseconds: 600));
    });
  });

  group('UI-008: prompt browser and answer sheet', () {
    testWidgets('categories with ten or more prompts each, as chevron cards', (
      tester,
    ) async {
      expect(kPromptCategories.length, greaterThanOrEqualTo(3));
      for (final c in kPromptCategories) {
        expect(c.prompts.length, greaterThanOrEqualTo(10), reason: c.name);
      }
      // No prompt appears in two categories.
      expect(kPromptQuestions.toSet().length, kPromptQuestions.length);

      final c = await newAccount(tester);
      await goTo(c, tester, '${Routes.prompt}?slot=0');
      for (final cat in kPromptCategories) {
        expect(find.text(cat.name), findsOneWidget);
      }
      await tapOn(tester, find.text('Opinions'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Let’s debate this'), findsOneWidget);
      expect(find.text('A perfect first date'), findsNothing);
      await settle(tester);
    });

    testWidgets(
      'select, write, save to the slot; reopen edits it; close keeps it',
      (tester) async {
        final c = await newAccount(tester);
        await goTo(c, tester, Routes.setupPrompts);
        await tapOn(tester, find.text('Add a prompt'));
        await tester.pump(const Duration(milliseconds: 600));
        await tapOn(tester, find.text('A green flag'));
        await tester.pump(const Duration(milliseconds: 600));
        // The sheet shows the exact prompt, with the answer field below it.
        expect(find.text('A green flag'), findsWidgets);
        expect(find.text('150 characters left'), findsOneWidget);
        await tester.enterText(find.byType(TextField).last, 'Remembers names.');
        await tester.pump();
        expect(find.text('134 characters left'), findsOneWidget);
        await tapOn(tester, find.text('Save prompt'));
        await tester.pump(const Duration(milliseconds: 600));
        expect(
          c.read(onboardingProvider).draft.prompt?.question,
          'A green flag',
        );
        expect(
          c.read(onboardingProvider).draft.prompt?.answer,
          'Remembers names.',
        );

        // Reopen: the saved prompt is marked, and its sheet starts with the saved answer.
        await goTo(c, tester, '${Routes.prompt}?slot=0');
        expect(find.text('Your current prompt'), findsOneWidget);
        await tapOn(tester, find.text('A green flag'));
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Remembers names.'), findsOneWidget);
        // Edit, then close without saving: the saved answer stays.
        await tester.enterText(find.byType(TextField).last, 'Something else.');
        await tester.pump();
        await tapOn(tester, find.bySemanticsLabel('Cancel').last);
        await tester.pump(const Duration(milliseconds: 600));
        expect(
          c.read(onboardingProvider).draft.prompt?.answer,
          'Remembers names.',
        );
        await settle(tester);
      },
    );
  });

  group('UI-002/UI-007/UI-009/UI-010: shared components', () {
    testWidgets('a standalone secondary action is a filled button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NumayaButton(
                label: 'Maybe later',
                variant: NumayaButtonVariant.quiet,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      final box = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(NumayaButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      // V8: a standalone secondary action is outlined on a faint wash, not a grey slab.
      final deco = box.decoration! as BoxDecoration;
      expect(deco.color, AppColors.buttonWash);
      expect(deco.border, isNotNull);
      expect(
        tester.getSize(find.byType(NumayaButton)).height,
        AppSizes.buttonHeight,
      );
    });

    testWidgets('prompt card: small label above a dominant answer, no icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PromptCard(question: 'My Sunday ritual', answer: 'Pastries.'),
          ),
        ),
      );
      final q = tester.widget<Text>(find.text('My Sunday ritual')).style!;
      final a = tester.widget<Text>(find.text('Pastries.')).style!;
      expect(q.fontSize, lessThan(a.fontSize!));
      expect(q.color, AppColors.textMuted);
      expect(find.byType(PromptMark), findsNothing);
      expect(
        tester.getTopLeft(find.text('My Sunday ritual')).dy,
        lessThan(tester.getTopLeft(find.text('Pastries.')).dy),
      );
    });

    testWidgets('heading illustration sits above the heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScreenHeader(
              title: 'Verify your photos?',
              art: SizedBox(width: 72, height: 72, child: Placeholder()),
            ),
          ),
        ),
      );
      final art = tester.getRect(find.byType(Placeholder));
      final title = tester.getRect(find.text('Verify your photos?'));
      expect(art.bottom, lessThanOrEqualTo(title.top));
      expect(art.height, ScreenHeader.artSize);
    });

    // Superseded by the Tabler MVP pass: the alert icon is centred on the full content height
    // (was UI-010's first-line alignment).
    testWidgets('alert icon is centred on multiline copy (Tabler MVP pass)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              child: InfoCard(
                icon: NumayaIcons.shield,
                title: 'The selfie is only used to check your photos. It isn’t shown on your profile.',
              ),
            ),
          ),
        ),
      );
      final icon = tester.getRect(find.byType(NumayaIcon));
      final text = tester.getRect(find.textContaining('The selfie'));
      expect(text.height, greaterThan(icon.height * 1.5)); // multiline
      // Centred on the content column (the title block), not the first line.
      final content = tester.getRect(
        find
            .ancestor(
              of: find.textContaining('The selfie'),
              matching: find.byType(Column),
            )
            .first,
      );
      expect((icon.center.dy - content.center.dy).abs(), lessThanOrEqualTo(1));
    });
  });
}
