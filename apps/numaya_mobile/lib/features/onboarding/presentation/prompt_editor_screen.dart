import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../profile/application/profile_details_controller.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';

/// Prompt browser (B-27, UI-008): category tabs at the top, each category's prompts as separate
/// tappable cards with a right-facing chevron. Tapping a prompt opens a sheet showing that exact
/// prompt with the answer field beneath it; Save writes the answer to this screen's [slot] and
/// returns to where the editor was opened. Closing the sheet keeps whatever was saved before.
///
/// [editing] (from Edit profile) also saves the profile. [slot] 1 and 2 edit the extra prompts of
/// a fuller profile (up to three, B-24), which can also be removed. A question answered in another
/// slot can't be picked again (OD-10). The answer limit is [PromptAnswer.maxLength] (150).
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

  /// Questions answered in the other slots: not offered again (OD-10).
  late final Set<String> _usedElsewhere = {
    for (final (i, p) in [
      ref.read(onboardingProvider).draft.prompt,
      ...ref.read(profileDetailsProvider).extraPrompts,
    ].indexed)
      if (p != null && i != widget.slot) p.question,
  };

  /// Opens on the category of the saved question, so editing starts where the answer lives.
  late int _category = _saved == null
      ? 0
      : kPromptCategories
            .indexWhere((c) => c.prompts.contains(_saved.question))
            .clamp(0, kPromptCategories.length - 1);

  bool _saving = false;

  Future<void> _save(String question, String answer) async {
    if (widget.slot > 0) {
      ref
          .read(profileDetailsProvider.notifier)
          .setExtraPrompt(widget.slot - 1, question, answer);
      NumayaToast.show(context, context.l10n.editSaved);
      context.pop();
      return;
    }
    final controller = ref.read(onboardingProvider.notifier);
    controller.setPrompt(question, answer);
    if (widget.editing) {
      setState(() => _saving = true);
      await controller.saveEdits();
      if (!mounted) return;
      NumayaToast.show(context, context.l10n.editSaved);
    }
    if (mounted) context.pop();
  }

  Future<void> _open(String question) async {
    final answer = await showPromptAnswerSheet(
      context: context,
      question: question,
      // The saved answer comes back only for the saved question; any other prompt starts empty.
      initialAnswer: question == _saved?.question ? _saved!.answer : '',
      savedAnswer: question == _saved?.question ? _saved!.answer : null,
    );
    if (answer == null || !mounted) return; // Closed: nothing changes.
    await _save(question, answer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = kPromptCategories[_category];

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: _saving ? null : () => context.pop(),
        backLabel: l10n.back,
        title: l10n.editPromptTitle,
      ),
      footer: widget.slot > 0 && _saved != null
          ? NumayaButton(
              label: l10n.promptRemove,
              variant: NumayaButtonVariant.destructive,
              onPressed: () {
                ref
                    .read(profileDetailsProvider.notifier)
                    .removeExtraPrompt(widget.slot - 1);
                NumayaToast.show(context, l10n.promptRemoved);
                context.pop();
              },
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ViewTabs(
            label: l10n.promptCategories,
            bleed: AppLayout.screenGutter,
            selected: _category,
            onSelect: (i) => setState(() => _category = i),
            options: [
              for (final c in kPromptCategories) (label: c.name, count: null),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          for (var i = 0; i < category.prompts.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s2),
            _PromptChoice(
              question: category.prompts[i],
              current: category.prompts[i] == _saved?.question,
              used: _usedElsewhere.contains(category.prompts[i]),
              onTap: () => _open(category.prompts[i]),
            ),
          ],
          const SizedBox(height: AppSpacing.s4),
        ],
      ),
    );
  }
}

/// One prompt in the browser: its own white card (UI-003), the prompt as the label, a chevron
/// for "opens". The saved question says so; one answered in another slot is unavailable.
class _PromptChoice extends StatelessWidget {
  const _PromptChoice({
    required this.question,
    required this.current,
    required this.used,
    required this.onTap,
  });

  final String question;
  final bool current;
  final bool used;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final note = used
        ? l10n.promptAlreadyUsed
        : current
        ? l10n.promptCurrent
        : null;
    final fg = used ? AppColors.disabledForeground : AppColors.ink;
    return Pressable(
      onTap: used ? null : onTap,
      semanticLabel: note == null ? question : '$question. $note',
      excludeChildSemantics: true,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: AppSizes.row),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(question, style: AppTypography.row.copyWith(color: fg)),
                  if (note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      note,
                      style: AppTypography.caption.copyWith(
                        color: current && !used
                            ? AppColors.accentOnTint
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            NumayaIcon(
              NumayaIcons.chevronRight,
              size: AppSizes.iconMd,
              color: used ? AppColors.disabledForeground : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// The answer sheet (UI-008): the exact prompt as the sheet's title, the answer field below it with
/// the characters left, and Save prompt. Returns the trimmed answer on Save, or null when the
/// sheet is closed (Cancel or swipe), in which case nothing saved is changed.
Future<String?> showPromptAnswerSheet({
  required BuildContext context,
  required String question,
  required String initialAnswer,
  String? savedAnswer,
}) {
  final l10n = context.l10n;
  return showNumayaSheet<String>(
    context: context,
    title: question,
    closeLabel: l10n.cancel,
    builder: (context) => _PromptAnswerForm(
      initialAnswer: initialAnswer,
      savedAnswer: savedAnswer,
    ),
  );
}

class _PromptAnswerForm extends StatefulWidget {
  const _PromptAnswerForm({required this.initialAnswer, this.savedAnswer});

  final String initialAnswer;
  final String? savedAnswer;

  @override
  State<_PromptAnswerForm> createState() => _PromptAnswerFormState();
}

class _PromptAnswerFormState extends State<_PromptAnswerForm> {
  late final TextEditingController _answer = TextEditingController(
    text: widget.initialAnswer,
  )..addListener(() => setState(() {}));

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final answer = _answer.text.trim();
    final changed = answer != (widget.savedAnswer ?? '');
    final canSave = answer.isNotEmpty && changed;
    final left = PromptAnswer.maxLength - _answer.text.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NumayaTextField(
          label: l10n.promptAnswerLabel,
          controller: _answer,
          multiline: true,
          autofocus: true,
          maxLength: PromptAnswer.maxLength,
          textCapitalization: TextCapitalization.sentences,
          placeholder: l10n.promptAnswerPlaceholder,
          trailingNote: l10n.promptCharsLeft(left),
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          label: l10n.promptSave,
          onPressed: canSave ? () => Navigator.of(context).pop(answer) : null,
        ),
        // UI-055: no helper line; the button's enabled state says when it can be saved.
      ],
    );
  }
}
