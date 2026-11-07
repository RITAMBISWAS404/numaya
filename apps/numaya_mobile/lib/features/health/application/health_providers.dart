import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../account_health/application/visibility_report.dart';
import '../../dating/application/dating_controller.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../domain/profile_health.dart';

/// Profile Health (formula v1) from the member's current setup. In the demo every photo on the
/// device counts as approved (the photos step says so); live, only server-approved photos count.
final profileHealthProvider = Provider<ProfileHealth>((ref) {
  final draft = ref.watch(onboardingProvider.select((s) => s.draft));
  final details = ref.watch(profileDetailsProvider);
  final now = ref.read(clockProvider)();
  return ProfileHealth.of(
    HealthInput(
      basicsComplete: draft.aboutYouComplete(now) && draft.lookingForComplete,
      approvedPhotos: draft.photos.length,
      hasBio: details.bio.trim().isNotEmpty,
      prompts:
          (draft.promptComplete ? 1 : 0) +
          details.extraPrompts.where((p) => p.answer.trim().isNotEmpty).length,
    ),
  );
});

/// Discovery status, separate from the score. The notice source "not answering" is unknown, never
/// restricted.
final discoveryStatusProvider = Provider<DiscoveryStatus>((ref) {
  final signals = ref.watch(accountSignalsProvider);
  final health = ref.watch(profileHealthProvider);
  final snoozed = ref.watch(datingProvider.select((s) => s.snoozed));
  return discoveryStatus(
    serviceAvailable: signals.notice != NoticeState.unavailable,
    restricted: signals.notice == NoticeState.restricted,
    paused: snoozed,
    requiredComplete: health.requiredComplete,
    photosPendingReview: false,
  );
});

/// One insights period. [sample] marks demo numbers (labelled on screen); a live build reads the
/// server's aggregate tables and never substitutes these.
@immutable
class InsightsReading {
  const InsightsReading({
    required this.days,
    required this.views,
    required this.likes,
    required this.matches,
    required this.conversations,
    required this.rate,
    this.sample = true,
  });

  final int days;
  final int views;
  final int likes;
  final int matches;
  final int conversations;
  final RateReading rate;
  final bool sample;
}

/// Insights for [days] (7 free; 28 and 90 with Premium). Demo: the sample world's real counts for
/// likes, matches and conversations, and fixed sample exposures.
final insightsProvider = Provider.family<InsightsReading, int>((ref, days) {
  ref.watch(datingProvider);
  final dating = ref.read(datingProvider.notifier);
  final threshold = ref.watch(catalogProvider).policy.insightsSampleThreshold;
  final window = Duration(days: days);
  // Sample exposures per period (approximate impressions); 7 days stays under the threshold so the
  // low-sample state is visible.
  final views = switch (days) {
    7 => 18,
    28 => 74,
    _ => 212,
  };
  final extra = switch (days) {
    7 => 0,
    28 => 6,
    _ => 19,
  };
  final likes = dating.likesReceivedWithin(window) + extra;
  return InsightsReading(
    days: days,
    views: views,
    likes: likes,
    matches: dating.matchesWithin(window) + extra ~/ 3,
    conversations: dating.conversationsWithin(window),
    rate: RateReading(exposures: views, likes: likes, threshold: threshold),
  );
});

final premiumActiveProvider = Provider<bool>(
  (ref) => ref.watch(premiumProvider).active,
);
