import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/events/application/events_controller.dart';
import 'package:numaya_mobile/features/events/data/events_repository.dart';
import 'package:numaya_mobile/features/events/domain/event.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';

import '../helpers/test_app.dart';

void main() {
  late ProviderContainer c;
  var failing = false;
  EventsController events() => c.read(eventsProvider.notifier);
  DemoEvent byId(String id) => c.read(eventsProvider).byId(id)!;
  List<String> ids(List<DemoEvent> l) => [for (final e in l) e.id];

  ProviderContainer make({DemoWorld world = DemoWorld.fresh}) =>
      ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(() => testNow),
          demoWorldProvider.overrideWith(() => FixedWorld(world)),
          eventsRepositoryProvider.overrideWith(
            (ref) => DemoEventsRepository(
              failing: () => failing,
              fullWorld: world == DemoWorld.full,
              latency: Duration.zero,
            ),
          ),
        ],
      );

  setUp(() {
    failing = false;
    c = make();
  });
  tearDown(() => c.dispose());

  group('Explore', () {
    test('lists others’ upcoming and live events; cancelled last; no past', () {
      final list = ids(events().explore());
      expect(list, isNot(contains('e-roast'))); // past
      expect(list.last, 'e-poetry'); // cancelled, kept and marked
      expect(list, containsAll(['e-runclub', 'e-swim', 'e-jazz', 'e-books']));
    });

    test('search matches title, venue, description and host name', () {
      expect(ids(events().explore(query: 'jazz')), ['e-jazz']);
      expect(ids(events().explore(query: 'castle')), ['e-climb']);
      expect(ids(events().explore(query: 'priya')), ['e-market']);
      expect(events().explore(query: 'karaoke'), isEmpty);
    });

    test('filters: category, free only, online, date, distance', () {
      expect(
        ids(
          events().explore(
            filters: const EventFilters(categories: {EventCategory.music}),
          ),
        ),
        ['e-jazz'],
      );
      final free = events().explore(
        filters: const EventFilters(freeOnly: true),
      );
      expect(free.every((e) => e.free), isTrue);
      expect(ids(free), isNot(contains('e-jazz')));
      expect(
        ids(
          events().explore(
            filters: const EventFilters(format: EventFormatFilter.online),
          ),
        ),
        ['e-books'],
      );
      // testNow is Tuesday 27 October: the weekend is Saturday 31 and Sunday 1.
      expect(
        ids(
          events().explore(
            filters: const EventFilters(
              date: EventDateFilter.weekend,
              sort: EventSort.date,
            ),
          ),
        ),
        ['e-board', 'e-film'],
      );
      expect(
        ids(
          events().explore(
            filters: const EventFilters(
              date: EventDateFilter.today,
              sort: EventSort.date,
            ),
          ),
        ),
        ['e-runclub', 'e-swim'],
      );
      // Distance needs an area; without one nothing in person fits.
      final near = const EventFilters(maxKm: 2, sort: EventSort.date);
      expect(ids(events().explore(filters: near)), ['e-books']);
      c.read(profileDetailsProvider.notifier).setArea('Hackney, London');
      expect(ids(events().explore(filters: near)), [
        'e-runclub',
        'e-jazz',
        'e-books',
        'e-market',
        'e-board',
        'e-poetry',
      ]);
      expect(byId('e-wine').distanceFrom('Hackney, London'), 6.0);
      expect(byId('e-wine').distanceFrom('Manchester'), isNull);
    });

    test('filter count ignores sort', () {
      expect(const EventFilters(sort: EventSort.date).activeCount, 0);
      expect(const EventFilters(freeOnly: true, maxKm: 5).activeCount, 2);
    });

    test('blocking a host hides their events', () {
      c.read(datingProvider.notifier).end('tomas', EndReason.blocked);
      expect(ids(events().explore()), isNot(contains('e-jazz')));
    });
  });

  group('Participation', () {
    test('join an open event: going, counted, in My events', () async {
      final before = byId('e-jazz').goingCount;
      expect(await events().join('e-jazz'), JoinResult.going);
      expect(byId('e-jazz').participation, Participation.going);
      expect(byId('e-jazz').goingCount, before + 1);
      expect(ids(events().going()), contains('e-jazz'));
    });

    test('a full event takes a waitlist with a position', () async {
      expect(byId('e-board').full, isTrue);
      expect(await events().join('e-board'), JoinResult.waitlisted);
      expect(byId('e-board').waitlistPosition, 3);
      expect(ids(events().waitlisted()), ['e-board']);
      // Two spots open: the two ahead go first, then the member.
      expect(events().openSpot('e-board'), isFalse);
      expect(byId('e-board').waitlistPosition, 2);
      events().openSpot('e-board');
      expect(events().openSpot('e-board'), isTrue);
      expect(byId('e-board').participation, Participation.going);
      expect(events().waitlisted(), isEmpty);
    });

    test('leaving gives the place to the first person waiting', () async {
      await events().join('e-jazz'); // 7 of 8
      await events().join('e-board'); // waitlisted
      expect(await events().leave('e-board'), isTrue);
      expect(byId('e-board').waitlist, ['ben', 'chloe']);
      expect(await events().leave('e-jazz'), isTrue);
      expect(byId('e-jazz').participation, Participation.none);
    });

    test('registration closes two hours before; live and cancelled can’t be joined', () async {
      expect(byId('e-swim').registrationOpenAt(testNow), isFalse);
      expect(await events().join('e-swim'), JoinResult.closed);
      expect(await events().join('e-runclub'), JoinResult.closed);
      expect(await events().join('e-poetry'), JoinResult.closed);
    });

    test('a failed join changes nothing', () async {
      failing = true;
      expect(await events().join('e-jazz'), JoinResult.failed);
      expect(byId('e-jazz').participation, Participation.none);
      expect(c.read(eventsProvider).pending, isEmpty);
    });

    test('answers to a host’s question are kept with the join', () async {
      await events().join('e-climb', answer: '  Never, no injuries ');
      expect(c.read(eventsProvider).answers['e-climb'], 'Never, no injuries');
    });

    test('saved, past and going lists', () {
      expect(ids(events().savedEvents()), ['e-film']);
      events().toggleSave('e-jazz');
      events().toggleSave('e-film');
      expect(ids(events().savedEvents()), ['e-jazz']);
      expect(ids(events().past()), ['e-roast']);
      expect(ids(events().going()), ['e-wine']); // seeded, with a change note
      expect(byId('e-wine').changeNote, isNotNull);
    });

    test('picks follow the member’s interests, with the reason', () {
      // No interests yet: nothing picked.
      expect(events().picks(), isEmpty);
    });
  });

  group('Hosting', () {
    final valid = EventDraft(
      title: 'Coffee and sketching',
      category: EventCategory.arts,
      description: 'Pencils, a big table and a slow Sunday morning.',
      day: DateTime(2026, 11, 8),
      startMinutes: 10 * 60,
      venue: 'Pophams, London Fields',
      area: 'Hackney, London',
      capacity: 6,
    );

    test('validation lists every problem', () {
      expect(
        EventRules.problems(const EventDraft(), now: testNow),
        containsAll([
          EventProblem.titleMissing,
          EventProblem.categoryMissing,
          EventProblem.descriptionMissing,
          EventProblem.dateMissing,
          EventProblem.venueMissing,
        ]),
      );
      expect(
        EventRules.problems(
          valid.copyWith(day: DateTime(2026, 10, 1)),
          now: testNow,
        ),
        [EventProblem.dateInPast],
      );
      expect(
        EventRules.problems(
          valid.copyWith(format: EventFormat.online),
          now: testNow,
        ),
        [EventProblem.onlineNoteMissing],
      );
      expect(
        EventRules.problems(
          valid.copyWith(capacity: 3),
          now: testNow,
          going: 4,
        ),
        [EventProblem.capacityBelowGoing],
      );
      expect(EventRules.problems(valid, now: testNow), isEmpty);
    });

    test('draft → edit → publish → in Hosting, not in Explore', () async {
      final id = await events().saveDraft(const EventDraft(title: 'Sketch'));
      expect(id, isNotNull);
      expect(byId(id!).status, EventStatus.draft);
      expect(ids(events().hosting()), [id]);
      expect(
        await events().publish(const EventDraft(title: 'x'), id: id),
        isNull,
      );
      expect(await events().publish(valid, id: id), id);
      expect(byId(id).status, EventStatus.published);
      expect(byId(id).title, 'Coffee and sketching');
      expect(ids(events().explore()), isNot(contains(id)));
    });

    test('changing the time of a published event tells attendees', () async {
      final id = (await events().publish(valid))!;
      expect(byId(id).changeNote, isNull);
      await events().publish(valid.copyWith(startMinutes: 11 * 60), id: id);
      expect(byId(id).changeNote, kHostUpdatedNote);
    });

    test('cancel keeps the event with its note', () async {
      final id = (await events().publish(valid))!;
      expect(await events().cancel(id, note: 'Ill, sorry'), isTrue);
      expect(byId(id).status, EventStatus.cancelled);
      expect(byId(id).cancelNote, 'Ill, sorry');
      expect(ids(events().hosting()), [id]);
    });

    test('drafts can be deleted; published events can’t', () async {
      final id = (await events().saveDraft(const EventDraft(title: 'Tmp')))!;
      events().deleteDraft(id);
      expect(c.read(eventsProvider).byId(id), isNull);
    });
  });

  group('Hosting in the full world', () {
    setUp(() {
      c.dispose();
      c = make(world: DemoWorld.full);
    });

    test(
      'removing someone promotes the waitlist; move to going needs room',
      () {
        final e = byId('e-mine');
        expect(e.full, isTrue);
        expect(events().moveToGoing('e-mine', 'jo'), isFalse);
        events().removeAttendee('e-mine', 'ollie');
        expect(byId('e-mine').attendees, contains('jo'));
        expect(byId('e-mine').waitlist, isEmpty);
      },
    );

    test('reset restores the sample dataset', () async {
      await events().join('e-jazz');
      events().reset();
      expect(byId('e-jazz').participation, Participation.none);
      expect(byId('e-mine').attendees, hasLength(4));
    });
  });
}
