import 'package:flutter/widgets.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import '../icons/tabler_icons.dart';
import 'primitives.dart';

/// The top card of a detail screen (selections pass, 2026-11-13; owner notes on Credits and
/// Streak): a small icon and heading, the number as the large line, a bar, then short details.
/// One anatomy for every such card; [purple] keeps the Credits card's selected purple surface.
///
/// The [bar] slot is for a real quantity only (seven streak days, the parts of a balance in spend
/// order). Leave it null rather than invent a denominator.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.icon,
    required this.heading,
    required this.value,
    this.iconFilled = false,
    this.bar,
    this.details = const [],
    this.purple = false,
  });

  final NumayaMobileIcons icon;
  final bool iconFilled;
  final String heading;

  /// The large line ("2 credits", "1-day streak").
  final String value;

  /// Draws the bar for this card's surface (see [SummaryBar]).
  final Widget Function(bool onPurple)? bar;

  /// One to three short lines under the bar; the first reads as the main detail.
  final List<String> details;
  final bool purple;

  @override
  Widget build(BuildContext context) {
    final fg = purple ? AppColors.accentForeground : AppColors.ink;
    final muted = purple ? AppColors.accentForeground : AppColors.textSecondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.heroPadding),
      decoration: BoxDecoration(
        color: purple ? AppColors.accent : AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.heroCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MobileIcon(
                icon,
                size: AppSizes.iconSm,
                filled: iconFilled,
                color: purple ? AppColors.accentForeground : AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(
                  heading,
                  style: AppTypography.weight(
                    AppTypography.bodySm,
                    AppTypography.semibold,
                  ).copyWith(color: muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Semantics(
            header: true,
            child: Text(
              value,
              style: AppTypography.pageTitle.copyWith(color: fg),
            ),
          ),
          if (bar != null) ...[
            const SizedBox(height: AppSpacing.s4),
            bar!(purple),
          ],
          for (var i = 0; i < details.length; i++) ...[
            SizedBox(height: i == 0 ? AppSpacing.s3 : AppSpacing.s1),
            Text(
              details[i],
              style: (i == 0 ? AppTypography.bodySm : AppTypography.helper)
                  .copyWith(color: i == 0 ? fg : muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// A bar for [SummaryCard]. [parts] are (amount, filled) in order: seven days of a streak are
/// seven parts of 1; a balance is its buckets in spend order, each as wide as its amount.
class SummaryBar extends StatelessWidget {
  const SummaryBar({
    super.key,
    required this.parts,
    required this.onPurple,
    required this.spoken,
  });

  final List<(int, bool)> parts;
  final bool onPurple;
  final String spoken;

  @override
  Widget build(BuildContext context) {
    final on = onPurple ? AppColors.accentForeground : AppColors.accent;
    final off = onPurple ? const Color(0x4DFFFFFF) : AppColors.fill;
    final total = parts.fold<int>(0, (n, p) => n + p.$1);
    return Semantics(
      label: spoken,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 8,
          child: total == 0
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: off,
                    borderRadius: AppRadii.all(AppRadii.pill),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < parts.length; i++)
                      if (parts[i].$1 > 0) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.s1),
                        Expanded(
                          flex: parts[i].$1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: parts[i].$2 ? on : off,
                              borderRadius: AppRadii.all(AppRadii.pill),
                            ),
                          ),
                        ),
                      ],
                  ],
                ),
        ),
      ),
    );
  }
}
