import 'package:flutter/foundation.dart';

import '../../../core/time/ist.dart';

/// Streak rules (PRD 01 and 02).
///
/// - A streak day (IST calendar day) qualifies with three distinct profile decisions, OR one sent
///   message in a reciprocal conversation, OR (only when neither is possible) an explicit
///   profile-review completion. There is no dwell-time requirement.
/// - Seven consecutive qualifying days award one credit; an award is unique per (run start, cycle),
///   so a repaired run never pays a cycle twice.
/// - Paid recovery repairs one missed day within 48 hours of that day ending, at most once in any
///   seven days, and only when it joins an eligible sequence (the day before it qualified and every
///   day since qualified). The server rechecks eligibility before charging.
/// - Credits already earned survive a streak reset (they live in the ledger, not here).
@immutable
class DayActivity {
  const DayActivity({
    this.decisions = const {},
    this.messages = 0,
    this.reviewCompleted = false,
  });

  /// Profiles decided on that day (a set, so deciding on the same person twice counts once).
  final Set<String> decisions;
  final int messages;
  final bool reviewCompleted;

  bool qualifies(int decisionsNeeded) =>
      decisions.length >= decisionsNeeded || messages > 0 || reviewCompleted;

  DayActivity copyWith({
    Set<String>? decisions,
    int? messages,
    bool? reviewCompleted,
  }) => DayActivity(
    decisions: decisions ?? this.decisions,
    messages: messages ?? this.messages,
    reviewCompleted: reviewCompleted ?? this.reviewCompleted,
  );
}

/// The outcome of an award, kept per cycle (`reward_cycles` on the server).
enum AwardResult { granted, skippedAtCap }

@immutable
class StreakRun {
  const StreakRun({required this.start, required this.length});

  /// First day of the run (null when there is no run).
  final IstDay? start;
  final int length;

  /// Days done in the current seven-day cycle, 0 to 7.
  int progress(int cycleDays) =>
      length == 0 ? 0 : ((length - 1) % cycleDays) + 1;
}

@immutable
class RecoveryOffer {
  const RecoveryOffer({
    required this.missedDay,
    required this.deadline,
    required this.resultingLength,
  });

  final IstDay missedDay;

  /// After this instant the day can no longer be repaired.
  final DateTime deadline;

  /// The streak length once the day is repaired.
  final int resultingLength;
}

@immutable
class StreakState {
  const StreakState({
    this.days = const {},
    this.repaired = const {},
    this.awards = const {},
    this.decisionsNeeded = 3,
    this.cycleDays = 7,
    this.recoveryWindow = const Duration(hours: 48),
  });

  final Map<IstDay, DayActivity> days;

  /// Days repaired by a recovery purchase.
  final Set<IstDay> repaired;

  /// Award outcome per cycle key `<runStart>:<cycleNumber>`.
  final Map<String, AwardResult> awards;
  final int decisionsNeeded;
  final int cycleDays;
  final Duration recoveryWindow;

  bool qualifies(IstDay day) =>
      repaired.contains(day) ||
      (days[day]?.qualifies(decisionsNeeded) ?? false);

  DayActivity activity(IstDay day) => days[day] ?? const DayActivity();

  StreakState copyWith({
    Map<IstDay, DayActivity>? days,
    Set<IstDay>? repaired,
    Map<String, AwardResult>? awards,
  }) => StreakState(
    days: days ?? this.days,
    repaired: repaired ?? this.repaired,
    awards: awards ?? this.awards,
    decisionsNeeded: decisionsNeeded,
    cycleDays: cycleDays,
    recoveryWindow: recoveryWindow,
  );

  StreakState _update(IstDay day, DayActivity Function(DayActivity) f) =>
      copyWith(days: {...days, day: f(activity(day))});

  StreakState recordDecision(DateTime at, String profileId) => _update(
    istDay(at),
    (a) => a.copyWith(decisions: {...a.decisions, profileId}),
  );

  StreakState recordMessage(DateTime at) =>
      _update(istDay(at), (a) => a.copyWith(messages: a.messages + 1));

  StreakState recordReview(DateTime at) =>
      _update(istDay(at), (a) => a.copyWith(reviewCompleted: true));

  /// The run ending today (if today qualifies) or yesterday (today still open).
  StreakRun run(DateTime now) => _runEnding(istDay(now), qualifies);

  StreakRun _runEnding(IstDay today, bool Function(IstDay) q) {
    var end = today;
    if (!q(end)) end = today - 1;
    var length = 0;
    var day = end;
    while (q(day)) {
      length++;
      day--;
    }
    return StreakRun(start: length == 0 ? null : day + 1, length: length);
  }

  /// Cycle keys completed by the current run that have no award yet, oldest first.
  List<String> pendingAwards(DateTime now) {
    final r = run(now);
    if (r.start == null) return const [];
    return [
      for (var c = 1; c <= r.length ~/ cycleDays; c++)
        if (!awards.containsKey('${r.start}:$c')) '${r.start}:$c',
    ];
  }

  /// The recovery that is open now, or null. Eligibility is rechecked by the server at purchase.
  RecoveryOffer? recoveryOffer(DateTime now) {
    final today = istDay(now);
    for (final missed in [today - 1, today - 2]) {
      if (qualifies(missed)) continue;
      // Joins an eligible sequence: the day before qualified...
      if (!qualifies(missed - 1)) continue;
      // ...and every full day since the missed one qualified (today may still be open).
      var bridged = true;
      for (var d = missed + 1; d < today; d++) {
        if (!qualifies(d)) bridged = false;
      }
      if (!bridged) continue;
      final deadline = istDayStart(missed + 1).add(recoveryWindow);
      if (!now.isBefore(deadline)) continue;
      // At most one repair in any seven days.
      if (repaired.any((r) => (missed - r).abs() < cycleDays)) continue;
      final after = _runEnding(today, (d) => d == missed || qualifies(d));
      return RecoveryOffer(
        missedDay: missed,
        deadline: deadline,
        resultingLength: after.length,
      );
    }
    return null;
  }

  /// Applies a verified recovery. Returns null when the offer is no longer valid (never charge).
  StreakState? repair(IstDay missedDay, DateTime now) {
    final offer = recoveryOffer(now);
    if (offer == null || offer.missedDay != missedDay) return null;
    return copyWith(repaired: {...repaired, missedDay});
  }
}
