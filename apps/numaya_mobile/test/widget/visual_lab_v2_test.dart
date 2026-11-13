import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Visual Lab V2 (2026-11-08): required changes R01–R12 and the variant registry.
void main() {
  setUpAll(loadAppFonts);

  group('Registry', () {
    test('every group has an O baseline (or M presets), its proposal and 4+ alternatives', () {
      final ids = <String>{};
      for (final g in kLabGroups) {
        expect(ids.add(g.id), isTrue, reason: 'duplicate ${g.id}');
        expect(g.ids, contains(g.proposed), reason: g.id);
        if (g.kind == LabKind.component) {
          expect(g.ids.first, 'O', reason: g.id);
          // profile-header lost D (the Insights header) when Insights was removed (H-13).
          expect(
            g.ids.length,
            greaterThanOrEqualTo(
              g.id == 'profile-header'
                  ? 4
                  // Ente alignment V3 groups: O plus two or three real alternatives (no padding).
                  : g.id.startsWith('ea-') || g.id.startsWith('v4-')
                  ? 3
                  : 5,
            ),
            reason: g.id,
          );
        }
        if (g.kind == LabKind.screen &&
            !g.id.startsWith('v4-') &&
            !g.id.startsWith('v6-') &&
            !g.id.startsWith('v7-') &&
            // Replacement V8 comparisons: the V7 choice plus one or two real options, no padding.
            !g.id.startsWith('r8-') &&
            // Fable lab groups list only implemented options (baseline plus up to two).
            !g.id.startsWith('fx-') &&
            // V8 review groups: the selected baseline plus the requested directions.
            !g.id.startsWith('v8-')) {
          expect(g.ids, ['O', 'A', 'B', 'C'], reason: g.id);
        }
        // Dependencies name real groups and variants.
        for (final needs in g.requires.values) {
          for (final n in needs) {
            final [group, variant] = n.split(':');
            expect(labGroup(group).ids, contains(variant), reason: n);
          }
        }
      }
    });

    test(
      'without demo sign-in (release) the proposed default always renders',
      () {
        final c = ProviderContainer(
          overrides: [demoAuthProvider.overrideWithValue(null)],
        );
        addTearDown(c.dispose);
        c.read(labChoicesProvider.notifier).choose('conversation-row', 'D');
        expect(
          c.read(labVariantProvider('conversation-row')),
          labGroup('conversation-row').proposed,
        );
      },
    );

    testWidgets(
      'every component preview renders every variant at 320dp and 200% text',
      (tester) async {
        await usePhoneSize(tester, size: const Size(320, 568));
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final c = await quickStartApp(tester, overrides: eventsOn);
        c.read(onboardingProvider.notifier).loadSample();
        final failures = <String>[];
        for (final g in kLabGroups.where((g) => g.kind == LabKind.component)) {
          for (final v in g.ids) {
            await goTo(c, tester, '${Routes.visualLabPreview}/${g.id}?v=$v');
            final e = tester.takeException();
            if (e != null) failures.add('${g.id} $v: $e');
            expect(
              find.byKey(const ValueKey('lab-preview-body')),
              findsOneWidget,
            );
          }
        }
        expect(failures, isEmpty);
        await settle(tester);
      },
    );

    testWidgets(
      'every component variant works in its real screen at 320dp and 200% text',
      (tester) async {
        const where = <String, String>{
          'match-avatar': Routes.messages,
          'conversation-row': Routes.messages,
          'compliment-card': '${Routes.likes}?tab=compliments',
          'like-tile': Routes.likes,
          'profile-header': Routes.profile,
          'insights-summary': Routes.insights,
          'metric-widget': Routes.insights,
          'profile-setup': Routes.profile,
          'prompt-card': Routes.home,
          'discover-photo': Routes.home,
          'streak-card': Routes.profile,
          'wallet-card': Routes.profile,
          'plan-card': Routes.paywall,
          'status-banner': '${Routes.chat}/rafa',
          'empty-state': '${Routes.likes}?tab=compliments',
          'ea-event-card': Routes.events,
          'v4-welcome': '${Routes.visualLabPreview}/v4-welcome',
          'ea-event-filters': Routes.events,
          'ea-event-action': '${Routes.evEvent}/ev-board-games-bandra',
          'ea-met-card': '${Routes.evMet}/ev-book-swap',
          'v8-stats': Routes.reviewStats,
        };
        await usePhoneSize(tester, size: const Size(320, 568));
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final c = await quickStartApp(tester);
        c.read(onboardingProvider.notifier).loadSample();
        final failures = <String>[];
        for (final g in kLabGroups.where((g) => g.kind == LabKind.component)) {
          for (final v in g.ids) {
            c.read(labChoicesProvider.notifier)
              ..reset()
              ..chooseAll('B', kind: LabKind.screen)
              ..choose(g.id, v);
            await goTo(c, tester, Routes.demo);
            await goTo(c, tester, where[g.id]!);
            final e = tester.takeException();
            if (e != null) failures.add('${g.id} $v: $e');
          }
        }
        expect(failures, isEmpty);
        await settle(tester);
      },
    );

    testWidgets('every screen direction lays out at 320dp and 200% text', (
      tester,
    ) async {
      await usePhoneSize(tester, size: const Size(320, 568));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester);
      c.read(onboardingProvider.notifier).loadSample();
      final failures = <String>[];
      for (final d in ['O', 'A', 'B', 'C']) {
        c.read(labChoicesProvider.notifier).chooseAll(d, kind: LabKind.screen);
        for (final path in [
          Routes.profile,
          Routes.insights,
          Routes.likes,
          '${Routes.likes}?tab=compliments',
          Routes.messages,
          Routes.home,
        ]) {
          await goTo(c, tester, path);
          final e = tester.takeException();
          if (e != null) failures.add('$d $path: $e');
        }
      }
      expect(failures, isEmpty);
      await settle(tester);
    });
  });

  group('R01 / R02 Chats', () {
    testWidgets(
      'Chats lists Archive, no Requests; new matches are square tiles',
      (tester) async {
        await usePhoneSize(tester);
        await quickStartApp(tester);
        await openTab(tester, 'Messages');
        expect(find.byKey(const ValueKey('chats-archive')), findsOneWidget);
        expect(find.byKey(const ValueKey('chats-requests')), findsNothing);
        // UI-033 (V8): square image-only tiles, no ring.
        expect(find.byType(CountdownAvatar), findsNothing);
        await tapOn(tester, find.byKey(const ValueKey('chats-archive')));
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byKey(const ValueKey('archived-rafa')), findsOneWidget);
        // UI-081 (V8): Archive holds archived conversations only, no expired matches.
        expect(find.byKey(const ValueKey('expired-ollie')), findsNothing);
        // A quiet chat is never called expired.
        expect(find.textContaining('expired chat'), findsNothing);
        await settle(tester);
      },
    );

    testWidgets('inside a new match: a countdown-only banner (UI-086)', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.chat}/jo');
      expect(find.byKey(const ValueKey('chat-countdown')), findsOneWidget);
      expect(find.textContaining('The match ends '), findsNothing);
      expect(find.text('Extend 24 hours'), findsNothing);
      await settle(tester);
    });
  });

  group('V8 Heart tab and Compliment conversations', () {
    testWidgets(
      'Likes only; a Compliment opens from Messages and replies once',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await openTab(tester, 'Likes');
        expect(
          find.byKey(const ValueKey('heart-tab-compliments')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('likes-locked')), findsOneWidget);
        await goTo(c, tester, '${Routes.likes}?tab=compliments');
        // The old Compliments link lands on Messages.
        expect(find.byKey(const ValueKey('conversation-sam')), findsOneWidget);
        await tapOn(tester, find.byKey(const ValueKey('conversation-sam')));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.enterText(find.byType(TextField), 'Thank you!');
        await tester.pump();
        await tapOn(tester, find.bySemanticsLabel('Send'));
        await tester.pump(const Duration(milliseconds: 600));
        final dating = c.read(datingProvider.notifier);
        expect(dating.conversations().where((p) => p.id == 'sam').length, 1);
        expect(c.read(complimentsProvider.notifier).requests().length, 1);
        await settle(tester);
      },
    );

    testWidgets('Dismiss asks first and leaves no duplicate', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.request}/seed-chloe');
      await tester.pump(const Duration(milliseconds: 400));
      await tapOn(tester, find.bySemanticsLabel('Conversation options'));
      await tester.pump(const Duration(milliseconds: 400));
      await tapOn(tester, find.text('Dismiss'));
      await tester.pump(const Duration(milliseconds: 600));
      await tapOn(tester, find.byKey(const ValueKey('dismiss-confirm')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        c
            .read(complimentsProvider.notifier)
            .requests()
            .where((r) => r.id == 'seed-chloe'),
        isEmpty,
      );
      await settle(tester);
    });
  });

  group('R05 / R06 / R08 controls', () {
    testWidgets(
      'the Compliment action sits bottom-right on the photo, clear of the name',
      (tester) async {
        await usePhoneSize(tester);
        await quickStartApp(tester);
        final action = tester.getRect(
          find.byKey(const ValueKey('compliment-photo-0')),
        );
        final name = tester.getRect(find.text('Maya, 29').first);
        expect(action.overlaps(name), isFalse);
        expect(action.left, greaterThan(name.right - 1));
        // Same 48pt target as the overflow control.
        expect(action.width, 48);
        await settle(tester);
      },
    );

    testWidgets('a prompt reserves a footer: the action is below the answer', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      final first = c.read(datingProvider.notifier).queue().first;
      final answer = first.prompt!.answer;
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('compliment-prompt-0')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final action = tester.getRect(
        find.byKey(const ValueKey('compliment-prompt-0')),
      );
      final text = tester.getRect(find.text(answer).first);
      expect(action.top, greaterThanOrEqualTo(text.bottom - 0.5));
      await settle(tester);
    });

    testWidgets(
      'chat header: verified mark after the name, not on the avatar',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, '${Routes.chat}/priya');
        final mark = find.byType(VerifiedMark);
        if (mark.evaluate().isNotEmpty) {
          final name = tester.getRect(find.text('Priya').first);
          expect(tester.getRect(mark.first).left, greaterThan(name.right));
        }
        await settle(tester);
      },
    );

    testWidgets('sheet close is the white squircle with a dark glyph', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.chat}/chloe');
      await tester.pump(const Duration(milliseconds: 400));
      await tapOn(tester, find.bySemanticsLabel('Conversation options'));
      await tester.pump(const Duration(milliseconds: 400));
      await tapOn(tester, find.text('Dismiss'));
      await tester.pump(const Duration(milliseconds: 600));
      final close = find.byKey(const ValueKey('sheet-close'));
      expect(close, findsOneWidget);
      final b = tester.widget<SquircleIconButton>(close);
      expect(b.onBrand, isFalse);
      expect(tester.getSize(close).width, 48);
      await settle(tester);
    });
  });

  group('Health/Insights removed (Events PRD)', () {
    testWidgets(
      'old Health, Insights and visibility links land on Profile, with no note',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        for (final path in [
          Routes.health,
          Routes.healthAbout,
          Routes.insights,
          Routes.visibility,
        ]) {
          await goTo(c, tester, path);
          expect(
            c.read(routerProvider).routerDelegate.currentConfiguration.uri.path,
            Routes.profile,
            reason: path,
          );
        }
        expect(find.textContaining('Your insights'), findsNothing);
        await settle(tester);
      },
    );
  });

  group('R12 large title', () {
    testWidgets('collapses into the bar on scroll and back', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.profile);
      double barOpacity() => tester
          .widgetList<Opacity>(
            find.ancestor(
              of: find.text('Profile'),
              matching: find.byType(Opacity),
            ),
          )
          .first
          .opacity;
      expect(barOpacity(), 0);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 300));
      expect(barOpacity(), 1);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await tester.pump(const Duration(milliseconds: 300));
      expect(barOpacity(), 0);
      await settle(tester);
    });
  });

  group('Motion presets', () {
    testWidgets('M0 is reduced everywhere; M2 is quicker than M1', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      c.read(labChoicesProvider.notifier).choose('motion', 'M2');
      await tester.pump();
      expect(AppMotion.preset, MotionPreset.m2);
      expect(AppMotion.route, const Duration(milliseconds: 240));
      c.read(labChoicesProvider.notifier).choose('motion', 'M0');
      await tester.pump();
      expect(AppMotion.preset, MotionPreset.m0);
      final ctx = tester.element(find.byType(Scaffold).first);
      expect(AppMotion.reduced(ctx), isTrue);
      expect(AppMotion.duration(ctx, AppMotion.state), Duration.zero);
      c.read(labChoicesProvider.notifier).choose('motion', 'M1');
      await tester.pump();
      expect(AppMotion.route, const Duration(milliseconds: 280));
      await settle(tester);
    });
  });
}
