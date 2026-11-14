import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/presentation/conversation_row.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// UI-087..102 review phase (2026-11-15): behaviour and geometry of the new requirements.
void main() {
  setUpAll(loadAppFonts);
  tearDown(() => DevModeStyles.apply(TypeSettings.baseline));

  Widget host(Widget child) => MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );

  group('UI-087 identity and information pills', () {
    testWidgets('selector chips, fact chips and status badges are capsules', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          Wrap(
            children: [
              NumayaChip(label: 'Jazz', selected: true, onTap: () {}),
              NumayaChip(label: 'Hiking', selected: false, onTap: () {}),
              const InfoChip(label: '168 cm', emoji: '📏'),
              const StatusBadge(label: 'Your move'),
            ],
          ),
        ),
      );
      final radii = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.borderRadius)
          .whereType<BorderRadius>()
          .toList();
      expect(radii, isNotEmpty);
      for (final r in radii) {
        expect(r, AppRadii.all(AppRadii.infoPill));
      }
      expect(AppRadii.infoPill, AppRadii.pill);
    });
  });

  group('UI-088 / UI-070 icon categories', () {
    testWidgets('menu rows use outline glyphs', (tester) async {
      await tester.pumpWidget(
        host(
          ListGroup(
            children: [
              ListRow(
                leading: NumayaIcons.settings,
                label: 'Settings',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      final icon = tester.widget<NumayaIcon>(
        find.byWidgetPredicate(
          (w) => w is NumayaIcon && w.icon == NumayaIcons.settings,
        ),
      );
      expect(icon.filled, isFalse);
    });
  });

  group('UI-089 birthday placeholders', () {
    testWidgets('DD MM YYYY placeholders, no visible part labels, '
        'distinct accessible names', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.setupName);
      expect(find.text('Birthday'), findsOneWidget);
      for (final p in ['DD', 'MM', 'YYYY']) {
        expect(find.text(p), findsOneWidget, reason: p);
      }
      for (final label in ['Day', 'Month', 'Year']) {
        expect(find.text(label), findsNothing, reason: 'no visible $label');
        expect(find.bySemanticsLabel(label), findsWidgets, reason: label);
      }
      // Validation is unchanged: an impossible date is rejected.
      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(1), '31');
      await tester.enterText(fields.at(2), '02');
      await tester.enterText(fields.at(3), '1995');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('doesn’t exist'), findsWidgets);
      await settle(tester);
    });
  });

  group('UI-091 / UI-092 / UI-093 / UI-073 Compliment composer', () {
    const photo = '${Routes.compliment}/noor?kind=photo&index=1';

    testWidgets('thumbnail fills the panel inside matching insets; dismiss is '
        'outside and clears the quote', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, Routes.home);
      // Opened over Discover, as tapping a photo's Compliment control does.
      unawaited(c.read(routerProvider).push<void>(photo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      final thumb = tester.getRect(
        find.byKey(const ValueKey('reply-preview-thumb')),
      );
      final panel = tester.getRect(
        find.byKey(const ValueKey('reply-preview-panel')),
      );
      // Equal top, bottom and right insets: the quote line's 8pt.
      expect(thumb.top - panel.top, closeTo(8, 0.5));
      expect(panel.bottom - thumb.bottom, closeTo(8, 0.5));
      expect(panel.right - thumb.right, closeTo(8, 0.5));
      final dismiss = tester.getRect(
        find.byKey(const ValueKey('reply-preview-dismiss')),
      );
      expect(dismiss.left, greaterThanOrEqualTo(panel.right));
      expect(dismiss.center.dy, closeTo(panel.center.dy, 1));
      // The external control works: in a Compliment the quote is the target, so dismissing it
      // closes the composer as before (no draft, so no discard prompt).
      await tapOn(tester, find.byKey(const ValueKey('reply-preview-dismiss')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('reply-preview-panel')), findsNothing);
      await settle(tester);
    });

    testWidgets('credit info leads, counter trails at the field edge; '
        'enabled Send is filled and centred on the field', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, photo);
      await tester.enterText(find.byType(EditableText).last, 'Lovely light.');
      await tester.pump(const Duration(milliseconds: 400));
      final field = tester.getRect(find.byType(TextField).last);
      final counter = tester.getRect(
        find.byKey(const ValueKey('compliment-counter')),
      );
      final meta = tester.getRect(
        find.byKey(const ValueKey('compliment-meta')),
      );
      expect(counter.right, closeTo(field.right, 16.5));
      expect(counter.left, greaterThan(meta.center.dx));
      // Send: brand fill, white glyph.
      final send = find.descendant(
        of: find.byType(Composer),
        matching: find.byWidgetPredicate(
          (w) =>
              w is AnimatedContainer &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      final deco =
          tester.widget<AnimatedContainer>(send).decoration! as BoxDecoration;
      expect(deco.color, AppColors.accent);
      expect(deco.border, isNull);
      final arrow = tester.widget<NumayaIcon>(
        find.descendant(of: send, matching: find.byType(NumayaIcon)),
      );
      expect(arrow.color, AppColors.accentForeground);
      final input = tester.getRect(
        find
            .ancestor(
              of: find.byType(TextField).last,
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(tester.getRect(send).center.dy, closeTo(input.center.dy, 0.5));
      // UI-073: the field uses the app-background token, like the reply preview.
      expect(Composer.inputFill, AppColors.canvas);
      await settle(tester);
    });
  });

  group('UI-067 / UI-068 / UI-033 Messages', () {
    testWidgets('unread is an avatar dot, never a number; Your move trails', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, Routes.messages);
      expect(find.byType(CountBadge), findsNothing);
      expect(find.byKey(const ValueKey('row-unread-dot')), findsWidgets);
      final row = find
          .ancestor(
            of: find.byKey(const ValueKey('row-your-move')).first,
            matching: find.byType(ConversationRow),
          )
          .first;
      final pill = tester.getRect(
        find.byKey(const ValueKey('row-your-move')).first,
      );
      expect(tester.getRect(row).right - pill.right, lessThan(4));
      await settle(tester);
    });
  });

  group('UI-094 status template', () {
    for (final r in ['failed', 'pending', 'success']) {
      testWidgets('payment $r: centred group with its actions', (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(
          c,
          tester,
          '${Routes.storeOutcome}?kind=premiumMonthly&result=$r',
        );
        final group = tester.getRect(
          find.byKey(const ValueKey('status-template')),
        );
        final screen = tester.getRect(find.byType(Scaffold).last);
        // Centred in the area under the 56pt top bar (within the bar's height).
        final areaCentre = (screen.top + 56 + screen.bottom) / 2;
        expect((group.center.dy - areaCentre).abs(), lessThan(40));
        expect(group.center.dx, closeTo(screen.center.dx, 1));
        expect(find.byKey(const ValueKey('outcome-done')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('outcome-retry')),
          r == 'failed' ? findsOneWidget : findsNothing,
        );
        expect(find.text('Restore purchases'), findsOneWidget);
        await settle(tester);
      });
    }
  });

  group('UI-101 / UI-102 headers', () {
    testWidgets('one continuous track whose fill follows the step', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const Center(child: StepProgress(step: 2, steps: 5))),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('step-progress-track')), findsOneWidget);
      final track = tester.getRect(
        find.byKey(const ValueKey('step-progress-track')),
      );
      final fill = tester.getRect(
        find.byKey(const ValueKey('step-progress-fill')),
      );
      expect(fill.width / track.width, closeTo(2 / 5, 0.01));
    });

    testWidgets('no stroke under the top bar while scrolled', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.settings);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 500));
      final strokes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .where(
            (d) =>
                d.border is Border &&
                (d.border! as Border).bottom.width > 0 &&
                (d.border! as Border).top.width == 0,
          );
      expect(strokes, isEmpty);
      await settle(tester);
    });
  });

  group('UI-090 sliders', () {
    testWidgets(
      'every slider block keeps the 8pt clearance around the control',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, Routes.setupMeet);
        final block = find.byKey(const ValueKey('slider-block'));
        expect(block, findsOneWidget);
        final outer = tester.getRect(block);
        final slider = tester.getRect(
          find.descendant(of: block, matching: find.byType(RangeSlider)),
        );
        expect(slider.top - outer.top, SliderBlock.clearance);
        expect(outer.bottom - slider.bottom, SliderBlock.clearance);
        await settle(tester);
      },
    );
  });
}
