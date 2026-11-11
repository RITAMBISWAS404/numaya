import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../health/domain/profile_health.dart';
import '../../lab/lab_banners.dart';
import '../../lab/lab_registry.dart';

/// Profile setup: a practical aid that lists what is left to add. It is not a score and not a
/// Health feature (Events PRD §4; owner's Visual Lab choice D, slim row).

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
        ? context.push(Routes.completion)
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
        // V9: an information card whose one tap opens the next step; no button inside it.
        return StatCard(
          key: const ValueKey('profile-setup-card'),
          icon: NumayaMobileIcons.chart,
          title: title,
          value: progress,
          description: allDone
              ? l10n.setupAllDone
              : l10n.v9SetupNextItem(healthFactorLabel(l10n, next)),
          visual: bar(),
          art: SceneArt(
            ArtScene.profile,
            width: StatCard.artWidth,
            progress: fraction,
          ),
          onTap: openNext,
        );
    }
  }
}
