import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Overnight v3 baseline corrections: V3-D01 (the Unmatch and Block sheets scroll their body above
/// a pinned action instead of overflowing) and V3-F01 (a tappable InfoCard shows Ente's round arrow).
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'V3-D01: the Unmatch sheet fits 320pt at 200% text, action pinned',
    (tester) async {
      tester.view.physicalSize = const Size(640, 1386);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.chat}/priya');
      await tester.tap(find.bySemanticsLabel('Conversation options').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unmatch').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // The destructive action stays on screen without scrolling.
      final button = find.widgetWithText(NumayaButton, 'Unmatch');
      expect(button.hitTestable(), findsOneWidget);
      // The body scrolls to reach the "report instead" card.
      await tester.scrollUntilVisible(
        find.byType(InfoCard),
        80,
        scrollable: find
            .descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.byType(InfoCard).hitTestable(), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets('V3-F01: InfoCard shows the arrow only when it is tappable', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              InfoCard(icon: NumayaIcons.info, title: 'Plain'),
              InfoCard(
                icon: NumayaIcons.flag,
                title: 'Tappable',
                trailingArrow: true,
              ),
            ],
          ),
        ),
      ),
    );
    final arrows = find.byWidgetPredicate(
      (w) => w is NumayaIcon && w.icon == NumayaIcons.arrowRight,
    );
    expect(arrows, findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(InfoCard, 'Tappable'),
        matching: arrows,
      ),
      findsOneWidget,
    );
  });
}
