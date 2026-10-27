import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../home/application/discovery_filters.dart';
import '../domain/sample_people.dart';

enum EndReason { unmatched, blocked, reported }

enum MessageStatus { sending, onDevice, failed }

/// A message written by the member. There are no incoming messages: the demo never invents replies.
@immutable
class DemoMessage {
  const DemoMessage({
    required this.id,
    required this.text,
    required this.status,
  });
  final int id;
  final String text;
  final MessageStatus status;

  DemoMessage withStatus(MessageStatus s) =>
      DemoMessage(id: id, text: text, status: s);

  @override
  String toString() => 'DemoMessage($id, ${status.name})';
}

/// A report kept on this device only (nothing is sent or reviewed).
@immutable
class DemoReport {
  const DemoReport({
    required this.personId,
    required this.reason,
    required this.blocked,
  });
  final String personId;
  final String reason;
  final bool blocked;
}

enum LikeFilter { all, newLikes, nearby }

/// Session state of the dating demo, ported from the web preview's reducer (src/flows/store.js).
@immutable
class DatingState {
  const DatingState({
    this.seen = const {},
    this.matches = const [],
    this.lastPass,
    this.likesHandled = const {},
    this.threads = const {},
    this.openedMatches = const {},
    this.ended = const {},
    this.reports = const [],
    this.snoozed = false,
    this.simulateErrors = false,
  });

  /// Sample profiles already liked or passed in Discover.
  final Set<String> seen;

  /// Matched people, newest last.
  final List<String> matches;

  /// The last person passed in Discover, for one-step undo.
  final String? lastPass;

  /// Likes the member answered: person → liked (true) or passed (false).
  final Map<String, bool> likesHandled;

  /// The member's messages per match.
  final Map<String, List<DemoMessage>> threads;

  /// New matches whose conversation has been opened.
  final Set<String> openedMatches;
  final Map<String, EndReason> ended;
  final List<DemoReport> reports;

  /// Snooze: Home is paused (B-71).
  final bool snoozed;

  /// Prototype tool: make loading and sending fail, to show the error states.
  final bool simulateErrors;

  bool isActive(String id) => !ended.containsKey(id);

  DatingState copyWith({
    Set<String>? seen,
    List<String>? matches,
    String? lastPass,
    bool clearLastPass = false,
    Map<String, bool>? likesHandled,
    Map<String, List<DemoMessage>>? threads,
    Set<String>? openedMatches,
    Map<String, EndReason>? ended,
    List<DemoReport>? reports,
    bool? snoozed,
    bool? simulateErrors,
  }) {
    return DatingState(
      seen: seen ?? this.seen,
      matches: matches ?? this.matches,
      lastPass: clearLastPass ? null : (lastPass ?? this.lastPass),
      likesHandled: likesHandled ?? this.likesHandled,
      threads: threads ?? this.threads,
      openedMatches: openedMatches ?? this.openedMatches,
      ended: ended ?? this.ended,
      reports: reports ?? this.reports,
      snoozed: snoozed ?? this.snoozed,
      simulateErrors: simulateErrors ?? this.simulateErrors,
    );
  }
}

/// What a decision in Discover or Likes led to.
enum DecisionResult { liked, passed, matched }

/// View model for the dating demo: Discover, Likes, matches, conversations and safety actions.
/// Everything is local and in memory; the UI labels it as sample data.
class DatingController extends Notifier<DatingState> {
  static const _log = AppLogger('Dating');
  int _messageIds = 0;

  @override
  DatingState build() => const DatingState();

  // Discover -------------------------------------------------------------------------------
  bool _fits(DiscoveryFilters? f, SamplePerson p) =>
      f == null ||
      (p.age >= f.minAge &&
          p.age <= f.maxAge &&
          p.distanceKm <= f.maxDistanceKm);

  /// Everyone who could appear in Discover: has a prompt, undecided, not matched, not ended.
  List<SamplePerson> _candidates() => [
    for (final p in kSamplePeople)
      if (p.prompt != null &&
          !state.seen.contains(p.id) &&
          !state.matches.contains(p.id) &&
          state.isActive(p.id))
        p,
  ];

  /// The Discover queue under [filters] (defaults to the saved filters).
  List<SamplePerson> queue([DiscoveryFilters? filters]) {
    final f = filters ?? ref.read(discoveryFiltersProvider);
    return [
      for (final p in _candidates())
        if (_fits(f, p)) p,
    ];
  }

  /// Candidates hidden only by the filters (for "No one fits your filters").
  int hiddenByFilters() => _candidates().length - queue().length;

  /// Like or pass someone in Discover. Liking someone who liked you is a match.
  DecisionResult decide(String id, {required bool liked}) {
    final person = personById(id);
    if (person == null) return DecisionResult.passed;
    final isMatch = liked && person.likesYou && !state.matches.contains(id);
    state = state.copyWith(
      seen: {...state.seen, id},
      lastPass: liked ? null : id,
      clearLastPass: liked,
      likesHandled: liked && person.likesYou
          ? {...state.likesHandled, id: true}
          : null,
      matches: isMatch ? [...state.matches, id] : null,
    );
    _log.info('Decision recorded (${liked ? 'like' : 'pass'})');
    return isMatch
        ? DecisionResult.matched
        : liked
        ? DecisionResult.liked
        : DecisionResult.passed;
  }

  /// Bring back the last person passed.
  void undo() {
    final id = state.lastPass;
    if (id == null) return;
    state = state.copyWith(
      seen: {...state.seen}..remove(id),
      clearLastPass: true,
    );
  }

  /// "Show them again": everyone passed comes back around.
  void resetDiscovery() =>
      state = state.copyWith(seen: {}, clearLastPass: true);

  // Likes -----------------------------------------------------------------------------------
  List<({SamplePerson person, bool isNew, bool matched})> likes([
    LikeFilter filter = LikeFilter.all,
  ]) {
    final out = <({SamplePerson person, bool isNew, bool matched})>[];
    for (final like in kSampleLikes) {
      final p = personById(like.person);
      if (p == null ||
          !state.isActive(p.id) ||
          state.likesHandled[p.id] == false) {
        continue;
      }
      final isNew =
          like.hoursAgo < kNewLikeHours && !state.matches.contains(p.id);
      final row = (
        person: p,
        isNew: isNew,
        matched: state.matches.contains(p.id),
      );
      final keep = switch (filter) {
        LikeFilter.all => true,
        LikeFilter.newLikes => isNew,
        LikeFilter.nearby => p.distanceKm <= kNearbyKm,
      };
      if (keep) out.add(row);
    }
    return out;
  }

  /// Likes not yet answered (the tab badge).
  int unansweredLikes() => likes()
      .where((l) => !l.matched && !state.likesHandled.containsKey(l.person.id))
      .length;

  DecisionResult likeBack(String id, {required bool liked}) {
    final handled = {...state.likesHandled, id: liked};
    final seen = {...state.seen, id};
    if (!liked) {
      state = state.copyWith(likesHandled: handled, seen: seen);
      return DecisionResult.passed;
    }
    final matches = state.matches.contains(id)
        ? state.matches
        : [...state.matches, id];
    state = state.copyWith(likesHandled: handled, seen: seen, matches: matches);
    return DecisionResult.matched;
  }

  // Messages --------------------------------------------------------------------------------
  /// Active matches with no messages yet, newest first.
  List<SamplePerson> newMatches() => [
    for (final id in state.matches.reversed)
      if (state.isActive(id) && (state.threads[id]?.isEmpty ?? true))
        personById(id)!,
  ];

  /// Active matches with messages, most recent first.
  List<SamplePerson> conversations() => [
    for (final id in state.matches.reversed)
      if (state.isActive(id) && (state.threads[id]?.isNotEmpty ?? false))
        personById(id)!,
  ];

  /// New matches not opened yet (the tab badge).
  int unopenedMatches() =>
      newMatches().where((p) => !state.openedMatches.contains(p.id)).length;

  void openChat(String id) =>
      state = state.copyWith(openedMatches: {...state.openedMatches, id});

  /// Adds a message to the thread. It stays on this device ([MessageStatus.onDevice]); with the
  /// "simulate connection problems" tool on, it fails so the retry path can be tried.
  Future<void> send(String id, String text) async {
    final body = text.trim();
    if (body.isEmpty || !state.isActive(id)) return;
    final message = DemoMessage(
      id: ++_messageIds,
      text: body,
      status: MessageStatus.sending,
    );
    _put(id, message);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!ref.mounted) return;
    _put(
      id,
      message.withStatus(
        state.simulateErrors ? MessageStatus.failed : MessageStatus.onDevice,
      ),
    );
  }

  Future<void> retry(String id, int messageId) async {
    final message = state.threads[id]?.firstWhere((m) => m.id == messageId);
    if (message == null) return;
    _put(id, message.withStatus(MessageStatus.sending));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!ref.mounted) return;
    _put(
      id,
      message.withStatus(
        state.simulateErrors ? MessageStatus.failed : MessageStatus.onDevice,
      ),
    );
  }

  void deleteMessage(String id, int messageId) {
    final thread = [...?state.threads[id]]
      ..removeWhere((m) => m.id == messageId);
    state = state.copyWith(threads: {...state.threads, id: thread});
  }

  void _put(String id, DemoMessage message) {
    final thread = [...?state.threads[id]];
    final i = thread.indexWhere((m) => m.id == message.id);
    if (i < 0) {
      thread.add(message);
    } else {
      thread[i] = message;
    }
    state = state.copyWith(
      threads: {...state.threads, id: thread},
      openedMatches: {...state.openedMatches, id},
    );
  }

  // Safety ----------------------------------------------------------------------------------
  void end(String id, EndReason reason) {
    state = state.copyWith(
      ended: {...state.ended, id: reason},
      clearLastPass: state.lastPass == id,
    );
    _log.info('Conversation ended (${reason.name})');
  }

  /// Saves a report on this device. Reporting with "also block" blocks the person (D-13).
  void report(String id, String reason, {required bool block}) {
    state = state.copyWith(
      reports: [
        ...state.reports,
        DemoReport(personId: id, reason: reason, blocked: block),
      ],
      ended: block ? {...state.ended, id: EndReason.reported} : null,
    );
  }

  /// People blocked or reported-and-blocked (Settings › Blocked people).
  List<SamplePerson> blocked() => [
    for (final e in state.ended.entries)
      if (e.value != EndReason.unmatched) personById(e.key)!,
  ];

  /// Unblocking never restores a match or messages (as in the web preview).
  void unblock(String id) {
    final ended = {...state.ended}..remove(id);
    final threads = {...state.threads}..remove(id);
    state = state.copyWith(
      ended: ended,
      threads: threads,
      matches: [...state.matches]..remove(id),
    );
  }

  // Settings --------------------------------------------------------------------------------
  void setSnoozed(bool value) => state = state.copyWith(snoozed: value);

  void setSimulateErrors(bool value) =>
      state = state.copyWith(simulateErrors: value);
}

final datingProvider = NotifierProvider<DatingController, DatingState>(
  DatingController.new,
);
