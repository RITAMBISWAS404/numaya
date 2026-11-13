import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/domain/catalog.dart';
import '../../commerce/presentation/store_screens.dart';
import '../../help/domain/help_articles.dart';
import '../../lab/lab_registry.dart';
import '../../lab/plan_picker.dart';
import '../application/premium_controller.dart';
import 'paywall_v8.dart';

/// What Premium adds (PRD 06): allowances and information, never ranking.
List<(NumayaIcons?, NumayaMobileIcons?, String)> premiumBenefits(
  AppLocalizations l10n,
) => [
  (NumayaIcons.heart, null, l10n.premiumBenefitLikes),
  (null, NumayaMobileIcons.compliment, l10n.premiumBenefitCompliments),
  (NumayaIcons.groups, null, l10n.premiumBenefitSeeLikes),
  (NumayaIcons.filter, null, l10n.premiumBenefitFilters),
  (null, NumayaMobileIcons.extend, l10n.premiumBenefitExtend),
];

String planLabel(AppLocalizations l10n, Product p) => switch (p.kind) {
  ProductKind.premiumWeekly => l10n.planWeekly,
  ProductKind.premiumMonthly => l10n.planMonthly,
  _ => l10n.planYearly,
};

String planBilling(AppLocalizations l10n, Product p) {
  final price = formatInr(p.pricePaise);
  return switch (p.kind) {
    ProductKind.premiumWeekly => l10n.planBilledWeekly(price),
    ProductKind.premiumMonthly => l10n.planBilledMonthly(price),
    _ => l10n.planBilledYearly(price),
  };
}

class _BenefitList extends StatelessWidget {
  const _BenefitList();

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        children: [
          for (final (icon, mobile, label) in premiumBenefits(context.l10n))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  if (icon != null)
                    NumayaIcon(icon, size: 20, color: AppColors.accent)
                  else
                    MobileIcon(mobile!, size: 20, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(child: Text(label, style: AppTypography.bodySm)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// S34 overview: the member's plan state (renewal date, cancel renewal) and what Premium adds.
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final premium = ref.watch(premiumProvider);
    final plan = premium.plan;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.premiumName,
      ),
      footer: plan == null
          ? NumayaButton(
              label: l10n.premiumSeePlans,
              onPressed: () => context.push(Routes.paywall),
            )
          : premium.autoRenew
          ? NumayaButton(
              label: l10n.premiumCancelRenewal,
              variant: NumayaButtonVariant.secondary,
              onPressed: () {
                ref.read(premiumProvider.notifier).cancel();
                NumayaToast.show(
                  context,
                  l10n.premiumCancelledUntil(shortDate(premium.paidThrough!)),
                );
              },
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          StatusBanner(
            tone: plan != null ? BannerTone.success : BannerTone.info,
            title: plan != null
                ? l10n.premiumPlanName(planLabel(l10n, plan))
                : l10n.premiumHeroTitle,
            body: plan == null
                ? l10n.premiumHeroBody
                : premium.autoRenew
                ? '${l10n.premiumRenews(shortDate(premium.paidThrough!))} · ${planBilling(l10n, plan)}'
                : l10n.premiumEnds(shortDate(premium.paidThrough!)),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Semantics(
            header: true,
            child: Text(l10n.premiumCompare, style: AppTypography.section),
          ),
          const SizedBox(height: AppSpacing.s3),
          const _BenefitList(),
          const SizedBox(height: AppSpacing.s3),
          Text(l10n.premiumFreeStays, style: AppTypography.helper),
          const SizedBox(height: AppSpacing.s2),
          const ProvisionalPriceNote(),
          const SizedBox(height: AppSpacing.s2),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLink(
              label: l10n.premiumHelp,
              onPressed: () =>
                  context.push('${Routes.help}/${HelpArticleId.premium.name}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// S34 paywall: names what opened it, lists the benefits, offers weekly / monthly / yearly with the
/// full billed amount and term (no invented savings or countdowns), and repeats the renewal terms
/// beside the button. Checkout goes through [startPurchase]; restore is always available.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.feature});

  final PremiumFeature? feature;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Product? _plan;

  /// UI-076: the chosen duration in the V8 directions (A, B, C).
  String? _option;

  void _choose(String id) => setState(() => _option = id);

  String _title(AppLocalizations l10n) => switch (widget.feature) {
    PremiumFeature.likes => l10n.premiumForLikes,
    PremiumFeature.seeLikes => l10n.premiumForSeeLikes,
    PremiumFeature.advancedFilters => l10n.paywallForFilters,
    PremiumFeature.extension ||
    PremiumFeature.extendUnlimited => l10n.premiumForExtension,
    PremiumFeature.insights => l10n.premiumForInsights,
    PremiumFeature.compliments => l10n.premiumForCompliments,
    // Retired entry points get the general paywall.
    PremiumFeature.rematch ||
    PremiumFeature.incognito ||
    PremiumFeature.travel ||
    PremiumFeature.superSwipes ||
    PremiumFeature.general ||
    null => l10n.paywallTitle,
  };

  @override
  Widget build(BuildContext context) {
    final plansFirst = ref.watch(labVariantProvider('v7-paywall')) == 'A';
    final l10n = context.l10n;
    final premium = ref.watch(premiumProvider);
    final plans = ref.watch(catalogProvider).plans;

    if (premium.active) {
      return NumayaScreen(
        top: NumayaTopBar(
          onBack: () => context.pop(),
          backLabel: l10n.close,
          closeIcon: true,
        ),
        footer: NumayaButton(label: l10n.done, onPressed: () => context.pop()),
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s10),
          child: ResultPanel(
            illustration: NumayaIllustration.hello,
            title: l10n.paywallAlreadyTitle,
            body: premium.autoRenew
                ? l10n.premiumRenews(shortDate(premium.paidThrough!))
                : l10n.premiumEnds(shortDate(premium.paidThrough!)),
          ),
        ),
      );
    }

    final v8 = ref.watch(labVariantProvider('v8-paywall'));
    if (v8 != 'O') return _v8(context, v8, plans, premium);
    final plan = _plan;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.close,
        closeIcon: true,
        title: l10n.premiumName,
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            label: plan == null
                ? l10n.paywallChoose
                : l10n.paywallContinuePlan(planLabel(l10n, plan)),
            loading: premium.purchasing,
            onPressed: plan == null || premium.purchasing
                ? null
                : () => startPurchase(context, ref, plan.kind),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            plan == null
                ? l10n.pricesProvisional
                : '${l10n.planRenewal(formatInr(plan.pricePaise))} ${l10n.pricesProvisional}',
            textAlign: TextAlign.center,
            style: AppTypography.micro,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ScreenHeader(title: _title(l10n), lede: l10n.paywallLede),
          const SizedBox(height: AppSpacing.s4),
          if (!plansFirst) ...[
            const _BenefitList(),
            const SizedBox(height: AppSpacing.s5),
          ],
          OptionGroupLabel(text: l10n.paywallPlans),
          const SizedBox(height: AppSpacing.s2),
          // Card family `plan-card` (Visual Lab V2): full billed amount and term together.
          PlanPicker(
            plans: [
              for (final p in plans)
                (
                  key: ValueKey('plan-${p.kind.name}'),
                  title: planLabel(l10n, p),
                  price: formatInr(p.pricePaise),
                  billing: planBilling(l10n, p),
                ),
            ],
            selected: _plan == null ? -1 : plans.indexOf(_plan!),
            onSelect: (i) => setState(() => _plan = plans[i]),
            comparison: [
              (l10n.planCompareLikes, '5', '15'),
              (l10n.planCompareCompliments, '0', '3'),
              (l10n.planCompareSeeLikes, '—', '✓'),
            ],
          ),
          if (plansFirst) ...[
            const SizedBox(height: AppSpacing.s5),
            const _BenefitList(),
          ],
          const SizedBox(height: AppSpacing.s2),
          const SizedBox(height: AppSpacing.s2),
          Text(l10n.premiumFreeStays, style: AppTypography.helper),
          const SizedBox(height: AppSpacing.s2),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLink(
              label: l10n.paywallRestore,
              onPressed: () =>
                  NumayaToast.show(context, l10n.paywallRestoreNone),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _PaywallScreenState {
  /// UI-076 (V8): the reworked paywall in direction [v] (A, B or C).
  Widget _v8(
    BuildContext context,
    String v,
    List<Product> plans,
    PremiumState premium,
  ) {
    final l10n = context.l10n;
    final options = paywallOptions(l10n, plans, (p) => planBilling(l10n, p));
    final chosen = options.where((o) => o.id == _option).firstOrNull;
    final plan = chosen?.product;
    Widget glyph(NumayaIcons? icon, NumayaMobileIcons? mobile) => icon != null
        ? NumayaIcon(icon, size: 20, filled: true, color: AppColors.accent)
        : MobileIcon(mobile!, size: 20, filled: true, color: AppColors.accent);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.close,
        closeIcon: true,
        title: l10n.premiumName,
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            key: const ValueKey('paywall-continue'),
            label: plan == null
                ? l10n.paywallChoose
                : l10n.paywallContinuePlan(chosen!.title),
            loading: premium.purchasing,
            onPressed: plan == null || premium.purchasing
                ? null
                : () => startPurchase(context, ref, plan.kind),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            plan == null
                ? l10n.pricesProvisional
                : '${l10n.planRenewal(formatInr(plan.pricePaise))} ${l10n.pricesProvisional}',
            textAlign: TextAlign.center,
            style: AppTypography.micro,
          ),
        ],
      ),
      body: PaywallV8Body(
        variant: v,
        title: _title(l10n),
        options: options,
        selected: _option,
        onSelect: (o) => _choose(o.id),
        benefits: [
          for (final (icon, mobile, label) in premiumBenefits(l10n))
            (glyph(icon, mobile), label),
        ],
        footnote: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.premiumFreeStays, style: AppTypography.helper),
            const SizedBox(height: AppSpacing.s2),
            TextLink(
              label: l10n.paywallRestore,
              onPressed: () =>
                  NumayaToast.show(context, l10n.paywallRestoreNone),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small capital label above a list (V16 legend style).
class OptionGroupLabel extends StatelessWidget {
  const OptionGroupLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: AppTypography.labelCaps),
  );
}
