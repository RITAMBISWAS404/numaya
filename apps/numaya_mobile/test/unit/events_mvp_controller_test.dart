import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/events_mvp/application/events_mvp_controller.dart';
import 'package:numaya_mobile/features/events_mvp/domain/event_models.dart';

import '../helpers/test_app.dart';

/// Events MVP rules (PRD E03–E08, H03/H04) on the controller, with a movable clock. Reserving
/// needs a completed profile, so those flows are covered in test/widget/events_mvp_test.dart.
void main() {
  late ProviderContainer c;
  late DateTime now;

  EventsMvpController ev() => c.read(eventsMvpProvider.notifier);
  EvState st() => c.read(eventsMvpProvider);

  setUp(() {
    now = testNow;
    c = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => now),
        demoWorldProvider.overrideWith(() => FixedWorld(DemoWorld.full)),
      ],
    );
  });
  tearDown(() => c.dispose());

  group('Policy', () {
    test(
      'reconfirm deadline: earlier of +24 h and start − 2 h; none under 2 h',
      () {
        final t = DateTime(2026, 11, 1, 10);
        expect(
          EvPolicy.reconfirmDeadline(t, t.add(const Duration(days: 3))),
          t.add(const Duration(hours: 24)),
        );
        expect(
          EvPolicy.reconfirmDeadline(t, t.add(const Duration(hours: 10))),
          t.add(const Duration(hours: 8)),
        );
        expect(
          EvPolicy.reconfirmDeadline(t, t.add(const Duration(hours: 3))),
          isNull,
        );
      },
    );
  });

  group('Seeded states', () {
    test('full event, cancelled event, reconfirm-required reservation', () {
      expect(ev().isFull('ev-coffee-indiranagar'), isTrue);
      expect(ev().placesLeft('ev-board-games-bandra'), greaterThan(0));
      expect(
        ev().effectiveReservation('ev-pottery-hauz-khas')!.cancelReason,
        CancelReason.eventCancelled,
      );
      expect(
        ev().effectiveReservation('ev-sunrise-walk')!.status,
        ResStatus.reconfirmRequired,
      );
      expect(ev().attendanceOf('ev-trivia-night'), Attendance.noShow);
    });

    test('a fresh account has no reservations, notices or proposals', () {
      final fresh = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(() => now),
          demoWorldProvider.overrideWith(() => FixedWorld(DemoWorld.fresh)),
        ],
      );
      addTearDown(fresh.dispose);
      final s = fresh.read(eventsMvpProvider);
      expect(s.reservations, isEmpty);
      expect(s.notices, isEmpty);
      expect(s.proposals, isEmpty);
    });
  });

  group('Material change and reconfirmation (E06, H04)', () {
    test(
      'a newer change supersedes the older notice; only the latest confirms',
      () {
        final walk = st().events['ev-sunrise-walk']!;
        expect(
          ev().applyMaterialChange(
            'ev-sunrise-walk',
            newStart: walk.start.add(const Duration(days: 1)),
            venueName: 'Bandstand',
            reason: 'Moved for the tide',
          ),
          isTrue,
        );
        final old = st().notices.firstWhere((n) => n.id == 'n-walk-v2');
        expect(ev().isSuperseded(old), isTrue);
        expect(ev().reconfirm('n-walk-v2'), isFalse);
        expect(ev().decline('n-walk-v2'), isFalse);
        final latest = ev().noticesFor('ev-sunrise-walk').first;
        expect(ev().isSuperseded(latest), isFalse);
        expect(ev().reconfirm(latest.id), isTrue);
        final r = ev().effectiveReservation('ev-sunrise-walk')!;
        expect(r.status, ResStatus.confirmed);
        expect(r.acceptedVersion, st().events['ev-sunrise-walk']!.version);
      },
    );

    test('a change leaving under two hours to respond is refused', () {
      expect(
        ev().applyMaterialChange(
          'ev-board-games-bandra',
          newStart: now.add(const Duration(hours: 3)),
          venueName: 'Elsewhere',
          reason: 'Too late',
        ),
        isFalse,
      );
    });

    test('after the deadline the reservation reads as cancelled and cannot reconfirm', () {
      final n = st().notices.firstWhere((n) => n.id == 'n-walk-v2');
      now = n.deadline!.add(const Duration(minutes: 1));
      final r = ev().effectiveReservation('ev-sunrise-walk')!;
      expect(r.status, ResStatus.cancelled);
      expect(r.cancelReason, CancelReason.deadlinePassed);
      expect(ev().reconfirm('n-walk-v2'), isFalse);
      // Expiry is committed by an action, never while building.
      expect(
        st().reservations['ev-sunrise-walk']!.cancelReason,
        CancelReason.deadlinePassed,
      );
    });

    test('declining a current change cancels with its own reason', () {
      expect(ev().decline('n-walk-v2'), isTrue);
      expect(
        ev().effectiveReservation('ev-sunrise-walk')!.cancelReason,
        CancelReason.declinedChange,
      );
    });
  });

  group('Attendance versus reservation (H03)', () {
    test('only an active reservation can be checked in', () {
      expect(
        ev().setMemberAttendance('ev-board-games-bandra', Attendance.checkedIn),
        isFalse,
      );
      expect(
        ev().setMemberAttendance('ev-pottery-hauz-khas', Attendance.checkedIn),
        isFalse,
      );
      // A no-show keeps its reservation record; attendance is separate.
      expect(st().reservations['ev-trivia-night'], isNotNull);
      expect(ev().attendanceOf('ev-trivia-night'), Attendance.noShow);
    });

    test('People I met needs check-in, opt-in and the seven-day window', () {
      expect(ev().followUpOpen('ev-book-swap'), isTrue);
      expect(ev().followUpOpen('ev-trivia-night'), isFalse); // no-show
      expect(ev().followUpOpen('ev-comedy-chai'), isFalse); // window passed
      now = ev().followUpEnds('ev-book-swap')!;
      expect(ev().followUpOpen('ev-book-swap'), isFalse);
      expect(ev().sendInterest('ev-book-swap', 'sam'), InterestResult.closed);
    });
  });

  group('People I met (E07/E08)', () {
    test('only checked-in, opted-in people are listed', () {
      final ids = [for (final p in ev().peers('ev-book-swap')) p.id];
      expect(ids, containsAll(['sam', 'tomas', 'rafa']));
      expect(ids, isNot(contains('ade'))); // not opted in
      expect(ids, isNot(contains('maya'))); // not checked in
    });

    test('three interests per event; duplicates are free', () {
      expect(ev().sendInterest('ev-book-swap', 'tomas'), InterestResult.sent);
      expect(
        ev().sendInterest('ev-book-swap', 'tomas'),
        InterestResult.duplicate,
      );
      expect(ev().sendInterest('ev-book-swap', 'ben'), InterestResult.sent);
      expect(ev().sendInterest('ev-book-swap', 'kemi'), InterestResult.sent);
      expect(ev().interestsLeft('ev-book-swap'), 0);
      expect(
        ev().sendInterest('ev-book-swap', 'sam'),
        InterestResult.exhausted,
      );
    });

    test('mutual interest creates one match; an existing chat is reused', () {
      final dating = c.read(datingProvider.notifier);
      final before = c.read(datingProvider).matches.length;
      expect(ev().sendInterest('ev-book-swap', 'sam'), InterestResult.mutual);
      expect(
        ev().connectionWith('ev-book-swap', 'sam'),
        EventConnection.created,
      );
      expect(c.read(datingProvider).matches.length, before + 1);
      // Rafa's conversation is archived: it is not reopened and nothing is reset.
      final rafaMatchedAt = c.read(datingProvider).matchedAt['rafa'];
      expect(dating.isArchived('rafa'), isTrue);
      expect(ev().sendInterest('ev-book-swap', 'rafa'), InterestResult.mutual);
      expect(
        ev().connectionWith('ev-book-swap', 'rafa'),
        EventConnection.existingArchived,
      );
      expect(dating.isArchived('rafa'), isTrue);
      expect(c.read(datingProvider).matchedAt['rafa'], rafaMatchedAt);
      expect(
        c.read(datingProvider).matches.where((m) => m == 'rafa').length,
        1,
      );
    });

    test('block and unmatch always prevail', () {
      final dating = c.read(datingProvider.notifier)
        ..end('sam', EndReason.blocked);
      expect([
        for (final p in ev().peers('ev-book-swap')) p.id,
      ], isNot(contains('sam')));
      expect(
        ev().sendInterest('ev-book-swap', 'sam'),
        InterestResult.notEligible,
      );
      expect(dating.connectFromEvent('sam'), EventConnection.restricted);
    });

    test(
      'withdrawing consent removes one-sided interest, keeps established chats',
      () {
        ev()
          ..sendInterest('ev-book-swap', 'tomas')
          ..sendInterest('ev-book-swap', 'sam')
          ..setDiscoverable('ev-book-swap', false);
        expect(st().interests['ev-book-swap'], {'sam'});
        expect(ev().followUpOpen('ev-book-swap'), isFalse);
        expect(c.read(datingProvider).matches, contains('sam'));
      },
    );
  });

  group('Proposals and staff (M01/M02, H01–H04)', () {
    test('publishing needs a host and reviewer and is idempotent', () {
      expect(ev().publishProposal('p-chess', host: '', reviewer: 'R'), isNull);
      final id = ev().publishProposal('p-chess', host: 'H', reviewer: 'R');
      expect(id, isNotNull);
      expect(ev().publishProposal('p-chess', host: 'H', reviewer: 'R'), id);
      expect(st().events.keys.where((k) => k == id).length, 1);
      expect(st().audit.where((a) => a.startsWith('Published')).length, 1);
    });

    test('cancelling an event is idempotent and keeps history', () {
      expect(ev().cancelEvent('ev-cycle-ride', 'Weather'), isTrue);
      ev().cancelEvent('ev-cycle-ride', 'Weather');
      final r = ev().effectiveReservation('ev-cycle-ride')!;
      expect(r.status, ResStatus.cancelled);
      expect(r.cancelReason, CancelReason.eventCancelled);
      expect(
        st().notices.where(
          (n) =>
              n.eventId == 'ev-cycle-ride' && n.kind == NoticeKind.cancellation,
        ),
        hasLength(1),
      );
    });
  });
}
