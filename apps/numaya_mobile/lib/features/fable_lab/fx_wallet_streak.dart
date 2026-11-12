import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../lab/activity_cards.dart' show WalletData;
import 'fx_profile.dart';

/// Fable design lab, groups `fx-wallet` and `fx-streak`. Every number is the member's real state;
/// the credit and streak rules are untouched. Art is the stand-in mascot (artwork-pending).

/// `fx-wallet` A (recipe W1, number-led sidecar): the amount and its label on the left, the art
/// on the right, the three buckets as labelled numbers, and the one action across the foot of
/// the same card (it leaves the screen footer).
class FxWalletSidecar extends StatelessWidget {
  const FxWalletSidecar({
    super.key,
    required this.data,
    required this.actionLabel,
    required this.onAction,
  });

  final WalletData data;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = data.weekly + data.earned + data.purchased;
    final large = MediaQuery.textScalerOf(context).scale(10) > 13;
    return Container(
      padding: const EdgeInsets.all(AppLayout.heroPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.heroCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  label: l10n.fxCreditsToSend(total),
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$total', style: AppTypography.metric),
                        Text(
                          l10n.fxCreditsToSend(total),
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!large)
                const ExcludeSemantics(
                  child: IllustrationView(
                    NumayaIllustration.mascotCheer,
                    width: 104,
                  ),
                ),
            ],
          ),
          const NumayaDividerLine(),
          FxBalanceColumns(data: data, onHero: false),
          const SizedBox(height: AppSpacing.s4),
          NumayaButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}

/// A hairline with room above and below, inside a card.
class NumayaDividerLine extends StatelessWidget {
  const NumayaDividerLine({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: SizedBox(
        height: AppBorders.hairline,
        width: double.infinity,
        child: ColoredBox(color: AppColors.divider),
      ),
    ),
  );
}

/// `fx-wallet` B: the three buckets as short tiles under the feature card. Three across while
/// they fit; a column at large text or on a narrow phone.
class FxBucketTiles extends StatelessWidget {
  const FxBucketTiles({super.key, required this.buckets});

  /// (label, amount, detail for the spoken label, destination or null).
  final List<(String, int, String, VoidCallback?)> buckets;

  @override
  Widget build(BuildContext context) {
    Widget tile((String, int, String, VoidCallback?) b) {
      final body = Container(
        padding: const EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('${b.$2}', style: AppTypography.card)),
                if (b.$4 != null)
                  const NumayaIcon(
                    NumayaIcons.chevronRight,
                    size: AppSizes.iconSm,
                    color: AppColors.textMuted,
                  ),
              ],
            ),
            Text(
              b.$1,
              style: AppTypography.weight(
                AppTypography.caption,
                AppTypography.semibold,
              ).copyWith(color: AppColors.ink),
            ),
            // The detail is spoken and one tap away; a third of the width cannot hold a sentence.
          ],
        ),
      );
      final spoken = '${b.$1}, ${b.$2}. ${b.$3}';
      return b.$4 == null
          ? Semantics(
              container: true,
              label: spoken,
              excludeSemantics: true,
              child: body,
            )
          : Pressable(
              onTap: b.$4,
              semanticLabel: spoken,
              excludeChildSemantics: true,
              pressedScale: 0.98,
              borderRadius: AppRadii.all(AppRadii.card),
              child: body,
            );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final large = MediaQuery.textScalerOf(context).scale(15) > 19;
        if (large || box.maxWidth < 330) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < buckets.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.s2),
                tile(buckets[i]),
              ],
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < buckets.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.s2),
                Expanded(child: tile(buckets[i])),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// `fx-streak` A (recipe T1): the week as seven numbered days. Counted days carry a check, the
/// next day to earn is ringed, and the last day shows the reward. [done] of [total] are counted.
class FxWeekStrip extends StatelessWidget {
  const FxWeekStrip({
    super.key,
    required this.done,
    required this.total,
    required this.spoken,
  });

  final int done;
  final int total;
  final String spoken;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: spoken,
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s1),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _Day(
                    number: i + 1,
                    counted: i < done,
                    next: i == done,
                    reward: i == total - 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.number,
    required this.counted,
    required this.next,
    required this.reward,
  });

  final int number;
  final bool counted;
  final bool next;
  final bool reward;

  @override
  Widget build(BuildContext context) {
    final fg = counted
        ? AppColors.accentForeground
        : next
        ? AppColors.accentOnTint
        : AppColors.textMuted;
    return Container(
      decoration: BoxDecoration(
        color: counted ? AppColors.accent : null,
        shape: BoxShape.circle,
        border: counted
            ? null
            : Border.all(
                color: next ? AppColors.accent : AppColors.border,
                width: next ? AppBorders.selected : AppBorders.hairline,
              ),
      ),
      alignment: Alignment.center,
      child: counted
          ? NumayaIcon(NumayaIcons.check, size: 18, color: fg)
          : reward
          ? MobileIcon(NumayaMobileIcons.gift, size: 18, color: fg)
          : FittedBox(
              child: Text(
                '$number',
                textScaler: TextScaler.noScaling,
                style: AppTypography.weight(
                  AppTypography.bodySm,
                  AppTypography.semibold,
                ).copyWith(color: fg),
              ),
            ),
    );
  }
}
