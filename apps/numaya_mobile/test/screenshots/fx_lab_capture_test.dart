@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Fable design lab (2026-11-13): every `fx-*` option rendered by the real app with one fixture
/// set (the full demo world) at 393 x 852 logical, 3x. Writes
/// `test/screenshots/fx/<group>__<option>__<view>.png`.
///
/// Opt-in: `flutter test --tags comparison --run-skipped --update-goldens <this file>`.
/// `--dart-define=FX_ONLY=<group prefix>` limits the run; `FX_SCALE=1.5` and `FX_WIDTH=360` render
/// the stress samples into `fx/stress/`.
const _only = String.fromEnvironment('FX_ONLY');
const _scale = String.fromEnvironment('FX_SCALE', defaultValue: '1');
const _width = String.fromEnvironment('FX_WIDTH', defaultValue: '393');

typedef _Scene = ({
  String group,
  String option,
  String view,
  String route,
  Map<String, String> choices,
  double scroll,
});

_Scene _s(
  String group,
  String option,
  String view,
  String route, {
  Map<String, String> choices = const {},
  double scroll = 0,
}) => (
  group: group,
  option: option,
  view: view,
  route: route,
  choices: {if (option != 'O') group: option, ...choices},
  scroll: scroll,
);

final List<_Scene> _scenes = [
  for (final o in ['O', 'A', 'B']) ...[
    _s('fx-discover', o, 'top', Routes.home),
    _s('fx-discover', o, 'more', Routes.home, scroll: 640),
    _s('fx-profile', o, 'top', Routes.profile),
    _s('fx-profile', o, 'more', Routes.profile, scroll: 620),
    _s('fx-messages', o, 'top', Routes.messages),
    _s('fx-compliment-thread', o, 'photo', '${Routes.chat}/sam'),
    _s('fx-compliment-thread', o, 'prompt', '${Routes.chat}/chloe'),
    _s('fx-wallet', o, 'top', Routes.wallet),
    _s('fx-streak', o, 'top', Routes.streak),
  ],
];

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await DemoPhotoLibrary.load();
  });

  final stress = _scale != '1' || _width != '393';
  final dir = stress ? 'fx/stress/w${_width}_x$_scale' : 'fx';

  for (final s in _scenes) {
    if (_only.isNotEmpty && !s.group.startsWith(_only)) continue;
    final known = kLabGroups.any((g) => g.id == s.group);
    testWidgets('${s.group} ${s.option} ${s.view}', skip: !known, (
      tester,
    ) async {
      final w = double.parse(_width);
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(w, 852) * 3;
      tester.platformDispatcher.textScaleFactorTestValue = double.parse(_scale);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      c.read(onboardingProvider.notifier).loadSample();
      final lab = c.read(labChoicesProvider.notifier);
      s.choices.forEach(lab.choose);
      await goTo(c, tester, s.route);
      // Photos decode on the real event loop.
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }
      if (s.scroll > 0) {
        await tester.drag(
          find.byType(Scrollable).first,
          Offset(0, -s.scroll),
        );
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 150)),
          );
          await tester.pump(const Duration(milliseconds: 300));
        }
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('$dir/${s.group}__${s.option}__${s.view}.png'),
      );
      await settle(tester);
    });
  }
}
