import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

enum NumayaButtonVariant {
  /// Purple pill, white label. One per screen.
  primary,

  /// Soft grey pill.
  secondary,

  /// Text only (48 tall), for the second choice under a primary.
  quiet,

  /// Lavender pill with deep purple text.
  brand,

  /// Red text (48 tall), for destructive choices.
  destructive,

  /// Solid red, for confirming a destructive choice.
  destructiveSolid,
}

/// Full-width pill button (`.btn`). Disabled: grey fill, subtle label. Loading keeps the size and
/// swaps the label for a spinner.
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
    final quietLike =
        variant == NumayaButtonVariant.quiet ||
        variant == NumayaButtonVariant.destructive;
    final height = small
        ? AppSizes.buttonHeightSm
        : quietLike
        ? AppSizes.buttonHeightQuiet
        : AppSizes.buttonHeight;

    final (
      Color bg,
      Color fg,
      List<BoxShadow> shadow,
      Color? ring,
    ) = switch (variant) {
      _ when disabled && quietLike => (
        Colors.transparent,
        AppColors.textSubtle,
        const <BoxShadow>[],
        null,
      ),
      _ when disabled => (
        AppColors.surfaceSunken,
        AppColors.textSubtle,
        const <BoxShadow>[],
        null,
      ),
      NumayaButtonVariant.primary => (
        AppColors.brand,
        AppColors.onBrand,
        AppElevation.button,
        null,
      ),
      NumayaButtonVariant.secondary => (
        AppColors.surfaceSoft,
        AppColors.textPrimary,
        const <BoxShadow>[],
        null,
      ),
      NumayaButtonVariant.quiet => (
        Colors.transparent,
        AppColors.textPrimary,
        const <BoxShadow>[],
        null,
      ),
      NumayaButtonVariant.brand => (
        AppColors.brandTint,
        AppColors.textBrandDeep,
        const <BoxShadow>[],
        AppColors.brandSubtle,
      ),
      NumayaButtonVariant.destructive => (
        Colors.transparent,
        AppColors.danger,
        const <BoxShadow>[],
        null,
      ),
      NumayaButtonVariant.destructiveSolid => (
        AppColors.danger,
        AppColors.onBrand,
        const <BoxShadow>[],
        null,
      ),
    };

    final textStyle = small
        ? AppTypography.weight(AppTypography.label, AppTypography.semibold)
        : AppTypography.button;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          NumayaIcon(icon!, size: AppSizes.iconMd, color: fg),
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
      borderRadius: AppRadii.all(AppRadii.pill),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.base),
        curve: AppMotion.easeOut,
        height: height,
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: small ? AppSpacing.s4 : AppSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.all(AppRadii.pill),
          boxShadow: shadow,
          border: ring == null
              ? null
              : Border.all(color: ring, width: AppBorders.hairline),
        ),
        alignment: Alignment.center,
        child: loading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
              )
            : content,
      ),
    );
  }
}

/// Circular "next" button that ends a step (`.fab`): purple with a white arrow; disabled grey.
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
          color: enabled ? AppColors.brand : AppColors.surfaceSunken,
          boxShadow: enabled ? AppElevation.button : const [],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.onBrand,
                ),
              )
            : NumayaIcon(
                icon,
                color: enabled ? AppColors.onBrand : AppColors.textSubtle,
              ),
      ),
    );
  }
}

enum NavButtonStyle {
  /// White circle with a soft shadow (top bars).
  floating,

  /// Grey circle, 36 (sheet close).
  flat,

  /// Bare icon.
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
    final (Color bg, Color fg, List<BoxShadow> shadow) = switch (style) {
      NavButtonStyle.floating => (
        AppColors.surface,
        AppColors.textPrimary,
        AppElevation.sm,
      ),
      NavButtonStyle.flat => (
        AppColors.surfaceSoft,
        AppColors.textSecondary,
        const <BoxShadow>[],
      ),
      NavButtonStyle.plain => (
        Colors.transparent,
        AppColors.textSecondary,
        const <BoxShadow>[],
      ),
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
            boxShadow: shadow,
          ),
          alignment: Alignment.center,
          child: NumayaIcon(
            icon,
            size: style == NavButtonStyle.flat
                ? AppSizes.iconMd
                : AppSizes.iconLg,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// Underlined inline action (`.text-button`): brand purple, semibold.
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
        ? AppColors.textSubtle
        : danger
        ? AppColors.danger
        : muted
        ? AppColors.textSecondary
        : AppColors.textBrand;
    final base = style ?? AppTypography.body;
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.xs),
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
                : muted
                ? AppColors.borderStrong
                : color.withValues(alpha: 0.32),
          ),
        ),
      ),
    );
  }
}
