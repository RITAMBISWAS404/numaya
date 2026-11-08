import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
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

/// The cover: a labelled illustration placeholder in a soft brand tint with the category glyph.
/// No photography or generated art (illustrations are a later pass).
class EvCover extends StatelessWidget {
  const EvCover({
    super.key,
    required this.event,
    this.aspectRatio = 16 / 9,
    this.radius = AppRadii.card,
  });

  final NumayaEvent event;
  final double aspectRatio;
  final double radius;

  static const _tints = [
    Color(0xFFEFEDFA),
    Color(0xFFE9F3EE),
    Color(0xFFF7EEE6),
    Color(0xFFEAF0F8),
    Color(0xFFF6EAF1),
    Color(0xFFF1F1E6),
  ];

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: AppRadii.all(radius),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ColoredBox(
          color: _tints[event.tone % _tints.length],
          child: Stack(
            children: [
              Center(
                child: NumayaIcon(
                  evIcon(event.category),
                  size: 44,
                  color: AppColors.accent,
                ),
              ),
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
                    color: AppColors.textMuted,
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

/// E01 event card: cover, title, when, where, then Free and availability.
class EvCard extends StatelessWidget {
  const EvCard({
    super.key,
    required this.event,
    required this.status,
    required this.onTap,
    this.statusBrand = false,
  });

  final NumayaEvent event;

  /// "12 places left", "Full", "You’re going"…
  final String status;
  final bool statusBrand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final when = evWhen(l10n, event.start);
    final place = '${event.venue.area}, ${event.city}';
    return Pressable(
      onTap: onTap,
      semanticLabel: l10n.evCardLabel(event.title, when, place, status),
      excludeChildSemantics: true,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
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
                  Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s1,
                    children: [
                      EvStatusBadge(label: l10n.evFree),
                      EvStatusBadge(label: status, brand: statusBrand),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
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
