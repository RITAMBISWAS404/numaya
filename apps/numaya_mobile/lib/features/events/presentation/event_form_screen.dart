import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/presentation/permission_prompt.dart';
import '../application/events_controller.dart';
import '../domain/event.dart';
import 'event_detail_screen.dart';
import 'event_parts.dart';

/// Create or edit an event (EV-08), Meetup's editor [O] cut to the MVP: cover colour, title,
/// category, description, date, start time, length, format, venue or online note, an attendee
/// limit, a cost note and an optional question. Save draft keeps it private; Publish needs every
/// required field; Preview shows it as attendees will (EV-09). Leaving with changes asks first.
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.eventId});

  /// Null for a new event.
  final String? eventId;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  late final DemoEvent? _existing = widget.eventId == null
      ? null
      : ref.read(eventsProvider).byId(widget.eventId!);
  late final EventDraft _initial = _existing == null
      ? const EventDraft()
      : EventDraft.of(_existing);
  late EventDraft _d = _initial;

  late final _title = TextEditingController(text: _initial.title);
  late final _description = TextEditingController(text: _initial.description);
  late final _venue = TextEditingController(text: _initial.venue);
  late final _online = TextEditingController(text: _initial.onlineNote);
  late final _cost = TextEditingController(text: _initial.cost);
  late final _question = TextEditingController(text: _initial.question);

  /// Errors show after the first Publish attempt (forms-and-input: not while typing the first time).
  bool _tried = false;
  bool _busy = false;
  bool _leaving = false;

  bool get _published => _existing?.status == EventStatus.published;

  @override
  void initState() {
    super.initState();
    void sync() => setState(
      () => _d = _d.copyWith(
        title: _title.text,
        description: _description.text,
        venue: _venue.text,
        onlineNote: _online.text,
        cost: _cost.text,
        question: _question.text,
      ),
    );
    for (final c in [_title, _description, _venue, _online, _cost, _question]) {
      c.addListener(sync);
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _description, _venue, _online, _cost, _question]) {
      c.dispose();
    }
    super.dispose();
  }

  EventsController get _events => ref.read(eventsProvider.notifier);

  int get _going => _existing == null
      ? 0
      : _existing.attendees.length + _existing.othersGoing;

  List<EventProblem> get _problems =>
      EventRules.problems(_d, now: _events.now, going: _going);

  bool get _dirty => _d != _initial;

  String? _error(List<EventProblem> problems, List<EventProblem> mine) {
    if (!_tried) return null;
    final l10n = context.l10n;
    for (final p in mine) {
      if (!problems.contains(p)) continue;
      return switch (p) {
        EventProblem.titleMissing => l10n.eventErrTitle(EventRules.titleMin),
        EventProblem.titleTooLong => l10n.eventErrTitleLong(
          EventRules.titleMax,
        ),
        EventProblem.categoryMissing => l10n.eventErrCategory,
        EventProblem.descriptionMissing => l10n.eventErrDescription(
          EventRules.descriptionMin,
        ),
        EventProblem.dateMissing => l10n.eventErrDate,
        EventProblem.dateInPast => l10n.eventErrPast,
        EventProblem.venueMissing => l10n.eventErrVenue,
        EventProblem.onlineNoteMissing => l10n.eventErrOnline,
        EventProblem.capacityTooSmall => l10n.eventErrCapacity(
          EventRules.capacityMin,
        ),
        EventProblem.capacityBelowGoing => l10n.eventErrCapacityGoing(_going),
      };
    }
    return null;
  }

  Future<void> _pickDay() async {
    final l10n = context.l10n;
    final now = _events.now;
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showNumayaSheet<DateTime>(
      context: context,
      title: l10n.eventFieldDate,
      closeLabel: l10n.close,
      tall: true,
      builder: (context) => SingleChildScrollView(
        child: ListGroup(
          children: [
            for (var i = 0; i < 28; i++)
              ListRow(
                label: i == 0
                    ? l10n.eventDateToday
                    : eventDay(today.add(Duration(days: i))),
                value: _d.day == today.add(Duration(days: i))
                    ? l10n.eventSelected
                    : null,
                onTap: () =>
                    Navigator.of(context).pop(today.add(Duration(days: i))),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _d = _d.copyWith(day: picked));
  }

  Future<void> _pickTime() async {
    final l10n = context.l10n;
    final picked = await showNumayaSheet<int>(
      context: context,
      title: l10n.eventFieldTime,
      closeLabel: l10n.close,
      tall: true,
      builder: (context) => SingleChildScrollView(
        child: ListGroup(
          children: [
            for (var m = 7 * 60; m <= 23 * 60; m += 30)
              ListRow(
                label: _clock(m),
                value: _d.startMinutes == m ? l10n.eventSelected : null,
                onTap: () => Navigator.of(context).pop(m),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _d = _d.copyWith(startMinutes: picked));
  }

  Future<void> _pickArea() async {
    final area = await showAreaSheet(context, selected: _d.area);
    if (area != null) setState(() => _d = _d.copyWith(area: area));
  }

  static String _clock(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  Future<void> _saveDraft() async {
    final l10n = context.l10n;
    if (!EventRules.canSaveDraft(_d)) {
      setState(() => _tried = true);
      NumayaToast.show(context, l10n.eventDraftNeedsTitle);
      return;
    }
    setState(() => _busy = true);
    final id = await _events.saveDraft(_d, id: widget.eventId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (id == null) {
      NumayaToast.show(context, l10n.eventFailedTitle);
      return;
    }
    NumayaToast.show(context, l10n.eventDraftSaved);
    _leaving = true;
    if (widget.eventId == null) {
      context.pushReplacement('${Routes.event}/$id');
    } else {
      context.pop();
    }
  }

  Future<void> _publish() async {
    final l10n = context.l10n;
    setState(() => _tried = true);
    if (_problems.isNotEmpty) {
      AppHaptics.fire(context, HapticMoment.reject);
      NumayaToast.show(context, l10n.eventFixErrors);
      return;
    }
    setState(() => _busy = true);
    final id = await _events.publish(_d, id: widget.eventId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (id == null) {
      NumayaToast.show(context, l10n.eventFailedTitle);
      return;
    }
    AppHaptics.fire(context, HapticMoment.success);
    _leaving = true;
    if (_published) {
      NumayaToast.show(context, l10n.eventChangesSaved);
      context.pop();
    } else {
      context.pushReplacement('${Routes.event}/$id?published=1');
    }
  }

  void _preview() {
    final l10n = context.l10n;
    final preview = DemoEvent(
      id: widget.eventId ?? 'preview',
      title: _d.title.trim().isEmpty ? l10n.eventUntitled : _d.title.trim(),
      category: _d.category ?? EventCategory.games,
      description: _d.description.trim(),
      hostId: kMe,
      start: _d.start ?? _events.now.add(const Duration(days: 7)),
      duration: _d.duration,
      format: _d.format,
      venue: _d.venue.trim(),
      area: _d.area,
      onlineNote: _d.onlineNote.trim(),
      capacity: _d.capacity,
      cost: _d.cost.trim().isEmpty ? null : _d.cost.trim(),
      question: _d.question.trim().isEmpty ? null : _d.question.trim(),
      attendees: _existing?.attendees ?? const [],
      othersGoing: _existing?.othersGoing ?? 0,
      tone: _d.tone,
      sample: false,
    );
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              EventDetailScreen(eventId: preview.id, preview: preview),
        ),
      ),
    );
  }

  Future<void> _confirmLeave() async {
    final l10n = context.l10n;
    final canDraft = !_published && EventRules.canSaveDraft(_d);
    final choice = await showNumayaSheet<String>(
      context: context,
      title: l10n.eventDiscardTitle,
      closeLabel: l10n.close,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.eventDiscardBody, style: AppTypography.body),
          const SizedBox(height: AppSpacing.s5),
          if (canDraft) ...[
            NumayaButton(
              label: l10n.eventSaveDraft,
              onPressed: () => Navigator.of(context).pop('draft'),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          NumayaButton(
            label: l10n.eventDiscard,
            variant: NumayaButtonVariant.destructive,
            onPressed: () => Navigator.of(context).pop('discard'),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.eventKeepEditing,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'draft') {
      await _saveDraft();
    } else if (choice == 'discard') {
      setState(() => _leaving = true);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (widget.eventId != null && _existing == null) {
      return NumayaScreen(
        top: NumayaTopBar(onBack: () => context.pop(), backLabel: l10n.back),
        body: EmptyState(
          title: l10n.eventMissingTitle,
          body: l10n.eventMissingBody,
        ),
      );
    }
    final problems = _problems;
    final durations = const [60, 90, 120, 180, 240];

    Widget gap([double h = AppSpacing.s4]) => SizedBox(height: h);
    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Semantics(
        header: true,
        child: Text(t, style: AppTypography.section),
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gap(),
        if (_published) ...[
          StatusBanner(
            title: l10n.eventEditingPublished,
            body: l10n.eventEditingPublishedBody,
          ),
          gap(),
        ],
        EventCover(
          event: DemoEvent(
            id: 'cover',
            title: '',
            category: _d.category ?? EventCategory.games,
            description: '',
            hostId: kMe,
            start: _events.now,
            duration: Duration.zero,
            tone: _d.tone,
          ),
          badges: const [],
        ),
        gap(AppSpacing.s3),
        Semantics(
          label: l10n.eventFieldCover,
          child: Row(
            children: [
              for (var i = 0; i < kEventTones.length; i++) ...[
                Pressable(
                  onTap: () => setState(() => _d = _d.copyWith(tone: i)),
                  semanticLabel: l10n.eventCoverOption(i + 1),
                  selected: _d.tone == i,
                  excludeChildSemantics: true,
                  borderRadius: AppRadii.all(AppRadii.pill),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kEventTones[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _d.tone == i
                            ? AppColors.ink
                            : AppColors.borderStrong,
                        width: _d.tone == i
                            ? AppBorders.selected
                            : AppBorders.hairline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
              ],
            ],
          ),
        ),
        gap(AppSpacing.s2),
        Text(l10n.eventCoverNote, style: AppTypography.caption),
        gap(AppSpacing.s5),
        NumayaTextField(
          label: l10n.eventFieldTitle,
          controller: _title,
          maxLength: EventRules.titleMax,
          textCapitalization: TextCapitalization.sentences,
          error: _error(problems, [
            EventProblem.titleMissing,
            EventProblem.titleTooLong,
          ]),
        ),
        gap(),
        heading(l10n.eventFieldCategory),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final c in EventCategory.values)
              NumayaChip(
                label: eventCategoryLabel(l10n, c),
                selected: _d.category == c,
                onTap: () => setState(() => _d = _d.copyWith(category: c)),
              ),
          ],
        ),
        if (_error(problems, [EventProblem.categoryMissing]) case final err?)
          FieldNote(err, tone: FieldNoteTone.error),
        gap(AppSpacing.s5),
        NumayaTextField(
          label: l10n.eventFieldDescription,
          controller: _description,
          multiline: true,
          maxLength: EventRules.descriptionMax,
          textCapitalization: TextCapitalization.sentences,
          hint: l10n.eventDescriptionHint,
          error: _error(problems, [EventProblem.descriptionMissing]),
        ),
        gap(AppSpacing.s5),
        heading(l10n.eventFieldWhen),
        ListGroup(
          children: [
            ListRow(
              label: l10n.eventFieldDate,
              value: _d.day == null ? l10n.eventChoose : eventDay(_d.day!),
              onTap: _pickDay,
            ),
            ListRow(
              label: l10n.eventFieldTime,
              value: _d.startMinutes == null
                  ? l10n.eventChoose
                  : _clock(_d.startMinutes!),
              onTap: _pickTime,
            ),
          ],
        ),
        if (_error(problems, [
              EventProblem.dateMissing,
              EventProblem.dateInPast,
            ])
            case final err?)
          FieldNote(err, tone: FieldNoteTone.error),
        gap(AppSpacing.s3),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final m in durations)
              NumayaChip(
                label: l10n.eventDuration(m ~/ 60, m % 60),
                selected: _d.duration.inMinutes == m,
                onTap: () => setState(
                  () => _d = _d.copyWith(duration: Duration(minutes: m)),
                ),
              ),
          ],
        ),
        gap(AppSpacing.s5),
        heading(l10n.eventFieldWhere),
        ViewTabs(
          label: l10n.eventFieldWhere,
          selected: _d.format.index,
          onSelect: (i) =>
              setState(() => _d = _d.copyWith(format: EventFormat.values[i])),
          options: [
            (label: l10n.eventFormatInPerson, count: null),
            (label: l10n.eventFormatOnline, count: null),
          ],
        ),
        gap(AppSpacing.s3),
        if (_d.format == EventFormat.inPerson) ...[
          NumayaTextField(
            label: l10n.eventFieldVenue,
            controller: _venue,
            maxLength: EventRules.venueMax,
            textCapitalization: TextCapitalization.words,
            hint: l10n.eventVenueHint,
            error: _error(problems, [EventProblem.venueMissing]),
          ),
          gap(AppSpacing.s3),
          ListGroup(
            footnote: l10n.eventAreaNote,
            children: [
              ListRow(
                label: l10n.eventFieldArea,
                value: _d.area ?? l10n.eventChoose,
                onTap: _pickArea,
              ),
            ],
          ),
        ] else
          NumayaTextField(
            label: l10n.eventFieldOnline,
            controller: _online,
            multiline: true,
            maxLength: EventRules.questionMax,
            textCapitalization: TextCapitalization.sentences,
            hint: l10n.eventOnlineHint,
            error: _error(problems, [EventProblem.onlineNoteMissing]),
          ),
        gap(AppSpacing.s5),
        heading(l10n.eventFieldPeople),
        ListGroup(
          footnote: l10n.eventLimitNote,
          children: [
            ListRow(
              label: l10n.eventFieldLimit,
              switchValue: _d.capacity != null,
              onSwitch: (on) => setState(
                () => _d = on
                    ? _d.copyWith(capacity: _going.clamp(8, 200))
                    : _d.copyWith(clearCapacity: true),
              ),
            ),
          ],
        ),
        if (_d.capacity != null) ...[
          gap(AppSpacing.s3),
          Row(
            children: [
              NavIconButton(
                icon: NumayaIcons.minus,
                label: l10n.eventFewer,
                onPressed: _d.capacity! > EventRules.capacityMin
                    ? () => setState(
                        () => _d = _d.copyWith(capacity: _d.capacity! - 1),
                      )
                    : null,
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.eventCapacityValue(_d.capacity!),
                    textAlign: TextAlign.center,
                    style: AppTypography.section,
                  ),
                ),
              ),
              NavIconButton(
                icon: NumayaIcons.plus,
                label: l10n.eventMore,
                onPressed: _d.capacity! < EventRules.capacityMax
                    ? () => setState(
                        () => _d = _d.copyWith(capacity: _d.capacity! + 1),
                      )
                    : null,
              ),
            ],
          ),
          if (_error(problems, [
                EventProblem.capacityTooSmall,
                EventProblem.capacityBelowGoing,
              ])
              case final err?)
            FieldNote(err, tone: FieldNoteTone.error),
        ],
        gap(AppSpacing.s5),
        NumayaTextField(
          label: l10n.eventFieldCost,
          controller: _cost,
          maxLength: EventRules.costMax,
          textCapitalization: TextCapitalization.sentences,
          hint: l10n.eventCostHint,
          inputFormatters: [
            LengthLimitingTextInputFormatter(EventRules.costMax),
          ],
        ),
        gap(),
        NumayaTextField(
          label: l10n.eventFieldQuestion,
          controller: _question,
          maxLength: EventRules.questionMax,
          textCapitalization: TextCapitalization.sentences,
          hint: l10n.eventQuestionHint,
        ),
        gap(AppSpacing.s5),
        Text(l10n.eventFormNote, style: AppTypography.caption),
        gap(),
      ],
    );

    final footer = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (!_published) ...[
              Expanded(
                child: NumayaButton(
                  label: l10n.eventSaveDraft,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: _busy ? null : _saveDraft,
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
            ],
            Expanded(
              child: NumayaButton(
                label: l10n.eventPreview,
                variant: NumayaButtonVariant.secondary,
                onPressed: _busy ? null : _preview,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: _published ? l10n.eventSaveChanges : l10n.eventPublish,
          loading: _busy,
          onPressed: _busy ? null : _publish,
        ),
      ],
    );

    return PopScope(
      canPop: !_dirty || _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmLeave());
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: NumayaScreen(
          top: NumayaTopBar(
            onBack: () => Navigator.of(context).maybePop(),
            backLabel: l10n.back,
            closeIcon: true,
            title: widget.eventId == null
                ? l10n.eventNewTitle
                : l10n.eventEditTitle,
          ),
          footer: footer,
          body: body,
        ),
      ),
    );
  }
}
