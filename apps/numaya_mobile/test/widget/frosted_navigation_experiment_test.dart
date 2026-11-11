import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/design_system/tokens/monochrome_tokens.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Frosted-navigation experiment (docs/design-experiments/frosted-navigation/): stage B
/// (typography and compact layout) and stage C (the frosted tab bar).
void main() {
  setUpAll(loadAppFonts);

  Widget host(Widget child, {double textScale = 1}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    ),
  );

  group('B: chips share one type role', () {
    testWidgets('a fact chip uses the chip role, not the card heading', (
      tester,
    ) async {
      await tester.pumpWidget(host(const InfoChip(label: 'Long-term')));
      final text = tester.widget<Text>(find.text('Long-term'));
      expect(text.style, AppTypography.chip);
      // Type-roles pass (TR-03): informational chips are 12/16.
      expect(AppTypography.chip.fontSize, 12);
      expect(AppTypography.chip.fontFamily, AppTypography.label.fontFamily);
      expect(AppTypography.chip.color, AppColors.ink);
    });

    testWidgets('a long value wraps instead of being cut off at 200% text', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 240,
            child: Wrap(
              children: [
                InfoChip(
                  label: 'Undergraduate degree in landscape architecture',
                  icon: NumayaIcons.tag,
                ),
              ],
            ),
          ),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.textContaining('Undergraduate'));
      expect(text.overflow, isNot(TextOverflow.ellipsis));
      expect(
        tester.getSize(find.byType(InfoChip)).height,
        greaterThan(AppSizes.chip),
      );
    });
  });

  // Ente experiment: the shipped bar is Ente's opaque Nav Bar; the frosted surface remains as a
  // comparison (Design Lab, High Contrast test below). The layout guarantees still apply.
  group('C: floating tab bar (Ente Nav Bar)', () {
    Finder bar() => find.byType(NumayaTabBar);
    Finder pillOf() => find.byKey(NumayaTabBar.pillKey);

    testWidgets(
      'nav bar: opaque white, fully rounded, soft shadow, no blur (UI-026, UI-027)',
      (tester) async {
        await usePhoneSize(tester);
        await quickStartApp(tester);
        expect(
          find.descendant(
            of: find.byType(NumayaTabBar),
            matching: find.byType(BackdropFilter),
          ),
          findsNothing,
        );
        final pill = tester.widget<Container>(pillOf());
        final deco = pill.decoration! as BoxDecoration;
        expect(deco.color, AppColors.surface);
        // UC-03: a stadium at any width.
        expect(deco.borderRadius, AppRadii.all(AppRadii.pill));
        expect(deco.boxShadow, AppElevation.navigation);
        expect(tester.getSize(pillOf()).height, AppSizes.tabBar);
        await settle(tester);
      },
    );

    testWidgets('system navigation keeps a page-colour strip under it', (
      tester,
    ) async {
      // A 48dp three-button bar, edge to edge.
      await usePhoneSize(tester);
      final dpr = tester.view.devicePixelRatio;
      tester.view.padding = FakeViewPadding(bottom: 48 * dpr);
      tester.view.viewPadding = FakeViewPadding(bottom: 48 * dpr);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      await quickStartApp(tester);
      final strip = find.descendant(
        of: bar(),
        matching: find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == MonoGlass.systemInset,
        ),
      );
      expect(strip, findsOneWidget);
      expect(tester.getSize(strip).height, 48);
      final screenBottom =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(tester.getBottomLeft(strip).dy, screenBottom);
      // The pill sits above the strip, never on the system buttons.
      final pill = tester.getRect(pillOf());
      expect(pill.bottom, lessThanOrEqualTo(screenBottom - 48));
      await settle(tester);
    });

    testWidgets('High Contrast falls back to the opaque pill', (tester) async {
      await usePhoneSize(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(highContrast: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await quickStartApp(tester);
      expect(
        find.descendant(
          of: find.byType(NumayaTabBar),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: bar(),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                (w.decoration as BoxDecoration?)?.color == AppColors.surface,
          ),
        ),
        findsOneWidget,
      );
      await settle(tester);
    });

    testWidgets(
      'selected: filled near-black glyph; unselected: light grey outlines (Tabler MVP pass)',
      (tester) async {
        await usePhoneSize(tester);
        await quickStartApp(tester);
        final icons = tester
            .widgetList<NumayaIcon>(
              find.descendant(of: bar(), matching: find.byType(NumayaIcon)),
            )
            .toList();
        // MVP Focus V5: four destinations.
        expect(icons, hasLength(4));
        // Discover is selected: Tabler's filled glyph in near-black; the others are outlines in
        // the light grey (3.46:1 on white, above WCAG 1.4.11's 3:1).
        expect(icons.first.filled, isTrue);
        expect(icons.first.color, AppColors.iconSelected);
        for (final icon in icons.skip(1)) {
          expect(icon.filled, isFalse);
          expect(icon.color, AppColors.iconInactive);
        }
        await settle(tester);
      },
    );

    testWidgets('tab content can scroll clear of the bar', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.profile);
      final scroll = find.byType(Scrollable).first;
      // V9: the hub's last row is Help centre (Settings moved to the bar).
      await tester.dragUntilVisible(
        find.text('Help centre').last,
        scroll,
        const Offset(0, -300),
      );
      await tester.drag(scroll, const Offset(0, -2000));
      await tester.pump(const Duration(milliseconds: 600));
      final last = tester.getRect(find.text('Help centre').last);
      final pill = tester.getRect(pillOf());
      expect(last.bottom, lessThanOrEqualTo(pill.top));
      await settle(tester);
    });

    testWidgets('tabs still switch and announce the selected one', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final handle = tester.ensureSemantics();
      final c = await quickStartApp(tester);
      await openTab(tester, 'Messages');
      expect(c.read(routerProvider).state.uri.path, Routes.messages);
      // The tab's label and its selected state, each on the node that owns it (as on baseline).
      expect(
        find.descendant(
          of: bar(),
          matching: find.bySemanticsLabel(RegExp('^Messages')),
        ),
        findsOneWidget,
      );
      final messages = find.ancestor(
        of: find.descendant(of: bar(), matching: find.byTooltip('Messages')),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.selected != null,
        ),
      );
      expect(
        tester.widget<Semantics>(messages.first).properties.selected,
        isTrue,
      );
      expect(
        tester.widget<Semantics>(messages.first).properties.button,
        isTrue,
      );
      await settle(tester);
      handle.dispose();
    });
  });

  group('B: compact Discover header', () {
    Future<void> discoverAt(WidgetTester tester, Size size) async {
      await usePhoneSize(tester, size: size);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.home);
    }

    testWidgets('at 320pt the wordmark clears Filters', (tester) async {
      // Ente's 38pt header buttons and 16pt gutter leave room for the full wordmark at 320pt;
      // what matters is that it never runs under the buttons.
      await discoverAt(tester, const Size(320, 568));
      final mark = tester.getRect(find.byType(Wordmark).first);
      final filters = tester.getRect(
        find
            .ancestor(
              of: find.bySemanticsLabel('Filters'),
              matching: find.byType(NavIconButton),
            )
            .first,
      );
      expect(mark.right, lessThan(filters.left));
      await settle(tester);
    });

    testWidgets('at 390pt the full wordmark still shows', (tester) async {
      await discoverAt(tester, const Size(390, 844));
      expect(
        find.descendant(
          of: find.byType(Wordmark),
          matching: find.text('numaya'),
        ),
        findsOneWidget,
      );
      await settle(tester);
    });
  });
}
