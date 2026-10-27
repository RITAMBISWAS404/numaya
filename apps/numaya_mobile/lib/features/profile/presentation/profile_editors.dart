import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../domain/profile_details.dart';

/// Inline text edit (B-25: a field with Cancel / Save). Returns the new text, or null when
/// cancelled. An empty result clears the value.
Future<String?> showTextEditSheet(
  BuildContext context, {
  required String title,
  required String initial,
  required int maxLength,
  String? hint,
  bool multiline = false,
  String? tip,
}) {
  final l10n = context.l10n;
  return showNumayaSheet<String>(
    context: context,
    title: title,
    closeLabel: l10n.cancel,
    builder: (context) => _TextEditForm(
      initial: initial,
      maxLength: maxLength,
      hint: hint,
      multiline: multiline,
      tip: tip,
      label: title,
    ),
  );
}

class _TextEditForm extends StatefulWidget {
  const _TextEditForm({
    required this.initial,
    required this.maxLength,
    required this.multiline,
    required this.label,
    this.hint,
    this.tip,
  });

  final String initial;
  final int maxLength;
  final bool multiline;
  final String label;
  final String? hint;
  final String? tip;

  @override
  State<_TextEditForm> createState() => _TextEditFormState();
}

class _TextEditFormState extends State<_TextEditForm> {
  late final _text = TextEditingController(text: widget.initial)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final changed = _text.text.trim() != widget.initial.trim();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NumayaTextField(
            label: widget.label,
            controller: _text,
            autofocus: true,
            multiline: widget.multiline,
            maxLength: widget.maxLength,
            placeholder: widget.hint,
            textCapitalization: TextCapitalization.sentences,
            trailingNote: l10n.promptCharsLeft(
              widget.maxLength - _text.text.length,
            ),
          ),
          if (widget.tip != null) ...[
            const SizedBox(height: AppSpacing.s3),
            InfoCard(
              icon: NumayaIcons.sparkle,
              title: l10n.editBioTipTitle,
              body: widget.tip,
            ),
          ],
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            label: l10n.save,
            onPressed: changed
                ? () => Navigator.of(context).pop(_text.text.trim())
                : null,
          ),
          if (widget.initial.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              label: l10n.editClear,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(''),
            ),
          ],
        ],
      ),
    );
  }
}

/// Attribute picker (B-26): one choice from a list, plus "Prefer not to say" to clear it.
/// Returns the choice, '' to clear, or null when dismissed.
Future<String?> showChoiceSheet(
  BuildContext context, {
  required String title,
  required String legend,
  required List<String> options,
  String? selected,
}) {
  final l10n = context.l10n;
  return showNumayaSheet<String>(
    context: context,
    title: title,
    closeLabel: l10n.close,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: OptionGroup(
              legend: legend,
              children: [
                for (final o in options)
                  OptionCard(
                    label: o,
                    selected: o == selected,
                    onTap: () => Navigator.of(context).pop(o),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          label: l10n.editPreferNotToSay,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(''),
        ),
      ],
    ),
  );
}

/// Height picker: a slider in centimetres. Returns the height, 0 to clear, or null.
Future<int?> showHeightSheet(BuildContext context, int? current) {
  final l10n = context.l10n;
  var value = current ?? 170;
  return showNumayaSheet<int>(
    context: context,
    title: l10n.editHeight,
    closeLabel: l10n.close,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.heightValue(value),
            textAlign: TextAlign.center,
            style: AppTypography.headline,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.fill,
              thumbColor: AppColors.surface,
              trackHeight: 4,
              thumbShape: const V16SliderThumb(),
            ),
            child: Slider(
              value: value.toDouble(),
              min: DetailRules.minHeight.toDouble(),
              max: DetailRules.maxHeight.toDouble(),
              divisions: DetailRules.maxHeight - DetailRules.minHeight,
              semanticFormatterCallback: (v) => l10n.heightValue(v.round()),
              onChanged: (v) => setSheet(() => value = v.round()),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          NumayaButton(
            label: l10n.save,
            onPressed: () => Navigator.of(context).pop(value),
          ),
          if (current != null) ...[
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              label: l10n.editClear,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(0),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Languages: up to five chips.
Future<List<String>?> showLanguagesSheet(
  BuildContext context,
  List<String> current,
) {
  final l10n = context.l10n;
  var picked = [...current];
  return showNumayaSheet<List<String>>(
    context: context,
    title: l10n.editLanguages,
    closeLabel: l10n.close,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.editLanguagesHint(picked.length, DetailRules.maxLanguages),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.s3),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
                children: [
                  for (final lang in kLanguages)
                    NumayaChip(
                      label: lang,
                      onCard: true,
                      selected: picked.contains(lang),
                      available:
                          picked.contains(lang) ||
                          picked.length < DetailRules.maxLanguages,
                      onTap: () => setSheet(() {
                        picked = [...picked];
                        if (!picked.remove(lang) &&
                            picked.length < DetailRules.maxLanguages) {
                          picked.add(lang);
                        }
                      }),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            label: l10n.save,
            onPressed: () => Navigator.of(context).pop(picked),
          ),
        ],
      ),
    ),
  );
}

/// Gender detail (B-12) and whether the profile shows it (B-13).
Future<({String? detail, bool show})?> showGenderDetailSheet(
  BuildContext context, {
  required List<String> options,
  required String? detail,
  required bool show,
}) {
  final l10n = context.l10n;
  var picked = detail;
  var visible = show;
  return showNumayaSheet<({String? detail, bool show})>(
    context: context,
    title: l10n.editGenderMore,
    closeLabel: l10n.close,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: OptionGroup(
                legend: l10n.editGenderLegend,
                children: [
                  for (final o in options)
                    OptionCard(
                      label: o,
                      selected: picked == o,
                      onTap: () =>
                          setSheet(() => picked = picked == o ? null : o),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            footnote: l10n.editGenderShowNote,
            children: [
              ListRow(
                label: l10n.editGenderShow,
                switchValue: visible,
                onSwitch: (v) => setSheet(() => visible = v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          NumayaButton(
            label: l10n.save,
            onPressed: () =>
                Navigator.of(context).pop((detail: picked, show: visible)),
          ),
        ],
      ),
    ),
  );
}
