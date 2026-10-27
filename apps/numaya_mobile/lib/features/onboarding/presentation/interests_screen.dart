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
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.interestsLabel,
                    style: AppTypography.weight(
                      AppTypography.label,
                      AppTypography.semibold,
                    ),
                  ),
                ),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.interestsSelected(count),
                    style: AppTypography.label.copyWith(
                      color: AppColors.textMuted,
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
                children: [
                  for (final interest in group.interests)
                    NumayaChip(
                      label: interest,
                      selected: draft.interests.contains(interest),
                      available: !atMax,
                      onTap: () => controller.toggleInterest(interest),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s5),
            ],
            if (atMax) ...[
              FieldNote(l10n.interestsMaxReached),
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
                onTap: () => showPromptEditor(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prompt editor (B-27 in Numaya form): pick a question, write an answer of up to 150 characters.
Future<void> showPromptEditor(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  return showNumayaSheet<void>(
    context: context,
    title: l10n.editPromptTitle,
    closeLabel: l10n.close,
    tall: true,
    builder: (context) => const _PromptEditor(),
  );
}

class _PromptEditor extends ConsumerStatefulWidget {
  const _PromptEditor();

  @override
  ConsumerState<_PromptEditor> createState() => _PromptEditorState();
}

class _PromptEditorState extends ConsumerState<_PromptEditor> {
  late String _question;
  late final TextEditingController _answer;

  @override
  void initState() {
    super.initState();
    final prompt = ref.read(onboardingProvider).draft.prompt;
    _question = prompt?.question ?? kPromptQuestions.first;
    _answer = TextEditingController(text: prompt?.answer ?? '')
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final answer = _answer.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OptionGroup(
                  legend: l10n.promptPick,
                  children: [
                    for (final q in kPromptQuestions)
                      OptionCard(
                        label: q,
                        selected: q == _question,
                        onTap: () => setState(() => _question = q),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.fieldGap),
                NumayaTextField(
                  label: l10n.promptAnswerLabel,
                  controller: _answer,
                  multiline: true,
                  maxLength: PromptAnswer.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  placeholder: l10n.promptAnswerPlaceholder,
                  trailingNote: l10n.promptCounter(
                    _answer.text.length,
                    PromptAnswer.maxLength,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
            ),
          ),
        ),
        NumayaButton(
          label: l10n.promptSave,
          onPressed: answer.isEmpty
              ? null
              : () {
                  ref
                      .read(onboardingProvider.notifier)
                      .setPrompt(_question, answer);
                  Navigator.of(context).pop();
                },
        ),
        if (answer.isEmpty) ...[
          const SizedBox(height: AppSpacing.s2),
          Text(
            l10n.promptWriteToSave,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ],
    );
  }
}
