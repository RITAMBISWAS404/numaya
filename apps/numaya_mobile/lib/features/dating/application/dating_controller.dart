import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/connectivity/connectivity.dart';
import '../../../core/logging/app_logger.dart';
import '../../../data/live/live_config.dart';
import '../../../data/live/live_dating_controller.dart';
import '../../commerce/application/economy_controller.dart';
import '../../commerce/domain/catalog.dart';
import '../../compliments/application/compliments_controller.dart';
import '../../home/application/discovery_filters.dart';
import '../../matches/domain/match_lifecycle.dart';
import '../../premium/application/premium_controller.dart';
import '../data/media_picker.dart';
import '../domain/sample_people.dart';

enum EndReason { unmatched, blocked, reported }

/// The outcome of an Events mutual connection ([DatingController.connectFromEvent]).
enum EventConnection {
  created,
  existing,
  existingArchived,
  existingEnded,
  restricted,
}

/// The context line above an opening Compliment on a photo.
const String kComplimentPhotoContext = 'Compliment on a photo';

enum MessageStatus { sending, onDevice, failed, waiting }

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
    this.attachment,
    this.replyToId,
    this.context,
  });
  final int id;

  /// What an opening Compliment was about (a photo, or the prompt it quoted); shown above it.
  final String? context;

  /// The message this one replies to (UI-036), by id in the same thread; null for an ordinary
  /// message. Optional, so every existing message and fixture stays valid.
  final int? replyToId;

  /// The message text, or its caption when there is an [attachment] (may then be empty).
  final String text;
  final MessageStatus status;
  final DateTime at;
  final bool mine;
  final bool sample;
  final MessageAttachment? attachment;

  DemoMessage withStatus(MessageStatus s) => DemoMessage(
    id: id,
    text: text,
    status: s,
    at: at,
    mine: mine,
    sample: sample,
    attachment: attachment,
    replyToId: replyToId,
    context: context,
  );

  /// Accepted by the service (sent, or a seeded sample message). Failed and queued sends are not.
  bool get accepted => status == MessageStatus.onDevice;

  @override
  String toString() => 'DemoMessage($id, ${status.name})';
}

/// Where and when a date is, to share with someone you trust (B-45).
@immutable
class DatePlan {
  const DatePlan({required this.where, required this.when});
  final String where;
  final String when;
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
    this.datePlans = const {},
    this.unmatchReasons = const {},
    this.nextMessageId = 1,
    this.muted = const {},
  });

  /// Conversations whose notifications are muted (S26).
  final Set<String> muted;

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

  /// Date details written to share with a friend (B-45 "Share Date"), per match. Kept on this
  /// device: there is no sharing service in this build.
  final Map<String, DatePlan> datePlans;

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
    Map<String, DatePlan>? datePlans,
    Map<String, String>? unmatchReasons,
    int? nextMessageId,
    Set<String>? muted,
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
      datePlans: datePlans ?? this.datePlans,
      unmatchReasons: unmatchReasons ?? this.unmatchReasons,
      nextMessageId: nextMessageId ?? this.nextMessageId,
      muted: muted ?? this.muted,
    );
  }
}

/// What a decision in Discover or Likes led to.
enum DecisionResult { liked, passed, matched, outOfLikes }

/// What happened when the member tried to extend a new match.
enum ExtendResult {
  extended,

  /// The free weekly extension is used: Premium has one a day.
  needsPremium,

  /// Premium's extension for today is used.
  usedToday,

  /// This match was already extended once (one per match).
  alreadyExtended,

  /// Nothing to extend (messaged, expired or ended).
  notNeeded,
}

/// The most consecutive messages one person may send without a reply (one-sided spam guard;
/// PRD 02 asks for a rate limit because each message resets the quiet timer).
const int kMaxUnansweredMessages = 10;

/// A new match in the queue (B-42): time left before it expires, and the fraction of its
/// original or extended window that is left (the avatar ring, R02).
@immutable
class QueuedMatch {
  const QueuedMatch(this.person, this.remaining, this.fraction);
  final SamplePerson person;
  final Duration remaining;

  /// Fraction of the (possibly extended) window left, 0–1, for the progress ring.
  final double fraction;
}

/// View model for the dating demo: Discover, Likes, matches, conversations and safety actions.
/// Everything is local and in memory; the UI labels it as sample data.
class DatingController extends Notifier<DatingState> {
  static const _log = AppLogger('Dating');

  DateTime get _now => ref.read(clockProvider)();

  DemoWorld get world => ref.read(demoWorldProvider);

  @override
  DatingState build() {
    // Back online: messages written while offline go out, oldest first.
    ref.listen(connectivityProvider, (was, online) {
      if (online && was == false) _sendWaiting();
    });
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
      openedMatches: {'lina', 'ade', 'ollie'},
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

  EconomyController get _economy => ref.read(economyProvider.notifier);

  /// Like or pass someone in Discover. Liking someone who liked you (or who sent you a pending
  /// Compliment) is a match. A like spends the daily allowance (unique per person, so a repeated
  /// tap never spends twice); a pass is free. Out of likes: nothing is recorded.
  DecisionResult decide(String id, {required bool liked}) {
    final person = personById(id);
    if (person == null || !state.isActive(id)) return DecisionResult.passed;
    if (liked && !_economy.spendLike(id)) return DecisionResult.outOfLikes;
    _economy.recordDecision(id);
    final pendingIntro =
        ref.read(complimentsProvider.notifier).pendingFrom(id) != null;
    final isMatch =
        liked &&
        (person.likesYou || pendingIntro) &&
        !state.matches.contains(id);
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
    if (isMatch) _convertRequest(id);
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
  ///
  /// Never brings back someone blocked or reported since (UI-013): the slot is cleared instead.
  SamplePerson? undo() {
    final id = state.lastPass;
    if (id == null) return null;
    if (!state.isActive(id) || personById(id) == null) {
      state = state.copyWith(clearLastPass: true);
      return null;
    }
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

  /// Likes received within [window] of now, answered or not (Profile & visibility's activity
  /// count, from the sample likes).
  int likesReceivedWithin(Duration window) => [
    for (final l in _likeEntries)
      if (Duration(hours: l.hoursAgo) < window) l,
  ].length;

  /// Matches made within [window] of now.
  int matchesWithin(Duration window) => [
    for (final id in state.matches)
      if (state.matchedAt[id] case final at?
          when _now.difference(at) < window && state.isActive(id))
        id,
  ].length;

  /// Active conversations with a message within [window] of now.
  int conversationsWithin(Duration window) => [
    for (final p in conversations())
      if (_now.difference(lastMessage(p.id)!.at) < window) p,
  ].length;

  /// Sample profiles not yet decided on (the deck Discover draws from).
  int candidateCount() => _candidates().length;

  /// Likes not yet answered (the tab badge).
  int unansweredLikes() => likes()
      .where((l) => !l.matched && !state.likesHandled.containsKey(l.person.id))
      .length;

  DecisionResult likeBack(String id, {required bool liked}) {
    if (!state.isActive(id)) return DecisionResult.passed;
    if (liked && !state.matches.contains(id) && !_economy.spendLike(id)) {
      return DecisionResult.outOfLikes;
    }
    _economy.recordDecision(id);
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
    if (!already) _convertRequest(id);
    return DecisionResult.matched;
  }

  /// A Compliment sent (S14) is a decision on that profile: it leaves the deck.
  void markDecided(String id) {
    state = state.copyWith(
      seen: {...state.seen, id},
      clearFront: state.front == id,
      coachDone: true,
    );
    _economy.recordDecision(id);
  }

  /// A pending Compliment between the pair becomes the first message of the new match.
  void _convertRequest(String id) {
    final c = ref.read(complimentsProvider.notifier).convertOnMatch(id);
    if (c == null) return;
    final message = DemoMessage(
      id: state.nextMessageId,
      text: c.text,
      status: MessageStatus.onDevice,
      at: c.sentAt,
      mine: c.fromMe,
      sample: !c.fromMe,
      context: c.referenceText ?? kComplimentPhotoContext,
    );
    state = state.copyWith(
      nextMessageId: state.nextMessageId + 1,
      threads: {
        ...state.threads,
        id: [message, ...?state.threads[id]],
      },
    );
  }

  /// Replying to a Compliment request (S21): match and conversation are created together, with
  /// their Compliment first and the reply second. Free.
  void openFromRequest(
    String id, {
    required String their,
    required DateTime theirAt,
    required String reply,
    String? context,
  }) {
    final now = _now;
    final first = DemoMessage(
      id: state.nextMessageId,
      text: their,
      status: MessageStatus.onDevice,
      at: theirAt,
      mine: false,
      sample: true,
      context: context ?? kComplimentPhotoContext,
    );
    final second = DemoMessage(
      id: state.nextMessageId + 1,
      text: reply,
      status: MessageStatus.onDevice,
      at: now,
    );
    state = state.copyWith(
      nextMessageId: state.nextMessageId + 2,
      seen: {...state.seen, id},
      matches: state.matches.contains(id) ? null : [...state.matches, id],
      matchedAt: {...state.matchedAt, id: now},
      threads: {
        ...state.threads,
        id: [first, second],
      },
      openedMatches: {...state.openedMatches, id},
      lastRead: {...state.lastRead, id: now},
    );
    _economy.recordMessage();
  }

  /// Events E08: a mutual post-event connection between the member and [id].
  ///
  /// Reuses whatever already exists and never resets it: an active or awaiting match is returned
  /// as it is (no new chat, no timer change); an archived chat stays archived (the member can
  /// resume it by sending, R01); a pair that unmatched or blocked is never reconnected; an initial
  /// match that ran out is not recreated (product rule OPEN, D5). Only a pair with no history gets
  /// a new match, which follows the normal 24-hour first-message rule.
  EventConnection connectFromEvent(String id) {
    if (state.ended.containsKey(id)) return EventConnection.restricted;
    if (state.matches.contains(id)) {
      return switch (status(id).phase) {
        MatchPhase.archived => EventConnection.existingArchived,
        MatchPhase.expired => EventConnection.existingEnded,
        _ => EventConnection.existing,
      };
    }
    state = state.copyWith(
      seen: {...state.seen, id},
      matches: [...state.matches, id],
      matchedAt: {...state.matchedAt, id: _now},
    );
    _log.info('Event connection created');
    return EventConnection.created;
  }

  // Matches and expiry -----------------------------------------------------------------------
  AllowancePolicy get _policy => ref.read(catalogProvider).policy;

  /// Everything the lifecycle needs for [id] (PRD 02 state machine).
  MatchTimeline timeline(String id) {
    final accepted = [
      for (final m in state.threads[id] ?? const <DemoMessage>[])
        if (m.accepted) m,
    ];
    final ended = state.ended[id];
    return MatchTimeline(
      matchedAt: state.matchedAt[id] ?? _now,
      extendedUntil: state.extendedUntil[id],
      firstMessageAt: accepted.firstOrNull?.at,
      lastMessageAt: accepted.lastOrNull?.at,
      ended: ended == null
          ? null
          : ended == EndReason.unmatched
          ? MatchPhase.unmatched
          : MatchPhase.blocked,
    );
  }

  MatchStatus status(String id) => matchStatus(timeline(id), _now, _policy);

  DateTime expiresAt(String id) => status(id).deadline ?? _now;

  bool _hasMessages(String id) => state.threads[id]?.isNotEmpty ?? false;

  /// An initial match that ran out without a first message (no reconnection, R02).
  bool isExpired(String id) =>
      state.matches.contains(id) && status(id).isExpired;

  /// A started conversation that has been quiet for the archive period (R01).
  bool isArchived(String id) =>
      state.matches.contains(id) && status(id).isArchived;

  /// Fraction of the first-message window left (the avatar ring), 0–1.
  double windowFraction(String id) => status(id).remainingFraction(_now);

  Duration remaining(String id) {
    final left = expiresAt(id).difference(_now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Matches waiting for a first message, newest first.
  List<SamplePerson> newMatches() => [
    for (final id in state.matches.reversed)
      if (state.isActive(id) &&
          status(id).phase == MatchPhase.awaitingFirstMessage &&
          !_hasMessages(id))
        personById(id)!,
  ];

  /// The queue with time left, for countdowns.
  List<QueuedMatch> queuedMatches() => [
    for (final p in newMatches())
      QueuedMatch(p, remaining(p.id), windowFraction(p.id)),
  ];

  /// Initial matches that expired without a first message, newest first. Shown only as a simple
  /// expired state; they cannot be revived (R02).
  List<SamplePerson> expiredMatches() {
    final ids = [
      for (final id in state.matches)
        if (state.isActive(id) && isExpired(id)) id,
    ]..sort((a, b) => status(b).expiredAt!.compareTo(status(a).expiredAt!));
    return [for (final id in ids) personById(id)!];
  }

  /// Archived conversations (R01), most recent activity first.
  List<SamplePerson> archivedConversations() {
    final ids = [
      for (final id in state.matches)
        if (state.isActive(id) && isArchived(id)) id,
    ]..sort((a, b) => _activityAt(b).compareTo(_activityAt(a)));
    return [for (final id in ids) personById(id)!];
  }

  /// Extends a new match by 24 hours: one extension per match; free members have one a week,
  /// Premium one a day. Never for expired or ended matches.
  ExtendResult extend(String id) {
    final s = status(id);
    if (s.phase != MatchPhase.awaitingFirstMessage) {
      return ExtendResult.notNeeded;
    }
    if (state.extendedUntil.containsKey(id)) {
      return ExtendResult.alreadyExtended;
    }
    if (!_economy.extensionAvailable()) {
      return ref.read(premiumProvider).active
          ? ExtendResult.usedToday
          : ExtendResult.needsPremium;
    }
    _economy.useExtension();
    state = state.copyWith(
      extendedUntil: {
        ...state.extendedUntil,
        id: s.deadline!.add(Duration(hours: _policy.extensionHours)),
      },
    );
    _log.info('Match extended');
    return ExtendResult.extended;
  }

  bool get freeExtendAvailable => _economy.extensionAvailable();

  void setMuted(String id, bool muted) => state = state.copyWith(
    muted: muted ? {...state.muted, id} : ({...state.muted}..remove(id)),
  );

  // Messages --------------------------------------------------------------------------------
  /// Active matches with messages, most recent first.
  List<SamplePerson> conversations() {
    final ids = [
      for (final id in state.matches)
        if (state.isActive(id) &&
            _hasMessages(id) &&
            status(id).phase == MatchPhase.active)
          id,
    ]..sort((a, b) => _activityAt(b).compareTo(_activityAt(a)));
    return [for (final id in ids) personById(id)!];
  }

  DateTime _activityAt(String id) =>
      lastMessage(id)?.at ?? state.matchedAt[id]!;

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

  bool get _online => ref.read(connectivityProvider);

  /// Adds a message to the thread. It stays on this device ([MessageStatus.onDevice]); with the
  /// "simulate connection problems" tool on, it fails so the retry path can be tried. Offline, it
  /// waits ([MessageStatus.waiting]) and goes out when the connection is back. An [attachment]
  /// (photo, video, voice note) goes the same way, with [text] as its optional caption; it is never
  /// uploaded.
  Future<void> send(
    String id,
    String text, {
    MessageAttachment? attachment,
    int? replyToId,
  }) async {
    final body = text.trim();
    if ((body.isEmpty && attachment == null) || !state.isActive(id)) return;
    // Expired initial matches keep their history but cannot send; archived chats can (R01).
    if (!status(id).canSend || !canSendMore(id)) return;
    // A reply keeps its target only if that message is still in this thread.
    final target = replyToId == null
        ? null
        : (state.threads[id] ?? const <DemoMessage>[])
              .where((m) => m.id == replyToId)
              .firstOrNull;
    final message = DemoMessage(
      id: state.nextMessageId,
      text: body,
      status: _online ? MessageStatus.sending : MessageStatus.waiting,
      at: _now,
      attachment: attachment,
      replyToId: target?.id,
    );
    state = state.copyWith(nextMessageId: state.nextMessageId + 1);
    _put(id, message);
    if (!_online) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!ref.mounted) return;
    _accept(id, message);
  }

  /// Removes one message (a moderation or account-deletion outcome): a reply to it then shows that
  /// the original is unavailable.
  void removeMessage(String id, int messageId) {
    state = state.copyWith(
      threads: {
        ...state.threads,
        id: [
          for (final m in state.threads[id] ?? const <DemoMessage>[])
            if (m.id != messageId) m,
        ],
      },
    );
  }

  /// The service's answer to a send. A first message counts only if it is accepted before the
  /// match's deadline; an accepted message resets the quiet timer and counts toward the streak.
  void _accept(String id, DemoMessage message) {
    final ok = !state.simulateErrors && status(id).canSend;
    _put(
      id,
      message.withStatus(ok ? MessageStatus.onDevice : MessageStatus.failed),
    );
    if (ok) _economy.recordMessage();
  }

  /// One-sided spam guard: false after [kMaxUnansweredMessages] unanswered messages in a row.
  bool canSendMore(String id) {
    var run = 0;
    for (final m in (state.threads[id] ?? const <DemoMessage>[]).reversed) {
      if (!m.mine) break;
      run++;
    }
    return run < kMaxUnansweredMessages;
  }

  Future<void> retry(String id, int messageId) async {
    final message = state.threads[id]?.firstWhere((m) => m.id == messageId);
    if (message == null) return;
    if (!_online) {
      _put(id, message.withStatus(MessageStatus.waiting));
      return;
    }
    _put(id, message.withStatus(MessageStatus.sending));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!ref.mounted) return;
    _accept(id, message);
  }

  /// Sends every waiting message, in the order they were written.
  Future<void> _sendWaiting() async {
    final waiting = [
      for (final MapEntry(key: id, value: thread) in state.threads.entries)
        for (final m in thread)
          if (m.status == MessageStatus.waiting) (id, m.id),
    ];
    for (final (id, messageId) in waiting) {
      if (!ref.mounted || !_online) return;
      await retry(id, messageId);
    }
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
    if (reason != EndReason.unmatched) {
      ref.read(complimentsProvider.notifier).hideFrom(id);
    }
    state = state.copyWith(
      ended: {...state.ended, id: reason},
      clearLastPass: state.lastPass == id,
    );
    _log.info('Conversation ended (${reason.name})');
  }

  /// Optional reason after unmatching (B-54).
  /// Saves (or with null, removes) the date details for match [id].
  void setDatePlan(String id, DatePlan? plan) => state = state.copyWith(
    datePlans: {
      for (final e in state.datePlans.entries)
        if (e.key != id) e.key: e.value,
      id: ?plan,
    },
  );

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
    if (block) ref.read(complimentsProvider.notifier).hideFrom(id);
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
      clearLastPass: block && state.lastPass == id,
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
  // Live backend builds use the server-backed controller (backend V1); demo builds are unchanged.
  () => LiveConfig.enabled ? LiveDatingController() : DatingController(),
);
