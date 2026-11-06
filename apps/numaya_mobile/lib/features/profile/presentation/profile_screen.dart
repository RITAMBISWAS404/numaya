import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/release_scope.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../../account_health/application/visibility_report.dart';
import '../../account_health/presentation/visibility_screen.dart';
import '../../experiments/experiments.dart';
import '../../home/presentation/home_shell.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../premium/application/premium_controller.dart';
import '../../verification/application/verification_controller.dart';
import '../application/profile_details_controller.dart';
import '../domain/profile_details.dart';
import 'profile_variants.dart';

/// B-23 Profile tab: the summary card (UI-042: a large round photo over the card, name,
/// verification state, Edit profile), the completion card, the profile rows (visibility,
/// verification, Premium; Opening Moves only when the release includes it, UI-031), the prompt,
/// then one support group.
/// Everything shown is what the member entered; no score or activity is invented.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final details = ref.watch(profileDetailsProvider);
    final premium = ref.watch(premiumProvider);
    final verification = ref.watch(photoVerificationProvider).status;
    final parts = ProfileCompletion.of(draft, details);
    final completion = parts.percent;
    // EXP-002 / EXP-004 (Experiment Lab only; release builds show the refined candidate).
    final headerVariant = ref.watch(
      experimentVariantProvider(Experiment.profileHeader),
    );
    final completionVariant = ref.watch(
      experimentVariantProvider(Experiment.completionCard),
    );
    final age = draft.ageOn(ref.read(onboardingProvider.notifier).today);
    final mainPhoto = draft.photos.isEmpty ? null : draft.photos.first.source;
    final initial = draft.firstName.trim().isEmpty
        ? '?'
        : draft.firstName.trim().characters.first.toUpperCase();

    ProfileHeaderData header() => ProfileHeaderData(
      photo: mainPhoto,
      initial: initial,
      name: age == null
          ? draft.firstName
          : l10n.profileNameAge(draft.firstName, age),
      verification: verification,
      onEdit: () => context.push(Routes.editProfile),
      onVerify: () => context.push(Routes.verifyPhoto),
      onPreview: () => context.push(Routes.preview),
    );
    // EXP-004 B: the first unfinished part in the completion hub's order, and where its editor
    // is (the bio editor is a sheet inside the hub, so Bio opens the hub).
    final candidates = [
      (l10n.completionPhotos, parts.photos, Routes.editProfile),
      (
        l10n.completionPrompts,
        parts.prompts,
        parts.prompts.done == 0
            ? Routes.editPrompt
            : '${Routes.editPrompt}?slot=${parts.prompts.done.clamp(1, 2)}',
      ),
      (l10n.completionInterests, parts.interests, Routes.editInterests),
      (l10n.completionBio, parts.bio, Routes.completion),
      (l10n.completionAbout, parts.about, Routes.editProfile),
      (l10n.completionMore, parts.moreAbout, Routes.editProfile),
    ];
    final firstOpen = candidates
        .where((c) => c.$2.done < c.$2.total)
        .firstOrNull;
    final next = firstOpen == null
        ? null
        : ((name: firstOpen.$1, part: firstOpen.$2), firstOpen.$3);

    return ColoredBox(
      color: AppColors.canvas,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.contentMax),
            child: Column(
              children: [
                TabHeader(
                  title: l10n.tabProfile,
                  actions: [
                    NavIconButton(
                      icon: NumayaIcons.help,
                      label: l10n.helpTitle,
                      onPressed: () => context.push(Routes.help),
                    ),
                    NavIconButton(
                      icon: NumayaIcons.settings,
                      label: l10n.profileSettings,
                      onPressed: () => context.push(Routes.settings),
                    ),
                  ],
                ),
                Expanded(
                  // Scrolls beneath the frosted tab bar and can always scroll clear of it.
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.screenGutter,
                      AppLayout.screenTop,
                      AppLayout.screenGutter,
                      AppSpacing.s8 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Identity (UI-042, A-019): a large round photo centred over the top
                        // edge of a white card; name, verification state and Edit profile below.
                        // Interests and details stay in Edit profile and the preview, which
                        // Edit profile opens (so the old globe shortcut here is gone).
                        switch (headerVariant) {
                          ExpVariant.current => _ProfileSummary(
                            photo: mainPhoto,
                            initial: initial,
                            name: age == null
                                ? draft.firstName
                                : l10n.profileNameAge(draft.firstName, age),
                            verification: verification,
                            onEdit: () => context.push(Routes.editProfile),
                            onVerify: () => context.push(Routes.verifyPhoto),
                          ),
                          ExpVariant.a => ProfileHeaderCover(data: header()),
                          ExpVariant.b => ProfileHeaderCompact(data: header()),
                          ExpVariant.c => ProfileHeaderActions(data: header()),
                        },
                        const SizedBox(height: AppSpacing.s4),
                        // 2. Completion: what's left, with the one way to finish it.
                        switch (completionVariant) {
                          ExpVariant.current => CompletionCard(
                            percent: completion,
                            title: l10n.profileCompletionLabel(completion),
                            // The bar and "Complete profile" say it; only the finished state
                            // needs words.
                            body: completion < 100 ? null : l10n.completionDone,
                            actionLabel: l10n.profileComplete,
                            onAction: () => context.push(Routes.completion),
                          ),
                          ExpVariant.a => CompletionBanner(
                            percent: completion,
                            onOpen: () => context.push(Routes.completion),
                          ),
                          ExpVariant.b => CompletionNextTask(
                            percent: completion,
                            next: next?.$1,
                            onContinue: () =>
                                context.push(next?.$2 ?? Routes.completion),
                            onSeeAll: () => context.push(Routes.completion),
                          ),
                          ExpVariant.c => CompletionWithCat(
                            percent: completion,
                            title: l10n.profileCompletionLabel(completion),
                            actionLabel: l10n.profileComplete,
                            onAction: () => context.push(Routes.completion),
                          ),
                        },
                        // 3. Your profile: Ente Menu Items (ER-05). The four half-empty tiles became
                        // rows with their status as the subtitle, the way Ente lists settings.
                        const SizedBox(height: AppLayout.sectionGap),
                        ListGroup(
                          title: l10n.profileYourProfile,
                          children: [
                            ListRow(
                              leading: NumayaIcons.explore,
                              tone: AccentTone.info,
                              label: l10n.visTitle,
                              detail: VisibilityScreen.statusLabel(
                                l10n,
                                ref.watch(visibilityReportProvider).status,
                              ),
                              onTap: () => context.push(Routes.visibility),
                            ),
                            if (ReleaseScope.openingMoves)
                              ListRow(
                                leading: NumayaIcons.message,
                                tone: AccentTone.social,
                                label: l10n.openingMovesTitle,
                                detail: l10n.openingMovesCount(
                                  details.openingMoves.length,
                                ),
                                onTap: () => context.push(Routes.openingMoves),
                              ),
                            ListRow(
                              leading: NumayaIcons.verified,
                              tone: AccentTone.positive,
                              label: l10n.editVerify,
                              detail: switch (verification) {
                                PhotoVerificationStatus.verified =>
                                  l10n.verifyStatusVerified,
                                PhotoVerificationStatus.pending =>
                                  l10n.verifyStatusPending,
                                PhotoVerificationStatus.rejected =>
                                  l10n.verifyStatusRejected,
                                PhotoVerificationStatus.notStarted =>
                                  l10n.verifyStatusNone,
                              },
                              onTap: () => context.push(Routes.verifyPhoto),
                            ),
                            ListRow(
                              leading: NumayaIcons.premium,
                              tone: AccentTone.brand,
                              label: l10n.premiumName,
                              detail: premium.active
                                  ? l10n.premiumActive
                                  : l10n.premiumExplore,
                              onTap: () => context.push(Routes.premium),
                            ),
                          ],
                        ),
                        if (draft.prompt != null) ...[
                          const SizedBox(height: AppLayout.sectionGap),
                          NumayaSection(
                            title: l10n.profilePromptTitle,
                            child: PromptCard(
                              question: draft.prompt!.question,
                              answer: draft.prompt!.answer,
                              editLabel: l10n.promptEditLabel,
                              onTap: () => context.push(Routes.editPrompt),
                            ),
                          ),
                        ],
                        if (premium.active) ...[
                          const SizedBox(height: AppLayout.sectionGap),
                          _PremiumCard(
                            active: premium.active,
                            until: premium.activeUntil,
                            onTap: () => context.push(Routes.premium),
                          ),
                        ],
                        // 4. Everything else in one quiet group.
                        const SizedBox(height: AppLayout.sectionGap),
                        ListGroup(
                          title: l10n.profileSafetySupport,
                          children: [
                            ListRow(
                              leading: NumayaIcons.shield,
                              tone: AccentTone.positive,
                              label: l10n.safetyTitle,
                              onTap: () => context.push(Routes.safety),
                            ),
                            ListRow(
                              leading: NumayaIcons.help,
                              tone: AccentTone.info,
                              label: l10n.helpTitle,
                              onTap: () => context.push(Routes.help),
                            ),
                            ListRow(
                              leading: NumayaIcons.settings,
                              label: l10n.profileSettings,
                              onTap: () => context.push(Routes.settings),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The Premium entry (B-23 pay-plan card): what it adds, or until when it's active.
class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.active,
    required this.until,
    required this.onTap,
  });

  final bool active;
  final DateTime? until;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(NumayaIcons.premium, tone: AccentTone.brand),
              const SizedBox(width: AppLayout.tileLabelGap),
              Expanded(
                child: Text(l10n.premiumName, style: AppTypography.emptyTitle),
              ),
              if (active)
                StatusBadge(label: l10n.premiumActive, tone: BadgeTone.brand),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            active && until != null
                ? l10n.premiumActiveUntil(
                    MaterialLocalizations.of(context).formatMediumDate(until!),
                  )
                : l10n.premiumCardBody,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: active ? l10n.premiumManage : l10n.premiumExplore,
            small: true,
            expand: false,
            variant: active
                ? NumayaButtonVariant.secondary
                : NumayaButtonVariant.brand,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

/// The Profile tab's summary card (UI-042). The photo is [diameter] across and sits half above
/// the card, ringed in the page colour so its edge reads against both the page and the card.
class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.photo,
    required this.initial,
    required this.name,
    required this.verification,
    required this.onEdit,
    required this.onVerify,
  });

  final String? photo;
  final String initial;
  final String name;
  final PhotoVerificationStatus verification;
  final VoidCallback onEdit;
  final VoidCallback onVerify;

  static const double diameter = 128;
  static const double ring = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outer = diameter + ring * 2;
    final initialText = Text(
      initial,
      style: AppTypography.hero.copyWith(
        fontSize: 48,
        height: 1,
        color: AppColors.onIdentity,
      ),
    );
    final verified = verification == PhotoVerificationStatus.verified;
    final status = switch (verification) {
      PhotoVerificationStatus.verified => l10n.verifyStatusVerified,
      PhotoVerificationStatus.pending => l10n.verifyStatusPending,
      PhotoVerificationStatus.rejected => l10n.verifyStatusRejected,
      PhotoVerificationStatus.notStarted => l10n.verifyStatusNone,
    };
    final badge = StatusBadge(
      label: status,
      icon: verified ? NumayaIcons.verified : NumayaIcons.shield,
      tone: verified ? BadgeTone.brand : BadgeTone.neutral,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The card starts at the photo's middle.
        Container(
          margin: EdgeInsets.only(top: outer / 2),
          padding: EdgeInsets.fromLTRB(
            AppLayout.heroPadding,
            outer / 2 + AppSpacing.s3,
            AppLayout.heroPadding,
            AppLayout.heroPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.heroCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Center(
                // Unverified: the pill opens verification, so the state is also the way to
                // change it.
                child: verified
                    ? badge
                    : Pressable(
                        onTap: onVerify,
                        semanticLabel: '$status. ${l10n.editVerify}',
                        excludeChildSemantics: true,
                        borderRadius: AppRadii.all(AppRadii.pill),
                        child: badge,
                      ),
              ),
              const SizedBox(height: AppSpacing.s5),
              NumayaButton(
                label: l10n.profileEdit,
                icon: NumayaIcons.edit,
                onPressed: onEdit,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ExcludeSemantics(
            child: Container(
              key: const ValueKey('profile-summary-photo'),
              width: outer,
              height: outer,
              padding: const EdgeInsets.all(ring),
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                shape: BoxShape.circle,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.identity,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: photo != null
                    ? Image(
                        image: localImage(photo!, width: 400),
                        width: diameter,
                        height: diameter,
                        fit: BoxFit.cover,
                        // V4-01: a photo file that has gone (cache cleared, file deleted) shows
                        // the initial, never Flutter's red error box.
                        errorBuilder: (_, _, _) => Center(child: initialText),
                      )
                    : initialText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
