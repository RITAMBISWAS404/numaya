import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/auth_copy.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'edit_guard.dart';

/// B-17 interests (3 to 5, a hard maximum) and one prompt answer.
class InterestsScreen extends ConsumerWidget {
  const InterestsScreen({super.key, this.editing = false});

  final bool editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final count = draft.interests.length;
    final atMax = count >= ProfileRules.maxInterests;
    final valid = draft.interestsComplete;
    final caption = count < ProfileRules.minInterests
        ? l10n.interestsPickMore(ProfileRules.minInterests - count)
        : draft.prompt == null
        ? l10n.interestsNeedPrompt
        : l10n.interestsCount(count);

    Future<void> next() async {
      if (editing) {
        await controller.saveEdits();
        if (!context.mounted) return;
        NumayaToast.show(context, l10n.editSaved);
        context.pop();
        return;
      }
      controller.completeStep(SetupStep.interests);
      unawaited(context.push(Routes.photos));
    }

    return EditGuard(
      enabled: editing,
      child: NumayaScreen(
        top: NumayaTopBar(
          onBack: () => context.pop(),
          backLabel: l10n.back,
          step: editing ? null : SignUpProgress.interests,
          steps: editing ? null : SignUpProgress.total,
          title: editing ? l10n.setupInterestsLabel : null,
        ),
        footer: editing
            ? NumayaButton(label: l10n.save, onPressed: valid ? next : null)
            : StepFooter(
                caption: caption,
                action: NumayaFab(
                  semanticLabel: l10n.next,
                  onPressed: valid ? next : null,
                ),
              ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!editing)
              ScreenHeader(
                title: l10n.interestsTitle,
                lede: l10n.interestsLede,
                art: const IllustrationView(
                  NumayaIllustration.interests,
                  width: 72,
                ),
              ),
            const SizedBox(height: AppSpacing.s6),
            // V16 chip-group label: small bold capitals, the count in muted tracked capitals.
            Row(
              children: [
                Expanded(child: FieldLabel(l10n.interestsLabel)),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.interestsSelected(count).toUpperCase(),
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w400,
                      fontVariations: const [FontVariation('wght', 400)],
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            for (final group in kInterestGroups) ...[
              ChipSet(
                label: group.label,
                emoji: group.emoji,
                tone: MarkTone.byName(group.tone),
                children: [
                  for (final interest in group.interests)
                    NumayaChip(
                      label: interest,
                      emoji: kInterestEmoji[interest],
                      selected: draft.interests.contains(interest),
                      available: !atMax,
                      onTap: () => controller.toggleInterest(interest),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s5),
            ],
            const SizedBox(height: AppSpacing.s3),
            NumayaSection(
              title: l10n.promptSectionTitle,
              description: l10n.promptSectionBody,
              child: PromptCard(
                question: draft.prompt?.question ?? kPromptQuestions.first,
                answer: draft.prompt?.answer,
                emptyLabel: l10n.promptEmpty,
                editLabel: l10n.promptEditLabel,
                // The editor only updates the draft; this screen's own Save persists it.
                onTap: () => context.push(Routes.prompt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
