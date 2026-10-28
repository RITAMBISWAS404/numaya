@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/refinement_board.dart';
import '../helpers/test_app.dart';

/// The refined components with worst-case data (test/helpers/refinement_board.dart) into
/// goldens/rNN-*.png, for docs/mobile/UI_REFINEMENT_QA.md. Opt-in: `--tags screenshots
/// --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  for (final (name, width, scale) in [
    ('01-320-1x', 320.0, 1.0),
    ('02-375-1x', 375.0, 1.0),
    ('03-375-2x', 375.0, 2.0),
  ]) {
    testWidgets('capture refinement board $name', (tester) async {
      tester.view.physicalSize = Size(width * 2, scale > 1 ? 4400 : 3000);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(refinementBoard(width: width, textScale: scale));
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/r$name.png'),
      );
    });
  }
}
