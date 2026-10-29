@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/data/media_picker.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Chat media states from the overnight pass, into goldens/nNN-*.png, for
/// docs/mobile/OVERNIGHT_QA_REPORT.md. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture chat media', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(
      tester,
      mediaPicker: const SampleMediaPicker(),
    );

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/n$name.png'),
      );
    }

    Future<void> choose(String option) async {
      await tapOn(
        tester,
        find.bySemanticsLabel('Add a photo, video or voice note'),
      );
      await tester.pump(const Duration(milliseconds: 600));
      if (option == 'Photo') await shot('01-attach-menu');
      await tester.tap(find.text(option).last);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
    }

    await goTo(c, tester, '${Routes.chat}/priya');
    await choose('Photo');
    await tester.enterText(find.byType(TextField), 'The stall I mentioned');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('02-photo-pending');
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(seconds: 1));
    await shot('03-photo-sent');

    await choose('Video');
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(seconds: 3));

    await choose('Voice note');
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Start recording'));
    await tester.pump(const Duration(seconds: 7));
    await shot('04-voice-recording');
    await tester.tap(find.widgetWithText(NumayaButton, 'Stop'));
    await tester.pump();
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Add to message'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(seconds: 1));
    await shot('05-video-and-voice-sent');

    await goTo(c, tester, Routes.messages);
    await shot('06-inbox-preview');
    await settle(tester);
  });

  testWidgets('capture illustrated empty states', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/n$name.png'),
      );
    }

    await goTo(c, tester, '${Routes.events}?view=mine');
    await shot('07-my-events-going');
    await tester.tap(find.bySemanticsLabel(RegExp('^Hosting')));
    await tester.pump(const Duration(milliseconds: 400));
    await shot('08-my-events-hosting-empty');
    await goTo(c, tester, Routes.events);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump(const Duration(milliseconds: 600));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('09-events-no-results');
    await settle(tester);
  });

  testWidgets('capture profile photos from the phone', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(
      tester,
      mediaPicker: const SampleMediaPicker(),
    );

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/n$name.png'),
      );
    }

    await goTo(c, tester, Routes.editProfile);
    await tapOn(tester, find.bySemanticsLabel('Add a photo').first);
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.bySemanticsLabel('Photo 4 options'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Make main photo'));
    await tester.pump(const Duration(seconds: 3));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
    await shot('10-edit-profile-real-photo');
    await goTo(c, tester, Routes.profile);
    await shot('11-profile-real-avatar');
    await goTo(c, tester, Routes.preview);
    await shot('12-preview-real-photo');
    await settle(tester);
  });
}
