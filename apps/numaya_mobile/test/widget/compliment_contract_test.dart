import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/features/commerce/application/economy_controller.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/compliments/domain/compliment.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// docs/product/mvp-focus-v5/COMPLIMENT_CONTRACT.md, through the existing demo repository layer.
void main() {
  setUpAll(loadAppFonts);

  const composer = '${Routes.compliment}/noor?kind=prompt&index=0';
  final send = find.byKey(const ValueKey('compliment-send'));

  int balance(ProviderContainer c) => c.read(creditBalanceProvider);
  int sentTo(ProviderContainer c, String id) => c
      .read(complimentsProvider)
      .where((x) => x.fromMe && x.personId == id)
      .length;

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).last, text);
    await tester.pump();
  }

  group('Length', () {
    test('counts what a member sees; emoji and accents count as one', () {
      expect(complimentLength('  héllo  '), 5);
      expect(complimentLength('👩‍🌾👍🏽'), 2);
      expect(complimentProblem('   \n ', 150), ComplimentProblem.empty);
      expect(complimentProblem('😀' * 150, 150), isNull);
      expect(complimentProblem('😀' * 151, 150), ComplimentProblem.tooLong);
    });
  });

  group('Sending', () {
    testWidgets('the credit is spent only after the send is accepted, once', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      // The service contract on the separate page (lab v8-compliment O); the UI-083 chat flow
      // has the same contract tests in v8_review_test.dart.
      c.read(labChoicesProvider.notifier).choose('v8-compliment', 'O');
      await goTo(c, tester, composer);
      await tester.pump(const Duration(milliseconds: 400));
      final before = balance(c);
      await type(tester, 'Croissants for dinner it is.');
      await tester.tap(send);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(balance(c), before, reason: 'no debit before the answer');
      await tester.tap(send, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 600));
      expect(balance(c), before - 1);
      expect(sentTo(c, 'noor'), 1);
      expect(find.text('Compliment sent'), findsOneWidget);
      expect(find.textContaining('If Noor replies'), findsOneWidget);
      expect(c.read(datingProvider).matches, isNot(contains('noor')));
      await settle(tester);
    });

    testWidgets('a failure keeps the words, spends nothing, and can retry', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      // The service contract on the separate page (lab v8-compliment O); the UI-083 chat flow
      // has the same contract tests in v8_review_test.dart.
      c.read(labChoicesProvider.notifier).choose('v8-compliment', 'O');
      await goTo(c, tester, composer);
      await tester.pump(const Duration(milliseconds: 400));
      final before = balance(c);
      await type(tester, 'Worth saying twice.');
      c.read(connectivityProvider.notifier).setOnline(false);
      await tester.pump();
      await tester.tap(send);
      await tester.pump(const Duration(milliseconds: 600));
      expect(balance(c), before);
      expect(sentTo(c, 'noor'), 0);
      expect(find.text('Worth saying twice.'), findsOneWidget);
      c.read(connectivityProvider.notifier).setOnline(true);
      await tester.pump();
      await tester.tap(send);
      await tester.pump(const Duration(milliseconds: 600));
      expect(balance(c), before - 1);
      expect(sentTo(c, 'noor'), 1);
      await settle(tester);
    });

    testWidgets('a second send to the same person is refused, not charged', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      // The service contract on the separate page (lab v8-compliment O); the UI-083 chat flow
      // has the same contract tests in v8_review_test.dart.
      c.read(labChoicesProvider.notifier).choose('v8-compliment', 'O');
      await tester.pump();
      final n = c.read(complimentsProvider.notifier);
      final first = n.send(
        personId: 'noor',
        target: const ComplimentTarget.prompt(0),
        text: 'One',
      );
      final second = n.send(
        personId: 'noor',
        target: const ComplimentTarget.prompt(0),
        text: 'Two',
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(await first, ComplimentSendResult.sent);
      expect(await second, ComplimentSendResult.notAllowed);
      expect(sentTo(c, 'noor'), 1);
      final left = balance(c);
      expect(
        await n.send(
          personId: 'noor',
          target: const ComplimentTarget.photo(0),
          text: 'Three',
        ),
        ComplimentSendResult.notAllowed,
      );
      expect(balance(c), left);
      await settle(tester);
    });

    testWidgets('no credits leads to the pack, with no debit', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      // The service contract on the separate page (lab v8-compliment O); the UI-083 chat flow
      // has the same contract tests in v8_review_test.dart.
      c.read(labChoicesProvider.notifier).choose('v8-compliment', 'O');
      await tester.pump();
      final economy = c.read(economyProvider.notifier);
      for (var i = 0; balance(c) > 0 && i < 20; i++) {
        economy.spendCredit(key: 'drain-$i', source: 'test');
      }
      await goTo(c, tester, composer);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Get Compliments'), findsWidgets);
      expect(send, findsNothing);
      await settle(tester);
    });

    testWidgets('closing with words asks first; keeping them changes nothing', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      // The service contract on the separate page (lab v8-compliment O); the UI-083 chat flow
      // has the same contract tests in v8_review_test.dart.
      c.read(labChoicesProvider.notifier).choose('v8-compliment', 'O');
      await goTo(c, tester, composer);
      await tester.pump(const Duration(milliseconds: 400));
      await type(tester, 'Half a thought');
      await tester.tap(find.bySemanticsLabel('Close').first);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Discard your Compliment?'), findsOneWidget);
      await tester.tap(find.text('Keep writing'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Half a thought'), findsOneWidget);
      await settle(tester);
    });
  });

  group('Receiving', () {
    testWidgets('a reply opens one chat; repeating cannot duplicate it', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await tester.pump();
      final n = c.read(complimentsProvider.notifier);
      final before = n.byId('seed-sam')!;
      expect(before.status, ComplimentStatus.pending);
      expect(n.reply('seed-sam', 'Thank you!'), isTrue);
      expect(n.byId('seed-sam')!.status, ComplimentStatus.replied);
      expect(c.read(datingProvider).matches, contains('sam'));
      expect(n.reply('seed-sam', 'Again'), isFalse);
      expect(n.requests().where((x) => x.personId == 'sam'), isEmpty);
      await settle(tester);
    });

    testWidgets('a dismissed or blocked request is gone from Compliments', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await tester.pump();
      final n = c.read(complimentsProvider.notifier);
      n.dismiss('seed-sam');
      n.hideFrom('chloe');
      expect(n.requests(), isEmpty);
      await goTo(c, tester, '${Routes.request}/seed-sam');
      expect(find.byType(TextField), findsNothing);
      await settle(tester);
    });
  });
}
