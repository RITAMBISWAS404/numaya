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

/// The event's cover at 16:9 ([AppMedia.eventCover]): its tone with the category mark, status
/// badges top left and an optional [action] top right. [radius] is 0 inside a card, which clips
/// it flush to its own corners (docs/mobile/UI_REFINEMENT_DECISIONS.md, RD-13).
class EventCover extends StatelessWidget {
  const EventCover({
    super.key,
    required this.event,
    required this.badges,
    this.radius = AppRadii.card,
    this.action,
  });

  final DemoEvent event;
  final List<Widget> badges;
  final double radius;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.all(radius),
      child: AspectRatio(
        aspectRatio: AppMedia.eventCover,
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: kEventTones[event.tone % kEventTones.length]),
              Center(
                child: ExcludeSemantics(
                  child: NumayaIcon(
                    eventCategoryIcon(event.category),
                    size: box.maxWidth > 360 ? 56 : 44,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (badges.isNotEmpty)
                Positioned(
                  left: AppSpacing.s3,
                  top: AppSpacing.s3,
                  // Clear of the action in the other corner.
                  right: action == null
                      ? AppSpacing.s3
                      : AppSpacing.s3 + AppSizes.iconButton + AppSpacing.s2,
                  child: Wrap(spacing: 6, runSpacing: 6, children: badges),
                ),
              if (action != null)
                Positioned(
                  top: AppSpacing.s2,
                  right: AppSpacing.s2,
                  child: action!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An event in a list (Meetup / Eventbrite card [O]): a flush 16:9 cover with status badges and
/// the save button, then title, when, where and who's going. [reason] is the "picked for you"
/// rule, when there is one.
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
    return ClipRRect(
      borderRadius: AppRadii.all(AppRadii.card),
      child: ColoredBox(
        color: AppColors.surface,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EventCover(
                    event: e,
                    badges: badges,
                    radius: 0,
                    // Keeps the badges clear of the save button laid over this corner.
                    action: onToggleSave == null
                        ? null
                        : const SizedBox.square(dimension: AppSizes.iconButton),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.cardPadding,
                      AppSpacing.s3,
                      AppLayout.cardPadding,
                      AppLayout.cardPadding,
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
                        const SizedBox(height: AppLayout.metaGap),
                        EventMetaRow(icon: NumayaIcons.calendar, text: when),
                        EventMetaRow(
                          icon: e.format == EventFormat.online
                              ? NumayaIcons.public
                              : NumayaIcons.location,
                          text: where,
                        ),
                        EventMetaRow(icon: NumayaIcons.groups, text: going),
                        if (reason != null) ...[
                          const SizedBox(height: AppSpacing.s2),
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
            if (onToggleSave != null)
              Positioned(
                top: AppSpacing.s2,
                right: AppSpacing.s2,
                child: NavIconButton(
                  icon: NumayaIcons.heart,
                  label: saved
                      ? l10n.eventUnsave(e.title)
                      : l10n.eventSave(e.title),
                  outline: !saved,
                  onPressed: onToggleSave,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One metadata line of an event: an inline icon and secondary text.
class EventMetaRow extends StatelessWidget {
  const EventMetaRow({super.key, required this.icon, required this.text});

  final NumayaIcons icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppLayout.metaGap),
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
          const SizedBox(width: AppLayout.iconLabelGap),
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
