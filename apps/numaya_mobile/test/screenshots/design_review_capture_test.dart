@Tags(['comparison'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/data/media_picker.dart';
import 'package:numaya_mobile/features/experiments/experiments.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// The complete design-experiment review (2026-11-14): renders every scene in the plan written by
/// `tool/design_review/scenes.py` with the real app, the full demo world and the local demo photos,
/// 393 logical wide at 3x, default typography. Writes `test/screenshots/design_review/<id>.png`
/// (git-ignored: the images show the private demo photos).
///
///     flutter test --tags comparison --run-skipped --update-goldens \
///       test/screenshots/design_review_capture_test.dart --dart-define=SCENES=<scenes.json>
const _scenes = String.fromEnvironment('SCENES');
const _only = String.fromEnvironment('ONLY');

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await DemoPhotoLibrary.load();
  });
  if (_scenes.isEmpty) return;
  final plan =
      jsonDecode(File(_scenes).readAsStringSync()) as Map<String, dynamic>;
  for (final raw in plan['scenes'] as List<dynamic>) {
    final s = raw as Map<String, dynamic>;
    final id = s['id'] as String;
    if (_only.isNotEmpty && !_only.split(',').any(id.startsWith)) continue;
    testWidgets(id, (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(393, (s['height'] as num).toDouble()) * 3;
      addTearDown(tester.view.reset);
      final c = await quickStartApp(
        tester,
        world: s['empty'] == true ? DemoWorld.fresh : DemoWorld.full,
        overrides: s['events'] == true ? eventsOn : const [],
        mediaPicker: s['attachments'] == true
            ? const SampleMediaPicker()
            : const NoPicker(),
      );
      c.read(onboardingProvider.notifier).loadSample();
      if (s['premium'] == true) c.read(premiumProvider.notifier).setActive(true);
      final lab = c.read(labChoicesProvider.notifier);
      (s['choices'] as Map<String, dynamic>).forEach(
        (k, v) => lab.choose(k, v as String),
      );
      final exp = s['experiment'] as List<dynamic>?;
      if (exp != null) {
        c
            .read(experimentChoicesProvider.notifier)
            .choose(
              Experiment.values.byName(exp[0] as String),
              ExpVariant.values.byName(exp[1] as String),
            );
      }
      await goTo(c, tester, s['route'] as String);
      Future<void> decode([int n = 4]) async {
        for (var i = 0; i < n; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 150)),
          );
          await tester.pump(const Duration(milliseconds: 300));
        }
      }

      await decode();
      if (s['setup'] == 'filters') {
        await tester.tap(find.bySemanticsLabel(RegExp('^Filters')).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        await decode(2);
      }
      if (s['setup'] == 'compliment') {
        final f = find.byKey(const ValueKey('compliment-prompt-0'));
        await tester.ensureVisible(f);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(f);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        await decode(2);
      }
      if (s['setup'] == 'reply') {
        // Reply to Priya's last message so a quoted reply shows in the thread.
        // Swipe right on the bubble (UI-036) to reply, then send from the keyboard.
        await tester.drag(find.text('Have you been?').last, const Offset(160, 0));
        await tester.pump(const Duration(milliseconds: 700));
        await tester.enterText(find.byType(TextField).last, 'Not yet. Saturday?');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pump(const Duration(milliseconds: 900));
        await decode(2);
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('design_review/$id.png'),
      );
      await settle(tester);
    });
  }
}
