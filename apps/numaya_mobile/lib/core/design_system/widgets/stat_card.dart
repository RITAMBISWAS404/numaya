import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import '../icons/tabler_icons.dart';
import 'primitives.dart';
import 'promo_card.dart';

/// UI-078 (V8): the data a statistics summary shows. Templates read only what is real: [progress]
/// only when the figure has a true denominator (streak day of 7, profile percent, earned credits
/// against their cap), never a balance dressed up as a percentage. No trends or scores.
@immutable
class StatData {
  const StatData({
    required this.icon,
    required this.heading,
    required this.value,
    this.unit,
    this.iconFilled = false,
    this.detail,
    this.note,
    this.progress,
    this.progressLabel,
    this.parts,
    this.partsLabel,
    this.marks,
    this.marksLabel,
    this.slot = 'stat',
  });

  final NumayaMobileIcons icon;
  final bool iconFilled;

  /// "Compliment credits", "Streak", "Profile".
  final String heading;

  /// The figure ("2", "1", "45%") and its unit ("credits", "day streak", "complete").
  final String value;
  final String? unit;

  /// The main supporting line ("Weekly 0 · Earned 2 · Purchased 0", "Day 1 of 7").
  final String? detail;

  /// A second, quieter line ("Today isn't counted yet").
  final String? note;

  /// 0..1 against a real denominator, with what it measures ("Earned 2 of 5").
  final double? progress;
  final String? progressLabel;

  /// Discrete marks: a week's days, the six profile parts, the credit buckets in spend order.
  /// Each entry is (weight, filled).
  final List<(int, bool)>? parts;
  final String? partsLabel;

  /// Equal marks for the cadence template, each one unit of a real whole (a day of the cycle, a
  /// profile part, an earned credit of the cap). Falls back to [parts].
  final List<bool>? marks;
  final String? marksLabel;

  /// Artwork slot code for the side-art template.
  final String slot;
}

/// The six statistics card templates under review (UI-078). One template is one component, used
/// for credits, streak and profile completion alike, so a choice applies as a family.
enum StatTemplate {
  /// T1 Number-first summary: icon and heading, the figure large, then the detail lines.
  number,

  /// T2 Progress rail: the figure, then a full-width rail (parts or progress), then details.
  rail,

  /// T3 Goal ring: a ring with the figure inside, the heading and details beside it.
  ring,

  /// T4 Cadence: heading and figure on one line, discrete marks across the card below.
  cadence,

  /// T5 Side art: a square artwork slot beside the figures and a compact rail (UI-061).
  sideArt,

  /// T6 Split: the figure on the left, a divider, heading and details on the right.
  split,
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.data,
    required this.template,
    this.onTap,
    this.semanticLabel,
  });

  final StatData data;
  final StatTemplate template;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final d = data;
    final head = Row(
      children: [
        MobileIcon(
          d.icon,
          size: 18,
          filled: d.iconFilled,
          color: AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: Text(
            d.heading,
            style: AppTypography.weight(
              AppTypography.label,
              AppTypography.semibold,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
    Widget figure({double size = 40}) => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: d.value,
            style: AppTypography.metric.copyWith(
              fontSize: size,
              height: (size + 4) / size,
            ),
          ),
          if (d.unit != null)
            TextSpan(text: ' ${d.unit}', style: AppTypography.metricUnit),
        ],
      ),
    );
    final details = [
      if (d.detail != null)
        Text(
          d.detail!,
          style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
        ),
      if (d.note != null)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(d.note!, style: AppTypography.caption),
        ),
    ];
    Widget rail({double height = 8}) =>
        _Rail(parts: d.parts, progress: d.progress, height: height);
    // UI-055: a caption that repeats the detail line is dropped.
    final caption = d.partsLabel ?? d.progressLabel;
    final railCaption = caption == d.detail ? null : caption;

    final Widget body = switch (template) {
      StatTemplate.number => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          head,
          const SizedBox(height: AppSpacing.s3),
          figure(size: 44),
          const SizedBox(height: AppSpacing.s2),
          ...details,
        ],
      ),
      StatTemplate.rail => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          head,
          const SizedBox(height: AppSpacing.s2),
          figure(size: 32),
          if (d.parts != null || d.progress != null) ...[
            const SizedBox(height: AppSpacing.s3),
            rail(),
            if (railCaption != null) ...[
              const SizedBox(height: AppSpacing.s1),
              Text(railCaption, style: AppTypography.caption),
            ],
          ],
          const SizedBox(height: AppSpacing.s3),
          ...details,
        ],
      ),
      StatTemplate.ring => Row(
        children: [
          _Ring(progress: d.progress, value: d.value, unit: null),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                head,
                const SizedBox(height: AppSpacing.s1),
                if (d.unit != null)
                  Text('${d.value} ${d.unit}', style: AppTypography.card),
                if (d.progressLabel != null)
                  Text(d.progressLabel!, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.s2),
                ...details,
              ],
            ),
          ),
        ],
      ),
      StatTemplate.cadence => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: head),
              figure(size: 28),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          _Marks(
            marks: d.marks ?? d.parts?.map((e) => e.$2).toList(),
            progress: d.progress,
          ),
          if ((d.marksLabel ?? railCaption) case final c?
              when c != d.detail) ...[
            const SizedBox(height: AppSpacing.s2),
            Text(c, style: AppTypography.caption),
          ],
          const SizedBox(height: AppSpacing.s3),
          ...details,
        ],
      ),
      StatTemplate.sideArt => const SizedBox.shrink(),
      StatTemplate.split => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.value,
                  style: AppTypography.metric.copyWith(
                    fontSize: 48,
                    height: 52 / 48,
                  ),
                ),
                if (d.unit != null)
                  Text(d.unit!, style: AppTypography.metricUnit),
              ],
            ),
            const SizedBox(width: AppSpacing.s4),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.divider,
            ),
            const SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  head,
                  const SizedBox(height: AppSpacing.s2),
                  ...details,
                  if (railCaption != null) ...[
                    const SizedBox(height: AppSpacing.s1),
                    Text(railCaption, style: AppTypography.caption),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    };

    final Widget card = template == StatTemplate.sideArt
        ? PromoCard(
            title: d.heading,
            slot: d.slot,
            slotLabel: '${d.heading} artwork',
            artStart: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                head,
                const SizedBox(height: AppSpacing.s1),
                figure(size: 28),
                if (d.parts != null || d.progress != null) ...[
                  const SizedBox(height: AppSpacing.s2),
                  rail(height: 6),
                ],
                const SizedBox(height: AppSpacing.s2),
                ...details,
              ],
            ),
          )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppLayout.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.all(AppRadii.card),
            ),
            child: body,
          );
    final label =
        semanticLabel ??
        [
          d.heading,
          [d.value, ?d.unit].join(' '),
          ?d.detail,
          ?d.progressLabel,
          ?d.note,
        ].join('. ');
    if (onTap == null) {
      return Semantics(
        container: true,
        label: label,
        child: ExcludeSemantics(child: card),
      );
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      excludeChildSemantics: true,
      borderRadius: AppRadii.all(AppRadii.card),
      child: card,
    );
  }
}

/// A full-width rail: weighted parts in order (filled brand, empty grey) or one progress fill.
class _Rail extends StatelessWidget {
  const _Rail({required this.parts, required this.progress, this.height = 8});

  final List<(int, bool)>? parts;
  final double? progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = parts;
    if (p == null || p.every((e) => e.$1 == 0)) {
      return ClipRRect(
        borderRadius: AppRadii.all(AppRadii.pill),
        child: LinearProgressIndicator(
          value: (progress ?? 0).clamp(0.0, 1.0),
          minHeight: height,
          color: AppColors.accent,
          backgroundColor: AppColors.fill,
        ),
      );
    }
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (w, on)) in p.indexed)
            if (w > 0) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                flex: w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: on ? AppColors.accent : AppColors.fill,
                    borderRadius: AppRadii.all(AppRadii.pill),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

/// Discrete marks of equal size (days, profile parts); a progress value becomes ten marks.
class _Marks extends StatelessWidget {
  const _Marks({required this.marks, required this.progress});

  final List<bool>? marks;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final marks =
        this.marks ??
        [for (var i = 0; i < 10; i++) (progress ?? 0) * 10 > i + 0.01];
    return Row(
      children: [
        for (final (i, on) in marks.indexed) ...[
          if (i > 0) const SizedBox(width: AppSpacing.s1),
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: on ? AppColors.accent : AppColors.canvas,
                borderRadius: AppRadii.all(AppRadii.chip),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A goal ring with the figure inside. With no real denominator, the ring is a quiet outline.
class _Ring extends StatelessWidget {
  const _Ring({required this.progress, required this.value, this.unit});

  final double? progress;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 84,
    child: CustomPaint(
      painter: _RingPainter(progress),
      child: Center(
        child: Text(
          value,
          style: AppTypography.metric.copyWith(fontSize: 24, height: 28 / 24),
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double? progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    final p = progress;
    if (p != null && p > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * p.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
