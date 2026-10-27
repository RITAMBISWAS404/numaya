@Tags(['screenshots'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';
import '../helpers/worst_case.dart';

/// The worst-case member (test/helpers/worst_case.dart) on the screens that show their own data,
/// into goldens/wNN-*.png, for docs/mobile/UI_POLISH_QA.md. Opt-in: `--tags screenshots
/// --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture worst case', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester);
    applyWorstCase(c);
    unawaited(
      c
          .read(datingProvider.notifier)
          .send(
            'priya',
            'https://maps.example.com/place/Columbia+Road+Flower+Market/@51.5291,-0.0700,17z',
          ),
    );
    await tester.pump(const Duration(seconds: 2));

    Future<void> shot(String route, String name) async {
      await goTo(c, tester, route);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/w$name.png'),
      );
    }

    await shot(Routes.profile, '01-profile');
    await shot(Routes.preview, '02-preview');
    await shot(Routes.editProfile, '03-edit-profile');
    await shot(Routes.openingMoves, '04-opening-moves');
    await shot('${Routes.chat}/priya', '05-chat-long-link');
    await shot(Routes.messages, '06-messages');
    await settle(tester);
  });
}
