import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/design_system/icons/lucide_icons.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Ente design system experiment (docs/design-experiments/ente-design-system/): the contract the
/// shared components now follow, and the regressions found on the emulator.
void main() {
  setUpAll(loadAppFonts);

  test('every shared icon name has one Lucide glyph (ED-03)', () {
    for (final icon in NumayaIcons.values) {
      expect(kLucideIcons[icon], isNotNull, reason: icon.name);
      expect(kLucideIcons[icon]!.fontFamily, 'Lucide', reason: icon.name);
    }
    for (final icon in NumayaMobileIcons.values) {
      expect(kLucideMobileIcons[icon], isNotNull, reason: icon.name);
    }
    // Back controls draw Ente's arrow, not a chevron.
    expect(kLucideIcons[NumayaIcons.chevronLeft], LucideIcons.arrowLeft);
  });

  testWidgets('Button Large: 52pt, 20pt corners, Body label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: NumayaButton(label: 'Save', onPressed: () {}),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(NumayaButton)).height, 52);
    final box = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(NumayaButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect((box.decoration! as BoxDecoration).borderRadius, AppRadii.all(20));
    final label = tester.widget<Text>(find.text('Save')).style!;
    expect(label.fontSize, 14);
    expect(label.fontWeight, FontWeight.w500);
  });

  testWidgets('inner pages use Ente Header (v2): bare back arrow, title left', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.settings);
    final back = tester
        .widgetList<NavIconButton>(
          find.descendant(
            of: find.byType(NumayaTopBar),
            matching: find.byType(NavIconButton),
          ),
        )
        .first;
    expect(back.style, NavButtonStyle.plain);
    final bar = tester.getRect(find.byType(NumayaTopBar));
    final title = tester.getRect(
      find.descendant(
        of: find.byType(NumayaTopBar),
        matching: find.text('Settings'),
      ),
    );
    // Left-aligned beside the back button, not centred.
    expect(title.left - bar.left, lessThan(bar.width / 4));
    await settle(tester);
  });

  testWidgets(
    'search hint stays on one line at 320pt and 150% text (device pass)',
    (tester) async {
      await usePhoneSize(tester, size: const Size(320, 568));
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.messages);
      await tester.tap(
        find.bySemanticsLabel('Search names and messages').first,
      );
      await tester.pump(const Duration(milliseconds: 300));
      final field = find.byType(NumayaSearchField);
      expect(field, findsOneWidget);
      final hint = find.descendant(
        of: field,
        matching: find.textContaining('Search'),
      );
      // One 20pt line at 150% is 30pt; two lines would be 60.
      final paragraph = tester.renderObject<RenderParagraph>(hint.first);
      expect(paragraph.size.height, lessThan(40));
      expect(tester.takeException(), isNull);
      await settle(tester);
    },
  );

  testWidgets('settings rows are separate Ente Menu Item cards', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.settings);
    final cards = find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color == AppColors.surface &&
          (w.decoration as BoxDecoration).borderRadius ==
              AppRadii.all(AppRadii.card),
    );
    expect(cards, findsWidgets);
    expect(tester.getSize(cards.first).height, greaterThanOrEqualTo(60));
    await settle(tester);
  });
}
