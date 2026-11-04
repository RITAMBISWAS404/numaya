@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Solid against frosted tab bar on identical content (DX-04). High Contrast is the only input that
/// switches the bar to the solid pill, so it renders the solid variant. Writes to
/// `test/screenshots/comparison/nav/`. Opt-in: `--tags comparison --run-skipped --update-goldens`.
void main() {
  setUpAll(loadAppFonts);

  for (final solid in [false, true]) {
    testWidgets('navigation ${solid ? 'solid' : 'frosted'}', (tester) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      if (solid) {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(highContrast: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
      }
      final c = await quickStartApp(tester);
      for (final (route, name) in [
        (Routes.home, 'discover'),
        (Routes.messages, 'messages'),
        (Routes.events, 'events'),
      ]) {
        await goTo(c, tester, route);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'comparison/nav/${solid ? 'solid' : 'frosted'}-$name.png',
          ),
        );
      }
      await settle(tester);
    });
  }
}
