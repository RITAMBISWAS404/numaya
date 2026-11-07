import 'package:flutter/foundation.dart';

/// Your insights (Visual Lab V2, R11 and brief 03). Sample data only: there is no tracking yet,
/// and every screen that shows these numbers labels them "Sample data". A live build reads the
/// server's aggregates and never substitutes these.
///
/// Honesty rules encoded here:
/// - Counts in a funnel come from **one cohort and one period**: of the distinct people who were
///   shown this profile in the period, how many liked, matched, and had a two-way conversation.
///   Counts from other windows never join it.
/// - Status is what the service itself is doing (shown, paused, restricted, limited audience,
///   not enough data). Nothing here claims that not replying or blocking lowers anyone's reach.
/// - A suggestion states its evidence, a possible reading, an action and its uncertainty; it never
///   promises a result.
enum InsightsScenario {
  /// New account: too little data for trends.
  newAccount,

  /// Typical week.
  typical,

  /// Fewer appearances, explained by a small eligible audience within the chosen distance.
  limitedAudience,

  /// The member paused their profile.
  paused,

  /// The service restricted the account (actual restriction; reason and appeal shown free).
  restricted,

  /// Normal appearances, few likes: the cause is unknown and is said to be unknown.
  fewLikes,

  /// Premium with 28 days of history.
  premiumHistory,
}

enum VisibilityState {
  shown,
  limitedAudience,
  paused,
  restricted,
  notEnoughData,
}

/// One evidence-linked suggestion (brief 03).
@immutable
class InsightAdvice {
  const InsightAdvice({
    required this.evidence,
    required this.reading,
    required this.action,
    required this.uncertainty,
    this.actionRoute,
  });

  /// What the numbers show.
  final String evidence;

  /// A possible interpretation, never a diagnosis.
  final String reading;

  /// One thing the member can do.
  final String action;
  final String? actionRoute;

  /// What this can't tell, and that nothing is guaranteed.
  final String uncertainty;
}

/// A period of sample insights. All counts are distinct people unless named otherwise.
@immutable
class InsightsSnapshot {
  const InsightsSnapshot({
    required this.scenario,
    required this.days,
    required this.state,
    required this.daily,
    required this.previousTotal,
    required this.liked,
    required this.matched,
    required this.conversations,
    required this.activeDays,
    required this.eligibleAudience,
    required this.distanceKm,
    this.advice,
    this.restrictionReason,
  });

  final InsightsScenario scenario;

  /// Period length: 7, 28 or 90 days.
  final int days;
  final VisibilityState state;

  /// People shown this profile **for the first time in the period** on each day, oldest first
  /// (length = [days]). Each person counts once, so the bars sum to [shown].
  final List<int> daily;

  /// The same measure over the previous period of equal length (null: no previous period).
  final int? previousTotal;

  /// Of the people shown this profile in this period (the cohort): liked it, matched, and had a
  /// conversation where both people wrote.
  final int liked;
  final int matched;
  final int conversations;

  /// Days in the period the member opened Numaya.
  final int activeDays;

  /// Members who match the member's filters within [distanceKm] right now (rounded).
  final int eligibleAudience;
  final int distanceKm;
  final InsightAdvice? advice;
  final String? restrictionReason;

  /// Distinct people shown this profile in the period (the funnel's cohort).
  int get shown => daily.fold(0, (a, b) => a + b);

  /// Below 20 people shown, rates and comparisons are not meaningful (low sample).
  bool get lowSample => shown < 20;

  /// Change against the previous period, or null when there is none or the sample is too small.
  int? get change =>
      previousTotal == null || lowSample ? null : shown - previousTotal!;

  bool get hasData => daily.isNotEmpty && shown > 0;
}

/// Repeats a week pattern to [days] with a gentle drift, for the Premium periods.
List<int> _stretch(List<int> week, int days, {int drift = 0}) => [
  for (var i = 0; i < days; i++)
    (week[i % 7] + ((i ~/ 7) - (days ~/ 7)) * drift).clamp(0, 999),
];

/// The sample snapshot for [scenario] over [days]. Deterministic: no clock, no randomness.
InsightsSnapshot sampleInsights(InsightsScenario scenario, int days) {
  switch (scenario) {
    case InsightsScenario.newAccount:
      return InsightsSnapshot(
        scenario: scenario,
        days: 7,
        state: VisibilityState.notEnoughData,
        daily: ([0, 0, 0, 0, 1, 3, 4]),
        previousTotal: null,
        liked: 1,
        matched: 0,
        conversations: 0,
        activeDays: 3,
        eligibleAudience: 140,
        distanceKm: 10,
        advice: const InsightAdvice(
          evidence: 'Your profile has been shown to 8 people so far.',
          reading: 'That is too few to see any pattern yet.',
          action: 'Keep using Discover as usual.',
          uncertainty:
              'Trends appear after about 20 people have seen your profile.',
        ),
      );
    case InsightsScenario.typical:
      final week = [9, 11, 8, 12, 10, 14, 13];
      return InsightsSnapshot(
        scenario: scenario,
        days: days,
        state: VisibilityState.shown,
        daily: days == 7 ? week : _stretch(week, days, drift: 1),
        previousTotal: days == 7 ? 70 : (days == 28 ? 262 : 801),
        liked: days == 7 ? 9 : (days == 28 ? 34 : 101),
        matched: days == 7 ? 3 : (days == 28 ? 11 : 30),
        conversations: days == 7 ? 2 : (days == 28 ? 7 : 19),
        activeDays: days == 7 ? 5 : (days == 28 ? 19 : 58),
        eligibleAudience: 620,
        distanceKm: 10,
        advice: const InsightAdvice(
          evidence:
              '2 of your 3 new matches this week haven’t had a first message.',
          reading: 'New matches end after 24 hours without one.',
          action: 'Open Chats to write first.',
          actionRoute: '/messages',
          uncertainty: 'A first message doesn’t guarantee a reply.',
        ),
      );
    case InsightsScenario.limitedAudience:
      return InsightsSnapshot(
        scenario: scenario,
        days: 7,
        state: VisibilityState.limitedAudience,
        daily: ([3, 2, 4, 2, 3, 2, 3]),
        previousTotal: 22,
        liked: 3,
        matched: 1,
        conversations: 1,
        activeDays: 6,
        eligibleAudience: 45,
        distanceKm: 5,
        advice: const InsightAdvice(
          evidence: 'About 45 people match your filters within 5 km, and most have already seen you.',
          reading: 'Fewer appearances are likely because few new people fit.',
          action: 'Preview how many people a 15 km distance would include.',
          actionRoute: '/profile/settings',
          uncertainty: 'A wider distance adds people; it can’t promise likes.',
        ),
      );
    case InsightsScenario.paused:
      return InsightsSnapshot(
        scenario: scenario,
        days: 7,
        state: VisibilityState.paused,
        daily: ([10, 9, 0, 0, 0, 0, 0]),
        previousTotal: 68,
        liked: 2,
        matched: 1,
        conversations: 1,
        activeDays: 2,
        eligibleAudience: 610,
        distanceKm: 10,
        advice: const InsightAdvice(
          evidence: 'Your profile has been paused since Wednesday.',
          reading: 'While paused, no one new sees you. Your chats still work.',
          action: 'Resume when you’re ready.',
          actionRoute: '/profile/settings/privacy',
          uncertainty: 'Nothing is lost while you’re paused.',
        ),
      );
    case InsightsScenario.restricted:
      return InsightsSnapshot(
        scenario: scenario,
        days: 7,
        state: VisibilityState.restricted,
        daily: ([11, 10, 12, 0, 0, 0, 0]),
        previousTotal: 71,
        liked: 3,
        matched: 1,
        conversations: 1,
        activeDays: 4,
        eligibleAudience: 620,
        distanceKm: 10,
        restrictionReason: 'A photo is being checked against our photo rules.',
        advice: const InsightAdvice(
          evidence:
              'Numaya has limited your profile while a photo is reviewed.',
          reading: 'This is our decision, not anything another member did.',
          action: 'See the reason and how to appeal.',
          actionRoute: '/account-blocked',
          uncertainty: 'Reviews usually finish within 2 days (sample).',
        ),
      );
    case InsightsScenario.fewLikes:
      return InsightsSnapshot(
        scenario: scenario,
        days: 7,
        state: VisibilityState.shown,
        daily: ([10, 12, 9, 11, 10, 13, 12]),
        previousTotal: 74,
        liked: 1,
        matched: 0,
        conversations: 0,
        activeDays: 5,
        eligibleAudience: 640,
        distanceKm: 10,
        advice: const InsightAdvice(
          evidence: '77 people saw your profile this week and 1 liked it.',
          reading:
              'We can’t tell why. Likes vary week to week for many reasons.',
          action: 'If you like, try a different first photo or add a prompt.',
          actionRoute: '/profile/edit',
          uncertainty: 'Changes may or may not affect likes.',
        ),
      );
    case InsightsScenario.premiumHistory:
      final week = [12, 14, 11, 15, 13, 17, 16];
      return InsightsSnapshot(
        scenario: scenario,
        days: days,
        state: VisibilityState.shown,
        daily: days == 7 ? week : _stretch(week, days, drift: 1),
        previousTotal: days == 7 ? 91 : (days == 28 ? 341 : 1010),
        liked: days == 7 ? 12 : (days == 28 ? 44 : 128),
        matched: days == 7 ? 4 : (days == 28 ? 15 : 41),
        conversations: days == 7 ? 3 : (days == 28 ? 10 : 27),
        activeDays: days == 7 ? 6 : (days == 28 ? 22 : 66),
        eligibleAudience: 700,
        distanceKm: 15,
        advice: const InsightAdvice(
          evidence:
              'Most of your likes this month arrived on Fridays and Saturdays.',
          reading: 'More people near you are active at weekends.',
          action: 'Weekend evenings may be a good time to reply.',
          uncertainty: 'This describes the past month; it isn’t a forecast.',
        ),
      );
  }
}
