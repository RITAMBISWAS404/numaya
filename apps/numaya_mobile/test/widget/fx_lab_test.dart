import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/compliments/domain/compliment.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Fable design lab: the alternatives keep the product rules of the baseline
/// (docs/v8-replacement/CONVERSATION_CONTRACT.md). Targeted checks only; the broad pass is in
/// docs/design/fable-lab/QA_HANDOFF.md.
void main() {
  setUpAll(loadAppFonts);

  Finder row(String id) => find.byKey(ValueKey('conversation-$id'));
  final rows = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('conversation-'),
  );

  for (final option in ['A', 'B']) {
    testWidgets(
      'fx-messages $option: one row per person, and a Compliment row opens its thread',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        c.read(labChoicesProvider.notifier).choose('fx-messages', option);
        await goTo(c, tester, Routes.messages);
        await settle(tester);
        final ids = [
          for (final e in tester.widgetList(rows))
            (e.key! as ValueKey<String>).value,
        ];
        expect(ids.length, 5);
        expect(ids.toSet().length, ids.length);
        await tester.ensureVisible(row('sam'));
        await tester.pump();
        await tester.tap(row('sam'));
        await settle(tester);
        // The row pushes the chat route: the pending Compliment is its first event.
        expect(find.byKey(const ValueKey('compliment-bubble')), findsOneWidget);
      },
    );
  }

  testWidgets(
    'fx-compliment-thread A: reply from the compact card is free and opens the chat',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      c.read(labChoicesProvider.notifier).choose('fx-compliment-thread', 'A');
      final balance = c.read(creditBalanceProvider);
      await goTo(c, tester, '${Routes.chat}/chloe');
      await settle(tester);
      expect(find.byKey(const ValueKey('compliment-bubble')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('compliment-sender-photo')),
        findsNothing,
      );
      await tester.enterText(
        find.byType(TextField).last,
        'The metro is the best place.',
      );
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await settle(tester);
      expect(
        c.read(complimentsProvider.notifier).byId('seed-chloe')!.status,
        ComplimentStatus.replied,
      );
      expect(c.read(creditBalanceProvider), balance);
    },
  );

  testWidgets(
    'fx-compliment-thread B: nothing can be typed until Reply; Dismiss asks first',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      c.read(labChoicesProvider.notifier).choose('fx-compliment-thread', 'B');
      await goTo(c, tester, '${Routes.chat}/sam');
      await settle(tester);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.byKey(const ValueKey('compliment-dismiss')));
      await settle(tester);
      expect(find.byKey(const ValueKey('dismiss-confirm')), findsOneWidget);
      expect(
        c.read(complimentsProvider.notifier).byId('seed-sam')!.status,
        ComplimentStatus.pending,
        reason: 'not dismissed until confirmed',
      );
      await tester.binding.handlePopRoute();
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('compliment-reply')));
      await settle(tester);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'A rooftop on Elm Street.',
      );
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await settle(tester);
      expect(
        c.read(complimentsProvider.notifier).byId('seed-sam')!.status,
        ComplimentStatus.replied,
      );
    },
  );

  testWidgets(
    'a sent Compliment has no composer in any fx-compliment-thread option',
    (tester) async {
      for (final option in ['A', 'B']) {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        c
            .read(labChoicesProvider.notifier)
            .choose('fx-compliment-thread', option);
        await goTo(c, tester, '${Routes.chat}/finn');
        await settle(tester);
        expect(find.byType(TextField), findsNothing, reason: option);
        expect(find.byKey(const ValueKey('compliment-reply')), findsNothing);
      }
    },
  );
}
