import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../profile/domain/profile_details.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'step_scaffold.dart';

/// Every prompt answered so far, in slot order (slot 0 is the draft's; 1 and 2 are the extras).
List<PromptAnswer> answeredPrompts(
  ProfileDraft draft,
  ProfileDetails details,
) => [?draft.prompt, ...details.extraPrompts];

/// OB-16: up to three prompts, the first required (Hinge "Pick Prompts" [O], OD-10). A filled slot
/// opens its answer; the next empty one adds a prompt. The editor (OB-18) won't reuse a question.
class PromptsScreen extends ConsumerWidget {
  const PromptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final details = ref.watch(profileDetailsProvider);
    final first = draft.prompt;
    final extras = details.extraPrompts;
    final count = (first == null ? 0 : 1) + extras.length;
    // Slots shown: every filled one plus the next empty one, at most three.
    final slots = first == null
        ? 1
        : (1 + extras.length + 1).clamp(1, DetailRules.maxPrompts);

    PromptAnswer? at(int slot) =>
        slot == 0 ? first : extras.elementAtOrNull(slot - 1);

    return OnboardingStepScaffold(
      step: SetupStep.prompts,
      title: l10n.obPromptsTitle,
      lede: l10n.obPromptsLede,
      caption: draft.promptComplete
          ? l10n.obPromptsFooter(count)
          : l10n.obPromptsFooterMissing,
      canContinue: draft.promptComplete,
      onContinue: () => continueFrom(context, ref, SetupStep.prompts),
      children: [
        for (var slot = 0; slot < slots; slot++) ...[
          Row(
            children: [
              Expanded(child: FieldLabel(l10n.obPromptSlot(slot + 1))),
              Text(
                slot == 0 ? l10n.obPromptRequired : l10n.obPromptOptional,
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          PromptCard(
            question: at(slot)?.question ?? l10n.obPromptAdd,
            answer: at(slot)?.answer,
            emptyLabel: l10n.promptEmpty,
            editLabel: l10n.promptEditLabel,
            onTap: () => context.push('${Routes.prompt}?slot=$slot'),
          ),
          const SizedBox(height: AppSpacing.s5),
        ],
      ],
    );
  }
}

/// OB-19: a short bio, optional, up to [DetailRules.bioLength] characters, saved as it's typed
/// (trimmed; whitespace alone counts as empty).
class BioScreen extends ConsumerStatefulWidget {
  const BioScreen({super.key});

  @override
  ConsumerState<BioScreen> createState() => _BioScreenState();
}

class _BioScreenState extends ConsumerState<BioScreen> {
  late final TextEditingController _bio = TextEditingController(
    text: ref.read(profileDetailsProvider).bio,
  );

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = ref.read(profileDetailsProvider.notifier);
    final bio = ref.watch(profileDetailsProvider.select((d) => d.bio));
    final left = DetailRules.bioLength - _bio.text.characters.length;

    return OnboardingStepScaffold(
      step: SetupStep.bio,
      title: l10n.obBioTitle,
      lede: l10n.obBioLede,
      caption: bio.isEmpty ? l10n.obBioFooterNone : l10n.obBioFooter,
      canContinue: true,
      onContinue: () => continueFrom(context, ref, SetupStep.bio),
      onSkip: () {
        _bio.clear();
        details.setBio('');
        continueFrom(context, ref, SetupStep.bio);
      },
      children: [
        NumayaTextField(
          label: l10n.obBioLabel,
          controller: _bio,
          multiline: true,
          maxLength: DetailRules.bioLength,
          textCapitalization: TextCapitalization.sentences,
          placeholder: l10n.obBioPlaceholder,
          trailingNote: l10n.promptCharsLeft(left),
          onChanged: (v) {
            setState(() {});
            details.setBio(v);
          },
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(l10n.obBioTip, style: AppTypography.caption),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s3),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLink(
              label: l10n.obBioClear,
              muted: true,
              onPressed: () {
                _bio.clear();
                details.setBio('');
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          ProfileSectionCard(
            title: l10n.obBioPreview,
            child: Text(bio, style: AppTypography.body),
          ),
        ],
      ],
    );
  }
}
