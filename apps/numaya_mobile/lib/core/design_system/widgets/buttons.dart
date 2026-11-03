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

  /// Text only, for the second choice under a primary on a page.
  quiet,

  /// The subtle purple surface with purple text (Meetup's tinted secondary).
  brand,

  /// Red text, for a destructive choice in a list.
  destructive,

  /// Solid red, for confirming a destructive choice.
  destructiveSolid,
}

/// Monochrome button: a 56pt full pill. Primary is brand purple with white text; secondary a
/// filled neutral with ink text (no outlines); [small] is the compact 40pt pill ("Edit profile").
/// Disabled: neutral grey fill with grey text.
class NumayaButton extends StatelessWidget {
  const NumayaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NumayaButtonVariant.primary,
    this.small = false,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final NumayaButtonVariant variant;
  final bool small;
  final bool loading;
  final NumayaIcons? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !loading;
    final textOnly =
        variant == NumayaButtonVariant.quiet ||
        variant == NumayaButtonVariant.destructive;
    final height = small
        ? AppSizes.buttonHeightSm
        : textOnly
        ? AppSizes.buttonHeightQuiet
        : AppSizes.buttonHeight;
    // Every button is a pill (RD-02: pills for actions, rounded rectangles for surfaces).
    const radius = AppRadii.pill;

    // A small button that isn't primary, tint or solid red is the outlined pill.
    final effective =
        small &&
            (variant == NumayaButtonVariant.quiet ||
                variant == NumayaButtonVariant.destructive)
        ? NumayaButtonVariant.secondary
        : variant;

    final (Color bg, Color fg, Color? ring) = switch (effective) {
      _ when disabled && textOnly && !small => (
        Colors.transparent,
        AppColors.disabledForeground,
        null,
      ),
      _ when disabled => (
        AppColors.disabled,
        AppColors.disabledForeground,
        null,
      ),
      NumayaButtonVariant.primary => (
        AppColors.accent,
        AppColors.accentForeground,
        null,
      ),
      // Filled neutral: surface contrast, not a stroke, says "less important".
      NumayaButtonVariant.secondary => (AppColors.field, AppColors.ink, null),
      NumayaButtonVariant.quiet => (Colors.transparent, AppColors.ink, null),
      NumayaButtonVariant.brand => (
        AppColors.accentTint,
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
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(color: fg, height: 1),
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
        height: height,
        width: expand && !small ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: small ? AppSpacing.s4 : AppSpacing.s6,
        ),
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
        // A compact button hugs its label; only full-width buttons fill the row.
        alignment: expand && !small ? Alignment.center : null,
        child: Center(
          widthFactor: 1,
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
        decoration: BoxDecoration(
          borderRadius: AppRadii.all(AppRadii.control),
          color: enabled ? AppColors.accent : AppColors.disabled,
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

  /// A bare ink icon: modal headers, sheet headers.
  plain,
}

/// Round icon button (`.nav-button`). Always has an accessible [label].
class NavIconButton extends StatelessWidget {
  const NavIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.style = NavButtonStyle.floating,
    this.outline = false,
    this.brand = false,
  });

  final NumayaIcons icon;
  final String label;
  final VoidCallback? onPressed;
  final NavButtonStyle style;

  /// The unfilled drawing (a toggle that is off, such as an unsaved heart).
  final bool outline;

  /// A brand action (Like in a list): the subtle purple surface with a purple icon.
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final size = style == NavButtonStyle.flat
        ? AppSizes.iconButtonSm
        : AppSizes.iconButton;
    final (Color bg, Color? ring) = brand
        ? (AppColors.accentTint, null)
        : switch (style) {
            // A white rounded square with no outline: surface contrast against the grey page.
            NavButtonStyle.floating => (AppColors.surface, null),
            NavButtonStyle.flat => (AppColors.fill, null),
            NavButtonStyle.plain => (Colors.transparent, null),
          };
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: label,
        excludeChildSemantics: true,
        pressedScale: 0.92,
        borderRadius: AppRadii.all(AppRadii.iconButton),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.all(AppRadii.iconButton),
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
            size: style == NavButtonStyle.flat
                ? AppSizes.iconMd
                : AppSizes.iconLg,
            outline: outline,
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
