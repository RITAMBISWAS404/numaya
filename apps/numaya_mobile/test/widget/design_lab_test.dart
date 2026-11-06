import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:numaya_mobile/app/app.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/demo/presentation/design_lab_screen.dart';

import '../helpers/test_app.dart';

void main() {
  GoRouter routerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
          .read(routerProvider);

  testWidgets('the Design Lab opens from the Demo Hub and shows the system', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp());
    await tester.pump();
    routerOf(tester).go(Routes.demo);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Design Lab'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DesignLabScreen), findsOneWidget);
    expect(find.text('Ente design system'), findsOneWidget);
    // Illustration slots are decorative: present in the tree, absent from semantics.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('illustration-slot-events_explore')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.bySemanticsLabel(RegExp('Illustration: Explore events')),
      findsNothing,
    );
    await settle(tester);
  });

  testWidgets('the Design Lab is refused where demo sign-in is not allowed', (
    tester,
  ) async {
    await usePhoneSize(tester);
    // As in a release build: no demo sign-in.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => testNow),
          demoAuthProvider.overrideWithValue(null),
        ],
        child: const NumayaApp(),
      ),
    );
    await tester.pump();
    routerOf(tester).go(Routes.designLab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DesignLabScreen), findsNothing);
    await settle(tester);
  });

  test('illustration slots keep their proportions', () {
    const slot = IllustrationSlot(
      slot: 'x',
      label: 'Anything',
      aspectRatio: 16 / 9,
    );
    expect(slot.aspectRatio, closeTo(1.777, 0.001));
  });
}
