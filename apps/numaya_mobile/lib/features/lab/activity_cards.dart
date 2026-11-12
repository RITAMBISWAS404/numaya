import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'lab_empty_state.dart';
import 'lab_registry.dart';

/// What the streak cards show. All real demo state (no invented activity).
typedef StreakData = ({int length, int progress, int cycle, bool todayCounts});

/// Card family `streak-card` (Visual Lab V2). O is the approved streak card (flame, days, the
/// seven-step row, the cycle line), kept as the baseline; A week row only, B next reward bar,
/// C large number, D illustration slot. No variant uses pressure copy or a looping effect.
class StreakSummaryCard extends ConsumerWidget {
  const StreakSummaryCard({
    super.key,
    required this.data,
    this.onTap,
    this.variant,
  });

  final StreakData data;
  final VoidCallback? onTap;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('streak-card'));
    final l10n = context.l10n;
    final d = data;
    final days = l10n.streakDays(d.length);
    final cycleLine = l10n.streakCycle(d.progress);
    final today = d.todayCounts ? l10n.streakToday : l10n.streakTodayOpen;
    final flame = MobileIcon(
      NumayaMobileIcons.flame,
      size: 28,
      filled: d.length > 0,
      color: d.length > 0 ? AppColors.accent : AppColors.textSecondary,
    );
    Widget dots() => ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < d.cycle; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.s2),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: i < d.progress ? AppColors.accent : AppColors.divider,
                  borderRadius: AppRadii.all(AppRadii.pill),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    BoxDecoration card() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    );
    const pad = EdgeInsets.all(AppLayout.cardPadding);
    final Widget body;
    switch (v) {
      case 'A':
        body = Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(days, style: AppTypography.card)),
                  Text(cycleLine, style: AppTypography.caption),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              dots(),
            ],
          ),
        );
      case 'B':
        final left = d.cycle - d.progress;
        body = Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  flame,
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(child: Text(days, style: AppTypography.card)),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: AppRadii.all(AppRadii.pill),
                  child: LinearProgressIndicator(
                    value: d.progress / d.cycle,
                    minHeight: 8,
                    color: AppColors.accent,
                    backgroundColor: AppColors.fill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                left == 0 ? l10n.streakRewardReady : l10n.streakToReward(left),
                style: AppTypography.bodySm,
              ),
            ],
          ),
        );
      case 'C':
        body = Container(
          padding: pad,
          decoration: card(),
          child: Row(
            children: [
              Text(
                '${d.length}',
                style: AppTypography.hero.copyWith(fontSize: 48, height: 1),
              ),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.streakDaysUnit(d.length),
                      style: AppTypography.weight(
                        AppTypography.body,
                        AppTypography.semibold,
                      ),
                    ),
                    Text(cycleLine, style: AppTypography.caption),
                    Text(today, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'D':
        body = Container(
          padding: pad,
          decoration: card(),
          child: Row(
            children: [
              const IllustrationBox(
                label: 'purple cat beside a small flame',
                width: 72,
              ),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(days, style: AppTypography.card),
                    const SizedBox(height: AppSpacing.s1),
                    Text(cycleLine, style: AppTypography.bodySm),
                    Text(today, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        body = Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  flame,
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(child: Text(days, style: AppTypography.pageTitle)),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
              dots(),
              const SizedBox(height: AppSpacing.s3),
              Text(cycleLine, style: AppTypography.bodySm),
              const SizedBox(height: AppSpacing.s1),
              Text(today, style: AppTypography.helper),
            ],
          ),
        );
    }
    final spoken = [days, cycleLine, today].join('. ');
    if (onTap == null) {
      return Semantics(label: spoken, excludeSemantics: true, child: body);
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: spoken,
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.card),
      child: body,
    );
  }
}

/// What the wallet cards show (the real demo ledger).
typedef WalletData = ({
  int weekly,
  int earned,
  int purchased,
  List<({String label, int amount})> recent,
});

/// Card family `wallet-card`: how many Compliments can be sent and which credits go first.
/// O balance and buckets, A stacked bar in spend order (Ente Segments 7585:3118), B hero balance,
/// C chips, D recent activity.
class WalletSummaryCard extends ConsumerWidget {
  const WalletSummaryCard({
    super.key,
    required this.data,
    this.onTap,
    this.variant,
  });

  final WalletData data;
  final VoidCallback? onTap;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('wallet-card'));
    // Replacement V8 comparison r8-wallet-value: A leads with the number and drops the repeated
    // spend-order sentence (the Wallet screen states it). O is the owner's V7 card unchanged.
    final valueLed = ref.watch(labVariantProvider('r8-wallet-value')) == 'A';
    final l10n = context.l10n;
    final d = data;
    final total = d.weekly + d.earned + d.purchased;
    final buckets = [
      (l10n.walletWeekly, d.weekly, AppColors.accent),
      (l10n.walletEarned, d.earned, AppColors.accent.withValues(alpha: 0.55)),
      (
        l10n.walletPurchased,
        d.purchased,
        AppColors.accent.withValues(alpha: 0.25),
      ),
    ];
    BoxDecoration card() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    );
    const pad = EdgeInsets.all(AppLayout.cardPadding);
    Widget heading() => Row(
      children: [
        const MobileIcon(
          NumayaMobileIcons.wallet,
          size: AppSizes.iconMd,
          color: AppColors.ink,
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: Text(
            l10n.walletTitle,
            style: AppTypography.weight(
              AppTypography.body,
              AppTypography.semibold,
            ),
          ),
        ),
        Text(l10n.walletTotal(total), style: AppTypography.bodySm),
      ],
    );
    final Widget body;
    switch (v) {
      case 'A':
        body = Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (valueLed) ...[
                Row(
                  children: [
                    const MobileIcon(
                      NumayaMobileIcons.wallet,
                      size: AppSizes.iconMd,
                      color: AppColors.ink,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Expanded(
                      child: Text(
                        l10n.walletTitle,
                        style: AppTypography.weight(
                          AppTypography.body,
                          AppTypography.semibold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  l10n.walletTotal(total),
                  key: const ValueKey('wallet-card-value'),
                  style: AppTypography.pageTitle,
                ),
              ] else
                heading(),
              const SizedBox(height: AppSpacing.s3),
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: AppRadii.all(AppRadii.pill),
                  child: SizedBox(
                    height: 10,
                    child: total == 0
                        ? const ColoredBox(color: AppColors.fill)
                        : Row(
                            children: [
                              for (final (_, n, c) in buckets)
                                if (n > 0)
                                  Expanded(
                                    flex: n,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 2),
                                      color: c,
                                    ),
                                  ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              Wrap(
                spacing: AppSpacing.s4,
                runSpacing: AppSpacing.s1,
                children: [
                  for (final (label, n, c) in buckets)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s1),
                        Text('$label $n', style: AppTypography.caption),
                      ],
                    ),
                ],
              ),
              if (!valueLed) ...[
                const SizedBox(height: AppSpacing.s2),
                Text(l10n.walletOrderShort, style: AppTypography.caption),
              ],
            ],
          ),
        );
      case 'B':
        body = Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.walletCanSend, style: AppTypography.caption),
              Text('$total', style: AppTypography.hero),
              const SizedBox(height: AppSpacing.s2),
              for (final (label, n, _) in buckets)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s1),
                  child: Row(
                    children: [
                      Expanded(child: Text(label, style: AppTypography.bodySm)),
                      Text('$n', style: AppTypography.bodySm),
                    ],
                  ),
                ),
            ],
          ),
        );
      case 'C':
        body = Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading(),
              const SizedBox(height: AppSpacing.s3),
              Wrap(
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
                children: [
                  for (final (label, n, _) in buckets)
                    StatusBadge(label: '$label · $n'),
                ],
              ),
            ],
          ),
        );
      case 'D':
        body = Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading(),
              const SizedBox(height: AppSpacing.s2),
              if (d.recent.isEmpty)
                Text(l10n.walletHistoryEmpty, style: AppTypography.caption)
              else
                for (final e in d.recent.take(3))
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s1),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.label,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          e.amount > 0 ? '+${e.amount}' : '${e.amount}',
                          style: AppTypography.weight(
                            AppTypography.bodySm,
                            AppTypography.semibold,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      default:
        body = Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading(),
              const SizedBox(height: AppSpacing.s2),
              for (final (label, n, _) in buckets)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s1),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text('$n', style: AppTypography.bodySm),
                    ],
                  ),
                ),
            ],
          ),
        );
    }
    final spoken = [
      l10n.walletTitle,
      l10n.walletTotal(total),
      for (final (label, n, _) in buckets) '$label $n',
    ].join('. ');
    final wrapped = body;
    if (onTap == null) {
      return Semantics(label: spoken, excludeSemantics: true, child: wrapped);
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: spoken,
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.card),
      child: wrapped,
    );
  }
}
