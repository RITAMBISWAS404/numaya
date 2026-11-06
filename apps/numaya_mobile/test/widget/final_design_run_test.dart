import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Final design run (docs/design-experiments/final-design-run/): regressions found on the emulator
/// that the earlier golden-only passes could not see.
void main() {
  setUpAll(loadAppFonts);

  group('FD-B1: button labels wrap instead of truncating', () {
    testWidgets('Welcome CTA is whole at 320pt and 200% text', (tester) async {
      await usePhoneSize(tester, size: const Size(320, 568));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(testApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final label = find.text('Create an account');
      expect(label, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(label);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a normal-size button keeps its 56pt height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NumayaButton(label: 'Continue', onPressed: () {}),
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(NumayaButton)).height,
        AppSizes.buttonHeight,
      );
    });
  });

  group('FD-B2: compact floating decision row', () {
    Widget bar({required bool floating}) => MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: DecisionBar(
            passLabel: 'Pass',
            superLabel: 'SuperSwipe',
            likeLabel: 'Like',
            onPass: () {},
            onSuper: () {},
            onLike: () {},
            floating: floating,
          ),
        ),
      ),
    );

    testWidgets('floating: three 56pt circles, centred, labels in semantics', (
      tester,
    ) async {
      await tester.pumpWidget(bar(floating: true));
      final row = tester.getRect(
        find
            .descendant(
              of: find.byType(DecisionBar),
              matching: find.byType(Row),
            )
            .first,
      );
      expect(row.width, 3 * DecisionBar.height + 2 * AppSpacing.s4);
      expect(row.center.dx, closeTo(400, 1)); // the 800-wide test surface
      for (final label in ['Pass', 'SuperSwipe', 'Like']) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
        expect(find.byTooltip(label), findsOneWidget);
      }
      // Icon-only: no visible label text.
      expect(find.text('Pass'), findsNothing);
    });

    testWidgets('inline: the labelled full-width row is unchanged', (
      tester,
    ) async {
      await tester.pumpWidget(bar(floating: false));
      expect(find.text('Pass'), findsOneWidget);
      expect(find.text('Like'), findsOneWidget);
      expect(tester.getSize(find.byType(DecisionBar)).width, 760);
    });
  });

  group('FD-D: header actions', () {
    Rect rectOf(WidgetTester tester, String label) => tester.getRect(
      find
          .ancestor(
            of: find.bySemanticsLabel(label),
            matching: find.byType(NavIconButton),
          )
          .first,
    );

    testWidgets('D1: two header actions keep an 8pt gap (Event detail)', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, overrides: eventsOn);
      await goTo(c, tester, '${Routes.event}/e-jazz');
      final share = rectOf(tester, 'Share');
      final save = rectOf(tester, 'Save Late jazz at the Vortex');
      expect(save.left - share.right, AppSpacing.s2);
      await settle(tester);
    });

    testWidgets('D2: Edit profile header follows Ente Header (v2)', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.editProfile);
      final buttons = tester
          .widgetList<NavIconButton>(
            find.descendant(
              of: find.byType(NumayaTopBar),
              matching: find.byType(NavIconButton),
            ),
          )
          .toList();
      expect(buttons, hasLength(2));
      // A bare back arrow, then the action as a filled 38pt Icon Button.
      expect(buttons.first.style, NavButtonStyle.plain);
      expect(buttons.last.style, NavButtonStyle.floating);
      await settle(tester);
    });
  });

  group('FD-A1: no unfinished art on product screens', () {
    for (final route in [
      Routes.safety,
      Routes.openingMoves,
      Routes.premium,
      Routes.completion,
      Routes.visibilityAbout,
    ]) {
      testWidgets('$route shows no illustration placeholder', (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, route);
        expect(find.textContaining('Illustration:'), findsNothing);
        for (final slot in tester.widgetList<IllustrationSlot>(
          find.byType(IllustrationSlot),
        )) {
          if (slot.asset == null) {
            // Nothing is drawn: no height (a stretching column may still give it width).
            expect(
              tester.getSize(find.byWidget(slot)).height,
              0,
              reason: slot.slot,
            );
          }
        }
        await settle(tester);
      });
    }

    testWidgets('the Design Lab still shows named placeholders', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.designLab);
      await tester.scrollUntilVisible(
        find.textContaining('Illustration:').first,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Illustration:'), findsWidgets);
      await settle(tester);
    });
  });
}
