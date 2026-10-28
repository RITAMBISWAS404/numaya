import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/domain/sample_people.dart';
import '../application/events_controller.dart';
import '../domain/event.dart';
import 'event_parts.dart';

/// Who's going (EV-07): the host first with a badge, then you, named attendees (first name and
/// initial only) and a count for the rest. The host also sees the waitlist and can remove someone
/// or move someone up when there is room. Attendees open the normal profile, where Report and
/// Block work as everywhere else.
class EventPeopleScreen extends ConsumerWidget {
  const EventPeopleScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(eventsProvider);
    final events = ref.read(eventsProvider.notifier);
    final e = events.byId(eventId);
    if (e == null) {
      return NumayaScreen(
        top: NumayaTopBar(onBack: () => context.pop(), backLabel: l10n.back),
        body: EmptyState(
          title: l10n.eventMissingTitle,
          body: l10n.eventMissingBody,
        ),
      );
    }
    final host = personById(e.hostId);
    final named = [
      for (final a in e.attendees)
        if (a != kMe) a,
    ];
    final youGoing = e.participation == Participation.going;
    final hostView = e.mine;

    Future<void> remove(String id, String name) async {
      final ok = await showNumayaSheet<bool>(
        context: context,
        title: l10n.eventRemoveTitle(name),
        closeLabel: l10n.close,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.eventRemoveBody, style: AppTypography.body),
            const SizedBox(height: AppSpacing.s5),
            NumayaButton(
              label: l10n.eventRemove,
              variant: NumayaButtonVariant.destructiveSolid,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              label: l10n.cancel,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      events.removeAttendee(eventId, id);
      NumayaToast.show(context, l10n.eventRemovedToast(name));
    }

    Widget person(String id, {String? detail}) {
      final p = personById(id);
      final name = p?.name ?? l10n.eventHostUnknown;
      return ListRow(
        avatar: InitialsAvatar(
          initial: p?.initial ?? '?',
          size: 36,
          verified: p?.verified ?? false,
        ),
        label: name,
        detail: detail,
        value: hostView ? l10n.eventRemove : null,
        onTap: hostView
            ? () => remove(id, name)
            : p == null
            ? null
            : () => context.push('${Routes.person}/${p.id}'),
      );
    }

    final others = e.othersGoing;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.eventWhoGoing,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Text(e.title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.s1),
          Text(eventGoing(l10n, e), style: AppTypography.caption),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            title: l10n.eventGoingHeading,
            footnote: hostView
                ? l10n.eventHostPeopleNote
                : l10n.eventPeopleNote,
            children: [
              ListRow(
                avatar: InitialsAvatar(
                  initial: e.mine ? l10n.eventYou[0] : (host?.initial ?? '?'),
                  size: 36,
                  verified: host?.verified ?? false,
                ),
                label: eventHostName(l10n, e),
                value: l10n.eventHostBadge,
                onTap: host == null
                    ? null
                    : () => context.push('${Routes.person}/${host.id}'),
              ),
              if (youGoing)
                ListRow(
                  avatar: InitialsAvatar(initial: l10n.eventYou[0], size: 36),
                  label: l10n.eventYou,
                  value: l10n.eventBadgeGoing,
                ),
              for (final id in named) person(id),
              if (others > 0) ListRow(label: l10n.eventAndMore(others)),
            ],
          ),
          if (e.waitlist.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s5),
            if (hostView)
              ListGroup(
                title: l10n.eventWaitlistHeading(e.waitlist.length),
                footnote: e.full
                    ? l10n.eventWaitlistFullNote
                    : l10n.eventWaitlistRoomNote,
                children: [
                  for (final (i, id) in e.waitlist.indexed)
                    ListRow(
                      avatar: InitialsAvatar(
                        initial: personById(id)?.initial ?? '?',
                        size: 36,
                      ),
                      label: personById(id)?.name ?? l10n.eventHostUnknown,
                      detail: l10n.eventWaitlistPlace(i + 1),
                      value: e.full ? null : l10n.eventMoveToGoing,
                      onTap: e.full
                          ? null
                          : () {
                              events.moveToGoing(eventId, id);
                              NumayaToast.show(
                                context,
                                l10n.eventMovedToast(
                                  personById(id)?.name ?? '',
                                ),
                              );
                            },
                    ),
                ],
              )
            else
              ListGroup(
                title: l10n.eventWaitlistHeading(e.waitlist.length),
                children: [
                  ListRow(
                    label: e.waitlistPosition == null
                        ? l10n.eventWaitingCount(e.waitlist.length)
                        : l10n.eventOnWaitlist(e.waitlistPosition!),
                  ),
                ],
              ),
          ],
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.eventsSampleNote,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
      ),
    );
  }
}
