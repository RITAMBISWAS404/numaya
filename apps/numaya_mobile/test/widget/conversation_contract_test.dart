import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/compliments/domain/compliment.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// docs/v8-replacement/CONVERSATION_CONTRACT.md: a Compliment is the first event of one
/// conversation per person, reached from Messages, notifications and old links alike.
void main() {
  setUpAll(loadAppFonts);

  String path(ProviderContainer c) =>
      c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;
  final rows = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('conversation-'),
  );
  Finder row(String id) => find.byKey(ValueKey('conversation-$id'));

  testWidgets('Heart has no Compliments part; the old link opens Messages', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.likes}?tab=compliments');
    await settle(tester);
    expect(path(c), Routes.messages);
    await goTo(c, tester, Routes.likes);
    await settle(tester);
    expect(find.text('Compliments'), findsNothing);
  });

  testWidgets(
    'a received Compliment is one Messages row; its link opens the same thread every time',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.messages);
      await settle(tester);
      expect(row('sam'), findsOneWidget);
      final ids = [
        for (final e in tester.widgetList(rows))
          (e.key! as ValueKey<String>).value,
      ];
      expect(ids.toSet().length, ids.length, reason: 'one row per person');
      for (var i = 0; i < 2; i++) {
        await goTo(c, tester, '${Routes.request}/seed-sam');
        await settle(tester);
        expect(path(c), '${Routes.chat}/sam');
        expect(find.byKey(const ValueKey('compliment-bubble')), findsOneWidget);
        // Selections pass (fx-compliment-thread A): an incoming message quoting your photo, with
        // no separate sender photo above it.
        expect(
          find.byKey(const ValueKey('compliment-sender-photo')),
          findsNothing,
        );
        expect(find.text('Your photo'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('compliment-reply-composer')),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('a sent Compliment waits: the sender has nothing to write in', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    final before = c.read(creditBalanceProvider);
    await goTo(c, tester, '${Routes.chat}/finn');
    await settle(tester);
    expect(find.byKey(const ValueKey('compliment-bubble')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(c.read(creditBalanceProvider), before, reason: 'opening is free');
  });

  testWidgets(
    'replying once unlocks the chat with the Compliment first; a second reply does nothing',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      final balance = c.read(creditBalanceProvider);
      final n = c.read(complimentsProvider.notifier);
      expect(n.reply('seed-sam', 'The rooftop on Elm Street.'), isTrue);
      expect(n.reply('seed-sam', 'Again'), isFalse);
      expect(n.byId('seed-sam')!.status, ComplimentStatus.replied);
      final thread = c.read(datingProvider).threads['sam']!;
      expect(thread.first.mine, isFalse);
      expect(thread.where((m) => m.text == 'Again'), isEmpty);
      expect(
        c.read(creditBalanceProvider),
        balance,
        reason: 'replying is free',
      );
      await goTo(c, tester, Routes.messages);
      await settle(tester);
      expect(row('sam'), findsOneWidget);
      await goTo(c, tester, '${Routes.request}/seed-sam');
      await settle(tester);
      expect(path(c), '${Routes.chat}/sam', reason: 'old link, same thread');
      expect(
        find.byKey(const ValueKey('compliment-reply-composer')),
        findsNothing,
      );
    },
  );

  testWidgets('blocking removes the row, and the link no longer opens it', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    // The block sheet's own call: ends the pair and hides their Compliments.
    c.read(datingProvider.notifier).end('sam', EndReason.blocked);
    await goTo(c, tester, Routes.messages);
    await settle(tester);
    expect(row('sam'), findsNothing);
    await goTo(c, tester, '${Routes.request}/seed-sam');
    await settle(tester);
    expect(path(c), Routes.messages);
  });
}
