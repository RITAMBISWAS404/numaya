import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../icons/numaya_icon_data.g.dart';
import '../icons/tabler_icons.dart' show NumayaMobileIcons;
import 'primitives.dart';

/// The shared elevated squircle control (Visual Lab V2, R05/R08): Ente's 38pt Icon Button
/// (`2207:42075`, radius 12) on a **white surface** with a dark or brand glyph and the subtle
/// shadow, inside a 48pt tap target. One size for the header buttons, the sheet close and the
/// Compliment action, so the three read as one family.
///
/// R08 interpretation (recorded in DECISIONS VL-D08): "white" means a white button surface with a
/// visible contrasting glyph. A white glyph is used only on a coloured surface ([onBrand]).
class SquircleIconButton extends StatelessWidget {
  const SquircleIconButton({
    super.key,
    this.icon,
    this.mobileIcon,
    required this.label,
    required this.onPressed,
    this.brandGlyph = false,
    this.onBrand = false,
    this.elevated = true,
  }) : assert(icon != null || mobileIcon != null);

  final NumayaIcons? icon;
  final NumayaMobileIcons? mobileIcon;
  final String label;
  final VoidCallback? onPressed;

  /// Purple glyph (the Compliment action); otherwise ink.
  final bool brandGlyph;

  /// Purple surface with a white glyph.
  final bool onBrand;

  /// The subtle shadow; off where the button sits on a white surface already.
  final bool elevated;

  static const double size = AppSizes.iconButton;
  static const double target = 48;

  @override
  Widget build(BuildContext context) {
    // On a white card the white squircle would vanish: it takes the fill grey, flat (Ente's icon
    // button on a white surface).
    final onWhite = OnWhiteSurface.of(context) && !onBrand;
    final glyphColor = onPressed == null
        ? AppColors.disabledForeground
        : onBrand
        ? AppColors.accentForeground
        : brandGlyph
        ? AppColors.accent
        : AppColors.ink;
    final glyph = icon != null
        ? NumayaIcon(icon!, size: AppSizes.iconMd, color: glyphColor)
        : MobileIcon(mobileIcon!, size: AppSizes.iconMd, color: glyphColor);
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: label,
        excludeChildSemantics: true,
        pressedScale: 0.95,
        borderRadius: AppRadii.all(AppRadii.iconButton),
        child: SizedBox.square(
          dimension: target,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: onBrand
                    ? AppColors.accent
                    : onWhite
                    ? AppColors.fill
                    : AppColors.surface,
                borderRadius: AppRadii.all(AppRadii.iconButton),
                boxShadow: elevated && !onWhite
                    ? AppElevation.subtle
                    : AppElevation.none,
              ),
              alignment: Alignment.center,
              child: glyph,
            ),
          ),
        ),
      ),
    );
  }
}

/// Marks a white surface (a card) so a [SquircleIconButton] inside draws on the fill grey.
class OnWhiteSurface extends InheritedWidget {
  const OnWhiteSurface({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OnWhiteSurface>() != null;

  @override
  bool updateShouldNotify(OnWhiteSurface oldWidget) => false;
}
