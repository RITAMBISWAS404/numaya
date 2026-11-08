import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../lab/lab_banners.dart';
import '../application/events_mvp_controller.dart';
import '../domain/event_models.dart';
import '../domain/sample_events_mvp.dart';
import 'ev_parts.dart';

String proposalStatusLabel(AppLocalizations l10n, ProposalStatus s) =>
    switch (s) {
      ProposalStatus.draft => l10n.evProposalStatusDraft,
      ProposalStatus.submitted => l10n.evProposalStatusSubmitted,
      ProposalStatus.inReview => l10n.evProposalStatusInReview,
      ProposalStatus.needsChanges => l10n.evProposalStatusNeedsChanges,
      ProposalStatus.rejected => l10n.evProposalStatusRejected,
      ProposalStatus.withdrawn => l10n.evProposalStatusWithdrawn,
      ProposalStatus.published => l10n.evProposalStatusPublished,
    };

/// M02 — the member's own suggestions and their status (O1 OPEN: proposed reconciliation).
class ProposalsScreen extends ConsumerWidget {
  const ProposalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.events),
        backLabel: l10n.back,
        title: l10n.evProposalsTitle,
      ),
      footer: NumayaButton(
        key: const ValueKey('ev-propose-new'),
        label: l10n.evProposeRow,
        onPressed: () {
          final p = c.newProposal();
          c.saveProposal(p);
          context.push('${Routes.evPropose}/${p.id}');
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          LabStatusBanner(
            key: const ValueKey('ev-o1-banner'),
            tone: BannerTone.info,
            title: l10n.evProposeRow,
            body: l10n.evProposeIntro,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (s.proposals
              .where(
                (p) => p.status != ProposalStatus.draft || p.title.isNotEmpty,
              )
              .isEmpty)
            Text(l10n.evProposalsEmpty, style: AppTypography.bodySm)
          else
            ListGroup(
              footnote: l10n.evProposalNoDeadline,
              children: [
                for (final p in s.proposals)
                  if (p.status != ProposalStatus.draft || p.title.isNotEmpty)
                    ListRow(
                      key: ValueKey('ev-proposal-${p.id}'),
                      leading: evIcon(p.category),
                      label: p.title.isEmpty ? l10n.evProposeRow : p.title,
                      detail: [
                        proposalStatusLabel(l10n, p.status),
                        ?p.reviewNote,
                      ].join(' · '),
                      onTap: () => context.push('${Routes.evPropose}/${p.id}'),
                    ),
              ],
            ),
        ],
      ),
    );
  }
}

/// M01 — suggest an event. Validation: a name, a public venue (never a home), 20–30 places, a
/// date at least three days away. Submitting publishes nothing.
class ProposalFormScreen extends ConsumerStatefulWidget {
  const ProposalFormScreen({super.key, required this.proposalId});
  final String proposalId;

  @override
  ConsumerState<ProposalFormScreen> createState() => _ProposalFormScreenState();
}

class _ProposalFormScreenState extends ConsumerState<ProposalFormScreen> {
  late EvProposal _p;
  late final TextEditingController _title;
  late final TextEditingController _venue;
  late final TextEditingController _desc;
  List<String> _problems = const [];

  @override
  void initState() {
    super.initState();
    _p = ref
        .read(eventsMvpProvider)
        .proposals
        .firstWhere((x) => x.id == widget.proposalId);
    _title = TextEditingController(text: _p.title);
    _venue = TextEditingController(text: _p.venueName);
    _desc = TextEditingController(text: _p.description);
  }

  @override
  void dispose() {
    _title.dispose();
    _venue.dispose();
    _desc.dispose();
    super.dispose();
  }

  EvProposal get _current => _p.copyWith(
    title: _title.text,
    venueName: _venue.text,
    description: _desc.text,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = ref.read(eventsMvpProvider.notifier);
    final live = ref
        .watch(eventsMvpProvider)
        .proposals
        .where((x) => x.id == widget.proposalId)
        .firstOrNull;
    final editable =
        live != null &&
        (live.status == ProposalStatus.draft ||
            live.status == ProposalStatus.needsChanges);
    String? err(String k) => _problems.contains(k)
        ? switch (k) {
            'title' => l10n.evProposeErrTitle,
            'venue' => l10n.evProposeErrVenue,
            'privateHome' => l10n.evProposeErrHome,
            'capacity' => l10n.evProposeErrCapacity,
            _ => l10n.evProposeErrDate,
          }
        : null;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () {
          if (editable) c.saveProposal(_current);
          context.pop();
        },
        backLabel: l10n.back,
        title: l10n.evProposeTitle,
      ),
      footer: editable
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NumayaButton(
                  key: const ValueKey('ev-propose-submit'),
                  label: live.status == ProposalStatus.needsChanges
                      ? l10n.evProposalRevise
                      : l10n.evProposeSubmit,
                  onPressed: () {
                    final p = _current;
                    final problems = c.proposalProblems(p);
                    setState(() => _problems = problems);
                    if (problems.isEmpty && c.submitProposal(p)) context.pop();
                  },
                ),
                const SizedBox(height: AppSpacing.s2),
                NumayaButton(
                  label: l10n.evProposeSaveDraft,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () {
                    c.saveProposal(_current);
                    context.pop();
                  },
                ),
              ],
            )
          : live != null &&
                live.status != ProposalStatus.withdrawn &&
                live.status != ProposalStatus.rejected &&
                live.status != ProposalStatus.published
          ? NumayaButton(
              key: const ValueKey('ev-propose-withdraw'),
              label: l10n.evProposalWithdraw,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => c.withdrawProposal(widget.proposalId),
            )
          : live?.publishedEventId != null
          ? NumayaButton(
              label: l10n.evProposalViewEvent,
              onPressed: () =>
                  context.push('${Routes.evEvent}/${live!.publishedEventId}'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          LabStatusBanner(tone: BannerTone.info, title: l10n.evProposeIntro),
          if (live != null && live.status != ProposalStatus.draft) ...[
            const SizedBox(height: AppSpacing.s3),
            LabStatusBanner(
              key: const ValueKey('ev-proposal-status'),
              tone: live.status == ProposalStatus.needsChanges
                  ? BannerTone.pending
                  : BannerTone.info,
              title: proposalStatusLabel(l10n, live.status),
              body: live.reviewNote,
            ),
          ],
          const SizedBox(height: AppSpacing.s4),
          NumayaTextField(
            key: const ValueKey('ev-propose-name'),
            controller: _title,
            label: l10n.evProposeName,
            enabled: editable,
            error: err('title'),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(l10n.evProposeCategory, style: AppTypography.fieldLabel),
          const SizedBox(height: AppSpacing.s2),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              for (final cat in EvCategory.values)
                NumayaChip(
                  label: evCategoryLabel(l10n, cat),
                  selected: _p.category == cat,
                  onTap: editable
                      ? () => setState(() => _p = _p.copyWith(category: cat))
                      : () {},
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(l10n.evProposeCity, style: AppTypography.fieldLabel),
          const SizedBox(height: AppSpacing.s2),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              for (final city in kEvCities)
                NumayaChip(
                  label: city,
                  selected: _p.city == city,
                  onTap: editable
                      ? () => setState(() => _p = _p.copyWith(city: city))
                      : () {},
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaTextField(
            key: const ValueKey('ev-propose-venue'),
            controller: _venue,
            label: l10n.evProposeVenue,
            enabled: editable,
            error: err('venue') ?? err('privateHome'),
          ),
          ListGroup(
            children: [
              ListRow(
                key: const ValueKey('ev-propose-home'),
                label: l10n.evProposePrivateHome,
                switchValue: _p.privateHome,
                onSwitch: editable
                    ? (v) => setState(() => _p = _p.copyWith(privateHome: v))
                    : null,
              ),
              ListRow(label: l10n.evProposeCapacity, value: '${_p.capacity}'),
              ListRow(label: l10n.evProposeDate, value: evWhen(l10n, _p.start)),
            ],
          ),
          if (err('capacity') != null || err('date') != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s2),
              child: FieldNote(
                (err('capacity') ?? err('date'))!,
                tone: FieldNoteTone.error,
              ),
            ),
          const SizedBox(height: AppSpacing.s3),
          NumayaTextField(
            controller: _desc,
            label: l10n.evProposeDescription,
            enabled: editable,
            multiline: true,
          ),
        ],
      ),
    );
  }
}

/// H — internal tools, demo role. Isolated from attendee navigation (Demo Hub only) and labelled
/// as not real authorization.
class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(eventsMvpProvider);
    final now = ref.read(clockProvider)();
    final queue = s.proposals
        .where(
          (p) =>
              p.status == ProposalStatus.submitted ||
              p.status == ProposalStatus.inReview,
        )
        .toList();
    final published =
        s.events.values
            .where(
              (e) =>
                  e.lifecycle == EvLifecycle.published &&
                  e.phaseAt(now) != EvPhase.completed,
            )
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.demo),
        backLabel: l10n.back,
        title: l10n.evStaffTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          LabStatusBanner(
            key: const ValueKey('ev-staff-banner'),
            tone: BannerTone.error,
            title: l10n.evStaffBanner,
            body: l10n.evStaffBannerBody,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.evStaffQueue,
            children: [
              if (queue.isEmpty) ListRow(label: l10n.evProposalsEmpty),
              for (final p in queue)
                ListRow(
                  key: ValueKey('ev-staff-p-${p.id}'),
                  leading: evIcon(p.category),
                  label: p.title,
                  detail: '${p.city} · ${proposalStatusLabel(l10n, p.status)}',
                  onTap: () => context.push('${Routes.staffProposal}/${p.id}'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.evStaffEvents,
            children: [
              for (final e in published)
                ListRow(
                  key: ValueKey('ev-staff-e-${e.id}'),
                  leading: evIcon(e.category),
                  label: e.title,
                  detail: '${e.city} · ${evWhen(l10n, e.start)}',
                  onTap: () => context.push('${Routes.staffEvent}/${e.id}'),
                ),
            ],
          ),
          if (s.audit.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            ListGroup(
              title: l10n.evStaffAudit,
              children: [
                for (final a in s.audit.reversed.take(8)) ListRow(label: a),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// H01/H02 — review a proposal: preview, named staffing, publish / return / reject.
class StaffProposalScreen extends ConsumerStatefulWidget {
  const StaffProposalScreen({super.key, required this.proposalId});
  final String proposalId;

  @override
  ConsumerState<StaffProposalScreen> createState() =>
      _StaffProposalScreenState();
}

class _StaffProposalScreenState extends ConsumerState<StaffProposalScreen> {
  final _host = TextEditingController(text: 'Sample host A');
  final _reviewer = TextEditingController(text: 'Sample reviewer B');
  final _note = TextEditingController();
  bool _missingStaff = false;

  @override
  void dispose() {
    _host.dispose();
    _reviewer.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final p = s.proposals.where((x) => x.id == widget.proposalId).firstOrNull;
    final top = NumayaTopBar(
      onBack: () => context.pop(),
      backLabel: l10n.back,
      title: l10n.evStaffReview,
    );
    if (p == null) return NumayaScreen(top: top, body: const SizedBox.shrink());
    return NumayaScreen(
      top: top,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NumayaButton(
            key: const ValueKey('ev-staff-publish'),
            label: l10n.evStaffPublish,
            onPressed: p.status == ProposalStatus.published
                ? null
                : () {
                    final id = c.publishProposal(
                      p.id,
                      host: _host.text,
                      reviewer: _reviewer.text,
                    );
                    setState(() => _missingStaff = id == null);
                  },
          ),
          const SizedBox(height: AppSpacing.s2),
          Row(
            children: [
              Expanded(
                child: NumayaButton(
                  key: const ValueKey('ev-staff-return'),
                  label: l10n.evStaffReturn,
                  small: true,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () => c.returnProposal(
                    p.id,
                    _note.text.isEmpty ? 'Please add more detail.' : _note.text,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: NumayaButton(
                  label: l10n.evStaffReject,
                  small: true,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () => c.rejectProposal(
                    p.id,
                    _note.text.isEmpty
                        ? 'Not suitable for the pilot.'
                        : _note.text,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          LabStatusBanner(tone: BannerTone.error, title: l10n.evStaffBanner),
          const SizedBox(height: AppSpacing.s3),
          LabStatusBanner(
            tone: BannerTone.info,
            title: proposalStatusLabel(l10n, p.status),
            body: p.reviewNote,
          ),
          const SizedBox(height: AppSpacing.s3),
          EvCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EvFact(
                  icon: evIcon(p.category),
                  title: p.title,
                  body: p.description,
                ),
                EvFact(
                  icon: NumayaIcons.location,
                  title: p.venueName,
                  body: '${p.city} · ${evWhen(l10n, p.start)} · ${p.capacity}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaTextField(controller: _host, label: l10n.evStaffHost),
          const SizedBox(height: AppSpacing.s3),
          NumayaTextField(controller: _reviewer, label: l10n.evStaffReviewer),
          if (_missingStaff)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s2),
              child: FieldNote(
                l10n.evStaffStaffingNeeded,
                tone: FieldNoteTone.error,
              ),
            ),
          const SizedBox(height: AppSpacing.s3),
          NumayaTextField(
            controller: _note,
            label: l10n.evStaffReturn,
            multiline: true,
          ),
        ],
      ),
    );
  }
}

/// H03/H04 — attendees and check-in; announce, change time/venue (with impact and deadline
/// validation) and cancel. Minimum identity only: first name and initial.
class StaffEventScreen extends ConsumerStatefulWidget {
  const StaffEventScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<StaffEventScreen> createState() => _StaffEventScreenState();
}

class _StaffEventScreenState extends ConsumerState<StaffEventScreen> {
  final _msg = TextEditingController();
  final _venue = TextEditingController();
  final _reason = TextEditingController();
  int _laterHours = 2;
  String? _changeError;

  @override
  void dispose() {
    _msg.dispose();
    _venue.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final e = s.events[widget.eventId];
    final top = NumayaTopBar(
      onBack: () => context.pop(),
      backLabel: l10n.back,
      title: e?.title ?? l10n.evStaffEvents,
    );
    if (e == null) return NumayaScreen(top: top, body: const SizedBox.shrink());
    final staff = s.staffAttendance[e.id] ?? const <String, Attendance>{};
    final memberRes = s.reservations[e.id];
    final affected = c.reserved(e.id);
    Widget attendRow(String name, Attendance a, ValueChanged<Attendance> set) =>
        ListRow(
          key: ValueKey('ev-staff-att-$name'),
          label: name,
          detail: switch (a) {
            Attendance.checkedIn => l10n.evStatusCheckedIn,
            Attendance.noShow => l10n.evStatusNoShow,
            Attendance.notRecorded => l10n.evStatusConfirmed,
          },
          onTap: () => set(
            a == Attendance.checkedIn
                ? Attendance.notRecorded
                : Attendance.checkedIn,
          ),
        );
    return NumayaScreen(
      top: top,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          LabStatusBanner(tone: BannerTone.error, title: l10n.evStaffBanner),
          const SizedBox(height: AppSpacing.s3),
          Text(
            '${evWhen(l10n, e.start)} · ${e.venue.name} · v${e.version}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.evStaffAttendees,
            footnote: l10n.evStaffImpact(affected),
            children: [
              if (memberRes != null && memberRes.active)
                attendRow(
                  l10n.evStaffMember,
                  c.attendanceOf(e.id),
                  (a) => c.setMemberAttendance(e.id, a),
                ),
              for (final MapEntry(key: n, value: a) in staff.entries.take(6))
                attendRow(n, a, (v) => c.setStaffAttendance(e.id, n, v)),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text(l10n.evStaffAnnounce, style: AppTypography.section),
          const SizedBox(height: AppSpacing.s2),
          NumayaTextField(
            controller: _msg,
            label: l10n.evStaffAnnouncementText,
            multiline: true,
          ),
          const SizedBox(height: AppSpacing.s2),
          NumayaButton(
            key: const ValueKey('ev-staff-announce'),
            label: l10n.evStaffAnnounce,
            small: true,
            variant: NumayaButtonVariant.secondary,
            onPressed: () {
              if (_msg.text.trim().isEmpty) return;
              c.announce(e.id, l10n.evUpdates, _msg.text.trim());
              _msg.clear();
              NumayaToast.show(context, l10n.evStaffSent);
            },
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text(l10n.evStaffChange, style: AppTypography.section),
          const SizedBox(height: AppSpacing.s2),
          Text(l10n.evStaffMinutesLater, style: AppTypography.fieldLabel),
          const SizedBox(height: AppSpacing.s2),
          Wrap(
            spacing: AppSpacing.s2,
            children: [
              for (final h in [1, 2, 24])
                NumayaChip(
                  label: '+${h}h',
                  selected: _laterHours == h,
                  onTap: () => setState(() => _laterHours = h),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          NumayaTextField(controller: _venue, label: l10n.evStaffNewVenue),
          const SizedBox(height: AppSpacing.s2),
          NumayaTextField(controller: _reason, label: l10n.evStaffCancelReason),
          if (_changeError != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s2),
              child: FieldNote(_changeError!, tone: FieldNoteTone.error),
            ),
          const SizedBox(height: AppSpacing.s2),
          NumayaButton(
            key: const ValueKey('ev-staff-change'),
            label: l10n.evStaffChange,
            small: true,
            variant: NumayaButtonVariant.secondary,
            onPressed: () {
              final ok = c.applyMaterialChange(
                e.id,
                newStart: e.start.add(Duration(hours: _laterHours)),
                venueName: _venue.text.trim().isEmpty
                    ? e.venue.name
                    : _venue.text.trim(),
                reason: _reason.text.trim().isEmpty
                    ? 'The schedule changed.'
                    : _reason.text.trim(),
              );
              setState(() => _changeError = ok ? null : l10n.evStaffTooLate);
              if (ok) NumayaToast.show(context, l10n.evStaffChangeApplied);
            },
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          NumayaButton(
            key: const ValueKey('ev-staff-cancel'),
            label: l10n.evStaffCancelEvent,
            variant: NumayaButtonVariant.secondary,
            onPressed: e.lifecycle == EvLifecycle.cancelled
                ? null
                : () => c.cancelEvent(
                    e.id,
                    _reason.text.trim().isEmpty
                        ? 'Numaya had to cancel this event.'
                        : _reason.text.trim(),
                  ),
          ),
        ],
      ),
    );
  }
}
