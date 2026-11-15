import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Production readiness (2026-11-15).
void main() {
  setUpAll(loadAppFonts);

  group('PR-002 the phone step with the keyboard open', () {
    // A software keyboard is modelled as a bottom view inset (what the platform reports). No
    // unfocus, no hidden shortcuts: the member taps the step button while typing.
    for (final (w, h, scale, kb) in [
      (393.0, 852.0, 1.0, 300.0),
      (360.0, 640.0, 1.0, 280.0),
      (320.0, 568.0, 1.5, 260.0),
    ]) {
      testWidgets(
        '${w.toInt()}x${h.toInt()} at ${scale}x, keyboard ${kb.toInt()}',
        (tester) async {
          tester.view.devicePixelRatio = 2;
          tester.view.physicalSize = Size(w, h) * 2;
          tester.view.viewInsets = FakeViewPadding(bottom: kb * 2);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final auth = testAuth();
          await tester.pumpWidget(testApp(auth: auth));
          await tester.pump();
          await tapOn(tester, find.text('Create an account'));
          await tester.enterText(find.byType(TextField), '4155550132');
          await tester.pump();
          final fab = find.byType(NumayaFab);
          final rect = tester.getRect(fab);
          // Fully above the keyboard.
          expect(rect.bottom, lessThanOrEqualTo(h - kb + 0.5));
          // Tapping it as a member would, while still typing, sends the code.
          await tester.tapAt(rect.center);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
          expect(auth.latestMessage, isNotNull);
          await settle(tester);
        },
      );
    }
  });
}
