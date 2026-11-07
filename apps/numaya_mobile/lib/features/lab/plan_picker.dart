import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'lab_registry.dart';

/// One plan as shown to the member: the full billed amount and its term, always together.
typedef PlanOption = ({Key key, String title, String price, String billing});

/// Card family `plan-card` (Visual Lab V2): the full price and renewal clear for each plan, no
/// pressure (no savings badges, countdowns or pre-ticked upsells). O plan cards; A segmented term
/// with one price panel; B radio rows; C free vs Premium comparison above the plans; D the first
/// plan large, the others as small rows.
class PlanPicker extends ConsumerWidget {
  const PlanPicker({
    super.key,
    required this.plans,
    required this.selected,
    required this.onSelect,
    this.comparison = const [],
    this.variant,
  });

  final List<PlanOption> plans;
  final int selected;
  final ValueChanged<int> onSelect;

  /// (feature, free, premium) rows for variant C.
  final List<(String, String, String)> comparison;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('plan-card'));
    Widget card(int i) => PlanCard(
      key: plans[i].key,
      title: plans[i].title,
      price: plans[i].price,
      perWeek: plans[i].billing,
      selected: i == selected,
      onTap: () => onSelect(i),
    );
    Widget radioRow(int i, {bool last = false}) {
      final p = plans[i];
      final on = i == selected;
      return Pressable(
        key: p.key,
        onTap: () => onSelect(i),
        selected: on,
        semanticLabel: '${p.title}, ${p.price}, ${p.billing}',
        excludeChildSemantics: true,
        pressedScale: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.cardPadding,
            vertical: AppSpacing.s3,
          ),
          decoration: BoxDecoration(
            border: last
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: AppColors.divider,
                      width: AppBorders.hairline,
                    ),
                  ),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: on ? AppColors.accent : AppColors.borderStrong,
                      width: on ? 7 : 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: AppTypography.weight(
                        AppTypography.body,
                        AppTypography.semibold,
                      ),
                    ),
                    Text(p.billing, style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(
                p.price,
                style: AppTypography.weight(
                  AppTypography.body,
                  AppTypography.semibold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    BoxDecoration surface() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    );

    switch (v) {
      case 'A':
        // Nothing is preselected (no pressure): until a term is chosen the panel says so.
        final p = selected < 0 ? null : plans[selected];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumayaSegmented(
              selected: selected,
              onSelect: onSelect,
              options: [
                for (final o in plans)
                  (label: o.title, count: null, key: o.key),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            Container(
              padding: const EdgeInsets.all(AppLayout.cardPadding),
              decoration: surface(),
              child: Semantics(
                liveRegion: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: p == null
                      ? [
                          Text(
                            context.l10n.planChooseTerm,
                            style: AppTypography.bodySm,
                          ),
                        ]
                      : [
                          Text(p.price, style: AppTypography.pageTitle),
                          Text(p.billing, style: AppTypography.bodySm),
                        ],
                ),
              ),
            ),
          ],
        );
      case 'B':
        return Container(
          decoration: surface(),
          child: Column(
            children: [
              for (var i = 0; i < plans.length; i++)
                radioRow(i, last: i == plans.length - 1),
            ],
          ),
        );
      case 'C':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (comparison.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppLayout.cardPadding),
                decoration: surface(),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    for (final (f, free, prem) in [
                      ('', context.l10n.premiumFree, context.l10n.premiumName),
                      ...comparison,
                    ])
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s1,
                            ),
                            child: Text(f, style: AppTypography.bodySm),
                          ),
                          Text(free, style: AppTypography.bodySm),
                          Text(
                            prem,
                            style: AppTypography.weight(
                              AppTypography.bodySm,
                              AppTypography.semibold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.s3),
            for (var i = 0; i < plans.length; i++) ...[
              card(i),
              const SizedBox(height: AppSpacing.s2),
            ],
          ],
        );
      case 'D':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            card(0),
            const SizedBox(height: AppSpacing.s3),
            if (plans.length > 1)
              Container(
                decoration: surface(),
                child: Column(
                  children: [
                    for (var i = 1; i < plans.length; i++)
                      radioRow(i, last: i == plans.length - 1),
                  ],
                ),
              ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < plans.length; i++) ...[
              card(i),
              const SizedBox(height: AppSpacing.s2),
            ],
          ],
        );
    }
  }
}
