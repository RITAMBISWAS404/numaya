import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/refinement_board.dart';

/// The refined components with worst-case data at narrow widths and large text: nothing may
/// overflow (a RenderFlex overflow fails the test), and the decision bar keeps its labels only
/// where they fit (docs/mobile/UI_REFINEMENT_QA.md).
void main() {
  // (width, text scale, whether the Pass and Like pills show their words). Labels need about
  // 112 pt per side pill at 1x, scaled with the text, so they hide early rather than clip.
  for (final (width, scale, labelled) in [
    (320.0, 1.0, false),
    (320.0, 2.0, false),
    (375.0, 1.0, true),
    (375.0, 1.3, false),
    (375.0, 2.0, false),
    (430.0, 1.0, true),
  ]) {
    testWidgets('refined components at ${width.toInt()} pt, ${scale}x text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width * 2, 4000);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(refinementBoard(width: width, textScale: scale));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);

      // Every pill keeps its name for screen readers and a 44 pt minimum target.
      for (final label in ['Pass', 'SuperSwipe', 'Like']) {
        final pill = find.byWidgetPredicate(
          (w) => w is Pressable && w.semanticLabel == label,
        );
        expect(pill, findsOneWidget);
        expect(tester.getSize(pill).height, greaterThanOrEqualTo(44));
      }
      // Labels are drawn only when they fit; the star never has one.
      expect(find.text('Pass'), labelled ? findsOneWidget : findsNothing);
      expect(find.text('SuperSwipe'), findsNothing);

      // The long name and title wrap rather than being cut.
      expect(find.textContaining('Maximiliana-Josephine'), findsOneWidget);
      expect(find.textContaining('absolute beginners'), findsOneWidget);
      // A complete profile offers no action.
      expect(find.text('Complete profile'), findsOneWidget);
    });
  }
}
