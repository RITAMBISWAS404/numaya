import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/domain/sample_people.dart';
import '../../dating/presentation/safety_sheets.dart';
import '../application/events_controller.dart';
import '../domain/event.dart';
import '../domain/sample_events.dart';
import 'event_parts.dart';

/// Event details (EV-04): what's needed to decide whether to go (when, where, cost, host, who's
/// going), then the description, safety notes and Report. The bottom bar carries the member's
/// status and the one action that fits it (Meetup's sticky attendance bar [O]). The host sees host
/// tools instead.
///
/// [preview] shows a not-yet-published event as attendees would see it (EV-09), without actions.
/// [published] shows the "Your event is live" confirmation (EV-10).
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.preview,
    this.published = false,
  });

  final String eventId;
  final DemoEvent? preview;
  final bool published;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  /// The last change failed (simulated connection problem): a banner offers Try again.
  String? _failed;

  EventsController get _events => ref.read(eventsProvider.notifier);

  Future<void> _join(DemoEvent e) async {
    final l10n = context.l10n;
    String? answer;
    if (e.question != null && !e.full) {
      answer = await _askQuestion(context, e.question!);
      if (answer == null || !mounted) return;
    }
    final result = await _events.join(e.id, answer: answer);
    if (!mounted) return;
    switch (result) {
      case JoinResult.going:
        setState(() => _failed = null);
        AppHaptics.fire(context, HapticMoment.success);
        NumayaToast.show(context, l10n.eventJoinedToast);
      case JoinResult.waitlisted:
        setState(() => _failed = null);
        AppHaptics.fire(context, HapticMoment.commit);
        NumayaToast.show(
          context,
          l10n.eventWaitlistToast(_events.byId(e.id)?.waitlistPosition ?? 1),
        );
      case JoinResult.closed:
        NumayaToast.show(context, l10n.eventClosedToast);
      case JoinResult.failed:
        AppHaptics.fire(context, HapticMoment.reject);
        setState(() => _failed = 'join');
    }
  }

  Future<void> _leave(DemoEvent e) async {
    final l10n = context.l10n;
    final waiting = e.participation == Participation.waitlisted;
    final ok = await _confirm(
      context,
      title: waiting ? l10n.eventLeaveWaitlistTitle : l10n.eventLeaveTitle,
      body: waiting ? l10n.eventLeaveWaitlistBody : l10n.eventLeaveBody,
      confirm: waiting ? l10n.eventLeaveWaitlist : l10n.eventLeave,
      cancel: l10n.eventStay,
    );
    if (!ok || !mounted) return;
    if (await _events.leave(e.id)) {
      if (!mounted) return;
      setState(() => _failed = null);
      NumayaToast.show(
        context,
        waiting ? l10n.eventLeftWaitlistToast : l10n.eventLeftToast,
      );
    } else if (mounted) {
      setState(() => _failed = 'leave');
    }
  }

  Future<void> _report(DemoEvent e) async {
    final l10n = context.l10n;
    final reason = await showNumayaSheet<String>(
      context: context,
      title: l10n.eventReportTitle,
      closeLabel: l10n.close,
      builder: (context) => const _ReportForm(),
    );
    if (reason == null || !mounted) return;
    _events.report(e.id, reason);
    NumayaToast.show(context, l10n.eventReportedToast);
    final host = personById(e.hostId);
    if (host == null) return;
    final block = await showNumayaActionSheet(
      context: context,
      cancelLabel: l10n.eventReportDone,
      actions: [
        (
          icon: NumayaIcons.block,
          label: l10n.optionBlock(host.name),
          destructive: true,
        ),
      ],
    );
    if (block != 0 || !mounted) return;
    if (await showBlockSheet(context, ref, host) && mounted) {
      NumayaToast.show(context, l10n.blockedToast(host.name));
      context.pop();
    }
  }

  Future<void> _cancelEvent(DemoEvent e) async {
    final l10n = context.l10n;
    final note = await showNumayaSheet<String>(
      context: context,
      title: l10n.eventCancelTitle,
      closeLabel: l10n.close,
      builder: (context) => const _CancelForm(),
    );
    if (note == null || !mounted) return;
    if (await _events.cancel(e.id, note: note)) {
      if (mounted) NumayaToast.show(context, l10n.eventCancelledToast);
    } else if (mounted) {
      setState(() => _failed = 'cancel');
    }
  }

  Future<void> _publishDraft(DemoEvent e) async {
    final l10n = context.l10n;
    final draft = EventDraft.of(e);
    if (EventRules.problems(draft, now: _events.now).isNotEmpty) {
      NumayaToast.show(context, l10n.eventDraftIncomplete);
      unawaited(context.push('${Routes.event}/${e.id}/edit'));
      return;
    }
    final id = await _events.publish(draft, id: e.id);
    if (!mounted) return;
    if (id == null) {
      setState(() => _failed = 'publish');
    } else {
      AppHaptics.fire(context, HapticMoment.success);
      NumayaToast.show(context, l10n.eventPublishedTitle);
    }
  }

  Future<void> _retry(DemoEvent e) async {
    switch (_failed) {
      case 'leave':
        await _leave(e);
      case 'cancel':
        await _cancelEvent(e);
      case 'publish':
        await _publishDraft(e);
      default:
        await _join(e);
    }
  }

  void _share() {
    NumayaToast.show(context, context.l10n.eventShareToast);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(eventsProvider);
    final e = widget.preview ?? state.byId(widget.eventId);
    final now = _events.now;
    if (e == null) {
      return NumayaScreen(
        top: NumayaTopBar(onBack: () => context.pop(), backLabel: l10n.back),
        body: EmptyState(
          title: l10n.eventMissingTitle,
          body: l10n.eventMissingBody,
          action: NumayaButton(
            label: l10n.eventsFind,
            small: true,
            onPressed: () => context.go(Routes.events),
          ),
        ),
      );
    }
    final preview = widget.preview != null;
    final phase = e.phaseAt(now);
    final saved = state.saved.contains(e.id);
    final pending = state.pending.contains(e.id);
    final host = personById(e.hostId);
    final area = _events.area;

    final banners = <Widget>[
      if (preview)
        StatusBanner(
          title: l10n.eventPreviewTitle,
          body: l10n.eventPreviewBody,
        ),
      if (widget.published && e.status == EventStatus.published)
        StatusBanner(
          title: l10n.eventPublishedTitle,
          body: l10n.eventPublishedBody,
          tone: BannerTone.success,
        ),
      if (e.status == EventStatus.draft && !preview)
        StatusBanner(title: l10n.eventDraftTitle, body: l10n.eventDraftBody),
      if (e.status == EventStatus.cancelled)
        StatusBanner(
          title: l10n.eventCancelledTitle,
          body: e.cancelNote == null
              ? l10n.eventCancelledBody
              : l10n.eventCancelledNote(e.cancelNote!),
          tone: BannerTone.error,
        ),
      if (e.status == EventStatus.published &&
          e.changeNote != null &&
          phase != EventPhase.past)
        StatusBanner(
          title: l10n.eventChangedTitle,
          body: e.changeNote == kHostUpdatedNote
              ? l10n.eventChangedByYou
              : e.changeNote,
          tone: BannerTone.pending,
        ),
      if (e.status == EventStatus.published && phase == EventPhase.live)
        StatusBanner(title: l10n.eventLiveTitle, body: l10n.eventLiveBody),
      if (e.status == EventStatus.published && phase == EventPhase.past)
        StatusBanner(title: l10n.eventPastTitle),
      if (_failed != null)
        StatusBanner(
          title: l10n.eventFailedTitle,
          body: l10n.eventFailedBody,
          tone: BannerTone.error,
          action: NumayaButton(
            label: l10n.discoverRetry,
            small: true,
            expand: false,
            loading: pending,
            onPressed: pending ? null : () => _retry(e),
          ),
        ),
    ];

    final named = [
      for (final a in e.attendees)
        if (a != kMe) a,
    ];
    final youGoing = e.participation == Participation.going;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.s2),
        EventCover(
          event: e,
          badges: eventBadges(l10n, e, now),
          height: 168,
          radius: AppRadii.photo,
        ),
        const SizedBox(height: AppSpacing.s4),
        for (final b in banners) ...[b, const SizedBox(height: AppSpacing.s3)],
        Semantics(
          header: true,
          child: Text(e.title, style: AppTypography.pageTitle),
        ),
        const SizedBox(height: AppSpacing.s1),
        Text(
          eventCategoryLabel(l10n, e.category),
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s4),
        ListGroup(
          children: [
            ListRow(
              leading: NumayaIcons.calendar,
              label: eventDay(e.start),
              detail: l10n.eventTimeRange(
                eventTime(e.start),
                eventTime(e.end),
                e.start.timeZoneName,
              ),
            ),
            ListRow(
              leading: e.format == EventFormat.online
                  ? NumayaIcons.public
                  : NumayaIcons.location,
              label: e.format == EventFormat.online
                  ? l10n.eventOnline
                  : e.venue,
              detail: e.format == EventFormat.online
                  ? e.onlineNote
                  : [
                      ?e.area,
                      if (e.distanceFrom(area) case final km?)
                        l10n.eventAbout(_fmt(km)),
                    ].join(' · '),
            ),
            ListRow(
              leading: NumayaIcons.tag,
              label: e.free ? l10n.eventFree : e.cost!,
              detail: l10n.eventCostNote,
            ),
            ListRow(
              leading: NumayaIcons.groups,
              label: eventGoing(l10n, e),
              detail: e.waitlist.isEmpty
                  ? null
                  : l10n.eventWaitingCount(e.waitlist.length),
              onTap: preview
                  ? null
                  : () => context.push('${Routes.event}/${e.id}/people'),
            ),
            ListRow(
              avatar: InitialsAvatar(
                initial: e.mine ? l10n.eventYou[0] : (host?.initial ?? '?'),
                size: 32,
                verified: host?.verified ?? false,
              ),
              label: l10n.eventHostedBy(eventHostName(l10n, e)),
              detail: e.mine ? l10n.eventHostYou : l10n.eventHostSample,
              onTap: host == null || preview
                  ? null
                  : () => context.push('${Routes.person}/${host.id}'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s5),
        Semantics(
          header: true,
          child: Text(l10n.eventAbout2, style: AppTypography.section),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(e.description, style: AppTypography.body),
        if (state.answers[e.id] case final answer?) ...[
          const SizedBox(height: AppSpacing.s4),
          ProfileSectionCard(
            title: e.question ?? l10n.eventYourAnswer,
            child: Text(answer, style: AppTypography.body),
          ),
        ],
        const SizedBox(height: AppSpacing.s5),
        Semantics(
          header: true,
          child: Text(l10n.eventWhoGoing, style: AppTypography.section),
        ),
        const SizedBox(height: AppSpacing.s3),
        _AttendeePreview(
          event: e,
          named: named,
          youGoing: youGoing,
          onOpen: preview
              ? null
              : () => context.push('${Routes.event}/${e.id}/people'),
        ),
        const SizedBox(height: AppSpacing.s5),
        InfoCard(
          icon: NumayaIcons.shield,
          title: l10n.eventSafetyTitle,
          body: l10n.eventSafetyBody,
        ),
        if (!e.mine && !preview) ...[
          const SizedBox(height: AppSpacing.s4),
          Center(
            child: TextLink(
              label: l10n.eventReport,
              muted: true,
              onPressed: () => _report(e),
            ),
          ),
        ],
        if (e.mine &&
            e.status == EventStatus.published &&
            phase != EventPhase.past &&
            !preview) ...[
          const SizedBox(height: AppSpacing.s4),
          Center(
            child: TextLink(
              label: l10n.eventCancel,
              danger: true,
              onPressed: pending ? null : () => _cancelEvent(e),
            ),
          ),
        ],
        if (e.mine && e.status == EventStatus.draft && !preview) ...[
          const SizedBox(height: AppSpacing.s4),
          Center(
            child: TextLink(
              label: l10n.eventDeleteDraft,
              danger: true,
              onPressed: () async {
                final ok = await _confirm(
                  context,
                  title: l10n.eventDeleteDraftTitle,
                  body: l10n.eventDeleteDraftBody,
                  confirm: l10n.eventDeleteDraft,
                  cancel: l10n.eventKeepDraft,
                );
                if (!ok || !context.mounted) return;
                _events.deleteDraft(e.id);
                context.pop();
                NumayaToast.show(context, l10n.eventDraftDeleted);
              },
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.s4),
        Text(
          e.sample ? l10n.eventsSampleNote : l10n.eventOwnNote,
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.s4),
      ],
    );

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: preview ? l10n.eventPreviewTitle : l10n.eventTitle,
        actions: [
          if (!preview && e.status != EventStatus.draft) ...[
            NavIconButton(
              icon: NumayaIcons.share,
              label: l10n.eventShare,
              onPressed: _share,
            ),
            if (!e.mine)
              NavIconButton(
                icon: NumayaIcons.heart,
                label: saved
                    ? l10n.eventUnsave(e.title)
                    : l10n.eventSave(e.title),
                outline: !saved,
                onPressed: () {
                  _events.toggleSave(e.id);
                  AppHaptics.fire(context, HapticMoment.selection);
                  NumayaToast.show(
                    context,
                    saved ? l10n.eventUnsaved : l10n.eventSaved,
                  );
                },
              ),
          ],
        ],
      ),
      footer: preview ? null : _footer(l10n, e, phase, pending),
      body: body,
    );
  }

  Widget? _footer(
    AppLocalizations l10n,
    DemoEvent e,
    EventPhase phase,
    bool pending,
  ) {
    final now = _events.now;
    if (e.mine) {
      if (e.status == EventStatus.draft) {
        return Row(
          children: [
            Expanded(
              child: NumayaButton(
                label: l10n.eventEdit,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => context.push('${Routes.event}/${e.id}/edit'),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: NumayaButton(
                label: l10n.eventPublish,
                loading: pending,
                onPressed: pending ? null : () => _publishDraft(e),
              ),
            ),
          ],
        );
      }
      if (e.status == EventStatus.cancelled || phase == EventPhase.past) {
        return null;
      }
      return Row(
        children: [
          Expanded(
            child: NumayaButton(
              label: l10n.eventEdit,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => context.push('${Routes.event}/${e.id}/edit'),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: NumayaButton(
              label: l10n.eventAttendees,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => context.push('${Routes.event}/${e.id}/people'),
            ),
          ),
        ],
      );
    }

    Widget bar(String status, String? detail, Widget? action) => Row(
      children: [
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status,
                  style: AppTypography.weight(
                    AppTypography.row,
                    AppTypography.semibold,
                  ),
                ),
                if (detail != null) Text(detail, style: AppTypography.caption),
              ],
            ),
          ),
        ),
        if (action != null) ...[const SizedBox(width: AppSpacing.s3), action],
      ],
    );

    Widget button(
      String label,
      VoidCallback onPressed, {
      bool secondary = false,
    }) => NumayaButton(
      label: label,
      expand: false,
      loading: pending,
      variant: secondary
          ? NumayaButtonVariant.secondary
          : NumayaButtonVariant.primary,
      onPressed: pending ? null : onPressed,
    );

    if (e.status == EventStatus.cancelled) {
      return bar(l10n.eventBadgeCancelled, l10n.eventCancelledFooter, null);
    }
    if (phase == EventPhase.past) {
      return bar(
        l10n.eventPastTitle,
        e.participation == Participation.going ? l10n.eventYouWent : null,
        null,
      );
    }
    switch (e.participation) {
      case Participation.going:
        return bar(
          l10n.eventYoureGoing,
          phase == EventPhase.live ? l10n.eventLiveTitle : l10n.eventDemoRsvp,
          phase == EventPhase.live
              ? null
              : button(l10n.eventLeave, () => _leave(e), secondary: true),
        );
      case Participation.waitlisted:
        return bar(
          l10n.eventOnWaitlist(e.waitlistPosition ?? 1),
          l10n.eventWaitlistDetail,
          button(l10n.eventLeaveWaitlist, () => _leave(e), secondary: true),
        );
      case Participation.none:
        if (!e.registrationOpenAt(now)) {
          return bar(
            phase == EventPhase.live
                ? l10n.eventLiveTitle
                : l10n.eventBadgeClosed,
            l10n.eventClosedDetail,
            null,
          );
        }
        final cost = e.free ? l10n.eventFree : l10n.eventCostAtVenue;
        if (e.full) {
          return bar(
            l10n.eventFull,
            l10n.eventWaitingCount(e.waitlist.length),
            button(l10n.eventJoinWaitlist, () => _join(e)),
          );
        }
        return bar(
          cost,
          e.spotsLeft == null ? null : l10n.eventSpotsLeft(e.spotsLeft!),
          button(l10n.eventJoin, () => _join(e)),
        );
    }
  }
}

String _fmt(double km) =>
    km == km.roundToDouble() ? km.toStringAsFixed(0) : km.toStringAsFixed(1);

/// Up to five named people (first name and initial), then a count (spec §6).
class _AttendeePreview extends StatelessWidget {
  const _AttendeePreview({
    required this.event,
    required this.named,
    required this.youGoing,
    required this.onOpen,
  });

  final DemoEvent event;
  final List<String> named;
  final bool youGoing;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final people = [for (final id in named.take(5)) ?personById(id)];
    final more = event.goingCount - 1 - people.length - (youGoing ? 1 : 0);
    final summary = [
      l10n.eventHostedBy(eventHostName(l10n, event)),
      if (youGoing) l10n.eventYou,
      for (final p in people) p.name,
      if (more > 0) l10n.eventAndMore(more),
    ].join(', ');
    return Pressable(
      onTap: onOpen,
      semanticLabel: '${l10n.eventWhoGoing}: $summary',
      excludeChildSemantics: true,
      pressedScale: 1,
      child: WhiteCard(
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: AppSpacing.s1,
                runSpacing: AppSpacing.s1,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (youGoing)
                    InitialsAvatar(initial: l10n.eventYou[0], size: 36),
                  for (final p in people)
                    InitialsAvatar(initial: p.initial, size: 36),
                  if (more > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.s2),
                      child: Text(
                        l10n.eventAndMore(more),
                        style: AppTypography.bodySm,
                      ),
                    ),
                  if (people.isEmpty && !youGoing && more <= 0)
                    Text(l10n.eventNobodyYet, style: AppTypography.bodySm),
                ],
              ),
            ),
            if (onOpen != null)
              const NumayaIcon(
                NumayaIcons.chevronRight,
                size: AppSizes.iconMd,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirm,
  required String cancel,
}) async {
  final l10n = context.l10n;
  final ok = await showNumayaSheet<bool>(
    context: context,
    title: title,
    closeLabel: l10n.close,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(body, style: AppTypography.body),
        const SizedBox(height: AppSpacing.s5),
        NumayaButton(
          label: confirm,
          variant: NumayaButtonVariant.destructiveSolid,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: cancel,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// The host's question before joining (EV-05). Returns the answer, or null when closed.
Future<String?> _askQuestion(BuildContext context, String question) {
  final l10n = context.l10n;
  return showNumayaSheet<String>(
    context: context,
    title: l10n.eventQuestionTitle,
    closeLabel: l10n.close,
    builder: (context) => _QuestionForm(question: question),
  );
}

class _QuestionForm extends StatefulWidget {
  const _QuestionForm({required this.question});

  final String question;

  @override
  State<_QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<_QuestionForm> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ok = _text.text.trim().isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.question, style: AppTypography.body),
        const SizedBox(height: AppSpacing.s3),
        NumayaTextField(
          label: l10n.eventYourAnswer,
          controller: _text,
          multiline: true,
          maxLength: EventRules.questionMax,
          textCapitalization: TextCapitalization.sentences,
          hint: l10n.eventAnswerHint,
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          label: l10n.eventJoin,
          onPressed: ok
              ? () => Navigator.of(context).pop(_text.text.trim())
              : null,
        ),
      ],
    );
  }
}

class _ReportForm extends StatefulWidget {
  const _ReportForm();

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  String? _reason;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: OptionGroup(
              legend: l10n.eventReportLegend,
              children: [
                for (final r in kEventReportReasons)
                  OptionCard(
                    label: r,
                    kind: OptionKind.radio,
                    selected: _reason == r,
                    onTap: () => setState(() => _reason = r),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        Text(l10n.eventReportNote, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          label: l10n.eventReportSend,
          onPressed: _reason == null
              ? null
              : () => Navigator.of(context).pop(_reason),
        ),
      ],
    );
  }
}

class _CancelForm extends StatefulWidget {
  const _CancelForm();

  @override
  State<_CancelForm> createState() => _CancelFormState();
}

class _CancelFormState extends State<_CancelForm> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.eventCancelBody, style: AppTypography.body),
        const SizedBox(height: AppSpacing.s3),
        NumayaTextField(
          label: l10n.eventCancelNoteLabel,
          controller: _note,
          multiline: true,
          maxLength: EventRules.questionMax,
          textCapitalization: TextCapitalization.sentences,
          hint: l10n.eventCancelNoteHint,
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          label: l10n.eventCancelConfirm,
          variant: NumayaButtonVariant.destructiveSolid,
          onPressed: () => Navigator.of(context).pop(_note.text),
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.eventCancelKeep,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
