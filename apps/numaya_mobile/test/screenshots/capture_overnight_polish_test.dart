@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Overnight polish captures (docs/design-experiments/overnight-polish/): the mascot empty state
/// and the large-text fixes (OP-04) on a 320pt phone at 200% text. Into goldens/op*.png.
/// Opt-in: `flutter test --tags screenshots --run-skipped --update-goldens`.
void main() {
  setUpAll(loadAppFonts);

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('capture the mascot empty state', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.like}/nobody');
    await shot(tester, 'op01-like-gone-mascot');
    await settle(tester);
  });

  testWidgets('capture large-text fixes at 320pt and 200%', (tester) async {
    tester.view.physicalSize = const Size(640, 1386);
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await quickStartApp(tester);
    await shot(tester, 'op02-discover-320-200');
    await goTo(c, tester, Routes.profile);
    await shot(tester, 'op03-profile-320-200');
    await settle(tester);
  });
}
