import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

/// Black translucent glass for content over a photo (V4 rule IMG-1): a clipped blur under exactly
/// the child's bounds and [AppColors.photoPanel] (55% black). The tint alone keeps white text at
/// 4.74:1 over a pure white photo, so the content stays readable where blur is unavailable. High
/// contrast mode drops the blur and raises the tint to 80% (9.7:1 or better).
///
/// In a scrolling grid, wrap the list in a [BackdropGroup] so the small filters share one backdrop.
class PhotoGlass extends StatelessWidget {
  const PhotoGlass({
    super.key,
    required this.child,
    this.radius = AppRadii.pill,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final strong = MediaQuery.highContrastOf(context);
    final content = ColoredBox(
      color: strong ? const Color(0xCC000000) : AppColors.photoPanel,
      child: Padding(padding: padding, child: child),
    );
    final group = BackdropGroup.of(context);
    return ClipRRect(
      borderRadius: AppRadii.all(radius),
      child: strong
          ? content
          : group != null
          ? BackdropFilter.grouped(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: content,
            )
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: content,
            ),
    );
  }
}

/// A status or fact over a photo (V4 rule IMG-1): white 12/16 semibold on [PhotoGlass], with an
/// optional meaningful white icon. Never tinted purple or a semantic colour over an image.
class PhotoPill extends StatelessWidget {
  const PhotoPill({
    super.key,
    required this.label,
    this.icon,
    this.filled = false,
  });

  final String label;
  final NumayaIcons? icon;

  /// Draw Tabler's filled artwork for [icon].
  final bool filled;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 26),
    child: PhotoGlass(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.badgeInsetX,
        vertical: AppLayout.badgeInsetY,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            NumayaIcon(
              icon!,
              size: 14,
              filled: filled,
              color: AppColors.inkForeground,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.weight(
                AppTypography.micro,
                AppTypography.semibold,
              ).copyWith(color: AppColors.inkForeground),
            ),
          ),
        ],
      ),
    ),
  );
}

/// White type straight on a photo: a tight shadow holds the letterforms over bright patches and a
/// wide one softens the area around them. Used with [PhotoScrim] on every name over a photo.
///
/// Owner note (selections pass, 2026-11-13): no text shadow on photos. Readability comes from the
/// smooth bottom gradient alone ([PhotoScrim]); this stays as the one place to restore a shadow.
abstract final class PhotoText {
  static const List<Shadow> shadows = [];
}

/// A compact backing for a name or title over a photo (V4 rule IMG-3). The photo gradient is held
/// under 25%, which cannot keep white text readable on a bright or busy crop, so the text carries
/// its own hugging glass instead of a dark band across the image.
class PhotoLabel extends StatelessWidget {
  const PhotoLabel({super.key, required this.child, this.compact = false});

  final Widget child;

  /// Tighter inset for small tiles.
  final bool compact;

  @override
  Widget build(BuildContext context) => PhotoGlass(
    radius: compact ? AppRadii.tag + 4 : AppRadii.control,
    padding: compact
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.s2,
            vertical: AppSpacing.s1,
          )
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: AppSpacing.s2,
          ),
    child: child,
  );
}
