import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/domain/sample_people.dart';
import '../domain/event.dart';

/// Cover colours (no photos in the demo): V16's photo grey and the three framing marks.
const List<Color> kEventTones = [
  AppColors.photo,
  AppColors.markYellow,
  AppColors.markLavender,
  AppColors.markPink,
];

NumayaIcons eventCategoryIcon(EventCategory c) => switch (c) {
  EventCategory.music => NumayaIcons.music,
  EventCategory.food => NumayaIcons.food,
  EventCategory.outdoors => NumayaIcons.park,
  EventCategory.sport => NumayaIcons.run,
  EventCategory.arts => NumayaIcons.palette,
  EventCategory.games => NumayaIcons.games,
};

String eventCategoryLabel(AppLocalizations l10n, EventCategory c) =>
    switch (c) {
      EventCategory.music => l10n.eventCatMusic,
      EventCategory.food => l10n.eventCatFood,
      EventCategory.outdoors => l10n.eventCatOutdoors,
      EventCategory.sport => l10n.eventCatSport,
      EventCategory.arts => l10n.eventCatArts,
      EventCategory.games => l10n.eventCatGames,
    };

/// "Wed 28 Oct"
String eventDay(DateTime d) => DateFormat('EEE d MMM').format(d);

/// "19:30"
String eventTime(DateTime d) => DateFormat('HH:mm').format(d);

/// "Wed 28 Oct · 19:30"
String eventWhen(DateTime d) => '${eventDay(d)} · ${eventTime(d)}';

/// The host's first name ("You" for the member).
String eventHostName(AppLocalizations l10n, DemoEvent e) => e.mine
    ? l10n.eventYou
    : (personById(e.hostId)?.name ?? l10n.eventHostUnknown);

/// The place line: venue and distance, or "Online".
String eventPlace(AppLocalizations l10n, DemoEvent e, String? area) {
  if (e.format == EventFormat.online) return l10n.eventOnline;
  final km = e.distanceFrom(area);
  return km == null ? e.venue : l10n.eventVenueDistance(e.venue, _km(km));
}

String _km(double km) =>
    km == km.roundToDouble() ? km.toStringAsFixed(0) : km.toStringAsFixed(1);

/// "12 going · 2 spots left"
String eventGoing(AppLocalizations l10n, DemoEvent e) {
  final going = l10n.eventGoingCount(e.goingCount);
  final left = e.spotsLeft;
  if (left == null) return going;
  if (left == 0) return '$going · ${l10n.eventFull}';
  return '$going · ${l10n.eventSpotsLeft(left)}';
}

/// The status badges an event carries at [now], most important first.
List<StatusBadge> eventBadges(
  AppLocalizations l10n,
  DemoEvent e,
  DateTime now, {
  BadgeTone tone = BadgeTone.onPhoto,
}) {
  final phase = e.phaseAt(now);
  final out = <StatusBadge>[];
  if (e.status == EventStatus.draft) {
    out.add(StatusBadge(label: l10n.eventBadgeDraft, tone: tone));
  } else if (e.status == EventStatus.cancelled) {
    out.add(
      StatusBadge(
        label: l10n.eventBadgeCancelled,
        icon: NumayaIcons.eventBusy,
        tone: tone,
      ),
    );
  } else if (phase == EventPhase.past) {
    out.add(StatusBadge(label: l10n.eventBadgePast, tone: tone));
  } else if (phase == EventPhase.live) {
    out.add(
      StatusBadge(
        label: l10n.eventBadgeLive,
        icon: NumayaIcons.clock,
        tone: tone,
      ),
    );
  }
  if (out.isEmpty) {
    switch (e.participation) {
      case Participation.going:
        out.add(
          StatusBadge(
            label: l10n.eventBadgeGoing,
            icon: NumayaIcons.check,
            tone: tone,
          ),
        );
      case Participation.waitlisted:
        out.add(StatusBadge(label: l10n.eventBadgeWaitlist, tone: tone));
      case Participation.none:
        if (e.mine) {
          out.add(StatusBadge(label: l10n.eventBadgeHosting, tone: tone));
        } else if (e.full) {
          out.add(StatusBadge(label: l10n.eventFull, tone: tone));
        } else if (!e.registrationOpenAt(now)) {
          out.add(StatusBadge(label: l10n.eventBadgeClosed, tone: tone));
        } else if (e.fewSpots) {
          out.add(StatusBadge(label: l10n.eventBadgeFewSpots, tone: tone));
        }
    }
  }
  if (e.changeNote != null &&
      e.status == EventStatus.published &&
      phase != EventPhase.past) {
    out.add(StatusBadge(label: l10n.eventBadgeChanged, tone: tone));
  }
  return out;
}

/// The cover band: the event's tone with its category mark, and badges on top.
class EventCover extends StatelessWidget {
  const EventCover({
    super.key,
    required this.event,
    required this.badges,
    this.height = 120,
    this.radius = AppRadii.card,
  });

  final DemoEvent event;
  final List<Widget> badges;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.all(radius),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: kEventTones[event.tone % kEventTones.length]),
            Center(
              child: ExcludeSemantics(
                child: NumayaIcon(
                  eventCategoryIcon(event.category),
                  size: height > 140 ? 56 : 40,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (badges.isNotEmpty)
              Positioned(
                left: AppSpacing.s3,
                top: AppSpacing.s3,
                right: AppSpacing.s3,
                child: Wrap(spacing: 6, runSpacing: 6, children: badges),
              ),
          ],
        ),
      ),
    );
  }
}

/// An event in a list (Meetup / Eventbrite card [O]): cover with status badges, title, when,
/// where, who's going, and a save button. [reason] is the "picked for you" rule, when there is one.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.now,
    required this.area,
    required this.saved,
    required this.onOpen,
    required this.onToggleSave,
    this.reason,
  });

  final DemoEvent event;
  final DateTime now;
  final String? area;
  final bool saved;
  final VoidCallback onOpen;
  final VoidCallback? onToggleSave;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final e = event;
    final badges = eventBadges(l10n, e, now);
    final when = eventWhen(e.start);
    final where = eventPlace(l10n, e, area);
    final going = eventGoing(l10n, e);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Stack(
        children: [
          Pressable(
            onTap: onOpen,
            pressedScale: 0.99,
            borderRadius: AppRadii.all(AppRadii.card),
            semanticLabel: [
              e.title,
              for (final b in badges) b.label,
              when,
              where,
              going,
              ?reason,
            ].join('. '),
            excludeChildSemantics: true,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EventCover(event: e, badges: badges),
                  const SizedBox(height: AppSpacing.s3),
                  // Text stays clear of the save button in the corner.
                  Padding(
                    padding: EdgeInsets.only(
                      right: onToggleSave == null ? 0 : AppSpacing.s8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          e.title,
                          style: AppTypography.weight(
                            AppTypography.sheetTitle,
                            AppTypography.semibold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s1),
                        _Line(icon: NumayaIcons.calendar, text: when),
                        _Line(
                          icon: e.format == EventFormat.online
                              ? NumayaIcons.public
                              : NumayaIcons.location,
                          text: where,
                        ),
                        _Line(icon: NumayaIcons.groups, text: going),
                        if (reason != null) ...[
                          const SizedBox(height: AppSpacing.s1),
                          Text(
                            l10n.eventPickedBecause(reason!),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textBrandDeep,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onToggleSave != null)
            Positioned(
              right: AppSpacing.s1,
              bottom: AppSpacing.s1,
              child: NavIconButton(
                icon: NumayaIcons.heart,
                label: saved
                    ? l10n.eventUnsave(e.title)
                    : l10n.eventSave(e.title),
                style: NavButtonStyle.plain,
                outline: !saved,
                onPressed: onToggleSave,
              ),
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final NumayaIcons icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: NumayaIcon(
              icon,
              size: AppSizes.iconSm,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
