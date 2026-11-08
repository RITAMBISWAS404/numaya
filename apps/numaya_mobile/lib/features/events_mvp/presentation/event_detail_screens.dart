import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../lab/lab_banners.dart';
import '../../lab/lab_registry.dart';
import '../application/events_mvp_controller.dart';
import '../domain/event_models.dart';
import 'ev_parts.dart';

/// E02 — Event detail. Activity, host, when (with timezone), public venue, access facts (unknown is
/// said to be unknown), who it's for, places, free price, cancellation terms, report and support.
/// No attendee list. Reserve, view reservation, or alternatives when full.
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final now = ref.read(clockProvider)();
    final e = s.events[eventId];
    final top = NumayaTopBar(
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.events),
      backLabel: l10n.back,
      actions: [
        NavIconButton(
          icon: NumayaIcons.flag,
          label: l10n.evReportSupport,
          onPressed: () => showEvReport(context, ref),
        ),
      ],
    );
    if (e == null ||
        e.lifecycle == EvLifecycle.draft ||
        e.lifecycle == EvLifecycle.review) {
      return NumayaScreen(
        top: top,
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s8),
          child: EmptyState(title: l10n.evNotFound, body: ''),
        ),
      );
    }
    final r = c.effectiveReservation(eventId);
    final phase = e.phaseAt(now);
    final full = c.isFull(eventId);
    final booked = r != null && r.active;

    final Widget footer;
    if (booked) {
      footer = NumayaButton(
        key: const ValueKey('ev-view-reservation'),
        label: l10n.evViewReservation,
        onPressed: () => context.push('${Routes.evReservation}/$eventId'),
      );
    } else if (phase == EvPhase.upcoming && !full) {
      // Lab group `ea-event-action` (Ente alignment V3): O is the approved full-width button.
      final v = ref.watch(labVariantProvider('ea-event-action'));
      final places = l10n.evPlacesLeft(c.placesLeft(eventId));
      void reserve() => context.push('${Routes.evEvent}/$eventId/reserve');
      footer = switch (v) {
        // A: summary on the left, a compact primary on the right (Insight Timer, Trainline).
        'A' => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.evFree,
                    style: AppTypography.weight(
                      AppTypography.body,
                      AppTypography.semibold,
                    ),
                  ),
                  Text(places, style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            NumayaButton(
              key: const ValueKey('ev-reserve'),
              label: l10n.evReserveShort,
              expand: false,
              onPressed: reserve,
            ),
          ],
        ),
        // B: the availability line above the full-width button.
        'B' => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.evFree} · $places',
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.s2),
            NumayaButton(
              key: const ValueKey('ev-reserve'),
              label: l10n.evReserve,
              onPressed: reserve,
            ),
          ],
        ),
        _ => NumayaButton(
          key: const ValueKey('ev-reserve'),
          label: l10n.evReserve,
          onPressed: reserve,
        ),
      };
    } else {
      footer = const SizedBox.shrink();
    }

    final Widget? state = switch (phase) {
      EvPhase.cancelled => LabStatusBanner(
        tone: BannerTone.error,
        title: l10n.evCancelledTitle,
        body: e.cancelReason,
      ),
      EvPhase.started => LabStatusBanner(
        tone: BannerTone.pending,
        title: l10n.evStartedTitle,
        body: l10n.evStartedBody,
      ),
      EvPhase.completed => LabStatusBanner(
        tone: BannerTone.info,
        title: l10n.evCompletedTitle,
      ),
      EvPhase.upcoming when full && !booked => LabStatusBanner(
        key: const ValueKey('ev-full'),
        tone: BannerTone.pending,
        title: l10n.evFullTitle,
        body: l10n.evFullBody,
      ),
      _ => null,
    };

    final alts = full && !booked && phase == EvPhase.upcoming
        ? c.alternatives(eventId)
        : const <NumayaEvent>[];

    return NumayaScreen(
      top: top,
      footer: booked || (phase == EvPhase.upcoming && !full) ? footer : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s2),
          EvCover(event: e),
          const SizedBox(height: AppSpacing.s4),
          Semantics(
            header: true,
            child: Text(e.title, style: AppTypography.pageTitle),
          ),
          const SizedBox(height: AppSpacing.s1),
          EvInfoLine(icon: NumayaIcons.calendar, text: evWhen(l10n, e.start)),
          const SizedBox(height: AppSpacing.s3),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s1,
            children: [
              EvStatusBadge(label: l10n.evFree),
              EvStatusBadge(label: evCategoryLabel(l10n, e.category)),
              EvStatusBadge(label: l10n.evSampleBanner),
            ],
          ),
          if (state != null) ...[const SizedBox(height: AppSpacing.s4), state],
          if (full && !booked && phase == EvPhase.upcoming) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(l10n.evAlternatives(e.city), style: AppTypography.section),
            const SizedBox(height: AppSpacing.s2),
            if (alts.isEmpty)
              Text(l10n.evNoAlternatives(e.city), style: AppTypography.bodySm)
            else
              for (final a in alts) ...[
                EvCard(
                  event: a,
                  status: l10n.evPlacesLeft(c.placesLeft(a.id)),
                  onTap: () => context.push('${Routes.evEvent}/${a.id}'),
                ),
                const SizedBox(height: AppSpacing.s2),
              ],
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          EvCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EvFact(
                  icon: NumayaIcons.info,
                  title: l10n.evAbout,
                  body: e.description,
                ),
                EvFact(
                  icon: NumayaIcons.user,
                  title: l10n.evHostedBy,
                  body: l10n.evHostSample(e.hostName),
                ),
                EvFact(
                  icon: NumayaIcons.clock,
                  title: l10n.evWhenTitle,
                  body:
                      '${evDay(e.start)} · ${l10n.evTimes(evTime(e.start), evTime(e.end), e.timezone)}',
                ),
                EvFact(
                  icon: NumayaIcons.location,
                  title: l10n.evWhereTitle,
                  body: '${e.venue.name}\n${e.venue.address}, ${e.city}',
                  extra: TextLink(
                    label: l10n.evDirections,
                    onPressed: () =>
                        NumayaToast.show(context, l10n.evDirectionsDemo),
                  ),
                ),
                EvFact(
                  icon: NumayaIcons.public,
                  title: l10n.evAccessibility,
                  body: e.venue.accessibility ?? l10n.evAccessUnknown,
                ),
                if (e.venue.transport != null)
                  EvFact(
                    icon: NumayaIcons.nearby,
                    title: l10n.evTransport,
                    body: e.venue.transport!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          EvCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EvFact(
                  icon: NumayaIcons.groups,
                  title: l10n.evWhoTitle,
                  body: l10n.evWhoBody(e.minAge),
                ),
                EvFact(
                  icon: NumayaIcons.event,
                  title: l10n.evPlacesTitle,
                  body: l10n.evPlacesBody(c.reserved(eventId), e.capacity),
                ),
                EvFact(
                  icon: NumayaIcons.tag,
                  title: l10n.evPriceTitle,
                  body: l10n.evPriceBody,
                ),
                EvFact(
                  icon: NumayaIcons.undo,
                  title: l10n.evCancelTermsTitle,
                  body: '${l10n.evCancelTerms} ${l10n.evNoDirectory}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Center(
            child: TextLink(
              label: l10n.evReportSupport,
              muted: true,
              onPressed: () => showEvReport(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

/// E03 — Reserve: one place, required acknowledgement, optional discoverability (off by
/// default, never bundled), then submitting / confirmed / full / duplicate / ineligible /
/// uncertain / error. The button locks while submitting.
class EventReserveScreen extends ConsumerStatefulWidget {
  const EventReserveScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<EventReserveScreen> createState() => _EventReserveScreenState();
}

class _EventReserveScreenState extends ConsumerState<EventReserveScreen> {
  bool _ack = false;
  bool _discoverable = false;
  bool _busy = false;
  ReserveResult? _result;

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    AppHaptics.fire(context, HapticMoment.commit);
    final r = await ref
        .read(eventsMvpProvider.notifier)
        .reserve(widget.eventId, discoverable: _discoverable);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = r;
    });
    if (r == ReserveResult.confirmed || r == ReserveResult.alreadyReserved) {
      AppHaptics.fire(context, HapticMoment.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final e = c.event(widget.eventId);
    final top = NumayaTopBar(
      onBack: () => context.pop(),
      backLabel: l10n.back,
      title: l10n.evReserveTitle,
      closeIcon: true,
    );
    if (e == null) {
      return NumayaScreen(
        top: top,
        body: EmptyState(title: l10n.evNotFound, body: ''),
      );
    }
    final problems = c.ineligibility(widget.eventId);
    final overlaps = c.overlaps(widget.eventId);
    final result = _result;

    if (result == ReserveResult.confirmed ||
        result == ReserveResult.alreadyReserved) {
      return NumayaScreen(
        top: top,
        footer: NumayaButton(
          key: const ValueKey('ev-reserved-view'),
          label: l10n.evViewReservation,
          onPressed: () => context.pushReplacement(
            '${Routes.evReservation}/${widget.eventId}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabStatusBanner(
                key: const ValueKey('ev-reserved'),
                tone: BannerTone.success,
                title: result == ReserveResult.confirmed
                    ? l10n.evReservedTitle
                    : l10n.evAlreadyReserved,
                body: l10n.evReservedBody(e.title),
              ),
            ],
          ),
        ),
      );
    }

    final banner = switch (result) {
      ReserveResult.full => LabStatusBanner(
        key: const ValueKey('ev-result-full'),
        tone: BannerTone.pending,
        title: l10n.evFullTitle,
        body: l10n.evFullBody,
      ),
      ReserveResult.uncertain => LabStatusBanner(
        key: const ValueKey('ev-result-uncertain'),
        tone: BannerTone.pending,
        title: l10n.evUncertainTitle,
        body: l10n.evUncertainBody,
        action: NumayaButton(
          key: const ValueKey('ev-check-status'),
          label: l10n.evCheckStatus,
          small: true,
          expand: false,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => setState(
            () => _result = ref
                .read(eventsMvpProvider.notifier)
                .reconcile(widget.eventId),
          ),
        ),
      ),
      ReserveResult.error ||
      ReserveResult.closed ||
      ReserveResult.cancelled => LabStatusBanner(
        key: const ValueKey('ev-result-error'),
        tone: BannerTone.error,
        title: l10n.evErrorTitle,
        body: l10n.evErrorBody,
      ),
      ReserveResult.ineligible => null,
      _ => null,
    };

    return NumayaScreen(
      top: top,
      footer: problems.isNotEmpty
          ? NumayaButton(
              label: l10n.evCompleteProfile,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => context.push(Routes.editProfile),
            )
          : NumayaButton(
              key: const ValueKey('ev-confirm'),
              label: _busy ? l10n.evSubmitting : l10n.evConfirmReserve,
              loading: _busy,
              onPressed: _ack && !_busy && result != ReserveResult.full
                  ? () => unawaited(_submit())
                  : null,
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          EvCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EvFact(
                  icon: NumayaIcons.event,
                  title: e.title,
                  body:
                      '${evWhen(l10n, e.start)} ${e.timezone}\n${e.venue.name}, ${e.city}',
                ),
                EvFact(
                  icon: NumayaIcons.user,
                  title: l10n.evReserveSummary,
                  body: '${l10n.evPriceBody} ${l10n.evCancelTerms}',
                ),
              ],
            ),
          ),
          if (problems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            LabStatusBanner(
              key: const ValueKey('ev-ineligible'),
              tone: BannerTone.error,
              title: l10n.evIneligibleTitle,
              body: problems
                  .map(
                    (p) => switch (p) {
                      Ineligibility.profileIncomplete =>
                        l10n.evIneligibleProfile,
                      Ineligibility.phoneUnverified => l10n.evIneligiblePhone,
                      Ineligibility.ageOutsideEvent => l10n.evIneligibleAge,
                      Ineligibility.underAge => l10n.evIneligibleUnder,
                    },
                  )
                  .join(' '),
            ),
          ] else ...[
            if (overlaps.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s4),
              LabStatusBanner(
                tone: BannerTone.pending,
                title: l10n.evOverlapTitle,
                body: l10n.evOverlapBody(overlaps.first.title),
              ),
            ],
            if (banner != null) ...[
              const SizedBox(height: AppSpacing.s4),
              banner,
            ],
            const SizedBox(height: AppSpacing.s4),
            EvCardBox(
              child: Column(
                children: [
                  CheckboxRow(
                    key: const ValueKey('ev-ack'),
                    value: _ack,
                    label: l10n.evReserveAck,
                    onChanged: (v) => setState(() => _ack = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            ListGroup(
              footnote: l10n.evDiscoverableBody,
              children: [
                ListRow(
                  key: const ValueKey('ev-discoverable'),
                  label: l10n.evDiscoverableTitle,
                  switchValue: _discoverable,
                  onSwitch: (v) => setState(() => _discoverable = v),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A labelled checkbox row (required acknowledgement).
class CheckboxRow extends StatelessWidget {
  const CheckboxRow({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => onChanged(!value),
    semanticLabel: label,
    toggled: value,
    excludeChildSemantics: true,
    pressedScale: 1,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.accent : AppColors.surface,
              borderRadius: AppRadii.all(AppRadii.checkbox),
              border: Border.all(
                color: value ? AppColors.accent : AppColors.borderStrong,
                width: 1.5,
              ),
            ),
            child: value
                ? const NumayaIcon(
                    NumayaIcons.check,
                    size: 16,
                    color: AppColors.accentForeground,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(child: Text(label, style: AppTypography.body)),
        ],
      ),
    ),
  );
}

/// E05 — Reservation detail: status, reference (not a ticket), directions and calendar (demo),
/// event-specific discoverability, cancel before start, updates, People I met when available.
class ReservationScreen extends ConsumerWidget {
  const ReservationScreen({super.key, required this.eventId});
  final String eventId;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showNumayaSheet<bool>(
      context: context,
      title: l10n.evCancelConfirmTitle,
      closeLabel: l10n.close,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.evCancelConfirmBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            key: const ValueKey('ev-cancel-confirm'),
            label: l10n.evCancel,
            // Ente yes/no sheet: the main action on top, Critical for a removal (EA-B02).
            variant: NumayaButtonVariant.destructiveSolid,
            onPressed: () => Navigator.of(sheet).pop(true),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.evCancelKeep,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => Navigator.of(sheet).pop(false),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    if (ref.read(eventsMvpProvider.notifier).cancel(eventId)) {
      NumayaToast.show(context, l10n.evCancelled);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final now = ref.read(clockProvider)();
    final e = c.event(eventId);
    final r = c.effectiveReservation(eventId);
    final top = NumayaTopBar(
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.evMine),
      backLabel: l10n.back,
      title: l10n.evReservationTitle,
      actions: [
        NavIconButton(
          icon: NumayaIcons.flag,
          label: l10n.evReportSupport,
          onPressed: () => showEvReport(context, ref),
        ),
      ],
    );
    if (e == null || r == null) {
      return NumayaScreen(
        top: top,
        body: EmptyState(title: l10n.evNotFound, body: ''),
      );
    }
    final phase = e.phaseAt(now);
    final attendance = c.attendanceOf(eventId);
    final notices = c.noticesFor(eventId);
    final pending = notices
        .where(
          (n) =>
              n.kind == NoticeKind.material &&
              !c.isSuperseded(n) &&
              r.status == ResStatus.reconfirmRequired,
        )
        .firstOrNull;

    final (
      String statusTitle,
      BannerTone tone,
      String? statusBody,
    ) = switch (r.status) {
      ResStatus.cancelled => (
        l10n.evStatusCancelled,
        BannerTone.error,
        switch (r.cancelReason) {
          CancelReason.eventCancelled => l10n.evCancelReasonEvent(
            e.cancelReason ?? '',
          ),
          CancelReason.declinedChange => l10n.evCancelReasonDeclined,
          CancelReason.deadlinePassed => l10n.evCancelReasonDeadline,
          _ => l10n.evCancelReasonMember,
        },
      ),
      ResStatus.reconfirmRequired => (
        l10n.evStatusReconfirm,
        BannerTone.pending,
        null,
      ),
      ResStatus.confirmed when attendance == Attendance.checkedIn => (
        l10n.evStatusCheckedIn,
        BannerTone.success,
        null,
      ),
      ResStatus.confirmed when attendance == Attendance.noShow => (
        l10n.evStatusNoShow,
        BannerTone.info,
        null,
      ),
      ResStatus.confirmed when phase == EvPhase.completed => (
        l10n.evStatusCompleted,
        BannerTone.info,
        null,
      ),
      _ => (l10n.evStatusConfirmed, BannerTone.success, null),
    };

    final canCancel = r.active && phase == EvPhase.upcoming;
    final metOpen = c.followUpOpen(eventId);
    final metEligible =
        attendance == Attendance.checkedIn && phase == EvPhase.completed;

    return NumayaScreen(
      top: top,
      footer: pending != null
          ? NumayaButton(
              key: const ValueKey('ev-open-change'),
              label: l10n.evStatusReconfirm,
              onPressed: () => context.push('${Routes.evNotice}/${pending.id}'),
            )
          : metEligible
          ? NumayaButton(
              key: const ValueKey('ev-open-met'),
              label: l10n.evPeopleMet,
              onPressed: () => context.push('${Routes.evMet}/$eventId'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          LabStatusBanner(
            key: const ValueKey('ev-res-status'),
            tone: tone,
            title: statusTitle,
            body: statusBody ?? l10n.evReference(r.reference),
          ),
          const SizedBox(height: AppSpacing.s3),
          EvCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EvFact(
                  icon: evIcon(e.category),
                  title: e.title,
                  body:
                      '${evDay(e.start)} · ${l10n.evTimes(evTime(e.start), evTime(e.end), e.timezone)}',
                ),
                EvFact(
                  icon: NumayaIcons.location,
                  title: e.venue.name,
                  body: '${e.venue.address}, ${e.city}',
                  extra: Wrap(
                    spacing: AppSpacing.s4,
                    children: [
                      TextLink(
                        label: l10n.evDirections,
                        onPressed: () =>
                            NumayaToast.show(context, l10n.evDirectionsDemo),
                      ),
                      if (r.active && phase == EvPhase.upcoming)
                        TextLink(
                          label: l10n.evAddCalendar,
                          onPressed: () =>
                              NumayaToast.show(context, l10n.evCalendarDemo),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (notices.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            ListGroup(
              title: l10n.evUpdates,
              children: [
                for (final n in notices)
                  ListRow(
                    key: ValueKey('ev-notice-${n.id}'),
                    leading: switch (n.kind) {
                      NoticeKind.material => NumayaIcons.alert,
                      NoticeKind.cancellation => NumayaIcons.eventBusy,
                      NoticeKind.ordinary => NumayaIcons.bell,
                    },
                    label: n.title,
                    detail: c.isSuperseded(n)
                        ? l10n.evNoticeSuperseded
                        : n.read
                        ? null
                        : l10n.evNoticeUnread,
                    onTap: () => context.push('${Routes.evNotice}/${n.id}'),
                  ),
              ],
            ),
          ],
          if (r.active || metEligible) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            ListGroup(
              footnote: l10n.evDiscoverableBody,
              children: [
                ListRow(
                  key: const ValueKey('ev-res-discoverable'),
                  label: l10n.evDiscoverableTitle,
                  switchValue: r.discoverable,
                  onSwitch: (v) => c.setDiscoverable(eventId, v),
                ),
                if (metEligible)
                  ListRow(
                    leadingMobile: NumayaMobileIcons.users,
                    label: l10n.evPeopleMet,
                    detail: metOpen
                        ? l10n.evPeopleMetDetail(
                            evDay(c.followUpEnds(eventId)!),
                          )
                        : l10n.evMetClosedTitle,
                    onTap: () => context.push('${Routes.evMet}/$eventId'),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          if (canCancel)
            NumayaButton(
              key: const ValueKey('ev-cancel'),
              label: l10n.evCancel,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => _cancel(context, ref),
            )
          else if (r.active && phase == EvPhase.started)
            Text(l10n.evCancelAfterStart, style: AppTypography.bodySm),
          const SizedBox(height: AppSpacing.s3),
          Center(
            child: TextLink(
              label: l10n.evReportSupport,
              muted: true,
              onPressed: () => showEvReport(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

/// S01 — Report or get help. Free; confidential; not an emergency service.
Future<void> showEvReport(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final types = [
    l10n.evReportTypeHelp,
    l10n.evReportTypeHost,
    l10n.evReportTypePerson,
    l10n.evReportTypeVenue,
  ];
  final ref0 = await showNumayaSheet<String>(
    context: context,
    title: l10n.evReportTitle,
    closeLabel: l10n.close,
    builder: (sheet) => _ReportForm(
      types: types,
      onSend: () =>
          Navigator.of(sheet)
              .pop(ref.read(eventsMvpProvider.notifier).submitReport()),
    ),
  );
  if (ref0 == null || !context.mounted) return;
  NumayaToast.show(
    context,
    '${l10n.evReportReceived(ref0)} ${l10n.evReportDemo}',
  );
}

class _ReportForm extends StatefulWidget {
  const _ReportForm({required this.types, required this.onSend});
  final List<String> types;
  final VoidCallback onSend;

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  int _type = 0;
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabStatusBanner(tone: BannerTone.error, title: l10n.evReportUrgent),
        const SizedBox(height: AppSpacing.s3),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (var i = 0; i < widget.types.length; i++)
              NumayaChip(
                label: widget.types[i],
                selected: _type == i,
                onTap: () => setState(() => _type = i),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaTextField(
          controller: _text,
          label: l10n.evReportDetails,
          multiline: true,
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          key: const ValueKey('ev-report-send'),
          label: l10n.evReportSend,
          onPressed: widget.onSend,
        ),
      ],
    );
  }
}
