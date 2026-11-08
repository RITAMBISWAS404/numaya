import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../premium/application/premium_controller.dart';
import '../application/economy_controller.dart';
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
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.walletTitle,
      ),
      footer: NumayaButton(
        label: l10n.complimentGetMore,
        onPressed: () => context.push(Routes.storeCompliments),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          MetricTile(
            label: l10n.walletTitle,
            value: '${ledger.total}',
            unit: l10n.walletUnit(ledger.total),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            footnote: l10n.walletOrder,
            children: [
              ListRow(
                key: const ValueKey('wallet-weekly'),
                leadingMobile: NumayaMobileIcons.hourglass,
                label: l10n.walletWeekly,
                value: '${ledger.weekly}',
                detail: premium.active && nextWeekly != null
                    ? l10n.walletWeeklyDetail(shortDate(nextWeekly))
                    : l10n.walletWeeklyNone,
                onTap: premium.active
                    ? null
                    : () => context.push(
                        '${Routes.paywall}?feature=${PremiumFeature.compliments.name}',
                      ),
              ),
              ListRow(
                key: const ValueKey('wallet-earned'),
                leadingMobile: NumayaMobileIcons.gift,
                label: l10n.walletEarned,
                value: '${ledger.earned}',
                detail: l10n.walletEarnedDetail(
                  ledger.earned,
                  controller.policy.earnedCap,
                ),
                onTap: () => context.push(Routes.streak),
              ),
              ListRow(
                key: const ValueKey('wallet-purchased'),
                leadingMobile: NumayaMobileIcons.receipt,
                label: l10n.walletPurchased,
                value: '${ledger.purchased}',
                detail: l10n.walletPurchasedDetail,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.walletHistory,
            children: [
              if (history.isEmpty)
                ListRow(label: l10n.walletHistoryEmpty)
              else
                for (final e in history.take(20))
                  ListRow(
                    label: walletEntryLabel(l10n, e),
                    detail: shortDateTime(e.at),
                    value: e.amount > 0 ? '+${e.amount}' : '${e.amount}',
                  ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          const ProvisionalPriceNote(),
        ],
      ),
    );
  }
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
