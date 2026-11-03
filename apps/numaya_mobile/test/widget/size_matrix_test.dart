import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';
import 'accessibility_test.dart' show fullAppRoutes;

/// Adversarial layout matrix (premium refinement): every full-app route on four phone widths at
/// 100%, 130% and 200% text. A RenderFlex overflow or any other layout exception fails the test.
void main() {
  setUpAll(loadAppFonts);

  const phones = [
    Size(320, 568), // smallest supported (iPhone SE 1st gen class)
    Size(375, 667),
    Size(390, 844),
    Size(430, 932),
  ];
  const scales = [1.0, 1.3, 2.0];

  for (final phone in phones) {
    for (final scale in scales) {
      testWidgets(
        'full-app routes lay out at ${phone.width.toInt()}pt with ${(scale * 100).toInt()}% text',
        (tester) async {
          await usePhoneSize(tester, size: phone);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final c = await quickStartApp(tester);
          for (final route in fullAppRoutes) {
            await goTo(c, tester, route);
            expect(tester.takeException(), isNull, reason: route);
          }
          await settle(tester);
        },
      );
    }
  }
}
