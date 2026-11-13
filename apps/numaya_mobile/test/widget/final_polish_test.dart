import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/presentation/match_screen.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Final UX polish (docs/agent-handoff/ACTIVE_TASK.md): real swipes, one decision per person,
/// undo, the single-photo match, icon tiles, inset dividers and nested corners.
void main() {
  setUpAll(loadAppFonts);

  Finder label(String l) => find.bySemanticsLabel(l);

  Future<void> afterDecision(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// A real pointer drag across the first photo, in small steps so the card follows the finger.
  Future<TestGesture> dragPhoto(
    WidgetTester tester,
    String name,
    double dx,
  ) async {
    final g = await tester.startGesture(tester.getCenter(find.text(name)));
    const steps = 8;
    for (var i = 0; i < steps; i++) {
      await g.moveBy(Offset(dx / steps, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    return g;
  }

  group('Discover swipes', () {
    testWidgets('dragging right shows Like on the photo and likes on release', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      // Sam has not liked you, so a like is not a match: pass Maya first.
      await tester.drag(find.text('Maya, 29'), const Offset(-200, 0));
      await afterDecision(tester);

      final g = await dragPhoto(tester, 'Sam, 31', 160);
      // Mid-drag: the decision is named on the photo, with its icon.
      expect(find.text('Like'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) => w is NumayaIcon && w.icon == NumayaIcons.check,
        ),
        findsOneWidget,
      );
      await g.up();
      await afterDecision(tester);
      expect(find.text('You liked Sam'), findsOneWidget);
      expect(find.text('Noor, 28'), findsOneWidget);
      await settle(tester);
    });

    testWidgets('dragging left shows Pass and passes; undo brings them back', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      final g = await dragPhoto(tester, 'Maya, 29', -160);
      expect(find.text('Pass'), findsWidgets);
      await g.up();
      await afterDecision(tester);
      expect(find.text('Sam, 31'), findsOneWidget);

      await tapOn(tester, label('Backtrack: bring back Maya'));
      expect(find.text('Maya, 29'), findsOneWidget);
      // One step only.
      expect(
        tester
            .widget<NavIconButton>(
              find.byKey(const ValueKey('discover-backtrack')),
            )
            .onPressed,
        isNull,
      );
      await settle(tester);
    });

    testWidgets(
      'an interrupted swipe springs back: dragged back before release',
      (tester) async {
        await usePhoneSize(tester);
        await signUpToHome(tester, testAuth());
        final g = await dragPhoto(tester, 'Maya, 29', 160);
        // Past the line, then brought back to the centre before letting go.
        for (var i = 0; i < 8; i++) {
          await g.moveBy(const Offset(-20, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await g.up();
        await afterDecision(tester);
        expect(find.text('Maya, 29'), findsOneWidget);
        // No stamp left on the photo (and no decision buttons since UI-016).
        expect(find.text('Like'), findsNothing);
        expect(
          find.byWidgetPredicate(
            (w) => w is NumayaIcon && w.icon == NumayaIcons.check,
          ),
          findsNothing,
        );
        await settle(tester);
      },
    );

    testWidgets(
      'a swipe past the line flung back toward the centre is cancelled',
      (tester) async {
        await usePhoneSize(tester);
        await signUpToHome(tester, testAuth());
        final start = tester.getCenter(find.text('Maya, 29'));
        final g = await tester.createGesture();
        await g.down(start, timeStamp: Duration.zero);
        // Slowly out to 240pt…
        for (var i = 1; i <= 8; i++) {
          await g.moveBy(
            const Offset(30, 0),
            timeStamp: Duration(milliseconds: 60 * i),
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        // …then a quick flick back of 80pt: still past the line, but heading home fast.
        for (var i = 1; i <= 4; i++) {
          await g.moveBy(
            const Offset(-20, 0),
            timeStamp: Duration(milliseconds: 480 + 8 * i),
          );
        }
        await g.up(timeStamp: const Duration(milliseconds: 520));
        await afterDecision(tester);
        expect(find.text('Maya, 29'), findsOneWidget);
        await settle(tester);
      },
    );

    testWidgets('a pointer cancel mid-drag decides nothing', (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      final g = await dragPhoto(tester, 'Maya, 29', 160);
      await g.cancel();
      await afterDecision(tester);
      expect(find.text('Maya, 29'), findsOneWidget);
      await settle(tester);
    });

    testWidgets('one decision per person: a double Pass passes only once', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      // UI-016: the Pass action is the swipe's non-gesture equivalent.
      semanticDecide(tester, like: false);
      semanticDecide(tester, like: false);
      await afterDecision(tester);
      expect(find.text('Sam, 31'), findsOneWidget);
      await settle(tester);
    });

    testWidgets('an action during a swipe exit does not decide again', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      final c = containerOf(tester);
      final g = await dragPhoto(tester, 'Maya, 29', -160);
      await g.up();
      // The card is leaving; a Like tap now must not like the next person or Maya.
      await tester.pump(const Duration(milliseconds: 50));
      semanticDecide(tester, like: true);
      await afterDecision(tester);
      final state = c.read(datingProvider);
      expect(state.seen, {'maya'});
      expect(state.liked, isEmpty);
      expect(find.text('Sam, 31'), findsOneWidget);
      await settle(tester);
    });

    testWidgets('a tap on the photo opens the photos instead of swiping', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await tapOn(tester, label('See Maya’s photos').first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        currentLocation(tester),
        startsWith('${Routes.person}/maya/photos'),
      );
      expect(containerOf(tester).read(datingProvider).seen, isEmpty);
      await settle(tester);
    });

    testWidgets(
      'the screen-reader actions decide the same way the gestures do',
      (tester) async {
        await usePhoneSize(tester);
        await signUpToHome(tester, testAuth());
        semanticDecide(tester, like: false);
        await afterDecision(tester);
        expect(find.text('Sam, 31'), findsOneWidget);
        semanticDecide(tester, like: true);
        await afterDecision(tester);
        expect(find.text('You liked Sam'), findsOneWidget);
        expect(find.text('Noor, 28'), findsOneWidget);
        await settle(tester);
      },
    );
  });

  group('Match', () {
    testWidgets('shows only the matched person, large, with their name', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.match}/amara');
      final match = find.byType(MatchScreen);
      expect(match, findsOneWidget);
      expect(find.text('It’s a match!'), findsOneWidget);
      // One photo, theirs; no avatar of the member and no two-portrait composition.
      final photos = find.descendant(
        of: match,
        matching: find.byType(PhotoPlaceholder),
      );
      expect(photos, findsOneWidget);
      expect(tester.widget<PhotoPlaceholder>(photos).label, 'Amara, photo 1');
      expect(
        find.descendant(of: match, matching: find.byType(InitialsAvatar)),
        findsNothing,
      );
      expect(
        find.descendant(of: match, matching: find.byType(ScallopPortrait)),
        findsNothing,
      );
      // UI-028 / UI-011: the profile photo's 3:4 portrait, with the hero-card corner, prominent.
      final size = tester.getSize(photos);
      expect(size.width / size.height, closeTo(3 / 4, 0.01));
      expect(size.width, greaterThanOrEqualTo(240));
      expect(tester.widget<PhotoPlaceholder>(photos).radius, AppRadii.heroCard);
      expect(find.textContaining('Amara'), findsWidgets);
      await settle(tester);
    });

    testWidgets('a match from Discover names the right person', (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await swipeDecide(tester, like: true); // Maya already liked you.
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('It’s a match!'), findsOneWidget);
      final photo = find.descendant(
        of: find.byType(MatchScreen),
        matching: find.byType(PhotoPlaceholder),
      );
      expect(tester.widget<PhotoPlaceholder>(photo).label, 'Maya, photo 1');
      await settle(tester);
    });

    testWidgets('fits a 320pt phone at 200% text with no photo', (
      tester,
    ) async {
      await usePhoneSize(tester, size: const Size(320, 568));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.match}/maya');
      expect(tester.takeException(), isNull);
      final photo = find.descendant(
        of: find.byType(MatchScreen),
        matching: find.byType(PhotoPlaceholder),
      );
      // No photo: their initial stands in, and the portrait stays within 42% of the height so
      // the two actions stay reachable (UI-030).
      expect(
        find.descendant(of: photo, matching: find.text('M')),
        findsOneWidget,
      );
      expect(tester.getSize(photo).height, lessThanOrEqualTo(568 * 0.42 + 0.5));
      // Both actions stay reachable (scrolled to, at this size).
      for (final key in ['match-open-chat', 'match-view-profile']) {
        await tester.ensureVisible(find.byKey(ValueKey(key)));
        await tester.pump();
        expect(find.byKey(ValueKey(key)).hitTestable(), findsOneWidget);
      }
      await settle(tester);
    });
  });

  group('Icon tiles and grouped lists', () {
    Widget host(Widget child) => MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );

    testWidgets('a leading icon is a plain monochrome glyph (CL-02)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const ListRow(
            leading: NumayaIcons.location,
            tone: AccentTone.info,
            label: 'Current location',
          ),
        ),
      );
      // Ente Menu Item Icon: a plain glyph in text/light in a 36pt slot, no tile behind it.
      expect(find.byType(IconTile), findsNothing);
      final icon = tester.widget<NumayaIcon>(find.byType(NumayaIcon));
      expect(
        icon.color,
        AppColors.iconSupporting,
      ); // X15-I: the lighter supporting grey
      expect(icon.size, AppSizes.iconMd);
      // The text starts after the list-card inset (UI-044: 16pt), the 36pt slot and its gap.
      final row = tester.getTopLeft(find.byType(ListRow));
      expect(
        tester.getTopLeft(find.text('Current location')).dx - row.dx,
        AppLayout.cardPadding + AppSizes.iconTile + AppLayout.tileLabelGap,
      );
    });

    testWidgets('metadata rows can keep a bare icon', (tester) async {
      await tester.pumpWidget(
        host(
          const ListRow(
            leading: NumayaIcons.calendar,
            inlineIcon: true,
            label: 'Friday',
          ),
        ),
      );
      expect(find.byType(IconTile), findsNothing);
    });

    testWidgets('off a sheet, related rows share one white card with a shared inset divider between '
        'rows (OV-02 grouping, UI-003 V8 dividers)', (tester) async {
      await tester.pumpWidget(
        host(
          const ListGroup(
            children: [
              ListRow(leading: NumayaIcons.user, label: 'One'),
              ListRow(leading: NumayaIcons.link, label: 'Two'),
              ListRow(label: 'Three'),
            ],
          ),
        ),
      );
      final lines = find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppColors.divider,
      );
      // UI-003 (V8): one divider at each boundary between the three rows.
      expect(lines, findsNWidgets(2));
      final cards = find.descendant(
        of: find.byType(ListGroup),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == AppColors.surface &&
              (w.decoration as BoxDecoration).borderRadius ==
                  AppRadii.all(AppRadii.card),
        ),
      );
      expect(cards, findsOneWidget);
      for (final label in ['One', 'Two', 'Three']) {
        expect(
          find.descendant(of: cards, matching: find.text(label)),
          findsOneWidget,
        );
      }
    });

    testWidgets('groups can opt out of dividers', (tester) async {
      await tester.pumpWidget(
        host(
          const ListGroup(
            dividers: false,
            children: [
              ListRow(label: 'One'),
              ListRow(label: 'Two'),
            ],
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == AppColors.divider,
        ),
        findsNothing,
      );
    });

    test('every accent tone is legible on its tint and on white', () {
      for (final tone in AccentTone.values) {
        final (bg, fg) = tone.colors;
        expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: '$tone');
        expect(
          contrast(fg, AppColors.surface),
          greaterThanOrEqualTo(4.5),
          reason: '$tone on white',
        );
      }
    });
  });

  group('Illustration slots', () {
    for (final (name, ratio) in [
      ('header', IllustrationSlot.header),
      ('empty', IllustrationSlot.empty),
    ]) {
      testWidgets('a $name slot keeps its ratio at 320pt and 200% text', (
        tester,
      ) async {
        await usePhoneSize(tester, size: const Size(320, 568));
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            // Slot geometry is reviewed with placeholders on (product screens hide them, FD-A1).
            builder: (context, child) =>
                IllustrationPlaceholders(child: child!),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    IllustrationSlot(
                      slot: 'test_$name',
                      label: 'A long description of what the mascot does here',
                      aspectRatio: ratio,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final size = tester.getSize(find.byType(IllustrationSlot));
        expect(size.width, 280);
        expect(size.width / size.height, closeTo(ratio, 0.01));
      });
    }
  });

  group('System bars', () {
    test('transparent status bar with dark icons; navigation colour left to Android', () {
      const s = AppSystemUi.style;
      expect(s.statusBarColor, const Color(0x00000000));
      expect(s.statusBarIconBrightness, Brightness.dark);
      expect(s.statusBarBrightness, Brightness.light);
      expect(s.systemNavigationBarIconBrightness, Brightness.dark);
      expect(s.systemNavigationBarContrastEnforced, isFalse);
      // Never black: API 24-25 get the system bar from the theme, later APIs the page colour or
      // transparency (res/values*/styles.xml).
      expect(s.systemNavigationBarColor, isNull);
      expect(AppTheme.light().appBarTheme.systemOverlayStyle, s);
    });

    testWidgets('every screen sits under the root system-bar region', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      for (final route in [
        Routes.home,
        Routes.events,
        Routes.profile,
        Routes.settings,
      ]) {
        await goTo(c, tester, route);
        final regions = tester
            .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
              find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
            )
            .map((r) => r.value);
        expect(regions, everyElement(AppSystemUi.style), reason: route);
        expect(regions, isNotEmpty, reason: route);
      }
      await settle(tester);
    });
  });

  group('Sheets above the system navigation bar', () {
    // A 48dp three-button bar, edge to edge: the app draws behind it and gets it as padding.
    Future<void> withNavBar(WidgetTester tester) async {
      await usePhoneSize(tester);
      final dpr = tester.view.devicePixelRatio;
      tester.view.padding = FakeViewPadding(bottom: 48 * dpr);
      tester.view.viewPadding = FakeViewPadding(bottom: 48 * dpr);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
    }

    Widget opener(void Function(BuildContext) open) => MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => open(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    testWidgets('the action sheet Cancel clears the bar', (tester) async {
      await withNavBar(tester);
      await tester.pumpWidget(
        opener(
          (context) => showNumayaActionSheet(
            context: context,
            cancelLabel: 'Cancel',
            actions: const [
              (icon: NumayaIcons.flag, label: 'Report', destructive: true),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final height =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(
        tester.getBottomLeft(find.text('Cancel')).dy,
        lessThanOrEqualTo(height - 48),
      );
    });

    testWidgets('the last control of a sheet clears the bar', (tester) async {
      await withNavBar(tester);
      await tester.pumpWidget(
        opener(
          (context) => showNumayaSheet<void>(
            context: context,
            title: 'Filters',
            closeLabel: 'Close',
            builder: (_) =>
                const SizedBox(height: 56, child: Center(child: Text('Reset'))),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final height =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final box = find.ancestor(
        of: find.text('Reset'),
        matching: find.byType(SizedBox),
      );
      expect(
        tester.getBottomLeft(box.first).dy,
        lessThanOrEqualTo(height - 48),
      );
    });
  });

  group('Nested corners', () {
    test(
      'inner radius is the outer radius minus the inset, never negative',
      () {
        expect(AppRadii.nested(32, 8), 24);
        expect(AppRadii.nested(12, 16), 0);
      },
    );

    testWidgets('the selected tab is a light neutral 12pt tile (UI-050)', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await quickStartApp(tester);
      final selected = find.descendant(
        of: find.byType(NumayaTabBar),
        matching: find.byWidgetPredicate(
          (w) =>
              w is AnimatedContainer &&
              (w.decoration as BoxDecoration?)?.color ==
                  AppColors.iconSelectedFill,
        ),
      );
      expect(selected, findsOneWidget);
      final deco =
          tester.widget<AnimatedContainer>(selected).decoration!
              as BoxDecoration;
      // V8 (UI-050): the selected tile is 12, 8pt inside the 20pt shell.
      expect(deco.borderRadius, AppRadii.all(AppRadii.navItem));
      await settle(tester);
    });

    testWidgets('the Discover photo nests inside its hero card', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      final photo = find.byWidgetPredicate(
        (w) =>
            w is ClipRRect &&
            w.borderRadius == AppRadii.all(SquircleIconButton.photoRadius),
      );
      expect(photo, findsWidgets);
      // Discover photo O (owner selection): the controls sit inside the card padding and the
      // radii are concentric: photo radius = squircle radius + its inset.
      expect(
        SquircleIconButton.photoRadius,
        AppRadii.iconButton + SquircleIconButton.photoInset,
      );
      await settle(tester);
    });
  });
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

String currentLocation(WidgetTester tester) =>
    containerOf(tester).read(routerProvider).state.uri.toString();

/// WCAG 2.x contrast ratio.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
