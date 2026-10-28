import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';
import '../../home/presentation/home_shell.dart';
import '../../home/presentation/tab_screens.dart';
import '../../onboarding/presentation/permission_prompt.dart';
import '../../profile/application/profile_details_controller.dart';
import '../application/events_controller.dart';
import '../domain/event.dart';
import 'event_parts.dart';

/// The Events tab (EVENTS_SCREEN_INVENTORY EV-01, EV-02): Explore (search, date chips, filters,
/// picks for your interests, the list) and My events (Going · Waitlist · Saved · Hosting · Past).
/// `?view=mine` opens My events.
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key, this.mine = false});

  final bool mine;

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

enum _MineList { going, waitlist, saved, hosting, past }

class _EventsScreenState extends ConsumerState<EventsScreen> {
  late int _view = widget.mine ? 1 : 0;
  _MineList _mine = _MineList.going;
  bool _retrying = false;
  int _failedRetries = 0;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: ref.read(eventsProvider).query);
  }

  @override
  void didUpdateWidget(EventsScreen old) {
    super.didUpdateWidget(old);
    if (old.mine != widget.mine) _view = widget.mine ? 1 : 0;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _retrying = false;
      if (ref.read(datingProvider).simulateErrors) _failedRetries++;
    });
  }

  void _open(DemoEvent e) => unawaited(context.push('${Routes.event}/${e.id}'));

  void _toggleSave(DemoEvent e) {
    final l10n = context.l10n;
    final events = ref.read(eventsProvider.notifier);
    final wasSaved = ref.read(eventsProvider).saved.contains(e.id);
    events.toggleSave(e.id);
    AppHaptics.fire(context, HapticMoment.selection);
    NumayaToast.show(context, wasSaved ? l10n.eventUnsaved : l10n.eventSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(eventsProvider);
    ref.watch(datingProvider);
    ref.watch(profileDetailsProvider);
    final failing = ref.read(datingProvider).simulateErrors && !_retrying;
    if (!ref.read(datingProvider).simulateErrors) _failedRetries = 0;
    final filterCount = state.filters.activeCount;

    final header = TabHeader(
      title: l10n.tabEvents,
      actions: [
        if (_view == 0)
          _CountedButton(
            count: filterCount,
            child: NavIconButton(
              icon: NumayaIcons.filter,
              label: filterCount == 0
                  ? l10n.eventFilters
                  : l10n.eventFiltersCount(filterCount),
              onPressed: () => showEventFiltersSheet(context, ref),
            ),
          ),
        NavIconButton(
          icon: NumayaIcons.plus,
          label: l10n.eventCreate,
          onPressed: () => context.push(Routes.eventNew),
        ),
      ],
    );

    final tabs = ViewTabs(
      label: l10n.tabEvents,
      selected: _view,
      onSelect: (i) => setState(() => _view = i),
      options: [
        (label: l10n.eventsExplore, count: null),
        (label: l10n.eventsMine, count: null),
      ],
    );

    final Widget body;
    if (_view == 1) {
      body = _myEvents(l10n);
    } else if (_retrying) {
      body = const _ListSkeleton();
    } else if (failing) {
      body = Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s6),
        child: EmptyState(
          art: const NumayaIcon(
            NumayaIcons.wifiOff,
            size: 36,
            color: AppColors.ink,
          ),
          title: _failedRetries > 0
              ? l10n.eventsErrorStillTitle
              : l10n.eventsErrorTitle,
          body: l10n.eventsErrorBody,
          action: NumayaButton(
            label: l10n.discoverRetry,
            small: true,
            onPressed: _retry,
          ),
        ),
      );
    } else {
      body = _explore(l10n, state);
    }

    return TabPage(
      header: header,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tabs,
          const SizedBox(height: AppSpacing.s4),
          body,
        ],
      ),
    );
  }

  Widget _explore(AppLocalizations l10n, EventsState state) {
    final events = ref.read(eventsProvider.notifier);
    final now = events.now;
    final area = events.area;
    final list = events.explore();
    final browsing =
        state.query.trim().isEmpty && state.filters.activeCount == 0;
    final picks = browsing ? events.picks() : const <DemoEvent>[];
    final dates = [
      (EventDateFilter.any, l10n.eventDateAny),
      (EventDateFilter.today, l10n.eventDateToday),
      (EventDateFilter.weekend, l10n.eventDateWeekend),
      (EventDateFilter.week, l10n.eventDateWeek),
    ];

    Widget card(DemoEvent e, {String? reason}) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: EventCard(
        event: e,
        now: now,
        area: area,
        saved: state.saved.contains(e.id),
        reason: reason,
        onOpen: () => _open(e),
        onToggleSave: () => _toggleSave(e),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NumayaSearchField(
          controller: _search,
          placeholder: l10n.eventsSearch,
          clearLabel: l10n.interestsClearSearch,
          onChanged: events.setQuery,
        ),
        const SizedBox(height: AppSpacing.s3),
        ViewTabs(
          label: l10n.eventFilterWhen,
          selected: dates.indexWhere((d) => d.$1 == state.filters.date),
          onSelect: (i) =>
              events.setFilters(state.filters.copyWith(date: dates[i].$1)),
          options: [for (final d in dates) (label: d.$2, count: null)],
        ),
        const SizedBox(height: AppSpacing.s4),
        if (picks.isNotEmpty) ...[
          Semantics(
            header: true,
            child: Text(l10n.eventsPicked, style: AppTypography.section),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(l10n.eventsPickedNote, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.s3),
          for (final e in picks) card(e, reason: events.pickedBecause(e)),
          const SizedBox(height: AppSpacing.s3),
          Semantics(
            header: true,
            child: Text(l10n.eventsAll, style: AppTypography.section),
          ),
          const SizedBox(height: AppSpacing.s3),
        ],
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: EmptyState(
              art: const NumayaIcon(
                NumayaIcons.search,
                size: 36,
                color: AppColors.ink,
              ),
              title: l10n.eventsNoResultsTitle,
              body: state.filters.maxKm != null && area == null
                  ? l10n.eventsNoAreaBody
                  : l10n.eventsNoResultsBody,
              action: NumayaButton(
                label: l10n.eventsClear,
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () {
                  _search.clear();
                  events.clearFilters();
                },
              ),
            ),
          )
        else
          for (final e in list) card(e),
        const SizedBox(height: AppSpacing.s3),
        Text(
          l10n.eventsSampleNote,
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _myEvents(AppLocalizations l10n) {
    final events = ref.read(eventsProvider.notifier);
    final state = ref.read(eventsProvider);
    final lists = {
      _MineList.going: events.going(),
      _MineList.waitlist: events.waitlisted(),
      _MineList.saved: events.savedEvents(),
      _MineList.hosting: events.hosting(),
      _MineList.past: events.past(),
    };
    final labels = {
      _MineList.going: l10n.eventsGoing,
      _MineList.waitlist: l10n.eventsWaitlist,
      _MineList.saved: l10n.eventsSaved,
      _MineList.hosting: l10n.eventsHosting,
      _MineList.past: l10n.eventsPast,
    };
    final list = lists[_mine]!;
    void explore() => setState(() => _view = 0);
    final empty = switch (_mine) {
      _MineList.going => (
        l10n.eventsGoingEmptyTitle,
        l10n.eventsGoingEmptyBody,
        l10n.eventsFind,
        explore,
      ),
      _MineList.waitlist => (
        l10n.eventsWaitlistEmptyTitle,
        l10n.eventsWaitlistEmptyBody,
        l10n.eventsFind,
        explore,
      ),
      _MineList.saved => (
        l10n.eventsSavedEmptyTitle,
        l10n.eventsSavedEmptyBody,
        l10n.eventsFind,
        explore,
      ),
      _MineList.hosting => (
        l10n.eventsHostingEmptyTitle,
        l10n.eventsHostingEmptyBody,
        l10n.eventCreate,
        () => unawaited(context.push(Routes.eventNew)),
      ),
      _MineList.past => (
        l10n.eventsPastEmptyTitle,
        l10n.eventsPastEmptyBody,
        null,
        null,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ViewTabs(
          label: l10n.eventsMine,
          selected: _mine.index,
          onSelect: (i) => setState(() => _mine = _MineList.values[i]),
          options: [
            for (final m in _MineList.values)
              (label: labels[m]!, count: lists[m]!.length),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: EmptyState(
              art: const NumayaIcon(
                NumayaIcons.event,
                size: 36,
                color: AppColors.ink,
              ),
              title: empty.$1,
              body: empty.$2,
              action: empty.$3 == null
                  ? null
                  : NumayaButton(
                      label: empty.$3!,
                      small: true,
                      variant: NumayaButtonVariant.secondary,
                      onPressed: empty.$4,
                    ),
            ),
          )
        else
          for (final e in list)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s3),
              child: EventCard(
                event: e,
                now: events.now,
                area: events.area,
                saved: state.saved.contains(e.id),
                onOpen: () => _open(e),
                onToggleSave: e.mine ? null : () => _toggleSave(e),
              ),
            ),
      ],
    );
  }
}

/// A header button with a small count of active filters (Eventbrite's badge [O]).
class _CountedButton extends StatelessWidget {
  const _CountedButton({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: IgnorePointer(
              child: ExcludeSemantics(child: CountBadge(count: count)),
            ),
          ),
      ],
    );
  }
}

/// Explore's loading placeholder: card-shaped, not a spinner.
class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: AppRadii.all(AppRadii.tag),
      ),
    );
    return Semantics(
      label: context.l10n.eventsLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 2; i++) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: AppRadii.all(AppRadii.card),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            bar(220, 18),
            const SizedBox(height: AppSpacing.s2),
            bar(160, 14),
            const SizedBox(height: AppSpacing.s5),
          ],
        ],
      ),
    );
  }
}

/// Explore filters (EV-03), in V16's sheet: categories, date, free only, format, distance (from
/// the member's chosen area) and sort, with a live count.
Future<void> showEventFiltersSheet(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  return showNumayaSheet<void>(
    context: context,
    title: l10n.eventFilters,
    closeLabel: l10n.close,
    tall: true,
    builder: (context) => const _EventFiltersForm(),
  );
}

class _EventFiltersForm extends ConsumerStatefulWidget {
  const _EventFiltersForm();

  @override
  ConsumerState<_EventFiltersForm> createState() => _EventFiltersFormState();
}

class _EventFiltersFormState extends ConsumerState<_EventFiltersForm> {
  late EventFilters _draft = ref.read(eventsProvider).filters;

  static const _distances = [2, 5, 10, 25];

  Future<void> _chooseArea() async {
    final area = await showAreaSheet(context);
    if (area == null || !mounted) return;
    ref.read(profileDetailsProvider.notifier).setArea(area);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(eventsProvider);
    ref.watch(profileDetailsProvider);
    final events = ref.read(eventsProvider.notifier);
    final count = events.explore(filters: _draft).length;
    final area = events.area;
    final hasGrid = area != null && kEventAreaGrid.containsKey(area);
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Semantics(
        header: true,
        child: Text(text, style: AppTypography.section),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading(l10n.eventFilterCategories),
                Wrap(
                  spacing: AppSpacing.s2,
                  runSpacing: AppSpacing.s2,
                  children: [
                    for (final c in EventCategory.values)
                      NumayaChip(
                        label: eventCategoryLabel(l10n, c),
                        selected: _draft.categories.contains(c),
                        onTap: () => setState(() {
                          final next = {..._draft.categories};
                          next.contains(c) ? next.remove(c) : next.add(c);
                          _draft = _draft.copyWith(categories: next);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s5),
                heading(l10n.eventFilterFormat),
                ViewTabs(
                  label: l10n.eventFilterFormat,
                  selected: _draft.format.index,
                  onSelect: (i) => setState(
                    () => _draft = _draft.copyWith(
                      format: EventFormatFilter.values[i],
                    ),
                  ),
                  options: [
                    (label: l10n.eventFormatAny, count: null),
                    (label: l10n.eventFormatInPerson, count: null),
                    (label: l10n.eventFormatOnline, count: null),
                  ],
                ),
                const SizedBox(height: AppSpacing.s5),
                ListGroup(
                  footnote: l10n.eventFilterFreeNote,
                  children: [
                    ListRow(
                      label: l10n.eventFilterFree,
                      switchValue: _draft.freeOnly,
                      onSwitch: (v) =>
                          setState(() => _draft = _draft.copyWith(freeOnly: v)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s5),
                heading(l10n.eventFilterDistance),
                if (!hasGrid) ...[
                  StatusBanner(
                    title: area == null
                        ? l10n.eventFilterNoArea
                        : l10n.eventFilterAreaOutside(area),
                    body: l10n.eventFilterAreaBody,
                    action: NumayaButton(
                      label: l10n.eventFilterChooseArea,
                      small: true,
                      expand: false,
                      variant: NumayaButtonVariant.secondary,
                      onPressed: _chooseArea,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                ] else ...[
                  Text(
                    l10n.eventFilterFromArea(area),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.s3),
                ],
                Wrap(
                  spacing: AppSpacing.s2,
                  runSpacing: AppSpacing.s2,
                  children: [
                    NumayaChip(
                      label: l10n.eventDistanceAny,
                      selected: _draft.maxKm == null,
                      onTap: () => setState(
                        () => _draft = _draft.copyWith(clearMaxKm: true),
                      ),
                    ),
                    for (final km in _distances)
                      NumayaChip(
                        label: l10n.eventDistanceWithin(km),
                        selected: _draft.maxKm == km,
                        available: hasGrid,
                        onTap: () =>
                            setState(() => _draft = _draft.copyWith(maxKm: km)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s5),
                OptionGroup(
                  legend: l10n.eventSortBy,
                  children: [
                    for (final (s, label) in [
                      (EventSort.relevance, l10n.eventSortRelevance),
                      (EventSort.date, l10n.eventSortDate),
                    ])
                      OptionCard(
                        label: label,
                        kind: OptionKind.radio,
                        selected: _draft.sort == s,
                        onTap: () =>
                            setState(() => _draft = _draft.copyWith(sort: s)),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s2),
                  child: Text(l10n.eventSortNote, style: AppTypography.caption),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          label: l10n.eventShowCount(count),
          onPressed: () {
            events.setFilters(_draft);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.filtersReset,
          variant: NumayaButtonVariant.secondary,
          onPressed: () =>
              setState(() => _draft = EventFilters(sort: _draft.sort)),
        ),
      ],
    );
  }
}
