@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';
import 'v8_scenes.dart';

/// V8 UI review (2026-11-14): renders scenes from [v8Scenes] with the real app, the full demo
/// world and the local demo photos at 393 x 852 logical, 3x (1179 x 2556). Writes
/// `test/screenshots/v8/<id>.png` (git-ignored: the images show the private demo photos).
///
///     flutter test --tags comparison --run-skipped --update-goldens \
///       test/screenshots/v8_review_capture_test.dart [--dart-define=V8_ONLY=<id prefix>]
///
/// `V8_SCALE=1.5` / `V8_WIDTH=320` render stress samples into `v8/stress/`.
const _only = String.fromEnvironment('V8_ONLY');
const _scale = String.fromEnvironment('V8_SCALE', defaultValue: '1');
const _width = String.fromEnvironment('V8_WIDTH', defaultValue: '393');

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await DemoPhotoLibrary.load();
  });
  tearDown(() => AppTypography.apply(TypeSettings.baseline));

  final stress = _scale != '1' || _width != '393';
  final dir = stress ? 'v8/stress/w${_width}_x$_scale' : 'v8';

  for (final s in v8Scenes) {
    if (_only.isNotEmpty &&
        !_only.split(',').any((p) => s.id.startsWith(p))) {
      continue;
    }
    testWidgets(s.id, (tester) async {
      final w = double.parse(_width);
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(w, s.height) * 3;
      tester.platformDispatcher.textScaleFactorTestValue = double.parse(_scale);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      AppTypography.apply(s.type);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      c.read(onboardingProvider.notifier).loadSample();
      if (s.premium) c.read(premiumProvider.notifier).setActive(true);
      final lab = c.read(labChoicesProvider.notifier);
      s.choices.forEach(lab.choose);
      await goTo(c, tester, s.route);
      Future<void> decode([int n = 4]) async {
        for (var i = 0; i < n; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 150)),
          );
          await tester.pump(const Duration(milliseconds: 300));
        }
      }

      await decode();
      if (s.setup != null) {
        await s.setup!(tester, c);
        await decode(3);
      }
      if (s.scroll > 0) {
        await tester.drag(find.byType(Scrollable).first, Offset(0, -s.scroll));
        await decode(3);
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('$dir/${s.id}.png'),
      );
      await settle(tester);
    });
  }
}
