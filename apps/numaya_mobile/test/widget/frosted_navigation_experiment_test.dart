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

  group('C: frosted tab bar', () {
    Finder bar() => find.byType(NumayaTabBar);

    testWidgets('one blur, bounded by the pill clip, with the glass tint', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await quickStartApp(tester);
      final blur = find.descendant(
        of: bar(),
        matching: find.byType(BackdropFilter),
      );
      expect(blur, findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(
        find.ancestor(of: blur, matching: find.byType(ClipRRect)),
        findsWidgets,
      );
      // The blur covers the pill only (64pt tall), never the screen.
      expect(tester.getSize(blur).height, AppSizes.tabBar);
      final glass = find.descendant(
        of: blur,
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.decoration as BoxDecoration?)?.color == MonoGlass.tint,
        ),
      );
      expect(glass, findsOneWidget);
      await settle(tester);
    });

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
      final pill = tester.getRect(
        find.descendant(of: bar(), matching: find.byType(BackdropFilter)),
      );
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
      expect(find.byType(BackdropFilter), findsNothing);
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

    testWidgets('unselected icons use the stronger ink on glass', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await quickStartApp(tester);
      final icons = tester
          .widgetList<Icon>(
            find.descendant(of: bar(), matching: find.byType(Icon)),
          )
          .toList();
      expect(icons, hasLength(5));
      // Home is selected (brand text on its tint); the other four are idle.
      expect(icons.first.color, AppColors.accentOnTint);
      for (final icon in icons.skip(1)) {
        expect(icon.color, AppColors.textSecondary);
      }
      await settle(tester);
    });

    testWidgets('tab content can scroll clear of the bar', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.profile);
      final scroll = find.byType(Scrollable).first;
      await tester.dragUntilVisible(
        find.text('Settings').last,
        scroll,
        const Offset(0, -300),
      );
      await tester.drag(scroll, const Offset(0, -2000));
      await tester.pump(const Duration(milliseconds: 600));
      final last = tester.getRect(find.text('Settings').last);
      final pill = tester.getRect(
        find.descendant(of: bar(), matching: find.byType(BackdropFilter)),
      );
      expect(last.bottom, lessThanOrEqualTo(pill.top));
      await settle(tester);
    });

    testWidgets('tabs still switch and announce the selected one', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final handle = tester.ensureSemantics();
      final c = await quickStartApp(tester);
      await openTab(tester, 'Events');
      expect(c.read(routerProvider).state.uri.path, Routes.events);
      // The tab's label and its selected state, each on the node that owns it (as on baseline).
      expect(
        find.descendant(of: bar(), matching: find.bySemanticsLabel('Events')),
        findsOneWidget,
      );
      final events = find.ancestor(
        of: find.descendant(of: bar(), matching: find.byTooltip('Events')),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.selected != null,
        ),
      );
      expect(
        tester.widget<Semantics>(events.first).properties.selected,
        isTrue,
      );
      expect(tester.widget<Semantics>(events.first).properties.button, isTrue);
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

    testWidgets(
      'at 320pt the wordmark shows the mark only and clears Filters',
      (tester) async {
        await discoverAt(tester, const Size(320, 568));
        final wordmark = find.byType(Wordmark);
        expect(
          find.descendant(of: wordmark, matching: find.text('numaya')),
          findsNothing,
        );
        final mark = tester.getRect(find.byType(BrandMark).first);
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
      },
    );

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
