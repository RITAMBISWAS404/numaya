import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../health/domain/profile_health.dart';
import '../../health/presentation/health_screens.dart';
import '../../lab/lab_banners.dart';
import '../../lab/lab_registry.dart';
import '../domain/insights_fixture.dart';

/// "Sample data" pill: every insights surface shows it while the numbers are fixtures.
class SampleDataTag extends StatelessWidget {
  const SampleDataTag({super.key});

  @override
  Widget build(BuildContext context) => StatusBadge(
    label: context.l10n.insightsSampleTag,
    icon: NumayaIcons.info,
  );
}

/// The period in words: "Last 7 days".
String periodLabel(AppLocalizations l10n, int days) =>
    l10n.insightsPeriod(days);

/// Visibility status in words, never a diagnosis of another member's behaviour.
({String title, String body, BannerTone tone, NumayaMobileIcons icon})
visibilityCopy(AppLocalizations l10n, InsightsSnapshot s) => switch (s.state) {
  VisibilityState.shown => (
    title: l10n.insightsStatusShown,
    body: l10n.insightsStatusShownBody(s.eligibleAudience, s.distanceKm),
    tone: BannerTone.success,
    icon: NumayaMobileIcons.eye,
  ),
  VisibilityState.limitedAudience => (
    title: l10n.insightsStatusLimited,
    body: l10n.insightsStatusLimitedBody(s.eligibleAudience, s.distanceKm),
    tone: BannerTone.info,
    icon: NumayaMobileIcons.users,
  ),
  VisibilityState.paused => (
    title: l10n.insightsStatusPaused,
    body: l10n.insightsStatusPausedBody,
    tone: BannerTone.pending,
    icon: NumayaMobileIcons.eye,
  ),
  VisibilityState.restricted => (
    title: l10n.insightsStatusRestricted,
    body: s.restrictionReason ?? l10n.insightsStatusRestrictedBody,
    tone: BannerTone.error,
    icon: NumayaMobileIcons.eye,
  ),
  VisibilityState.notEnoughData => (
    title: l10n.insightsStatusNew,
    body: l10n.insightsStatusNewBody,
    tone: BannerTone.info,
    icon: NumayaMobileIcons.chart,
  ),
};

/// Where the status banner leads (restriction and pause are explained free).
String? visibilityRoute(InsightsSnapshot s) => switch (s.state) {
  VisibilityState.restricted => Routes.accountBlocked,
  VisibilityState.paused => Routes.privacy,
  _ => null,
};

/// The change against the previous period in words, or the reason there is none.
String changeLabel(AppLocalizations l10n, InsightsSnapshot s) {
  if (s.lowSample) return l10n.insightsLowSampleNote;
  final c = s.change;
  if (c == null) return l10n.insightsNoPrevious;
  if (c == 0) return l10n.insightsNoChange(s.days);
  return c > 0 ? l10n.insightsUp(c, s.days) : l10n.insightsDown(-c, s.days);
}

// Charts ------------------------------------------------------------------------------------

/// Daily new people shown the profile, as bars with an honest zero baseline and the exact values
/// as text for screen readers. A short one-time reveal (MOT06) that never replays on rebuild and
/// is skipped under reduced motion.
class ExposureBars extends StatelessWidget {
  const ExposureBars({
    super.key,
    required this.daily,
    required this.endDate,
    this.height = 96,
  });

  final List<int> daily;

  /// The last day in [daily], for the weekday labels.
  final DateTime endDate;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final week = daily.length <= 7;
    final maxV = daily.fold<int>(0, math.max);
    final days = [
      for (var i = 0; i < daily.length; i++)
        endDate.subtract(Duration(days: daily.length - 1 - i)),
    ];
    final spoken = week
        ? [
            for (var i = 0; i < daily.length; i++)
              '${DateFormat('EEEE').format(days[i])} ${daily[i]}',
          ].join(', ')
        : l10n.insightsBarsSummary(
            daily.length,
            maxV,
            daily.fold(0, (a, b) => a + b),
          );
    final reveal = AppMotion.duration(
      context,
      const Duration(milliseconds: 220),
    );
    return Semantics(
      label: '${l10n.insightsBarsLabel}. $spoken',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: height,
            child: TweenAnimationBuilder<double>(
              // Keyed by the data, so a rebuild with the same numbers doesn't replay it.
              key: ValueKey(Object.hashAll(daily)),
              tween: Tween(begin: reveal == Duration.zero ? 1 : 0, end: 1),
              duration: reveal,
              curve: AppMotion.easeOut,
              builder: (context, t, _) => CustomPaint(
                size: Size.infinite,
                painter: _BarsPainter(daily: daily, max: maxV, t: t),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s1),
          if (week)
            Row(
              children: [
                for (final d in days)
                  Expanded(
                    child: Text(
                      DateFormat('EEEEE').format(d),
                      textAlign: TextAlign.center,
                      style: AppTypography.micro,
                    ),
                  ),
              ],
            )
          else
            Row(
              children: [
                Text(
                  DateFormat('d MMM').format(days.first),
                  style: AppTypography.micro,
                ),
                const Spacer(),
                Text(
                  DateFormat('d MMM').format(days.last),
                  style: AppTypography.micro,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.daily, required this.max, required this.t});
  final List<int> daily;
  final int max;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final n = daily.length;
    if (n == 0) return;
    final slot = size.width / n;
    final w = n <= 7 ? math.min(20.0, slot * 0.5) : math.max(2.0, slot * 0.6);
    final base = Paint()..color = AppColors.border;
    canvas.drawRect(Rect.fromLTWH(0, size.height - 1, size.width, 1), base);
    final bar = Paint()..color = AppColors.accent;
    final zero = Paint()..color = AppColors.fill;
    for (var i = 0; i < n; i++) {
      final v = daily[i];
      final x = slot * i + (slot - w) / 2;
      if (v == 0 || max == 0) {
        // Zero is drawn as a short stub, so "no one" differs from "missing".
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - 4, w, 3),
            const Radius.circular(2),
          ),
          zero,
        );
        continue;
      }
      final h = (size.height - 2) * (v / max) * t;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, size.height - 1 - h, w, h),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        bar,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.t != t || old.max != max || old.daily != daily;
}

/// One cohort, one period: of the people shown the profile, how many liked, matched and had a
/// two-way conversation. Each bar shows its exact value; widths are proportional to the cohort.
class InsightsFunnel extends StatelessWidget {
  const InsightsFunnel({super.key, required this.s});
  final InsightsSnapshot s;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = [
      (l10n.insightsFunnelShown, s.shown),
      (l10n.insightsFunnelLiked, s.liked),
      (l10n.insightsFunnelMatched, s.matched),
      (l10n.insightsFunnelTalked, s.conversations),
    ];
    final top = math.max(1, s.shown);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.insightsFunnelCaption(s.shown, s.days),
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.s3),
        for (final (label, v) in rows) ...[
          Semantics(
            label: '$label: $v',
            excludeSemantics: true,
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(label, style: AppTypography.bodySm),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        height: 20,
                        width: math.max(4, box.maxWidth * v / top),
                        decoration: BoxDecoration(
                          color: v == 0 ? AppColors.fill : AppColors.accent,
                          borderRadius: AppRadii.all(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                SizedBox(
                  width: 36,
                  child: Text(
                    '$v',
                    textAlign: TextAlign.end,
                    style: AppTypography.weight(
                      AppTypography.body,
                      AppTypography.semibold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
        ],
      ],
    );
  }
}

// insights-summary ---------------------------------------------------------------------------

/// Card family `insights-summary`: the top of Insights. Always states visibility (free, plain),
/// the period and its denominator. O status card, A chart-led, B widget grid, C funnel-led,
/// D plain sentence.
class InsightsSummary extends ConsumerWidget {
  const InsightsSummary({
    super.key,
    required this.s,
    required this.yourTurn,
    required this.endDate,
    this.variant,
  });

  final InsightsSnapshot s;
  final int yourTurn;
  final DateTime endDate;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('insights-summary'));
    final l10n = context.l10n;
    final status = visibilityCopy(l10n, s);
    final route = visibilityRoute(s);
    final statusBanner = LabStatusBanner(
      key: const ValueKey('insights-status'),
      tone: status.tone,
      icon: status.icon,
      title: status.title,
      body: status.body,
      onTap: route == null ? null : () => context.push(route),
    );
    final period = Text(
      l10n.insightsShownPeriod(s.shown, s.days),
      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
    );
    BoxDecoration card() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    );
    Widget headline() => Semantics(
      label: l10n.insightsShownSpoken(s.shown, s.days),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('${s.shown}', style: AppTypography.largeTitle),
          const SizedBox(width: AppSpacing.s2),
          Flexible(
            child: Text(
              l10n.insightsShownUnit,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
    final change = Text(changeLabel(l10n, s), style: AppTypography.caption);

    switch (v) {
      case 'A':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppLayout.cardPadding),
              decoration: card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  headline(),
                  change,
                  const SizedBox(height: AppSpacing.s4),
                  if (s.hasData)
                    ExposureBars(daily: s.daily, endDate: endDate)
                  else
                    Text(l10n.insightsNoDataYet, style: AppTypography.bodySm),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            statusBanner,
          ],
        );
      case 'B':
        final tiles = [
          (NumayaMobileIcons.eye, l10n.insightsTileShown, s.shown),
          (null, l10n.insightsTileLikes, s.liked),
          (null, l10n.insightsTileMatches, s.matched),
          (null, l10n.insightsTileYourTurn, yourTurn),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            statusBanner,
            const SizedBox(height: AppSpacing.s3),
            LayoutBuilder(
              builder: (context, box) {
                final w = (box.maxWidth - AppSpacing.s3) / 2;
                return Wrap(
                  spacing: AppSpacing.s3,
                  runSpacing: AppSpacing.s3,
                  children: [
                    for (final (_, label, value) in tiles)
                      Semantics(
                        label: '$label: $value',
                        excludeSemantics: true,
                        child: Container(
                          width: w,
                          padding: const EdgeInsets.all(AppSpacing.s4),
                          decoration: card(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: AppTypography.caption),
                              const SizedBox(height: AppSpacing.s1),
                              Text('$value', style: AppTypography.pageTitle),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.s2),
            period,
          ],
        );
      case 'C':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            statusBanner,
            const SizedBox(height: AppSpacing.s3),
            Container(
              padding: const EdgeInsets.all(AppLayout.cardPadding),
              decoration: card(),
              child: s.hasData
                  ? InsightsFunnel(s: s)
                  : Text(l10n.insightsNoDataYet, style: AppTypography.bodySm),
            ),
          ],
        );
      case 'D':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.hasData
                  ? l10n.insightsSentence(s.shown, s.liked, s.matched, s.days)
                  : l10n.insightsNoDataYet,
              style: AppTypography.answer,
            ),
            const SizedBox(height: AppSpacing.s1),
            change,
            const SizedBox(height: AppSpacing.s4),
            statusBanner,
          ],
        );
      default:
        return Container(
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  MobileIcon(
                    status.icon,
                    size: AppSizes.iconMd,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Expanded(
                    child: Text(
                      status.title,
                      style: AppTypography.weight(
                        AppTypography.body,
                        AppTypography.semibold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                status.body,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              if (route != null) ...[
                const SizedBox(height: AppSpacing.s2),
                TextLink(
                  label: l10n.insightsStatusMore,
                  onPressed: () => context.push(route),
                ),
              ],
              const SizedBox(height: AppSpacing.s3),
              const ExcludeSemantics(
                child: SizedBox(
                  height: AppBorders.hairline,
                  child: ColoredBox(color: AppColors.divider),
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              period,
              change,
            ],
          ),
        );
    }
  }
}

// metric-widget ------------------------------------------------------------------------------

/// Card family `metric-widget`: one measure with its period. O value tile, A value with weekly
/// bars, B row, C change card, D large number.
class MetricWidget extends ConsumerWidget {
  const MetricWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.daily,
    this.endDate,
    this.change,
    this.onTap,
    this.variant,
  });

  final NumayaMobileIcons icon;
  final String label;
  final int value;

  /// Period and denominator in words ("Last 7 days", "Right now").
  final String caption;
  final List<int>? daily;
  final DateTime? endDate;

  /// The change in words, when meaningful.
  final String? change;
  final VoidCallback? onTap;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('metric-widget'));
    final spoken = [label, '$value', caption, ?change].join('. ');
    BoxDecoration card() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    );
    Widget title() => Row(
      children: [
        MobileIcon(icon, size: 18, color: AppColors.iconSupporting),
        const SizedBox(width: AppSpacing.s2),
        Expanded(child: Text(label, style: AppTypography.bodySm)),
        if (onTap != null)
          const NumayaIcon(
            NumayaIcons.chevronRight,
            size: 18,
            color: AppColors.iconSupporting,
          ),
      ],
    );
    final Widget body;
    switch (v) {
      case 'A':
        body = Container(
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title(),
              const SizedBox(height: AppSpacing.s2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$value', style: AppTypography.pageTitle),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: daily == null || endDate == null
                        ? const SizedBox.shrink()
                        : ExcludeSemantics(
                            child: ExposureBars(
                              daily: daily!,
                              endDate: endDate!,
                              height: 36,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(change ?? caption, style: AppTypography.caption),
            ],
          ),
        );
      case 'B':
        body = Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.cardPadding,
            vertical: AppSpacing.s3,
          ),
          decoration: card(),
          child: Row(
            children: [
              MobileIcon(icon, size: AppSizes.iconMd, color: AppColors.ink),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.row),
                    Text(caption, style: AppTypography.caption),
                  ],
                ),
              ),
              Text(
                '$value',
                style: AppTypography.weight(
                  AppTypography.row,
                  AppTypography.semibold,
                ),
              ),
            ],
          ),
        );
      case 'C':
        body = Container(
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title(),
              const SizedBox(height: AppSpacing.s1),
              Text('$value', style: AppTypography.pageTitle),
              Text(change ?? caption, style: AppTypography.bodySm),
              if (change != null) Text(caption, style: AppTypography.caption),
            ],
          ),
        );
      case 'D':
        body = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 88,
                child: Text('$value', style: AppTypography.hero),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.weight(
                        AppTypography.body,
                        AppTypography.semibold,
                      ),
                    ),
                    Text(change ?? caption, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        body = Container(
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title(),
              const SizedBox(height: AppSpacing.s1),
              Text('$value', style: AppTypography.pageTitle),
              Text(caption, style: AppTypography.caption),
            ],
          ),
        );
    }
    if (onTap == null) {
      return Semantics(label: spoken, excludeSemantics: true, child: body);
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: spoken,
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.card),
      child: body,
    );
  }
}

// profile-setup ------------------------------------------------------------------------------

/// Card family `profile-setup` (R11: completion is a supporting card, labelled as setup, never a
/// behavioural score). O title, bar, button; A Ente progress banner; B next single task;
/// C checklist; D slim row with a small ring.
class ProfileSetupCard extends ConsumerWidget {
  const ProfileSetupCard({super.key, required this.health, this.variant});

  final ProfileHealth health;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('profile-setup'));
    final l10n = context.l10n;
    final total = HealthFactor.values.length;
    final done = total - health.missing.length;
    final next = health.missing.firstOrNull;
    final title = l10n.setupTitle;
    final progress = l10n.setupProgress(done, total);
    final fraction = done / total;
    void openNext() => next == null
        ? context.push(Routes.healthAbout)
        : context.push(healthFactorRoute(next));
    BoxDecoration card() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    );
    Widget bar() => ExcludeSemantics(
      child: ClipRRect(
        borderRadius: AppRadii.all(AppRadii.pill),
        child: LinearProgressIndicator(
          value: fraction,
          minHeight: 6,
          color: AppColors.accent,
          backgroundColor: AppColors.fill,
        ),
      ),
    );
    final allDone = next == null;
    switch (v) {
      case 'A':
        return LabStatusBanner(
          variant: 'A',
          tone: allDone ? BannerTone.success : BannerTone.info,
          icon: NumayaMobileIcons.chart,
          title: allDone ? l10n.setupAllDone : title,
          body: allDone
              ? progress
              : '$progress · ${healthFactorLabel(l10n, next)}',
          onTap: openNext,
        );
      case 'B':
        return Container(
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          decoration: card(),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allDone ? l10n.setupAllDone : l10n.setupNext,
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      allDone ? progress : healthFactorLabel(l10n, next),
                      style: AppTypography.weight(
                        AppTypography.body,
                        AppTypography.semibold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!allDone)
                NumayaButton(
                  label: l10n.setupAdd,
                  small: true,
                  expand: false,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: openNext,
                ),
            ],
          ),
        );
      case 'C':
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.cardPadding,
                  AppSpacing.s2,
                  AppLayout.cardPadding,
                  AppSpacing.s1,
                ),
                child: Text(
                  '$title · $progress',
                  style: AppTypography.weight(
                    AppTypography.body,
                    AppTypography.semibold,
                  ),
                ),
              ),
              for (final f in HealthFactor.values)
                ListRow(
                  leading: health.done.contains(f)
                      ? NumayaIcons.check
                      : NumayaIcons.plus,
                  label: healthFactorLabel(l10n, f),
                  value: health.done.contains(f) ? l10n.setupDone : null,
                  onTap: health.done.contains(f)
                      ? null
                      : () => context.push(healthFactorRoute(f)),
                ),
            ],
          ),
        );
      case 'D':
        return Container(
          decoration: card(),
          child: ListRow(
            leadingMobile: NumayaMobileIcons.chart,
            label: title,
            value: progress,
            onTap: openNext,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.weight(
                        AppTypography.body,
                        AppTypography.semibold,
                      ),
                    ),
                  ),
                  Text(progress, style: AppTypography.caption),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              bar(),
              const SizedBox(height: AppSpacing.s3),
              if (allDone)
                Text(l10n.setupAllDone, style: AppTypography.bodySm)
              else
                NumayaButton(
                  label: healthFactorLabel(l10n, next),
                  small: true,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: openNext,
                ),
            ],
          ),
        );
    }
  }
}

/// One evidence-linked suggestion: evidence, a possible reading, an action, and its uncertainty.
class AdviceCard extends StatelessWidget {
  const AdviceCard({super.key, required this.advice});
  final InsightAdvice advice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MobileIcon(
                NumayaMobileIcons.bulb,
                size: AppSizes.iconMd,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.insightsAdviceTitle,
                    style: AppTypography.weight(
                      AppTypography.body,
                      AppTypography.semibold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(advice.evidence, style: AppTypography.body),
          const SizedBox(height: AppSpacing.s1),
          Text(
            advice.reading,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          if (advice.actionRoute != null)
            NumayaButton(
              label: advice.action,
              small: true,
              expand: false,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => context.push(advice.actionRoute!),
            )
          else
            Text(
              advice.action,
              style: AppTypography.weight(
                AppTypography.bodySm,
                AppTypography.semibold,
              ),
            ),
          const SizedBox(height: AppSpacing.s2),
          Text(advice.uncertainty, style: AppTypography.caption),
        ],
      ),
    );
  }
}
