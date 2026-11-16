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

/// V10 pilot (2026-11-16): Discover, own Profile and Chat for each direction, with identical
/// fixtures (full demo world, sample profile, local demo photos), viewport (393 x 852 logical at
/// 3x = 1179 x 2556), fonts and demo provider mode. Writes `test/screenshots/v10/<dir>/<id>.png`
/// (git-ignored: private demo photos).
///
///     flutter test --tags comparison --run-skipped --update-goldens \
///       test/screenshots/v10_capture_test.dart --dart-define=V10_DIRS=O,A,C
const _dirs = String.fromEnvironment('V10_DIRS', defaultValue: 'O');
const _only = String.fromEnvironment('V10_ONLY');
const _scale = String.fromEnvironment('V10_SCALE', defaultValue: '1');
const _width = String.fromEnvironment('V10_WIDTH', defaultValue: '393');

class _Scene {
  const _Scene(this.id, this.route, {this.scroll = 0});
  final String id;
  final String route;
  final double scroll;
}

const _scenes = [
  _Scene('discover-1-top', Routes.home),
  _Scene('discover-2-mid', Routes.home, scroll: 560),
  _Scene('discover-3-low', Routes.home, scroll: 1160),
  _Scene('profile-1-top', Routes.profile),
  _Scene('profile-2-mid', Routes.profile, scroll: 600),
  _Scene('chat-1-active', '${Routes.chat}/priya'),
  _Scene('chat-2-received-compliment', '${Routes.chat}/sam'),
];

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await DemoPhotoLibrary.load();
  });

  final stress = _scale != '1' || _width != '393';
  for (final dir in _dirs.split(',')) {
    for (final s in _scenes) {
      if (_only.isNotEmpty && !s.id.startsWith(_only)) continue;
      testWidgets('$dir ${s.id}', (tester) async {
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = Size(double.parse(_width), 852) * 3;
        tester.platformDispatcher.textScaleFactorTestValue = double.parse(
          _scale,
        );
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final c = await quickStartApp(tester, world: DemoWorld.full);
        c.read(onboardingProvider.notifier).loadSample();
        // Always choose explicitly: since A became the default, leaving O unchosen rendered A
        // into the O folder (caught by the final blind critic).
        if (kLabGroups.any((g) => g.id == 'v10-direction')) {
          c.read(labChoicesProvider.notifier).choose('v10-direction', dir);
        }
        await goTo(c, tester, s.route);
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
        final sub = stress ? '$dir/stress_w${_width}_x$_scale' : dir;
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('v10/$sub/${s.id}.png'),
        );
        await settle(tester);
      });
    }
  }
}
