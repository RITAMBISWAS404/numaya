import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/home_shell.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/domain/profile_draft.dart';

/// B-23 Profile tab: the member's own profile as others will see it, from what they entered.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final age = draft.ageIn(ref.read(onboardingProvider.notifier).currentYear);
    final looking = [
      for (final value in LookingFor.values)
        if (draft.lookingFor.contains(value))
          switch (value) {
            LookingFor.longTerm => l10n.lookingLongTerm,
            LookingFor.open => l10n.lookingOpen,
            LookingFor.casual => l10n.lookingCasual,
          },
    ];

    return SafeArea(
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
                    AppSpacing.s2,
                    AppSpacing.gutter,
                    AppSizes.tabBar + AppSpacing.s10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PhotoPlaceholder(
                        tone: draft.photos.isEmpty
                            ? 0
                            : draft.photos.first.tone,
                        caption: l10n.profilePhotosPlaceholder,
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Semantics(
                        header: true,
                        child: Text(
                          age == null
                              ? draft.firstName
                              : l10n.profileNameAge(draft.firstName, age),
                          style: AppTypography.hero,
                        ),
                      ),
                      if (looking.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s1),
                        Text(
                          '${l10n.profileLookingFor}: ${looking.join(', ')}',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s5),
                      NumayaButton(
                        label: l10n.profileEdit,
                        variant: NumayaButtonVariant.secondary,
                        icon: NumayaIcons.edit,
                        onPressed: () => context.push(Routes.editProfile),
                      ),
                      if (draft.prompt != null) ...[
                        const SizedBox(height: AppSpacing.sectionGap),
                        PromptCard(
                          question: draft.prompt!.question,
                          answer: draft.prompt!.answer,
                        ),
                      ],
                      if (draft.interests.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sectionGap),
                        NumayaSection(
                          title: l10n.interestsLabel,
                          child: Wrap(
                            spacing: AppSpacing.s2,
                            runSpacing: AppSpacing.s2,
                            children: [
                              for (final interest in draft.interests)
                                _StaticChip(interest),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.tone, required this.caption});

  final int tone;
  final String caption;

  static const _tones = [
    AppColors.surfacePhoto,
    AppColors.surfaceSunken,
    AppColors.brandSubtle,
    AppColors.brandTintStrong,
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: caption,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          decoration: BoxDecoration(
            color: _tones[tone % _tones.length],
            borderRadius: AppRadii.all(AppRadii.photo),
          ),
          padding: const EdgeInsets.all(AppSpacing.s5),
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              const NumayaIcon(
                NumayaIcons.image,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(
                  caption,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticChip extends StatelessWidget {
  const _StaticChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.chip,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.pill),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppBorders.hairline,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.weight(
          AppTypography.label,
          AppTypography.medium,
        ).copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
