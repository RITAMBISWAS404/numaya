import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/release_scope.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/presentation/likes_screens.dart';
import 'package:numaya_mobile/features/dating/presentation/match_screen.dart';
import 'package:numaya_mobile/features/dating/presentation/person_profile.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';
import 'package:numaya_mobile/features/profile/presentation/profile_hub_screens.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Discover, Filters, navigation and New Match review (UI-013 to UI-032, NUMAYA_UI_REVIEW.md):
/// behaviour the review changed, checked by issue ID.
void main() {
  setUpAll(loadAppFonts);

  Future<ProviderContainer> home(WidgetTester tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await settle(tester);
    return c;
  }

  String? front(ProviderContainer c) {
    final q = c
        .read(datingProvider.notifier)
        .queue(c.read(discoveryFiltersProvider));
    return q.isEmpty ? null : q.first.id;
  }

  Future<void> swipe(WidgetTester tester, String id, double dx) async {
    await tester.drag(find.byKey(ValueKey('swipe-$id')), Offset(dx, 0));
    await tester.pumpAndSettle();
  }

  NavIconButton backtrack(WidgetTester tester) => tester.widget<NavIconButton>(
    find.byKey(const ValueKey('discover-backtrack')),
  );

  group('UI-013: Discover header and Backtrack', () {
    testWidgets(
      'logo, then exactly Backtrack and Filter; no sparkle, no strip',
      (tester) async {
        await home(tester);
        final header = find.ancestor(
          of: find.byKey(const ValueKey('discover-backtrack')),
          matching: find.byType(Row),
        );
        final buttons = find.descendant(
          of: header.first,
          matching: find.byType(NavIconButton),
        );
        expect(buttons, findsNWidgets(2));
        expect(
          tester.widget<NavIconButton>(buttons.at(0)).icon,
          NumayaIcons.undo,
        );
        expect(
          tester.widget<NavIconButton>(buttons.at(1)).icon,
          NumayaIcons.filter,
        );
        expect(find.byTooltip('For you'), findsNothing);
        expect(
          find.byWidgetPredicate(
            (w) => w is NavIconButton && w.icon == NumayaIcons.sparkle,
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'a left swipe, then Backtrack, brings the same person back once',
      (tester) async {
        final c = await home(tester);
        // Nothing to bring back yet: disabled, and it says why.
        expect(backtrack(tester).onPressed, isNull);
        final first = front(c)!;
        await swipe(tester, first, -260);
        expect(front(c), isNot(first));
        expect(c.read(datingProvider).lastPass, first);
        expect(backtrack(tester).onPressed, isNotNull);

        await tapOn(tester, find.byKey(const ValueKey('discover-backtrack')));
        await settle(tester);
        expect(front(c), first);
        expect(c.read(datingProvider).seen.contains(first), isFalse);
        // One step: a second tap has nothing to restore and creates no duplicate.
        expect(backtrack(tester).onPressed, isNull);
        final queue = c
            .read(datingProvider.notifier)
            .queue(c.read(discoveryFiltersProvider));
        expect(queue.where((p) => p.id == first), hasLength(1));
        // Their content is back with them.
        expect(find.byKey(ValueKey('swipe-$first')), findsOneWidget);
      },
    );

    testWidgets(
      'a right swipe likes (and opens the match when they liked you)',
      (tester) async {
        final c = await home(tester);
        final first = front(c)!;
        await swipe(tester, first, 260);
        expect(c.read(datingProvider).liked, contains(first));
        // Maya liked the member already: a like is a match.
        expect(find.byType(MatchScreen), findsOneWidget);
        // Likes are never backtracked.
        expect(c.read(datingProvider).lastPass, isNull);
      },
    );

    testWidgets('someone blocked after a pass is never brought back', (
      tester,
    ) async {
      final c = await home(tester);
      final first = front(c)!;
      await swipe(tester, first, -260);
      c
          .read(datingProvider.notifier)
          .report(first, 'Fake profile', block: true);
      await settle(tester);
      expect(c.read(datingProvider.notifier).undo(), isNull);
      expect(front(c), isNot(first));
    });
  });

  group('UI-014 / UI-015 / UI-016 / UI-017: the Discover card', () {
    testWidgets(
      'identity at the foot of the photo; no count, no shared card on it',
      (tester) async {
        await home(tester);
        final hero = find.byType(PersonHeroCard);
        expect(
          find.descendant(of: hero, matching: find.text('Maya, 29')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: hero, matching: find.text('New here')),
          findsOneWidget,
        );
        // The tag sits immediately above the name.
        final tag = tester.getRect(
          find.descendant(of: hero, matching: find.text('New here')),
        );
        final name = tester.getRect(
          find.descendant(of: hero, matching: find.text('Maya, 29')),
        );
        expect(tag.bottom, lessThanOrEqualTo(name.top));
        expect(name.top - tag.bottom, lessThan(24));
        expect(find.textContaining('photos'), findsNothing);
        expect(
          find.descendant(of: hero, matching: find.text('You both like')),
          findsNothing,
        );
        // 3:4 portrait frame (UI-011).
        final photo = tester.getSize(
          find.descendant(of: hero, matching: find.byType(AspectRatio)).first,
        );
        expect(photo.width / photo.height, closeTo(3 / 4, 0.01));
      },
    );

    testWidgets('shared interests are their own section after About me', (
      tester,
    ) async {
      await home(tester);
      final shared = find.byKey(const ValueKey('shared-interests'));
      await tester.scrollUntilVisible(
        shared,
        200,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first,
      );
      final about = find.text('About me');
      expect(
        tester.getTopLeft(shared).dy,
        greaterThan(tester.getTopLeft(about).dy),
      );
      expect(
        find.descendant(of: shared, matching: find.text('Jazz')),
        findsOneWidget,
      );
    });

    testWidgets(
      'no decision buttons and no SuperSwipe; swipe has non-gesture paths',
      (tester) async {
        final c = await home(tester);
        expect(find.byType(DecisionBar), findsNothing);
        expect(find.textContaining('SuperSwipe'), findsNothing);
        expect(find.byTooltip('SuperSwipe'), findsNothing);
        final first = front(c)!;
        // Screen readers get Like and Pass as actions on the photo.
        final actions = tester
            .widgetList<Semantics>(find.byType(Semantics))
            .map((s) => s.properties.customSemanticsActions)
            .whereType<Map<CustomSemanticsAction, VoidCallback>>()
            .expand((m) => m.entries)
            .toList();
        expect(actions.map((e) => e.key.label), containsAll(['Like', 'Pass']));
        actions.firstWhere((e) => e.key.label == 'Pass').value();
        await tester.pumpAndSettle();
        expect(c.read(datingProvider).seen, contains(first));
        expect(c.read(datingProvider).liked.contains(first), isFalse);
      },
    );

    testWidgets('the photo menu offers Report and Block for this person', (
      tester,
    ) async {
      await home(tester);
      await tapOn(tester, find.bySemanticsLabel('Profile options'));
      await settle(tester);
      expect(find.text('Report'), findsOneWidget);
      expect(find.text('Block Maya'), findsOneWidget);
    });
  });

  group('UI-018 / UI-019 / UI-020: About me', () {
    testWidgets('bio, a divider, then emoji detail pills', (tester) async {
      await home(tester);
      final divider = find.byKey(const ValueKey('about-divider'));
      await tester.scrollUntilVisible(
        divider,
        200,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first,
      );
      final bio = find.text('Designer by day, crate-digger by night.');
      expect(
        tester.getTopLeft(bio).dy,
        lessThan(tester.getTopLeft(divider).dy),
      );
      final pill = find.widgetWithText(InfoChip, '168 cm');
      expect(tester.widget<InfoChip>(pill).emoji, '📏');
      expect(tester.widget<InfoChip>(pill).icon, isNull);
      // The label is small and muted; the bio carries the emphasis.
      final label = tester.widget<Text>(find.text('About me'));
      final body = tester.widget<Text>(bio);
      expect(label.style!.fontSize!, lessThan(body.style!.fontSize!));
      expect(label.style!.color, AppColors.textMuted);
    });
  });

  group('UI-021 to UI-025: Filters', () {
    Future<void> openFilters(WidgetTester tester) async {
      // After applying, the button says the filters changed.
      await tapOn(tester, find.bySemanticsLabel(RegExp('^Filters')).first);
      await settle(tester);
    }

    testWidgets(
      'genders are rows; several can be chosen, applied, reopened, reset',
      (tester) async {
        final c = await home(tester);
        await openFilters(tester);
        expect(find.byType(NumayaChip), findsNothing);
        final women = find.byKey(const ValueKey('gender-woman'));
        final men = find.byKey(const ValueKey('gender-man'));
        expect(tester.widget<OptionCard>(women).kind, OptionKind.multiCircle);
        await tapOn(tester, women);
        await tapOn(tester, men);
        expect(tester.widget<OptionCard>(women).selected, isTrue);
        expect(tester.widget<OptionCard>(men).selected, isTrue);
        // Clearing one keeps the other.
        await tapOn(tester, men);
        expect(tester.widget<OptionCard>(men).selected, isFalse);
        await tapOn(tester, men);
        await tapOn(
          tester,
          find.textContaining(
            RegExp(r'^Show \d+ (people|person)$|^Apply filters$'),
          ),
        );
        await settle(tester);
        expect(c.read(discoveryFiltersProvider).genders, {
          Gender.woman,
          Gender.man,
        });
        await openFilters(tester);
        expect(tester.widget<OptionCard>(women).selected, isTrue);
        await tapOn(tester, find.text('Reset'));
        expect(tester.widget<OptionCard>(women).selected, isFalse);
        expect(
          find.text('Showing everyone. Pick one or more to narrow it down.'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'grey sheet, white inactive tab with no stroke both ways (UI-047), full-width sliders',
      (tester) async {
        await home(tester);
        await openFilters(tester);
        final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
        expect(sheet.backgroundColor, AppColors.canvas);

        AnimatedContainer box(String label) => tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        BoxDecoration pill(String label) =>
            box(label).decoration! as BoxDecoration;
        Color? edge(String label) =>
            ((box(label).foregroundDecoration as BoxDecoration?)?.border
                    as Border?)
                ?.top
                .color;
        // UI-047 (supersedes UI-022's outline): on the grey sheet the white fill is the
        // boundary, with no stroke, both ways.
        expect(pill('Advanced').color, AppColors.surface);
        expect(edge('Advanced'), isNull);
        await tapOn(tester, find.text('Advanced'));
        expect(pill('Basic').color, AppColors.surface);
        expect(edge('Basic'), isNull);
        expect(pill('Advanced').color, AppColors.accent);
        // Height sits in its own white card.
        expect(
          find.byKey(const ValueKey('filters-height-card')),
          findsOneWidget,
        );
        await tapOn(tester, find.text('Basic'));

        // The age track spans its card's content width (16pt card padding each side).
        final slider = find.byType(RangeSlider);
        final card = find
            .ancestor(of: slider, matching: find.byType(WhiteCard))
            .first;
        final inner = tester.getRect(card).deflate(0).width - 2 * AppSpacing.s4;
        expect(tester.getSize(slider).width, closeTo(inner, 0.5));
        expect(tester.getSize(slider).height, AppSizes.touchMin);
      },
    );

    testWidgets(
      'switch off: solid #D6D6D6 track, no outline; on stays purple',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Column(
              children: [
                NumayaSwitch(value: false, onChanged: _noop),
                NumayaSwitch(value: true, onChanged: _noop),
              ],
            ),
          ),
        );
        final tracks = tester
            .widgetList<AnimatedContainer>(
              find.descendant(
                of: find.byType(NumayaSwitch),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .map((a) => a.decoration! as BoxDecoration)
            .toList();
        expect(tracks[0].color, AppColors.switchOff); // SW-01: solid #D6D6D6
        expect(tracks[0].border, isNull);
        expect(tracks[1].color, AppColors.accent);
        expect(tracks[1].border, isNull);
      },
    );
  });

  group('Navigation (UC-03 stadium bar; supersedes the Tabler MVP and UI-026/027 geometry)', () {
    testWidgets(
      'stadium bar, 8pt inside, four equal 48pt items, 4pt-inset pills, four destinations',
      (tester) async {
        final c = await home(tester);
        final pill = find.byKey(NumayaTabBar.pillKey);
        final deco =
            tester.widget<Container>(pill).decoration! as BoxDecoration;
        expect(deco.boxShadow, AppElevation.navigation);
        expect(deco.borderRadius, AppRadii.all(AppRadii.pill));
        final bar = tester.getRect(pill);
        expect(bar.height, AppSizes.tabBar);
        // MVP Focus V5: Discover, Likes, Chats and Profile.
        final items = [
          for (var i = 0; i < 4; i++)
            tester.getRect(find.byKey(ValueKey('tab-item-$i'))),
        ];
        final tiles = [
          for (var i = 0; i < 4; i++)
            tester.getRect(find.byKey(ValueKey('tab-tile-$i'))),
        ];
        expect(find.byKey(const ValueKey('tab-tile-4')), findsNothing);
        // 8 inside the bar on all four sides.
        expect(items.first.left - bar.left, closeTo(8, 0.01));
        expect(bar.right - items.last.right, closeTo(8, 0.01));
        expect(items.first.top - bar.top, closeTo(8, 0.01));
        expect(bar.bottom - items.first.bottom, closeTo(8, 0.01));
        for (var i = 0; i < 4; i++) {
          expect(items[i].height, 48);
          expect(items[i].width, closeTo(items[0].width, 0.01));
          // 4 inside each item on all four sides.
          expect(tiles[i].left - items[i].left, closeTo(4, 0.01));
          expect(items[i].right - tiles[i].right, closeTo(4, 0.01));
          expect(tiles[i].top - items[i].top, closeTo(4, 0.01));
          expect(items[i].bottom - tiles[i].bottom, closeTo(4, 0.01));
          if (i > 0) expect(items[i].left, closeTo(items[i - 1].right, 0.01));
        }
        // Every remaining destination still works, and the selected one is the filled glyph on
        // the light neutral tile.
        for (final (label, path, index) in [
          ('Likes', Routes.likes, 1),
          ('Messages', Routes.messages, 2),
          ('Profile', Routes.profile, 3),
          ('Home', Routes.home, 0),
        ]) {
          await openTab(tester, label);
          expect(c.read(routerProvider).state.uri.path, startsWith(path));
          final tile =
              tester
                      .widget<AnimatedContainer>(
                        find.byKey(ValueKey('tab-tile-$index')),
                      )
                      .decoration!
                  as BoxDecoration;
          expect(tile.color, AppColors.iconSelectedFill);
          final icon = tester.widget<NumayaIcon>(
            find.descendant(
              of: find.byKey(ValueKey('tab-tile-$index')),
              matching: find.byType(NumayaIcon),
            ),
          );
          expect(icon.filled, isTrue);
          expect(icon.color, AppColors.iconSelected);
        }
      },
    );
  });

  group('UI-028 to UI-031: New Match', () {
    Future<ProviderContainer> match(WidgetTester tester) async {
      final c = await home(tester);
      await swipe(tester, front(c)!, 260);
      expect(find.byType(MatchScreen), findsOneWidget);
      return c;
    }

    testWidgets(
      'app bar, portrait photo, shared card; no composer or Opening Move',
      (tester) async {
        await match(tester);
        expect(find.byType(NumayaTopBar), findsOneWidget);
        expect(find.text('It’s a match!'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(find.text('Send'), findsNothing);
        expect(find.textContaining('Opening Move'), findsNothing);
        expect(
          find.byKey(const ValueKey('match-shared-interests')),
          findsOneWidget,
        );
        final photo = tester.getSize(find.byKey(const ValueKey('match-photo')));
        expect(photo.width / photo.height, closeTo(3 / 4, 0.01));
        // No decorative heart badge on the match photo.
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('match-photo')),
            matching: find.byWidgetPredicate(
              (w) => w is NumayaIcon && w.icon == NumayaIcons.heart,
            ),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'View profile opens the matched person; back returns to the match',
      (tester) async {
        await match(tester);
        await tapOn(tester, find.byKey(const ValueKey('match-view-profile')));
        await settle(tester);
        final profile = tester.widget<PersonProfileScreen>(
          find.byType(PersonProfileScreen),
        );
        expect(profile.personId, 'maya');
        await tapOn(tester, find.bySemanticsLabel('Back').first);
        await settle(tester);
        expect(find.byType(MatchScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Open chat opens their ordinary conversation; Close keeps browsing',
      (tester) async {
        final c = await match(tester);
        await tapOn(tester, find.byKey(const ValueKey('match-open-chat')));
        await settle(tester);
        expect(c.read(routerProvider).state.uri.path, '${Routes.chat}/maya');
        // Ordinary messaging, no Opening Move gate: the composer is there and sends.
        expect(find.byType(TextField), findsOneWidget);
        expect(find.textContaining('Opening Move'), findsNothing);
        expect(c.read(datingProvider).threads['maya'] ?? const [], isEmpty);
      },
    );

    testWidgets('Close returns to browsing', (tester) async {
      final c = await match(tester);
      await closeMatch(tester);
      await settle(tester);
      expect(find.byType(MatchScreen), findsNothing);
      expect(c.read(routerProvider).state.uri.path, Routes.home);
    });
  });

  group('UI-016 / UI-031 / UI-032: first-release exclusions', () {
    testWidgets('flags are off in this build', (tester) async {
      expect(ReleaseScope.openingMoves, isFalse);
      expect(ReleaseScope.superSwipe, isFalse);
      expect(ReleaseScope.follow, isFalse);
    });

    testWidgets(
      'the Opening Moves route, deep links included, lands on Profile',
      (tester) async {
        final c = await home(tester);
        await goTo(c, tester, Routes.openingMoves);
        expect(find.byType(OpeningMovesScreen), findsNothing);
        expect(c.read(routerProvider).state.uri.path, Routes.profile);
      },
    );

    testWidgets('no Opening Moves, Follow or SuperSwipe on the main surfaces', (
      tester,
    ) async {
      final c = await home(tester);
      for (final path in [
        Routes.messages,
        Routes.profile,
        Routes.editProfile,
        Routes.premium,
        '${Routes.paywall}?feature=superSwipes',
        '${Routes.chat}/jo',
      ]) {
        await goTo(c, tester, path);
        await settle(tester);
        expect(find.textContaining('Opening Move'), findsNothing, reason: path);
        expect(find.textContaining('SuperSwipe'), findsNothing, reason: path);
        expect(find.textContaining('Follow'), findsNothing, reason: path);
      }
    });
  });
}

void _noop(bool _) {}
