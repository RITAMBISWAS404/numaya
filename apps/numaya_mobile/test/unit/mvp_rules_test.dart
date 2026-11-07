// Business rules from the MVP PRD (docs/product/mvp-prd-v1), tested with fixed UTC clocks so the
// India (IST, UTC+05:30) day and week boundaries are exercised whatever the machine's time zone.
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/time/ist.dart';
import 'package:numaya_mobile/features/commerce/domain/catalog.dart';
import 'package:numaya_mobile/features/commerce/domain/credit_ledger.dart';
import 'package:numaya_mobile/features/compliments/domain/compliment.dart';
import 'package:numaya_mobile/features/health/domain/profile_health.dart';
import 'package:numaya_mobile/features/likes/domain/allowances.dart';
import 'package:numaya_mobile/features/matches/domain/match_lifecycle.dart';
import 'package:numaya_mobile/features/streaks/domain/streak.dart';

void main() {
  const policy = AllowancePolicy();
  // Tuesday 3 November 2026, 12:00 IST.
  final noonIst = DateTime.utc(2026, 11, 3, 6, 30);

  group('IST calendar', () {
    test('the day changes at midnight IST, not UTC', () {
      final beforeMidnight = DateTime.utc(2026, 11, 3, 18, 29); // 23:59 IST
      final afterMidnight = DateTime.utc(2026, 11, 3, 18, 30); // 00:00 IST
      expect(istDay(afterMidnight), istDay(beforeMidnight) + 1);
      expect(nextIstMidnight(noonIst), afterMidnight);
    });

    test('the week starts on Monday 00:00 IST', () {
      // Monday 9 November 2026 00:00 IST = Sunday 8 November 18:30 UTC.
      expect(nextIstMonday(noonIst), DateTime.utc(2026, 11, 8, 18, 30));
      expect(
        istWeekStart(noonIst),
        istDay(DateTime.utc(2026, 11, 1, 18, 30)), // Monday 2 Nov IST
      );
    });
  });

  group('Catalog', () {
    test('provisional INR prices and Indian digit grouping', () {
      final c = kProvisionalCatalog;
      expect(formatInr(c.product(ProductKind.premiumWeekly).pricePaise), '₹99');
      expect(
        formatInr(c.product(ProductKind.premiumMonthly).pricePaise),
        '₹299',
      );
      expect(
        formatInr(c.product(ProductKind.premiumYearly).pricePaise),
        '₹1,999',
      );
      expect(
        formatInr(c.product(ProductKind.complimentPack).pricePaise),
        '₹79',
      );
      expect(
        formatInr(c.product(ProductKind.streakRecovery).pricePaise),
        '₹19',
      );
      expect(formatInr(12345600), '₹1,23,456');
      expect(c.provisional, isTrue);
      expect(c.billingLive, isFalse);
    });
  });

  group('Credit ledger', () {
    test('welcome credits are granted once and the earned bank caps at 5', () {
      var l = const CreditLedger();
      final first = l.grant(
        bucket: CreditBucket.earned,
        amount: 3,
        key: 'welcome',
        source: 'welcome',
        at: noonIst,
      );
      l = first.ledger;
      expect(l.earned, 3);
      final again = l.grant(
        bucket: CreditBucket.earned,
        amount: 3,
        key: 'welcome',
        source: 'welcome',
        at: noonIst,
      );
      expect(again.status, GrantStatus.duplicate);
      final capped = l.grant(
        bucket: CreditBucket.earned,
        amount: 3,
        key: 'streak:a',
        source: 'streak',
        at: noonIst,
      );
      expect(capped.status, GrantStatus.partiallyCapped);
      expect(capped.ledger.earned, 5);
      final skipped = capped.ledger.grant(
        bucket: CreditBucket.earned,
        amount: 1,
        key: 'streak:b',
        source: 'streak',
        at: noonIst,
      );
      expect(skipped.status, GrantStatus.skippedAtCap);
      expect(skipped.ledger.entries.length, capped.ledger.entries.length);
    });

    test('spending takes weekly, then earned, then purchased; never twice', () {
      var l = const CreditLedger();
      for (final (b, k) in [
        (CreditBucket.purchased, 'p'),
        (CreditBucket.earned, 'e'),
        (CreditBucket.weekly, 'w'),
      ]) {
        l = l
            .grant(bucket: b, amount: 1, key: k, source: k, at: noonIst)
            .ledger;
      }
      final a = l.spend(key: 's1', source: 'c1', at: noonIst);
      expect(a.bucket, CreditBucket.weekly);
      final dup = a.ledger.spend(key: 's1', source: 'c1', at: noonIst);
      expect(dup.status, SpendStatus.duplicate);
      expect(dup.ledger.total, 2);
      final b = dup.ledger.spend(key: 's2', source: 'c2', at: noonIst);
      expect(b.bucket, CreditBucket.earned);
      final c = b.ledger.spend(key: 's3', source: 'c3', at: noonIst);
      expect(c.bucket, CreditBucket.purchased);
      expect(
        c.ledger.spend(key: 's4', source: 'c4', at: noonIst).status,
        SpendStatus.insufficient,
      );
    });

    test(
      'a technical failure refunds once; weekly expiry touches weekly only',
      () {
        var l = const CreditLedger()
            .grant(
              bucket: CreditBucket.weekly,
              amount: 3,
              key: 'w',
              source: 'premium_week:0',
              at: noonIst,
            )
            .ledger
            .grant(
              bucket: CreditBucket.purchased,
              amount: 3,
              key: 'p',
              source: 'purchase:1',
              at: noonIst,
            )
            .ledger;
        l = l.spend(key: 's', source: 'compliment:x', at: noonIst).ledger;
        expect(l.weekly, 2);
        l = l.reverseSpend('s', at: noonIst).reverseSpend('s', at: noonIst);
        expect(l.weekly, 3);
        l = l.expireWeekly(key: 'x', at: noonIst);
        expect(l.weekly, 0);
        expect(l.purchased, 3);
        // Entries are only ever appended.
        expect(l.entries.map((e) => e.kind), [
          LedgerKind.grant,
          LedgerKind.grant,
          LedgerKind.spend,
          LedgerKind.reversal,
          LedgerKind.expiry,
        ]);
      },
    );

    test('a store refund removes what is left, never below zero', () {
      var l = const CreditLedger()
          .grant(
            bucket: CreditBucket.purchased,
            amount: 3,
            key: 'g',
            source: 'purchase:1',
            at: noonIst,
          )
          .ledger;
      l = l.spend(key: 'a', source: 'c', at: noonIst).ledger;
      l = l.spend(key: 'b', source: 'c', at: noonIst).ledger;
      l = l.refundPurchase('g', at: noonIst);
      expect(l.purchased, 0);
    });
  });

  group('Like allowance', () {
    test('free 5 a day, Premium 15; a repeat like never spends twice', () {
      var q = const LikeQuota();
      for (var i = 0; i < 5; i++) {
        q = q.spend('p$i', noonIst, policy, premium: false)!;
      }
      expect(q.remaining(noonIst, policy, premium: false), 0);
      expect(q.spend('p0', noonIst, policy, premium: false), same(q));
      expect(q.spend('p9', noonIst, policy, premium: false), isNull);
      expect(q.remaining(noonIst, policy, premium: true), 10);
    });

    test('the allowance resets at midnight IST', () {
      var q = const LikeQuota();
      for (var i = 0; i < 5; i++) {
        q = q.spend('p$i', noonIst, policy, premium: false)!;
      }
      final tomorrow = nextIstMidnight(noonIst);
      expect(q.remaining(tomorrow, policy, premium: false), 5);
      // People already liked stay liked: no second like to the same person.
      expect(q.alreadyLiked('p0'), isTrue);
    });
  });

  group('Extensions', () {
    test('free: one a week (Monday IST); Premium: one a day', () {
      final a = const ExtensionAllowance().use(noonIst);
      expect(a.available(noonIst, premium: false), isFalse);
      final sunday = DateTime.utc(2026, 11, 8, 12); // Sunday 17:30 IST
      expect(a.available(sunday, premium: false), isFalse);
      expect(a.available(nextIstMonday(noonIst), premium: false), isTrue);
      expect(a.available(noonIst, premium: true), isFalse);
      expect(a.available(nextIstMidnight(noonIst), premium: true), isTrue);
    });
  });

  group('Match lifecycle', () {
    MatchStatus at(MatchTimeline t, Duration after) =>
        matchStatus(t, noonIst.add(after), policy);

    test('a new match expires 24 hours later without a first message', () {
      final t = MatchTimeline(matchedAt: noonIst);
      expect(
        at(t, const Duration(hours: 23, minutes: 59)).phase,
        MatchPhase.awaitingFirstMessage,
      );
      final expired = at(t, const Duration(hours: 24));
      expect(expired.phase, MatchPhase.expired);
      expect(expired.expiryKind, ExpiryKind.noFirstMessage);
      expect(expired.canSend, isFalse);
    });

    test('the extension moves the deadline', () {
      final t = MatchTimeline(
        matchedAt: noonIst,
        extendedUntil: noonIst.add(const Duration(hours: 48)),
      );
      expect(
        at(t, const Duration(hours: 30)).phase,
        MatchPhase.awaitingFirstMessage,
      );
    });

    test(
      'a first message stops the timer; 7 quiet days check in, 14 expire',
      () {
        final first = noonIst.add(const Duration(hours: 2));
        final t = MatchTimeline(
          matchedAt: noonIst,
          firstMessageAt: first,
          lastMessageAt: first,
        );
        expect(at(t, const Duration(days: 3)).phase, MatchPhase.active);
        expect(at(t, const Duration(days: 3)).checkInDue, isFalse);
        final week = at(t, const Duration(days: 7, hours: 3));
        expect(week.phase, MatchPhase.active);
        expect(week.checkInDue, isTrue);
        final gone = at(t, const Duration(days: 14, hours: 3));
        expect(gone.phase, MatchPhase.expired);
        expect(gone.expiryKind, ExpiryKind.quiet);
      },
    );

    test('reconnection: one request per expiry episode; accept reopens', () {
      final t = MatchTimeline(matchedAt: noonIst);
      final s = at(t, const Duration(hours: 30));
      expect(canRequestReconnect(t, s), isTrue);
      final asked = MatchTimeline(
        matchedAt: noonIst,
        reconnect: ReconnectRequest(
          fromMe: true,
          at: noonIst.add(const Duration(hours: 30)),
          episode: s.expiredAt!,
        ),
      );
      final pending = at(asked, const Duration(hours: 31));
      expect(pending.phase, MatchPhase.reconnectPending);
      expect(canRequestReconnect(asked, pending), isFalse);
      final declined = MatchTimeline(
        matchedAt: noonIst,
        reconnect: asked.reconnect!.withStatus(ReconnectStatus.declined),
      );
      final afterDecline = at(declined, const Duration(hours: 32));
      expect(afterDecline.phase, MatchPhase.expired);
      expect(canRequestReconnect(declined, afterDecline), isFalse);
      final reopened = MatchTimeline(
        matchedAt: noonIst,
        reopenedAt: noonIst.add(const Duration(hours: 32)),
        reconnect: asked.reconnect!.withStatus(ReconnectStatus.accepted),
      );
      expect(at(reopened, const Duration(hours: 33)).phase, MatchPhase.active);
    });

    test('unmatch and block are terminal', () {
      final t = MatchTimeline(matchedAt: noonIst, ended: MatchPhase.blocked);
      expect(at(t, Duration.zero).phase, MatchPhase.blocked);
      expect(at(t, Duration.zero).canSend, isFalse);
    });
  });

  group('Streak', () {
    final day0 = noonIst;
    DateTime day(int n) => day0.add(Duration(days: n));

    test('3 distinct decisions or 1 message make a day', () {
      var s = const StreakState();
      s = s.recordDecision(day0, 'a').recordDecision(day0, 'a');
      s = s.recordDecision(day0, 'b');
      expect(s.qualifies(istDay(day0)), isFalse);
      s = s.recordDecision(day0, 'c');
      expect(s.qualifies(istDay(day0)), isTrue);
      s = s.recordMessage(day(1));
      expect(s.run(day(1)).length, 2);
    });

    test('seven days in a row complete one cycle, awarded once', () {
      var s = const StreakState();
      for (var i = 0; i < 7; i++) {
        s = s.recordMessage(day(i));
      }
      final pending = s.pendingAwards(day(6));
      expect(pending, hasLength(1));
      s = s.copyWith(awards: {pending.single: AwardResult.granted});
      expect(s.pendingAwards(day(6)), isEmpty);
      expect(s.run(day(6)).progress(7), 7);
      expect(s.run(day(7)).length, 7); // today still open
    });

    test('recovery repairs one missed day within 48 hours', () {
      var s = const StreakState();
      for (final i in [0, 1, 2, 4]) {
        s = s.recordMessage(day(i));
      }
      // Day 3 was missed; on day 4 the offer is open and joins 0-2 with 4.
      final offer = s.recoveryOffer(day(4));
      expect(offer, isNotNull);
      expect(offer!.missedDay, istDay(day(3)));
      expect(offer.resultingLength, 5);
      // 48 hours after day 3 ended (start of day 6 IST) it closes (day 5 may then be offered).
      expect(
        s.recoveryOffer(istDayStart(istDay(day(3)) + 3))?.missedDay,
        isNot(istDay(day(3))),
      );
      final repaired = s.repair(offer.missedDay, day(4))!;
      expect(repaired.run(day(4)).length, 5);
      // Once in any seven days: no second offer for a nearby miss.
      final again = repaired.recordMessage(day(6));
      expect(again.recoveryOffer(day(6)), isNull);
    });

    test('no recovery when the day before was not a streak day', () {
      var s = const StreakState();
      s = s.recordMessage(day(2));
      expect(s.recoveryOffer(day(2)), isNull);
    });

    test('a repaired run never pays a cycle twice', () {
      var s = const StreakState();
      for (final i in [0, 1, 2, 3, 4, 5, 6]) {
        s = s.recordMessage(day(i));
      }
      final cycle = s.pendingAwards(day(6)).single;
      s = s.copyWith(awards: {cycle: AwardResult.granted});
      // Miss day 7, keep day 8, repair day 7: the run still starts on day 0.
      s = s.recordMessage(day(8));
      final offer = s.recoveryOffer(day(8));
      expect(offer, isNotNull);
      s = s.repair(offer!.missedDay, day(8))!;
      expect(s.pendingAwards(day(8)), isEmpty);
    });
  });

  group('Compliments', () {
    test('1-150 characters', () {
      expect(complimentProblem('  ', 150), ComplimentProblem.empty);
      expect(complimentProblem('a' * 151, 150), ComplimentProblem.tooLong);
      expect(complimentProblem('a' * 150, 150), isNull);
    });

    test('one introduction per pair, whichever way it went', () {
      final sent = Compliment(
        id: '1',
        personId: 'maya',
        fromMe: true,
        target: const ComplimentTarget.photo(0),
        text: 'Hi',
        sentAt: noonIst,
      );
      expect(
        complimentBlock([sent], 'maya', connected: false, available: true),
        ComplimentBlock.alreadySent,
      );
      final got = Compliment(
        id: '2',
        personId: 'sam',
        fromMe: false,
        target: const ComplimentTarget.prompt(0),
        text: 'Hi',
        sentAt: noonIst,
        status: ComplimentStatus.dismissed,
      );
      expect(
        complimentBlock([got], 'sam', connected: false, available: true),
        ComplimentBlock.alreadyReceived,
      );
      expect(
        complimentBlock([], 'noor', connected: true, available: true),
        ComplimentBlock.connected,
      );
      expect(
        complimentBlock([], 'noor', connected: false, available: false),
        ComplimentBlock.unavailable,
      );
    });
  });

  group('Profile Health v1', () {
    test('required setup is 80; every factor is 100', () {
      const required = HealthInput(
        basicsComplete: true,
        approvedPhotos: 2,
        hasBio: true,
        prompts: 1,
      );
      expect(ProfileHealth.of(required).score, 80);
      expect(ProfileHealth.of(required).requiredComplete, isTrue);
      const full = HealthInput(
        basicsComplete: true,
        approvedPhotos: 3,
        hasBio: true,
        prompts: 2,
      );
      expect(ProfileHealth.of(full).score, 100);
      const partial = HealthInput(
        basicsComplete: true,
        approvedPhotos: 1,
        hasBio: false,
        prompts: 1,
      );
      expect(ProfileHealth.of(partial).score, 45);
      expect(ProfileHealth.of(partial).requiredComplete, isFalse);
    });

    test('a missing service is unknown, never restricted', () {
      expect(
        discoveryStatus(
          serviceAvailable: null,
          restricted: false,
          paused: false,
          requiredComplete: true,
          photosPendingReview: false,
        ),
        DiscoveryStatus.unknown,
      );
      expect(
        discoveryStatus(
          serviceAvailable: true,
          restricted: false,
          paused: true,
          requiredComplete: true,
          photosPendingReview: false,
        ),
        DiscoveryStatus.paused,
      );
    });

    test('rates under 20 exposures are labelled low sample', () {
      const low = RateReading(exposures: 18, likes: 5, threshold: 20);
      expect(low.lowSample, isTrue);
      expect(low.percent, isNull);
      const ok = RateReading(exposures: 40, likes: 10, threshold: 20);
      expect(ok.percent, 25);
    });
  });
}
