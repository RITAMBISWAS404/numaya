import 'package:flutter/foundation.dart';

import '../../commerce/domain/catalog.dart';

/// Match and conversation lifecycle (PRD 02):
///
///     awaiting_first_message -> active -> expired -> reconnect_pending -> active
///     blocked / unmatched terminate.
///
/// - A new match expires 24 hours after it was made unless someone sends a first message; either
///   person may start. One extension (24 hours more) per match.
/// - In a conversation, any genuine accepted message resets the quiet clock; system notices do not.
///   After 7 quiet days both people get a check-in once; after 14 the chat expires. History is kept
///   and sending is disabled.
/// - After any expiry either person may ask to reconnect once per expiry episode; the other must
///   accept. Acceptance reopens the chat with no automatic message and no charge. A declined request
///   cannot be repeated in that episode. Unmatch and block are terminal and never reconnect.
/// - Deadlines are evaluated on every read and write, so a delayed job never extends a match.
enum MatchPhase {
  awaitingFirstMessage,
  active,
  expired,
  reconnectPending,
  blocked,
  unmatched,
}

enum ExpiryKind { noFirstMessage, quiet }

enum ReconnectStatus { pending, accepted, declined }

@immutable
class ReconnectRequest {
  const ReconnectRequest({
    required this.fromMe,
    required this.at,
    required this.episode,
    this.status = ReconnectStatus.pending,
  });

  final bool fromMe;
  final DateTime at;

  /// The expiry this request answers (the instant the chat expired).
  final DateTime episode;
  final ReconnectStatus status;

  ReconnectRequest withStatus(ReconnectStatus s) =>
      ReconnectRequest(fromMe: fromMe, at: at, episode: episode, status: s);
}

/// Everything the phase depends on, for one pair.
@immutable
class MatchTimeline {
  const MatchTimeline({
    required this.matchedAt,
    this.extendedUntil,
    this.firstMessageAt,
    this.lastMessageAt,
    this.reopenedAt,
    this.reconnect,
    this.ended,
  });

  final DateTime matchedAt;

  /// The extended first-message deadline, when the one extension was used.
  final DateTime? extendedUntil;

  /// First and latest genuine accepted messages (failed or queued sends do not count).
  final DateTime? firstMessageAt;
  final DateTime? lastMessageAt;

  /// When an accepted reconnection reopened the chat.
  final DateTime? reopenedAt;
  final ReconnectRequest? reconnect;

  /// Terminal state, if any.
  final MatchPhase? ended;
}

@immutable
class MatchStatus {
  const MatchStatus({
    required this.phase,
    this.deadline,
    this.expiredAt,
    this.expiryKind,
    this.checkInDue = false,
    this.quietSince,
  });

  final MatchPhase phase;

  /// When the current phase ends on its own (first-message deadline or quiet expiry).
  final DateTime? deadline;
  final DateTime? expiredAt;
  final ExpiryKind? expiryKind;

  /// Seven quiet days have passed in an active conversation.
  final bool checkInDue;

  /// The start of the current quiet period.
  final DateTime? quietSince;

  bool get canSend =>
      phase == MatchPhase.awaitingFirstMessage || phase == MatchPhase.active;

  bool get isExpired =>
      phase == MatchPhase.expired || phase == MatchPhase.reconnectPending;
}

MatchStatus matchStatus(MatchTimeline t, DateTime now, AllowancePolicy p) {
  if (t.ended != null) return MatchStatus(phase: t.ended!);
  final reopened = t.reopenedAt;
  final messagedSinceReopen =
      t.lastMessageAt != null &&
      (reopened == null || !t.lastMessageAt!.isBefore(reopened));
  // Never messaged (and not reopened): the first-message window.
  if (t.firstMessageAt == null && reopened == null) {
    final deadline =
        t.extendedUntil ?? t.matchedAt.add(Duration(hours: p.matchWindowHours));
    if (now.isBefore(deadline)) {
      return MatchStatus(
        phase: MatchPhase.awaitingFirstMessage,
        deadline: deadline,
      );
    }
    return _expired(t, deadline, ExpiryKind.noFirstMessage);
  }
  final quietSince = messagedSinceReopen ? t.lastMessageAt! : reopened!;
  final expiry = quietSince.add(Duration(days: p.quietExpiryDays));
  if (!now.isBefore(expiry)) return _expired(t, expiry, ExpiryKind.quiet);
  return MatchStatus(
    phase: MatchPhase.active,
    deadline: expiry,
    quietSince: quietSince,
    checkInDue: !now.isBefore(
      quietSince.add(Duration(days: p.quietCheckInDays)),
    ),
  );
}

MatchStatus _expired(MatchTimeline t, DateTime at, ExpiryKind kind) {
  final r = t.reconnect;
  final pending =
      r != null && r.episode == at && r.status == ReconnectStatus.pending;
  return MatchStatus(
    phase: pending ? MatchPhase.reconnectPending : MatchPhase.expired,
    expiredAt: at,
    expiryKind: kind,
  );
}

/// Whether a reconnection may be requested now (one request per pair per expiry episode).
bool canRequestReconnect(MatchTimeline t, MatchStatus s) {
  if (s.phase != MatchPhase.expired) return false;
  final r = t.reconnect;
  return r == null || r.episode != s.expiredAt;
}
