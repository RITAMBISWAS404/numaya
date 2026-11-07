import 'package:flutter/foundation.dart';

import '../../../core/time/ist.dart';
import '../../commerce/domain/catalog.dart';

/// Daily positive-like allowance (PRD 01/02): free 5 a day, Premium 15, reset at midnight IST.
/// Passes are free and unlimited. A like is unique per (sender, recipient): liking the same person
/// again, or a duplicate tap, never spends twice.
@immutable
class LikeQuota {
  const LikeQuota({this.likesByDay = const {}});

  /// Recipients liked on each IST day.
  final Map<IstDay, Set<String>> likesByDay;

  int usedOn(DateTime now) => likesByDay[istDay(now)]?.length ?? 0;

  int limit(AllowancePolicy policy, {required bool premium}) =>
      policy.likesPerDay(premium: premium);

  int remaining(
    DateTime now,
    AllowancePolicy policy, {
    required bool premium,
  }) => (limit(policy, premium: premium) - usedOn(now)).clamp(0, 1 << 30);

  bool alreadyLiked(String recipient) =>
      likesByDay.values.any((s) => s.contains(recipient));

  DateTime nextReset(DateTime now) => nextIstMidnight(now);

  /// Records a like. Returns null when the allowance is used up (nothing is recorded).
  LikeQuota? spend(
    String recipient,
    DateTime now,
    AllowancePolicy policy, {
    required bool premium,
  }) {
    if (alreadyLiked(recipient)) return this;
    if (remaining(now, policy, premium: premium) <= 0) return null;
    final day = istDay(now);
    return LikeQuota(
      likesByDay: {
        ...likesByDay,
        day: {...?likesByDay[day], recipient},
      },
    );
  }
}

/// Match extensions (PRD 01): free members get one a week (resets Monday 00:00 IST), Premium one a
/// day (midnight IST). One extension in total per match; none for ended connections.
@immutable
class ExtensionAllowance {
  const ExtensionAllowance({this.uses = const []});

  final List<DateTime> uses;

  bool available(DateTime now, {required bool premium}) {
    if (premium) return !uses.any((u) => istDay(u) == istDay(now));
    final week = istWeekStart(now);
    return !uses.any((u) => istWeekStart(u) == week);
  }

  DateTime nextReset(DateTime now, {required bool premium}) =>
      premium ? nextIstMidnight(now) : nextIstMonday(now);

  ExtensionAllowance use(DateTime now) =>
      ExtensionAllowance(uses: [...uses, now]);
}
