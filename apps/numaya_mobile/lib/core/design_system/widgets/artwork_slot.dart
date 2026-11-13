import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'illustration_slot.dart';
import 'primitives.dart';

/// UI-076/UI-077 (V8): space reserved for artwork the reviewer will supply (the Premium hero, a
/// mascot in an empty state). Unlike [IllustrationSlot], it always keeps its [aspectRatio] so the
/// layout is final before the art exists: a quiet tint with a small image glyph and, in review
/// builds with [IllustrationPlaceholders] on, a caption naming the slot. Decorative: excluded
/// from semantics. Replace with the asset through [art] once it exists (ARTWORK_SLOTS.csv).
class ArtworkSlot extends StatelessWidget {
  const ArtworkSlot({
    super.key,
    required this.slot,
    required this.label,
    this.aspectRatio = 16 / 9,
    this.art,
    this.radius = AppRadii.heroCard,
  });

  /// Code from ARTWORK_SLOTS.csv (`premium_hero`).
  final String slot;

  /// What the artwork should show.
  final String label;
  final double aspectRatio;
  final Widget? art;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final review = IllustrationPlaceholders.showIn(context);
    return ExcludeSemantics(
      child: AspectRatio(
        key: ValueKey('artwork-slot-$slot'),
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: AppRadii.all(radius),
          child:
              art ??
              ColoredBox(
                color: AppColors.accentTint,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const NumayaIcon(
                        NumayaIcons.image,
                        size: AppSizes.iconLg,
                        color: AppColors.accentOnTint,
                      ),
                      if (review) ...[
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          'Artwork: $label',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.accentOnTint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
