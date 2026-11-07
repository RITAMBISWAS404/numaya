import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../health/application/health_providers.dart';
import '../../home/presentation/large_title_page.dart';
import '../../lab/lab_registry.dart';
import '../../premium/application/premium_controller.dart';
import '../application/insights_providers.dart';
import '../domain/insights_fixture.dart';
import 'insight_cards.dart';

/// R11: Your insights. Visibility, activity and connection measures lead; profile setup is a
/// supporting card. Every number is labelled sample data. Free: status, restriction and its
/// resolution, and the 7-day measures. Premium: 28 and 90 days and period comparisons.
///
/// Screen group `screen-insights` (Visual Lab V2): O current-rules baseline, A quiet editorial,
/// B connected cards, C visual insights. Directions A–C fix some component variants inside this
/// screen only (documented in the registry's `requires`).
class InsightsDashboard extends ConsumerStatefulWidget {
  const InsightsDashboard({super.key});

  @override
  ConsumerState<InsightsDashboard> createState() => _InsightsDashboardState();
}

class _InsightsDashboardState extends ConsumerState<InsightsDashboard> {
  int _period = 0;
  static const _days = [7, 28, 90];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final premium = ref.watch(premiumProvider).active;
    final direction = ref.watch(labVariantProvider('screen-insights'));
    final days = _days[_period];
    final locked = !premium && days != 7;
    final s = ref.watch(insightsSnapshotProvider(locked ? 7 : days));
    final chats = ref.watch(chatCountsProvider);
    final health = ref.watch(profileHealthProvider);
    final today = ref.read(clockProvider)();
    final period = periodLabel(l10n, s.days);
    final change = s.change == null ? null : changeLabel(l10n, s);

    // Direction-fixed component variants (null: the Lab's component choice).
    final (
      String? summaryV,
      String? metricV,
      String? setupV,
    ) = switch (direction) {
      'A' => ('D', 'D', 'D'),
      'B' => (null, 'C', 'B'),
      'C' => ('A', 'A', 'A'),
      _ => (null, null, null),
    };

    final metrics = <Widget>[
      MetricWidget(
        key: const ValueKey('metric-likes'),
        icon: NumayaMobileIcons.compliment,
        label: l10n.insightsMetricLikes,
        value: s.liked,
        caption: period,
        variant: metricV,
        onTap: () => context.go(Routes.likes),
      ),
      MetricWidget(
        key: const ValueKey('metric-matches'),
        icon: NumayaMobileIcons.users,
        label: l10n.insightsMetricMatches,
        value: s.matched,
        caption: period,
        variant: metricV,
      ),
      MetricWidget(
        key: const ValueKey('metric-conversations'),
        icon: NumayaMobileIcons.chart,
        label: l10n.insightsMetricConversations,
        value: s.conversations,
        caption: l10n.insightsConversationsCaption(s.days),
        variant: metricV,
      ),
      MetricWidget(
        key: const ValueKey('metric-your-turn'),
        icon: NumayaMobileIcons.bulb,
        label: l10n.insightsMetricYourTurn,
        value: chats.yourTurn,
        caption: l10n.insightsRightNow,
        variant: metricV,
        onTap: () => context.go(Routes.messages),
      ),
      MetricWidget(
        key: const ValueKey('metric-archived'),
        icon: NumayaMobileIcons.archive,
        label: l10n.insightsMetricArchived,
        value: chats.archived,
        caption: l10n.insightsRightNow,
        variant: metricV,
        onTap: () => context.push(Routes.archive),
      ),
      MetricWidget(
        key: const ValueKey('metric-active'),
        icon: NumayaMobileIcons.flame,
        label: l10n.insightsMetricActiveDays,
        value: s.activeDays,
        caption: l10n.insightsActiveCaption(s.days),
        variant: metricV,
      ),
      MetricWidget(
        key: const ValueKey('metric-audience'),
        icon: NumayaMobileIcons.users,
        label: l10n.insightsMetricAudience,
        value: s.eligibleAudience,
        caption: l10n.insightsAudienceCaption(s.distanceKm),
        variant: metricV,
        onTap: () => context.push(Routes.settings),
      ),
    ];
    if (metricV == null || metricV == 'A') {
      // The shown measure gets its own card with daily bars only where bars are the variant.
      metrics.insert(
        0,
        MetricWidget(
          key: const ValueKey('metric-shown'),
          icon: NumayaMobileIcons.eye,
          label: l10n.insightsMetricShown,
          value: s.shown,
          caption: period,
          change: change,
          daily: s.daily.length <= 7 ? s.daily : null,
          endDate: today,
          variant: metricV,
        ),
      );
    }

    Widget metricLayout() {
      final v = metricV ?? ref.watch(labVariantProvider('metric-widget'));
      if (v == 'B' || v == 'C' || v == 'D') {
        // Rows, change cards and large numbers read best one per line.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final m in metrics) ...[
              m,
              if (v == 'D')
                const ExcludeSemantics(
                  child: SizedBox(
                    height: AppBorders.hairline,
                    child: ColoredBox(color: AppColors.divider),
                  ),
                )
              else
                const SizedBox(height: AppSpacing.s2),
            ],
          ],
        );
      }
      return LayoutBuilder(
        builder: (context, box) {
          final two =
              box.maxWidth >= 300 &&
              MediaQuery.textScalerOf(context).scale(15) < 24;
          final w = two ? (box.maxWidth - AppSpacing.s3) / 2 : box.maxWidth;
          return Wrap(
            spacing: AppSpacing.s3,
            runSpacing: AppSpacing.s3,
            children: [for (final m in metrics) SizedBox(width: w, child: m)],
          );
        },
      );
    }

    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sectionGap,
        bottom: AppSpacing.s3,
      ),
      child: Semantics(
        header: true,
        child: Text(title, style: AppTypography.section),
      ),
    );

    final content = locked
        ? _LockedPeriod(days: days)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InsightsSummary(
                key: const ValueKey('insights-summary'),
                s: s,
                yourTurn: chats.yourTurn,
                endDate: today,
                variant: summaryV,
              ),
              if (direction == 'C' && s.hasData) ...[
                const SizedBox(height: AppSpacing.s3),
                Container(
                  padding: const EdgeInsets.all(AppLayout.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.all(AppRadii.card),
                  ),
                  child: InsightsFunnel(s: s),
                ),
              ],
              section(l10n.insightsActivityTitle),
              metricLayout(),
              if (s.advice != null) ...[
                section(l10n.insightsAdviceSection),
                AdviceCard(advice: s.advice!),
              ],
            ],
          );

    return LargeTitlePage(
      title: l10n.insightsDashTitle,
      onBack: () => context.pop(),
      backLabel: l10n.back,
      tabRoot: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.s3,
            runSpacing: AppSpacing.s2,
            children: [
              const SampleDataTag(),
              TextLink(
                label: l10n.insightsHowItWorks,
                muted: true,
                onPressed: () => context.push(Routes.healthAbout),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaSegmented(
            label: l10n.insightsPeriodLabel,
            selected: _period,
            onSelect: (i) => setState(() => _period = i),
            options: [
              for (final d in _days)
                (
                  label: d == 7 || premium
                      ? l10n.insightsDays(d)
                      : l10n.insightsDaysLocked(d),
                  count: null,
                  key: ValueKey('period-$d'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          content,
          section(l10n.setupSection),
          ProfileSetupCard(health: health, variant: setupV),
          const SizedBox(height: AppSpacing.s4),
          Text(l10n.insightsFootnote, style: AppTypography.caption),
        ],
      ),
    );
  }
}

/// 28 and 90 days for free members: what Premium adds, while the 7-day view stays complete.
class _LockedPeriod extends StatelessWidget {
  const _LockedPeriod({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      key: const ValueKey('insights-locked'),
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.insightsLockedTitle(days),
            style: AppTypography.weight(
              AppTypography.body,
              AppTypography.semibold,
            ),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            l10n.insightsLockedBody,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          NumayaButton(
            label: l10n.insightsLockedCta,
            small: true,
            onPressed: () => context.push(
              '${Routes.paywall}?feature=${PremiumFeature.insights.name}',
            ),
          ),
        ],
      ),
    );
  }
}

/// The scenario name for the Lab and the Demo Hub.
String scenarioName(InsightsScenario s) => switch (s) {
  InsightsScenario.newAccount => 'New account, not enough data',
  InsightsScenario.typical => 'Typical week',
  InsightsScenario.limitedAudience => 'Lower exposure, small audience',
  InsightsScenario.paused => 'Paused profile',
  InsightsScenario.restricted => 'Restricted by Numaya',
  InsightsScenario.fewLikes => 'Normal exposure, few likes',
  InsightsScenario.premiumHistory => 'Premium, 28-day history',
};
