import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'buttons.dart';
import 'illustration_slot.dart';
import 'primitives.dart';

/// UI-061 (V8): the illustrated card for promotions, pricing and summaries. A compact white card:
/// heading, short supporting copy and an optional compact action (UI-062) on the content side,
/// and a square artwork area on the other. The square stays reserved even before the artwork
/// exists (the reviewer supplies it later): a quiet neutral tile with a small image glyph, and in
/// review builds with [IllustrationPlaceholders] on, a short caption naming the slot.
///
/// [artStart] puts the artwork on the leading side. [content] replaces the heading block for
/// statistics (figures and a progress indicator grouped on the content side).
class PromoCard extends StatelessWidget {
  const PromoCard({
    super.key,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.slot = 'promo',
    this.slotLabel = 'Promotion artwork',
    this.art,
    this.artStart = false,
    this.content,
    this.onTap,
  });

  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final NumayaIcons? actionIcon;

  /// Artwork slot code (ARTWORK_SLOTS.csv) and what it should show.
  final String slot;
  final String slotLabel;

  /// The artwork once supplied; null keeps the reserved square.
  final Widget? art;
  final bool artStart;
  final Widget? content;

  /// The whole card as one target (Settings), in addition to or instead of the action.
  final VoidCallback? onTap;

  /// The artwork square's side.
  static const double artSize = 88;

  @override
  Widget build(BuildContext context) {
    final text =
        content ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTypography.card),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.s1),
              Text(
                body!,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.s3),
              NumayaButton(
                label: actionLabel!,
                small: true,
                expand: false,
                icon: actionIcon,
                onPressed: onAction,
              ),
            ],
          ],
        );
    final square = ExcludeSemantics(
      child: SizedBox.square(
        key: ValueKey('promo-art-$slot'),
        dimension: artSize,
        child: art ?? _ReservedArt(label: slotLabel),
      ),
    );
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (artStart) ...[square, const SizedBox(width: AppSpacing.s4)],
        Expanded(child: text),
        if (!artStart) ...[const SizedBox(width: AppSpacing.s4), square],
      ],
    );
    final card = Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: row,
    );
    if (onTap == null) return Semantics(container: true, child: card);
    return Pressable(
      onTap: onTap,
      semanticLabel: body == null ? title : '$title. $body',
      excludeChildSemantics: actionLabel == null,
      borderRadius: AppRadii.all(AppRadii.card),
      child: card,
    );
  }
}

class _ReservedArt extends StatelessWidget {
  const _ReservedArt({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final review = IllustrationPlaceholders.showIn(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        // Nested inside the 16pt card at a 16pt inset: a square inner corner would be 0; the
        // tile is its own medium tile (12), not a contour of the card's corner.
        borderRadius: AppRadii.all(AppRadii.iconButton),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NumayaIcon(
              NumayaIcons.image,
              size: AppSizes.iconMd,
              color: AppColors.textSubtle,
            ),
            if (review) ...[
              const SizedBox(height: AppSpacing.s1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.micro.copyWith(fontSize: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
