import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/connectivity/connectivity.dart';
import '../../../core/logging/app_logger.dart';
import '../../dating/application/dating_controller.dart';
import '../../dating/domain/sample_people.dart';
import '../../health/application/health_providers.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../domain/event_models.dart';
import '../domain/sample_events_mvp.dart';

/// Outcome of a private event interest (E07).
enum InterestResult { sent, mutual, duplicate, exhausted, notEligible, closed }

/// Date filter for E01.
enum EvDateFilter { any, thisWeek, weekend }

@immutable
class EvState {
  const EvState({
    required this.events,
    this.reservations = const {},
    this.attendance = const {},
    this.notices = const [],
    this.interests = const {},
    this.passes = const {},
    this.connections = const {},
    this.proposals = const [],
    this.staffAttendance = const {},
    this.reports = 0,
    this.city = 'Mumbai',
    this.category,
    this.dateFilter = EvDateFilter.any,
    this.inFlight = const {},
    this.uncertain = const {},
    this.dropNextResponse = false,
    this.forceIneligible = false,
    this.nextRef = 1001,
    this.audit = const [],
  });

  final Map<String, NumayaEvent> events;
  final Map<String, Reservation> reservations;
  final Map<String, Attendance> attendance;
  final List<EvNotice> notices;
  final Map<String, Set<String>> interests;
  final Map<String, Set<String>> passes;
  final Map<String, Map<String, EventConnection>> connections;
  final List<EvProposal> proposals;

  /// H03: sample attendees' attendance per event (names only).
  final Map<String, Map<String, Attendance>> staffAttendance;
  final int reports;
  final String city;
  final EvCategory? category;
  final EvDateFilter dateFilter;

  /// Reservations being submitted (repeated taps are ignored).
  final Set<String> inFlight;

  /// Reservations whose result was not received (E03 uncertain): reconcile before retrying.
  final Set<String> uncertain;

  /// Demo scenario: the next reservation commits but its response is "lost".
  final bool dropNextResponse;

  /// Demo scenario: treat the member as ineligible.
  final bool forceIneligible;
  final int nextRef;

  /// Staff actions (H01–H04), newest last: "who did what" in the demo.
  final List<String> audit;

  EvState copyWith({
    Map<String, NumayaEvent>? events,
    Map<String, Reservation>? reservations,
    Map<String, Attendance>? attendance,
    List<EvNotice>? notices,
    Map<String, Set<String>>? interests,
    Map<String, Set<String>>? passes,
    Map<String, Map<String, EventConnection>>? connections,
    List<EvProposal>? proposals,
    Map<String, Map<String, Attendance>>? staffAttendance,
    int? reports,
    String? city,
    EvCategory? category,
    bool clearCategory = false,
    EvDateFilter? dateFilter,
    Set<String>? inFlight,
    Set<String>? uncertain,
    bool? dropNextResponse,
    bool? forceIneligible,
    int? nextRef,
    List<String>? audit,
  }) => EvState(
    events: events ?? this.events,
    reservations: reservations ?? this.reservations,
    attendance: attendance ?? this.attendance,
    notices: notices ?? this.notices,
    interests: interests ?? this.interests,
    passes: passes ?? this.passes,
    connections: connections ?? this.connections,
    proposals: proposals ?? this.proposals,
    staffAttendance: staffAttendance ?? this.staffAttendance,
    reports: reports ?? this.reports,
    city: city ?? this.city,
    category: clearCategory ? null : (category ?? this.category),
    dateFilter: dateFilter ?? this.dateFilter,
    inFlight: inFlight ?? this.inFlight,
    uncertain: uncertain ?? this.uncertain,
    dropNextResponse: dropNextResponse ?? this.dropNextResponse,
    forceIneligible: forceIneligible ?? this.forceIneligible,
    nextRef: nextRef ?? this.nextRef,
    audit: audit ?? this.audit,
  );
}

/// The Events demo (PRD E01–E08, S01, M01/M02, H01–H04). Local and deterministic; every rule a
/// live build needs on the server is noted where it is applied.
class EventsMvpController extends Notifier<EvState> {
  static const _log = AppLogger('EventsMvp');

  DateTime get _now => ref.read(clockProvider)();

  @override
  EvState build() {
    final now = ref.read(clockProvider)();
    final events = {for (final e in sampleEventsMvp(now)) e.id: e};
    final seeded = ref.watch(demoWorldProvider) != DemoWorld.fresh;
    final reservations = <String, Reservation>{};
    if (seeded) {
      var n = 1;
      for (final MapEntry(key: id, value: (v, disc))
          in kSeededReservations.entries) {
        final e = events[id]!;
        final pending = e.version > v;
        reservations[id] = Reservation(
          eventId: id,
          status: e.lifecycle == EvLifecycle.cancelled
              ? ResStatus.cancelled
              : pending
              ? ResStatus.reconfirmRequired
              : ResStatus.confirmed,
          acceptedVersion: v,
          createdAt: now.subtract(Duration(days: 12 - n)),
          reference: 'NM-${900 + n++}',
          cancelReason: e.lifecycle == EvLifecycle.cancelled
              ? CancelReason.eventCancelled
              : null,
          cancelledAt: e.lifecycle == EvLifecycle.cancelled
              ? now.subtract(const Duration(hours: 20))
              : null,
          discoverable: disc,
        );
      }
    }
    final walk = events['ev-sunrise-walk']!;
    final notices = seeded
        ? [
            EvNotice(
              id: 'n-cycle-1',
              eventId: 'ev-cycle-ride',
              kind: NoticeKind.ordinary,
              title: 'Meeting point reminder',
              body: 'We meet at the NCPA end at 6:20. Bring water; it gets warm by 8.',
              sentAt: now.subtract(const Duration(hours: 3)),
              sender: 'Numaya events team (sample)',
            ),
            EvNotice(
              id: 'n-walk-v2',
              eventId: 'ev-sunrise-walk',
              kind: NoticeKind.material,
              title: 'Meeting point moved',
              body: 'The promenade’s south gate is closed for works, so we start at the north gate. Your place is held until you answer.',
              sentAt: now.subtract(const Duration(hours: 2)),
              sender: 'Numaya events team (sample)',
              forVersion: walk.version,
              before: 'Carter Road Promenade, south gate',
              after: walk.venue.name,
              deadline: EvPolicy.reconfirmDeadline(
                now.subtract(const Duration(hours: 2)),
                walk.start,
              ),
            ),
            EvNotice(
              id: 'n-pottery-cancel',
              eventId: 'ev-pottery-hauz-khas',
              kind: NoticeKind.cancellation,
              title: 'This event is cancelled',
              body: events['ev-pottery-hauz-khas']!.cancelReason!,
              sentAt: now.subtract(const Duration(hours: 20)),
              sender: 'Numaya events team (sample)',
              pushFailed: true,
            ),
          ]
        : <EvNotice>[];
    final proposals = seeded
        ? [
            EvProposal(
              id: 'p-chess',
              title: 'Chess in the park',
              category: EvCategory.games,
              city: 'Mumbai',
              venueName: 'Joggers Park lawn',
              description: 'Bring a board or borrow one. Beginners welcome.',
              start: now.add(const Duration(days: 14, hours: 4)),
              capacity: 20,
              status: ProposalStatus.needsChanges,
              reviewNote: 'Please confirm the park allows organised groups, and add an end time.',
              submittedAt: now.subtract(const Duration(days: 2)),
            ),
          ]
        : <EvProposal>[];
    return EvState(
      events: events,
      reservations: reservations,
      attendance: seeded ? Map.of(kSeededAttendance) : const {},
      notices: notices,
      proposals: proposals,
      staffAttendance: {
        for (final id in events.keys)
          id: {for (final n in kSampleAttendeeNames) n: Attendance.notRecorded},
      },
    );
  }

  void reset() => ref.invalidateSelf();

  // Scenarios (demo controls) -------------------------------------------------------------
  void setDropNextResponse(bool v) =>
      state = state.copyWith(dropNextResponse: v);
  void setForceIneligible(bool v) => state = state.copyWith(forceIneligible: v);

  // E01 --------------------------------------------------------------------------------------
  void setCity(String c) => state = state.copyWith(city: c);
  void setCategory(EvCategory? c) => c == null
      ? state = state.copyWith(clearCategory: true)
      : state = state.copyWith(category: c);
  void setDateFilter(EvDateFilter f) => state = state.copyWith(dateFilter: f);

  /// Published, not yet started events in the chosen city, soonest first. Cancelled events are
  /// never offered here; past events live in My events.
  List<NumayaEvent> feed() {
    final now = _now;
    final weekEnd = now.add(const Duration(days: 7));
    return state.events.values.where((e) {
      if (e.city != state.city) return false;
      if (e.lifecycle != EvLifecycle.published) return false;
      if (!now.isBefore(e.start)) return false;
      if (state.category != null && e.category != state.category) return false;
      return switch (state.dateFilter) {
        EvDateFilter.any => true,
        EvDateFilter.thisWeek => e.start.isBefore(weekEnd),
        EvDateFilter.weekend =>
          e.start.isBefore(weekEnd) &&
              (e.start.weekday == DateTime.saturday ||
                  e.start.weekday == DateTime.sunday),
      };
    }).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  NumayaEvent? event(String id) => state.events[id];
  Reservation? reservation(String id) => state.reservations[id];

  /// Reserved places: other members' sample reservations plus the member's active one.
  /// Reconfirmation-held seats count; cancelled ones never do.
  int reserved(String id) {
    final e = state.events[id];
    if (e == null) return 0;
    final mine = effectiveReservation(id)?.active ?? false;
    return (e.othersReserved + (mine ? 1 : 0)).clamp(0, e.capacity);
  }

  int placesLeft(String id) {
    final e = state.events[id];
    return e == null ? 0 : e.capacity - reserved(id);
  }

  bool isFull(String id) => placesLeft(id) <= 0;

  /// Open alternatives in the same city (never fabricated).
  List<NumayaEvent> alternatives(String id) {
    final e = state.events[id];
    if (e == null) return const [];
    return feed().where((x) => x.id != id && !isFull(x.id)).take(2).toList();
  }

  /// Why the member cannot reserve [id] (empty: eligible). Live: evaluated on the server.
  List<Ineligibility> ineligibility(String id) {
    final e = state.events[id];
    if (state.forceIneligible) return [Ineligibility.profileIncomplete];
    final out = <Ineligibility>[];
    final draft = ref.read(onboardingProvider).draft;
    final age = draft.ageOn(_now);
    if (age == null || age < 18) out.add(Ineligibility.underAge);
    if (e != null &&
        age != null &&
        (age < e.minAge || (e.maxAge != null && age > e.maxAge!))) {
      out.add(Ineligibility.ageOutsideEvent);
    }
    if (!ref.read(profileHealthProvider).requiredComplete) {
      out.add(Ineligibility.profileIncomplete);
    }
    if (ref.read(sessionPhoneVerifiedProvider) == false) {
      out.add(Ineligibility.phoneUnverified);
    }
    return out;
  }

  // E03 --------------------------------------------------------------------------------------
  /// Reserves one place. Repeated taps while submitting do nothing; an existing reservation is
  /// returned instead of a second one; an uncertain result must be reconciled before retrying.
  /// Live: an atomic server write checking version, start, eligibility and capacity.
  Future<ReserveResult> reserve(String id, {required bool discoverable}) async {
    if (state.inFlight.contains(id)) return ReserveResult.alreadyReserved;
    _expireDeadlines();
    final e = state.events[id];
    if (e == null) return ReserveResult.error;
    if (state.reservations[id]?.active ?? false) {
      return ReserveResult.alreadyReserved;
    }
    if (state.uncertain.contains(id)) {
      // Reconcile first: never resubmit blind.
      return reconcile(id);
    }
    if (e.lifecycle == EvLifecycle.cancelled) return ReserveResult.cancelled;
    if (!_now.isBefore(e.start)) return ReserveResult.closed;
    if (ineligibility(id).isNotEmpty) return ReserveResult.ineligible;
    if (isFull(id)) return ReserveResult.full;
    if (!ref.read(connectivityProvider)) return ReserveResult.error;
    state = state.copyWith(inFlight: {...state.inFlight, id});
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!ref.mounted) return ReserveResult.error;
    // Server re-check at commit time.
    final full = isFull(id);
    final drop = state.dropNextResponse;
    if (!full) {
      state = state.copyWith(
        reservations: {
          ...state.reservations,
          id: Reservation(
            eventId: id,
            status: ResStatus.confirmed,
            acceptedVersion: e.version,
            createdAt: _now,
            reference: 'NM-${state.nextRef}',
            discoverable: discoverable,
          ),
        },
        nextRef: state.nextRef + 1,
      );
    }
    state = state.copyWith(
      inFlight: {...state.inFlight}..remove(id),
      uncertain: drop && !full ? {...state.uncertain, id} : null,
      dropNextResponse: false,
    );
    if (full) return ReserveResult.full;
    if (drop) return ReserveResult.uncertain;
    _log.info('Reserved');
    return ReserveResult.confirmed;
  }

  /// Looks up the authoritative result of an uncertain reservation.
  ReserveResult reconcile(String id) {
    state = state.copyWith(uncertain: {...state.uncertain}..remove(id));
    return (state.reservations[id]?.active ?? false)
        ? ReserveResult.confirmed
        : ReserveResult.error;
  }

  /// Other active reservations that overlap [id] (a warning, never a ban).
  List<NumayaEvent> overlaps(String id) {
    final e = state.events[id];
    if (e == null) return const [];
    return [
      for (final r in state.reservations.values)
        if (r.active && r.eventId != id)
          if (state.events[r.eventId] case final o?)
            if (o.start.isBefore(e.end) && e.start.isBefore(o.end)) o,
    ];
  }

  // E04/E05 ----------------------------------------------------------------------------------
  /// The member's reservations as they stand now (deadlines applied without writing state, so
  /// screens can read this while building). Live: a server job expires them.
  List<(NumayaEvent, Reservation)> myEvents() => [
    for (final r in state.reservations.values)
      if (state.events[r.eventId] case final e?) (e, _effective(r)),
  ]..sort((a, b) => a.$1.start.compareTo(b.$1.start));

  Reservation? effectiveReservation(String id) {
    final r = state.reservations[id];
    return r == null ? null : _effective(r);
  }

  /// A reconfirmation whose deadline has passed reads as cancelled (deadline).
  Reservation _effective(Reservation r) {
    if (r.status != ResStatus.reconfirmRequired) return r;
    final e = state.events[r.eventId];
    final n = state.notices
        .where(
          (n) =>
              n.eventId == r.eventId &&
              n.kind == NoticeKind.material &&
              n.forVersion == e?.version,
        )
        .lastOrNull;
    if (n?.deadline != null && !_now.isBefore(n!.deadline!)) {
      return r.copyWith(
        status: ResStatus.cancelled,
        cancelReason: CancelReason.deadlinePassed,
        cancelledAt: n.deadline,
      );
    }
    return r;
  }

  void _expireDeadlines() {
    final now = _now;
    var changed = false;
    final res = {...state.reservations};
    for (final n in state.notices) {
      if (n.kind != NoticeKind.material || n.deadline == null) continue;
      final r = res[n.eventId];
      final e = state.events[n.eventId];
      if (r == null || e == null) continue;
      if (r.status == ResStatus.reconfirmRequired &&
          n.forVersion == e.version &&
          !now.isBefore(n.deadline!)) {
        res[n.eventId] = r.copyWith(
          status: ResStatus.cancelled,
          cancelReason: CancelReason.deadlinePassed,
          cancelledAt: n.deadline,
        );
        changed = true;
      }
    }
    if (changed) state = state.copyWith(reservations: res);
  }

  Attendance attendanceOf(String id) =>
      state.attendance[id] ?? Attendance.notRecorded;

  /// Cancels before the start. Idempotent; a checked-in seat is never recycled.
  bool cancel(String id, {CancelReason reason = CancelReason.member}) {
    _expireDeadlines();
    final r = state.reservations[id];
    final e = state.events[id];
    if (r == null || e == null || !r.active) return false;
    if (attendanceOf(id) == Attendance.checkedIn) return false;
    if (!_now.isBefore(e.start) && reason == CancelReason.member) return false;
    state = state.copyWith(
      reservations: {
        ...state.reservations,
        id: r.copyWith(
          status: ResStatus.cancelled,
          cancelReason: reason,
          cancelledAt: _now,
        ),
      },
    );
    return true;
  }

  /// Event-specific discoverability. Turning it off withdraws pending one-sided interests; it
  /// never deletes established chats.
  void setDiscoverable(String id, bool on) {
    final r = state.reservations[id];
    if (r == null) return;
    final conns = state.connections[id] ?? const {};
    state = state.copyWith(
      reservations: {
        ...state.reservations,
        id: r.copyWith(discoverable: on),
      },
      interests: on
          ? null
          : {
              ...state.interests,
              id: {
                for (final p in state.interests[id] ?? const <String>{})
                  if (conns.containsKey(p)) p,
              },
            },
    );
  }

  // E06 --------------------------------------------------------------------------------------
  List<EvNotice> noticesFor(String eventId) => [
    for (final n in state.notices.reversed)
      if (n.eventId == eventId) n,
  ];

  int unreadNotices() => state.notices.where((n) => !n.read).length;

  /// A material notice is current only for the event's latest version.
  bool isSuperseded(EvNotice n) =>
      n.kind == NoticeKind.material &&
      n.forVersion != state.events[n.eventId]?.version;

  void markRead(String noticeId) =>
      _setNotice(noticeId, (n) => n.copyWith(read: true));

  void acknowledge(String noticeId) => _setNotice(
    noticeId,
    (n) => n.copyWith(read: true, response: NoticeResponse.acknowledged),
  );

  /// Reconfirms the latest version before the deadline. Older notices can't confirm anything.
  bool reconfirm(String noticeId) {
    _expireDeadlines();
    final n = state.notices.where((x) => x.id == noticeId).firstOrNull;
    if (n == null || isSuperseded(n)) return false;
    final r = state.reservations[n.eventId];
    final e = state.events[n.eventId];
    if (r == null || e == null || r.status != ResStatus.reconfirmRequired) {
      return false;
    }
    state = state.copyWith(
      reservations: {
        ...state.reservations,
        n.eventId: r.copyWith(
          status: ResStatus.confirmed,
          acceptedVersion: e.version,
        ),
      },
    );
    _setNotice(
      noticeId,
      (x) => x.copyWith(read: true, response: NoticeResponse.reconfirmed),
    );
    return true;
  }

  bool decline(String noticeId) {
    final n = state.notices.where((x) => x.id == noticeId).firstOrNull;
    if (n == null || isSuperseded(n)) return false;
    final ok = cancel(n.eventId, reason: CancelReason.declinedChange);
    if (ok) {
      _setNotice(
        noticeId,
        (x) => x.copyWith(read: true, response: NoticeResponse.declined),
      );
    }
    return ok;
  }

  void _setNotice(String id, EvNotice Function(EvNotice) f) =>
      state = state.copyWith(
        notices: [for (final n in state.notices) n.id == id ? f(n) : n],
      );

  // E07/E08 ----------------------------------------------------------------------------------
  /// Whether People I met is open for the member at [id]: completed, checked in, opted in, and
  /// inside the seven-day window.
  bool followUpOpen(String id) {
    final e = state.events[id];
    final r = state.reservations[id];
    if (e == null || r == null) return false;
    return attendanceOf(id) == Attendance.checkedIn &&
        r.discoverable &&
        EvPolicy.followUpOpen(e, _now);
  }

  DateTime? followUpEnds(String id) =>
      state.events[id]?.end.add(EvPolicy.followUpWindow);

  /// Eligible people: checked in, opted in, compatible with the member's preferences, not
  /// blocked or unmatched. Live: re-evaluated on every read and write.
  List<SamplePerson> peers(String id) {
    if (id != 'ev-book-swap') return const [];
    final dating = ref.read(datingProvider);
    final openTo = ref.read(onboardingProvider).draft.openTo;
    return [
      for (final p in kBookSwapPeers)
        if (p.checkedIn && p.optedIn)
          if (personById(p.personId) case final person?)
            if ((openTo == null || openTo.contains(person.gender)) &&
                !dating.ended.containsKey(person.id))
              person,
    ];
  }

  int interestsLeft(String id) =>
      EvPolicy.interestsPerEvent - (state.interests[id]?.length ?? 0);

  /// Sends a private interest. Duplicates cost nothing; a fourth distinct one is refused; when
  /// the other person is also interested it becomes a mutual connection through the existing
  /// chat rules (never a duplicate chat, never a reset timer).
  InterestResult sendInterest(String id, String personId) {
    if (!followUpOpen(id)) return InterestResult.closed;
    final sent = state.interests[id] ?? const <String>{};
    if (sent.contains(personId)) return InterestResult.duplicate;
    if (!peers(id).any((p) => p.id == personId))
      return InterestResult.notEligible;
    if (sent.length >= EvPolicy.interestsPerEvent)
      return InterestResult.exhausted;
    state = state.copyWith(
      interests: {
        ...state.interests,
        id: {...sent, personId},
      },
    );
    final peer = kBookSwapPeers
        .where((p) => p.personId == personId)
        .firstOrNull;
    if (peer != null && peer.interestedInMember) {
      final result = ref
          .read(datingProvider.notifier)
          .connectFromEvent(personId);
      state = state.copyWith(
        connections: {
          ...state.connections,
          id: {...state.connections[id] ?? const {}, personId: result},
        },
      );
      return InterestResult.mutual;
    }
    return InterestResult.sent;
  }

  void pass(String id, String personId) => state = state.copyWith(
    passes: {
      ...state.passes,
      id: {...state.passes[id] ?? const {}, personId},
    },
  );

  EventConnection? connectionWith(String id, String personId) =>
      state.connections[id]?[personId];

  // S01 --------------------------------------------------------------------------------------
  String submitReport() {
    state = state.copyWith(reports: state.reports + 1);
    return 'R-${2400 + state.reports}';
  }

  // M01/M02 (proposed reconciliation of O1) ---------------------------------------------------
  /// Validation for a proposal: title, public venue (never a home), 20–30 places, a future date.
  List<String> proposalProblems(EvProposal p) => [
    if (p.title.trim().length < 4) 'title',
    if (p.venueName.trim().length < 3) 'venue',
    if (p.privateHome) 'privateHome',
    if (p.capacity < 20 || p.capacity > 30) 'capacity',
    if (!p.start.isAfter(_now.add(const Duration(days: 3)))) 'date',
  ];

  EvProposal newProposal() => EvProposal(
    id: 'p-${_now.microsecondsSinceEpoch}',
    title: '',
    category: EvCategory.coffee,
    city: state.city,
    venueName: '',
    description: '',
    start: _now.add(const Duration(days: 14)),
    capacity: 24,
    status: ProposalStatus.draft,
  );

  void saveProposal(EvProposal p) => state = state.copyWith(
    proposals: [
      for (final x in state.proposals)
        if (x.id != p.id) x,
      p,
    ],
  );

  bool submitProposal(EvProposal p) {
    if (proposalProblems(p).isNotEmpty) return false;
    saveProposal(
      p.copyWith(status: ProposalStatus.submitted, submittedAt: _now),
    );
    return true;
  }

  void withdrawProposal(String id) =>
      _setProposal(id, (p) => p.copyWith(status: ProposalStatus.withdrawn));

  void _setProposal(String id, EvProposal Function(EvProposal) f) =>
      state = state.copyWith(
        proposals: [for (final p in state.proposals) p.id == id ? f(p) : p],
      );

  // H01–H04 (internal tools, demo role) ------------------------------------------------------
  void _audit(String line) =>
      state = state.copyWith(audit: [...state.audit, line]);

  void startReview(String id) {
    _setProposal(id, (p) => p.copyWith(status: ProposalStatus.inReview));
    _audit('Review started: $id');
  }

  void returnProposal(String id, String note) {
    _setProposal(
      id,
      (p) => p.copyWith(status: ProposalStatus.needsChanges, reviewNote: note),
    );
    _audit('Returned for changes: $id');
  }

  void rejectProposal(String id, String note) {
    _setProposal(
      id,
      (p) => p.copyWith(status: ProposalStatus.rejected, reviewNote: note),
    );
    _audit('Rejected: $id');
  }

  /// Publishes a reviewed proposal as an event. Idempotent: publishing twice returns the same
  /// event. Refuses private homes and anything without a named host and reviewer.
  String? publishProposal(
    String id, {
    required String host,
    required String reviewer,
  }) {
    final p = state.proposals.where((x) => x.id == id).firstOrNull;
    if (p == null ||
        p.privateHome ||
        host.trim().isEmpty ||
        reviewer.trim().isEmpty) {
      return null;
    }
    if (p.publishedEventId != null) return p.publishedEventId;
    final eventId = 'ev-$id';
    final e = NumayaEvent(
      id: eventId,
      title: p.title,
      category: p.category,
      city: p.city,
      venue: EvVenue(name: p.venueName, address: p.venueName, area: p.city),
      start: p.start,
      end: p.start.add(const Duration(hours: 2)),
      capacity: p.capacity,
      description: p.description,
      hostName: host,
      reviewerName: reviewer,
      fromProposal: id,
    );
    state = state.copyWith(
      events: {...state.events, eventId: e},
      staffAttendance: {
        ...state.staffAttendance,
        eventId: {
          for (final n in kSampleAttendeeNames) n: Attendance.notRecorded,
        },
      },
    );
    _setProposal(
      id,
      (x) => x.copyWith(
        status: ProposalStatus.published,
        publishedEventId: eventId,
      ),
    );
    _audit('Published: $eventId');
    return eventId;
  }

  /// H03: check in or correct attendance. Only active reservations can be checked in.
  bool setStaffAttendance(String eventId, String name, Attendance a) {
    final map = state.staffAttendance[eventId];
    if (map == null || !map.containsKey(name)) return false;
    state = state.copyWith(
      staffAttendance: {
        ...state.staffAttendance,
        eventId: {...map, name: a},
      },
    );
    _audit('Attendance $name: ${a.name} ($eventId)');
    return true;
  }

  /// H03 for the demo member's own reservation.
  bool setMemberAttendance(String eventId, Attendance a) {
    final r = state.reservations[eventId];
    if (r == null || !r.active) return false;
    state = state.copyWith(attendance: {...state.attendance, eventId: a});
    _audit('Attendance member: ${a.name} ($eventId)');
    return true;
  }

  /// H04: an ordinary announcement. Persistent in-app; push may fail.
  void announce(String eventId, String title, String body) {
    state = state.copyWith(
      notices: [
        ...state.notices,
        EvNotice(
          id: 'n-${_now.microsecondsSinceEpoch}',
          eventId: eventId,
          kind: NoticeKind.ordinary,
          title: title,
          body: body,
          sentAt: _now,
          sender: 'Numaya events team (sample)',
        ),
      ],
    );
    _audit('Announcement: $eventId');
  }

  /// H04: a material time/venue change. Refused when it leaves under two hours to respond.
  /// Holds seats and requires reconfirmation; older notices become superseded.
  bool applyMaterialChange(
    String eventId, {
    required DateTime newStart,
    required String venueName,
    required String reason,
  }) {
    final e = state.events[eventId];
    if (e == null || e.lifecycle != EvLifecycle.published) return false;
    final deadline = EvPolicy.reconfirmDeadline(_now, newStart);
    if (deadline == null) return false;
    final updated = e.copyWith(
      start: newStart,
      end: newStart.add(e.end.difference(e.start)),
      venue: EvVenue(
        name: venueName,
        address: venueName,
        area: e.venue.area,
        accessibility: null,
        transport: null,
      ),
      version: e.version + 1,
    );
    final r = state.reservations[eventId];
    state = state.copyWith(
      events: {...state.events, eventId: updated},
      reservations: r != null && r.active
          ? {
              ...state.reservations,
              eventId: r.copyWith(status: ResStatus.reconfirmRequired),
            }
          : null,
      notices: [
        ...state.notices,
        EvNotice(
          id: 'n-${_now.microsecondsSinceEpoch}',
          eventId: eventId,
          kind: NoticeKind.material,
          title: 'Time or place changed',
          body: reason,
          sentAt: _now,
          sender: 'Numaya events team (sample)',
          forVersion: updated.version,
          before: '${e.venue.name}, ${e.start}',
          after: '$venueName, $newStart',
          deadline: deadline,
        ),
      ],
    );
    _audit('Material change v${updated.version}: $eventId');
    return true;
  }

  /// H04: cancels the event. Idempotent; reservations show the reason; history stays.
  bool cancelEvent(String eventId, String reason) {
    final e = state.events[eventId];
    if (e == null) return false;
    if (e.lifecycle == EvLifecycle.cancelled) return true;
    state = state.copyWith(
      events: {
        ...state.events,
        eventId: e.copyWith(
          lifecycle: EvLifecycle.cancelled,
          cancelReason: reason,
        ),
      },
      notices: [
        ...state.notices,
        EvNotice(
          id: 'n-${_now.microsecondsSinceEpoch}',
          eventId: eventId,
          kind: NoticeKind.cancellation,
          title: 'This event is cancelled',
          body: reason,
          sentAt: _now,
          sender: 'Numaya events team (sample)',
        ),
      ],
    );
    final r = state.reservations[eventId];
    if (r != null && r.active) {
      state = state.copyWith(
        reservations: {
          ...state.reservations,
          eventId: r.copyWith(
            status: ResStatus.cancelled,
            cancelReason: CancelReason.eventCancelled,
            cancelledAt: _now,
          ),
        },
      );
    }
    _audit('Cancelled: $eventId');
    return true;
  }
}

final eventsMvpProvider = NotifierProvider<EventsMvpController, EvState>(
  EventsMvpController.new,
);

/// Whether the member's phone is verified (demo sessions are verified). Overridable in tests.
final sessionPhoneVerifiedProvider = Provider<bool>((ref) => true);
