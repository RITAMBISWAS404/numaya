import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/time/ist.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/application/economy_controller.dart';
import '../../commerce/domain/catalog.dart';
import '../../commerce/presentation/store_screens.dart';
import '../../dating/application/dating_controller.dart';
import '../../fable_lab/fx_profile.dart';
import '../../fable_lab/fx_wallet_streak.dart';
import '../../lab/lab_registry.dart';
import '../../premium/application/premium_controller.dart';
import '../domain/streak.dart';

/// S32: the seven-day cycle, what counts, the reward, and recovery when it is open. Mobbin
/// references: WHOOP "Day Streak" (week row with day marks), Cal AI "streak lost" (plain recovery
/// framing). Translated into Numaya's cards; no flames-and-confetti pressure, no shame copy.
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final economy = ref.watch(economyProvider);
    ref.watch(datingProvider);
    final controller = ref.read(economyProvider.notifier);
    final now = ref.read(clockProvider)();
    final streak = economy.streak;
    final run = streak.run(now);
    final cycle = controller.policy.streakCycleDays;
    final progress = run.progress(cycle);
    final today = istDay(now);
    final todayCounts = streak.qualifies(today);
    final offer = controller.recoveryOffer();
    final price = formatInr(
      ref.watch(catalogProvider).product(ProductKind.streakRecovery).pricePaise,
    );
    final dating = ref.read(datingProvider.notifier);
    // Review completion counts only when there is no one to decide on and no chat to write in.
    final reviewEligible =
        !todayCounts &&
        dating.queue().isEmpty &&
        dating.conversations().isEmpty &&
        dating.newMatches().isEmpty;
    final capped = economy.lastAward?.result == AwardResult.skippedAtCap;

    final hero = ref.watch(labVariantProvider('v6-streak-hero')) == 'A';
    final v7 = ref.watch(labVariantProvider('v7-streak'));
    // Fable lab `fx-streak`: A the week as seven numbered days; B the next credit as a feature card.
    final fx = ref.watch(labVariantProvider('fx-streak'));
    final todayLine = todayCounts ? l10n.streakToday : l10n.streakTodayOpen;
    final toGo = cycle - progress;
    final fg = hero ? AppColors.accentForeground : AppColors.ink;
    final head = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MobileIcon(
              NumayaMobileIcons.flame,
              size: 28,
              filled: run.length > 0,
              color: hero
                  ? AppColors.accentForeground
                  : run.length > 0
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.streakDays(run.length),
                  style: AppTypography.pageTitle.copyWith(color: fg),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        _CycleDots(done: progress, total: cycle, onAccent: hero),
        const SizedBox(height: AppSpacing.s3),
        Text(
          l10n.streakCycle(progress),
          style: AppTypography.bodySm.copyWith(color: fg),
        ),
        const SizedBox(height: AppSpacing.s1),
        Text(
          todayCounts ? l10n.streakToday : l10n.streakTodayOpen,
          style: AppTypography.helper.copyWith(color: hero ? fg : null),
        ),
      ],
    );
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.streakTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          if (fx == 'A')
            WhiteCard(
              padding: const EdgeInsets.all(AppLayout.heroPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    label: l10n.streakDays(run.length),
                    child: ExcludeSemantics(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('${run.length}', style: AppTypography.metric),
                          const SizedBox(width: AppSpacing.s2),
                          Expanded(
                            child: Text(
                              l10n.fxStreakUnit(run.length),
                              style: AppTypography.card,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  FxWeekStrip(
                    done: progress,
                    total: cycle,
                    spoken: '${l10n.streakCycle(progress)}. $todayLine',
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(todayLine, style: AppTypography.bodySm),
                  Text(l10n.fxNextCreditIn(toGo), style: AppTypography.helper),
                ],
              ),
            )
          else if (fx == 'B')
            FxHeroCard(
              label: toGo == 0 ? l10n.fxNextCredit : l10n.fxNextCreditInLabel,
              value: l10n.fxDaysToGo(toGo),
              detail: l10n.streakDays(run.length),
              art: NumayaIllustration.mascotCheer,
              spoken: [
                l10n.streakDays(run.length),
                l10n.fxNextCreditIn(toGo),
                todayLine,
              ].join('. '),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CycleDots(done: progress, total: cycle, onAccent: true),
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    '${l10n.streakCycle(progress)} · $todayLine',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.inkForeground,
                    ),
                  ),
                ],
              ),
            )
          else if (v7 == 'A')
            Column(
              children: [
                Text(
                  '${run.length}',
                  style: AppTypography.hero.copyWith(
                    fontSize: 64,
                    height: 72 / 64,
                  ),
                ),
                Text(l10n.v7StreakDays, style: AppTypography.section),
                const SizedBox(height: AppSpacing.s4),
                _CycleDots(done: progress, total: cycle),
              ],
            )
          else if (v7 == 'B')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.streakDays(run.length),
                  style: AppTypography.flowTitle,
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(l10n.streakCycle(progress), style: AppTypography.body),
                Text(
                  todayCounts ? l10n.streakToday : l10n.streakTodayOpen,
                  style: AppTypography.helper,
                ),
              ],
            )
          else if (v7 == 'C')
            Container(
              padding: const EdgeInsets.all(AppLayout.heroPadding),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: AppRadii.all(AppRadii.heroCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.streakDays(run.length),
                    style: AppTypography.pageTitle.copyWith(
                      color: AppColors.accentForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < cycle; i++)
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < progress
                                ? AppColors.accentForeground
                                : const Color(0x33FFFFFF),
                          ),
                          alignment: Alignment.center,
                          child: i < progress
                              ? const NumayaIcon(
                                  NumayaIcons.check,
                                  size: 18,
                                  color: AppColors.accent,
                                )
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    l10n.streakCycle(progress),
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.accentForeground,
                    ),
                  ),
                ],
              ),
            )
          else
            hero
                ? Container(
                    padding: const EdgeInsets.all(AppLayout.heroPadding),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: AppRadii.all(AppRadii.heroCard),
                    ),
                    child: head,
                  )
                : WhiteCard(child: head),
          if (offer != null) ...[
            const SizedBox(height: AppSpacing.s4),
            StatusBanner(
              key: const ValueKey('streak-recovery'),
              tone: BannerTone.info,
              title: l10n.streakRecoverTitle(istDayLabel(offer.missedDay)),
              body: l10n.streakRecoverBody(
                shortDateTime(offer.deadline),
                offer.resultingLength,
              ),
              action: NumayaButton(
                label: l10n.streakRecoverAction(price),
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => context.push(Routes.storeRecovery),
              ),
            ),
          ],
          if (capped) ...[
            const SizedBox(height: AppSpacing.s4),
            StatusBanner(
              key: const ValueKey('streak-capped'),
              title: l10n.streakCapTitle,
              body: l10n.streakCapBody(controller.policy.earnedCap),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.streakHowTitle,
            footnote: '${l10n.streakReward} ${l10n.streakKeep}',
            children: [
              ListRow(
                leading: NumayaIcons.heart,
                label: l10n.streakHowDecide,
                detail:
                    '${streak.activity(today).decisions.length.clamp(0, controller.policy.streakDecisionsPerDay)}/${controller.policy.streakDecisionsPerDay}',
                onTap: () => context.go(Routes.home),
              ),
              ListRow(
                leading: NumayaIcons.message,
                label: l10n.streakHowMessage,
                onTap: () => context.go(Routes.messages),
              ),
              ListRow(
                leading: NumayaIcons.user,
                label: l10n.streakHowReview,
                detail: streak.activity(today).reviewCompleted
                    ? l10n.streakReviewDone
                    : null,
                onTap: reviewEligible
                    ? () async {
                        await context.push(Routes.preview);
                        if (!context.mounted) return;
                        controller.recordReview(eligible: true);
                        NumayaToast.show(context, l10n.streakReviewDone);
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLink(
              label: l10n.walletTitle,
              onPressed: () => context.push(Routes.wallet),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seven marks for the current cycle: filled for days done.
class _CycleDots extends StatelessWidget {
  const _CycleDots({
    required this.done,
    required this.total,
    this.onAccent = false,
  });

  final bool onAccent;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.streakCycle(done),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: i < done
                        ? (onAccent
                              ? AppColors.accentForeground
                              : AppColors.accent)
                        : (onAccent ? const Color(0x4DFFFFFF) : AppColors.fill),
                    borderRadius: AppRadii.all(AppRadii.pill),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
