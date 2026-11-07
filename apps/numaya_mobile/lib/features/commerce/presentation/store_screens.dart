import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/time/ist.dart';
import '../../../l10n/l10n.dart';
import '../../premium/application/premium_controller.dart';
import '../application/economy_controller.dart';
import '../data/store_gateway.dart';
import '../domain/catalog.dart';

/// "5h 20m", "45m": a compact duration for reset and deadline lines.
String compactDuration(Duration d) {
  if (d.isNegative) return '0m';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h >= 24) return '${d.inDays}d ${h % 24}h';
  return h > 0 ? '${h}h ${m}m' : '${m.clamp(1, 59)}m';
}

/// "Mon 9 Nov, 23:59" in the phone's time zone (deadlines are stored in UTC).
String shortDateTime(DateTime at) =>
    DateFormat('EEE d MMM, HH:mm').format(at.toLocal());

/// "Mon 9 Nov".
String shortDate(DateTime at) => DateFormat('EEE d MMM').format(at.toLocal());

/// The IST calendar day as a readable date.
String istDayLabel(IstDay day) =>
    DateFormat('EEEE d MMM').format(istDayStart(day).add(kIstOffset).toUtc());

String productName(AppLocalizations l10n, Product p) => switch (p.kind) {
  ProductKind.premiumWeekly => l10n.premiumPlanName(l10n.planWeekly),
  ProductKind.premiumMonthly => l10n.premiumPlanName(l10n.planMonthly),
  ProductKind.premiumYearly => l10n.premiumPlanName(l10n.planYearly),
  ProductKind.complimentPack => l10n.packTitle,
  ProductKind.streakRecovery => l10n.recoveryTitle,
};

/// Runs a purchase: in the demo the tester picks what the store reports (the sheet says no money
/// moves); a build without a store goes straight to "not available". Then the outcome screen.
Future<void> startPurchase(
  BuildContext context,
  WidgetRef ref,
  ProductKind kind,
) async {
  final l10n = context.l10n;
  final product = ref.read(catalogProvider).product(kind);
  final gateway = ref.read(storeGatewayProvider);
  if (gateway is DemoStoreGateway) {
    final choice = await showNumayaSheet<StoreResult>(
      context: context,
      title: l10n.checkoutTitle,
      closeLabel: l10n.close,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.checkoutBody(
              productName(l10n, product),
              formatInr(product.pricePaise),
            ),
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            label: l10n.checkoutSuccess,
            onPressed: () => Navigator.of(sheet).pop(StoreResult.purchased),
          ),
          const SizedBox(height: AppSpacing.s3),
          for (final (label, result) in [
            (l10n.checkoutPending, StoreResult.pending),
            (l10n.checkoutCancelled, StoreResult.cancelled),
            (l10n.checkoutFailed, StoreResult.failed),
          ]) ...[
            NumayaButton(
              label: label,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => Navigator.of(sheet).pop(result),
            ),
            const SizedBox(height: AppSpacing.s2),
          ],
        ],
      ),
    );
    // Closing the sheet is backing out: nothing is bought or spent.
    if (choice == null) return;
    gateway.nextResult = choice;
  }
  final outcome = await ref.read(economyProvider.notifier).purchase(kind);
  if (!context.mounted) return;
  AppHaptics.fire(
    context,
    outcome == PurchaseOutcome.success
        ? HapticMoment.success
        : HapticMoment.selection,
  );
  await context.push(
    '${Routes.storeOutcome}?kind=${kind.name}&result=${outcome.name}',
  );
}

/// The provisional-price line shown under every price (PRD 06).
class ProvisionalPriceNote extends StatelessWidget {
  const ProvisionalPriceNote({super.key});

  @override
  Widget build(BuildContext context) =>
      Text(context.l10n.pricesProvisional, style: AppTypography.helper);
}

/// S35: the three-Compliment pack, its exact price and the current balance.
class ComplimentPackScreen extends ConsumerWidget {
  const ComplimentPackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final balance = ref.watch(economyProvider).ledger.total;
    final product = ref
        .watch(catalogProvider)
        .product(ProductKind.complimentPack);
    final price = formatInr(product.pricePaise);
    final busy = ref.watch(premiumProvider).purchasing;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.close,
        closeIcon: true,
      ),
      footer: NumayaButton(
        label: l10n.packBuy(price),
        loading: busy,
        onPressed: busy
            ? null
            : () => startPurchase(context, ref, ProductKind.complimentPack),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          const Center(
            child: MobileIcon(
              NumayaMobileIcons.compliment,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          ScreenHeader(title: l10n.packTitle, lede: l10n.packBody),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            children: [
              ListRow(
                leadingMobile: NumayaMobileIcons.receipt,
                label: l10n.packTitle,
                value: l10n.packPrice(price),
              ),
              ListRow(
                leadingMobile: NumayaMobileIcons.wallet,
                label: l10n.walletTitle,
                value: l10n.packBalance(balance),
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

/// S36: repairing one missed streak day. Shows the day, the deadline, the resulting streak and the
/// exact price before purchase; the controller rechecks eligibility before charging.
class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(economyProvider);
    final offer = ref.read(economyProvider.notifier).recoveryOffer();
    final product = ref
        .watch(catalogProvider)
        .product(ProductKind.streakRecovery);
    final price = formatInr(product.pricePaise);
    final busy = ref.watch(premiumProvider).purchasing;
    final top = NumayaTopBar(
      onBack: () => context.pop(),
      backLabel: l10n.close,
      closeIcon: true,
    );
    if (offer == null) {
      return NumayaScreen(
        top: top,
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s10),
          child: EmptyState(
            art: const MobileIcon(
              NumayaMobileIcons.flame,
              size: 36,
              color: AppColors.ink,
            ),
            title: l10n.recoveryNone,
            body: l10n.recoveryNoneBody,
          ),
        ),
      );
    }
    return NumayaScreen(
      top: top,
      footer: NumayaButton(
        label: l10n.recoveryBuy(price),
        loading: busy,
        onPressed: busy
            ? null
            : () => startPurchase(context, ref, ProductKind.streakRecovery),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ScreenHeader(title: l10n.recoveryTitle, lede: l10n.recoveryCheck),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            children: [
              ListRow(
                leadingMobile: NumayaMobileIcons.flame,
                label: l10n.recoveryMissed(istDayLabel(offer.missedDay)),
              ),
              ListRow(
                leadingMobile: NumayaMobileIcons.hourglass,
                label: l10n.recoveryDeadline(shortDateTime(offer.deadline)),
              ),
              ListRow(
                leadingMobile: NumayaMobileIcons.gift,
                label: l10n.recoveryResult(offer.resultingLength),
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

/// S37: what happened. Entitlement only ever follows a verified (here: demo-verified) purchase.
class PurchaseOutcomeScreen extends ConsumerWidget {
  const PurchaseOutcomeScreen({
    super.key,
    required this.kind,
    required this.outcome,
  });

  final ProductKind? kind;
  final PurchaseOutcome outcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final (title, body, illustration) = switch (outcome) {
      PurchaseOutcome.success => (
        l10n.outcomeSuccessTitle,
        l10n.outcomeSuccessBody,
        NumayaIllustration.hello,
      ),
      PurchaseOutcome.pending => (
        l10n.outcomePendingTitle,
        l10n.outcomePendingBody,
        null,
      ),
      PurchaseOutcome.cancelled => (
        l10n.outcomeCancelledTitle,
        l10n.outcomeCancelledBody,
        null,
      ),
      PurchaseOutcome.failed => (
        l10n.outcomeFailedTitle,
        l10n.outcomeFailedBody,
        null,
      ),
      PurchaseOutcome.unavailable => (
        l10n.outcomeUnavailableTitle,
        l10n.outcomeUnavailableBody,
        null,
      ),
      PurchaseOutcome.ineligible => (
        l10n.outcomeIneligibleTitle,
        l10n.outcomeIneligibleBody,
        null,
      ),
    };
    final k = kind;
    final retry =
        k != null &&
        (outcome == PurchaseOutcome.failed ||
            outcome == PurchaseOutcome.cancelled);
    void done() {
      // Back to where the purchase started: close the outcome and the store page under it.
      context.pop();
      if (outcome == PurchaseOutcome.success && context.canPop()) {
        context.pop();
      }
    }

    return NumayaScreen(
      top: NumayaTopBar(onBack: done, backLabel: l10n.close, closeIcon: true),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (retry) ...[
            NumayaButton(
              label: l10n.outcomeTryAgain,
              // Back to the store page, where the plan or pack is still chosen.
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          NumayaButton(
            label: l10n.done,
            variant: retry
                ? NumayaButtonVariant.secondary
                : NumayaButtonVariant.primary,
            onPressed: done,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResultPanel(title: title, body: body, illustration: illustration),
            const SizedBox(height: AppSpacing.s6),
            Center(
              child: Wrap(
                spacing: AppSpacing.s5,
                children: [
                  TextLink(
                    label: l10n.outcomeRestore,
                    onPressed: () =>
                        NumayaToast.show(context, l10n.paywallRestoreNone),
                  ),
                  TextLink(
                    label: l10n.outcomeHelp,
                    onPressed: () => context.push(Routes.helpContact),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reads the outcome screen's query parameters.
({ProductKind? kind, PurchaseOutcome outcome}) parseOutcome(
  Map<String, String> q,
) => (
  kind: ProductKind.values.where((k) => k.name == q['kind']).firstOrNull,
  outcome:
      PurchaseOutcome.values.where((o) => o.name == q['result']).firstOrNull ??
      PurchaseOutcome.failed,
);
