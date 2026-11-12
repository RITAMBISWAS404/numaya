import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/test_app.dart';

/// Replacement V8 large-text review (SCREEN_LEDGER): defects found in the 200% captures.
void main() {
  setUpAll(loadAppFonts);

  Future<void> host(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('a balanced title never breaks inside a word', (tester) async {
    await host(
      tester,
      BalancedText('Compliment Noor', style: AppTypography.flowTitle),
    );
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(BalancedText),
        matching: find.byType(Text),
      ),
    );
    final box = tester.getSize(find.byWidget(text));
    final painter = TextPainter(
      text: TextSpan(text: 'Compliment', style: AppTypography.flowTitle),
      textDirection: TextDirection.ltr,
      textScaler: const TextScaler.linear(2),
    )..layout();
    expect(box.width, greaterThanOrEqualTo(painter.width));
    painter.dispose();
  });

  testWidgets('the unread badge grows with the text instead of clipping', (
    tester,
  ) async {
    await host(tester, const CountBadge(count: 2));
    final badge = tester.getSize(find.byType(CountBadge));
    final digit = tester.getSize(find.text('2'));
    expect(badge.height, greaterThanOrEqualTo(digit.height));
  });
}
