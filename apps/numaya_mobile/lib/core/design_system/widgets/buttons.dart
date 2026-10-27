import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

enum NumayaButtonVariant {
  /// Ink, white label ("Done", "Next" in the reference). One per screen.
  primary,

  /// White with a 1px ink outline ("Share", "Previous"); also the cancel under a primary in sheets.
  secondary,

  /// Text only, for the second choice under a primary on a page.
  quiet,

  /// The blue tint with deep-blue text ("Explore data").
  brand,

  /// Red text, for a destructive choice in a list.
  destructive,

  /// Solid red, for confirming a destructive choice.
  destructiveSolid,
}

/// V16 button (`.theme-withings .btn`): a 50pt rounded rectangle with the 12pt control corner.
/// [small] is the compact 36pt outlined pill ("Edit profile", "Find your people"); a small primary
/// stays ink. Disabled: warm grey `#D6D2CE` with `#77736F` text.
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
    final radius = small ? AppRadii.pill : AppRadii.control;

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
        AppColors.ink,
        AppColors.inkForeground,
        null,
      ),
      NumayaButtonVariant.secondary => (
        AppColors.surface,
        AppColors.ink,
        AppColors.ink,
      ),
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

/// The step button (`.fab`): an ink circle with a white arrow, like the reference's "Add Logs";
/// disabled warm grey.
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
      borderRadius: AppRadii.all(AppRadii.pill),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.base),
        curve: AppMotion.easeOut,
        width: AppSizes.fab,
        height: AppSizes.fab,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.ink : AppColors.disabled,
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.inkForeground,
                ),
              )
            : NumayaIcon(
                icon,
                color: enabled
                    ? AppColors.inkForeground
                    : AppColors.disabledForeground,
              ),
      ),
    );
  }
}

enum NavButtonStyle {
  /// A 40pt white circle with a hairline: page and tab-root headers.
  floating,

  /// A grey circle.
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
  });

  final NumayaIcons icon;
  final String label;
  final VoidCallback? onPressed;
  final NavButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final size = style == NavButtonStyle.flat
        ? AppSizes.iconButtonSm
        : AppSizes.iconButton;
    final (Color bg, Color? ring) = switch (style) {
      NavButtonStyle.floating => (AppColors.surface, AppColors.border),
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
        borderRadius: AppRadii.all(AppRadii.pill),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
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
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// Underlined inline action (`.text-button`): deep blue, semibold.
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
