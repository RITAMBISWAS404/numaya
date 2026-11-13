import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/design_system/design_system.dart';
import '../../core/time/ist.dart';
import '../../l10n/l10n.dart';
import '../commerce/application/economy_controller.dart';
import '../onboarding/application/onboarding_controller.dart';
import '../profile/application/profile_details_controller.dart';
import '../profile/domain/profile_details.dart';
import 'lab_registry.dart';

/// UI-078 (V8): the real figures behind the three statistics cards, read from the same providers
/// as the Wallet, Streak and Complete your profile screens. Nothing here is invented.
({StatData credits, StatData streak, StatData completion}) statFamily(
  WidgetRef ref,
  AppLocalizations l10n,
) {
  final economy = ref.watch(economyProvider);
  final controller = ref.read(economyProvider.notifier);
  final ledger = economy.ledger;
  final cap = controller.policy.earnedCap;
  final now = ref.read(clockProvider)();
  final run = economy.streak.run(now);
  final cycle = controller.policy.streakCycleDays;
  final progress = run.progress(cycle);
  final todayCounts = economy.streak.qualifies(istDay(now));
  final completion = ProfileCompletion.of(
    ref.watch(onboardingProvider.select((s) => s.draft)),
    ref.watch(profileDetailsProvider),
  );
  final done = completion.parts.where((p) => p.complete).length;
  return (
    credits: StatData(
      icon: NumayaMobileIcons.wallet,
      heading: l10n.walletTitle,
      value: '${ledger.total}',
      unit: l10n.walletUnit(ledger.total),
      detail: [
        '${l10n.walletWeekly} ${ledger.weekly}',
        '${l10n.walletEarned} ${ledger.earned}',
        '${l10n.walletPurchased} ${ledger.purchased}',
      ].join(' · '),
      // A balance has no denominator; the earned bucket does (its cap).
      progress: cap == 0 ? null : ledger.earned / cap,
      progressLabel: l10n.v8StatEarnedOf(ledger.earned, cap),
      parts: [
        (ledger.weekly, true),
        (ledger.earned, true),
        (ledger.purchased, true),
      ],
      partsLabel: l10n.walletOrder,
      // Cadence: one mark per earnable credit, filled for those earned (a real cap).
      marks: [for (var i = 0; i < cap; i++) i < ledger.earned],
      marksLabel: l10n.v8StatEarnedOf(ledger.earned, cap),
      slot: 'stat_credits',
    ),
    streak: StatData(
      icon: NumayaMobileIcons.flame,
      iconFilled: run.length > 0,
      heading: l10n.streakTitle,
      value: '${run.length}',
      unit: l10n.v8StatDayStreak(run.length),
      detail: l10n.streakCycle(progress),
      note: todayCounts ? l10n.streakToday : l10n.streakTodayOpen,
      progress: progress / cycle,
      progressLabel: l10n.streakCycle(progress),
      parts: [for (var i = 0; i < cycle; i++) (1, i < progress)],
      slot: 'stat_streak',
    ),
    completion: StatData(
      icon: NumayaMobileIcons.chart,
      heading: l10n.v8StatProfile,
      value: '${completion.percent}%',
      unit: l10n.v8StatComplete,
      detail: l10n.v8StatPartsDone(done, completion.parts.length),
      progress: completion.percent / 100,
      progressLabel: l10n.v8StatPartsDone(done, completion.parts.length),
      parts: [for (final p in completion.parts) (1, p.complete)],
      slot: 'stat_completion',
    ),
  );
}

/// The template the lab has chosen for statistics cards, or null for each screen's selected
/// card (O).
StatTemplate? chosenStatTemplate(WidgetRef ref) =>
    switch (ref.watch(labVariantProvider('v8-stats'))) {
      'T1' => StatTemplate.number,
      'T2' => StatTemplate.rail,
      'T3' => StatTemplate.ring,
      'T4' => StatTemplate.cadence,
      'T5' => StatTemplate.sideArt,
      'T6' => StatTemplate.split,
      _ => null,
    };

/// DEVELOPMENT ONLY (UI-078 review): the chosen template, or all six, for credits, streak and
/// profile completion with the account's real figures, one family per template.
class StatTemplatesScreen extends ConsumerWidget {
  const StatTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final f = statFamily(ref, l10n);
    final chosen = chosenStatTemplate(ref);
    final templates = chosen == null ? StatTemplate.values : [chosen];
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.demo),
        backLabel: l10n.back,
        title: l10n.v8StatReviewTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final t in templates) ...[
            const SizedBox(height: AppSpacing.s4),
            if (templates.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s2),
                child: Text('T${t.index + 1}', style: AppTypography.section),
              ),
            for (final d in [f.credits, f.streak, f.completion]) ...[
              StatCard(data: d, template: t),
              const SizedBox(height: AppSpacing.s3),
            ],
          ],
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}
