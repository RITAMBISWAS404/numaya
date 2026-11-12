import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/experiments/experiments.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Overnight v4 interaction and edge-case fixes (EVIDENCE.csv V4-01 to V4-04).
void main() {
  setUpAll(loadAppFonts);

  void phone(WidgetTester t, {bool narrow = false}) {
    t.view.devicePixelRatio = 2;
    t.view.physicalSize = narrow
        ? const Size(640, 1386)
        : const Size(780, 1688);
    if (narrow) t.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(t.view.reset);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  }

  for (final v in [
    ExpVariant.current,
    ExpVariant.a,
    ExpVariant.b,
    ExpVariant.c,
  ]) {
    testWidgets(
      'V4-01: a missing main photo shows the initial (header ${v.letter})',
      (tester) async {
        phone(tester);
        final c = await quickStartApp(tester);
        final n = c.read(onboardingProvider.notifier);
        n.replacePhoto(
          c.read(onboardingProvider).draft.photos.first.id,
          source: '/no/such/photo.jpg',
        );
        c
            .read(experimentChoicesProvider.notifier)
            .choose(Experiment.profileHeader, v);
        await goTo(c, tester, Routes.profile);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
        // No error widget, and the initial is drawn in its place.
        expect(find.byType(ErrorWidget), findsNothing);
        expect(find.textContaining('PathNotFoundException'), findsNothing);
        expect(find.text('A'), findsWidgets);
        await settle(tester);
      },
    );
  }

  testWidgets(
    'V4-02: at 200% text a row value moves under the label, words stay whole',
    (tester) async {
      phone(tester, narrow: true);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.settings);
      await tester.pump(const Duration(milliseconds: 600));
      final label = tester.getRect(find.text('Phone number'));
      final value = tester.getRect(find.textContaining('555'));
      expect(value.top, greaterThanOrEqualTo(label.bottom - 1));
      // The label's box is at least as wide as its longest word at this text size, so it can wrap
      // between words but never inside "number".
      final text = tester.widget<Text>(find.text('Phone number'));
      final word = TextPainter(
        text: TextSpan(text: 'number', style: text.style),
        textScaler: const TextScaler.linear(2),
        textDirection: TextDirection.ltr,
      )..layout();
      expect(label.width, greaterThanOrEqualTo(word.width - 0.5));
      word.dispose();
      await settle(tester);
    },
  );

  testWidgets('V4-02: at 100% text the short value stays beside the label', (
    tester,
  ) async {
    phone(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.settings);
    await tester.pump(const Duration(milliseconds: 600));
    final label = tester.getRect(find.text('Phone number'));
    final value = tester.getRect(find.textContaining('555'));
    expect(value.left, greaterThan(label.right));
    await settle(tester);
  });

  for (final v in [ExpVariant.a, ExpVariant.b]) {
    testWidgets(
      'V4-03: match ${v.letter} chips are white on the page and pass contrast',
      (tester) async {
        phone(tester);
        final handle = tester.ensureSemantics();
        final c = await quickStartApp(tester);
        c
            .read(experimentChoicesProvider.notifier)
            .choose(Experiment.matchMoment, v);
        await goTo(c, tester, '${Routes.match}/maya');
        await tester.pump(const Duration(seconds: 2));
        for (final chip in tester.widgetList<InfoChip>(find.byType(InfoChip))) {
          expect(chip.onPage, isTrue);
        }
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
        await settle(tester);
      },
    );
  }

  testWidgets('V4-04: EXP-002 A cover grows with a long name at 200% text', (
    tester,
  ) async {
    phone(tester, narrow: true);
    final c = await quickStartApp(tester);
      // This checks the cover hero of Profile O (kept in the Design Lab).
      c.read(labChoicesProvider.notifier).choose('fx-profile', 'O');
    c.read(onboardingProvider.notifier).setFirstName('Maximiliana-Alexandria');
    // The cover is Visual Lab V2 `profile-header` A (was EXP-002 A).
    c.read(labChoicesProvider.notifier).choose('profile-header', 'A');
    await goTo(c, tester, Routes.profile);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    final name = tester.getRect(find.textContaining('Maximiliana'));
    final edit = tester.getRect(
      find.byKey(const ValueKey('profile-header-edit')),
    );
    final cover = tester.getRect(
      find.byKey(const ValueKey('profile-header-cover')),
    );
    expect(name.top, greaterThan(edit.bottom));
    expect(cover.bottom, greaterThan(name.bottom));
    await settle(tester);
  });
}
