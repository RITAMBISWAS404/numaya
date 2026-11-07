import 'package:flutter/foundation.dart';

import '../../commerce/domain/catalog.dart';

/// Match and conversation lifecycle (Visual Lab V2, R01/R02; supersedes PRD 02's 14-day expiry
/// and reconnection):
///
///     awaiting_first_message -> active <-> archived
///     awaiting_first_message -> expired           (no first message in time; terminal, no reconnect)
///     blocked / unmatched terminate.
///
/// - A new match expires 24 hours after it was made unless someone sends a first message; either
///   person may start. One extension (24 hours more) per match. An expired initial match shows a
///   simple expired state: there is no reconnection (VL-D02, conservative reading of R02).
/// - A started conversation never expires. After [AllowancePolicy.archiveAfterDays] days without a
///   genuine accepted message it moves to Archive. Either person may still send; an accepted send
///   makes it active again for both. History, mute and safety controls stay. System notices do not
///   count as messages, so they never reset the quiet clock.
/// - Deadlines are evaluated on every read and write, so a delayed job never extends a match.
enum MatchPhase {
  awaitingFirstMessage,
  active,
  archived,
  expired,
  blocked,
  unmatched,
}

/// Everything the phase depends on, for one pair.
@immutable
class MatchTimeline {
  const MatchTimeline({
    required this.matchedAt,
    this.extendedUntil,
    this.firstMessageAt,
    this.lastMessageAt,
    this.ended,
  });

  final DateTime matchedAt;

  /// The extended first-message deadline, when the one extension was used.
  final DateTime? extendedUntil;

  /// First and latest genuine accepted messages (failed or queued sends do not count).
  final DateTime? firstMessageAt;
  final DateTime? lastMessageAt;

  /// Terminal state, if any.
  final MatchPhase? ended;
}

@immutable
class MatchStatus {
  const MatchStatus({
    required this.phase,
    this.deadline,
    this.windowStart,
    this.expiredAt,
    this.archivedAt,
  });

  final MatchPhase phase;

  /// The first-message deadline (awaiting only).
  final DateTime? deadline;

  /// When the current first-message window began (the match), for the progress ring's fraction.
  final DateTime? windowStart;

  /// When an initial match ran out without a first message.
  final DateTime? expiredAt;

  /// When a quiet conversation moved to Archive.
  final DateTime? archivedAt;

  /// Archived conversations accept messages; sending makes them active again.
  bool get canSend =>
      phase == MatchPhase.awaitingFirstMessage ||
      phase == MatchPhase.active ||
      phase == MatchPhase.archived;

  bool get isExpired => phase == MatchPhase.expired;

  bool get isArchived => phase == MatchPhase.archived;

  /// Fraction of the (possibly extended) first-message window left, 0–1, at [now].
  double remainingFraction(DateTime now) {
    final d = deadline, s = windowStart;
    if (d == null || s == null) return 0;
    final total = d.difference(s).inSeconds;
    if (total <= 0) return 0;
    return (d.difference(now).inSeconds / total).clamp(0.0, 1.0);
  }
}

MatchStatus matchStatus(MatchTimeline t, DateTime now, AllowancePolicy p) {
  if (t.ended != null) return MatchStatus(phase: t.ended!);
  final last = t.lastMessageAt;
  if (t.firstMessageAt == null || last == null) {
    final deadline =
        t.extendedUntil ?? t.matchedAt.add(Duration(hours: p.matchWindowHours));
    if (now.isBefore(deadline)) {
      return MatchStatus(
        phase: MatchPhase.awaitingFirstMessage,
        deadline: deadline,
        windowStart: t.matchedAt,
      );
    }
    return MatchStatus(phase: MatchPhase.expired, expiredAt: deadline);
  }
  final archiveAt = last.add(Duration(days: p.archiveAfterDays));
  if (!now.isBefore(archiveAt)) {
    return MatchStatus(phase: MatchPhase.archived, archivedAt: archiveAt);
  }
  return const MatchStatus(phase: MatchPhase.active);
}
