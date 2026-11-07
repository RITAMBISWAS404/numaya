import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/experiments/experiment_lab_screen.dart';
import 'package:numaya_mobile/features/experiments/experiments.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Overnight v3 experiments: every variant keeps the task (main and secondary actions, back),
/// variants are independent, and only the lab (never a release build) switches them.
void main() {
  setUpAll(loadAppFonts);

  String path(ProviderContainer c) => c
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .last
      .matchedLocation;

  Future<ProviderContainer> open(
    WidgetTester tester,
    Experiment e,
    ExpVariant v,
    String route, {
    DemoWorld world = DemoWorld.full,
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester, world: world, overrides: overrides);
    c.read(experimentChoicesProvider.notifier).choose(e, v);
    await goTo(c, tester, Routes.profile);
    await goTo(c, tester, route);
    await tester.pump(const Duration(seconds: 1));
    return c;
  }

  test('release builds always render the refined candidate', () {
    final c = ProviderContainer(
      overrides: [demoAuthProvider.overrideWithValue(null)],
    );
    addTearDown(c.dispose);
    c
        .read(experimentChoicesProvider.notifier)
        .choose(Experiment.matchMoment, ExpVariant.b);
    expect(
      c.read(experimentVariantProvider(Experiment.matchMoment)),
      ExpVariant.current,
    );
  });

  testWidgets('choices are independent and summarised for a reply', (
    tester,
  ) async {
    final c = await quickStartApp(tester);
    final n = c.read(experimentChoicesProvider.notifier)
      ..choose(Experiment.matchMoment, ExpVariant.b)
      ..choose(Experiment.profileHeader, ExpVariant.a);
    expect(
      c.read(experimentVariantProvider(Experiment.matchMoment)),
      ExpVariant.b,
    );
    expect(
      c.read(experimentVariantProvider(Experiment.emptyChats)),
      ExpVariant.current,
    );
    expect(
      ExperimentLabScreen.summary(c.read(experimentChoicesProvider)),
      'EXP-001 B; EXP-002 A; EXP-003 Current; EXP-004 Current',
    );
    n.resetAll();
    expect(c.read(experimentChoicesProvider), isEmpty);
    await settle(tester);
  });

  testWidgets('the lab switches a variant with its chips', (tester) async {
    tester.view.physicalSize = const Size(780, 2800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.experimentLab);
    await tester.tap(
      find.byKey(const ValueKey('lab-EXP-003-empty-conversations-C')),
    );
    await tester.pump();
    expect(
      c.read(experimentVariantProvider(Experiment.emptyChats)),
      ExpVariant.c,
    );
    expect(find.text('Open page, one action'), findsOneWidget);
    await settle(tester);
  });

  group('EXP-001 match moment', () {
    for (final v in ExpVariant.values) {
      testWidgets('${v.letter}: open chat, view profile, close', (
        tester,
      ) async {
        final route = '${Routes.match}/maya';
        var c = await open(tester, Experiment.matchMoment, v, route);
        expect(tester.takeException(), isNull);
        expect(find.text('Jazz'), findsOneWidget);
        await tapOn(tester, find.byKey(const ValueKey('match-open-chat')));
        await tester.pump(const Duration(milliseconds: 600));
        expect(path(c), '${Routes.chat}/maya');
        await settle(tester);

        c = await open(tester, Experiment.matchMoment, v, route);
        await tapOn(tester, find.byKey(const ValueKey('match-view-profile')));
        await tester.pump(const Duration(milliseconds: 600));
        expect(path(c), '${Routes.person}/maya');
        await settle(tester);

        c = await open(tester, Experiment.matchMoment, v, route);
        await closeMatch(tester);
        expect(path(c), isNot(startsWith(Routes.match)));
        await settle(tester);
      });
    }
  });

  group('EXP-002 own-profile header', () {
    for (final v in ExpVariant.values) {
      testWidgets('${v.letter}: edit and verify', (tester) async {
        var c = await open(tester, Experiment.profileHeader, v, Routes.profile);
        expect(tester.takeException(), isNull);
        expect(find.text('Alex, 30'), findsOneWidget);
        await tapOn(tester, find.text('Edit profile'));
        await tester.pump(const Duration(milliseconds: 600));
        expect(path(c), Routes.editProfile);
        await settle(tester);

        c = await open(tester, Experiment.profileHeader, v, Routes.profile);
        // The unverified pill opens verification in every variant.
        await tapOn(tester, find.text('Not verified').first);
        await tester.pump(const Duration(milliseconds: 600));
        expect(path(c), Routes.verifyPhoto);
        await settle(tester);
      });
    }

    // Superseded on Profile by Visual Lab V2 group `profile-header` (C is now identity with
    // streak); the EXP-002 C widget is still previewed in the Visual Lab.
    testWidgets('C: Preview is one tap from the tab', skip: true, (
      tester,
    ) async {
      final c = await open(
        tester,
        Experiment.profileHeader,
        ExpVariant.c,
        Routes.profile,
      );
      await tapOn(tester, find.byKey(const ValueKey('profile-action-preview')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(path(c), Routes.preview);
      await settle(tester);
    });
  });

  // Superseded by R11 (Visual Lab V2): completion is the supporting Profile setup card, counted
  // in parts (group `profile-setup`), not a percentage. Kept for history; not run.
  group('EXP-004 completion card', skip: true, () {
    for (final v in ExpVariant.values) {
      testWidgets('${v.letter}: same percentage, reaches the hub', (
        tester,
      ) async {
        final c = await open(
          tester,
          Experiment.completionCard,
          v,
          Routes.profile,
        );
        expect(tester.takeException(), isNull);
        expect(find.textContaining('28%'), findsWidgets);
        final Finder target = switch (v) {
          ExpVariant.a => find.byKey(const ValueKey('completion-banner')),
          ExpVariant.b => find.text('See all'),
          _ => find.widgetWithText(NumayaButton, 'Complete profile'),
        };
        await tapOn(tester, target);
        await tester.pump(const Duration(milliseconds: 600));
        expect(path(c), Routes.completion);
        await settle(tester);
      });
    }

    testWidgets('B: Continue opens the next unfinished part (photos)', (
      tester,
    ) async {
      final c = await open(
        tester,
        Experiment.completionCard,
        ExpVariant.b,
        Routes.profile,
      );
      expect(find.text('Next: Photos'), findsOneWidget);
      await tapOn(
        tester,
        find.byKey(const ValueKey('completion-next-continue')),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(path(c), Routes.editProfile);
      await settle(tester);
    });
  });

  group('EXP-003 empty conversations', () {
    for (final v in ExpVariant.values) {
      testWidgets('${v.letter}: Find your people opens Discover', (
        tester,
      ) async {
        final c = await open(
          tester,
          Experiment.emptyChats,
          v,
          Routes.messages,
          world: DemoWorld.fresh,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Connections start here'), findsOneWidget);
        final target = v == ExpVariant.b
            ? find.text('Browse people near you')
            : find.text('Find your people');
        await tapOn(tester, target);
        await tester.pump(const Duration(milliseconds: 600));
        expect(path(c), Routes.home);
        await settle(tester);
      });
    }

    for (final v in [ExpVariant.a, ExpVariant.b]) {
      testWidgets('${v.letter}: no Events path in the MVP', (tester) async {
        await open(
          tester,
          Experiment.emptyChats,
          v,
          Routes.messages,
          world: DemoWorld.fresh,
        );
        expect(find.text('Find an event'), findsNothing);
        expect(find.text('Connections start here'), findsOneWidget);
        await settle(tester);
      });
    }

    testWidgets('B with Events available: Find an event opens Events', (
      tester,
    ) async {
      final c = await open(
        tester,
        Experiment.emptyChats,
        ExpVariant.b,
        Routes.messages,
        world: DemoWorld.fresh,
        overrides: eventsOn,
      );
      await tapOn(tester, find.text('Find an event'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(path(c), Routes.events);
      await settle(tester);
    });

    testWidgets('the cat is decorative: no extra screen-reader stop', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(
        tester,
        Experiment.emptyChats,
        ExpVariant.c,
        Routes.messages,
        world: DemoWorld.fresh,
      );
      expect(find.byType(MascotArt), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MascotArt),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && (w.properties.label ?? '').isNotEmpty,
          ),
        ),
        findsNothing,
      );
      handle.dispose();
      await settle(tester);
    });
  });
}
