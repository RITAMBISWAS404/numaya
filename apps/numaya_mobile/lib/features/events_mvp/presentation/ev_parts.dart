import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/media/demo_photos.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../../lab/lab_registry.dart';
import '../domain/event_models.dart';

/// Shared Events pieces, built only from the design system (Ente foundations, Tabler, purple).

NumayaIcons evIcon(EvCategory c) => switch (c) {
  EvCategory.coffee => NumayaIcons.event,
  EvCategory.games => NumayaIcons.games,
  EvCategory.workshop => NumayaIcons.palette,
  EvCategory.walk => NumayaIcons.park,
  EvCategory.food => NumayaIcons.food,
  EvCategory.arts => NumayaIcons.sparkle,
};

String evCategoryLabel(AppLocalizations l10n, EvCategory c) => switch (c) {
  EvCategory.coffee => l10n.evCatCoffee,
  EvCategory.games => l10n.evCatGames,
  EvCategory.workshop => l10n.evCatWorkshop,
  EvCategory.walk => l10n.evCatWalk,
  EvCategory.food => l10n.evCatFood,
  EvCategory.arts => l10n.evCatArts,
};

String evDay(DateTime d) => DateFormat('EEE d MMM').format(d);
String evTime(DateTime d) => DateFormat('HH:mm').format(d);
String evWhen(AppLocalizations l10n, DateTime d) =>
    l10n.evWhen(evDay(d), evTime(d));

/// The cover: the local demo photo for this event when a set is installed; otherwise a neutral
/// placeholder with the category glyph and a one-line art brief (V4: no decorative tints).
class EvCover extends StatelessWidget {
  const EvCover({
    super.key,
    required this.event,
    this.aspectRatio = 16 / 9,
    this.radius = AppRadii.card,
    this.showLabel = true,
    this.iconSize = 44,
  });

  final NumayaEvent event;
  final double aspectRatio;
  final double radius;

  /// The demo art-direction label; off in thumbnails, where it can't be read.
  final bool showLabel;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final photo = DemoPhotoLibrary.instance.coverFor(event.tone);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: AppRadii.all(radius),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: photo != null
              ? Image(
                  image: localImage(photo.source, width: 1080),
                  fit: BoxFit.cover,
                  alignment: photo.focus,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: AppColors.photo),
                )
              : ColoredBox(
                  color: AppColors.photo,
                  child: Stack(
                    children: [
                      Center(
                        child: NumayaIcon(
                          evIcon(event.category),
                          size: iconSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (showLabel)
                        Positioned(
                          left: AppSpacing.s3,
                          bottom: AppSpacing.s2,
                          right: AppSpacing.s3,
                          child: Text(
                            'Illustration: cover for ${event.title.toLowerCase()}',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            textScaler: TextScaler.noScaling,
                            style: AppTypography.micro.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// The member-facing state of an event, as a small badge (never fake scarcity).
class EvStatusBadge extends StatelessWidget {
  const EvStatusBadge({super.key, required this.label, this.brand = false});
  final String label;
  final bool brand;

  @override
  Widget build(BuildContext context) => StatusBadge(
    label: label,
    tone: brand ? BadgeTone.brand : BadgeTone.neutral,
  );
}

/// E01 event card. Lab group `ea-event-card` (Ente alignment V3): O is the approved cover-led
/// card; A, B and C are alternatives for owner selection, never promoted silently.
class EvCard extends ConsumerWidget {
  const EvCard({
    super.key,
    required this.event,
    required this.status,
    required this.onTap,
    this.statusBrand = false,
    this.variant,
  });

  final NumayaEvent event;

  /// "12 places left", "Full", "You’re going"…
  final String status;
  final bool statusBrand;
  final VoidCallback onTap;

  /// Forces a variant (Visual Lab previews); otherwise the registry decides.
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final v = variant ?? ref.watch(labVariantProvider('ea-event-card'));
    final when = evWhen(l10n, event.start);
    final place = '${event.venue.area}, ${event.city}';
    final Widget body = switch (v) {
      'A' => _compact(l10n, when, place),
      'B' => _dateLed(l10n, place),
      'C' => _coverDate(l10n, place),
      'P' => _photoLed(l10n, when, place),
      _ => _original(l10n, when, place),
    };
    return Pressable(
      onTap: onTap,
      semanticLabel: l10n.evCardLabel(event.title, when, place, status),
      excludeChildSemantics: true,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.card),
      child: body,
    );
  }

  Widget _badges(AppLocalizations l10n) => Wrap(
    spacing: AppSpacing.s2,
    runSpacing: AppSpacing.s1,
    children: [
      EvStatusBadge(label: l10n.evFree),
      EvStatusBadge(label: status, brand: statusBrand),
    ],
  );

  BoxDecoration get _box => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadii.all(AppRadii.card),
  );

  Widget _original(AppLocalizations l10n, String when, String place) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.s2),
        decoration: _box,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concentric: card radius 20 = cover radius 12 + inset 8.
            EvCover(event: event, radius: AppRadii.card - AppSpacing.s2),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s2,
                AppSpacing.s3,
                AppSpacing.s2,
                AppSpacing.s2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppTypography.card),
                  const SizedBox(height: AppSpacing.s1),
                  EvInfoLine(icon: NumayaIcons.calendar, text: when),
                  const SizedBox(height: 2),
                  EvInfoLine(icon: NumayaIcons.location, text: place),
                  const SizedBox(height: AppSpacing.s3),
                  _badges(l10n),
                ],
              ),
            ),
          ],
        ),
      );

  /// P (V4 default): the photo leads with the date on a glass pill; title, place, and one quiet
  /// line for price and availability, with a chevron as the affordance. One status, no badges row.
  Widget _photoLed(AppLocalizations l10n, String when, String place) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.s2),
        decoration: _box,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                EvCover(event: event, radius: AppRadii.card - AppSpacing.s2),
                Positioned(
                  left: AppSpacing.s2,
                  top: AppSpacing.s2,
                  child: PhotoPill(label: when, icon: NumayaIcons.calendar),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s2,
                AppSpacing.s3,
                AppSpacing.s2,
                AppSpacing.s2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: AppTypography.card),
                        const SizedBox(height: AppSpacing.s1),
                        EvInfoLine(icon: NumayaIcons.location, text: place),
                        const SizedBox(height: AppSpacing.s2),
                        if (statusBrand)
                          EvStatusBadge(label: status, brand: true)
                        else
                          Text(
                            '${l10n.evFree} · $status',
                            style: AppTypography.weight(
                              AppTypography.bodySm,
                              AppTypography.semibold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  const NumayaIcon(
                    NumayaIcons.chevronRight,
                    size: AppSizes.iconMd,
                    color: AppColors.iconSupporting,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// A: compact row (density). A square category thumbnail, then when, title and place, then
  /// status. About twice as many events per screen; the cover shrinks to a mark.
  Widget _compact(AppLocalizations l10n, String when, String place) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.s3),
        decoration: _box,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 76,
              // Concentric: 20 card radius minus the 12 inset.
              child: EvCover(
                event: event,
                aspectRatio: 1,
                radius: AppRadii.card - AppSpacing.s3,
                showLabel: false,
                iconSize: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    when,
                    style: AppTypography.weight(
                      AppTypography.caption,
                      AppTypography.semibold,
                    ).copyWith(color: AppColors.accentOnTint),
                  ),
                  const SizedBox(height: 2),
                  Text(event.title, style: AppTypography.card),
                  const SizedBox(height: 2),
                  Text(
                    place,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  _badges(l10n),
                ],
              ),
            ),
          ],
        ),
      );

  /// B: date-led (hierarchy). The day leads in a tinted date tile; time and place share one
  /// line; no cover. Scans like a calendar; loses imagery.
  Widget _dateLed(AppLocalizations l10n, String place) => Container(
    padding: const EdgeInsets.all(AppSpacing.s3),
    decoration: _box,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: AppRadii.all(AppRadii.card - AppSpacing.s3),
          ),
          child: Column(
            children: [
              Text(
                DateFormat('EEE').format(event.start),
                style: AppTypography.caption.copyWith(
                  color: AppColors.accentOnTint,
                ),
              ),
              Text(
                DateFormat('d').format(event.start),
                style: AppTypography.weight(
                  AppTypography.card,
                  AppTypography.semibold,
                ).copyWith(color: AppColors.accentOnTint, fontSize: 22),
              ),
              Text(
                DateFormat('MMM').format(event.start),
                style: AppTypography.caption.copyWith(
                  color: AppColors.accentOnTint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: AppTypography.card),
              const SizedBox(height: 2),
              Text(
                '${evTime(event.start)} · $place',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              _badges(l10n),
            ],
          ),
        ),
      ],
    ),
  );

  /// C: cover with a date chip (imagery). The date sits on the cover; one status line merges
  /// "Free" with availability, so the card carries a single badge.
  Widget _coverDate(AppLocalizations l10n, String place) => Container(
    padding: const EdgeInsets.all(AppSpacing.s2),
    decoration: _box,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            EvCover(event: event, radius: AppRadii.card - AppSpacing.s2),
            Positioned(
              left: AppSpacing.s2,
              top: AppSpacing.s2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.all(AppRadii.pill),
                ),
                child: Text(
                  evDay(event.start),
                  style: AppTypography.weight(
                    AppTypography.caption,
                    AppTypography.semibold,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s2,
            AppSpacing.s3,
            AppSpacing.s2,
            AppSpacing.s2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: AppTypography.card),
              const SizedBox(height: 2),
              Text(
                '${evTime(event.start)} · $place',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              EvStatusBadge(
                label: '${l10n.evFree} · $status',
                brand: statusBrand,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// An icon and one line of secondary text.
class EvInfoLine extends StatelessWidget {
  const EvInfoLine({super.key, required this.icon, required this.text});
  final NumayaIcons icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: NumayaIcon(icon, size: 16, color: AppColors.iconSupporting),
      ),
      const SizedBox(width: AppSpacing.s2),
      Expanded(
        child: Text(
          text,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
      ),
    ],
  );
}

/// A titled block of event facts on a white card (E02/E05).
class EvFact extends StatelessWidget {
  const EvFact({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.extra,
  });

  final NumayaIcons icon;
  final String title;
  final String body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) => Padding(
    // A trailing link already carries its 44dp target's slack; no second gap below it.
    padding: EdgeInsets.only(
      top: AppSpacing.s2,
      bottom: extra == null ? AppSpacing.s2 : 0,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumayaIcon(
          icon,
          size: AppSizes.iconMd,
          color: AppColors.iconSupporting,
        ),
        const SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.weight(
                  AppTypography.body,
                  AppTypography.semibold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              ?extra,
            ],
          ),
        ),
      ],
    ),
  );
}

/// The event's description on its own white card: a four-line preview with a real expand action
/// when the text runs longer. (V4 pilot: About separated from logistics.)
class EvAboutCard extends StatefulWidget {
  const EvAboutCard({super.key, required this.title, required this.body});
  final String title;
  final String body;

  @override
  State<EvAboutCard> createState() => _EvAboutCardState();
}

class _EvAboutCardState extends State<EvAboutCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = AppTypography.body.copyWith(color: AppColors.textSecondary);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(widget.title, style: AppTypography.section),
          ),
          const SizedBox(height: AppSpacing.s2),
          LayoutBuilder(
            builder: (context, box) {
              final painter = TextPainter(
                text: TextSpan(text: widget.body, style: style),
                textScaler: MediaQuery.textScalerOf(context),
                textDirection: Directionality.of(context),
                maxLines: 4,
              )..layout(maxWidth: box.maxWidth);
              final long = painter.didExceedMaxLines;
              painter.dispose();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.body,
                    style: style,
                    maxLines: _open ? null : 4,
                    overflow: _open
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if (long)
                    TextLink(
                      label: _open ? l10n.evShowLess : l10n.evReadMore,
                      onPressed: () => setState(() => _open = !_open),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// White card wrapper with the shared padding.
class EvCardBox extends StatelessWidget {
  const EvCardBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppLayout.cardPadding,
      vertical: AppSpacing.s2,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    ),
    child: child,
  );
}

/// Ente Disclosure Button, chip form (2207:41577: "a value that opens a menu; never a normal
/// button"): the current value with a down chevron, 40pt tall (48pt target). [active] marks a
/// non-default value with the solid brand fill so a set filter is visible at a glance.
class EvDisclosureChip extends StatelessWidget {
  const EvDisclosureChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.active = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback onTap;
  final NumayaIcons? icon;
  final bool active;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.accentForeground : AppColors.ink;
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel ?? label,
      selected: active,
      excludeChildSemantics: true,
      pressedScale: 0.97,
      borderRadius: AppRadii.all(AppRadii.pill),
      child: Container(
        height: AppSizes.chip,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              NumayaIcon(
                icon!,
                size: 18,
                color: active ? fg : AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.s1),
            ],
            Text(
              label,
              style: AppTypography.weight(
                AppTypography.bodySm,
                AppTypography.semibold,
              ).copyWith(color: fg),
            ),
            const SizedBox(width: AppSpacing.s1),
            NumayaIcon(NumayaIcons.chevronDown, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}
