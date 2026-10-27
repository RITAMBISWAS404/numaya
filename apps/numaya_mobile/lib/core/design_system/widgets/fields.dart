import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

enum FieldNoteTone { neutral, error, success }

/// Helper, error or success line under a field (`.field__note`). Announced when it changes.
class FieldNote extends StatelessWidget {
  const FieldNote(this.text, {super.key, this.tone = FieldNoteTone.neutral});

  final String text;
  final FieldNoteTone tone;

  @override
  Widget build(BuildContext context) {
    final style = switch (tone) {
      FieldNoteTone.neutral => AppTypography.caption,
      FieldNoteTone.error => AppTypography.caption.copyWith(
        color: AppColors.danger,
      ),
      FieldNoteTone.success => AppTypography.weight(
        AppTypography.caption,
        AppTypography.semibold,
      ).copyWith(color: AppColors.textBrand),
    };
    return Semantics(
      liveRegion: tone != FieldNoteTone.neutral,
      child: Text(text, style: style),
    );
  }
}

/// The shared input surface (`.input`): soft grey, 56 tall, 16 corner. Focused: white with a 2pt
/// purple ring and a soft halo. Invalid: white with a red ring. Disabled: sunken grey.
class InputSurface extends StatelessWidget {
  const InputSurface({
    super.key,
    required this.child,
    this.focused = false,
    this.invalid = false,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
    this.height = AppSizes.control,
  });

  final Widget child;
  final bool focused;
  final bool invalid;
  final bool disabled;
  final EdgeInsetsGeometry padding;

  /// Null grows with the content (multi-line fields).
  final double? height;

  @override
  Widget build(BuildContext context) {
    final white = focused || invalid;
    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.base),
      curve: AppMotion.easeOut,
      height: height,
      constraints: height == null ? const BoxConstraints(minHeight: 120) : null,
      padding: padding,
      decoration: BoxDecoration(
        color: disabled
            ? AppColors.surfaceSunken
            : white
            ? AppColors.surface
            : AppColors.surfaceSoft,
        borderRadius: AppRadii.all(AppRadii.md),
        border: Border.all(
          color: invalid
              ? AppColors.danger
              : focused
              ? AppColors.focusField
              : Colors.transparent,
          width: AppBorders.focus,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        boxShadow: focused && !invalid
            ? const [BoxShadow(color: AppColors.focusHalo, spreadRadius: 4)]
            : const [],
      ),
      alignment: height == null ? Alignment.topLeft : Alignment.centerLeft,
      child: child,
    );
  }
}

/// Labelled text field (`.field` + `.input`) with an optional helper or error note.
class NumayaTextField extends StatefulWidget {
  const NumayaTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.hint,
    this.error,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.autofocus = false,
    this.enabled = true,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.semanticsIdentifier,
    this.multiline = false,
    this.trailingNote,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? hint;
  final String? error;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final bool enabled;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;
  final String? semanticsIdentifier;

  /// A text area: grows from 120pt, wraps lines, body type.
  final bool multiline;

  /// Right-aligned note under the field, e.g. a character counter.
  final String? trailingNote;

  @override
  State<NumayaTextField> createState() => _NumayaTextFieldState();
}

class _NumayaTextFieldState extends State<NumayaTextField> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(NumayaTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invalid = widget.error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(child: Text(widget.label, style: AppTypography.label)),
        const SizedBox(height: AppSpacing.s2),
        InputSurface(
          focused: _focus.hasFocus,
          invalid: invalid,
          disabled: !widget.enabled,
          height: widget.multiline ? null : AppSizes.control,
          padding: widget.multiline
              ? const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s4,
                  vertical: 14,
                )
              : const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          child: Semantics(
            identifier: widget.semanticsIdentifier,
            label: widget.label,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardType: widget.multiline
                  ? TextInputType.multiline
                  : widget.keyboardType,
              minLines: widget.multiline ? 3 : 1,
              maxLines: widget.multiline ? 8 : 1,
              textInputAction: widget.textInputAction,
              inputFormatters: [
                ...?widget.inputFormatters,
                if (widget.maxLength != null)
                  LengthLimitingTextInputFormatter(widget.maxLength),
              ],
              autofillHints: widget.enabled ? widget.autofillHints : null,
              textCapitalization: widget.textCapitalization,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style:
                  (widget.multiline ? AppTypography.body : AppTypography.input)
                      .copyWith(
                        color: widget.enabled
                            ? AppColors.textPrimary
                            : AppColors.textSubtle,
                        fontFeatures: widget.multiline
                            ? null
                            : const [FontFeature.tabularFigures()],
                      ),
              cursorColor: AppColors.brand,
              decoration: InputDecoration.collapsed(
                hintText: widget.placeholder,
                hintStyle: AppTypography.weight(
                  widget.multiline ? AppTypography.body : AppTypography.input,
                  400,
                ).copyWith(color: AppColors.textSubtle),
              ),
            ),
          ),
        ),
        if (widget.error != null ||
            widget.hint != null ||
            widget.trailingNote != null) ...[
          const SizedBox(height: AppSpacing.s2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: widget.error == null && widget.hint == null
                    ? const SizedBox.shrink()
                    : FieldNote(
                        widget.error ?? widget.hint!,
                        tone: invalid
                            ? FieldNoteTone.error
                            : FieldNoteTone.neutral,
                      ),
              ),
              if (widget.trailingNote != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s3),
                  child: Text(
                    widget.trailingNote!,
                    style: AppTypography.caption,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// ISO country code badge (`.input__code`), e.g. "US".
class CountryCodeBadge extends StatelessWidget {
  const CountryCodeBadge(this.iso, {super.key});

  final String iso;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 30),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.xs),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppBorders.hairline,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        iso,
        style: AppTypography.weight(AppTypography.micro, AppTypography.bold)
            .copyWith(
              fontSize: 11,
              height: 1,
              letterSpacing: 0.66,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

/// Search field (`.search`): grey pill with a magnifier; focus ring like inputs.
class NumayaSearchField extends StatefulWidget {
  const NumayaSearchField({
    super.key,
    required this.placeholder,
    required this.onChanged,
    this.controller,
    this.autofocus = false,
    this.clearLabel = 'Clear search',
  });

  final String placeholder;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final String clearLabel;

  @override
  State<NumayaSearchField> createState() => _NumayaSearchFieldState();
}

class _NumayaSearchFieldState extends State<NumayaSearchField> {
  final _focus = FocusNode();
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.base),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      decoration: BoxDecoration(
        color: focused ? AppColors.surface : AppColors.surfaceSoft,
        borderRadius: AppRadii.all(AppRadii.pill),
        border: Border.all(
          color: focused ? AppColors.focusField : Colors.transparent,
          width: AppBorders.focus,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        boxShadow: focused
            ? const [BoxShadow(color: AppColors.focusHalo, spreadRadius: 4)]
            : const [],
      ),
      child: Row(
        children: [
          const NumayaIcon(
            NumayaIcons.search,
            size: AppSizes.iconMd,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.body.copyWith(fontSize: 16),
              decoration: InputDecoration.collapsed(
                hintText: widget.placeholder,
                hintStyle: AppTypography.body.copyWith(
                  fontSize: 16,
                  color: AppColors.textSubtle,
                ),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            Pressable(
              semanticLabel: widget.clearLabel,
              excludeChildSemantics: true,
              onTap: () {
                _controller.clear();
                widget.onChanged('');
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.textSubtle,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const NumayaIcon(
                  NumayaIcons.close,
                  size: 14,
                  color: AppColors.textOnInverse,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
