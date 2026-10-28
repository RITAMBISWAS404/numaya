import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/logging/app_logger.dart';
import '../../home/application/discovery_filters.dart';
import '../../premium/application/premium_controller.dart';
import '../domain/sample_people.dart';

enum EndReason { unmatched, blocked, reported }

enum MessageStatus { sending, onDevice, failed }

/// Which sample world the demo starts in.
enum DemoWorld {
  /// A brand-new account: seven profiles, five likes, no matches.
  fresh,

  /// The explorable demo: a larger deck, seeded matches (some about to expire, one expired) and
  /// sample conversations.
  full,
}

/// The app starts in the full world in demo builds; tests pick their world explicitly.
class DemoWorldController extends Notifier<DemoWorld> {
  @override
  DemoWorld build() =>
      AppConfig.demoAuthAllowed ? DemoWorld.full : DemoWorld.fresh;

  void set(DemoWorld world) => state = world;
}

final demoWorldProvider = NotifierProvider<DemoWorldController, DemoWorld>(
  DemoWorldController.new,
);

/// A message in a conversation. [mine] messages were written by the member on this device and are
/// never delivered. Other messages exist only in seeded sample conversations ([sample]); the demo
/// never invents a reply to something the member writes.
@immutable
class DemoMessage {
  const DemoMessage({
    required this.id,
    required this.text,
    required this.status,
    required this.at,
    this.mine = true,
    this.sample = false,
  });
  final int id;
  final String text;
  final MessageStatus status;
  final DateTime at;
  final bool mine;
  final bool sample;

  DemoMessage withStatus(MessageStatus s) => DemoMessage(
    id: id,
    text: text,
    status: s,
    at: at,
    mine: mine,
    sample: sample,
  );

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
    this.part,
    this.details = '',
  });
  final String personId;
  final String reason;
  final bool blocked;

  /// Which part of the profile or chat (B-51), when the reason asks.
  final String? part;
  final String details;
}

enum LikeFilter { all, newLikes, nearby }

/// Session state of the dating demo, ported from the web preview's reducer (src/flows/store.js)
/// and extended with the full world.
@immutable
class DatingState {
  const DatingState({
    this.seen = const {},
    this.liked = const {},
    this.matches = const [],
    this.lastPass,
    this.front,
    this.coachDone = false,
    this.likesHandled = const {},
    this.threads = const {},
    this.openedMatches = const {},
    this.ended = const {},
    this.reports = const [],
    this.snoozed = false,
    this.simulateErrors = false,
    this.matchedAt = const {},
    this.extendedUntil = const {},
    this.lastRead = const {},
    this.freeExtendUsedOn,
    this.superSwipes = 3,
    this.superSwiped = const {},
    this.dateFeedback = const {},
    this.unmatchReasons = const {},
    this.nextMessageId = 1,
  });

  /// Sample profiles already liked or passed in Discover.
  final Set<String> seen;

  /// The people in [seen] who were liked (or SuperSwiped). A like is sent, so they never come back
  /// round when the passed people are shown again.
  final Set<String> liked;

  /// Someone brought back by Undo: shown first, wherever they sit in the deck.
  final String? front;

  /// The swipe hint on the first card has been read or acted on (B-31).
  final bool coachDone;

  /// Matched people, newest last.
  final List<String> matches;

  /// The last person passed in Discover, for one-step undo.
  final String? lastPass;

  /// Likes the member answered: person → liked (true) or passed (false).
  final Map<String, bool> likesHandled;

  /// Messages per match, oldest first.
  final Map<String, List<DemoMessage>> threads;

  /// New matches whose conversation has been opened.
  final Set<String> openedMatches;
  final Map<String, EndReason> ended;
  final List<DemoReport> reports;

  /// Snooze: Home is paused (B-71).
  final bool snoozed;

  /// Prototype tool: make loading and sending fail, to show the error states.
  final bool simulateErrors;

  final Map<String, DateTime> matchedAt;

  /// Extend (B-47): a new expiry for a match.
  final Map<String, DateTime> extendedUntil;

  /// When each conversation was last opened, for unread counts.
  final Map<String, DateTime> lastRead;

  /// The day the free daily Extend was used.
  final DateTime? freeExtendUsedOn;

  /// Free SuperSwipes left (premium adds more).
  final int superSwipes;
  final Set<String> superSwiped;

  /// "Did you meet?" answers (B-55).
  final Map<String, bool> dateFeedback;

  /// Optional reasons after unmatching (B-54), kept on this device.
  final Map<String, String> unmatchReasons;
  final int nextMessageId;

  bool isActive(String id) => !ended.containsKey(id);

  DatingState copyWith({
    Set<String>? seen,
    Set<String>? liked,
    List<String>? matches,
    String? lastPass,
    bool clearLastPass = false,
    String? front,
    bool clearFront = false,
    bool? coachDone,
    Map<String, bool>? likesHandled,
    Map<String, List<DemoMessage>>? threads,
    Set<String>? openedMatches,
    Map<String, EndReason>? ended,
    List<DemoReport>? reports,
    bool? snoozed,
    bool? simulateErrors,
    Map<String, DateTime>? matchedAt,
    Map<String, DateTime>? extendedUntil,
    Map<String, DateTime>? lastRead,
    DateTime? freeExtendUsedOn,
    int? superSwipes,
    Set<String>? superSwiped,
    Map<String, bool>? dateFeedback,
    Map<String, String>? unmatchReasons,
    int? nextMessageId,
  }) {
    return DatingState(
      seen: seen ?? this.seen,
      liked: liked ?? this.liked,
      matches: matches ?? this.matches,
      lastPass: clearLastPass ? null : (lastPass ?? this.lastPass),
      front: clearFront ? null : (front ?? this.front),
      coachDone: coachDone ?? this.coachDone,
      likesHandled: likesHandled ?? this.likesHandled,
      threads: threads ?? this.threads,
      openedMatches: openedMatches ?? this.openedMatches,
      ended: ended ?? this.ended,
      reports: reports ?? this.reports,
      snoozed: snoozed ?? this.snoozed,
      simulateErrors: simulateErrors ?? this.simulateErrors,
      matchedAt: matchedAt ?? this.matchedAt,
      extendedUntil: extendedUntil ?? this.extendedUntil,
      lastRead: lastRead ?? this.lastRead,
      freeExtendUsedOn: freeExtendUsedOn ?? this.freeExtendUsedOn,
      superSwipes: superSwipes ?? this.superSwipes,
      superSwiped: superSwiped ?? this.superSwiped,
      dateFeedback: dateFeedback ?? this.dateFeedback,
      unmatchReasons: unmatchReasons ?? this.unmatchReasons,
      nextMessageId: nextMessageId ?? this.nextMessageId,
    );
  }
}

/// What a decision in Discover or Likes led to.
enum DecisionResult { liked, passed, matched }

/// What happened when the member tried to extend or rematch.
enum ExtendResult { extended, needsPremium, notNeeded }

/// A new match in the queue (B-42): time left before it expires.
@immutable
class QueuedMatch {
  const QueuedMatch(this.person, this.remaining);
  final SamplePerson person;
  final Duration remaining;

  /// Fraction of the window left, for the countdown ring.
  double get fraction =>
      (remaining.inMinutes / (kMatchWindowHours * 60)).clamp(0.0, 1.0);
}

/// View model for the dating demo: Discover, Likes, matches, conversations and safety actions.
/// Everything is local and in memory; the UI labels it as sample data.
class DatingController extends Notifier<DatingState> {
  static const _log = AppLogger('Dating');

  DateTime get _now => ref.read(clockProvider)();

  DemoWorld get world => ref.read(demoWorldProvider);

  @override
  DatingState build() {
    final world = ref.watch(demoWorldProvider);
    if (world == DemoWorld.fresh) return const DatingState();
    return _seed(ref.read(clockProvider)());
  }

  static DatingState _seed(DateTime now) {
    final threads = <String, List<DemoMessage>>{};
    final matchedAt = <String, DateTime>{};
    final lastRead = <String, DateTime>{};
    var id = 1;
    for (final m in kSeedMatches) {
      matchedAt[m.person] = now.subtract(Duration(hours: m.hoursAgo));
      if (m.messages.isEmpty) continue;
      threads[m.person] = [
        for (final s in m.messages)
          DemoMessage(
            id: id++,
            text: s.text,
            status: MessageStatus.onDevice,
            at: now.subtract(Duration(minutes: s.minutesAgo)),
            mine: s.mine,
            sample: true,
          ),
      ];
      // Priya's latest messages are unread; the others have been read.
      if (m.person != 'priya') lastRead[m.person] = now;
    }
    return DatingState(
      matches: [for (final m in kSeedMatches) m.person],
      matchedAt: matchedAt,
      threads: threads,
      lastRead: lastRead,
      openedMatches: {'lina'},
      nextMessageId: id,
    );
  }

  /// Every profile that can appear in Discover in this world.
  List<SamplePerson> get deck => world == DemoWorld.full
      ? [...kSamplePeople, ...kExtraPeople]
      : kSamplePeople;

  // Discover -------------------------------------------------------------------------------
  bool _fits(DiscoveryFilters? f, SamplePerson p, {bool relaxed = false}) {
    if (f == null) return true;
    final premium = ref.read(premiumProvider).active;
    final filters = premium ? f : f.basicOnly();
    final ageSlack = relaxed && filters.ageFallback
        ? DiscoveryFilters.ageFallbackYears
        : 0;
    final distance = relaxed && filters.distanceFallback
        ? filters.maxDistanceKm * DiscoveryFilters.distanceFallbackFactor
        : filters.maxDistanceKm.toDouble();
    if (p.age < filters.minAge - ageSlack ||
        p.age > filters.maxAge + ageSlack ||
        p.distanceKm > distance) {
      return false;
    }
    if (filters.genders.isNotEmpty && !filters.genders.contains(p.gender)) {
      return false;
    }
    if (filters.verifiedOnly && !p.verified) return false;
    if (relaxed && filters.advancedFallback) return true;
    if (filters.minHeightCm != null && p.heightCm < filters.minHeightCm!) {
      return false;
    }
    if (filters.intentions.isNotEmpty &&
        !filters.intentions.contains(p.lookingFor)) {
      return false;
    }
    for (final e in filters.details.entries) {
      if (e.value.isNotEmpty && !e.value.contains(p.details[e.key])) {
        return false;
      }
    }
    return true;
  }

  /// Everyone who could appear in Discover: has a prompt, undecided, not matched, not ended.
  List<SamplePerson> _candidates() => [
    for (final p in deck)
      if (p.prompt != null &&
          !state.seen.contains(p.id) &&
          !state.matches.contains(p.id) &&
          state.isActive(p.id))
        p,
  ];

  /// The Discover queue under [filters] (defaults to the saved filters). When nobody fits and a
  /// fallback switch is on, people just outside the filters are shown instead (D-15).
  List<SamplePerson> queue([DiscoveryFilters? filters]) {
    final f = filters ?? ref.read(discoveryFiltersProvider);
    final strict = [
      for (final p in _candidates())
        if (_fits(f, p)) p,
    ];
    final out = strict.isNotEmpty
        ? strict
        : [
            for (final p in _candidates())
              if (_fits(f, p, relaxed: true)) p,
          ];
    // Someone brought back by Undo comes first, as they were before the pass.
    final i = out.indexWhere((p) => p.id == state.front);
    if (i > 0) out.insert(0, out.removeAt(i));
    return out;
  }

  /// True when the queue is showing people outside the filters because of a fallback.
  bool showingFallback([DiscoveryFilters? filters]) {
    final f = filters ?? ref.read(discoveryFiltersProvider);
    return queue(f).isNotEmpty && !_candidates().any((p) => _fits(f, p));
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
      liked: liked ? {...state.liked, id} : null,
      lastPass: liked ? null : id,
      clearLastPass: liked,
      clearFront: state.front == id,
      coachDone: true,
      likesHandled: liked && person.likesYou
          ? {...state.likesHandled, id: true}
          : null,
      matches: isMatch ? [...state.matches, id] : null,
      matchedAt: isMatch ? {...state.matchedAt, id: _now} : null,
    );
    _log.info('Decision recorded (${liked ? 'like' : 'pass'})');
    return isMatch
        ? DecisionResult.matched
        : liked
        ? DecisionResult.liked
        : DecisionResult.passed;
  }

  /// SuperSwipe: a like that uses a credit. Null when no credits are left (the paywall offers
  /// more).
  DecisionResult? superSwipe(String id) {
    if (state.superSwipes > 0) {
      state = state.copyWith(superSwipes: state.superSwipes - 1);
    } else if (!ref.read(premiumProvider.notifier).useSuperSwipe()) {
      return null;
    }
    state = state.copyWith(superSwiped: {...state.superSwiped, id});
    return decide(id, liked: true);
  }

  int get superSwipesLeft =>
      state.superSwipes + ref.read(premiumProvider).extraSuperSwipes;

  /// Bring back the last person passed, at the front of the queue. One step only, and only for a
  /// pass: a like has been sent (Bumble's Backtrack works the same way). Returns who came back.
  SamplePerson? undo() {
    final id = state.lastPass;
    if (id == null) return null;
    state = state.copyWith(
      seen: {...state.seen}..remove(id),
      clearLastPass: true,
      front: id,
    );
    return personById(id);
  }

  /// People passed in Discover who could be shown again (not liked, matched or ended).
  int passedCount() => [
    for (final id in state.seen)
      if (!state.liked.contains(id) &&
          !state.matches.contains(id) &&
          state.isActive(id))
        id,
  ].length;

  /// "Show them again": everyone passed comes back around. People liked stay liked.
  void resetDiscovery() => state = state.copyWith(
    seen: {
      for (final id in state.seen)
        if (state.liked.contains(id)) id,
    },
    clearLastPass: true,
    clearFront: true,
  );

  /// The first-card swipe hint was dismissed.
  void dismissCoach() => state = state.copyWith(coachDone: true);

  /// "For you" (B-33): up to four undecided people with the most in common, regardless of the
  /// filters, refreshed daily.
  List<SamplePerson> picks() {
    final people = _candidates()
      ..sort((a, b) => b.shared.length.compareTo(a.shared.length));
    return people.take(4).toList();
  }

  // Likes -----------------------------------------------------------------------------------
  List<({String person, int hoursAgo})> get _likeEntries {
    if (world == DemoWorld.fresh) return kSampleLikes;
    return [...kSampleLikes, ...kExtraLikes]
      ..sort((a, b) => a.hoursAgo.compareTo(b.hoursAgo));
  }

  List<({SamplePerson person, bool isNew, bool matched})> likes([
    LikeFilter filter = LikeFilter.all,
  ]) {
    final out = <({SamplePerson person, bool isNew, bool matched})>[];
    for (final like in _likeEntries) {
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
    final already = state.matches.contains(id);
    state = state.copyWith(
      likesHandled: handled,
      seen: seen,
      matches: already ? null : [...state.matches, id],
      matchedAt: already ? null : {...state.matchedAt, id: _now},
    );
    return DecisionResult.matched;
  }

  // Matches and expiry -----------------------------------------------------------------------
  DateTime expiresAt(String id) =>
      state.extendedUntil[id] ??
      (state.matchedAt[id] ?? _now).add(
        const Duration(hours: kMatchWindowHours),
      );

  bool _hasMessages(String id) => state.threads[id]?.isNotEmpty ?? false;

  /// A new match nobody wrote to within the window (B-47).
  bool isExpired(String id) =>
      state.matches.contains(id) &&
      !_hasMessages(id) &&
      !_now.isBefore(expiresAt(id));

  Duration remaining(String id) {
    final left = expiresAt(id).difference(_now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Active matches with no messages yet, newest first.
  List<SamplePerson> newMatches() => [
    for (final id in state.matches.reversed)
      if (state.isActive(id) && !_hasMessages(id) && !isExpired(id))
        personById(id)!,
  ];

  /// The queue with time left, for countdown rings.
  List<QueuedMatch> queuedMatches() => [
    for (final p in newMatches()) QueuedMatch(p, remaining(p.id)),
  ];

  List<SamplePerson> expiredMatches() => [
    for (final id in state.matches.reversed)
      if (state.isActive(id) && isExpired(id)) personById(id)!,
  ];

  /// Extend a new match by another window: one free Extend a day, unlimited with premium.
  ExtendResult extend(String id) {
    if (_hasMessages(id)) return ExtendResult.notNeeded;
    final premium = ref.read(premiumProvider).active;
    final today = DateTime(_now.year, _now.month, _now.day);
    final usedToday = state.freeExtendUsedOn == today;
    if (isExpired(id) && !premium) return ExtendResult.needsPremium;
    if (usedToday && !premium) return ExtendResult.needsPremium;
    state = state.copyWith(
      extendedUntil: {
        ...state.extendedUntil,
        id: _now.add(const Duration(hours: kMatchWindowHours)),
      },
      freeExtendUsedOn: premium ? null : today,
    );
    _log.info('Match extended');
    return ExtendResult.extended;
  }

  bool get freeExtendAvailable {
    final today = DateTime(_now.year, _now.month, _now.day);
    return state.freeExtendUsedOn != today;
  }

  /// Rematch an expired match (premium, B-47).
  ExtendResult rematch(String id) {
    if (!isExpired(id)) return ExtendResult.notNeeded;
    if (!ref.read(premiumProvider).active) return ExtendResult.needsPremium;
    state = state.copyWith(
      matchedAt: {...state.matchedAt, id: _now},
      extendedUntil: {...state.extendedUntil}..remove(id),
    );
    _log.info('Rematched');
    return ExtendResult.extended;
  }

  // Messages --------------------------------------------------------------------------------
  /// Active matches with messages, most recent first.
  List<SamplePerson> conversations() {
    final ids = [
      for (final id in state.matches)
        if (state.isActive(id) && _hasMessages(id)) id,
    ]..sort((a, b) => lastMessage(b)!.at.compareTo(lastMessage(a)!.at));
    return [for (final id in ids) personById(id)!];
  }

  DemoMessage? lastMessage(String id) {
    final t = state.threads[id];
    return t == null || t.isEmpty ? null : t.last;
  }

  /// Their messages since the conversation was last opened.
  int unread(String id) {
    final read = state.lastRead[id];
    return (state.threads[id] ?? const <DemoMessage>[])
        .where((m) => !m.mine && (read == null || m.at.isAfter(read)))
        .length;
  }

  /// The last message is theirs: it's the member's turn to reply.
  bool yourMove(String id) => !(lastMessage(id)?.mine ?? true);

  /// New matches not opened yet plus unread conversations (the tab badge).
  int unopenedMatches() =>
      newMatches().where((p) => !state.openedMatches.contains(p.id)).length +
      conversations().where((p) => unread(p.id) > 0).length;

  void openChat(String id) => state = state.copyWith(
    openedMatches: {...state.openedMatches, id},
    lastRead: {...state.lastRead, id: _now},
  );

  /// Adds a message to the thread. It stays on this device ([MessageStatus.onDevice]); with the
  /// "simulate connection problems" tool on, it fails so the retry path can be tried.
  Future<void> send(String id, String text) async {
    final body = text.trim();
    if (body.isEmpty || !state.isActive(id)) return;
    final message = DemoMessage(
      id: state.nextMessageId,
      text: body,
      status: MessageStatus.sending,
      at: _now,
    );
    state = state.copyWith(nextMessageId: state.nextMessageId + 1);
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
      lastRead: {...state.lastRead, id: _now},
    );
  }

  /// "Did you meet?" (B-55): kept on this device.
  void recordMeeting(String id, {required bool met}) =>
      state = state.copyWith(dateFeedback: {...state.dateFeedback, id: met});

  // Safety ----------------------------------------------------------------------------------
  void end(String id, EndReason reason) {
    state = state.copyWith(
      ended: {...state.ended, id: reason},
      clearLastPass: state.lastPass == id,
    );
    _log.info('Conversation ended (${reason.name})');
  }

  /// Optional reason after unmatching (B-54).
  void recordUnmatchReason(String id, String reason) => state = state.copyWith(
    unmatchReasons: {...state.unmatchReasons, id: reason},
  );

  /// Saves a report on this device. Reporting with "also block" blocks the person (D-13).
  void report(
    String id,
    String reason, {
    required bool block,
    String? part,
    String details = '',
  }) {
    state = state.copyWith(
      reports: [
        ...state.reports,
        DemoReport(
          personId: id,
          reason: reason,
          blocked: block,
          part: part,
          details: details,
        ),
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
