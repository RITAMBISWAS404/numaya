// MVP PRD screens (docs/product/mvp-prd-v1/TRACEABILITY.md): every new route lays out at 320, 360
// and 411 logical widths at 100% and 200% text, meets the tap-target and label guidelines, and the
// key flows work through the controllers.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/commerce/application/economy_controller.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Every route added for the PRD, with the S-IDs it carries.
const _routes = <String, String>{
  'S11 Discover with quota and anchors': Routes.home,
  'S14 Compliment composer': '${Routes.compliment}/noor?kind=prompt&index=0',
  'S17 Allowance used': Routes.allowance,
  'S18 Likes (free, locked)': Routes.likes,
  'S20 Chats with requests': Routes.messages,
  'S21 Request': '${Routes.request}/seed-sam',
  'S22 Expired conversation': '${Routes.chat}/ade',
  'S24 Expired chats': Routes.expiredChats,
  'S25 Reconnect request': '${Routes.reconnect}/ade',
  'S27 Profile hub': Routes.profile,
  'S29 Profile Health': Routes.health,
  'S30 Health explanation': Routes.healthAbout,
  'S31 Insights': Routes.insights,
  'S32 Streak': Routes.streak,
  'S33 Wallet': Routes.wallet,
  'S34 Paywall': Routes.paywall,
  'S34 Premium overview': Routes.premium,
  'S35 Compliment pack': Routes.storeCompliments,
  'S36 Recovery': Routes.storeRecovery,
  'S37 Outcome (pending)':
      '${Routes.storeOutcome}?kind=premiumMonthly&result=pending',
  'S43 Support requests': Routes.supportRequests,
  'S45 Legal': Routes.legal,
  'S45 Safety contacts': '${Routes.legal}/safety',
};

void main() {
  setUpAll(loadAppFonts);

  for (final size in const [Size(320, 568), Size(360, 800), Size(411, 891)]) {
    for (final scale in const [1.0, 2.0]) {
      testWidgets(
        'MVP routes lay out at ${size.width.toInt()}dp, ${(scale * 100).toInt()}% text',
        (tester) async {
          await usePhoneSize(tester, size: size);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final c = await quickStartApp(tester);
          c.read(onboardingProvider.notifier).loadSample();
          for (final MapEntry(key: name, value: path) in _routes.entries) {
            await goTo(c, tester, path);
            expect(tester.takeException(), isNull, reason: name);
          }
          await settle(tester);
        },
      );
    }
  }

  testWidgets('MVP routes meet tap-target and label guidelines', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final handle = tester.ensureSemantics();
    final c = await quickStartApp(tester);
    c.read(onboardingProvider.notifier).loadSample();
    for (final MapEntry(key: name, value: path) in _routes.entries) {
      await goTo(c, tester, path);
      await expectLater(
        tester,
        meetsGuideline(labeledTapTargetGuideline),
        reason: name,
      );
      await expectLater(
        tester,
        meetsGuideline(androidTapTargetGuideline),
        reason: name,
      );
    }
    await settle(tester);
    handle.dispose();
  });

  testWidgets('S11 → S14: a Compliment on a prompt spends one credit', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    final before = c.read(creditBalanceProvider);
    final first = c.read(datingProvider.notifier).queue().first;
    expect(find.byKey(const ValueKey('discover-quota')), findsOneWidget);
    expect(find.text('5 of 5 likes left today'), findsOneWidget);
    await tapOn(tester, find.byKey(const ValueKey('compliment-prompt-0')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Compliment ${first.name}'), findsOneWidget);
    final send = find.byKey(const ValueKey('compliment-send'));
    expect(tester.widget<NumayaButton>(send).onPressed, isNull);
    await tester.enterText(
      find.byKey(const ValueKey('compliment-field')),
      'That answer made my day.',
    );
    await tester.pump();
    await tapOn(tester, send);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(creditBalanceProvider), before - 1);
    expect(find.text('Compliment sent to ${first.name}'), findsOneWidget);
    // The profile left the deck.
    expect(
      c.read(datingProvider.notifier).queue().map((p) => p.id),
      isNot(contains(first.id)),
    );
    await settle(tester);
  });

  testWidgets('S20 → S21: replying to a request opens the chat', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await openTab(tester, 'Messages');
    expect(find.byKey(const ValueKey('chats-requests')), findsOneWidget);
    await tapOn(tester, find.byKey(const ValueKey('request-seed-sam')));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(
      find.byType(TextField),
      'Thank you! Goa, last March.',
    );
    await tester.pump();
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(datingProvider).threads['sam'], hasLength(2));
    expect(find.byKey(const ValueKey('chat-composer-bar')), findsOneWidget);
    await settle(tester);
  });

  testWidgets('S17: out of likes, a right swipe opens the allowance page', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    c.read(economyProvider.notifier).exhaustLikes();
    await tester.pump();
    expect(find.text('No likes left today'), findsOneWidget);
    await swipeDecide(tester, like: true);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('You’ve used today’s likes'), findsOneWidget);
    expect(find.byKey(const ValueKey('allowance-reset')), findsOneWidget);
    await settle(tester);
  });

  testWidgets('S25: accepting a reconnection reopens the chat', (tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.reconnect}/ade');
    await tapOn(tester, find.byKey(const ValueKey('reconnect-accept')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(datingProvider.notifier).isExpired('ade'), isFalse);
    expect(find.byKey(const ValueKey('chat-composer-bar')), findsOneWidget);
    await settle(tester);
  });

  testWidgets('S23: a quiet chat shows its check-in once', (tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/rafa');
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('It’s been quiet with Rafa'), findsOneWidget);
    await tapOn(tester, find.text('Not now'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(datingProvider.notifier).checkInDue('rafa'), isFalse);
    await settle(tester);
  });
}
