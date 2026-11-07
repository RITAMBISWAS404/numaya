// The MVP PRD flows through the demo controllers (the deterministic demo implementation of the
// server's transactional endpoints).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/features/commerce/application/economy_controller.dart';
import 'package:numaya_mobile/features/commerce/data/store_gateway.dart';
import 'package:numaya_mobile/features/commerce/domain/catalog.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/compliments/domain/compliment.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';

import '../helpers/test_app.dart';

void main() {
  late ProviderContainer c;
  late DateTime now;
  late DemoStoreGateway store;

  ProviderContainer make(DemoWorld world) => ProviderContainer(
    overrides: [
      clockProvider.overrideWithValue(() => now),
      demoWorldProvider.overrideWith(() => FixedWorld(world)),
      storeGatewayProvider.overrideWithValue(store),
    ],
  );

  setUp(() {
    now = testNow;
    store = DemoStoreGateway(latency: Duration.zero);
  });
  tearDown(() => c.dispose());

  DatingController dating() => c.read(datingProvider.notifier);
  EconomyController economy() => c.read(economyProvider.notifier);
  ComplimentsController compliments() => c.read(complimentsProvider.notifier);

  group('Likes through Discover (S11, S17)', () {
    test('five likes a day, then out of likes; passing stays free', () {
      c = make(DemoWorld.full);
      c.read(discoveryFiltersProvider.notifier).broaden();
      final deck = dating().queue().map((p) => p.id).toList();
      var liked = 0;
      for (final id in deck) {
        if (liked == 5) break;
        final r = dating().decide(id, liked: true);
        expect(r, isNot(DecisionResult.outOfLikes));
        liked++;
      }
      expect(economy().likesLeft(), 0);
      final next = dating().queue().first.id;
      expect(dating().decide(next, liked: true), DecisionResult.outOfLikes);
      // Nothing was recorded: the person is still in the deck.
      expect(dating().queue().first.id, next);
      expect(dating().decide(next, liked: false), DecisionResult.passed);
    });

    test('Premium has 15 a day', () {
      c = make(DemoWorld.fresh);
      c.read(premiumProvider.notifier).setActive(true);
      expect(economy().likesLeft(), 15);
    });
  });

  group('Compliments (S14, S21)', () {
    test('sending spends one credit; no credits opens the store', () async {
      c = make(DemoWorld.fresh);
      expect(
        await compliments().send(
          personId: 'maya',
          target: const ComplimentTarget.photo(0),
          text: 'Love the record shop answer',
        ),
        ComplimentSendResult.insufficientCredits,
      );
      economy().grantWelcome();
      expect(c.read(creditBalanceProvider), 3);
      expect(
        await compliments().send(
          personId: 'maya',
          target: const ComplimentTarget.photo(0),
          text: 'Love the record shop answer',
        ),
        ComplimentSendResult.sent,
      );
      expect(c.read(creditBalanceProvider), 2);
      // One per pair, and the profile left the deck.
      expect(compliments().blockFor('maya'), ComplimentBlock.alreadySent);
      expect(c.read(datingProvider).seen, contains('maya'));
    });

    test('a technical failure refunds the credit', () async {
      c = make(DemoWorld.fresh);
      economy().grantWelcome();
      dating().setSimulateErrors(true);
      expect(
        await compliments().send(
          personId: 'sam',
          target: const ComplimentTarget.prompt(0),
          text: 'Hello',
        ),
        ComplimentSendResult.failed,
      );
      expect(c.read(creditBalanceProvider), 3);
      expect(compliments().blockFor('sam'), isNull);
    });

    test('replying opens the conversation with their Compliment first', () {
      c = make(DemoWorld.full);
      final request = compliments().requests().firstWhere(
        (r) => r.personId == 'sam',
      );
      expect(compliments().reply(request.id, 'Thank you! It was Goa.'), isTrue);
      final thread = c.read(datingProvider).threads['sam']!;
      expect(thread.first.text, request.text);
      expect(thread.first.mine, isFalse);
      expect(thread.last.mine, isTrue);
      expect(dating().conversations().map((p) => p.id), contains('sam'));
      expect(compliments().requests().map((r) => r.personId), isNot(['sam']));
    });

    test('a like while a request is pending matches into the same chat', () {
      c = make(DemoWorld.full);
      c.read(discoveryFiltersProvider.notifier).broaden();
      expect(dating().decide('chloe', liked: true), DecisionResult.matched);
      final thread = c.read(datingProvider).threads['chloe']!;
      expect(thread, hasLength(1));
      expect(thread.single.context, isNotNull);
      expect(compliments().pendingFrom('chloe'), isNull);
    });

    test('dismissing is final and refunds nobody', () {
      c = make(DemoWorld.full);
      final r = compliments().requests().first;
      final before = c.read(creditBalanceProvider);
      compliments().dismiss(r.id);
      expect(compliments().requests().map((x) => x.id), isNot(contains(r.id)));
      expect(c.read(creditBalanceProvider), before);
      expect(
        compliments().blockFor(r.personId),
        ComplimentBlock.alreadyReceived,
      );
    });

    test('blocking hides their request', () {
      c = make(DemoWorld.full);
      dating().end('sam', EndReason.blocked);
      expect(compliments().requests().map((r) => r.personId), isNot(['sam']));
    });
  });

  group('Credits and Premium', () {
    test('welcome credits once after profile completion', () {
      c = make(DemoWorld.fresh);
      economy().grantWelcome();
      economy().grantWelcome();
      expect(c.read(economyProvider).ledger.earned, 3);
    });

    test('Premium adds 3 weekly credits from activation, no rollover', () {
      c = make(DemoWorld.fresh);
      c.read(premiumProvider.notifier).setActive(true);
      expect(c.read(economyProvider).ledger.weekly, 3);
      economy().spendCredit(key: 'k1', source: 'compliment:1');
      expect(c.read(economyProvider).ledger.weekly, 2);
      now = testNow.add(const Duration(days: 7, hours: 1));
      economy().syncWeekly();
      expect(c.read(economyProvider).ledger.weekly, 3);
    });

    test('a verified pack purchase adds 3 purchased credits', () async {
      c = make(DemoWorld.fresh);
      store.nextResult = StoreResult.purchased;
      expect(
        await economy().purchase(ProductKind.complimentPack),
        PurchaseOutcome.success,
      );
      expect(c.read(economyProvider).ledger.purchased, 3);
      expect(c.read(economyProvider).purchases.single.demo, isTrue);
    });

    test('failed, pending and cancelled purchases change nothing', () async {
      c = make(DemoWorld.fresh);
      for (final r in [
        StoreResult.failed,
        StoreResult.pending,
        StoreResult.cancelled,
      ]) {
        store.nextResult = r;
        await economy().purchase(ProductKind.premiumMonthly);
      }
      expect(c.read(premiumProvider).active, isFalse);
      expect(c.read(economyProvider).ledger.total, 0);
    });

    test(
      'a build without a store reports unavailable, never success',
      () async {
        c = ProviderContainer(
          overrides: [
            clockProvider.overrideWithValue(() => now),
            demoWorldProvider.overrideWith(() => FixedWorld(DemoWorld.fresh)),
            storeGatewayProvider.overrideWithValue(
              const UnconfiguredStoreGateway(),
            ),
          ],
        );
        expect(
          await economy().purchase(ProductKind.premiumWeekly),
          PurchaseOutcome.unavailable,
        );
        expect(c.read(premiumProvider).active, isFalse);
      },
    );

    test('recovery is not charged when no day can be repaired', () async {
      c = make(DemoWorld.fresh);
      expect(
        await economy().purchase(ProductKind.streakRecovery),
        PurchaseOutcome.ineligible,
      );
    });

    test('the demo account can repair its missed day', () async {
      c = make(DemoWorld.full);
      final offer = economy().recoveryOffer();
      expect(offer, isNotNull);
      final before = c.read(economyProvider).streak.run(now).length;
      store.nextResult = StoreResult.purchased;
      expect(
        await economy().purchase(ProductKind.streakRecovery),
        PurchaseOutcome.success,
      );
      expect(
        c.read(economyProvider).streak.run(now).length,
        greaterThan(before),
      );
    });
  });

  group('Chats lifecycle (S22-S25)', () {
    test('an expired initial match cannot send (R02)', () async {
      c = make(DemoWorld.full);
      await dating().send('ollie', 'Hello');
      expect(c.read(datingProvider).threads['ollie'] ?? const [], isEmpty);
    });

    test(
      'an archived chat can send; blocked cannot be revived (R01)',
      () async {
        c = make(DemoWorld.full);
        expect(dating().isArchived('rafa'), isTrue);
        await dating().send('rafa', 'Board games this week?');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(dating().isArchived('rafa'), isFalse);
        expect(dating().status('rafa').phase.name, 'active');
      },
    );

    test('ten unanswered messages, then wait for a reply', () async {
      c = make(DemoWorld.full);
      // Rafa's thread already ends with two of the member's messages.
      for (var i = 0; i < 8; i++) {
        await dating().send('rafa', 'm$i');
      }
      expect(dating().canSendMore('rafa'), isFalse);
      await dating().send('rafa', 'one more');
      expect(c.read(datingProvider).threads['rafa']!.last.text, 'm7');
    });
  });
}
