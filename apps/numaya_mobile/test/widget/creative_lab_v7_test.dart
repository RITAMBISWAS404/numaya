// V7 Creative Lab: every alternative renders on its real route, the baseline stays the default,
// and the rules the brief protects behave the same in every arrangement.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';

import '../helpers/journeys.dart';

const _routes = {
  'v7-nav': Routes.home,
  'v7-discover': Routes.home,
  'v7-compliment': '${Routes.compliment}/noor?kind=prompt&index=0',
  'v7-profile': Routes.profile,
  'v7-streak': Routes.streak,
  'v7-request': '${Routes.request}/seed-chloe',
  'v7-paywall': Routes.paywall,
  'v7-likes-locked': Routes.likes,
};

void main() {
  for (final entry in _routes.entries) {
    for (final v in labGroup(entry.key).ids) {
      testWidgets('${entry.key} $v renders on its route', (tester) async {
        final c = await quickStartApp(tester);
        c.read(labChoicesProvider.notifier).choose(entry.key, v);
        await goTo(c, tester, entry.value);
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Sheet direction opens over Discover and returns to it', (
    tester,
  ) async {
    final c = await quickStartApp(tester);
    c.read(labChoicesProvider.notifier).choose('v7-compliment', 'B');
    await goTo(c, tester, Routes.home);
    await tester.tap(find.byKey(const ValueKey('compliment-photo-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('compliment-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A failed send in the sheet keeps the words and the credit', (
    tester,
  ) async {
    final c = await quickStartApp(tester);
    c.read(labChoicesProvider.notifier).choose('v7-compliment', 'B');
    await goTo(c, tester, Routes.home);
    final before = c.read(creditBalanceProvider);
    await tester.tap(find.byKey(const ValueKey('compliment-photo-0')));
    await tester.pumpAndSettle();
    const words = 'That looks like the best kind of Sunday.';
    await tester.enterText(
      find.byKey(const ValueKey('compliment-field')),
      words,
    );
    await tester.pump();
    c.read(datingProvider.notifier).setSimulateErrors(true);
    await tester.tap(find.byKey(const ValueKey('compliment-send')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(words), findsOneWidget);
    expect(c.read(creditBalanceProvider), before);
  });
}
