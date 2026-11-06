import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Tabler MVP pass (docs/design-experiments/ente-design-system/tabler-mvp/): Tabler icons,
/// filled/outline navigation states, centred alert icons, and Events unavailable in the MVP.
void main() {
  setUpAll(loadAppFonts);

  // The top of the stack: a pushed page (a chat), or the tab's location.
  String location(ProviderContainer c) => c.read(routerProvider).state.uri.path;

  group('Tabler icons', () {
    testWidgets('icons draw bundled Tabler SVGs tinted with srcIn', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Row(
            children: [
              NumayaIcon(NumayaIcons.heart, color: AppColors.negative),
              NumayaIcon(
                NumayaIcons.heart,
                filled: true,
                color: AppColors.negative,
              ),
              NumayaIcon(NumayaIcons.close, filled: true),
            ],
          ),
        ),
      );
      final svgs = tester
          .widgetList<TablerSvg>(find.byType(TablerSvg))
          .toList();
      expect(svgs[0].asset, 'assets/icons/tabler/outline/heart.svg');
      expect(svgs[1].asset, 'assets/icons/tabler/filled/heart.svg');
      // No filled twin: the outline stays.
      expect(svgs[2].asset, 'assets/icons/tabler/outline/x.svg');
      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
      expect(
        picture.colorFilter,
        const ColorFilter.mode(AppColors.negative, BlendMode.srcIn),
      );
      // The icon is excluded from semantics: its control carries the label.
      expect(
        find.ancestor(
          of: find.byType(SvgPicture).first,
          matching: find.byType(ExcludeSemantics),
        ),
        findsWidgets,
      );
    });
  });

  group('Navigation', () {
    testWidgets(
      'four destinations; selected is filled near-black on a light tile, announced as selected',
      (tester) async {
        await usePhoneSize(tester);
        final handle = tester.ensureSemantics();
        final c = await quickStartApp(tester);
        await goTo(c, tester, Routes.home);
        final bar = find.byType(NumayaTabBar);
        for (final label in ['Home', 'Likes', 'Messages', 'Profile']) {
          expect(
            find.descendant(of: bar, matching: find.byTooltip(label)),
            findsOneWidget,
            reason: label,
          );
        }
        expect(
          find.descendant(of: bar, matching: find.byTooltip('Events')),
          findsNothing,
        );
        // Discover (labelled Home) is announced as a selected button: the selected flag sits on
        // the tab's own Semantics node, as on the V4 baseline.
        final home = find.ancestor(
          of: find.descendant(of: bar, matching: find.byTooltip('Home')),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.selected != null,
          ),
        );
        expect(
          tester.widget<Semantics>(home.first).properties.selected,
          isTrue,
        );
        expect(tester.widget<Semantics>(home.first).properties.button, isTrue);
        await openTab(tester, 'Profile');
        final icons = tester
            .widgetList<NumayaIcon>(
              find.descendant(of: bar, matching: find.byType(NumayaIcon)),
            )
            .toList();
        expect([for (final i in icons) i.filled], [false, false, false, true]);
        expect(icons.last.color, AppColors.iconSelected);
        expect(icons.first.color, AppColors.iconInactive);
        handle.dispose();
        await settle(tester);
      },
    );

    testWidgets('the whole 48 x 44 slot is tappable, not just the glyph', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.home);
      final tile = tester.getRect(find.byKey(const ValueKey('tab-tile-2')));
      // 4pt outside the visible 38pt tile, still inside the slot.
      await tester.tapAt(Offset(tile.right + 4, tile.bottom + 2));
      await tester.pump(const Duration(milliseconds: 600));
      expect(location(c), Routes.messages);
      await settle(tester);
    });

    testWidgets('at 320pt and 200% text all four tiles fit inside the bar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(640, 1386);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.messages);
      final bar = tester.getRect(find.byType(NumayaTabBar));
      var previousRight = double.negativeInfinity;
      for (var i = 0; i < 4; i++) {
        final tile = tester.getRect(find.byKey(ValueKey('tab-tile-$i')));
        expect(tile.left, greaterThanOrEqualTo(bar.left), reason: '$i');
        // Inside the bar's 16pt gutter and 10pt inner padding.
        expect(tile.right, lessThanOrEqualTo(320 - 16 - 10), reason: '$i');
        expect(tile.left, greaterThan(previousRight), reason: '$i');
        previousRight = tile.right;
      }
      await openTab(tester, 'Profile');
      expect(location(c), Routes.profile);
      expect(tester.takeException(), isNull);
      await settle(tester);
    });

    testWidgets('each tab keeps its own stack; back returns to Discover', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.messages);
      await tapOn(tester, find.text('Priya'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(location(c), '${Routes.chat}/priya');
      // The chat is pushed above the shell; back to Messages, then switch tabs and return.
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 600));
      expect(location(c), Routes.messages);
      // Let the chat's exit transition finish before switching tabs.
      await settle(tester);
      await openTab(tester, 'Profile');
      expect(location(c), Routes.profile);
      await openTab(tester, 'Messages');
      expect(location(c), Routes.messages);
      // Android back on a tab root other than Discover goes to Discover.
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 600));
      expect(location(c), Routes.home);
      await settle(tester);
    });
  });

  group('Alerts', () {
    for (final (name, title, body, action) in [
      ('short', 'Heads up', null, false),
      (
        'multiline',
        'Your account has been blocked',
        'We found activity that goes against our guidelines. You can appeal within 6 months, and we reply within two days.',
        false,
      ),
      ('with action', 'Confirm your email', 'So you can get back in.', true),
    ]) {
      testWidgets('StatusBanner icon is centred on the content ($name)', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: StatusBanner(
                  title: title,
                  body: body,
                  tone: BannerTone.error,
                  action: action
                      ? NumayaButton(
                          label: 'Confirm',
                          small: true,
                          expand: false,
                          onPressed: () {},
                        )
                      : null,
                ),
              ),
            ),
          ),
        );
        final icon = tester.getRect(find.byType(NumayaIcon));
        final content = tester.getRect(
          find
              .ancestor(of: find.text(title), matching: find.byType(Column))
              .first,
        );
        expect(
          (icon.center.dy - content.center.dy).abs(),
          lessThanOrEqualTo(1),
        );
        expect(
          tester.widget<NumayaIcon>(find.byType(NumayaIcon)).filled,
          isTrue,
        );
      });
    }

    testWidgets('InfoCard icon stays centred at 320pt and 200% text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(640, 1386);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoCard(
              icon: NumayaIcons.info,
              title: 'Only you can see this',
              body: 'Nothing here is shared with your matches.',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final icon = tester.getRect(find.byType(NumayaIcon));
      final content = tester.getRect(
        find
            .ancestor(
              of: find.text('Only you can see this'),
              matching: find.byType(Column),
            )
            .first,
      );
      expect(content.height, greaterThan(icon.height * 3));
      expect((icon.center.dy - content.center.dy).abs(), lessThanOrEqualTo(1));
    });
  });

  group('Events is unavailable in the MVP', () {
    for (final path in [
      Routes.events,
      '${Routes.events}?view=mine',
      Routes.eventNew,
      '${Routes.event}/e-jazz',
      '${Routes.event}/e-jazz/people',
      '${Routes.event}/e-jazz/edit',
    ]) {
      testWidgets('direct route $path lands on Discover', (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, Routes.profile);
        await goTo(c, tester, path);
        await tester.pump(const Duration(milliseconds: 600));
        expect(location(c), Routes.home);
        expect(find.text('Late jazz at the Vortex'), findsNothing);
        expect(tester.takeException(), isNull);
        await settle(tester);
      });
    }

    testWidgets('a pushed event link resolves to Discover without a loop', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.messages);
      unawaited(c.read(routerProvider).push('${Routes.event}/e-jazz'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(location(c), Routes.home);
      expect(tester.takeException(), isNull);
      await settle(tester);
    });

    testWidgets('no Events shortcuts in the Demo Hub', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.demo);
      await tester.pump(const Duration(milliseconds: 600));
      final scroll = find.byType(Scrollable).first;
      for (var i = 0; i < 12; i++) {
        await tester.drag(scroll, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('An open event (Late jazz)'), findsNothing);
      }
      // The Events group and its shortcuts (open, full and cancelled events, create) are gone.
      expect(find.text('An open event (Late jazz)'), findsNothing);
      expect(find.text('A full event with a waitlist'), findsNothing);
      expect(find.text('Create an event'), findsNothing);
      await settle(tester);
    });

    testWidgets('with Events available, the tab comes back second', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, overrides: eventsOn);
      await goTo(c, tester, Routes.home);
      final bar = find.byType(NumayaTabBar);
      expect(
        find.descendant(of: bar, matching: find.byTooltip('Events')),
        findsOneWidget,
      );
      await openTab(tester, 'Events');
      expect(location(c), Routes.events);
      await settle(tester);
    });
  });
}
