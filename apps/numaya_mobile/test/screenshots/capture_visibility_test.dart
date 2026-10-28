@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/account_health/application/visibility_report.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/settings/application/account_prefs.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Profile & visibility at 393 x 852 @2x, into goldens/hNN-*.png, for
/// docs/mobile/ACCOUNT_HEALTH_QA_REPORT.md. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture visibility', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester, world: DemoWorld.full);
    final router = c.read(routerProvider);
    final signals = c.read(accountSignalsProvider.notifier);

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/h$name.png'),
      );
    }

    Future<void> go(String path) async {
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> scroll(double dy) async {
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        Offset(0, -dy),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    await go(Routes.profile);
    await scroll(500);
    await shot('01-profile-entry');
    await go(Routes.visibility);
    await shot('02-visible');
    await scroll(700);
    await shot('03-completeness-discovery');
    await scroll(700);
    await shot('04-verification-notices-activity');
    await scroll(1400);
    await shot('05-suggestions');

    c.read(accountPrefsProvider.notifier).startSnooze(SnoozeLength.day);
    c.read(datingProvider.notifier).setSnoozed(true);
    await go(Routes.profile);
    await go(Routes.visibility);
    await shot('06-paused');
    c.read(accountPrefsProvider.notifier).endSnooze();
    c.read(datingProvider.notifier).setSnoozed(false);

    signals.setNotice(NoticeState.restricted);
    await tester.pump();
    await shot('07-restricted');
    signals.setNotice(NoticeState.unavailable);
    await tester.pump();
    await shot('08-cant-check');
    signals
      ..setNotice(NoticeState.notice)
      ..setInsights(InsightsState.unavailable);
    await tester.pump();
    await scroll(1100);
    await shot('09-notice-activity-unavailable');
    signals.reset();

    await go(Routes.visibilityAbout);
    await shot('10-how-it-works');
  });
}
