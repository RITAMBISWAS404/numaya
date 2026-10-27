import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/home_shell.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/domain/profile_draft.dart';

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
                          child: Semantics(
                            label: l10n.profileInitialLabel,
                            excludeSemantics: true,
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
                        Center(
                          child: NumayaButton(
                            label: l10n.profileEdit,
                            small: true,
                            variant: NumayaButtonVariant.secondary,
                            icon: NumayaIcons.edit,
                            onPressed: () => context.push(Routes.editProfile),
                          ),
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
