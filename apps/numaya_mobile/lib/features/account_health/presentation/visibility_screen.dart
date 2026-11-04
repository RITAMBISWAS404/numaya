import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/filters_sheet.dart';
import '../../onboarding/presentation/permission_prompt.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../verification/application/verification_controller.dart';
import '../application/visibility_report.dart';

/// Profile & visibility (docs/mobile/ACCOUNT_HEALTH_METRICS.md): what Numaya knows about whether
/// the profile can appear in Discover, what's complete, how Discover is set up, verification,
/// account notices and recent activity, with a direct way to change each. No combined score, no
/// ranking, no guesses: unknowns are shown as unknown, and demo sources say so.
class VisibilityScreen extends ConsumerWidget {
  const VisibilityScreen({super.key});

  static String statusLabel(AppLocalizations l10n, VisibilityStatus s) =>
      switch (s) {
        VisibilityStatus.visible => l10n.visStatusVisible,
        VisibilityStatus.paused => l10n.visStatusPaused,
        VisibilityStatus.limited => l10n.visStatusLimited,
        VisibilityStatus.actionNeeded => l10n.visStatusAction,
        VisibilityStatus.cantCheck => l10n.visStatusCantCheck,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = ref.watch(visibilityReportProvider);
    final signals = ref.read(accountSignalsProvider.notifier);

    void open(String route) => unawaited(context.push(route));

    Future<void> chooseArea() async {
      final area = await showAreaSheet(
        context,
        selected: ref.read(profileDetailsProvider).area,
      );
      if (area == null) return;
      ref.read(profileDetailsProvider.notifier).setArea(area);
    }

    Future<void> readNotice() => showNumayaSheet<void>(
      context: context,
      title: l10n.visNoticeSheetTitle,
      closeLabel: l10n.close,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.visNoticeSheetBody, style: AppTypography.body),
          const SizedBox(height: AppSpacing.s3),
          Text(l10n.visDemoNoticeNote, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            label: l10n.visGuidelines,
            onPressed: () {
              Navigator.of(context).pop();
              open(Routes.help);
            },
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.visContactSupport,
            variant: NumayaButtonVariant.secondary,
            onPressed: () {
              Navigator.of(context).pop();
              open(Routes.helpContact);
            },
          ),
        ],
      ),
    );

    void act(Suggestion s) {
      switch (s) {
        case Suggestion.reviewRestriction:
          open(Routes.accountBlocked);
        case Suggestion.readNotice:
          unawaited(readNotice());
        case Suggestion.resume:
          SettingsScreen.endSnooze(context, ref);
        case Suggestion.finishSetup:
          open(Routes.setup);
        case Suggestion.addRequiredPhotos || Suggestion.morePhotos:
          open(Routes.editPhotos);
        case Suggestion.addRequiredInterests || Suggestion.moreInterests:
          open(Routes.editInterests);
        case Suggestion.addRequiredPrompt || Suggestion.morePrompts:
          open(
            r.completion.prompts.done == 0
                ? Routes.editPrompt
                : '${Routes.editPrompt}?slot=${r.completion.prompts.done.clamp(1, 2)}',
          );
        case Suggestion.verifyPhoto:
          open(Routes.verifyPhoto);
        case Suggestion.addBio ||
            Suggestion.aboutYou ||
            Suggestion.moreAboutYou:
          open(Routes.editProfile);
        case Suggestion.chooseArea:
          unawaited(chooseArea());
        case Suggestion.reviewFilters:
          unawaited(showFiltersSheet(context, ref));
      }
    }

    final (statusBody, statusAction) = switch (r.status) {
      VisibilityStatus.visible => (l10n.visVisibleBody, null),
      VisibilityStatus.paused => (
        r.pausedUntil == null
            ? l10n.visPausedBody
            : l10n.visPausedUntil(
                DateFormat('EEE d MMM, HH:mm').format(r.pausedUntil!),
              ),
        (l10n.visResume, () => act(Suggestion.resume)),
      ),
      VisibilityStatus.limited => (
        l10n.visLimitedBody,
        (l10n.visPrivacySettings, () => open(Routes.privacy)),
      ),
      VisibilityStatus.cantCheck => (
        l10n.visCantCheckBody,
        (l10n.discoverRetry, () => signals.setNotice(NoticeState.none)),
      ),
      VisibilityStatus.actionNeeded =>
        r.notice == NoticeState.restricted
            ? (
                l10n.visRestrictedBody,
                (l10n.visReviewNotice, () => act(Suggestion.reviewRestriction)),
              )
            : (l10n.visMissingBody, null),
    };

    final statusTone = switch (r.status) {
      VisibilityStatus.visible => BannerTone.success,
      VisibilityStatus.paused || VisibilityStatus.limited => BannerTone.info,
      VisibilityStatus.cantCheck => BannerTone.pending,
      VisibilityStatus.actionNeeded => BannerTone.error,
    };

    String reqLabel(Requirement q) => switch (q) {
      Requirement.profile => l10n.visReqProfile,
      Requirement.photos => l10n.visReqPhotos,
      Requirement.interests => l10n.visReqInterests,
      Requirement.prompt => l10n.visReqPrompt,
    };

    final c = r.completion;
    final parts = [
      (l10n.completionPhotos, c.photos, Suggestion.morePhotos),
      (l10n.completionPrompts, c.prompts, Suggestion.morePrompts),
      (l10n.completionInterests, c.interests, Suggestion.moreInterests),
      (l10n.completionBio, c.bio, Suggestion.addBio),
      (l10n.completionAbout, c.about, Suggestion.aboutYou),
      (l10n.completionMore, c.moreAbout, Suggestion.moreAboutYou),
    ];

    String photoLabel() => switch (r.photoStatus) {
      PhotoVerificationStatus.notStarted => l10n.visPhotoNotStarted,
      PhotoVerificationStatus.pending => l10n.visPhotoPending,
      PhotoVerificationStatus.verified => l10n.visPhotoVerified,
      PhotoVerificationStatus.rejected => l10n.visPhotoRejected(
        r.photoAttemptsLeft.clamp(0, 9),
      ),
    };

    Widget section(String title, {String? note, required Widget child}) =>
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: AppTypography.section),
              ),
              if (note != null) ...[
                const SizedBox(height: AppSpacing.s1),
                Text(note, style: AppTypography.caption),
              ],
              const SizedBox(height: AppSpacing.s3),
              child,
            ],
          ),
        );

    final activity = r.activity;
    final Widget activityBody;
    if (activity == null) {
      activityBody = StatusBanner(
        title: l10n.visActivityUnavailable,
        body: l10n.visActivityUnavailableBody,
        tone: BannerTone.pending,
      );
    } else if (activity.empty) {
      activityBody = EmptyState(
        art: const IllustrationView(
          NumayaIllustration.notEnoughData,
          width: 128,
        ),
        title: l10n.visActivityEmpty,
        body: l10n.visActivityEmptyBody,
      );
    } else {
      // Bevel-style metric tiles, two per row. Profile views aren't measured, so that tile says so
      // instead of showing a number.
      Widget pair(Widget a, Widget b) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: a),
            const SizedBox(width: AppLayout.itemGap),
            Expanded(child: b),
          ],
        ),
      );
      activityBody = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pair(
            MetricTile(
              icon: NumayaIcons.heart,
              label: l10n.visLikes,
              value: '${activity.likes}',
            ),
            MetricTile(
              icon: NumayaIcons.groups,
              label: l10n.visMatches,
              value: '${activity.matches}',
            ),
          ),
          const SizedBox(height: AppLayout.itemGap),
          pair(
            MetricTile(
              icon: NumayaIcons.message,
              label: l10n.visConversations,
              value: '${activity.conversations}',
            ),
            MetricTile(
              icon: NumayaIcons.eyeOff,
              label: l10n.visViews,
              value: null,
              status: l10n.visNotMeasured,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
            child: Text(
              r.insights == InsightsState.stale
                  ? l10n.visActivityStale
                  : l10n.visActivityUpdated,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    String suggestionTitle(Suggestion s) => switch (s) {
      Suggestion.reviewRestriction => l10n.visSugRestriction,
      Suggestion.readNotice => l10n.visSugNotice,
      Suggestion.resume => l10n.visSugResume,
      Suggestion.finishSetup => l10n.visSugFinish,
      Suggestion.addRequiredPhotos => l10n.visSugReqPhotos,
      Suggestion.addRequiredInterests => l10n.visSugReqInterests,
      Suggestion.addRequiredPrompt => l10n.visSugReqPrompt,
      Suggestion.verifyPhoto => l10n.visSugVerify,
      Suggestion.morePhotos => l10n.visSugPhotos,
      Suggestion.morePrompts => l10n.visSugPrompts,
      Suggestion.addBio => l10n.visSugBio,
      Suggestion.moreInterests => l10n.visSugInterests,
      Suggestion.aboutYou => l10n.visSugAbout,
      Suggestion.moreAboutYou => l10n.visSugMore,
      Suggestion.chooseArea => l10n.visSugArea,
      Suggestion.reviewFilters => l10n.visSugFilters,
    };

    String suggestionWhy(Suggestion s) => switch (s) {
      Suggestion.reviewRestriction => l10n.visWhyRestriction,
      Suggestion.readNotice => l10n.visWhyNotice,
      Suggestion.resume => l10n.visWhyResume,
      Suggestion.finishSetup ||
      Suggestion.addRequiredPhotos ||
      Suggestion.addRequiredInterests ||
      Suggestion.addRequiredPrompt => l10n.visWhyRequired,
      Suggestion.verifyPhoto => l10n.visWhyVerify,
      Suggestion.morePhotos ||
      Suggestion.morePrompts ||
      Suggestion.addBio ||
      Suggestion.moreInterests ||
      Suggestion.aboutYou ||
      Suggestion.moreAboutYou => l10n.visWhyIncomplete,
      Suggestion.chooseArea => l10n.visWhyArea,
      Suggestion.reviewFilters => l10n.visWhyFilters,
    };

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.visTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.visLede,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s4),
          // 1. Hero: visibility status and completeness together (Bevel's one-number summary).
          _HealthHero(
            statusTitle: statusLabel(l10n, r.status),
            statusBody: [
              statusBody,
              for (final q in r.missing) '• ${reqLabel(q)}',
            ].join('\n'),
            tone: statusTone,
            percent: c.percent,
            percentLabel: l10n.completionPercent(c.percent),
            completeLabel: c.percent >= 100
                ? l10n.visComplete
                : l10n.visIncomplete,
            action: statusAction == null
                ? null
                : NumayaButton(
                    label: statusAction.$1,
                    small: true,
                    expand: false,
                    onPressed: statusAction.$2,
                  ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
            child: Text(
              r.status == VisibilityStatus.visible
                  ? l10n.visVisibleLimits
                  : l10n.visSourceNote,
              style: AppTypography.caption,
            ),
          ),

          // 2. Profile completeness, part by part
          section(
            l10n.visCompleteness,
            note: l10n.visCompletenessNote,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListGroup(
                  children: [
                    for (final (label, part, s) in parts)
                      // Status in the tile (FP-04): green check when done, amber when there is
                      // something to add; the value says it in words too.
                      ListRow(
                        leading: part.complete
                            ? NumayaIcons.check
                            : NumayaIcons.pending,
                        tone: part.complete
                            ? AccentTone.positive
                            : AccentTone.caution,
                        label: label,
                        value: part.complete
                            ? l10n.visDone
                            : l10n.completionProgress(
                                part.done.clamp(0, part.total),
                                part.total,
                              ),
                        onTap: part.complete ? null : () => act(s),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Discovery setup
          section(
            l10n.visDiscovery,
            note: l10n.visDiscoveryNote,
            child: ListGroup(
              children: [
                ListRow(
                  leading: NumayaIcons.location,
                  tone: r.areaSet ? AccentTone.positive : AccentTone.caution,
                  label: l10n.visArea,
                  detail: r.areaSet ? null : l10n.visAreaMissing,
                  value:
                      ref.watch(profileDetailsProvider).area ?? l10n.visNotSet,
                  onTap: () => unawaited(chooseArea()),
                ),
                ListRow(
                  leading: NumayaIcons.heart,
                  tone: r.openToSet ? AccentTone.positive : AccentTone.caution,
                  label: l10n.visOpenTo,
                  value: r.openToSet ? l10n.visSet : l10n.visNotSet,
                ),
                ListRow(
                  leading: NumayaIcons.filter,
                  tone: r.deckSize > 0 && r.filtersFit == 0
                      ? AccentTone.caution
                      : AccentTone.positive,
                  label: l10n.visFilters,
                  detail: r.deckSize > 0 && r.filtersFit == 0
                      ? l10n.visFiltersEmpty
                      : null,
                  value: l10n.visFiltersFit(r.filtersFit, r.deckSize),
                  onTap: () => unawaited(showFiltersSheet(context, ref)),
                ),
              ],
            ),
          ),

          // 4. Verification
          section(
            l10n.visVerification,
            note: l10n.visVerificationNote,
            child: ListGroup(
              children: [
                ListRow(
                  leading: NumayaIcons.user,
                  tone: r.phoneVerified
                      ? AccentTone.positive
                      : AccentTone.caution,
                  label: l10n.visPhone,
                  value: r.phoneVerified
                      ? l10n.visPhotoVerified
                      : l10n.visNotSet,
                ),
                ListRow(
                  leading: NumayaIcons.verified,
                  tone: switch (r.photoStatus) {
                    PhotoVerificationStatus.verified => AccentTone.positive,
                    PhotoVerificationStatus.pending => AccentTone.info,
                    _ => AccentTone.caution,
                  },
                  label: l10n.visPhoto,
                  value: photoLabel(),
                  onTap:
                      r.photoStatus == PhotoVerificationStatus.verified ||
                          r.photoStatus == PhotoVerificationStatus.pending
                      ? null
                      : () => act(Suggestion.verifyPhoto),
                ),
              ],
            ),
          ),

          // 5. Account notices
          section(
            l10n.visNotices,
            child: switch (r.notice) {
              NoticeState.none => ListGroup(
                children: [
                  ListRow(
                    leading: NumayaIcons.check,
                    tone: AccentTone.positive,
                    label: l10n.visNoNotices,
                    detail: l10n.visDemoNoticeSource,
                  ),
                ],
              ),
              NoticeState.notice => StatusBanner(
                title: l10n.visNoticeTitle,
                body: l10n.visNoticeBody,
                tone: BannerTone.pending,
                action: NumayaButton(
                  label: l10n.visReadNotice,
                  small: true,
                  expand: false,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () => act(Suggestion.readNotice),
                ),
              ),
              NoticeState.restricted => StatusBanner(
                title: l10n.visRestrictedTitle,
                body: l10n.visRestrictedBody,
                tone: BannerTone.error,
                action: NumayaButton(
                  label: l10n.visReviewNotice,
                  small: true,
                  expand: false,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () => act(Suggestion.reviewRestriction),
                ),
              ),
              NoticeState.unavailable => StatusBanner(
                title: l10n.visStatusCantCheck,
                body: l10n.visNoticesUnavailable,
                tone: BannerTone.pending,
                action: NumayaButton(
                  label: l10n.discoverRetry,
                  small: true,
                  expand: false,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () => signals.setNotice(NoticeState.none),
                ),
              ),
            },
          ),

          // 6. Activity
          section(
            l10n.visActivity,
            note: l10n.visActivityNote,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                    label: l10n.visSampleData,
                    tone: BadgeTone.brand,
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                activityBody,
                const SizedBox(height: AppSpacing.s2),
                Text(l10n.visActivityMeaning, style: AppTypography.caption),
              ],
            ),
          ),

          // 7. Suggestions
          section(
            l10n.visSuggestions,
            note: r.suggestions.isEmpty ? null : l10n.visSuggestionsNote,
            child: r.suggestions.isEmpty
                ? StatusBanner(
                    title: l10n.visNoSuggestions,
                    body: l10n.visNoSuggestionsBody,
                  )
                : ListGroup(
                    children: [
                      for (final s in r.suggestions)
                        ListRow(
                          leading: NumayaIcons.sparkle,
                          tone: AccentTone.brand,
                          label: suggestionTitle(s),
                          detail: suggestionWhy(s),
                          onTap: () => act(s),
                        ),
                    ],
                  ),
          ),

          const SizedBox(height: AppSpacing.s6),
          ListGroup(
            children: [
              ListRow(
                leading: NumayaIcons.info,
                tone: AccentTone.info,
                label: l10n.visHowItWorks,
                onTap: () => open(Routes.visibilityAbout),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            l10n.visCheckedAt(DateFormat('HH:mm').format(r.checkedAt)),
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
      ),
    );
  }
}

/// "How this works" (§9): what is measured, how, from what, when it updates, what you can change
/// and what this page can't determine.
class VisibilityAboutScreen extends StatelessWidget {
  const VisibilityAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (l10n.visAboutMeasuredTitle, l10n.visAboutMeasuredBody),
      (l10n.visAboutHowTitle, l10n.visAboutHowBody),
      (l10n.visAboutDataTitle, l10n.visAboutDataBody),
      (l10n.visAboutWhenTitle, l10n.visAboutWhenBody),
      (l10n.visAboutChangeTitle, l10n.visAboutChangeBody),
      (l10n.visAboutCantTitle, l10n.visAboutCantBody),
    ];
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.visHowItWorks,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          const IllustrationSlot(
            slot: 'health_how_it_works',
            label: 'How visibility is checked',
            aspectRatio: IllustrationSlot.header,
          ),
          const SizedBox(height: AppSpacing.s5),
          for (final (title, body) in items) ...[
            ProfileSectionCard(
              title: title,
              child: Text(body, style: AppTypography.body),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          InfoCard(
            icon: NumayaIcons.info,
            title: l10n.visAboutDemoTitle,
            body: l10n.visAboutDemoBody,
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
      ),
    );
  }
}

/// The Account Health hero: a tinted status pill with its explanation and action, and profile
/// completeness as one large number over a thick bar. Everything shown comes from the visibility
/// report and the member's own entries; nothing is predicted.
class _HealthHero extends StatelessWidget {
  const _HealthHero({
    required this.statusTitle,
    required this.statusBody,
    required this.tone,
    required this.percent,
    required this.percentLabel,
    required this.completeLabel,
    this.action,
  });

  final String statusTitle;
  final String statusBody;
  final BannerTone tone;
  final int percent;
  final String percentLabel;
  final String completeLabel;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, NumayaIcons icon) = switch (tone) {
      BannerTone.success => (
        AppColors.accentTint,
        AppColors.accentOnTint,
        NumayaIcons.verified,
      ),
      BannerTone.info => (
        AppColors.accentTint,
        AppColors.accentOnTint,
        NumayaIcons.info,
      ),
      BannerTone.pending => (
        AppColors.warningTint,
        AppColors.warning,
        NumayaIcons.pending,
      ),
      BannerTone.error => (
        AppColors.dangerTint,
        AppColors.negative,
        NumayaIcons.alert,
      ),
    };
    final number = percentLabel.split(' ').first;
    final rest = percentLabel.substring(number.length);
    return Container(
      padding: const EdgeInsets.all(AppLayout.heroPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.heroCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            header: true,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: AppRadii.all(AppRadii.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumayaIcon(icon, size: 18, color: fg),
                  const SizedBox(width: AppLayout.compactIconGap),
                  Flexible(
                    child: Text(
                      statusTitle,
                      style: AppTypography.weight(
                        AppTypography.bodySm,
                        AppTypography.bold,
                      ).copyWith(color: fg),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            statusBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.s4),
            action!,
          ],
          const SizedBox(height: AppSpacing.s6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: number,
                        style: AppTypography.metric.copyWith(
                          fontSize: 52,
                          height: 56 / 52,
                          color: AppColors.accentOnTint,
                        ),
                      ),
                      TextSpan(text: rest, style: AppTypography.metricUnit),
                    ],
                  ),
                ),
              ),
              StatusBadge(label: completeLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          ClipRRect(
            borderRadius: AppRadii.all(AppRadii.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (percent / 100).clamp(0, 1)),
              duration: AppMotion.duration(context, AppMotion.progress),
              curve: AppMotion.easeOut,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                color: AppColors.accent,
                backgroundColor: AppColors.fill,
                semanticsLabel: percentLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
