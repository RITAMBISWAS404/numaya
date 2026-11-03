import 'package:flutter/material.dart';
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
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
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

      await tapOn(tester, label('Undo: bring back Maya'));
      expect(find.text('Maya, 29'), findsOneWidget);
      // One step only.
      expect(find.bySemanticsLabel(RegExp('^Undo')), findsNothing);
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
        expect(find.text('Like'), findsWidgets); // only the button, no stamp
        expect(find.byIcon(Icons.check_rounded), findsNothing);
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

    testWidgets('one decision per person: a double tap passes only once', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      final pass = label('Pass').last;
      await tester.tap(pass);
      await tester.tap(pass, warnIfMissed: false);
      await afterDecision(tester);
      expect(find.text('Sam, 31'), findsOneWidget);
      await settle(tester);
    });

    testWidgets('a button during a swipe exit does not decide again', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      final c = containerOf(tester);
      final g = await dragPhoto(tester, 'Maya, 29', -160);
      await g.up();
      // The card is leaving; a Like tap now must not like the next person or Maya.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(label('Like').last, warnIfMissed: false);
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

    testWidgets('the buttons decide the same way the gestures do', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await tapOn(tester, label('Pass').last);
      await afterDecision(tester);
      expect(find.text('Sam, 31'), findsOneWidget);
      await tapOn(tester, label('Like').last);
      await afterDecision(tester);
      expect(find.text('You liked Sam'), findsOneWidget);
      expect(find.text('Noor, 28'), findsOneWidget);
      await settle(tester);
    });
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
      expect(
        tester.widget<PhotoPlaceholder>(photos).label,
        'Amara, photo 1 (placeholder)',
      );
      expect(
        find.descendant(of: match, matching: find.byType(InitialsAvatar)),
        findsNothing,
      );
      expect(
        find.descendant(of: match, matching: find.byType(ScallopPortrait)),
        findsNothing,
      );
      // Square, with the hero-card corner, and prominent.
      final size = tester.getSize(photos);
      expect(size.width, size.height);
      expect(size.width, greaterThanOrEqualTo(280));
      expect(tester.widget<PhotoPlaceholder>(photos).radius, AppRadii.heroCard);
      expect(find.textContaining('Amara'), findsWidgets);
      await settle(tester);
    });

    testWidgets('a match from Discover names the right person', (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await tapOn(tester, label('Like').last); // Maya already liked you.
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('It’s a match!'), findsOneWidget);
      final photo = find.descendant(
        of: find.byType(MatchScreen),
        matching: find.byType(PhotoPlaceholder),
      );
      expect(
        tester.widget<PhotoPlaceholder>(photo).label,
        'Maya, photo 1 (placeholder)',
      );
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
      // No photo: their initial stands in, and the square stays within 40% of the height.
      expect(
        find.descendant(of: photo, matching: find.text('M')),
        findsOneWidget,
      );
      expect(tester.getSize(photo).height, lessThanOrEqualTo(568 * 0.4));
      await settle(tester);
    });
  });

  group('Icon tiles and grouped lists', () {
    Widget host(Widget child) => MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );

    testWidgets('a leading icon sits in a 40pt rounded-square tile', (
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
      final tile = find.byType(IconTile);
      expect(tile, findsOneWidget);
      expect(tester.getSize(tile), const Size(40, 40));
      final box = tester.widget<Container>(
        find.descendant(of: tile, matching: find.byType(Container)),
      );
      final deco = box.decoration! as BoxDecoration;
      expect(deco.color, AppColors.infoTint);
      expect(deco.borderRadius, AppRadii.all(AppRadii.iconTile));
      // The text starts after the tile and its gap.
      final row = tester.getTopLeft(find.byType(ListRow));
      expect(
        tester.getTopLeft(find.text('Current location')).dx - row.dx,
        AppLayout.cardPadding + IconTile.rowInset,
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

    testWidgets('dividers sit between rows only, inset to the text', (
      tester,
    ) async {
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
      expect(lines, findsNWidgets(2));
      final group = tester.getTopLeft(find.byType(ListGroup)).dx;
      // Before a row with a tile: starts at the text, never through the tile.
      expect(
        tester.getTopLeft(lines.at(0)).dx - group,
        AppLayout.cardPadding + IconTile.rowInset,
      );
      // Before a plain row: starts at the card padding.
      expect(tester.getTopLeft(lines.at(1)).dx - group, AppLayout.cardPadding);
      // Ends at the card padding.
      final card = tester.getTopRight(find.byType(ListGroup)).dx;
      expect(card - tester.getTopRight(lines.at(0)).dx, AppLayout.cardPadding);
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

  group('Nested corners', () {
    test(
      'inner radius is the outer radius minus the inset, never negative',
      () {
        expect(AppRadii.nested(32, 8), 24);
        expect(AppRadii.nested(12, 16), 0);
      },
    );

    testWidgets('the tab indicator is concentric with the floating pill', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await quickStartApp(tester);
      final selected = find.descendant(
        of: find.byType(NumayaTabBar),
        matching: find.byWidgetPredicate(
          (w) =>
              w is AnimatedContainer &&
              (w.decoration as BoxDecoration?)?.color == AppColors.accentTint,
        ),
      );
      expect(selected, findsOneWidget);
      final deco =
          tester.widget<AnimatedContainer>(selected).decoration!
              as BoxDecoration;
      expect(
        deco.borderRadius,
        AppRadii.all(
          AppRadii.nested(AppSizes.tabBar / 2, NumayaTabBar.tabInset),
        ),
      );
      await settle(tester);
    });

    testWidgets('the Discover photo nests inside its hero card', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      final photo = find.byWidgetPredicate(
        (w) => w is ClipRRect && w.borderRadius == AppRadii.all(AppRadii.photo),
      );
      expect(photo, findsWidgets);
      // The hero card is 32 with an 8pt inset: the photo's 24 is exactly what the rule asks.
      expect(AppRadii.nested(AppRadii.heroCard, AppSpacing.s2), AppRadii.photo);
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
