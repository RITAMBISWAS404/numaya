@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/experiments/experiments.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Overnight v3 experiment evidence: every experiment in each variant (Current = the refined
/// candidate in this branch, A, B, C) with the same fixture and size. Views:
/// `phone` 390x844 (2x, text 1.0); `narrow` 320x693 (2x, text 2.0); `tall` 390x1400 (2x), the
/// scroll continuation. Writes `test/screenshots/comparison/v3/exp/<EXP-id>/<variant>/<view>.png`.
/// Opt-in: `flutter test --tags comparison --run-skipped --update-goldens <this file>`.
void main() {
  setUpAll(loadAppFonts);

  const views = {
    'phone': (Size(780, 1688), 1.0),
    'narrow': (Size(640, 1386), 2.0),
    'tall': (Size(780, 2800), 1.0),
  };

  ({String route, DemoWorld world}) scene(Experiment e) => switch (e) {
    Experiment.matchMoment => (
      route: '${Routes.match}/maya',
      world: DemoWorld.full,
    ),
    Experiment.profileHeader ||
    Experiment.completionCard => (route: Routes.profile, world: DemoWorld.full),
    Experiment.emptyChats => (route: Routes.messages, world: DemoWorld.fresh),
  };

  for (final e in Experiment.values) {
    for (final v in ExpVariant.values) {
      for (final MapEntry(key: view, value: (size, text)) in views.entries) {
        testWidgets('v3 exp ${e.id} ${v.letter} $view', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 2;
          tester.platformDispatcher.textScaleFactorTestValue = text;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final s = scene(e);
          final c = await quickStartApp(tester, world: s.world);
          c.read(experimentChoicesProvider.notifier).choose(e, v);
          await goTo(c, tester, s.route);
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 200)),
          );
          await tester.pump(const Duration(milliseconds: 1200));
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              'comparison/v3/exp/${e.id}/${v.letter}/$view.png',
            ),
          );
          await settle(tester);
        });
      }
    }
  }

  testWidgets('v3 exp lab', (tester) async {
    tester.view.physicalSize = const Size(780, 2800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester);
    c.read(experimentChoicesProvider.notifier)
      ..choose(Experiment.matchMoment, ExpVariant.b)
      ..choose(Experiment.profileHeader, ExpVariant.a);
    await goTo(c, tester, Routes.experimentLab);
    await tester.pump(const Duration(milliseconds: 600));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('comparison/v3/exp/lab.png'),
    );
    await settle(tester);
  });

  // Mascot placement board: the existing waiting cat on the empty Likes tab.
  testWidgets('v3 mascot likes-empty', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, Routes.likes);
    await tester.pump(const Duration(milliseconds: 1200));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('comparison/v3/exp/mascot-likes-empty.png'),
    );
    await settle(tester);
  });
}
