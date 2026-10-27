import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

enum CodeInputState { idle, checking, error, success }

/// Six-cell verification code (`.code`): 3 + 3 cells, a blinking caret in the active cell, a shake
/// on error and a purple fill on success. One hidden text field drives it, so paste and SMS
/// one-time-code autofill work.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.length = 6,
    this.state = CodeInputState.idle,
    this.onCompleted,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final int length;
  final CodeInputState state;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> with TickerProviderStateMixin {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 440),
  );
  late final AnimationController _caret = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
    _focus.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(CodeInput old) {
    super.didUpdateWidget(old);
    if (old.state != CodeInputState.error &&
        widget.state == CodeInputState.error &&
        !AppMotion.reduced(context)) {
      _shake.forward(from: 0);
    }
  }

  void _rebuild() => setState(() {});

  void _onText() {
    setState(() {});
    final text = widget.controller.text;
    if (text.length == widget.length) widget.onCompleted?.call(text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _focus.removeListener(_rebuild);
    _ownFocus?.dispose();
    _shake.dispose();
    _caret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final locked =
        widget.state == CodeInputState.checking ||
        widget.state == CodeInputState.success;
    // Blink only while a cell shows the caret, so an idle screen schedules no frames.
    final caretVisible =
        _focus.hasFocus && !locked && text.length < widget.length;
    if (caretVisible && !_caret.isAnimating) {
      _caret.repeat();
    } else if (!caretVisible && _caret.isAnimating) {
      _caret.stop();
    }
    final cells = <Widget>[];
    for (var i = 0; i < widget.length; i++) {
      if (i == widget.length ~/ 2) cells.add(const SizedBox(width: 6 + 8));
      if (i > 0 && i != widget.length ~/ 2) cells.add(const SizedBox(width: 8));
      cells.add(
        Expanded(
          child: _CodeCell(
            digit: i < text.length ? text[i] : null,
            active: _focus.hasFocus && !locked && i == text.length,
            state: widget.state,
            caret: _caret,
            index: i,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        final dx = math.sin(t * math.pi * 6) * 8 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Stack(
        children: [
          Row(children: cells),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                readOnly: locked,
                showCursor: false,
                enableInteractiveSelection: false,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                decoration: InputDecoration.collapsed(hintText: widget.label),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeCell extends StatelessWidget {
  const _CodeCell({
    required this.digit,
    required this.active,
    required this.state,
    required this.caret,
    required this.index,
  });

  final String? digit;
  final bool active;
  final CodeInputState state;
  final Animation<double> caret;
  final int index;

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;
    final (Color bg, Color? ring, double ringWidth, Color fg) = switch (state) {
      CodeInputState.error => (
        AppColors.dangerTint,
        AppColors.danger,
        AppBorders.selected,
        AppColors.danger,
      ),
      CodeInputState.success => (
        AppColors.brandTint,
        AppColors.brand,
        AppBorders.selected,
        AppColors.textBrandDeep,
      ),
      _ when active => (
        AppColors.surface,
        AppColors.focusField,
        AppBorders.focus,
        AppColors.textPrimary,
      ),
      _ when filled => (
        AppColors.surface,
        AppColors.borderStrong,
        AppBorders.hairline,
        AppColors.textPrimary,
      ),
      _ => (AppColors.surfaceSoft, null, 0, AppColors.textPrimary),
    };
    return AnimatedOpacity(
      opacity: state == CodeInputState.checking ? AppOpacity.pending : 1,
      duration: AppMotion.duration(context, AppMotion.base),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.base),
        curve: AppMotion.easeOut,
        height: AppSizes.codeCellHeight,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.all(AppSizes.codeCellRadius),
          border: ring == null
              ? null
              : Border.all(
                  color: ring,
                  width: ringWidth,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
          boxShadow: active && state == CodeInputState.idle
              ? const [BoxShadow(color: AppColors.focusHalo, spreadRadius: 4)]
              : const [],
        ),
        alignment: Alignment.center,
        child: filled
            ? Text(
                digit!,
                style:
                    AppTypography.weight(
                      AppTypography.input,
                      AppTypography.semibold,
                    ).copyWith(
                      fontSize: 24,
                      height: 1,
                      color: fg,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              )
            : active
            ? FadeTransition(
                opacity: AppMotion.reduced(context)
                    ? const AlwaysStoppedAnimation(1)
                    : caret.drive(_StepBlink()),
                child: Container(
                  width: 2,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.textBrand,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// `blink 1.05s steps(1)`: visible for the first half, hidden for the second.
class _StepBlink extends Animatable<double> {
  @override
  double transform(double t) => t < 0.5 ? 1 : 0;
}

/// Selectable chip (`.chip`): outlined white; selected solid purple with a minus; unavailable
/// (quota reached) greyed with a muted plus.
class NumayaChip extends StatelessWidget {
  const NumayaChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.available = true,
  });

  final String label;
  final bool selected;
  final bool available;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unavailable = !available && !selected;
    final fg = selected
        ? AppColors.controlSelectedText
        : unavailable
        ? AppColors.textSubtle
        : AppColors.textPrimary;
    return Pressable(
      onTap: unavailable ? null : onTap,
      semanticLabel: label,
      selected: selected,
      excludeChildSemantics: true,
      pressedScale: 0.97,
      borderRadius: AppRadii.all(AppRadii.pill),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.base),
        curve: AppMotion.easeOut,
        constraints: const BoxConstraints(minHeight: AppSizes.chip),
        padding: const EdgeInsets.fromLTRB(14, 5, AppSpacing.s3, 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.controlSelected : AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.pill),
          border: selected
              ? null
              : Border.all(
                  color: unavailable
                      ? AppColors.borderSubtle
                      : AppColors.borderStrong,
                  width: AppBorders.hairline,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTypography.weight(
                  AppTypography.bodySm,
                  AppTypography.medium,
                ).copyWith(color: fg, height: 20 / 15),
              ),
            ),
            const SizedBox(width: 6),
            NumayaIcon(
              selected ? NumayaIcons.minus : NumayaIcons.plus,
              size: 18,
              color: selected
                  ? AppColors.onBrand
                  : unavailable
                  ? AppColors.borderStrong
                  : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled set of chips.
class ChipSet extends StatelessWidget {
  const ChipSet({super.key, required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.s2),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: children,
        ),
      ],
    );
  }
}

enum OptionKind { radio, checkbox }

/// Option card (`.option-card`): pill row with a radio or checkbox at the end. Selected: lavender
/// fill with a 2pt purple ring.
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.kind = OptionKind.radio,
    this.description,
    this.enabled = true,
  });

  final String label;
  final String? description;
  final bool selected;
  final bool enabled;
  final OptionKind kind;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = description == null ? AppRadii.pill : AppRadii.lg;
    final fg = enabled ? AppColors.textPrimary : AppColors.textSubtle;
    return Semantics(
      inMutuallyExclusiveGroup: kind == OptionKind.radio,
      checked: selected,
      child: Pressable(
        onTap: enabled ? onTap : null,
        semanticLabel: description == null ? label : '$label. $description',
        excludeChildSemantics: true,
        pressedScale: 0.99,
        borderRadius: AppRadii.all(radius),
        child: AnimatedContainer(
          duration: AppMotion.duration(context, AppMotion.base),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppSizes.touchMin),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s5,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandTint : AppColors.surface,
            borderRadius: AppRadii.all(radius),
            border: Border.all(
              color: selected
                  ? AppColors.controlSelected
                  : AppColors.borderStrong,
              width: selected ? AppBorders.focus : AppBorders.hairline,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.weight(
                        AppTypography.body,
                        AppTypography.medium,
                      ).copyWith(color: fg),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(description!, style: AppTypography.caption),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s4),
              _ChoiceMark(kind: kind, selected: selected, enabled: enabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceMark extends StatelessWidget {
  const _ChoiceMark({
    required this.kind,
    required this.selected,
    required this.enabled,
  });

  final OptionKind kind;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final radio = kind == OptionKind.radio;
    return Opacity(
      opacity: enabled ? 1 : AppOpacity.disabled,
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.fast),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: selected && !radio
              ? AppColors.controlSelected
              : AppColors.surface,
          shape: radio ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: radio ? null : AppRadii.all(AppRadii.xs),
          border: Border.all(
            color: selected
                ? AppColors.controlSelected
                : AppColors.borderControl,
            width: selected && radio ? AppBorders.focus : AppBorders.selected,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        alignment: Alignment.center,
        child: !selected
            ? null
            : radio
            ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.controlSelected,
                  shape: BoxShape.circle,
                ),
              )
            : const NumayaIcon(
                NumayaIcons.check,
                size: 18,
                color: AppColors.onBrand,
              ),
      ),
    );
  }
}

/// A legend over a column of option cards (`.option-cards`).
class OptionGroup extends StatelessWidget {
  const OptionGroup({super.key, required this.legend, required this.children});

  final String legend;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: legend,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Text(
              legend,
              style: AppTypography.weight(
                AppTypography.label,
                AppTypography.semibold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            children[i],
          ],
        ],
      ),
    );
  }
}
