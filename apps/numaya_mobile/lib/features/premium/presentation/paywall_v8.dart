import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/domain/catalog.dart';

/// One duration on the V8 paywall (UI-076). Weekly, Monthly and Yearly are the catalog's
/// products; 3 months and 6 months are shown because the owner asked for five durations, but no
/// price or store product exists for them yet, so they carry [product] null and cannot be chosen.
/// Nothing here invents a price or a billing contract.
@immutable
class PaywallOption {
  const PaywallOption({
    required this.id,
    required this.title,
    required this.short,
    this.product,
    this.price,
    this.billing,
  });

  final String id;
  final String title;

  /// "1 wk", "3 mo": the segment label in the duration picker.
  final String short;
  final Product? product;
  final String? price;
  final String? billing;

  bool get available => product != null;
}

List<PaywallOption> paywallOptions(
  AppLocalizations l10n,
  List<Product> plans,
  String Function(Product) billing,
) {
  Product? of(ProductKind k) {
    for (final p in plans) {
      if (p.kind == k) return p;
    }
    return null;
  }

  PaywallOption live(String id, String title, String short, ProductKind k) {
    final p = of(k);
    return PaywallOption(
      id: id,
      title: title,
      short: short,
      product: p,
      price: p == null ? null : formatInr(p.pricePaise),
      billing: p == null ? null : billing(p),
    );
  }

  return [
    live(
      'weekly',
      l10n.planWeekly,
      l10n.v8PlanShortWeek,
      ProductKind.premiumWeekly,
    ),
    live(
      'monthly',
      l10n.planMonthly,
      l10n.v8PlanShortMonth,
      ProductKind.premiumMonthly,
    ),
    PaywallOption(
      id: 'quarter',
      title: l10n.v8Plan3Months,
      short: l10n.v8PlanShort3,
    ),
    PaywallOption(
      id: 'half',
      title: l10n.v8Plan6Months,
      short: l10n.v8PlanShort6,
    ),
    live(
      'yearly',
      l10n.planYearly,
      l10n.v8PlanShortYear,
      ProductKind.premiumYearly,
    ),
  ];
}

/// The V8 paywall body (UI-076), above the shared footer. [variant]: A benefits first with
/// stacked plans, B plans first as comparison cards, C a duration picker with the selected
/// plan's details. All three share the 16:9 hero slot above the title, one grouped benefits
/// card and the same five durations.
class PaywallV8Body extends StatelessWidget {
  const PaywallV8Body({
    super.key,
    required this.variant,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.benefits,
    required this.footnote,
  });

  final String variant;
  final String title;
  final List<PaywallOption> options;
  final String? selected;
  final ValueChanged<PaywallOption> onSelect;
  final List<(Widget, String)> benefits;

  /// "Chatting, archived chats, reporting and blocking are always free." and Restore.
  final Widget footnote;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hero = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s4),
      child: ArtworkSlot(slot: 'premium_hero', label: l10n.v8PremiumHeroSlot),
    );
    final heading = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s5),
      child: Semantics(
        header: true,
        child: Text(title, style: AppTypography.flowTitle),
      ),
    );
    final benefitCard = _Benefits(items: benefits);
    final Widget plans = switch (variant) {
      'B' => _PlanCards(
        options: options,
        selected: selected,
        onSelect: onSelect,
      ),
      'C' => _DurationPicker(
        options: options,
        selected: selected,
        onSelect: onSelect,
      ),
      _ => _StackedPlans(
        options: options,
        selected: selected,
        onSelect: onSelect,
      ),
    };
    final plansBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.paywallPlans, style: AppTypography.section),
        const SizedBox(height: AppSpacing.s3),
        plans,
      ],
    );
    final benefitsBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.v8PremiumIncluded, style: AppTypography.section),
        const SizedBox(height: AppSpacing.s3),
        benefitCard,
      ],
    );
    final plansFirst = variant == 'B' || variant == 'C';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hero,
        heading,
        const SizedBox(height: AppSpacing.s5),
        if (plansFirst) plansBlock else benefitsBlock,
        const SizedBox(height: AppSpacing.sectionGap),
        if (plansFirst) benefitsBlock else plansBlock,
        const SizedBox(height: AppSpacing.s4),
        footnote,
      ],
    );
  }
}

/// Every benefit in one white card, a glyph per row and the shared inset divider (UI-053).
class _Benefits extends StatelessWidget {
  const _Benefits({required this.items});

  final List<(Widget, String)> items;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const CardDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.cardPadding,
              vertical: AppSpacing.s3 + 2,
            ),
            child: Row(
              children: [
                items[i].$1,
                const SizedBox(width: AppSpacing.s3),
                Expanded(child: Text(items[i].$2, style: AppTypography.body)),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

/// A: five stacked rows in one card, price at the end; pending durations say so and are inert.
class _StackedPlans extends StatelessWidget {
  const _StackedPlans({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<PaywallOption> options;
  final String? selected;
  final ValueChanged<PaywallOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        for (final (i, o) in options.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s2),
          _Selectable(
            key: ValueKey('plan-${o.id}'),
            option: o,
            selected: selected == o.id,
            onTap: () => onSelect(o),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.title,
                        style:
                            AppTypography.weight(
                              AppTypography.row,
                              AppTypography.semibold,
                            ).copyWith(
                              color: o.available
                                  ? AppColors.ink
                                  : AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        o.billing ?? l10n.v8PlanPendingDetail,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Text(
                  o.price ?? l10n.v8PlanPricePending,
                  style: o.available
                      ? AppTypography.weight(
                          AppTypography.row,
                          AppTypography.semibold,
                        )
                      : AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// B: comparison cards, two to a row, the yearly plan across the full width.
class _PlanCards extends StatelessWidget {
  const _PlanCards({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<PaywallOption> options;
  final String? selected;
  final ValueChanged<PaywallOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget card(PaywallOption o) => _Selectable(
      key: ValueKey('plan-${o.id}'),
      option: o,
      selected: selected == o.id,
      onTap: () => onSelect(o),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(o.title, style: AppTypography.label),
          const SizedBox(height: AppSpacing.s1),
          Text(
            o.price ?? l10n.v8PlanPricePending,
            style: o.available
                ? AppTypography.card
                : AppTypography.weight(
                    AppTypography.body,
                    AppTypography.semibold,
                  ).copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            o.billing ?? l10n.v8PlanPendingDetail,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
    final last = options.last;
    final rest = options.sublist(0, options.length - 1);
    return LayoutBuilder(
      builder: (context, box) {
        const gap = AppSpacing.s2;
        final w = (box.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final o in rest) SizedBox(width: w, child: card(o)),
            SizedBox(width: box.maxWidth, child: card(last)),
          ],
        );
      },
    );
  }
}

/// C: a five-way duration picker and one card with the chosen plan's details.
class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<PaywallOption> options;
  final String? selected;
  final ValueChanged<PaywallOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = options.where((o) => o.id == selected).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: l10n.paywallPlans,
          child: Row(
            children: [
              for (final (i, o) in options.indexed) ...[
                if (i > 0) const SizedBox(width: AppSpacing.s1),
                Expanded(
                  child: _Selectable(
                    key: ValueKey('plan-${o.id}'),
                    option: o,
                    selected: selected == o.id,
                    compact: true,
                    onTap: () => onSelect(o),
                    child: Center(
                      child: Text(
                        o.short,
                        textAlign: TextAlign.center,
                        style:
                            AppTypography.weight(
                              AppTypography.label,
                              AppTypography.semibold,
                            ).copyWith(
                              color: o.available
                                  ? AppColors.ink
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        Container(
          key: const ValueKey('plan-detail'),
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: current == null
              ? Text(l10n.paywallChoose, style: AppTypography.helper)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(current.title, style: AppTypography.label),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      current.price ?? l10n.v8PlanPricePending,
                      style: AppTypography.headline,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      current.billing ?? l10n.v8PlanPendingDetail,
                      style: AppTypography.helper,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// A selectable plan surface: white, a 2pt brand edge when chosen; an unavailable duration is
/// inert and announced as not available yet.
class _Selectable extends StatelessWidget {
  const _Selectable({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    required this.child,
    this.compact = false,
  });

  final PaywallOption option;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = option.available
        ? '${option.title}, ${option.price}. ${option.billing}'
        : '${option.title}. ${l10n.v8PlanPendingDetail}';
    final surface = AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.state),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 48 : AppSizes.row),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.s1 : AppLayout.cardPadding,
        vertical: AppSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: option.available ? AppColors.surface : AppColors.calloutFill,
        borderRadius: AppRadii.all(compact ? AppRadii.control : AppRadii.card),
        border: Border.all(
          color: selected ? AppColors.accent : const Color(0x00FFFFFF),
          width: AppBorders.selected,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: child,
    );
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: option.available,
      child: Pressable(
        onTap: option.available ? onTap : null,
        semanticLabel: label,
        excludeChildSemantics: true,
        pressedScale: 0.99,
        borderRadius: AppRadii.all(compact ? AppRadii.control : AppRadii.card),
        child: surface,
      ),
    );
  }
}
