import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import '../icons/tabler_icons.dart';
import 'primitives.dart' show MobileIcon, Pressable;

/// V8 information card: one consistent order for any card that reports a value.
/// 1 icon, 2 heading, 3 primary value, 4 visual (bar, dots, art), 5 metadata. Any part but the
/// heading and value may be left out. Pair two with [InfoTilePair].
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.visual,
    this.meta,
    this.onTap,
  });

  final NumayaMobileIcons icon;
  final String title;
  final String value;
  final Widget? visual;
  final String? meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentWash,
                  borderRadius: AppRadii.all(AppRadii.iconTile),
                ),
                alignment: Alignment.center,
                child: MobileIcon(
                  icon,
                  size: AppSizes.iconSm,
                  color: AppColors.accentOnTint,
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.weight(
                    AppTypography.caption,
                    AppTypography.semibold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(value, style: AppTypography.pageTitle),
          if (visual != null) ...[
            const SizedBox(height: AppSpacing.s3),
            ExcludeSemantics(child: visual!),
          ],
          if (meta != null) ...[
            const SizedBox(height: AppSpacing.s3),
            Text(meta!, style: AppTypography.caption),
          ],
        ],
      ),
    );
    if (onTap == null) {
      return Semantics(
        container: true,
        label: [title, value, ?meta].join('. '),
        excludeSemantics: true,
        child: body,
      );
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: [title, value, ?meta].join('. '),
      excludeChildSemantics: true,
      pressedScale: 0.98,
      borderRadius: AppRadii.all(AppRadii.card),
      child: body,
    );
  }
}

/// Two [InfoTile]s side by side, equal height; stacked when the width or text size can't hold
/// two columns comfortably.
class InfoTilePair extends StatelessWidget {
  const InfoTilePair({super.key, required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final large = MediaQuery.textScalerOf(context).scale(15) > 22;
        if (large || box.maxWidth < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              const SizedBox(height: AppSpacing.s3),
              second,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: first),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: second),
            ],
          ),
        );
      },
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
