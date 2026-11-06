@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/verification/application/verification_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Review batch 3 (UI-033–UI-046) evidence: the screens behind A-015, A-017, A-018, A-020 and
/// A-021 at 390×844 (2x), with the quick-start demo data. Writes to
/// `test/screenshots/comparison/r3/<set>/`, where `<set>` is `--dart-define=R3_SET=before|after`.
/// Opt-in: `flutter test --tags comparison --run-skipped --update-goldens <this file>`.
void main() {
  setUpAll(loadAppFonts);
  const set = String.fromEnvironment('R3_SET', defaultValue: 'after');

  for (final (route, name) in [
    (Routes.messages, 'a015-messages'),
    ('${Routes.chat}/priya', 'a017-chat'),
    (Routes.profile, 'a018-profile'),
    (Routes.editBasics, 'a020-basics'),
    (Routes.completion, 'a021-completion'),
  ]) {
    testWidgets('r3 $name', (tester) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final c = await quickStartApp(tester);
      await goTo(c, tester, route);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('comparison/r3/$set/$name.png'),
      );
      await settle(tester);
    });
  }

  // Stress: 320pt wide at 200% text.
  for (final (route, name) in [
    (Routes.messages, 's320-messages'),
    ('${Routes.chat}/priya', 's320-chat'),
    (Routes.profile, 's320-profile'),
    (Routes.completion, 's320-completion'),
  ]) {
    testWidgets('r3 $name', (tester) async {
      tester.view.physicalSize = const Size(640, 1386);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester);
      await goTo(c, tester, route);
      await tester.pump(const Duration(milliseconds: 600));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('comparison/r3/$set/$name.png'),
      );
      await settle(tester);
    });
  }

  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  Future<void> shot(WidgetTester tester, String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('comparison/r3/$set/$name.png'),
  );

  testWidgets('r3 i1-time-reveal', (tester) async {
    await phone(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    final g = await tester.startGesture(
      tester.getCenter(find.text('That bakery on Columbia Road, right?')),
    );
    await g.moveBy(const Offset(-20, 0));
    await g.moveBy(const Offset(-60, 0));
    await tester.pump();
    await shot(tester, 'i1-time-reveal');
    await g.up();
    await settle(tester);
  });

  testWidgets('r3 i2-reply-preview', (tester) async {
    await phone(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    await tester.drag(find.text('Have you been?'), const Offset(90, 0));
    await tester.pumpAndSettle();
    await shot(tester, 'i2-reply-preview');
    await settle(tester);
  });

  testWidgets('r3 i3-reply-sent', (tester) async {
    await phone(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    await tester.drag(find.text('Have you been?'), const Offset(90, 0));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Not yet! Saturday?');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(milliseconds: 900));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 400));
    await shot(tester, 'i3-reply-sent');
    await settle(tester);
  });

  testWidgets('r3 i4-keyboard-multiline', (tester) async {
    await phone(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    addTearDown(tester.view.resetViewInsets);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    await tester.tap(find.byType(TextField));
    await tester.enterText(
      find.byType(TextField),
      'A longer draft that wraps onto a second line,\nand a third line too.',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await shot(tester, 'i4-keyboard-multiline');
    await settle(tester);
  });

  testWidgets('r3 i5-profile-verified', (tester) async {
    await phone(tester);
    final c = await quickStartApp(tester);
    c.read(photoVerificationProvider.notifier).setApproveNext(true);
    final done = c.read(photoVerificationProvider.notifier).submit();
    await tester.pump(const Duration(seconds: 3));
    await done;
    await goTo(c, tester, Routes.profile);
    await tester.pump(const Duration(milliseconds: 600));
    await shot(tester, 'i5-profile-verified');
    await settle(tester);
  });

  testWidgets('r3 a022-a025-filters-tooltip-switch', (tester) async {
    await phone(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.home);
    await tester.tap(find.bySemanticsLabel('Filters').first);
    await tester.pumpAndSettle();
    final slider = find.byType(RangeSlider).first;
    final r = tester.getRect(slider);
    // Press the lower thumb and drag it a few steps: the tooltip shows that thumb's age.
    final g = await tester.startGesture(
      Offset(r.left + r.width * 0.12, r.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 50));
    for (var i = 0; i < 4; i++) {
      await g.moveBy(const Offset(6, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'a022-a025-filters-tooltip-switch');
    await g.up();
    await settle(tester);
  });
}
