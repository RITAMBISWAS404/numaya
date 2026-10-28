import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/connectivity/connectivity.dart';
import '../../../core/logging/app_logger.dart';
import '../../dating/application/dating_controller.dart';
import '../../dating/domain/sample_people.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../data/events_repository.dart';
import '../domain/event.dart';
import '../domain/sample_events.dart';

enum EventDateFilter { any, today, weekend, week }

enum EventFormatFilter { any, inPerson, online }

enum EventSort { relevance, date }

/// Explore filters (Eventbrite's filter sheet [O]: categories, free only, online, sort; Meetup's
/// date chips [O]).
@immutable
class EventFilters {
  const EventFilters({
    this.categories = const {},
    this.date = EventDateFilter.any,
    this.freeOnly = false,
    this.format = EventFormatFilter.any,
    this.maxKm,
    this.sort = EventSort.relevance,
  });

  final Set<EventCategory> categories;
  final EventDateFilter date;
  final bool freeOnly;
  final EventFormatFilter format;

  /// Null: any distance. Needs an area (the member's own choice; no device location).
  final int? maxKm;
  final EventSort sort;

  /// Filters changed from the defaults (the button's count badge); sort isn't a filter.
  int get activeCount =>
      (categories.isEmpty ? 0 : 1) +
      (date == EventDateFilter.any ? 0 : 1) +
      (freeOnly ? 1 : 0) +
      (format == EventFormatFilter.any ? 0 : 1) +
      (maxKm == null ? 0 : 1);

  EventFilters copyWith({
    Set<EventCategory>? categories,
    EventDateFilter? date,
    bool? freeOnly,
    EventFormatFilter? format,
    int? maxKm,
    bool clearMaxKm = false,
    EventSort? sort,
  }) => EventFilters(
    categories: categories ?? this.categories,
    date: date ?? this.date,
    freeOnly: freeOnly ?? this.freeOnly,
    format: format ?? this.format,
    maxKm: clearMaxKm ? null : (maxKm ?? this.maxKm),
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is EventFilters &&
      setEquals(other.categories, categories) &&
      other.date == date &&
      other.freeOnly == freeOnly &&
      other.format == format &&
      other.maxKm == maxKm &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(categories),
    date,
    freeOnly,
    format,
    maxKm,
    sort,
  );
}

@immutable
class EventsState {
  const EventsState({
    required this.events,
    this.saved = const {},
    this.answers = const {},
    this.reports = const [],
    this.pending = const {},
    this.filters = const EventFilters(),
    this.query = '',
    this.nextId = 1,
  });

  final List<DemoEvent> events;
  final Set<String> saved;

  /// Answers to hosts' questions, kept on this device.
  final Map<String, String> answers;
  final List<EventReport> reports;

  /// Events with a change on its way to the (simulated) service.
  final Set<String> pending;
  final EventFilters filters;
  final String query;
  final int nextId;

  DemoEvent? byId(String id) {
    for (final e in events) {
      if (e.id == id) return e;
    }
    return null;
  }

  EventsState copyWith({
    List<DemoEvent>? events,
    Set<String>? saved,
    Map<String, String>? answers,
    List<EventReport>? reports,
    Set<String>? pending,
    EventFilters? filters,
    String? query,
    int? nextId,
  }) => EventsState(
    events: events ?? this.events,
    saved: saved ?? this.saved,
    answers: answers ?? this.answers,
    reports: reports ?? this.reports,
    pending: pending ?? this.pending,
    filters: filters ?? this.filters,
    query: query ?? this.query,
    nextId: nextId ?? this.nextId,
  );
}

/// What a join attempt led to.
enum JoinResult { going, waitlisted, closed, failed }

/// The events repository: the demo one, failing when "Simulate connection problems" is on or the
/// app is offline (a join needs the service's answer, so it is not queued).
final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => DemoEventsRepository(
    failing: () =>
        ref.read(datingProvider).simulateErrors ||
        !ref.read(connectivityProvider),
    fullWorld: ref.watch(demoWorldProvider) == DemoWorld.full,
  ),
);

/// Events: Explore, My events, joining, saving and hosting. Local and in memory; every change goes
/// through [EventsRepository.send] first, so a failure leaves the state as it was.
class EventsController extends Notifier<EventsState> {
  static const _log = AppLogger('Events');

  DateTime get now => ref.read(clockProvider)();

  EventsRepository get _repo => ref.read(eventsRepositoryProvider);

  @override
  EventsState build() {
    final repo = ref.watch(eventsRepositoryProvider);
    return EventsState(
      events: repo.initial(ref.read(clockProvider)()),
      saved: kSampleSavedEvents,
    );
  }

  /// Demo Hub: back to the predictable sample dataset.
  void reset() => ref.invalidateSelf();

  DemoEvent? byId(String id) => state.byId(id);

  /// The member's chosen area (onboarding's location step or the events area sheet).
  String? get area => ref.read(profileDetailsProvider).area;

  bool _hostBlocked(DemoEvent e) =>
      !e.mine && !ref.read(datingProvider).isActive(e.hostId);

  /// Why an event is picked for the member ("Because you like Jazz"), or null.
  String? pickedBecause(DemoEvent e) {
    final interests = ref.read(onboardingProvider).draft.interests;
    for (final i in kCategoryInterests[e.category] ?? const <String>[]) {
      if (interests.contains(i)) return i;
    }
    return null;
  }

  // Explore ---------------------------------------------------------------------------------
  bool _matchesQuery(DemoEvent e, String q) {
    if (q.isEmpty) return true;
    final host = personById(e.hostId)?.name ?? '';
    final text = '${e.title} ${e.description} ${e.venue} ${e.area ?? ''} $host'
        .toLowerCase();
    return q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .every(text.contains);
  }

  bool _matchesDate(DemoEvent e, EventDateFilter f) {
    final t = now;
    final today = DateTime(t.year, t.month, t.day);
    switch (f) {
      case EventDateFilter.any:
        return true;
      case EventDateFilter.today:
        return e.start.isBefore(today.add(const Duration(days: 1))) &&
            e.end.isAfter(t);
      case EventDateFilter.week:
        return e.start.isBefore(today.add(const Duration(days: 8)));
      case EventDateFilter.weekend:
        // This (or the coming) Saturday and Sunday.
        final toSat = (DateTime.saturday - today.weekday) % 7;
        final sat = today.weekday == DateTime.sunday
            ? today.subtract(const Duration(days: 1))
            : today.add(Duration(days: toSat));
        final mon = sat.add(const Duration(days: 2));
        return !e.start.isBefore(sat) && e.start.isBefore(mon);
    }
  }

  bool _fits(DemoEvent e, EventFilters f) {
    if (f.categories.isNotEmpty && !f.categories.contains(e.category)) {
      return false;
    }
    if (!_matchesDate(e, f.date)) return false;
    if (f.freeOnly && !e.free) return false;
    if (f.format == EventFormatFilter.inPerson &&
        e.format != EventFormat.inPerson) {
      return false;
    }
    if (f.format == EventFormatFilter.online &&
        e.format != EventFormat.online) {
      return false;
    }
    if (f.maxKm != null && e.format == EventFormat.inPerson) {
      final d = e.distanceFrom(area);
      if (d == null || d > f.maxKm!) return false;
    }
    return true;
  }

  /// Everything Explore could show: others' events, not past, not drafts, host not blocked.
  List<DemoEvent> _discoverable() => [
    for (final e in state.events)
      if (!e.mine &&
          e.status != EventStatus.draft &&
          e.phaseAt(now) != EventPhase.past &&
          !_hostBlocked(e))
        e,
  ];

  /// Explore under [filters] and [query] (defaults: the saved ones). Cancelled events stay listed,
  /// marked, after the rest.
  List<DemoEvent> explore({EventFilters? filters, String? query}) {
    final f = filters ?? state.filters;
    final q = (query ?? state.query).trim();
    final out = [
      for (final e in _discoverable())
        if (_fits(e, f) && _matchesQuery(e, q)) e,
    ];
    int byDate(DemoEvent a, DemoEvent b) => a.start.compareTo(b.start);
    out.sort((a, b) {
      final ca = a.status == EventStatus.cancelled ? 1 : 0;
      final cb = b.status == EventStatus.cancelled ? 1 : 0;
      if (ca != cb) return ca - cb;
      if (f.sort == EventSort.relevance) {
        final pa = pickedBecause(a) == null ? 1 : 0;
        final pb = pickedBecause(b) == null ? 1 : 0;
        if (pa != pb) return pa - pb;
      }
      return byDate(a, b);
    });
    return out;
  }

  /// "Picked for your interests": open upcoming events in a category linked to an interest.
  List<DemoEvent> picks() => [
    for (final e in explore(filters: const EventFilters(), query: ''))
      if (e.status == EventStatus.published &&
          e.registrationOpenAt(now) &&
          pickedBecause(e) != null &&
          e.participation == Participation.none)
        e,
  ].take(4).toList();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setFilters(EventFilters f) => state = state.copyWith(filters: f);
  void clearFilters() => state = state.copyWith(
    filters: EventFilters(sort: state.filters.sort),
    query: '',
  );

  // My events -------------------------------------------------------------------------------
  bool _ended(DemoEvent e) => e.phaseAt(now) == EventPhase.past;

  /// Going (including events since cancelled, marked), soonest first.
  List<DemoEvent> going() => _sorted([
    for (final e in state.events)
      if (!e.mine && e.participation == Participation.going && !_ended(e)) e,
  ]);

  List<DemoEvent> waitlisted() => _sorted([
    for (final e in state.events)
      if (e.participation == Participation.waitlisted && !_ended(e)) e,
  ]);

  List<DemoEvent> savedEvents() => _sorted([
    for (final e in state.events)
      if (state.saved.contains(e.id) && !_ended(e)) e,
  ]);

  /// The member's own events: drafts first, then published and cancelled by date.
  List<DemoEvent> hosting() {
    final mine = [
      for (final e in state.events)
        if (e.mine && !_ended(e)) e,
    ];
    final drafts = [
      for (final e in mine)
        if (e.status == EventStatus.draft) e,
    ];
    return [
      ...drafts,
      ..._sorted([
        for (final e in mine)
          if (e.status != EventStatus.draft) e,
      ]),
    ];
  }

  /// Past events the member went to or hosted, newest first.
  List<DemoEvent> past() {
    final out = [
      for (final e in state.events)
        if (_ended(e) &&
            e.status != EventStatus.draft &&
            (e.mine || e.participation == Participation.going))
          e,
    ]..sort((a, b) => b.start.compareTo(a.start));
    return out;
  }

  List<DemoEvent> _sorted(List<DemoEvent> l) =>
      l..sort((a, b) => a.start.compareTo(b.start));

  // Participation ---------------------------------------------------------------------------
  void _put(DemoEvent e) => state = state.copyWith(
    events: [for (final x in state.events) x.id == e.id ? e : x],
  );

  Future<bool> _send(String action, String id) async {
    state = state.copyWith(pending: {...state.pending, id});
    try {
      await _repo.send(action, id);
      return true;
    } on EventsUnavailable {
      _log.info('Event change failed ($action)');
      return false;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(pending: {...state.pending}..remove(id));
      }
    }
  }

  /// Join an event (or its waitlist when full). [answer] goes with it when the host asked a
  /// question.
  Future<JoinResult> join(String id, {String? answer}) async {
    final e = byId(id);
    if (e == null || !e.registrationOpenAt(now) || e.mine) {
      return JoinResult.closed;
    }
    if (e.participation != Participation.none) {
      return e.participation == Participation.going
          ? JoinResult.going
          : JoinResult.waitlisted;
    }
    if (!await _send('join', id)) return JoinResult.failed;
    if (!ref.mounted) return JoinResult.failed;
    final fresh = byId(id)!;
    final result = fresh.full ? JoinResult.waitlisted : JoinResult.going;
    _put(
      result == JoinResult.going
          ? fresh.copyWith(attendees: [...fresh.attendees, kMe])
          : fresh.copyWith(waitlist: [...fresh.waitlist, kMe]),
    );
    final a = answer?.trim() ?? '';
    if (a.isNotEmpty) {
      state = state.copyWith(answers: {...state.answers, id: a});
    }
    return result;
  }

  /// Leave an event or its waitlist. A place given up goes to the first person waiting.
  Future<bool> leave(String id) async {
    final e = byId(id);
    if (e == null || e.participation == Participation.none) return true;
    if (!await _send('leave', id)) return false;
    if (!ref.mounted) return false;
    final fresh = byId(id)!;
    final wasGoing = fresh.participation == Participation.going;
    var next = fresh.copyWith(
      attendees: [...fresh.attendees]..remove(kMe),
      waitlist: [...fresh.waitlist]..remove(kMe),
    );
    if (wasGoing) next = _promote(next);
    _put(next);
    state = state.copyWith(answers: {...state.answers}..remove(id));
    return true;
  }

  /// Moves the first waiting person to going while there is room.
  DemoEvent _promote(DemoEvent e) {
    var next = e;
    while (next.waitlist.isNotEmpty && !next.full) {
      final first = next.waitlist.first;
      next = next.copyWith(
        attendees: [...next.attendees, first],
        waitlist: next.waitlist.sublist(1),
      );
    }
    return next;
  }

  /// Demo Hub / tests: someone going drops out of [id]. Returns true when that moved the member
  /// from the waitlist to going.
  bool openSpot(String id) {
    final e = byId(id);
    if (e == null) return false;
    final waiting = e.participation == Participation.waitlisted;
    DemoEvent next;
    if (e.othersGoing > 0) {
      next = e.copyWith(othersGoing: e.othersGoing - 1);
    } else {
      final named = [
        for (final a in e.attendees)
          if (a != kMe) a,
      ];
      if (named.isEmpty) return false;
      next = e.copyWith(attendees: [...e.attendees]..remove(named.last));
    }
    next = _promote(next);
    _put(next);
    return waiting && next.participation == Participation.going;
  }

  void toggleSave(String id) {
    final saved = {...state.saved};
    saved.contains(id) ? saved.remove(id) : saved.add(id);
    state = state.copyWith(saved: saved);
  }

  /// Saves a report on this device. Nothing is sent or reviewed.
  void report(String id, String reason) => state = state.copyWith(
    reports: [
      ...state.reports,
      EventReport(eventId: id, reason: reason),
    ],
  );

  // Hosting ---------------------------------------------------------------------------------
  DemoEvent _fromDraft(
    String id,
    EventDraft d,
    EventStatus status, {
    DemoEvent? base,
  }) {
    final grid = d.area == null ? null : kEventAreaGrid[d.area];
    final event = DemoEvent(
      id: id,
      title: d.title.trim(),
      category: d.category ?? EventCategory.games,
      description: d.description.trim(),
      hostId: kMe,
      start: d.start ?? now.add(const Duration(days: 7)),
      duration: d.duration,
      format: d.format,
      venue: d.format == EventFormat.inPerson ? d.venue.trim() : '',
      area: d.format == EventFormat.inPerson ? d.area : null,
      x: grid?.x ?? 0,
      y: grid?.y ?? 0,
      onlineNote: d.format == EventFormat.online ? d.onlineNote.trim() : '',
      capacity: d.capacity,
      cost: d.cost.trim().isEmpty ? null : d.cost.trim(),
      question: d.question.trim().isEmpty ? null : d.question.trim(),
      attendees: base?.attendees ?? const [],
      othersGoing: base?.othersGoing ?? 0,
      waitlist: base?.waitlist ?? const [],
      status: status,
      tone: d.tone,
      sample: false,
    );
    return event;
  }

  /// Saves [draft] as a draft (new when [id] is null). Returns the event id, or null on failure.
  Future<String?> saveDraft(EventDraft draft, {String? id}) async {
    if (!EventRules.canSaveDraft(draft)) return null;
    final newId = id ?? 'h-${state.nextId}';
    if (!await _send('draft', newId)) return null;
    if (!ref.mounted) return null;
    final existing = id == null ? null : byId(id);
    final event = _fromDraft(newId, draft, EventStatus.draft, base: existing);
    state = state.copyWith(
      events: existing == null
          ? [...state.events, event]
          : [for (final x in state.events) x.id == id ? event : x],
      nextId: id == null ? state.nextId + 1 : state.nextId,
    );
    return newId;
  }

  /// Publishes [draft] (a new event, a draft, or changes to a published event). Returns the id, or
  /// null when it isn't valid or the change failed.
  Future<String?> publish(EventDraft draft, {String? id}) async {
    final existing = id == null ? null : byId(id);
    final going = existing == null
        ? 0
        : existing.attendees.length + existing.othersGoing;
    if (EventRules.problems(draft, now: now, going: going).isNotEmpty) {
      return null;
    }
    final newId = id ?? 'h-${state.nextId}';
    if (!await _send('publish', newId)) return null;
    if (!ref.mounted) return null;
    var event = _fromDraft(newId, draft, EventStatus.published, base: existing);
    // Attendees are told when the time or place of a published event changes.
    if (existing != null &&
        existing.status == EventStatus.published &&
        (existing.start != event.start ||
            existing.venue != event.venue ||
            existing.format != event.format)) {
      event = event.copyWith(changeNote: kHostUpdatedNote);
    }
    if (existing != null) event = _promote(event);
    state = state.copyWith(
      events: existing == null
          ? [...state.events, event]
          : [for (final x in state.events) x.id == id ? event : x],
      nextId: id == null ? state.nextId + 1 : state.nextId,
    );
    return newId;
  }

  /// Cancels the member's event; it stays visible with its status and [note].
  Future<bool> cancel(String id, {String note = ''}) async {
    final e = byId(id);
    if (e == null || !e.mine) return false;
    if (!await _send('cancel', id)) return false;
    if (!ref.mounted) return false;
    _put(
      e.copyWith(
        status: EventStatus.cancelled,
        cancelNote: note.trim().isEmpty ? null : note.trim(),
      ),
    );
    return true;
  }

  void deleteDraft(String id) => state = state.copyWith(
    events: [
      for (final e in state.events)
        if (!(e.id == id && e.status == EventStatus.draft)) e,
    ],
  );

  /// Host: removes someone going; the first person waiting takes the place.
  void removeAttendee(String id, String personId) {
    final e = byId(id);
    if (e == null || !e.mine) return;
    _put(_promote(e.copyWith(attendees: [...e.attendees]..remove(personId))));
  }

  /// Host: moves someone from the waitlist to going (only when there is room).
  bool moveToGoing(String id, String personId) {
    final e = byId(id);
    if (e == null || !e.mine || e.full || !e.waitlist.contains(personId)) {
      return false;
    }
    _put(
      e.copyWith(
        attendees: [...e.attendees, personId],
        waitlist: [...e.waitlist]..remove(personId),
      ),
    );
    return true;
  }
}

final eventsProvider = NotifierProvider<EventsController, EventsState>(
  EventsController.new,
);
