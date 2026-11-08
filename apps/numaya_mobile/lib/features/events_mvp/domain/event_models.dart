import 'package:flutter/foundation.dart';

/// Numaya Events MVP (co-founder PRD v1.0, 8 Nov 2026). Pure models and rules, clock-injected.
///
/// Kept separate on purpose (PRD §11): event content and lifecycle, reservations, attendance,
/// discoverability consent, private interests, proposals, staff actions and notices. Everything
/// here is the **demo** implementation; a live build needs server-authoritative capacity,
/// eligibility, consent and block checks, idempotent writes and server-time deadlines.
///
/// Not in scope (PRD §3): tickets, payments, waitlists, plus-ones, approval queues, attendee
/// directories, group chat, private homes, gender balancing.

enum EvCategory { coffee, games, workshop, walk, food, arts }

/// Content lifecycle. Full is derived from capacity; completed is derived from the end time.
enum EvLifecycle { draft, review, published, cancelled }

/// What a member sees for an event at a moment.
enum EvPhase { upcoming, started, completed, cancelled }

@immutable
class EvVenue {
  const EvVenue({
    required this.name,
    required this.address,
    required this.area,
    this.accessibility,
    this.transport,
  });

  final String name;
  final String address;
  final String area;

  /// Verified accessibility facts; null means unknown (never implied accessible).
  final String? accessibility;
  final String? transport;
}

/// One version of an event's material details (time and venue). A material change makes a new
/// version; reservations accepted on an older version need reconfirmation.
@immutable
class NumayaEvent {
  const NumayaEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.city,
    required this.venue,
    required this.start,
    required this.end,
    required this.capacity,
    required this.description,
    required this.hostName,
    required this.reviewerName,
    this.minAge = 18,
    this.maxAge,
    this.lifecycle = EvLifecycle.published,
    this.version = 1,
    this.cancelReason,
    this.othersReserved = 0,
    this.tone = 0,
    this.fromProposal,
  });

  final String id;
  final String title;
  final EvCategory category;
  final String city;
  final EvVenue venue;
  final DateTime start;
  final DateTime end;

  /// Places, normally 20–30 (PRD Q3A).
  final int capacity;
  final String description;

  /// Sample Numaya host and report reviewer (named staff are OPEN, D2).
  final String hostName;
  final String reviewerName;
  final int minAge;
  final int? maxAge;
  final EvLifecycle lifecycle;
  final int version;
  final String? cancelReason;

  /// Sample reservations by other members (the count only; no attendee list, Q11A).
  final int othersReserved;
  final int tone;

  /// The member proposal this event came from, if any.
  final String? fromProposal;

  /// Display timezone. The demo uses India Standard Time throughout.
  String get timezone => 'IST';

  EvPhase phaseAt(DateTime now) {
    if (lifecycle == EvLifecycle.cancelled) return EvPhase.cancelled;
    if (now.isBefore(start)) return EvPhase.upcoming;
    if (now.isBefore(end)) return EvPhase.started;
    return EvPhase.completed;
  }

  NumayaEvent copyWith({
    String? title,
    EvVenue? venue,
    DateTime? start,
    DateTime? end,
    int? capacity,
    String? description,
    EvLifecycle? lifecycle,
    int? version,
    String? cancelReason,
  }) => NumayaEvent(
    id: id,
    title: title ?? this.title,
    category: category,
    city: city,
    venue: venue ?? this.venue,
    start: start ?? this.start,
    end: end ?? this.end,
    capacity: capacity ?? this.capacity,
    description: description ?? this.description,
    hostName: hostName,
    reviewerName: reviewerName,
    minAge: minAge,
    maxAge: maxAge,
    lifecycle: lifecycle ?? this.lifecycle,
    version: version ?? this.version,
    cancelReason: cancelReason ?? this.cancelReason,
    othersReserved: othersReserved,
    tone: tone,
    fromProposal: fromProposal,
  );
}

/// Reservation status. Attendance is a separate record ([Attendance]).
enum ResStatus { confirmed, reconfirmRequired, cancelled }

enum CancelReason { member, eventCancelled, declinedChange, deadlinePassed }

@immutable
class Reservation {
  const Reservation({
    required this.eventId,
    required this.status,
    required this.acceptedVersion,
    required this.createdAt,
    required this.reference,
    this.cancelReason,
    this.cancelledAt,
    this.discoverable = false,
  });

  final String eventId;
  final ResStatus status;

  /// The event version the member last agreed to.
  final int acceptedVersion;
  final DateTime createdAt;

  /// A booking reference, not a ticket.
  final String reference;
  final CancelReason? cancelReason;
  final DateTime? cancelledAt;

  /// Optional post-event discoverability (E03/E05/E07): separate from the reservation, default off.
  final bool discoverable;

  bool get active => status != ResStatus.cancelled;

  Reservation copyWith({
    ResStatus? status,
    int? acceptedVersion,
    CancelReason? cancelReason,
    DateTime? cancelledAt,
    bool? discoverable,
  }) => Reservation(
    eventId: eventId,
    status: status ?? this.status,
    acceptedVersion: acceptedVersion ?? this.acceptedVersion,
    createdAt: createdAt,
    reference: reference,
    cancelReason: cancelReason ?? this.cancelReason,
    cancelledAt: cancelledAt ?? this.cancelledAt,
    discoverable: discoverable ?? this.discoverable,
  );
}

/// Recorded by the Numaya host (H03). Not identity verification.
enum Attendance { notRecorded, checkedIn, noShow }

/// A notice about an event (E06). Material changes need a response by [deadline].
enum NoticeKind { ordinary, material, cancellation }

enum NoticeResponse { none, acknowledged, reconfirmed, declined }

@immutable
class EvNotice {
  const EvNotice({
    required this.id,
    required this.eventId,
    required this.kind,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.sender,
    this.forVersion,
    this.before,
    this.after,
    this.deadline,
    this.read = false,
    this.response = NoticeResponse.none,
    this.pushFailed = false,
  });

  final String id;
  final String eventId;
  final NoticeKind kind;
  final String title;
  final String body;
  final DateTime sentAt;

  /// Verified sender, e.g. "Numaya events team".
  final String sender;

  /// The event version a material change created.
  final int? forVersion;
  final String? before;
  final String? after;
  final DateTime? deadline;
  final bool read;
  final NoticeResponse response;

  /// Simulated push delivery failed; the in-app notice persists regardless.
  final bool pushFailed;

  EvNotice copyWith({bool? read, NoticeResponse? response}) => EvNotice(
    id: id,
    eventId: eventId,
    kind: kind,
    title: title,
    body: body,
    sentAt: sentAt,
    sender: sender,
    forVersion: forVersion,
    before: before,
    after: after,
    deadline: deadline,
    read: read ?? this.read,
    response: response ?? this.response,
    pushFailed: pushFailed,
  );
}

/// Member proposal (M01/M02): the PRD's recommended reconciliation of O1, shown as a proposal.
enum ProposalStatus {
  draft,
  submitted,
  inReview,
  needsChanges,
  rejected,
  withdrawn,
  published,
}

@immutable
class EvProposal {
  const EvProposal({
    required this.id,
    required this.title,
    required this.category,
    required this.city,
    required this.venueName,
    required this.description,
    required this.start,
    required this.capacity,
    required this.status,
    this.reviewNote,
    this.submittedAt,
    this.publishedEventId,
    this.privateHome = false,
  });

  final String id;
  final String title;
  final EvCategory category;
  final String city;
  final String venueName;
  final String description;
  final DateTime start;
  final int capacity;
  final ProposalStatus status;
  final String? reviewNote;
  final DateTime? submittedAt;
  final String? publishedEventId;

  /// Private homes can never be published (Q12A).
  final bool privateHome;

  EvProposal copyWith({
    String? title,
    EvCategory? category,
    String? city,
    String? venueName,
    String? description,
    DateTime? start,
    int? capacity,
    ProposalStatus? status,
    String? reviewNote,
    DateTime? submittedAt,
    String? publishedEventId,
    bool? privateHome,
  }) => EvProposal(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    city: city ?? this.city,
    venueName: venueName ?? this.venueName,
    description: description ?? this.description,
    start: start ?? this.start,
    capacity: capacity ?? this.capacity,
    status: status ?? this.status,
    reviewNote: reviewNote ?? this.reviewNote,
    submittedAt: submittedAt ?? this.submittedAt,
    publishedEventId: publishedEventId ?? this.publishedEventId,
    privateHome: privateHome ?? this.privateHome,
  );
}

/// Policy numbers (PRD §7–§8; "recommended" defaults are marked in the PRD, not founder-selected).
abstract final class EvPolicy {
  static const int interestsPerEvent = 3;
  static const Duration followUpWindow = Duration(days: 7);

  /// Material change deadline: the earlier of 24 h after the change and 2 h before the new start.
  static DateTime? reconfirmDeadline(DateTime changedAt, DateTime newStart) {
    final a = changedAt.add(const Duration(hours: 24));
    final b = newStart.subtract(const Duration(hours: 2));
    final d = a.isBefore(b) ? a : b;
    // Under two hours to respond: no automatic expiry; staff must reschedule or cancel.
    if (d.difference(changedAt) < const Duration(hours: 2)) return null;
    return d;
  }

  /// The People I met window: from the scheduled end, exactly seven days.
  static bool followUpOpen(NumayaEvent e, DateTime now) =>
      e.phaseAt(now) == EvPhase.completed &&
      now.isBefore(e.end.add(followUpWindow));
}

/// What happened when the member tried to reserve (E03).
enum ReserveResult {
  confirmed,
  alreadyReserved,
  full,
  ineligible,
  closed,
  cancelled,
  uncertain,
  error,
}

/// Why a member cannot reserve.
enum Ineligibility {
  underAge,
  profileIncomplete,
  phoneUnverified,
  ageOutsideEvent,
}
