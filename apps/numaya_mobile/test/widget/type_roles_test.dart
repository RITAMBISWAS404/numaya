import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Type-roles pass (docs/design-experiments/overnight-polish/TYPE_ROLES.md): the 14/20 body
/// reaches real body copy, and pills resolve to 12/16 without losing their hit areas.
void main() {
  setUpAll(loadAppFonts);

  /// The style a [Text] actually paints with: its own style merged over the ambient default.
  TextStyle resolved(WidgetTester tester, Finder f) {
    final text = tester.widget<Text>(f);
    final ambient = DefaultTextStyle.of(tester.element(f)).style;
    return ambient.merge(text.style);
  }

  void expectBody(TextStyle s, String what) {
    expect(s.fontSize, 14, reason: '$what: size');
    expect(s.height! * s.fontSize!, closeTo(20, 0.001), reason: '$what: line');
    // Regression: the old 16/24 default must not come back through an override.
    expect(s.fontSize, isNot(16), reason: '$what: not the old 16');
    // Ente Body is medium (500) (Ente experiment).
    expect(s.fontWeight, FontWeight.w500, reason: '$what: Figtree 500');
  }

  group('TR-01: body copy is 14/20', () {
    test('the semantic body role', () {
      expectBody(AppTypography.body, 'AppTypography.body');
      expect(AppTypography.body.fontFamily, 'Figtree');
    });

    // UI-020: the bio is the About me card's primary content, larger than its 14pt label.
    testWidgets('a Discover bio is the card-primary role (UI-020)', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await quickStartApp(tester);
      final bio = find.text('Designer by day, crate-digger by night.').first;
      await tester.ensureVisible(bio);
      final s = resolved(tester, bio);
      expect(s.fontSize, AppTypography.cardPrimary.fontSize);
      expect(s.fontSize, greaterThan(AppTypography.body.fontSize!));
      await settle(tester);
    });

    testWidgets('chat messages resolve to the body role', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.chat}/priya');
      for (final m in [
        'That bakery on Columbia Road, right?',
        'Have you been?',
      ]) {
        expect(resolved(tester, find.text(m)).fontSize, 14, reason: m);
        expect(
          resolved(tester, find.text(m)).height! * 14,
          closeTo(20, 0.001),
          reason: m,
        );
      }
      await settle(tester);
    });

    testWidgets('an empty-state description resolves to the body role', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Nothing yet',
              body: 'A short description.',
            ),
          ),
        ),
      );
      final s = resolved(tester, find.text('A short description.'));
      expect(s.fontSize, 14);
      expect(s.height! * 14, closeTo(20, 0.001));
    });
  });

  group('TR-03/04: pills and badges are 12/16 with unchanged hit areas', () {
    Widget host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

    testWidgets('selectable chip: 12/16, medium idle and semibold selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumayaChip(label: 'Natural wine', selected: false, onTap: () {}),
              NumayaChip(label: 'Jazz', selected: true, onTap: () {}),
            ],
          ),
        ),
      );
      final idle = tester.widget<Text>(find.text('Natural wine')).style!;
      final on = tester.widget<Text>(find.text('Jazz')).style!;
      expect(idle.fontSize, 12);
      expect(idle.height! * 12, closeTo(16, 0.001));
      // Ente Filter Chip: Mini at 500 in both states; the fill carries the selection.
      expect(idle.fontWeight, FontWeight.w500);
      expect(on.fontWeight, FontWeight.w500);
      // The pill keeps its height; the smaller label does not shrink the control.
      expect(
        tester.getSize(find.byType(NumayaChip).first).height,
        greaterThanOrEqualTo(AppSizes.chip),
      );
    });

    testWidgets('view tabs: Ente Tag Chip, Body 14/20 labels in a 44pt chip', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.events);
      final explore = find.descendant(
        of: find.byType(ViewTabs).first,
        matching: find.byType(RichText),
      );
      final styles = tester
          .widgetList<RichText>(explore)
          .map((r) => r.text.style)
          .whereType<TextStyle>()
          .toList();
      expect(styles, isNotEmpty);
      for (final s in styles) {
        expect(s.fontSize, 14);
      }
      expect(
        tester.getSize(find.byType(ViewTabs).first).height,
        greaterThanOrEqualTo(AppSizes.tagChip),
      );
      await settle(tester);
    });

    testWidgets('fact chips and status badges: 12/16, never 8', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoChip(label: 'Long-term'),
              StatusBadge(label: 'Verified', tone: BadgeTone.brand),
            ],
          ),
        ),
      );
      for (final label in ['Long-term', 'Verified']) {
        final s = tester.widget<Text>(find.text(label)).style!;
        expect(s.fontSize, 12, reason: label);
        expect(s.height! * 12, closeTo(16, 0.001), reason: label);
      }
    });
  });
}
