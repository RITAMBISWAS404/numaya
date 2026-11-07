import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';
import '../../premium/application/premium_controller.dart';
import '../application/health_providers.dart';
import '../domain/profile_health.dart';

String healthFactorLabel(AppLocalizations l10n, HealthFactor f) => switch (f) {
  HealthFactor.basics => l10n.healthFactorBasics,
  HealthFactor.photos => l10n.healthFactorPhotos,
  HealthFactor.bio => l10n.healthFactorBio,
  HealthFactor.firstPrompt => l10n.healthFactorPrompt,
  HealthFactor.thirdPhoto => l10n.healthFactorThirdPhoto,
  HealthFactor.secondPrompt => l10n.healthFactorSecondPrompt,
};

String healthFactorRoute(HealthFactor f) => switch (f) {
  HealthFactor.basics => Routes.editBasics,
  HealthFactor.photos || HealthFactor.thirdPhoto => Routes.editPhotos,
  HealthFactor.bio => Routes.editProfile,
  HealthFactor.firstPrompt => '${Routes.editPrompt}?slot=0',
  HealthFactor.secondPrompt => '${Routes.editPrompt}?slot=1',
};

String discoveryStatusLabel(AppLocalizations l10n, DiscoveryStatus s) =>
    switch (s) {
      DiscoveryStatus.visible => l10n.healthStatusVisible,
      DiscoveryStatus.paused => l10n.healthStatusPaused,
      DiscoveryStatus.incomplete => l10n.healthStatusIncomplete,
      DiscoveryStatus.underReview => l10n.healthStatusReview,
      DiscoveryStatus.restricted => l10n.healthStatusRestricted,
      DiscoveryStatus.unknown => l10n.healthStatusUnknown,
    };

/// S29: the 0-100 setup score, discovery status (separate), free last-7-day counts and the way to
/// Premium depth. Ente "Pick up again … 40% reviewed" progress card shape (Banners 14590:125265).
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final health = ref.watch(profileHealthProvider);
    final status = ref.watch(discoveryStatusProvider);
    final week = ref.watch(insightsProvider(7));
    final premium = ref.watch(premiumProvider).active;
    ref.watch(datingProvider);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.healthTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.healthSubtitle, style: AppTypography.helper),
                const SizedBox(height: AppSpacing.s1),
                Semantics(
                  label: l10n.healthScore(health.score),
                  excludeSemantics: true,
                  child: Text(
                    '${health.score}',
                    style: AppTypography.pageTitle,
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: AppRadii.all(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: health.score / 100,
                      minHeight: 8,
                      color: AppColors.accent,
                      backgroundColor: AppColors.divider,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(l10n.healthNotRanking, style: AppTypography.bodySm),
                const SizedBox(height: AppSpacing.s2),
                TextLink(
                  label: l10n.healthHow,
                  onPressed: () => context.push(Routes.healthAbout),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.healthStatusTitle,
            children: [
              ListRow(
                key: const ValueKey('health-status'),
                leading: status == DiscoveryStatus.visible
                    ? NumayaIcons.check
                    : NumayaIcons.info,
                tone: status == DiscoveryStatus.visible
                    ? AccentTone.positive
                    : AccentTone.neutral,
                label: discoveryStatusLabel(l10n, status),
                detail: status == DiscoveryStatus.unknown
                    ? l10n.healthUnknownBody
                    : null,
                onTap: switch (status) {
                  DiscoveryStatus.restricted => () => context.push(
                    Routes.accountBlocked,
                  ),
                  DiscoveryStatus.paused => () => context.push(Routes.privacy),
                  _ => () => context.push(Routes.healthAbout),
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.healthImprove,
            children: [
              if (health.missing.isEmpty)
                ListRow(
                  leading: NumayaIcons.check,
                  tone: AccentTone.positive,
                  label: l10n.healthAllDone,
                )
              else
                for (final f in health.missing)
                  ListRow(
                    leading: NumayaIcons.plus,
                    label: healthFactorLabel(l10n, f),
                    value: '+${f.points}',
                    onTap: () => context.push(healthFactorRoute(f)),
                  ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.healthWeek,
            footnote: week.sample ? l10n.healthSampleData : null,
            children: [
              ListRow(
                leading: NumayaIcons.heart,
                label: l10n.insightsLikes,
                value: '${week.likes}',
              ),
              ListRow(
                leading: NumayaIcons.star,
                label: l10n.insightsMatches,
                value: '${week.matches}',
              ),
              ListRow(
                leading: NumayaIcons.message,
                label: l10n.insightsConversations,
                value: '${week.conversations}',
              ),
              ListRow(
                leadingMobile: NumayaMobileIcons.chart,
                tone: AccentTone.brand,
                label: premium ? l10n.insightsTitle : l10n.healthPremiumDepth,
                onTap: () => context.push(Routes.insights),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// S30: every factor with its points, the actual restriction state (free, never the reporter or
/// security detail) and links to fix setup or appeal.
class HealthAboutScreen extends ConsumerWidget {
  const HealthAboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final health = ref.watch(profileHealthProvider);
    final status = ref.watch(discoveryStatusProvider);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.healthAboutTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Text(l10n.healthAboutBody, style: AppTypography.body),
          const SizedBox(height: AppSpacing.s2),
          Text(l10n.healthNotRanking, style: AppTypography.helper),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            children: [
              for (final f in HealthFactor.values)
                ListRow(
                  leading: health.done.contains(f)
                      ? NumayaIcons.check
                      : NumayaIcons.plus,
                  tone: health.done.contains(f)
                      ? AccentTone.positive
                      : AccentTone.neutral,
                  label: healthFactorLabel(l10n, f),
                  value: l10n.healthPoints(
                    health.done.contains(f) ? f.points : 0,
                    f.points,
                  ),
                  onTap: health.done.contains(f)
                      ? null
                      : () => context.push(healthFactorRoute(f)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.healthRestrictionsTitle,
            children: [
              if (status == DiscoveryStatus.restricted)
                ListRow(
                  leading: NumayaIcons.alert,
                  tone: AccentTone.danger,
                  label: l10n.healthRestricted,
                  onTap: () => context.push(Routes.accountBlocked),
                )
              else if (status == DiscoveryStatus.unknown)
                ListRow(
                  leading: NumayaIcons.info,
                  label: l10n.healthStatusUnknown,
                  detail: l10n.healthUnknownBody,
                )
              else
                ListRow(
                  leading: NumayaIcons.shield,
                  tone: AccentTone.positive,
                  label: l10n.healthNoRestrictions,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// S31: views, likes, matches and conversations by period. Free: 7 days. Premium: 28 and 90 days
/// and a views-to-likes rate, labelled low-sample under 20 exposures. Never reveals identities.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  static const _ranges = [7, 28, 90];
  int _range = 7;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final premium = ref.watch(premiumProvider).active;
    final r = ref.watch(insightsProvider(_range));
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.insightsTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ViewTabs(
            label: l10n.insightsTitle,
            bleed: AppLayout.screenGutter,
            selected: _ranges.indexOf(_range),
            onSelect: (i) {
              final days = _ranges[i];
              if (days != 7 && !premium) {
                context.push(
                  '${Routes.paywall}?feature=${PremiumFeature.insights.name}',
                );
                return;
              }
              setState(() => _range = days);
            },
            options: [
              // Free: 28 and 90 open the paywall; the banner below says they are Premium.
              for (final d in _ranges)
                (label: l10n.insightsRange(d), count: null),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          if (r.sample) ...[
            StatusBanner(title: l10n.healthSampleData),
            const SizedBox(height: AppSpacing.s4),
          ],
          ListGroup(
            children: [
              ListRow(
                leading: NumayaIcons.user,
                label: l10n.insightsViews,
                detail: l10n.insightsViewsNote,
                value: '${r.views}',
              ),
              ListRow(
                leading: NumayaIcons.heart,
                label: l10n.insightsLikes,
                value: '${r.likes}',
              ),
              ListRow(
                leading: NumayaIcons.star,
                label: l10n.insightsMatches,
                value: '${r.matches}',
              ),
              ListRow(
                leading: NumayaIcons.message,
                label: l10n.insightsConversations,
                value: '${r.conversations}',
              ),
              if (premium)
                ListRow(
                  key: const ValueKey('insights-rate'),
                  leadingMobile: NumayaMobileIcons.chart,
                  tone: AccentTone.brand,
                  label: l10n.insightsRate,
                  detail: r.rate.lowSample
                      ? l10n.insightsLowSample(r.rate.exposures)
                      : null,
                  value: r.rate.percent == null
                      ? '–'
                      : l10n.insightsRateValue(r.rate.percent!),
                ),
            ],
          ),
          if (!premium) ...[
            const SizedBox(height: AppSpacing.s4),
            StatusBanner(
              tone: BannerTone.info,
              title: l10n.insightsLocked,
              action: NumayaButton(
                label: l10n.premiumSeePlans,
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => context.push(
                  '${Routes.paywall}?feature=${PremiumFeature.insights.name}',
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s4),
          Text(l10n.insightsCaveat, style: AppTypography.helper),
        ],
      ),
    );
  }
}
