import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../auth/application/session_controller.dart';
import '../../dating/application/dating_controller.dart';
import '../../home/application/discovery_filters.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../profile/domain/profile_details.dart';
import '../../settings/application/account_prefs.dart';
import '../../verification/application/verification_controller.dart';

/// What the account-notice source reports (docs/mobile/ACCOUNT_HEALTH_METRICS.md §6). In this
/// build the source is a labelled demo, set from the Demo Hub; a real one is the trust and safety
/// service. Nothing else may say an account is hidden by Numaya.
enum NoticeState { none, notice, restricted, unavailable }

/// Availability of the activity counts (§7).
enum InsightsState { live, stale, unavailable }

@immutable
class AccountSignals {
  const AccountSignals({
    this.notice = NoticeState.none,
    this.insights = InsightsState.live,
  });

  final NoticeState notice;
  final InsightsState insights;

  /// True while the sources are the demo's (always, in this build). The UI labels it.
  bool get demo => true;

  AccountSignals copyWith({NoticeState? notice, InsightsState? insights}) =>
      AccountSignals(
        notice: notice ?? this.notice,
        insights: insights ?? this.insights,
      );
}

/// The demo notice and insights sources (Demo Hub sets them; reset returns to none / live).
class AccountSignalsController extends Notifier<AccountSignals> {
  @override
  AccountSignals build() => const AccountSignals();

  void setNotice(NoticeState n) => state = state.copyWith(notice: n);
  void setInsights(InsightsState i) => state = state.copyWith(insights: i);
  void reset() => state = const AccountSignals();
}

final accountSignalsProvider =
    NotifierProvider<AccountSignalsController, AccountSignals>(
      AccountSignalsController.new,
    );

/// The overall visibility status (§1). Not a score.
enum VisibilityStatus { visible, paused, limited, actionNeeded, cantCheck }

/// What Discover needs from a profile (§2).
enum Requirement { profile, photos, interests, prompt }

/// Suggestions, in the order they are shown (§8).
enum Suggestion {
  reviewRestriction,
  readNotice,
  resume,
  finishSetup,
  addRequiredPhotos,
  addRequiredInterests,
  addRequiredPrompt,
  reviewFilters,
  verifyPhoto,
  morePhotos,
  morePrompts,
  addBio,
  moreInterests,
  aboutYou,
  moreAboutYou,
  chooseArea,
}

/// Counts for the last [window] (§7), from sample data in this build.
@immutable
class ActivityCounts {
  const ActivityCounts({
    required this.likes,
    required this.matches,
    required this.conversations,
  });

  final int likes;
  final int matches;
  final int conversations;

  bool get empty => likes == 0 && matches == 0 && conversations == 0;
}

/// Everything Profile & visibility shows, computed from live app state on every change.
@immutable
class VisibilityReport {
  const VisibilityReport({
    required this.status,
    required this.missing,
    required this.paused,
    required this.pausedUntil,
    required this.incognito,
    required this.notice,
    required this.completion,
    required this.areaSet,
    required this.openToSet,
    required this.filtersFit,
    required this.deckSize,
    required this.phoneVerified,
    required this.photoStatus,
    required this.photoAttemptsLeft,
    required this.insights,
    required this.activity,
    required this.suggestions,
    required this.checkedAt,
    required this.demo,
  });

  static const Duration window = Duration(days: 7);
  static const int maxSuggestions = 5;

  final VisibilityStatus status;
  final List<Requirement> missing;
  final bool paused;

  /// When Snooze ends, or null when indefinite or not paused.
  final DateTime? pausedUntil;
  final bool incognito;
  final NoticeState notice;
  final ProfileCompletion completion;
  final bool areaSet;
  final bool openToSet;

  /// Sample profiles the filters let through, out of [deckSize] undecided ones (§4).
  final int filtersFit;
  final int deckSize;
  final bool phoneVerified;
  final PhotoVerificationStatus photoStatus;
  final int photoAttemptsLeft;
  final InsightsState insights;

  /// Null when insights are unavailable.
  final ActivityCounts? activity;
  final List<Suggestion> suggestions;
  final DateTime checkedAt;
  final bool demo;

  /// Builds the report from its inputs (pure; unit-tested).
  factory VisibilityReport.of({
    required bool hasProfile,
    required bool signedIn,
    required bool paused,
    required DateTime? pausedUntil,
    required bool incognito,
    required ProfileDraft draft,
    required ProfileDetails details,
    required int filtersFit,
    required int deckSize,
    required PhotoVerificationState photo,
    required AccountSignals signals,
    required ActivityCounts counts,
    required DateTime now,
  }) {
    final missing = [
      if (!hasProfile) Requirement.profile,
      if (draft.photos.length < ProfileRules.minPhotos) Requirement.photos,
      if (draft.interests.length < ProfileRules.minInterests)
        Requirement.interests,
      if (!draft.promptComplete) Requirement.prompt,
    ];
    final status = signals.notice == NoticeState.restricted
        ? VisibilityStatus.actionNeeded
        : paused
        ? VisibilityStatus.paused
        : missing.isNotEmpty
        ? VisibilityStatus.actionNeeded
        : signals.notice == NoticeState.unavailable
        ? VisibilityStatus.cantCheck
        : incognito
        ? VisibilityStatus.limited
        : VisibilityStatus.visible;
    final completion = ProfileCompletion.of(draft, details);
    final areaSet = details.area != null;
    final suggestions = [
      if (signals.notice == NoticeState.restricted)
        Suggestion.reviewRestriction,
      if (signals.notice == NoticeState.notice) Suggestion.readNotice,
      if (paused) Suggestion.resume,
      if (missing.contains(Requirement.profile)) Suggestion.finishSetup,
      if (missing.contains(Requirement.photos)) Suggestion.addRequiredPhotos,
      if (missing.contains(Requirement.interests))
        Suggestion.addRequiredInterests,
      if (missing.contains(Requirement.prompt)) Suggestion.addRequiredPrompt,
      // Only when Discover would certainly be empty (§4).
      if (deckSize > 0 && filtersFit == 0) Suggestion.reviewFilters,
      if (photo.status == PhotoVerificationStatus.notStarted ||
          (photo.status == PhotoVerificationStatus.rejected &&
              photo.attempts < PhotoVerificationController.maxAttempts))
        Suggestion.verifyPhoto,
      if (!completion.photos.complete && !missing.contains(Requirement.photos))
        Suggestion.morePhotos,
      if (!completion.prompts.complete && !missing.contains(Requirement.prompt))
        Suggestion.morePrompts,
      if (!completion.bio.complete) Suggestion.addBio,
      if (!completion.interests.complete &&
          !missing.contains(Requirement.interests))
        Suggestion.moreInterests,
      if (!completion.about.complete) Suggestion.aboutYou,
      if (!completion.moreAbout.complete) Suggestion.moreAboutYou,
      if (!areaSet) Suggestion.chooseArea,
    ].take(maxSuggestions).toList();
    return VisibilityReport(
      status: status,
      missing: missing,
      paused: paused,
      pausedUntil: paused ? pausedUntil : null,
      incognito: incognito,
      notice: signals.notice,
      completion: completion,
      areaSet: areaSet,
      openToSet: draft.openTo != null,
      filtersFit: filtersFit,
      deckSize: deckSize,
      phoneVerified: signedIn,
      photoStatus: photo.status,
      photoAttemptsLeft:
          PhotoVerificationController.maxAttempts - photo.attempts,
      insights: signals.insights,
      activity: signals.insights == InsightsState.unavailable ? null : counts,
      suggestions: suggestions,
      checkedAt: now,
      demo: signals.demo,
    );
  }
}

/// The live report. Watching every source means an edit, a snooze, a verification or a filter
/// change shows up at once (§ Update rules).
final visibilityReportProvider = Provider<VisibilityReport>((ref) {
  final session = ref.watch(sessionProvider);
  final prefs = ref.watch(accountPrefsProvider);
  final dating = ref.watch(datingProvider);
  final premium = ref.watch(premiumProvider);
  ref.watch(discoveryFiltersProvider);
  final controller = ref.read(datingProvider.notifier);
  const window = VisibilityReport.window;
  return VisibilityReport.of(
    hasProfile: session?.hasProfile ?? false,
    signedIn: session != null,
    paused: dating.snoozed || prefs.snoozeLength != null,
    pausedUntil: prefs.snoozeUntil,
    incognito: premium.active && premium.incognito,
    draft: ref.watch(onboardingProvider.select((s) => s.draft)),
    details: ref.watch(profileDetailsProvider),
    filtersFit: controller.queue().length,
    deckSize: controller.candidateCount(),
    photo: ref.watch(photoVerificationProvider),
    signals: ref.watch(accountSignalsProvider),
    counts: ActivityCounts(
      likes: controller.likesReceivedWithin(window),
      matches: controller.matchesWithin(window),
      conversations: controller.conversationsWithin(window),
    ),
    now: ref.read(clockProvider)(),
  );
});
