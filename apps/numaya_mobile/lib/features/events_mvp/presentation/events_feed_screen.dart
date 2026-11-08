import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/large_title_page.dart';
import '../../lab/lab_banners.dart';
import '../../lab/lab_empty_state.dart';
import '../../lab/lab_registry.dart';
import '../application/events_mvp_controller.dart';
import '../domain/event_models.dart';
import '../domain/sample_events_mvp.dart';
import 'ev_parts.dart';

/// E01 — Events feed. Explicit city, date and category filters, cover-led cards, My events, and the
/// proposed member suggestion entry (O1 OPEN). Sample data stays labelled. Filters persist.
class EventsFeedScreen extends ConsumerWidget {
  const EventsFeedScreen({super.key});

  Future<void> _pickCity(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final current = ref.read(eventsMvpProvider).city;
    final picked = await showNumayaSheet<String>(
      context: context,
      title: l10n.evCityTitle,
      closeLabel: l10n.close,
      builder: (sheet) => ListGroup(
        children: [
          for (final c in kEvCities)
            ListRow(
              key: ValueKey('ev-city-$c'),
              label: c,
              selected: c == current,
              onTap: () => Navigator.of(sheet).pop(c),
            ),
        ],
      ),
    );
    if (picked != null) ref.read(eventsMvpProvider.notifier).setCity(picked);
  }

  Future<T?> _pick<T>(
    BuildContext context,
    String title,
    List<(T, String)> options,
    T current,
  ) {
    final l10n = context.l10n;
    return showNumayaSheet<T>(
      context: context,
      title: title,
      closeLabel: l10n.close,
      builder: (sheet) => ListGroup(
        children: [
          for (final (value, label) in options)
            ListRow(
              label: label,
              selected: value == current,
              onTap: () => Navigator.of(sheet).pop(value),
            ),
        ],
      ),
    );
  }

  /// Lab group `ea-event-filters`: O (approved), A (one row of disclosure chips), B (city chip
  /// leading the date pills). Same filters, same state and persistence in every variant.
  List<Widget> _filterHeader(
    BuildContext context,
    WidgetRef ref,
    EvState s,
    EventsMvpController c,
  ) {
    final l10n = context.l10n;
    final v = ref.watch(labVariantProvider('ea-event-filters'));
    final dateLabels = [l10n.evDateAny, l10n.evDateWeek, l10n.evDateWeekend];
    final cityChip = EvDisclosureChip(
      key: const ValueKey('ev-city'),
      icon: NumayaIcons.location,
      label: s.city,
      semanticLabel: l10n.evCityChange(s.city),
      onTap: () => _pickCity(context, ref),
    );
    final categoryTabs = ViewTabs(
      label: l10n.evCategoryAll,
      bleed: AppLayout.screenGutter,
      selected: s.category == null ? 0 : s.category!.index + 1,
      onSelect: (i) => c.setCategory(i == 0 ? null : EvCategory.values[i - 1]),
      options: [
        (label: l10n.evCategoryAll, count: null),
        for (final cat in EvCategory.values)
          (label: evCategoryLabel(l10n, cat), count: null),
      ],
    );
    final dateTabs = ViewTabs(
      label: l10n.evDateAny,
      bleed: AppLayout.screenGutter,
      selected: s.dateFilter.index,
      onSelect: (i) => c.setDateFilter(EvDateFilter.values[i]),
      options: [for (final d in dateLabels) (label: d, count: null)],
    );
    switch (v) {
      case 'A':
        return [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                cityChip,
                const SizedBox(width: AppSpacing.s2),
                EvDisclosureChip(
                  key: const ValueKey('ev-date-chip'),
                  icon: NumayaIcons.calendar,
                  label: dateLabels[s.dateFilter.index],
                  active: s.dateFilter != EvDateFilter.any,
                  onTap: () async {
                    final d = await _pick<EvDateFilter>(
                      context,
                      l10n.evDateAny,
                      [
                        for (final f in EvDateFilter.values)
                          (f, dateLabels[f.index]),
                      ],
                      s.dateFilter,
                    );
                    if (d != null) c.setDateFilter(d);
                  },
                ),
                const SizedBox(width: AppSpacing.s2),
                EvDisclosureChip(
                  key: const ValueKey('ev-category-chip'),
                  icon: NumayaIcons.sparkle,
                  label: s.category == null
                      ? l10n.evCategoryAll
                      : evCategoryLabel(l10n, s.category!),
                  active: s.category != null,
                  onTap: () async {
                    final picked = await _pick<int>(
                      context,
                      l10n.evCategoryAll,
                      [
                        (-1, l10n.evCategoryAll),
                        for (final cat in EvCategory.values)
                          (cat.index, evCategoryLabel(l10n, cat)),
                      ],
                      s.category?.index ?? -1,
                    );
                    if (picked != null) {
                      c.setCategory(
                        picked < 0 ? null : EvCategory.values[picked],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ];
      case 'B':
        return [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                cityChip,
                const SizedBox(width: AppSpacing.s2),
                for (final f in EvDateFilter.values) ...[
                  NumayaChip(
                    label: dateLabels[f.index],
                    selected: s.dateFilter == f,
                    onTap: () => c.setDateFilter(f),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          categoryTabs,
        ];
      default:
        return [
          // City first and explicit (Eventbrite's "in <city>" pill).
          Pressable(
            key: const ValueKey('ev-city'),
            onTap: () => _pickCity(context, ref),
            semanticLabel: l10n.evCityChange(s.city),
            excludeChildSemantics: true,
            pressedScale: 1,
            borderRadius: AppRadii.all(AppRadii.pill),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s3,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.all(AppRadii.pill),
              ),
              child: Row(
                children: [
                  const NumayaIcon(
                    NumayaIcons.location,
                    size: AppSizes.iconMd,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Expanded(
                    child: Text(
                      s.city,
                      style: AppTypography.weight(
                        AppTypography.body,
                        AppTypography.semibold,
                      ),
                    ),
                  ),
                  const NumayaIcon(
                    NumayaIcons.chevronDown,
                    size: 18,
                    color: AppColors.iconSupporting,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          dateTabs,
          const SizedBox(height: AppSpacing.s2),
          categoryTabs,
        ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final events = c.feed();
    final now = ref.read(clockProvider)();
    final mine = c.myEvents();
    final upcoming = mine
        .where((m) => m.$2.active && m.$1.phaseAt(now) != EvPhase.completed)
        .length;
    final needsAnswer = mine
        .where((m) => m.$2.status == ResStatus.reconfirmRequired)
        .length;

    String status(NumayaEvent e) {
      final r = s.reservations[e.id];
      if (r?.status == ResStatus.reconfirmRequired) {
        return l10n.evReconfirmNeeded;
      }
      if (r?.active ?? false) return l10n.evReservedByYou;
      if (c.isFull(e.id)) return l10n.evFull;
      return l10n.evPlacesLeft(c.placesLeft(e.id));
    }

    final filtered = s.category != null || s.dateFilter != EvDateFilter.any;

    return LargeTitlePage(
      title: l10n.evTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._filterHeader(context, ref, s, c),
          const SizedBox(height: AppSpacing.s4),
          LabStatusBanner(
            key: const ValueKey('ev-sample-banner'),
            tone: BannerTone.info,
            title: l10n.evSampleBanner,
            body: l10n.evSampleBannerBody,
          ),
          const SizedBox(height: AppSpacing.s3),
          ListGroup(
            children: [
              ListRow(
                key: const ValueKey('ev-my-events'),
                leading: NumayaIcons.calendar,
                label: l10n.evMyEvents,
                detail: needsAnswer > 0
                    ? l10n.evNoticesWaiting(needsAnswer)
                    : l10n.evMyEventsDetail(upcoming),
                onTap: () => context.push(Routes.evMine),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (events.isEmpty)
            LabEmptyState(
              key: const ValueKey('ev-empty'),
              slot: 'events_empty',
              slotLabel: 'purple cat looking at a map',
              icon: NumayaMobileIcons.chart,
              title: filtered
                  ? l10n.evEmptyFilterTitle
                  : l10n.evEmptyTitle(s.city),
              body: l10n.evEmptyBody,
              actionLabel: filtered ? l10n.evClearFilters : null,
              onAction: filtered
                  ? () {
                      c.setCategory(null);
                      c.setDateFilter(EvDateFilter.any);
                    }
                  : null,
            )
          else
            for (final e in events) ...[
              EvCard(
                key: ValueKey('ev-card-${e.id}'),
                event: e,
                status: status(e),
                statusBrand: s.reservations[e.id]?.active ?? false,
                onTap: () => context.push('${Routes.evEvent}/${e.id}'),
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            footnote: l10n.evProposeRowDetail,
            children: [
              ListRow(
                key: const ValueKey('ev-propose'),
                leading: NumayaIcons.plus,
                label: l10n.evProposeRow,
                onTap: () => context.push(Routes.evProposals),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
