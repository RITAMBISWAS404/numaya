import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// The member, in attendee and waitlist lists and as a host.
const String kMe = 'me';

enum EventCategory { music, food, outdoors, sport, arts, games }

/// Interests (onboarding's list) that make an event in a category "picked for you". The rule is
/// shown with the pick ("Because you like Jazz"), so the recommendation is never a black box.
const Map<EventCategory, List<String>> kCategoryInterests = {
  EventCategory.music: ['Jazz', 'Poetry'],
  EventCategory.food: ['Natural wine', 'Cooking'],
  EventCategory.outdoors: ['Travel', 'Running'],
  EventCategory.sport: ['Climbing', 'Running'],
  EventCategory.arts: ['Museums', 'Poetry', 'Film photography'],
  EventCategory.games: ['Board games'],
};

enum EventFormat { inPerson, online }

enum EventStatus { draft, published, cancelled }

/// Where an event is in time, from the app clock.
enum EventPhase { upcoming, live, past }

/// The member's place in an event.
enum Participation { none, going, waitlisted }

/// London areas the demo events are in, on a km grid (the web preview's `AREAS`). Areas outside
/// this list have no distance: the demo has no events there and says so.
const Map<String, ({double x, double y})> kEventAreaGrid = {
  'Hackney, London': (x: 0, y: 0),
  'Islington, London': (x: -3, y: 1),
  'Camden, London': (x: -5, y: 3),
  'Peckham, London': (x: 1, y: -8),
  'Brixton, London': (x: -3, y: -9),
};

/// Joining closes this long before the start (Meetup's RSVP window, here fixed).
const Duration kRegistrationCloses = Duration(hours: 2);

/// [DemoEvent.changeNote] when the member changed the time or place of their published event (the
/// UI shows its own wording for it).
const String kHostUpdatedNote = 'host-updated';

/// "Few spots left" from this many free places down.
const int kFewSpots = 2;

/// An event on Numaya. Sample events are invented (the UI says so); the member's own events are
/// kept on this device. Never contains a home address or anyone's live location.
@immutable
class DemoEvent {
  const DemoEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.hostId,
    required this.start,
    required this.duration,
    this.format = EventFormat.inPerson,
    this.venue = '',
    this.area,
    this.x = 0,
    this.y = 0,
    this.onlineNote = '',
    this.capacity,
    this.cost,
    this.question,
    this.attendees = const [],
    this.othersGoing = 0,
    this.waitlist = const [],
    this.status = EventStatus.published,
    this.cancelNote,
    this.changeNote,
    this.tone = 0,
    this.sample = true,
  });

  final String id;
  final String title;
  final EventCategory category;
  final String description;

  /// A sample person id, or [kMe].
  final String hostId;
  final DateTime start;
  final Duration duration;
  final EventFormat format;

  /// The public place the host chose ("Vortex Jazz Club, Dalston"); empty for online events.
  final String venue;

  /// The area name, one of [kEventAreaGrid]'s keys (for distance).
  final String? area;
  final double x;
  final double y;

  /// For online events: how the link is shared ("The host sends the link to people going").
  final String onlineNote;

  /// Null means no limit.
  final int? capacity;

  /// The host's note about cost ("Pay at the door, about £12"). Null means free. Numaya never
  /// takes a payment.
  final String? cost;

  /// A question the host asks people joining (Meetup's "Ask members a question").
  final String? question;

  /// Named attendees (first names shown), may include [kMe]. The host isn't in this list.
  final List<String> attendees;

  /// People going who aren't named (a count only).
  final int othersGoing;

  /// People waiting for a spot, in order; may include [kMe].
  final List<String> waitlist;
  final EventStatus status;
  final String? cancelNote;

  /// A change the host announced ("Moved to 8 pm").
  final String? changeNote;

  /// Cover colour index (no photos in the demo).
  final int tone;

  /// A sample event from the demo dataset (not the member's own).
  final bool sample;

  bool get mine => hostId == kMe;
  DateTime get end => start.add(duration);
  bool get free => cost == null || cost!.trim().isEmpty;

  /// Everyone going, the host included.
  int get goingCount => attendees.length + othersGoing + 1;

  int? get spotsLeft => capacity == null
      ? null
      : math.max(0, capacity! - (attendees.length + othersGoing));
  bool get full => spotsLeft == 0;
  bool get fewSpots =>
      spotsLeft != null && spotsLeft! > 0 && spotsLeft! <= kFewSpots;

  Participation get participation => attendees.contains(kMe)
      ? Participation.going
      : waitlist.contains(kMe)
      ? Participation.waitlisted
      : Participation.none;

  /// 1-based place on the waitlist, or null.
  int? get waitlistPosition {
    final i = waitlist.indexOf(kMe);
    return i < 0 ? null : i + 1;
  }

  EventPhase phaseAt(DateTime now) => now.isBefore(start)
      ? EventPhase.upcoming
      : now.isBefore(end)
      ? EventPhase.live
      : EventPhase.past;

  /// Joining is possible: published, not started, and not within [kRegistrationCloses].
  bool registrationOpenAt(DateTime now) =>
      status == EventStatus.published &&
      now.isBefore(start.subtract(kRegistrationCloses));

  /// Straight-line km from [area] (rounded to 0.5), or null when it can't be worked out (online,
  /// no area, or an area outside the demo's grid).
  double? distanceFrom(String? area) {
    if (format == EventFormat.online || area == null) return null;
    final from = kEventAreaGrid[area];
    if (from == null) return null;
    final d = math.sqrt(math.pow(x - from.x, 2) + math.pow(y - from.y, 2));
    return (d * 2).round() / 2;
  }

  DemoEvent copyWith({
    String? title,
    EventCategory? category,
    String? description,
    DateTime? start,
    Duration? duration,
    EventFormat? format,
    String? venue,
    String? area,
    double? x,
    double? y,
    String? onlineNote,
    int? capacity,
    bool clearCapacity = false,
    String? cost,
    bool clearCost = false,
    String? question,
    bool clearQuestion = false,
    List<String>? attendees,
    int? othersGoing,
    List<String>? waitlist,
    EventStatus? status,
    String? cancelNote,
    String? changeNote,
    bool clearChangeNote = false,
    int? tone,
  }) => DemoEvent(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    description: description ?? this.description,
    hostId: hostId,
    start: start ?? this.start,
    duration: duration ?? this.duration,
    format: format ?? this.format,
    venue: venue ?? this.venue,
    area: area ?? this.area,
    x: x ?? this.x,
    y: y ?? this.y,
    onlineNote: onlineNote ?? this.onlineNote,
    capacity: clearCapacity ? null : (capacity ?? this.capacity),
    cost: clearCost ? null : (cost ?? this.cost),
    question: clearQuestion ? null : (question ?? this.question),
    attendees: attendees ?? this.attendees,
    othersGoing: othersGoing ?? this.othersGoing,
    waitlist: waitlist ?? this.waitlist,
    status: status ?? this.status,
    cancelNote: cancelNote ?? this.cancelNote,
    changeNote: clearChangeNote ? null : (changeNote ?? this.changeNote),
    tone: tone ?? this.tone,
    sample: sample,
  );

  @override
  String toString() => 'DemoEvent($id, ${status.name})';
}

/// What a host fills in when creating or editing (validated by [EventRules]).
@immutable
class EventDraft {
  const EventDraft({
    this.title = '',
    this.category,
    this.description = '',
    this.day,
    this.startMinutes,
    this.duration = const Duration(hours: 2),
    this.format = EventFormat.inPerson,
    this.venue = '',
    this.area,
    this.onlineNote = '',
    this.capacity,
    this.cost = '',
    this.question = '',
    this.tone = 0,
  });

  factory EventDraft.of(DemoEvent e) => EventDraft(
    title: e.title,
    category: e.category,
    description: e.description,
    day: DateTime(e.start.year, e.start.month, e.start.day),
    startMinutes: e.start.hour * 60 + e.start.minute,
    duration: e.duration,
    format: e.format,
    venue: e.venue,
    area: e.area,
    onlineNote: e.onlineNote,
    capacity: e.capacity,
    cost: e.cost ?? '',
    question: e.question ?? '',
    tone: e.tone,
  );

  final String title;
  final EventCategory? category;
  final String description;
  final DateTime? day;

  /// Minutes after midnight.
  final int? startMinutes;
  final Duration duration;
  final EventFormat format;
  final String venue;
  final String? area;
  final String onlineNote;
  final int? capacity;
  final String cost;
  final String question;
  final int tone;

  DateTime? get start => day == null || startMinutes == null
      ? null
      : DateTime(
          day!.year,
          day!.month,
          day!.day,
          startMinutes! ~/ 60,
          startMinutes! % 60,
        );

  EventDraft copyWith({
    String? title,
    EventCategory? category,
    String? description,
    DateTime? day,
    int? startMinutes,
    Duration? duration,
    EventFormat? format,
    String? venue,
    String? area,
    String? onlineNote,
    int? capacity,
    bool clearCapacity = false,
    String? cost,
    String? question,
    int? tone,
  }) => EventDraft(
    title: title ?? this.title,
    category: category ?? this.category,
    description: description ?? this.description,
    day: day ?? this.day,
    startMinutes: startMinutes ?? this.startMinutes,
    duration: duration ?? this.duration,
    format: format ?? this.format,
    venue: venue ?? this.venue,
    area: area ?? this.area,
    onlineNote: onlineNote ?? this.onlineNote,
    capacity: clearCapacity ? null : (capacity ?? this.capacity),
    cost: cost ?? this.cost,
    question: question ?? this.question,
    tone: tone ?? this.tone,
  );

  @override
  bool operator ==(Object other) =>
      other is EventDraft &&
      other.title == title &&
      other.category == category &&
      other.description == description &&
      other.day == day &&
      other.startMinutes == startMinutes &&
      other.duration == duration &&
      other.format == format &&
      other.venue == venue &&
      other.area == area &&
      other.onlineNote == onlineNote &&
      other.capacity == capacity &&
      other.cost == cost &&
      other.question == question &&
      other.tone == tone;

  @override
  int get hashCode => Object.hash(
    title,
    category,
    description,
    day,
    startMinutes,
    duration,
    format,
    venue,
    area,
    onlineNote,
    capacity,
    cost,
    question,
    tone,
  );
}

enum EventProblem {
  titleMissing,
  titleTooLong,
  categoryMissing,
  descriptionMissing,
  dateMissing,
  dateInPast,
  venueMissing,
  onlineNoteMissing,
  capacityTooSmall,
  capacityBelowGoing,
}

/// Validation for creating and editing events.
abstract final class EventRules {
  static const int titleMin = 4;
  static const int titleMax = 80;
  static const int descriptionMin = 20;
  static const int descriptionMax = 1000;
  static const int questionMax = 120;
  static const int costMax = 60;
  static const int venueMax = 80;
  static const int capacityMin = 2;
  static const int capacityMax = 200;

  /// Everything wrong with [d] for publishing. A draft can be saved with only a title.
  /// [going] is how many people already joined (an edit can't set the limit below it).
  static List<EventProblem> problems(
    EventDraft d, {
    required DateTime now,
    int going = 0,
  }) => [
    if (d.title.trim().length < titleMin) EventProblem.titleMissing,
    if (d.title.trim().length > titleMax) EventProblem.titleTooLong,
    if (d.category == null) EventProblem.categoryMissing,
    if (d.description.trim().length < descriptionMin)
      EventProblem.descriptionMissing,
    if (d.start == null) EventProblem.dateMissing,
    if (d.start != null && !d.start!.isAfter(now)) EventProblem.dateInPast,
    if (d.format == EventFormat.inPerson && d.venue.trim().isEmpty)
      EventProblem.venueMissing,
    if (d.format == EventFormat.online && d.onlineNote.trim().isEmpty)
      EventProblem.onlineNoteMissing,
    if (d.capacity != null && d.capacity! < capacityMin)
      EventProblem.capacityTooSmall,
    if (d.capacity != null && d.capacity! < going)
      EventProblem.capacityBelowGoing,
  ];

  /// A draft needs a title to be saved.
  static bool canSaveDraft(EventDraft d) => d.title.trim().isNotEmpty;
}

/// A report about an event, kept on this device only (nothing is sent or reviewed).
@immutable
class EventReport {
  const EventReport({required this.eventId, required this.reason});
  final String eventId;
  final String reason;
}
