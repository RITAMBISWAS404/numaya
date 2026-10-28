@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/events/application/events_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Events screens and states at 393 x 852 @2x, into goldens/vNN-*.png, for
/// docs/mobile/EVENTS_QA_REPORT.md. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture events', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester, world: DemoWorld.full);
    final router = c.read(routerProvider);
    final events = c.read(eventsProvider.notifier);
    c.read(profileDetailsProvider.notifier).setArea('Hackney, London');
    final o = c.read(onboardingProvider.notifier);
    for (final i in ['Jazz', 'Board games']) {
      if (!c.read(onboardingProvider).draft.interests.contains(i)) {
        o.toggleInterest(i);
      }
    }

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/v$name.png'),
      );
    }

    Future<void> go(String path) async {
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> push(String path) async {
      // Not awaited: push completes only when the page is closed.
      // ignore: unawaited_futures
      router.push(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> back() async {
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    await go(Routes.events);
    await shot('01-explore');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1400),
    );
    await shot('02-explore-list');
    events.setQuery('karaoke');
    await go(Routes.events);
    await shot('03-no-results');
    events.clearFilters();

    await push('${Routes.event}/e-jazz');
    await shot('04-detail-open');
    await back();
    await push('${Routes.event}/e-board');
    await shot('05-detail-full');
    // Not awaited: the demo repository's latency runs on the test clock.
    // ignore: unawaited_futures
    events.join('e-board');
    await tester.pump(const Duration(milliseconds: 400));
    await shot('06-detail-waitlisted');
    await back();
    await push('${Routes.event}/e-poetry');
    await shot('07-detail-cancelled');
    await back();
    await push('${Routes.event}/e-wine');
    await shot('08-detail-going-changed');
    await back();
    await push('${Routes.event}/e-mine');
    await shot('09-detail-host');
    await push('${Routes.event}/e-mine/people');
    await shot('10-people-host');
    await back();
    await back();
    await push(Routes.eventNew);
    await shot('11-create-empty');
    await back();

    await go('${Routes.events}?view=mine');
    await shot('12-my-events');

    c.read(datingProvider.notifier).setSimulateErrors(true);
    await go('${Routes.events}?view=explore');
    await shot('13-error');
    c.read(datingProvider.notifier).setSimulateErrors(false);
  });
}
