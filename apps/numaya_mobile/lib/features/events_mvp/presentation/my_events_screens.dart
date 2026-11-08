import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';
import '../../dating/domain/sample_people.dart';
import '../../dating/presentation/person_profile.dart';
import '../../lab/lab_banners.dart';
import '../../lab/lab_empty_state.dart';
import '../../lab/lab_registry.dart';
import '../application/events_mvp_controller.dart';
import '../domain/event_models.dart';
import 'ev_parts.dart';

/// E04 — My events: upcoming, past and cancelled reservations; outstanding changes first;
/// People I met when available. Proposals never appear here.
class MyEventsScreen extends ConsumerStatefulWidget {
  const MyEventsScreen({super.key});

  @override
  ConsumerState<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends ConsumerState<MyEventsScreen> {
  int _view = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final now = ref.read(clockProvider)();
    final all = c.myEvents();
    final upcoming = [
      for (final m in all)
        if (m.$2.active && m.$1.phaseAt(now) != EvPhase.completed) m,
    ];
    final past = [
      for (final m in all)
        if (m.$2.active && m.$1.phaseAt(now) == EvPhase.completed) m,
    ]..sort((a, b) => b.$1.start.compareTo(a.$1.start));
    final cancelled = [
      for (final m in all)
        if (!m.$2.active) m,
    ];
    final lists = [upcoming, past, cancelled];
    final rows = lists[_view];
    final attention = [
      for (final m in all)
        if (m.$2.status == ResStatus.reconfirmRequired) m,
    ];

    String detail(NumayaEvent e, Reservation r) {
      final when = evWhen(l10n, e.start);
      if (r.status == ResStatus.reconfirmRequired) {
        return '$when · ${l10n.evReconfirmNeeded}';
      }
      if (!r.active) return '$when · ${l10n.evStatusCancelled}';
      final a = c.attendanceOf(e.id);
      if (e.phaseAt(now) == EvPhase.completed) {
        if (a == Attendance.checkedIn && c.followUpOpen(e.id)) {
          return '$when · ${l10n.evPeopleMetDetail(evDay(c.followUpEnds(e.id)!))}';
        }
        return '$when · ${a == Attendance.checkedIn ? l10n.evStatusCheckedIn : l10n.evStatusNoShow}';
      }
      return '$when · ${l10n.evStatusConfirmed}';
    }

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.events),
        backLabel: l10n.back,
        title: l10n.evMyEvents,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          for (final m in attention) ...[
            LabStatusBanner(
              key: ValueKey('ev-attention-${m.$1.id}'),
              tone: BannerTone.pending,
              title: '${m.$1.title}: ${l10n.evReconfirmNeeded}',
              body: l10n.evNoticesWaiting(1),
              onTap: () => context.push('${Routes.evReservation}/${m.$1.id}'),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          ViewTabs(
            label: l10n.evMyEvents,
            bleed: AppLayout.screenGutter,
            selected: _view,
            onSelect: (i) => setState(() => _view = i),
            keys: const [
              ValueKey('ev-mine-upcoming'),
              ValueKey('ev-mine-past'),
              ValueKey('ev-mine-cancelled'),
            ],
            options: [
              (label: l10n.evMyUpcoming, count: upcoming.length),
              (label: l10n.evMyPast, count: past.length),
              (label: l10n.evMyCancelled, count: cancelled.length),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          if (rows.isEmpty)
            LabEmptyState(
              slot: 'events_mine_empty',
              slotLabel: 'purple cat with a calendar',
              icon: NumayaMobileIcons.chart,
              title: l10n.evMyEmptyTitle,
              body: l10n.evMyEmptyBody,
              actionLabel: l10n.evBrowse,
              onAction: () => context.go(Routes.events),
            )
          else
            ListGroup(
              children: [
                for (final (e, r) in rows)
                  ListRow(
                    key: ValueKey('ev-mine-${e.id}'),
                    leading: evIcon(e.category),
                    label: e.title,
                    detail: detail(e, r),
                    onTap: () =>
                        context.push('${Routes.evReservation}/${e.id}'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// E06 — Announcement or change. Material changes show before/now, the reason and a deadline;
/// only the latest version can be reconfirmed. A read receipt is never agreement.
class EventNoticeScreen extends ConsumerStatefulWidget {
  const EventNoticeScreen({super.key, required this.noticeId});
  final String noticeId;

  @override
  ConsumerState<EventNoticeScreen> createState() => _EventNoticeScreenState();
}

class _EventNoticeScreenState extends ConsumerState<EventNoticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(eventsMvpProvider.notifier).markRead(widget.noticeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = ref.watch(eventsMvpProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final now = ref.read(clockProvider)();
    final n = s.notices.where((x) => x.id == widget.noticeId).firstOrNull;
    final top = NumayaTopBar(
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.evMine),
      backLabel: l10n.back,
      title: l10n.evUpdates,
    );
    if (n == null) {
      return NumayaScreen(
        top: top,
        body: EmptyState(title: l10n.evNotFound, body: ''),
      );
    }
    final e = c.event(n.eventId)!;
    final r = c.effectiveReservation(n.eventId);
    final superseded = c.isSuperseded(n);
    final expired = n.deadline != null && !now.isBefore(n.deadline!);
    final awaiting =
        n.kind == NoticeKind.material &&
        !superseded &&
        !expired &&
        r?.status == ResStatus.reconfirmRequired;

    final Widget? footer;
    if (awaiting) {
      footer = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NumayaButton(
            key: const ValueKey('ev-reconfirm'),
            label: l10n.evNoticeReconfirm,
            onPressed: () {
              if (c.reconfirm(n.id)) {
                NumayaToast.show(context, l10n.evNoticeReconfirmed);
              }
            },
          ),
          const SizedBox(height: AppSpacing.s2),
          NumayaButton(
            key: const ValueKey('ev-decline'),
            label: l10n.evNoticeDecline,
            variant: NumayaButtonVariant.secondary,
            onPressed: () {
              if (c.decline(n.id)) {
                NumayaToast.show(context, l10n.evNoticeDeclined);
              }
            },
          ),
        ],
      );
    } else if (n.kind == NoticeKind.ordinary &&
        n.response == NoticeResponse.none) {
      footer = NumayaButton(
        key: const ValueKey('ev-ack-notice'),
        label: l10n.evNoticeAck,
        onPressed: () => c.acknowledge(n.id),
      );
    } else {
      footer = NumayaButton(
        label: l10n.evViewReservation,
        variant: NumayaButtonVariant.secondary,
        onPressed: () => context.push('${Routes.evReservation}/${n.eventId}'),
      );
    }

    final outcome = switch (n.response) {
      NoticeResponse.reconfirmed => l10n.evNoticeReconfirmed,
      NoticeResponse.declined => l10n.evNoticeDeclined,
      NoticeResponse.acknowledged => l10n.evNoticeAcknowledged,
      NoticeResponse.none => null,
    };

    return NumayaScreen(
      top: top,
      footer: footer,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          Text(e.title, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.s1),
          Semantics(
            header: true,
            child: Text(n.title, style: AppTypography.pageTitle),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            '${l10n.evNoticeFrom(n.sender)} · ${evWhen(l10n, n.sentAt)}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(n.body, style: AppTypography.body),
          if (n.before != null && n.after != null) ...[
            const SizedBox(height: AppSpacing.s4),
            EvCardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EvFact(
                    icon: NumayaIcons.undo,
                    title: l10n.evNoticeBefore,
                    body: n.before!,
                  ),
                  EvFact(
                    icon: NumayaIcons.arrowRight,
                    title: l10n.evNoticeAfter,
                    body: n.after!,
                  ),
                ],
              ),
            ),
          ],
          if (n.deadline != null && awaiting) ...[
            const SizedBox(height: AppSpacing.s3),
            LabStatusBanner(
              tone: BannerTone.pending,
              title: l10n.evNoticeDeadline(evWhen(l10n, n.deadline!)),
            ),
          ],
          if (superseded) ...[
            const SizedBox(height: AppSpacing.s3),
            LabStatusBanner(
              tone: BannerTone.info,
              title: l10n.evNoticeSuperseded,
            ),
          ] else if (expired && n.kind == NoticeKind.material) ...[
            const SizedBox(height: AppSpacing.s3),
            LabStatusBanner(tone: BannerTone.info, title: l10n.evNoticeExpired),
          ],
          if (outcome != null) ...[
            const SizedBox(height: AppSpacing.s3),
            LabStatusBanner(tone: BannerTone.success, title: outcome),
          ],
          if (n.pushFailed) ...[
            const SizedBox(height: AppSpacing.s3),
            Text(l10n.evNoticePushFailed, style: AppTypography.caption),
          ],
        ],
      ),
    );
  }
}

/// E07 — People I met. Checked-in, opted-in, preference-compatible people only; three private
/// interests; seven days; one-sided interest is never shown to anyone. E08 on a mutual result.
class PeopleMetScreen extends ConsumerWidget {
  const PeopleMetScreen({super.key, required this.eventId});
  final String eventId;

  Future<void> _interested(
    BuildContext context,
    WidgetRef ref,
    SamplePerson p,
  ) async {
    final l10n = context.l10n;
    final c = ref.read(eventsMvpProvider.notifier);
    final res = c.sendInterest(eventId, p.id);
    switch (res) {
      case InterestResult.mutual:
        await showMutualSheet(
          context,
          person: p,
          eventTitle: c.event(eventId)!.title,
          result: c.connectionWith(eventId, p.id)!,
        );
      case InterestResult.exhausted:
        NumayaToast.show(context, l10n.evMetExhausted);
      case InterestResult.sent || InterestResult.duplicate:
        NumayaToast.show(context, l10n.evMetSent);
      case InterestResult.closed || InterestResult.notEligible:
        NumayaToast.show(context, l10n.evMetClosedTitle);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(eventsMvpProvider);
    ref.watch(datingProvider);
    final c = ref.read(eventsMvpProvider.notifier);
    final now = ref.read(clockProvider)();
    final e = c.event(eventId);
    final r = c.effectiveReservation(eventId);
    final top = NumayaTopBar(
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.evMine),
      backLabel: l10n.back,
      title: l10n.evMetTitle,
    );
    if (e == null || r == null) {
      return NumayaScreen(
        top: top,
        body: EmptyState(title: l10n.evNotFound, body: ''),
      );
    }
    final attended =
        c.attendanceOf(eventId) == Attendance.checkedIn &&
        e.phaseAt(now) == EvPhase.completed;
    final open = c.followUpOpen(eventId);
    final windowOpen = attended && EvPolicy.followUpOpen(e, now);

    Widget body;
    if (!attended) {
      body = LabStatusBanner(
        key: const ValueKey('ev-met-not-attended'),
        tone: BannerTone.info,
        title: l10n.evMetNotAttendedTitle,
        body: l10n.evMetNotAttendedBody,
      );
    } else if (!windowOpen) {
      body = LabStatusBanner(
        key: const ValueKey('ev-met-closed'),
        tone: BannerTone.info,
        title: l10n.evMetClosedTitle,
        body: l10n.evMetClosedBody,
      );
    } else if (!r.discoverable) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabStatusBanner(
            key: const ValueKey('ev-met-not-opted'),
            tone: BannerTone.info,
            title: l10n.evMetNotOptedTitle,
            body: l10n.evMetNotOptedBody,
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            key: const ValueKey('ev-met-opt-in'),
            label: l10n.evMetTurnOn,
            onPressed: () => c.setDiscoverable(eventId, true),
          ),
        ],
      );
    } else {
      final peers = c.peers(eventId);
      final sent = s.interests[eventId] ?? const <String>{};
      final passed = s.passes[eventId] ?? const <String>{};
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.evMetIntro, style: AppTypography.bodySm),
          const SizedBox(height: AppSpacing.s2),
          Wrap(
            spacing: AppSpacing.s2,
            children: [
              EvStatusBadge(
                label: l10n.evMetLeft(c.interestsLeft(eventId)),
                brand: true,
              ),
              EvStatusBadge(
                label: l10n.evMetEnds(evWhen(l10n, c.followUpEnds(eventId)!)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          if (peers.isEmpty)
            LabEmptyState(
              slot: 'events_met_empty',
              slotLabel: 'purple cat waving goodbye',
              icon: NumayaMobileIcons.users,
              title: l10n.evMetEmptyTitle,
              body: l10n.evMetEmptyBody,
            )
          else
            for (final p in peers) ...[
              PeerCard(
                key: ValueKey('ev-peer-${p.id}'),
                person: p,
                sent: sent.contains(p.id),
                passed: passed.contains(p.id),
                canSend: open && c.interestsLeft(eventId) > 0,
                onInterested: () => _interested(context, ref, p),
                onPass: () => c.pass(eventId, p.id),
                onProfile: () => context.push('${Routes.person}/${p.id}'),
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
          const SizedBox(height: AppSpacing.s3),
          Center(
            child: TextLink(
              key: const ValueKey('ev-met-withdraw'),
              label: l10n.evMetWithdraw,
              muted: true,
              onPressed: () {
                c.setDiscoverable(eventId, false);
                NumayaToast.show(context, l10n.evMetWithdrawNote);
              },
            ),
          ),
        ],
      );
    }

    return NumayaScreen(
      top: top,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          Text(e.title, style: AppTypography.section),
          Text(evWhen(l10n, e.start), style: AppTypography.caption),
          const SizedBox(height: AppSpacing.s4),
          body,
        ],
      ),
    );
  }
}

/// One person at People I met. Lab group `ea-met-card` (Ente alignment V3): O is the approved row
/// with paired buttons; A and B are alternatives for owner selection. Every variant keeps the
/// same private actions and states (sent, passed, allowance used).
class PeerCard extends ConsumerWidget {
  const PeerCard({
    super.key,
    required this.person,
    required this.sent,
    required this.passed,
    required this.canSend,
    required this.onInterested,
    required this.onPass,
    required this.onProfile,
    this.variant,
  });

  final SamplePerson person;
  final bool sent;
  final bool passed;
  final bool canSend;
  final VoidCallback onInterested;
  final VoidCallback onPass;
  final VoidCallback onProfile;

  /// Forces a variant (Visual Lab previews); otherwise the registry decides.
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('ea-met-card'));
    return switch (v) {
      'A' => _photo(context),
      'B' => _compact(context),
      _ => _original(context),
    };
  }

  BoxDecoration get _box => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadii.all(AppRadii.card),
  );

  Widget _name(BuildContext context) => NameWithBadge(
    name: context.l10n.profileNameAge(person.name, person.age),
    verified: person.verified,
    verifiedLabel: context.l10n.photoVerifiedLabel,
    style: AppTypography.card,
  );

  /// Sent, passed, or the two peer actions at equal width (EA-B01).
  Widget _actions(BuildContext context) {
    final l10n = context.l10n;
    if (sent) return Text(l10n.evMetSent, style: AppTypography.bodySm);
    if (passed) return Text(l10n.evMetPassed, style: AppTypography.bodySm);
    return NumayaButtonGroup(
      children: [
        NumayaButton(
          key: ValueKey('ev-pass-${person.id}'),
          label: l10n.evMetPass,
          small: true,
          expand: true,
          variant: NumayaButtonVariant.secondary,
          onPressed: onPass,
        ),
        NumayaButton(
          key: ValueKey('ev-interested-${person.id}'),
          label: l10n.evMetInterested,
          small: true,
          expand: true,
          onPressed: canSend ? onInterested : null,
        ),
      ],
    );
  }

  Widget _original(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: _box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Pressable(
            onTap: onProfile,
            semanticLabel: l10n.viewProfile(person.name),
            excludeChildSemantics: true,
            pressedScale: 1,
            child: Row(
              children: [
                InitialsAvatar(
                  initial: person.initial,
                  size: 56,
                  image: personAvatarImage(person),
                  imageAlignment: personAvatarFocus(person),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(child: _name(context)),
                const NumayaIcon(
                  NumayaIcons.chevronRight,
                  size: 18,
                  color: AppColors.iconSupporting,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          _actions(context),
        ],
      ),
    );
  }

  /// A: photo card (imagery). A large photo leads, as on Discover; the name sits under it.
  Widget _photo(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: _box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Pressable(
            onTap: onProfile,
            semanticLabel: l10n.viewProfile(person.name),
            excludeChildSemantics: true,
            pressedScale: 0.99,
            borderRadius: AppRadii.all(AppRadii.card - AppSpacing.s2),
            child: ClipRRect(
              // Concentric: 20 card radius minus the 8 inset.
              borderRadius: AppRadii.all(AppRadii.card - AppSpacing.s2),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: ColoredBox(
                  color: AppColors.fill,
                  child: personPhotoImage(person, 1) ?? const SizedBox(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s2,
              AppSpacing.s3,
              AppSpacing.s2,
              AppSpacing.s2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _name(context),
                const SizedBox(height: AppSpacing.s3),
                _actions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// B: compact row (density). Photo, name, then two labelled round actions on the right
  /// (Ente's compact contextual actions); the state replaces them once decided.
  Widget _compact(BuildContext context) {
    final l10n = context.l10n;
    final Widget trailing;
    if (sent || passed) {
      trailing = Text(
        sent ? l10n.evMetSent : l10n.evMetPassed,
        style: AppTypography.caption,
      );
    } else {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SquircleIconButton(
            key: ValueKey('ev-pass-${person.id}'),
            icon: NumayaIcons.close,
            label: l10n.evMetPass,
            elevated: false,
            onPressed: onPass,
          ),
          const SizedBox(width: AppSpacing.s2),
          SquircleIconButton(
            key: ValueKey('ev-interested-${person.id}'),
            icon: NumayaIcons.heart,
            label: l10n.evMetInterested,
            onBrand: true,
            elevated: false,
            onPressed: canSend ? onInterested : null,
          ),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.cardPadding,
        vertical: AppSpacing.s3,
      ),
      decoration: _box,
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              onTap: onProfile,
              semanticLabel: l10n.viewProfile(person.name),
              excludeChildSemantics: true,
              pressedScale: 1,
              child: Row(
                children: [
                  InitialsAvatar(
                    initial: person.initial,
                    size: 48,
                    image: personAvatarImage(person),
                    imageAlignment: personAvatarFocus(person),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(child: _name(context)),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s2),
          Flexible(child: trailing),
        ],
      ),
    );
  }
}

/// E08 — Mutual connection result. Reuses existing chat rules; never promises a date.
Future<void> showMutualSheet(
  BuildContext context, {
  required SamplePerson person,
  required String eventTitle,
  required EventConnection result,
}) {
  final l10n = context.l10n;
  final line = switch (result) {
    EventConnection.created => l10n.evMutualNew,
    EventConnection.existing => l10n.evMutualExisting(person.name),
    EventConnection.existingArchived => l10n.evMutualArchived(person.name),
    EventConnection.existingEnded => l10n.evMutualEnded(person.name),
    EventConnection.restricted => l10n.evMutualRestricted,
  };
  final canChat =
      result == EventConnection.created ||
      result == EventConnection.existing ||
      result == EventConnection.existingArchived;
  return showNumayaSheet<void>(
    context: context,
    title: l10n.evMutualTitle,
    closeLabel: l10n.close,
    builder: (sheet) => Column(
      key: const ValueKey('ev-mutual'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.evMutualBody(person.name, eventTitle),
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          line,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s5),
        if (canChat)
          NumayaButton(
            key: const ValueKey('ev-mutual-chat'),
            label: l10n.evOpenChat,
            onPressed: () {
              Navigator.of(sheet).pop();
              context.push('${Routes.chat}/${person.id}');
            },
          ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.evLater,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => Navigator.of(sheet).pop(),
        ),
      ],
    ),
  );
}
