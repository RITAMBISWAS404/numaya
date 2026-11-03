import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../../account_health/application/visibility_report.dart';
import '../../account_health/presentation/visibility_screen.dart';
import '../../home/presentation/home_shell.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../../premium/application/premium_controller.dart';
import '../../verification/application/verification_controller.dart';
import '../application/profile_details_controller.dart';
import '../domain/profile_details.dart';

/// B-23 Profile tab (premium refinement): a hero card (avatar beside the name and summary, the
/// phone-verified badge, interests, Edit profile and Preview), the completion card, four profile
/// tiles (visibility, Opening Moves, verification, Premium), the prompt, then one support group.
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
    final completion = ProfileCompletion.of(draft, details).percent;
    final age = draft.ageOn(ref.read(onboardingProvider.notifier).today);
    final gender = switch (draft.gender) {
      Gender.woman => l10n.genderWoman,
      Gender.man => l10n.genderMan,
      Gender.nonbinary => l10n.genderNonbinary,
      null => null,
    };
    final looking = draft.lookingFor.isEmpty
        ? null
        : switch (LookingFor.values.firstWhere(draft.lookingFor.contains)) {
            LookingFor.longTerm => l10n.profileLookingLongTerm,
            LookingFor.open => l10n.profileLookingOpen,
            LookingFor.casual => l10n.profileLookingCasual,
          };
    final summary = [?gender, ?looking].join(' · ');
    final mainPhoto = draft.photos.isEmpty ? null : draft.photos.first.source;
    final initial = draft.firstName.trim().isEmpty
        ? '?'
        : draft.firstName.trim().characters.first.toUpperCase();

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
                      outline: true,
                      label: l10n.helpTitle,
                      onPressed: () => context.push(Routes.help),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    NavIconButton(
                      icon: NumayaIcons.settings,
                      outline: true,
                      label: l10n.profileSettings,
                      onPressed: () => context.push(Routes.settings),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.screenGutter,
                      AppLayout.screenTop,
                      AppLayout.screenGutter,
                      AppSpacing.s8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Identity: one hero card (Meetup's member page) holding who you are,
                        // what you're into and the two things you do with your profile.
                        Container(
                          padding: const EdgeInsets.all(AppLayout.heroPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadii.all(AppRadii.heroCard),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  ExcludeSemantics(
                                    child: Container(
                                      width: AppSizes.avatarProfile,
                                      height: AppSizes.avatarProfile,
                                      decoration: const BoxDecoration(
                                        color: AppColors.identity,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.antiAlias,
                                      child: mainPhoto != null
                                          ? Image(
                                              image: localImage(
                                                mainPhoto,
                                                width: 300,
                                              ),
                                              width: AppSizes.avatarProfile,
                                              height: AppSizes.avatarProfile,
                                              fit: BoxFit.cover,
                                            )
                                          : Text(
                                              initial,
                                              style: AppTypography.hero
                                                  .copyWith(
                                                    fontSize: 40,
                                                    height: 1,
                                                    color: AppColors.onIdentity,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Semantics(
                                          header: true,
                                          child: Text(
                                            age == null
                                                ? draft.firstName
                                                : l10n.profileNameAge(
                                                    draft.firstName,
                                                    age,
                                                  ),
                                            style: AppTypography.headline,
                                          ),
                                        ),
                                        if (summary.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            summary,
                                            style: AppTypography.bodySm
                                                .copyWith(
                                                  color: AppColors.textMuted,
                                                ),
                                          ),
                                        ],
                                        const SizedBox(height: AppSpacing.s2),
                                        StatusBadge(
                                          label: l10n.profilePhoneVerified,
                                          icon: NumayaIcons.verified,
                                          tone: BadgeTone.brand,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (draft.interests.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.s5),
                                Wrap(
                                  spacing: AppSpacing.s2,
                                  runSpacing: AppSpacing.s2,
                                  children: [
                                    for (final interest in draft.interests)
                                      _StaticChip(
                                        label: interest,
                                        emoji: kInterestEmoji[interest],
                                      ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: AppSpacing.s5),
                              Row(
                                children: [
                                  Expanded(
                                    child: NumayaButton(
                                      label: l10n.profileEdit,
                                      icon: NumayaIcons.edit,
                                      onPressed: () =>
                                          context.push(Routes.editProfile),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s3),
                                  // Preview as a filled square beside the primary: one action
                                  // leads, the second stays one tap away (and named for
                                  // screen readers and on long press).
                                  Tooltip(
                                    message: l10n.editPreview,
                                    excludeFromSemantics: true,
                                    child: Pressable(
                                      onTap: () => context.push(Routes.preview),
                                      semanticLabel: l10n.editPreview,
                                      excludeChildSemantics: true,
                                      borderRadius: AppRadii.all(AppRadii.pill),
                                      child: Container(
                                        width: AppSizes.buttonHeight,
                                        height: AppSizes.buttonHeight,
                                        decoration: const BoxDecoration(
                                          color: AppColors.field,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const NumayaIcon(
                                          NumayaIcons.public,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        // 2. Completion: what's left, with the one way to finish it.
                        CompletionCard(
                          percent: completion,
                          title: l10n.profileCompletionLabel(completion),
                          body: completion < 100
                              ? l10n.completionLede
                              : l10n.completionDone,
                          actionLabel: l10n.profileComplete,
                          onAction: () => context.push(Routes.completion),
                        ),
                        // 3. Your profile at a glance: four tiles (Meetup's action tiles) instead of
                        // a list of rows.
                        const SizedBox(height: AppLayout.sectionGap),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.profileYourProfile,
                            style: AppTypography.section,
                          ),
                        ),
                        const SizedBox(height: AppLayout.headingGap),
                        _TileGrid(
                          tiles: [
                            _Tile(
                              icon: NumayaIcons.explore,
                              label: l10n.visTitle,
                              value: VisibilityScreen.statusLabel(
                                l10n,
                                ref.watch(visibilityReportProvider).status,
                              ),
                              onTap: () => context.push(Routes.visibility),
                            ),
                            _Tile(
                              icon: NumayaIcons.message,
                              label: l10n.openingMovesTitle,
                              value: l10n.openingMovesCount(
                                details.openingMoves.length,
                              ),
                              onTap: () => context.push(Routes.openingMoves),
                            ),
                            _Tile(
                              icon: NumayaIcons.verified,
                              label: l10n.editVerify,
                              value: switch (verification) {
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
                            _Tile(
                              icon: NumayaIcons.premium,
                              label: l10n.premiumName,
                              value: premium.active
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.s1,
                              AppSpacing.s3,
                              0,
                              0,
                            ),
                            child: Text(
                              l10n.profilePromptCaption,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
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
                              label: l10n.safetyTitle,
                              onTap: () => context.push(Routes.safety),
                            ),
                            ListRow(
                              leading: NumayaIcons.help,
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

/// A content chip in the hero card: the fill grey, a full pill, emoji and medium label.
class _StaticChip extends StatelessWidget {
  const _StaticChip({required this.label, this.emoji});

  final String label;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.chip,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: AppRadii.all(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Emoji(emoji!, size: 15.5),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.weight(
                AppTypography.label,
                AppTypography.medium,
              ).copyWith(fontSize: 15, color: AppColors.ink),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NumayaIcon(
                NumayaIcons.premium,
                size: 24,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.s2),
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

/// One profile tile: a purple icon, a bold label and the current value, the whole tile tappable.
class _Tile {
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final NumayaIcons icon;
  final String label;
  final String value;
  final VoidCallback onTap;
}

/// Tiles two to a row, each row as tall as its tallest tile.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.tiles});

  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppLayout.itemGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tile(tiles[i])),
                const SizedBox(width: AppLayout.itemGap),
                Expanded(
                  child: i + 1 < tiles.length
                      ? _tile(tiles[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _tile(_Tile t) => Pressable(
    onTap: t.onTap,
    semanticLabel: '${t.label}, ${t.value}',
    excludeChildSemantics: true,
    borderRadius: AppRadii.all(AppRadii.card),
    child: Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumayaIcon(t.icon, size: 26, color: AppColors.accentOnTint),
          const SizedBox(height: AppSpacing.s4),
          Text(
            t.label,
            style: AppTypography.weight(
              AppTypography.body,
              AppTypography.semibold,
            ),
          ),
          const SizedBox(height: 2),
          Text(t.value, style: AppTypography.caption),
        ],
      ),
    ),
  );
}
