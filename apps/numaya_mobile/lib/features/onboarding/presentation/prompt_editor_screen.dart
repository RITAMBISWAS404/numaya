import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../profile/application/profile_details_controller.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';

/// Prompt editor (B-27), V16 "YOUR PROMPT" screen: a capital legend over one white card of the six
/// questions, an outlined answer area with the characters left inside it, and Save prompt with a
/// caption that says why it is disabled. [editing] (from Edit profile) also saves the profile.
/// [slot] 1 and 2 edit the extra prompts of a fuller profile (up to three, B-24), which can also be
/// removed.
class PromptEditorScreen extends ConsumerStatefulWidget {
  const PromptEditorScreen({super.key, this.editing = false, this.slot = 0});

  final bool editing;
  final int slot;

  @override
  ConsumerState<PromptEditorScreen> createState() => _PromptEditorScreenState();
}

class _PromptEditorScreenState extends ConsumerState<PromptEditorScreen> {
  late final PromptAnswer? _saved = widget.slot == 0
      ? ref.read(onboardingProvider).draft.prompt
      : ref
            .read(profileDetailsProvider)
            .extraPrompts
            .elementAtOrNull(widget.slot - 1);
  late String _question = _saved?.question ?? kPromptQuestions.first;
  late final TextEditingController _answer = TextEditingController(
    text: _saved?.answer ?? '',
  )..addListener(() => setState(() {}));
  bool _saving = false;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.slot > 0) {
      ref
          .read(profileDetailsProvider.notifier)
          .setExtraPrompt(widget.slot - 1, _question, _answer.text);
      NumayaToast.show(context, context.l10n.editSaved);
      context.pop();
      return;
    }
    final controller = ref.read(onboardingProvider.notifier);
    controller.setPrompt(_question, _answer.text);
    if (widget.editing) {
      setState(() => _saving = true);
      await controller.saveEdits();
      if (!mounted) return;
      NumayaToast.show(context, context.l10n.editSaved);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final answer = _answer.text.trim();
    final changed =
        _question != _saved?.question || answer != (_saved?.answer ?? '');
    final canSave = answer.isNotEmpty && changed;
    final left = PromptAnswer.maxLength - _answer.text.length;

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: _saving ? null : () => context.pop(),
        backLabel: l10n.back,
        title: l10n.editPromptTitle,
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            label: l10n.promptSave,
            loading: _saving,
            onPressed: canSave ? _save : null,
          ),
          if (widget.slot > 0 && _saved != null) ...[
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              label: l10n.promptRemove,
              variant: NumayaButtonVariant.destructive,
              onPressed: () {
                ref
                    .read(profileDetailsProvider.notifier)
                    .removeExtraPrompt(widget.slot - 1);
                NumayaToast.show(context, l10n.promptRemoved);
                context.pop();
              },
            ),
          ],
          const SizedBox(height: AppSpacing.s3),
          Text(
            answer.isEmpty
                ? l10n.promptWriteToSave
                : changed
                ? l10n.promptSavedHint
                : l10n.promptNoChanges,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
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
            trailingNote: l10n.promptCharsLeft(left),
          ),
        ],
      ),
    );
  }
}
