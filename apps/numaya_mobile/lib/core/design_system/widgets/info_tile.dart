import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import '../icons/tabler_icons.dart';
import 'primitives.dart' show MobileIcon, Pressable;

/// V9 information card: a full-width, single-column card that reports one thing.
///
/// Reading order (docs/v9/design-decisions.md, D-04): 1 a small icon and heading, 2 the primary
/// value, 3 one short line of description, 4 an optional visual (bar, marks), 5 optional metadata.
/// An illustration may sit at the side ([art], [artStart] puts it on the left) with its own room,
/// never under the text. The icon is drawn straight on the card, filled at this small size and
/// with no backplate (V9 icon rule). The whole card is one tap target with one destination:
/// actions never sit inside it.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.description,
    this.visual,
    this.meta,
    this.art,
    this.artStart = false,
    this.onTap,
  });

  final NumayaMobileIcons icon;
  final String title;
  final String value;
  final String? description;
  final Widget? visual;
  final String? meta;

  /// The illustration (usually a [SceneArt] about 96pt wide).
  final Widget? art;
  final bool artStart;
  final VoidCallback? onTap;

  /// Width kept for [art] beside the text.
  static const double artWidth = 96;

  @override
  Widget build(BuildContext context) {
    // At large text the art drops under the copy, so the text keeps the card's full width.
    final large = MediaQuery.textScalerOf(context).scale(15) > 21;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MobileIcon(
              icon,
              size: AppSizes.iconSm,
              filled: true,
              color: AppColors.accentOnTint,
            ),
            const SizedBox(width: AppSpacing.s2),
            Expanded(
              child: Text(
                title,
                style: AppTypography.weight(
                  AppTypography.caption,
                  AppTypography.semibold,
                ).copyWith(color: AppColors.accentOnTint),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(value, style: AppTypography.pageTitle),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.s1),
          Text(
            description!,
            maxLines: 2,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (visual != null) ...[
          const SizedBox(height: AppSpacing.s3),
          ExcludeSemantics(child: visual!),
        ],
        if (meta != null) ...[
          const SizedBox(height: AppSpacing.s2),
          Text(meta!, style: AppTypography.caption),
        ],
      ],
    );
    final artBox = art == null
        ? null
        : ExcludeSemantics(
            child: SizedBox(
              width: artWidth,
              child: Center(child: art),
            ),
          );
    final Widget content;
    if (artBox == null) {
      content = text;
    } else if (large) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          text,
          const SizedBox(height: AppSpacing.s3),
          Align(alignment: AlignmentDirectional.centerStart, child: artBox),
        ],
      );
    } else {
      content = Row(
        children: [
          if (artStart) ...[artBox, const SizedBox(width: AppSpacing.s4)],
          Expanded(child: text),
          if (!artStart) ...[const SizedBox(width: AppSpacing.s4), artBox],
        ],
      );
    }
    final body = Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: content,
    );
    final label = [title, value, ?description, ?meta].join('. ');
    if (onTap == null) {
      return Semantics(
        container: true,
        label: label,
        excludeSemantics: true,
        child: body,
      );
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      excludeChildSemantics: true,
      pressedScale: 0.98,
      borderRadius: AppRadii.all(AppRadii.card),
      child: body,
    );
  }
}

/// A thin bar split into proportional parts (credit buckets, in spend order).
class SegmentBar extends StatelessWidget {
  const SegmentBar({super.key, required this.parts});

  final List<(int, Color)> parts;

  @override
  Widget build(BuildContext context) {
    final total = parts.fold<int>(0, (n, p) => n + p.$1);
    return ClipRRect(
      borderRadius: AppRadii.all(AppRadii.pill),
      child: SizedBox(
        height: 8,
        child: total == 0
            ? const ColoredBox(color: AppColors.divider)
            : Row(
                children: [
                  for (final (n, c) in parts)
                    if (n > 0)
                      Expanded(
                        flex: n,
                        child: Container(
                          margin: const EdgeInsetsDirectional.only(end: 2),
                          color: c,
                        ),
                      ),
                ],
              ),
      ),
    );
  }
}

/// A row of short marks, [done] of [total] filled (streak days).
class StepMarks extends StatelessWidget {
  const StepMarks({super.key, required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: i < done ? AppColors.accent : AppColors.divider,
                borderRadius: AppRadii.all(AppRadii.pill),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
