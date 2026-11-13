import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

enum NumayaButtonVariant {
  /// Brand purple, white label. One per screen.
  primary,

  /// Filled neutral grey with ink text; also the cancel under a primary in sheets.
  secondary,

  /// The second, standalone choice under a primary ("I have an account", "Maybe later"). UI-002:
  /// drawn exactly as [secondary] (the light grey fill), so every standalone secondary action has
  /// one recognisable button shape. Inline links stay [TextLink].
  quiet,

  /// The subtle purple surface with purple text (Meetup's tinted secondary).
  brand,

  /// Red text, for a destructive choice in a list.
  destructive,

  /// Solid red, for confirming a destructive choice.
  destructiveSolid,
}

/// Ente Button Large / Small (2207:41759, 2207:41578): 52pt tall, 20pt corners, 24pt side insets,
/// Body 14/20 label. Primary is Numaya purple (Ente's primary role) with white text; secondary the
/// fill/dark neutral with ink text; [small] is the compact 40pt button. Disabled: fill/dark with
/// grey text.
class NumayaButton extends StatelessWidget {
  const NumayaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NumayaButtonVariant.primary,
    this.small = false,
    this.loading = false,
    this.icon,
    this.expand,
  });

  final String label;
  final VoidCallback? onPressed;
  final NumayaButtonVariant variant;
  final bool small;
  final bool loading;
  final NumayaIcons? icon;

  /// Whether the button fills the width it is given. Defaults: Button Large fills, Button Small
  /// hugs its label. Pass `true` for a small button that shares a row with peers
  /// ([NumayaButtonGroup]); Ente alignment V3, issue EA-B01.
  final bool? expand;
  bool get _fills => expand ?? !small;

  /// Secondary, quiet and brand buttons are outlined (replacement V8 default). Set once from the
  /// app root; false is the V7 filled comparison.
  static bool outlinedSecondary = true;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !loading;
    final textOnly = variant == NumayaButtonVariant.destructive;
    final height = small
        ? AppSizes.buttonHeightSm
        : textOnly
        ? AppSizes.buttonHeightQuiet
        : AppSizes.buttonHeight;
    // UI-050: standard buttons 12; UI-062: the compact button for cards and menus is 8.
    final radius = small ? AppRadii.tag : AppRadii.control;

    // A small button that isn't primary, tint or solid red is the outlined pill.
    final effective = small && variant == NumayaButtonVariant.destructive
        ? NumayaButtonVariant.secondary
        : variant;

    final (Color bg, Color fg, Color? ring) = switch (effective) {
      _ when disabled && textOnly && !small => (
        Colors.transparent,
        AppColors.disabledForeground,
        null,
      ),
      // UI-057 (V8): disabled is an outlined, muted button with no grey fill, for every
      // variant; enabled primaries are brand purple.
      _ when disabled => (
        Colors.transparent,
        AppColors.disabledForeground,
        AppColors.disabledOutline,
      ),
      NumayaButtonVariant.primary => (
        AppColors.accent,
        AppColors.accentForeground,
        null,
      ),
      // Replacement V8 (C-03): secondary actions are a quiet 1pt outline with no fill, so only
      // the primary action is solid. [outlinedSecondary] false restores V7's filled neutral for
      // comparison (lab group r8-secondary-button).
      NumayaButtonVariant.secondary || NumayaButtonVariant.quiet
          when outlinedSecondary =>
        (Colors.transparent, AppColors.ink, AppColors.buttonOutline),
      NumayaButtonVariant.secondary => (AppColors.field, AppColors.ink, null),
      NumayaButtonVariant.quiet => (AppColors.field, AppColors.ink, null),
      // The brand action: a purple label, outlined in faint purple (V7: on the neutral fill).
      NumayaButtonVariant.brand when outlinedSecondary => (
        Colors.transparent,
        AppColors.accentOnTint,
        AppColors.accentOutline,
      ),
      NumayaButtonVariant.brand => (
        AppColors.field,
        AppColors.accentOnTint,
        null,
      ),
      NumayaButtonVariant.destructive => (
        Colors.transparent,
        AppColors.negative,
        null,
      ),
      NumayaButtonVariant.destructiveSolid => (
        AppColors.negative,
        AppColors.inkForeground,
        null,
      ),
    };

    final textStyle = small ? AppTypography.buttonSm : AppTypography.button;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          NumayaIcon(icon!, size: small ? 18 : AppSizes.iconMd, color: fg),
          const SizedBox(width: AppSpacing.s2),
        ],
        // Up to two centred lines: at large text on a narrow phone the label wraps instead of
        // being cut off ("Create an accou…" on Welcome at 320pt and 200%, final design run FD-B1).
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textStyle.copyWith(color: fg, height: 1.2),
          ),
        ),
      ],
    );

    return Pressable(
      onTap: loading ? null : onPressed,
      semanticLabel: label,
      excludeChildSemantics: true,
      borderRadius: AppRadii.all(radius),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.base),
        curve: AppMotion.easeOut,
        // At least the button height; taller only when the label wraps.
        constraints: BoxConstraints(minHeight: height),
        width: _fills ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: small ? AppSpacing.s4 : AppSpacing.s6,
          vertical: AppSpacing.s2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.all(radius),
          border: ring == null
              ? null
              : Border.all(
                  color: ring,
                  width: AppBorders.control,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
        ),
        // A compact button hugs its label; only full-width buttons fill the row. Both factors are
        // 1 so the button never stretches to fill a tall parent (only `minHeight` applies).
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: loading
              ? SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
                )
              : content,
        ),
      ),
    );
  }
}

/// The step button (`.fab`): a purple rounded square with a white arrow; disabled neutral grey.
class NumayaFab extends StatelessWidget {
  const NumayaFab({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    this.loading = false,
    this.icon = NumayaIcons.arrowRight,
  });

  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool loading;
  final NumayaIcons icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null || loading;
    return Pressable(
      onTap: loading ? null : onPressed,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      pressedScale: 0.94,
      borderRadius: AppRadii.all(AppRadii.control),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.base),
        curve: AppMotion.easeOut,
        width: AppSizes.fab,
        height: AppSizes.fab,
        // A rounded square like every other icon button (RD-02).
        // UI-057: disabled is outlined and muted, like every disabled button.
        decoration: BoxDecoration(
          borderRadius: AppRadii.all(AppRadii.control),
          color: enabled ? AppColors.accent : Colors.transparent,
          border: enabled
              ? null
              : Border.all(
                  color: AppColors.disabledOutline,
                  width: AppBorders.control,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.accentForeground,
                ),
              )
            : NumayaIcon(
                icon,
                color: enabled
                    ? AppColors.accentForeground
                    : AppColors.disabledForeground,
              ),
      ),
    );
  }
}

enum NavButtonStyle {
  /// A white rounded square: page and tab-root headers, and over photos.
  floating,

  /// A grey rounded square.
  flat,

  /// A bare ink icon: modal headers.
  plain,

  /// Ente Icon Button Type=Circular (5518:37854): a 38pt fill/dark circle, the sheet close button
  /// and controls over photos.
  circular,
}

/// Round icon button (`.nav-button`). Always has an accessible [label].
class NavIconButton extends StatelessWidget {
  const NavIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.style = NavButtonStyle.floating,
    this.filled = false,
    this.brand = false,
  });

  final NumayaIcons icon;
  final String label;
  final VoidCallback? onPressed;
  final NavButtonStyle style;

  /// Tabler's filled artwork, for a toggle that is on (a saved heart). Neutral actions keep the
  /// outline (Ente's toolbar icons are outlines).
  final bool filled;

  /// A brand action (Like in a list): the subtle purple surface with a purple icon.
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final size = style == NavButtonStyle.flat
        ? AppSizes.iconButtonSm
        : AppSizes.iconButton;
    final radius = style == NavButtonStyle.circular
        ? AppRadii.pill
        : AppRadii.iconButton;
    final (Color bg, Color? ring) = brand
        ? (AppColors.fill, null)
        : switch (style) {
            // A white rounded square with no outline: surface contrast against the grey page.
            NavButtonStyle.floating => (AppColors.surface, null),
            NavButtonStyle.flat => (AppColors.fill, null),
            NavButtonStyle.plain => (Colors.transparent, null),
            NavButtonStyle.circular => (AppColors.fill, null),
          };
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: label,
        excludeChildSemantics: true,
        pressedScale: 0.95,
        borderRadius: AppRadii.all(radius),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.all(radius),
            border: ring == null
                ? null
                : Border.all(
                    color: ring,
                    width: AppBorders.hairline,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
          ),
          alignment: Alignment.center,
          child: NumayaIcon(
            icon,
            // Ente Icon: Small (18) inside a 38pt Icon Button; 20 here for the outline stroke's
            // weight at phone density.
            size: AppSizes.iconMd,
            filled: filled,
            // Unavailable (no handler): the icon greys out, the button keeps its place.
            color: onPressed == null
                ? AppColors.disabledForeground
                : brand
                ? AppColors.accentOnTint
                : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// Underlined inline action (`.text-button`): purple text, semibold.
class TextLink extends StatelessWidget {
  const TextLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.muted = false,
    this.danger = false,
    this.style,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool muted;
  final bool danger;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? AppColors.disabledForeground
        : danger
        ? AppColors.negative
        : muted
        ? AppColors.textSecondary
        : AppColors.accentOnTint;
    final base = style ?? AppTypography.body;
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.tag),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: AppTypography.weight(base, AppTypography.semibold).copyWith(
            color: color,
            decoration: TextDecoration.underline,
            decorationThickness: 1.5,
            decorationColor: onPressed == null
                ? Colors.transparent
                : color.withValues(alpha: 0.32),
          ),
        ),
      ),
    );
  }
}

/// Ente action groups (alignment V3, EA-B01). Ente stacks Button Large in sheets, main action on
/// top (Bottom Sheet 4809:8074, spacing/md 12 between); peer actions in rows and cards share the
/// width equally with the same 12pt gap, so no arbitrary space opens between two content-width
/// buttons. When the row can't hold each label on one line (narrow phone, large text) the group
/// stacks instead of shrinking type or targets.
enum NumayaButtonGroupLayout {
  /// Equal-width buttons side by side; stacks when too narrow.
  peers,

  /// Full-width buttons one above the other, the first one on top.
  stacked,
}

class NumayaButtonGroup extends StatelessWidget {
  const NumayaButtonGroup({
    super.key,
    required this.children,
    this.layout = NumayaButtonGroupLayout.peers,
    this.minButtonWidth = 120,
  });

  /// The actions, in reading order (main action last in a row, first in a stack: callers pass
  /// the order they want read).
  final List<Widget> children;
  final NumayaButtonGroupLayout layout;

  /// Below this width per button at the current text scale, a peer row stacks.
  final double minButtonWidth;

  static const double gap = AppSpacing.s3;

  @override
  Widget build(BuildContext context) {
    Widget stack() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: gap),
          children[i],
        ],
      ],
    );
    if (layout == NumayaButtonGroupLayout.stacked) return stack();
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, c) {
        final each =
            (c.maxWidth - gap * (children.length - 1)) / children.length;
        if (each < minButtonWidth * scale) return stack();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}
