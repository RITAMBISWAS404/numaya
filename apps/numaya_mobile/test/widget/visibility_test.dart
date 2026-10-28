import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/account_health/application/visibility_report.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/features/settings/application/account_prefs.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tapOn(tester, f);
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'reachable from the Profile tab with its status; sample data labelled',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await openTab(tester, 'Profile');
      final row = find.bySemanticsLabel(RegExp('^Profile & visibility'));
      expect(row, findsOneWidget);
      await _tap(tester, row);
      expect(find.text('PROFILE & VISIBILITY'), findsOneWidget);
      final status = c.read(visibilityReportProvider).status;
      expect(status, VisibilityStatus.visible);
      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Sample data'), findsOneWidget);
      expect(find.text('Profile views'), findsOneWidget);
      expect(find.text('Not measured'), findsOneWidget);
      expect(find.textContaining('shadowban'), findsNothing);
      await settle(tester);
    },
  );

  testWidgets('pausing shows Paused with Resume; resuming updates it at once', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.full);
    c.read(accountPrefsProvider.notifier).startSnooze(SnoozeLength.day);
    c.read(datingProvider.notifier).setSnoozed(true);
    await goTo(c, tester, Routes.visibility);
    expect(find.text('Paused'), findsOneWidget);
    expect(find.textContaining('It ends'), findsOneWidget);
    await _tap(tester, find.text('Resume').first);
    expect(c.read(datingProvider).snoozed, isFalse);
    expect(find.text('Visible'), findsOneWidget);
    await settle(tester);
  });

  testWidgets(
    'completeness recalculates after an edit; a suggestion opens the editor',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, Routes.visibility);
      final before = c.read(visibilityReportProvider).completion.percent;
      c.read(profileDetailsProvider.notifier).setBio('');
      await tester.pump();
      final without = c.read(visibilityReportProvider).completion.percent;
      expect(find.text('$without% complete'), findsOneWidget);
      c.read(profileDetailsProvider.notifier).setBio('Designer by day.');
      await tester.pump();
      expect(
        c.read(visibilityReportProvider).completion.percent,
        greaterThan(without),
      );
      expect(before, greaterThanOrEqualTo(without));

      c.read(profileDetailsProvider.notifier).setBio('');
      await tester.pump();
      await _tap(tester, find.text('Write a bio'));
      expect(c.read(routerProvider).state.uri.path, Routes.editProfile);
      await tapOn(tester, find.bySemanticsLabel('Back').first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('PROFILE & VISIBILITY'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'notices: restriction, a notice, and a source that doesn’t answer',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      final signals = c.read(accountSignalsProvider.notifier);
      await goTo(c, tester, Routes.visibility);
      expect(find.text('No notices'), findsOneWidget);

      signals.setNotice(NoticeState.unavailable);
      await tester.pump();
      expect(find.text('Can’t check right now'), findsWidgets);
      expect(find.text('Visible'), findsNothing);
      await _tap(tester, find.text('Try again').first);
      expect(find.text('Visible'), findsOneWidget);

      signals.setNotice(NoticeState.notice);
      await tester.pump();
      expect(find.text('A notice about your profile'), findsOneWidget);
      expect(find.text('Visible'), findsOneWidget);

      signals.setNotice(NoticeState.restricted);
      await tester.pump();
      expect(find.text('Action needed'), findsOneWidget);
      await _tap(tester, find.text('Review and appeal').first);
      expect(c.read(routerProvider).state.uri.path, Routes.accountBlocked);
      await settle(tester);
    },
  );

  testWidgets(
    'activity: stale and unavailable are said, numbers never invented',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      final signals = c.read(accountSignalsProvider.notifier);
      await goTo(c, tester, Routes.visibility);
      final likes = c
          .read(datingProvider.notifier)
          .likesReceivedWithin(VisibilityReport.window);
      expect(c.read(visibilityReportProvider).activity!.likes, likes);
      expect(find.text('Updated just now.'), findsOneWidget);
      signals.setInsights(InsightsState.stale);
      await tester.pump();
      expect(find.textContaining('Last updated 3 days ago'), findsOneWidget);
      signals.setInsights(InsightsState.unavailable);
      await tester.pump();
      expect(
        find.text('Activity counts aren’t available right now'),
        findsOneWidget,
      );
      expect(find.text('Likes received'), findsNothing);
      await settle(tester);
    },
  );

  testWidgets('How this works answers what it can’t determine', (tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.full);
    await goTo(c, tester, Routes.visibility);
    await _tap(tester, find.text('How this works'));
    expect(find.text('What this page can’t tell you'), findsOneWidget);
    expect(find.text('Demo sources'), findsOneWidget);
    await settle(tester);
  });

  testWidgets(
    'Demo Hub: events and visibility rows work; reset restores events',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, Routes.demo);
      await _tap(tester, find.text('Notices: hidden while reviewed'));
      expect(c.read(accountSignalsProvider).notice, NoticeState.restricted);
      await _tap(tester, find.text('Activity: unavailable'));
      expect(
        c.read(accountSignalsProvider).insights,
        InsightsState.unavailable,
      );
      await _tap(tester, find.text('Open a spot at board games'));
      await _tap(tester, find.text('Reset events'));
      expect(find.text('Events back to the sample data'), findsOneWidget);
      await _tap(tester, find.text('A full event with a waitlist'));
      expect(find.text('Board games and natural wine'), findsOneWidget);
      expect(find.text('7 going · Full'), findsOneWidget);
      await settle(tester);
    },
  );
}
