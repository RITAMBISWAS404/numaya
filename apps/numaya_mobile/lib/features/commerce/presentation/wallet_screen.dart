import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../fable_lab/fx_profile.dart';
import '../../fable_lab/fx_wallet_streak.dart';
import '../../lab/activity_cards.dart' show WalletData;
import '../../lab/lab_registry.dart';
import '../../premium/application/premium_controller.dart';
import '../application/economy_controller.dart';
import '../../lab/stat_templates.dart';
import '../domain/credit_ledger.dart';
import 'store_screens.dart';

/// S33: Compliment credits by bucket (weekly, earned, purchased) with their dates, the spending
/// order, the ledger history and the way to buy more.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Bring the weekly allowance up to date when the wallet opens (server time in a live build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(economyProvider.notifier).syncWeekly();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final economy = ref.watch(economyProvider);
    final premium = ref.watch(premiumProvider);
    final controller = ref.read(economyProvider.notifier);
    final ledger = economy.ledger;
    final nextWeekly = controller.nextWeeklyGrant();
    final history = ledger.entries.reversed.toList();
    // Fable lab `fx-wallet`: A number-led card with the action inside it; B the feature card with
    // the buckets as tiles. In both the action leaves the footer.
    final fx = ref.watch(labVariantProvider('fx-wallet'));
    final WalletData data = (
      weekly: ledger.weekly,
      earned: ledger.earned,
      purchased: ledger.purchased,
      recent: const [],
    );
    void getMore() => context.push(Routes.storeCompliments);
    final weeklyDetail = premium.active && nextWeekly != null
        ? l10n.walletWeeklyDetail(shortDate(nextWeekly))
        : l10n.walletWeeklyNone;
    final VoidCallback? toPremium = premium.active
        ? null
        : () => context.push(
            '${Routes.paywall}?feature=${PremiumFeature.compliments.name}',
          );
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.walletTitle,
      ),
      footer: fx == 'O'
          ? NumayaButton(label: l10n.complimentGetMore, onPressed: getMore)
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          // UI-078 review: a chosen statistics template replaces the header card.
          if (chosenStatTemplate(ref) != null)
            StatCard(
              key: const ValueKey('wallet-stat'),
              data: statFamily(ref, l10n).credits,
              template: chosenStatTemplate(ref)!,
            )
          else if (fx == 'A')
            FxWalletSidecar(
              data: data,
              actionLabel: l10n.complimentGetMore,
              onAction: getMore,
            )
          else if (fx == 'B')
            FxHeroCard(
              label: l10n.walletTitle,
              value: '${ledger.total} ${l10n.walletUnit(ledger.total)}',
              detail: l10n.fxSpendOrder,
              art: NumayaIllustration.mascotCheer,
              spoken:
                  '${l10n.walletTitle}, ${ledger.total} ${l10n.walletUnit(ledger.total)}',
              action: Pressable(
                key: const ValueKey('fx-wallet-get'),
                onTap: getMore,
                semanticLabel: l10n.complimentGetMore,
                excludeChildSemantics: true,
                borderRadius: AppRadii.all(AppRadii.control),
                child: FxHeroPill(label: l10n.complimentGetMore),
              ),
            )
          else if (ref.watch(labVariantProvider('v6-wallet-header')) == 'A')
            // The selected purple card in the shared summary anatomy (owner note): icon and
            // heading, the balance, a bar of its parts in spend order, then which part is which.
            SummaryCard(
              key: const ValueKey('wallet-summary'),
              purple: true,
              icon: NumayaMobileIcons.wallet,
              heading: l10n.walletTitle,
              value: '${ledger.total} ${l10n.walletUnit(ledger.total)}',
              bar: (onPurple) => SummaryBar(
                onPurple: onPurple,
                spoken: l10n.walletOrder,
                parts: [
                  (ledger.weekly, true),
                  (ledger.earned, true),
                  (ledger.purchased, true),
                ],
              ),
              details: [
                [
                  '${l10n.walletWeekly} ${ledger.weekly}',
                  '${l10n.walletEarned} ${ledger.earned}',
                  '${l10n.walletPurchased} ${ledger.purchased}',
                ].join(' · '),
              ],
            )
          else
            MetricTile(
              label: l10n.walletTitle,
              value: '${ledger.total}',
              unit: l10n.walletUnit(ledger.total),
            ),
          if (fx == 'B') ...[
            const SizedBox(height: AppSpacing.s3),
            FxBucketTiles(
              buckets: [
                (l10n.walletWeekly, ledger.weekly, weeklyDetail, toPremium),
                (
                  l10n.walletEarned,
                  ledger.earned,
                  l10n.walletEarnedDetail(
                    ledger.earned,
                    controller.policy.earnedCap,
                  ),
                  () => context.push(Routes.streak),
                ),
                (
                  l10n.walletPurchased,
                  ledger.purchased,
                  l10n.walletPurchasedDetail,
                  null,
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sectionGap),
            // UI-003 (V8, mixed actions and information): the three balances are information
            // only; the ways to get more are actions, in their own card.
            ListGroup(
              key: const ValueKey('wallet-balances'),
              footnote: fx == 'A' ? null : l10n.walletOrder,
              children: [
                ListRow(
                  key: const ValueKey('wallet-weekly'),
                  leadingMobile: NumayaMobileIcons.hourglass,
                  label: l10n.walletWeekly,
                  value: fx == 'A' ? null : '${ledger.weekly}',
                  detail: weeklyDetail,
                ),
                ListRow(
                  key: const ValueKey('wallet-earned'),
                  leadingMobile: NumayaMobileIcons.gift,
                  label: l10n.walletEarned,
                  value: fx == 'A' ? null : '${ledger.earned}',
                  detail: l10n.walletEarnedDetail(
                    ledger.earned,
                    controller.policy.earnedCap,
                  ),
                ),
                ListRow(
                  key: const ValueKey('wallet-purchased'),
                  leadingMobile: NumayaMobileIcons.receipt,
                  label: l10n.walletPurchased,
                  value: fx == 'A' ? null : '${ledger.purchased}',
                  detail: l10n.walletPurchasedDetail,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            ListGroup(
              key: const ValueKey('wallet-actions'),
              children: [
                ListRow(
                  key: const ValueKey('wallet-earn-streak'),
                  leadingMobile: NumayaMobileIcons.flame,
                  label: l10n.walletEarnAction,
                  onTap: () => context.push(Routes.streak),
                ),
                if (toPremium != null)
                  ListRow(
                    key: const ValueKey('wallet-weekly-premium'),
                    leading: NumayaIcons.premium,
                    label: l10n.walletWeeklyAction,
                    onTap: toPremium,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.walletHistory,
            children: [
              if (history.isEmpty)
                ListRow(label: l10n.walletHistoryEmpty)
              else
                for (final e in history.take(20))
                  // UI-053/UI-070 (V8): each entry names its kind with a compact glyph.
                  ListRow(
                    leadingMobile: walletEntryIcon(e),
                    label: walletEntryLabel(l10n, e),
                    detail: shortDateTime(e.at),
                    value: e.amount > 0 ? '+${e.amount}' : '${e.amount}',
                  ),
            ],
          ),
          // UI-041/055: the wallet shows no prices, so no provisional-price footer here.
        ],
      ),
    );
  }
}

/// The glyph for a ledger entry: welcome and streak rewards, Premium weekly credits, purchases,
/// Compliments sent, expired credits and refunds each have their own.
NumayaMobileIcons walletEntryIcon(LedgerEntry e) {
  if (e.source == 'welcome') return NumayaMobileIcons.gift;
  if (e.source.startsWith('streak')) return NumayaMobileIcons.flame;
  if (e.source.startsWith('premium_week')) return NumayaMobileIcons.wallet;
  if (e.kind == LedgerKind.expiry) return NumayaMobileIcons.hourglass;
  if (e.source.startsWith('purchase')) return NumayaMobileIcons.receipt;
  if (e.source.startsWith('compliment')) return NumayaMobileIcons.compliment;
  if (e.kind == LedgerKind.reversal) return NumayaMobileIcons.trendingUp;
  return NumayaMobileIcons.wallet;
}

/// The member-facing name of a ledger entry (wallet history, wallet card variant D).
String walletEntryLabel(AppLocalizations l10n, LedgerEntry e) {
  if (e.source == 'welcome') return l10n.walletEntryWelcome;
  if (e.source.startsWith('streak')) return l10n.walletEntryStreak;
  if (e.source.startsWith('premium_week')) return l10n.walletEntryWeekly;
  if (e.kind == LedgerKind.expiry) return l10n.walletEntryWeeklyExpiry;
  if (e.source.startsWith('purchase')) return l10n.walletEntryPurchase;
  if (e.source.startsWith('compliment')) return l10n.walletEntryCompliment;
  if (e.kind == LedgerKind.reversal) return l10n.walletEntryRefund;
  return l10n.walletEntryOther;
}
