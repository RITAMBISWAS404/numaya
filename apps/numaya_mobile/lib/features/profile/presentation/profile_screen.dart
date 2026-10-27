import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/home_shell.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../../premium/application/premium_controller.dart';
import '../../verification/application/verification_controller.dart';
import '../application/profile_details_controller.dart';
import '../domain/profile_details.dart';

/// B-23 Profile tab in V16's layout (screenshot 099-profile): the page title with a round settings
/// button, a navy initials avatar, the name on the hero scale, a summary line, interest chips, an
/// outlined "Edit profile" pill, the prompt card, then grouped rows. Everything shown is what the
/// member entered; no score or activity is invented.
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
    final age = draft.ageIn(ref.read(onboardingProvider.notifier).currentYear);
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
                      label: l10n.helpTitle,
                      onPressed: () => context.push(Routes.help),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    NavIconButton(
                      icon: NumayaIcons.settings,
                      label: l10n.profileSettings,
                      onPressed: () => context.push(Routes.settings),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.s3,
                      AppSpacing.gutter,
                      AppSpacing.s8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CompletionRing(
                            percent: completion,
                            label: l10n.profileCompletionLabel(completion),
                            size: AppSizes.avatar + 16,
                            child: Container(
                              width: AppSizes.avatar,
                              height: AppSizes.avatar,
                              decoration: const BoxDecoration(
                                color: AppColors.identity,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initial,
                                style:
                                    AppTypography.weight(
                                      AppTypography.pageTitle,
                                      AppTypography.semibold,
                                    ).copyWith(
                                      fontSize: 40,
                                      height: 1,
                                      color: AppColors.inkForeground,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Semantics(
                          header: true,
                          child: Text(
                            age == null
                                ? draft.firstName
                                : l10n.profileNameAge(draft.firstName, age),
                            textAlign: TextAlign.center,
                            style: AppTypography.hero,
                          ),
                        ),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s1),
                          Text(
                            summary,
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        if (draft.interests.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s4),
                          Wrap(
                            alignment: WrapAlignment.center,
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
                        const SizedBox(height: AppSpacing.s4),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.s2,
                          runSpacing: AppSpacing.s2,
                          children: [
                            if (completion < 100)
                              NumayaButton(
                                label: l10n.profileComplete,
                                small: true,
                                expand: false,
                                onPressed: () =>
                                    context.push(Routes.completion),
                              ),
                            NumayaButton(
                              label: l10n.profileEdit,
                              small: true,
                              expand: false,
                              variant: NumayaButtonVariant.secondary,
                              icon: NumayaIcons.edit,
                              onPressed: () => context.push(Routes.editProfile),
                            ),
                          ],
                        ),
                        if (draft.prompt != null) ...[
                          const SizedBox(height: AppSpacing.sectionGap),
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
                        const SizedBox(height: AppSpacing.sectionGap),
                        ListGroup(
                          title: l10n.profileYourProfile,
                          children: [
                            ListRow(
                              leading: NumayaIcons.public,
                              label: l10n.editPreview,
                              onTap: () => context.push(Routes.preview),
                            ),
                            ListRow(
                              leading: NumayaIcons.message,
                              label: l10n.openingMovesTitle,
                              value: l10n.openingMovesCount(
                                details.openingMoves.length,
                              ),
                              onTap: () => context.push(Routes.openingMoves),
                            ),
                            ListRow(
                              leading: NumayaIcons.verified,
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
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                        _PremiumCard(
                          active: premium.active,
                          until: premium.activeUntil,
                          onTap: () => context.push(Routes.premium),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
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
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                        ListGroup(
                          title: l10n.profileAccount,
                          children: [
                            ListRow(
                              leading: NumayaIcons.settings,
                              label: l10n.profileSettings,
                              onTap: () => context.push(Routes.settings),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                        ListGroup(
                          title: l10n.profileTrust,
                          children: [
                            ListRow(
                              leading: NumayaIcons.shield,
                              label: l10n.profileVerification,
                              value: l10n.profilePhoneVerified,
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

/// A content chip shown on the page (V16: white, 12pt corner, emoji and medium label).
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
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Emoji(emoji!, size: 15.5),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTypography.card),
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
                : NumayaButtonVariant.primary,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
