@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Every screen of the full demo world at 393 x 852 @2x, into goldens/fNN-*.png, for
/// docs/mobile/FULL_APP_VISUAL_QA.md. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture full app', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp(world: DemoWorld.full));
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    GoRouter router() => container.read(routerProvider);

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/f$name.png'),
      );
    }

    Future<void> go(String path) async {
      router().go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> sheet() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> closeSheet() async {
      await tester.tap(find.bySemanticsLabel('Close').last);
      await tester.pump(const Duration(milliseconds: 600));
    }

    await go(Routes.demo);
    await shot('01-demo-hub-signed-out');
    await container.read(sessionProvider.notifier).quickStart();
    await go(Routes.home);
    await shot('02-home-full');
    await go(Routes.forYou);
    await shot('03-for-you');
    await go(Routes.home);
    await tapOn(tester, find.bySemanticsLabel('Filters'));
    await sheet();
    await shot('04-filters-basic');
    await tapOn(tester, find.bySemanticsLabel('Advanced'));
    await sheet();
    await shot('05-filters-advanced-locked');
    await closeSheet();
    await go(Routes.likes);
    await shot('06-likes-full');
    await go(Routes.messages);
    await shot('07-messages-full');
    await go('${Routes.chat}/priya');
    await shot('08-chat-history');
    await tapOn(tester, find.bySemanticsLabel('Conversation options'));
    await sheet();
    await shot('09-chat-menu');
    await tapOn(tester, find.text('Did you meet?'));
    await sheet();
    await shot('10-did-you-meet');
    await closeSheet();
    await go('${Routes.chat}/jo');
    await shot('11-chat-new-match');
    await go('${Routes.chat}/lina');
    await shot('12-chat-expiring');
    await go('${Routes.chat}/ollie');
    await shot('13-chat-expired');
    await go('${Routes.match}/amara');
    await shot('14-match-opening-move');
    await go(Routes.paywall);
    await shot('15-paywall');
    await tapOn(tester, find.bySemanticsLabel(RegExp('^1 month')));
    await shot('16-paywall-selected');
    await go(Routes.profile);
    await shot('17-profile');
    await go(Routes.completion);
    await shot('18-completion-hub');
    await go(Routes.editProfile);
    await shot('19-edit-profile');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1400),
    );
    await shot('20-edit-profile-more');
    await go(Routes.preview);
    await shot('21-preview');
    await go(Routes.openingMoves);
    await shot('22-opening-moves');
    await go(Routes.verifyPhoto);
    await shot('23-verify-intro');
    await tapOn(tester, find.text('Let’s get verified'));
    await shot('24-verify-capture');
    await tapOn(tester, find.text('Take demo selfie'));
    await tapOn(tester, find.text('Submit for review'));
    await shot('25-verify-pending');
    await tester.pump(const Duration(seconds: 3));
    await shot('26-verify-done');
    await go(Routes.premium);
    await shot('27-premium');
    await go(Routes.settings);
    await shot('28-settings');
    await tapOn(tester, find.bySemanticsLabel(RegExp('^Snooze')));
    await sheet();
    await shot('29-snooze-length');
    await closeSheet();
    await go(Routes.notifications);
    await shot('30-notifications');
    await tapOn(tester, find.text('New matches'));
    await shot('31-notification-category');
    await go(Routes.privacy);
    await shot('32-privacy');
    await go(Routes.deleteAccount);
    await shot('33-delete-account');
    await go(Routes.help);
    await shot('34-help');
    await go('${Routes.help}/verification');
    await shot('35-help-article');
    await go(Routes.helpContact);
    await shot('36-contact');
    await go(Routes.safety);
    await shot('37-safety');
    await go(Routes.demo);
    await shot('38-demo-hub');
    await go(Routes.accountBlocked);
    await shot('39-account-blocked');
    await go('/no-such-page');
    await shot('40-not-found');
    await go('${Routes.chat}/rafa');
    await tapOn(tester, find.bySemanticsLabel('Conversation options'));
    await sheet();
    await tapOn(tester, find.text('Report'));
    await sheet();
    await tapOn(tester, find.text('Inappropriate photos or text'));
    await shot('41-report-where');
    await closeSheet();
    await tester.pump(const Duration(seconds: 3));
  });
}
