import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_haptics.dart';
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
    duration: AppMotion.reject,
  );
  late final AnimationController _caret = AnimationController(
    vsync: this,
    duration: AppMotion.caretBlink,
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
        widget.state == CodeInputState.error) {
      // The haptic survives reduced motion; the shake doesn't.
      AppHaptics.fire(context, HapticMoment.reject);
      if (!AppMotion.reduced(context)) _shake.forward(from: 0);
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
    // Blink only while a cell shows the caret, so an idle screen schedules no frames. Under
    // reduced motion the caret stays on.
    final caretVisible =
        _focus.hasFocus && !locked && text.length < widget.length;
    final blink = caretVisible && !AppMotion.reduced(context);
    if (blink && !_caret.isAnimating) {
      _caret.repeat();
    } else if (!blink && _caret.isAnimating) {
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
                style: AppTypography.input,
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
    // The cells extend the filled field: the neutral fill with no outline, white with a 2pt purple
    // edge when active, red when wrong, the purple tint when verified.
    final (Color bg, Color ring, double ringWidth, Color fg) = switch (state) {
      CodeInputState.error => (
        AppColors.dangerTint,
        AppColors.negative,
        AppBorders.focus,
        AppColors.negative,
      ),
      CodeInputState.success => (
        AppColors.accentTint,
        AppColors.accent,
        AppBorders.selected,
        AppColors.accentOnTint,
      ),
      _ when active => (
        AppColors.surface,
        AppColors.focusField,
        AppBorders.focus,
        AppColors.ink,
      ),
      _ => (
        AppColors.field,
        const Color(0x00EAEAEF),
        AppBorders.focus,
        AppColors.ink,
      ),
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
          borderRadius: AppRadii.all(AppRadii.field),
          border: Border.all(
            color: ring,
            width: ringWidth,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        alignment: Alignment.center,
        child: filled
            ? Text(
                digit!,
                style: AppTypography.headline.copyWith(
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
                    color: AppColors.accent,
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

/// Tone of an interest set's emoji holder (V11 data tones, V16 pastels).
enum MarkTone {
  peach(AppColors.markPink),
  lilac(AppColors.markLavender),
  sky(AppColors.markLavender),
  mint(AppColors.accentTint),
  butter(AppColors.markYellow);

  const MarkTone(this.color);
  final Color color;

  static MarkTone byName(String name) =>
      values.firstWhere((t) => t.name == name, orElse: () => butter);
}

/// Ente Filter Chip (9524:4352): a 40pt pill, Mini 12/16 label. Unselected: white (fill/dark on a
/// white card or sheet, [onCard]), text/light label and an add glyph at the end. Selected: the
/// reverse (ink) fill, white label and a small cross to clear. Unavailable (quota reached): the
/// disabled foreground.
class NumayaChip extends StatelessWidget {
  const NumayaChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.available = true,
    this.emoji,
    this.onCard = false,
  });

  final String label;
  final bool selected;
  final bool available;
  final String? emoji;
  final bool onCard;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unavailable = !available && !selected;
    final fg = selected
        ? AppColors.inkForeground
        : unavailable
        ? AppColors.disabledForeground
        : AppColors.textMuted;
    return Pressable(
      onTap: unavailable ? null : onTap,
      haptic: HapticMoment.selection,
      semanticLabel: label,
      selected: selected,
      excludeChildSemantics: true,
      pressedScale: 0.97,
      borderRadius: AppRadii.all(AppRadii.pill),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.base),
        curve: AppMotion.easeOut,
        constraints: const BoxConstraints(minHeight: AppSizes.chip),
        // Ente: 16 before the label, 12 after the trailing glyph, 8 between.
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.s4,
          AppSpacing.s2,
          AppSpacing.s3,
          AppSpacing.s2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.ink
              : onCard
              ? AppColors.fill
              : AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Emoji(emoji!, size: 16),
              const SizedBox(width: AppLayout.compactIconGap),
            ],
            Flexible(
              child: Text(label, style: AppTypography.pill.copyWith(color: fg)),
            ),
            const SizedBox(width: AppSpacing.s2),
            NumayaIcon(
              selected ? NumayaIcons.close : NumayaIcons.plus,
              size: selected ? 14 : 18,
              color: selected
                  ? AppColors.inkForeground
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

/// A labelled set of chips (`.chip-group__set`): the set name beside its emoji in a round pastel
/// holder (V16's category icons), chips below.
class ChipSet extends StatelessWidget {
  const ChipSet({
    super.key,
    required this.label,
    required this.children,
    this.emoji,
    this.tone = MarkTone.butter,
  });

  final String label;
  final String? emoji;
  final MarkTone tone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (emoji != null) ...[
              // The emoji stands on its own beside the heading (RD-08: no passive holders).
              Emoji(emoji!, size: 18),
              const SizedBox(width: AppLayout.iconLabelGap),
            ],
            // Flexible: a long group name wraps at large text instead of overflowing (found on
            // /profile/edit/interests at 320pt and 200% by the overnight route-gap sweep).
            Flexible(
              child: Text(
                label,
                style: AppTypography.weight(
                  AppTypography.label,
                  AppTypography.semibold,
                ).copyWith(color: AppColors.ink),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        Wrap(
          spacing: AppLayout.groupGap,
          runSpacing: AppLayout.groupGap,
          children: children,
        ),
      ],
    );
  }
}

/// [radio]: one choice (a ring with a dot, announced as a mutually exclusive group). [checkbox]:
/// several (a square with a tick). [multiCircle]: several, drawn as a circle that fills with a
/// tick (UI-021's round indicator) while announcing truthful multi-select (checked, not exclusive).
enum OptionKind { radio, checkbox, multiCircle }

/// One selection row (`.theme-withings .option-card`). Rows sit in one white card with hairline
/// dividers ([OptionGroup]); the radio or checkbox carries the selection, so a selected row takes no
/// ring.
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
    final fg = enabled ? AppColors.ink : AppColors.disabledForeground;
    return Semantics(
      inMutuallyExclusiveGroup: kind == OptionKind.radio,
      checked: selected,
      child: Pressable(
        onTap: enabled ? onTap : null,
        haptic: HapticMoment.selection,
        semanticLabel: description == null ? label : '$label. $description',
        excludeChildSemantics: true,
        pressedScale: 1,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppSizes.row),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Option rows share ListRow's `row` role (Body 14/20, UI-012).
                    Text(label, style: AppTypography.row.copyWith(color: fg)),
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

/// Ente Radio Button and Checkbox (2482:6625, 2482:6649) at 20pt: an outlined ring or 5pt-corner
/// square in the 3:1 control grey; selected Numaya purple (Ente's primary) with a white tick or a
/// purple dot.
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
    final round = kind != OptionKind.checkbox;
    final checked = selected && !radio;
    return Opacity(
      opacity: enabled ? 1 : AppOpacity.disabled,
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.fast),
        width: AppSizes.choice,
        height: AppSizes.choice,
        decoration: BoxDecoration(
          color: checked ? AppColors.accent : AppColors.surface,
          shape: round ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: round ? null : AppRadii.all(AppRadii.checkbox),
          border: checked
              ? null
              : Border.all(
                  color: selected ? AppColors.accent : AppColors.control,
                  width: AppBorders.selected,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
        ),
        alignment: Alignment.center,
        child: !selected
            ? null
            : radio
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              )
            : const NumayaIcon(
                NumayaIcons.check,
                size: 14,
                color: AppColors.accentForeground,
              ),
      ),
    );
  }
}

/// A capital legend over one white card of selection rows (`.option-cards`), dividers between.
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
            child: Text(legend, style: AppTypography.fieldLabel),
          ),
          const SizedBox(height: AppSpacing.s3),
          // UI-003: adjacent options are visibly separate, each its own white card 8pt apart
          // (Ente's menu item list, as `ListGroup`). Sheets are the grey page surface since UI-023,
          // so the same cards read there too.
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s2),
            WhiteCard(padding: EdgeInsets.zero, child: children[i]),
          ],
        ],
      ),
    );
  }
}

/// V16 card: white on the stone page, 14pt corner, no border, no shadow.
class WhiteCard extends StatelessWidget {
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: child,
    );
  }
}
