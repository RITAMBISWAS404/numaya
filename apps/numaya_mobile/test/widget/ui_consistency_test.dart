import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// UI consistency pass (docs/design-experiments/ente-design-system/ui-consistency/): guards for
/// the shared header action group (UC-02) and the stadium navigation bar (UC-03). The switch
/// (UC-01) is guarded in component_cleanup_test.
void main() {
  setUpAll(loadAppFonts);

  /// The visible 38pt tiles of the header buttons found by [labels], left to right.
  List<Rect> tiles(WidgetTester tester, List<String> labels) => [
    for (final l in labels)
      tester.getRect(
        find
            .descendant(
              of: find.bySemanticsLabel(l),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.constraints?.maxWidth == AppSizes.iconButton,
              ),
            )
            .first,
      ),
  ];

  group('UC-02 header actions', () {
    test('the layout gap plus the tiles\' own margins make the 8pt rule', () {
      expect(AppLayout.headerActionGap, 8);
      expect(
        AppLayout.headerActionLayoutGap +
            (AppSizes.iconButtonSlot - AppSizes.iconButton),
        AppLayout.headerActionGap,
      );
      // Hit boxes never overlap.
      expect(AppLayout.headerActionLayoutGap, greaterThanOrEqualTo(0));
    });

    testWidgets(
      'Discover and Profile show the same 8pt between their two actions',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await settle(tester);
        final discover = tiles(tester, [
          'Backtrack. Nothing to bring back yet: pass on someone first',
          'Filters',
        ]);
        expect(discover[1].left - discover[0].right, closeTo(8, 0.01));
        final discoverEdge = 390 - discover[1].right;

        await goTo(c, tester, Routes.profile);
        await settle(tester);
        final profile = tiles(tester, ['Help centre', 'Settings']);
        expect(profile[1].left - profile[0].right, closeTo(8, 0.01));
        // The same trailing inset on both tab roots.
        expect(390 - profile[1].right, closeTo(discoverEdge, 0.01));
      },
    );

    testWidgets(
      'a two-action top bar keeps its title and both targets at 320pt / 200%',
      (tester) async {
        tester.view.physicalSize = const Size(640, 1386);
        tester.view.devicePixelRatio = 2;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: NumayaTopBar(
                  onBack: () {},
                  title: 'Notification settings and privacy',
                  actions: [
                    NavIconButton(
                      icon: NumayaIcons.search,
                      label: 'Search',
                      onPressed: () {},
                    ),
                    NavIconButton(
                      icon: NumayaIcons.more,
                      label: 'More',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        final t = tiles(tester, ['Search', 'More']);
        expect(t[1].left - t[0].right, closeTo(8, 0.01));
        expect(t[1].right, lessThanOrEqualTo(320));
        // Separate 44pt targets: tapping each reaches only its own handler.
        final search = tester.getRect(find.bySemanticsLabel('Search'));
        final more = tester.getRect(find.bySemanticsLabel('More'));
        expect(search.width, greaterThanOrEqualTo(44));
        expect(more.width, greaterThanOrEqualTo(44));
        expect(search.right, lessThanOrEqualTo(more.left));
        // The title wraps instead of pushing the actions off screen.
        final title = tester.getRect(
          find.text('Notification settings and privacy'),
        );
        expect(title.right, lessThanOrEqualTo(search.left));
      },
    );
  });

  group('UC-03 navigation bar', () {
    testWidgets('fully rounded at 390pt and 320pt; items never under 48 x 48', (
      tester,
    ) async {
      for (final width in [390.0, 320.0]) {
        tester.view.physicalSize = Size(width * 2, 1688);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        final c = await quickStartApp(tester);
        await settle(tester);
        final bar = tester.getRect(find.byKey(NumayaTabBar.pillKey));
        final deco =
            tester
                    .widget<Container>(find.byKey(NumayaTabBar.pillKey))
                    .decoration!
                as BoxDecoration;
        expect(deco.borderRadius, AppRadii.all(AppRadii.pill));
        expect(bar.height, 64);
        expect(bar.left, greaterThanOrEqualTo(16), reason: '$width');
        expect(bar.right, lessThanOrEqualTo(width - 16), reason: '$width');
        for (var i = 0; i < 4; i++) {
          final item = tester.getRect(find.byKey(ValueKey('tab-item-$i')));
          expect(item.width, greaterThanOrEqualTo(48), reason: '$width $i');
          expect(item.height, 48);
        }
        // Each selected position draws the stadium pill on the light neutral.
        for (final (label, index) in [
          ('Likes', 1),
          ('Messages', 2),
          ('Profile', 3),
          ('Home', 0),
        ]) {
          await openTab(tester, label);
          final tile =
              tester
                      .widget<AnimatedContainer>(
                        find.byKey(ValueKey('tab-tile-$index')),
                      )
                      .decoration!
                  as BoxDecoration;
          expect(tile.color, AppColors.iconSelectedFill);
          expect(tile.borderRadius, AppRadii.all(AppRadii.pill));
        }
        expect(c, isNotNull);
        await settle(tester);
      }
    });

    testWidgets('a tap just outside the bar does not switch tabs', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await settle(tester);
      final bar = tester.getRect(find.byKey(NumayaTabBar.pillKey));
      await tester.tapAt(Offset(bar.right + 4, bar.center.dy));
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.read(routerProvider).state.uri.path, Routes.home);
      await settle(tester);
    });
  });
}
