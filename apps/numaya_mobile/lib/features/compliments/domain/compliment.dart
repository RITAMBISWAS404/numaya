import 'package:flutter/foundation.dart';

/// Compliments (PRD 01/02): a contextual introduction of up to 150 characters on one photo or one
/// prompt answer, sent before a match.
///
/// - One lifetime introduction per unordered pair (MVP): no retry after dismissal, and the sender
///   cannot send again until the recipient replies (which opens a conversation anyway).
/// - It costs one credit, spent only when the server accepts the send; a technical failure refunds
///   it, a dismissal does not.
/// - The recipient sees it in Chats › Requests and may reply (free; the reply opens a reciprocal
///   conversation atomically), dismiss, block or report. Pending requests do not expire in MVP.
/// - A deleted photo or prompt shows as an unavailable reference; edits never retarget it.
/// - If the pair become a mutual match while it is pending, it becomes the first message of that
///   same conversation (never a duplicate).
enum ComplimentTargetKind { photo, prompt }

@immutable
class ComplimentTarget {
  const ComplimentTarget.photo(this.index) : kind = ComplimentTargetKind.photo;
  const ComplimentTarget.prompt(this.index)
    : kind = ComplimentTargetKind.prompt;

  final ComplimentTargetKind kind;

  /// Photo position (0-based) or prompt position (0-based) on the profile when it was sent.
  final int index;

  @override
  bool operator ==(Object other) =>
      other is ComplimentTarget && other.kind == kind && other.index == index;

  @override
  int get hashCode => Object.hash(kind, index);
}

enum ComplimentStatus { pending, replied, dismissed, converted, blocked }

@immutable
class Compliment {
  const Compliment({
    required this.id,
    required this.personId,
    required this.fromMe,
    required this.target,
    required this.text,
    required this.sentAt,
    this.referenceText,
    this.referenceAvailable = true,
    this.status = ComplimentStatus.pending,
  });

  final String id;

  /// The other person in the pair.
  final String personId;
  final bool fromMe;
  final ComplimentTarget target;
  final String text;
  final DateTime sentAt;

  /// The prompt question and answer quoted with it (null for photos).
  final String? referenceText;

  /// False once the referenced photo or prompt has been removed.
  final bool referenceAvailable;
  final ComplimentStatus status;

  Compliment withStatus(ComplimentStatus s) => Compliment(
    id: id,
    personId: personId,
    fromMe: fromMe,
    target: target,
    text: text,
    sentAt: sentAt,
    referenceText: referenceText,
    referenceAvailable: referenceAvailable,
    status: s,
  );

  @override
  String toString() => 'Compliment($id ${status.name})';
}

enum ComplimentProblem { empty, tooLong }

ComplimentProblem? complimentProblem(String text, int maxLength) {
  final t = text.trim();
  if (t.isEmpty) return ComplimentProblem.empty;
  if (t.runes.length > maxLength) return ComplimentProblem.tooLong;
  return null;
}

/// Why a compliment cannot be sent to [personId] (null: it can).
enum ComplimentBlock { alreadySent, alreadyReceived, connected, unavailable }

ComplimentBlock? complimentBlock(
  Iterable<Compliment> all,
  String personId, {
  required bool connected,
  required bool available,
}) {
  if (!available) return ComplimentBlock.unavailable;
  if (connected) return ComplimentBlock.connected;
  for (final c in all.where((c) => c.personId == personId)) {
    return c.fromMe
        ? ComplimentBlock.alreadySent
        : ComplimentBlock.alreadyReceived;
  }
  return null;
}
