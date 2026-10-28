import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_haptics.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'buttons.dart';
import 'people.dart';
import 'primitives.dart';

/// A new match in the queue (B-42): the initials avatar inside a countdown ring that empties as the
/// match approaches expiry (Withings blue; red under two hours). Expired matches are grey, dimmed,
/// with a full grey ring.
class CountdownAvatar extends StatelessWidget {
  const CountdownAvatar({
    super.key,
    required this.initial,
    required this.fraction,
    this.size = 72,
    this.expired = false,
    this.urgent = false,
  });

  final String initial;

  /// Time left as a fraction of the window (1 = just matched).
  final double fraction;
  final double size;
  final bool expired;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final avatar = Opacity(
      opacity: expired ? 0.45 : 1,
      child: InitialsAvatar(initial: initial, size: size - 10),
    );
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: expired ? 1 : fraction,
          color: expired
              ? AppColors.borderStrong
              : urgent
              ? AppColors.negative
              : AppColors.accent,
        ),
        child: Center(child: avatar),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(
      r,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.fill,
    );
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * fraction.clamp(0, 1),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}

/// Profile completion (B-23, refined in RD-15): a card with the percentage, a progress bar and,
/// while anything is missing, one action. Replaces the ring around the avatar, which said only a
/// number. [title] is read as the card's label ("Profile 28% complete").
class CompletionCard extends StatelessWidget {
  const CompletionCard({
    super.key,
    required this.percent,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final int percent;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final done = percent >= 100;
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (done) ...[
                const NumayaIcon(
                  NumayaIcons.check,
                  size: AppSizes.iconMd,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppLayout.iconLabelGap),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.weight(
                    AppTypography.body,
                    AppTypography.semibold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          // The bar fills from its old value when the percentage changes (the number changes at
          // once; the title already says it, so the bar is not read).
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: AppRadii.all(AppRadii.pill),
              child: SizedBox(
                height: 6,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: (percent / 100).clamp(0, 1)),
                  duration: AppMotion.duration(context, AppMotion.progress),
                  curve: AppMotion.easeOut,
                  builder: (context, fraction, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: AppColors.fill),
                      FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: fraction,
                        child: const ColoredBox(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            body,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null && !done) ...[
            const SizedBox(height: AppSpacing.s4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: NumayaButton(
                label: actionLabel!,
                small: true,
                expand: false,
                onPressed: onAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A tile in the completion hub (B-21): icon, section name, "2 of 4 added", a check when done.
class CompletionTile extends StatelessWidget {
  const CompletionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.progress,
    required this.done,
    required this.onTap,
  });

  final NumayaIcons icon;
  final String title;
  final String progress;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title. $progress',
      excludeChildSemantics: true,
      pressedScale: 0.98,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NumayaIcon(
                  done ? NumayaIcons.check : icon,
                  size: AppSizes.iconMd,
                  color: done ? AppColors.accent : AppColors.ink,
                ),
                const Spacer(),
                const NumayaIcon(
                  NumayaIcons.chevronRight,
                  size: 20,
                  color: AppColors.control,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            Text(title, style: AppTypography.card),
            const SizedBox(height: 2),
            Text(
              progress,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A plan card on the paywall (B-61): selectable, with duration, price, per-week price and an
/// optional saving tag. No plan is pre-selected (D-14).
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.perWeek,
    required this.selected,
    required this.onTap,
    this.tag,
  });

  final String title;
  final String price;
  final String perWeek;
  final String? tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Pressable(
        onTap: onTap,
        haptic: HapticMoment.selection,
        semanticLabel: [title, price, perWeek, ?tag].join(', '),
        excludeChildSemantics: true,
        pressedScale: 0.98,
        borderRadius: AppRadii.all(AppRadii.card),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.row),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.border,
              width: selected ? 2 : 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTypography.weight(
                            AppTypography.row,
                            AppTypography.semibold,
                          ),
                        ),
                        if (tag != null) ...[
                          const SizedBox(width: AppSpacing.s2),
                          StatusBadge(label: tag!, tone: BadgeTone.brand),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      perWeek,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(price, style: AppTypography.row),
            ],
          ),
        ),
      ),
    );
  }
}

/// One row of the plan comparison (B-64): feature name and a check per tier.
class ComparisonRow extends StatelessWidget {
  const ComparisonRow({
    super.key,
    required this.label,
    required this.free,
    required this.premium,
    required this.yesLabel,
    required this.noLabel,
  });

  final String label;
  final bool free;
  final bool premium;
  final String yesLabel;
  final String noLabel;

  @override
  Widget build(BuildContext context) {
    Widget mark(bool on) => SizedBox(
      width: 72,
      child: Center(
        child: on
            ? const NumayaIcon(
                NumayaIcons.check,
                size: 20,
                color: AppColors.ink,
              )
            : const NumayaIcon(
                NumayaIcons.minus,
                size: 20,
                color: AppColors.borderStrong,
              ),
      ),
    );
    return Semantics(
      label:
          '$label: free ${free ? yesLabel : noLabel}, premium ${premium ? yesLabel : noLabel}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.bodySm)),
            mark(free),
            mark(premium),
          ],
        ),
      ),
    );
  }
}

enum BannerTone { info, pending, success, error }

/// A status banner (states-and-recovery: `StatusBanner`): pending review, approved, rejected,
/// offline. Tinted card with an icon, title and optional body and action.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.title,
    this.body,
    this.tone = BannerTone.info,
    this.action,
  });

  final String title;
  final String? body;
  final BannerTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, NumayaIcons icon) = switch (tone) {
      BannerTone.info => (
        AppColors.accentTint,
        AppColors.accentOnTint,
        NumayaIcons.info,
      ),
      BannerTone.pending => (
        AppColors.warningTint,
        AppColors.ink,
        NumayaIcons.pending,
      ),
      BannerTone.success => (
        AppColors.accentTint,
        AppColors.accentOnTint,
        NumayaIcons.verified,
      ),
      BannerTone.error => (
        AppColors.dangerTint,
        AppColors.negative,
        NumayaIcons.alert,
      ),
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumayaIcon(icon, size: 22, color: fg),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        AppTypography.weight(
                          AppTypography.body,
                          AppTypography.semibold,
                        ).copyWith(
                          color: fg == AppColors.negative ? fg : AppColors.ink,
                        ),
                  ),
                  if (body != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      body!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: AppSpacing.s3),
                    action!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A day or system line in a conversation ("Today", "You matched with Maya").
class ChatSystemLine extends StatelessWidget {
  const ChatSystemLine(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.s4, bottom: AppSpacing.s1),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.caption,
    ),
  );
}

/// A count dot for unread messages (Withings blue, white figure).
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 22),
    height: 22,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: AppRadii.all(AppRadii.pill),
    ),
    alignment: Alignment.center,
    child: Text(
      '$count',
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.accentForeground,
        letterSpacing: 0,
      ),
    ),
  );
}
