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
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MobileIcon(
                      NumayaMobileIcons.flame,
                      size: 28,
                      filled: run.length > 0,
                      color: run.length > 0
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.streakDays(run.length),
                          style: AppTypography.pageTitle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),
                _CycleDots(done: progress, total: cycle),
                const SizedBox(height: AppSpacing.s3),
                Text(l10n.streakCycle(progress), style: AppTypography.bodySm),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  todayCounts ? l10n.streakToday : l10n.streakTodayOpen,
                  style: AppTypography.helper,
                ),
              ],
            ),
          ),
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
  const _CycleDots({required this.done, required this.total});

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
                    color: i < done ? AppColors.accent : AppColors.divider,
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
