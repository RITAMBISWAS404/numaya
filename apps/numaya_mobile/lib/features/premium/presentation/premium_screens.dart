import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';
import '../../help/domain/help_articles.dart';
import '../application/premium_controller.dart';

/// Premium overview (B-60 pay plan, B-63 active state, B-64 comparison): what Premium adds, the
/// SuperSwipes left, and the plan state. Simulated: no store is connected.
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final premium = ref.watch(premiumProvider);
    ref.watch(datingProvider);
    final superSwipes = ref.read(datingProvider.notifier).superSwipesLeft;
    final rows = [
      (l10n.featureLikes, true, true),
      (l10n.featureSeeLikes, true, true),
      (l10n.featureExtend, false, true),
      (l10n.featureRematch, false, true),
      (l10n.featureAdvancedFilters, false, true),
      (l10n.featureIncognito, false, true),
      (l10n.featureTravel, false, true),
      (l10n.featureSuperSwipes, false, true),
    ];
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.premiumName,
      ),
      footer: premium.active
          ? NumayaButton(
              label: l10n.premiumCancelDemo,
              variant: NumayaButtonVariant.secondary,
              onPressed: () {
                ref.read(premiumProvider.notifier).cancel();
                NumayaToast.show(context, l10n.premiumCancelled);
              },
            )
          : NumayaButton(
              label: l10n.premiumSeePlans,
              onPressed: () => context.push(Routes.paywall),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          StatusBanner(
            tone: premium.active ? BannerTone.success : BannerTone.info,
            title: premium.active
                ? l10n.premiumActiveUntil(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(premium.activeUntil!),
                  )
                : l10n.premiumHeroTitle,
            body: premium.active
                ? l10n.premiumActivePlan(premium.activePlan!.label)
                : l10n.premiumHeroBody,
          ),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            title: l10n.premiumYourExtras,
            children: [
              ListRow(
                leading: NumayaIcons.star,
                label: l10n.premiumSuperSwipesLeft,
                value: '$superSwipes',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Semantics(
            header: true,
            child: Text(l10n.premiumCompare, style: AppTypography.section),
          ),
          const SizedBox(height: AppSpacing.s3),
          WhiteCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      width: 72,
                      child: Text(
                        l10n.premiumFree,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelCaps,
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        l10n.premiumShort,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelCaps,
                      ),
                    ),
                  ],
                ),
                for (final (label, free, plus) in rows)
                  ComparisonRow(
                    label: label,
                    free: free,
                    premium: plus,
                    yesLabel: l10n.yes,
                    noLabel: l10n.no,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(l10n.premiumDemoNote, style: AppTypography.caption),
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

/// Paywall (B-61, D-14): names the feature that opened it, lists what Premium adds, shows plans as
/// selectable cards with none pre-selected, keeps the terms visible and repeats the chosen plan on
/// the button. "Buying" opens a confirmation that says no payment is taken; the demo can also show
/// a failed payment (states-and-recovery: return with the plan still selected).
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.feature});

  final PremiumFeature? feature;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  PremiumPlan? _plan;
  bool _failed = false;
  bool _done = false;

  Future<void> _buy() async {
    final l10n = context.l10n;
    final plan = _plan;
    if (plan == null) return;
    final outcome = await showNumayaSheet<PurchaseOutcome>(
      context: context,
      title: l10n.paywallConfirmTitle,
      closeLabel: l10n.close,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.paywallConfirmBody(plan.label, plan.price),
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            label: l10n.paywallConfirmBuy,
            onPressed: () => Navigator.of(context).pop(PurchaseOutcome.success),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.paywallConfirmFail,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(PurchaseOutcome.failed),
          ),
        ],
      ),
    );
    if (outcome == null || !mounted) return;
    final result = await ref
        .read(premiumProvider.notifier)
        .purchase(plan, simulate: outcome);
    if (!mounted) return;
    setState(() {
      _failed = result == PurchaseOutcome.failed;
      _done = result == PurchaseOutcome.success;
    });
  }

  String _title(AppLocalizations l10n) => switch (widget.feature) {
    PremiumFeature.advancedFilters => l10n.paywallForFilters,
    PremiumFeature.rematch => l10n.paywallForRematch,
    PremiumFeature.extendUnlimited => l10n.paywallForExtend,
    PremiumFeature.incognito => l10n.paywallForIncognito,
    PremiumFeature.travel => l10n.paywallForTravel,
    PremiumFeature.superSwipes => l10n.paywallForSuperSwipes,
    PremiumFeature.general || null => l10n.paywallTitle,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final premium = ref.watch(premiumProvider);

    if (_done || premium.active) {
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
            title: _done ? l10n.paywallSuccessTitle : l10n.paywallAlreadyTitle,
            body: l10n.paywallSuccessBody(
              MaterialLocalizations.of(context)
                  .formatMediumDate(premium.activeUntil!),
            ),
          ),
        ),
      );
    }

    final benefits = [
      (NumayaIcons.filter, l10n.featureAdvancedFilters),
      (NumayaIcons.refresh, l10n.featureRematch),
      (NumayaIcons.clock, l10n.featureExtend),
      (NumayaIcons.eyeOff, l10n.featureIncognito),
      (NumayaIcons.location, l10n.featureTravel),
      (NumayaIcons.star, l10n.featureSuperSwipes),
    ];

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
            label: _plan == null
                ? l10n.paywallChoose
                : l10n.paywallContinue(_plan!.label, _plan!.price),
            loading: premium.purchasing,
            onPressed: _plan == null || premium.purchasing ? null : _buy,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            l10n.paywallLegal,
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
          WhiteCard(
            child: Column(
              children: [
                for (final (icon, label) in benefits)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        NumayaIcon(icon, size: 20, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: Text(label, style: AppTypography.bodySm),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          if (_failed) ...[
            StatusBanner(
              tone: BannerTone.error,
              title: l10n.paywallFailedTitle,
              body: l10n.paywallFailedBody,
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          OptionGroupLabel(text: l10n.paywallPlans),
          const SizedBox(height: AppSpacing.s2),
          for (final p in kPremiumPlans) ...[
            PlanCard(
              title: p.label,
              price: p.price,
              perWeek: p.perWeek,
              tag: p.saving,
              selected: _plan == p,
              onTap: () => setState(() => _plan = p),
            ),
            const SizedBox(height: AppSpacing.s2),
          ],
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

/// A small capital label above a list (V16 legend style).
class OptionGroupLabel extends StatelessWidget {
  const OptionGroupLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text.toUpperCase(), style: AppTypography.labelCaps),
  );
}
