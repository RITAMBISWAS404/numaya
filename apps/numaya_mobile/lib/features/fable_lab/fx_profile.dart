import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../health/domain/profile_health.dart';
import '../lab/activity_cards.dart';
import '../profile/presentation/profile_setup_card.dart';
import '../profile/presentation/profile_variants.dart';

/// Fable design lab, group `fx-profile` (docs/design/fable-lab/EXPERIMENTS.md), and the shared
/// hero used by `fx-wallet` B and `fx-streak` B.
///
/// Every number is the member's real demo state; credits lead with the number in every option
/// (owner choice r8-wallet-value A). Help and Settings stay in the title bar (r8-profile-bar O).

/// A: who you are in one row: photo, name, verification state (which opens verification while
/// unverified), then the two things you do here as an equal pair.
class FxIdentityRow extends StatelessWidget {
  const FxIdentityRow({super.key, required this.data, this.completion});

  final ProfileHeaderData data;

  /// Profile setup done, 0-100, from the real setup state (the same factors as the setup row).
  /// Null hides the pill.
  final int? completion;

  static const double _photo = 88;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ExcludeSemantics(
              child: ClipOval(
                child: SizedBox.square(
                  dimension: _photo,
                  child: data.picture(initialSize: 32),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: NameWithBadge(
                      name: data.name,
                      verified: data.verified,
                      verifiedLabel: l10n.photoVerifiedLabel,
                      style: AppTypography.headline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: [
                      data.badge(context),
                      if (completion != null)
                        StatusBadge(
                          key: const ValueKey('profile-completion-pill'),
                          label: l10n.profileCompletionLabel(completion!),
                          icon: NumayaIcons.check,
                          tone: completion == 100
                              ? BadgeTone.brand
                              : BadgeTone.neutral,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButtonGroup(
          children: [
            NumayaButton(
              key: const ValueKey('profile-header-edit'),
              label: l10n.profileEdit,
              onPressed: data.onEdit,
            ),
            NumayaButton(
              label: l10n.previewTitle,
              variant: NumayaButtonVariant.secondary,
              onPressed: data.onPreview,
            ),
          ],
        ),
      ],
    );
  }
}

String _bucketLine(AppLocalizations l10n, WalletData d) => [
  if (d.weekly > 0) '${l10n.walletWeekly} ${d.weekly}',
  if (d.earned > 0) '${l10n.walletEarned} ${d.earned}',
  if (d.purchased > 0) '${l10n.walletPurchased} ${d.purchased}',
].join(' · ');

/// The seven-step streak track. [onDark] draws it for the dark hero.
class FxStreakDots extends StatelessWidget {
  const FxStreakDots({
    super.key,
    required this.data,
    this.onDark = false,
    this.height = 6,
  });

  final StreakData data;
  final bool onDark;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      children: [
        for (var i = 0; i < data.cycle; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.s1),
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: i < data.progress
                    ? (onDark ? AppColors.accentLine : AppColors.accent)
                    : (onDark ? AppColors.heroTrack : AppColors.divider),
                borderRadius: AppRadii.all(AppRadii.pill),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// A: credits and streak as two number-first tiles, side by side while both fit (stacked at
/// large text or on a narrow phone). Each opens its own page.
class FxStatTiles extends StatelessWidget {
  const FxStatTiles({
    super.key,
    required this.wallet,
    required this.streak,
    required this.onWallet,
    required this.onStreak,
  });

  final WalletData wallet;
  final StreakData streak;
  final VoidCallback onWallet;
  final VoidCallback onStreak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = wallet.weekly + wallet.earned + wallet.purchased;
    final buckets = _bucketLine(l10n, wallet);
    // One anatomy for both tiles (owner note): outline icon, the number, its label, one short
    // line. No progress bar on either: a credit balance has no denominator to fill against.
    Widget tile({
      required Key key,
      required NumayaMobileIcons icon,
      required String number,
      required String unit,
      required String foot,
      required String spoken,
      required VoidCallback onTap,
    }) => Pressable(
      key: key,
      onTap: onTap,
      semanticLabel: spoken,
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Container(
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
                MobileIcon(
                  icon,
                  size: AppSizes.iconMd,
                  color: AppColors.accent,
                ),
                const Spacer(),
                const NumayaIcon(
                  NumayaIcons.chevronRight,
                  size: AppSizes.iconSm,
                  color: AppColors.iconSupporting,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            Text(number, style: AppTypography.hero.copyWith(height: 1)),
            const SizedBox(height: AppSpacing.s1),
            Text(
              unit,
              style: AppTypography.weight(
                AppTypography.body,
                AppTypography.semibold,
              ),
            ),
            const SizedBox(height: AppSpacing.s1),
            Text(foot, style: AppTypography.caption),
          ],
        ),
      ),
    );

    final credits = tile(
      key: const ValueKey('hub-wallet'),
      icon: NumayaMobileIcons.wallet,
      number: '$total',
      unit: l10n.walletTitle,
      foot: l10n.fxCreditsToSend(total),
      spoken: [
        l10n.walletTitle,
        l10n.walletTotal(total),
        if (buckets.isNotEmpty) buckets,
      ].join('. '),
      onTap: onWallet,
    );
    final streakTile = tile(
      key: const ValueKey('hub-streak'),
      icon: NumayaMobileIcons.flame,
      number: '${streak.length}',
      unit: l10n.fxStreakUnit(streak.length),
      foot: l10n.streakCycle(streak.progress),
      spoken: [
        l10n.streakDays(streak.length),
        l10n.streakCycle(streak.progress),
        streak.todayCounts ? l10n.streakToday : l10n.streakTodayOpen,
      ].join('. '),
      onTap: onStreak,
    );
    return LayoutBuilder(
      builder: (context, box) {
        final stacked =
            MediaQuery.textScalerOf(context).scale(10) > 13 ||
            box.maxWidth < 300;
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              credits,
              const SizedBox(height: AppSpacing.s3),
              streakTile,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: credits),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: streakTile),
            ],
          ),
        );
      },
    );
  }
}

/// The surface of a feature card.
enum FxHeroTone {
  /// Near-black (Ente's storage card, 12099:96480).
  dark,

  /// Solid brand purple: the same geometry, as a palette comparison.
  brand,
}

/// The feature card (Ente's storage card with supplied reference 2's split and research
/// reference 07's zones): a copy zone on the left, one piece of artwork in its own zone on the
/// right that rises above the card's top edge, supporting facts at full width, and one action
/// across the foot. One of these per screen at most.
///
/// Art slot: [artWidth] wide, anchored top-right, rising [artRise] above the card; the subject
/// should fill the slot's width and sit on its bottom edge. The copy zone never runs under it,
/// the art never takes touches, and at large text the art gives its room to the words.
/// The mascot used today is a stand-in: these options are artwork-pending.
class FxHeroCard extends StatelessWidget {
  const FxHeroCard({
    super.key,
    required this.label,
    required this.value,
    required this.art,
    required this.spoken,
    this.tone = FxHeroTone.dark,
    this.detail,
    this.body,
    this.action,
    this.onTap,
  });

  final String label;

  /// The large line: the number first.
  final String value;
  final String? detail;
  final FxHeroTone tone;

  /// Under the top zones, full width: labelled balances, a track.
  final Widget? body;

  /// The action across the foot. Decorative when [onTap] makes the whole card one target; a real
  /// control otherwise.
  final Widget? action;
  final NumayaIllustration art;
  final String spoken;
  final VoidCallback? onTap;

  static const double artWidth = 136;

  /// How far the artwork rises above the card. The caller leaves this much room above.
  static const double artRise = 28;

  /// The height the art zone keeps inside the card, beside the copy.
  static const double artZone = 84;

  Widget _copy(Color muted) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(label, style: AppTypography.label.copyWith(color: muted)),
      const SizedBox(height: AppSpacing.s1),
      Text(
        value,
        style: AppTypography.hero.copyWith(color: AppColors.inkForeground),
      ),
      if (detail != null)
        Text(detail!, style: AppTypography.body.copyWith(color: muted)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(10) > 13;
    final brand = tone == FxHeroTone.brand;
    // On purple every line is full white (4.90:1); the dark card can afford a muted label.
    final muted = brand ? AppColors.accentForeground : AppColors.onHeroMuted;
    final copy = Semantics(
      container: true,
      header: true,
      label: spoken,
      child: ExcludeSemantics(child: _copy(muted)),
    );
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.heroPadding),
      decoration: BoxDecoration(
        color: brand ? AppColors.accent : AppColors.surfaceHero,
        borderRadius: AppRadii.all(AppRadii.heroCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (large)
            copy
          else
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: artZone),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: copy),
                  // The art zone: kept clear; the art itself is drawn over it below.
                  const SizedBox(width: artWidth - AppSpacing.s2),
                ],
              ),
            ),
          if (body != null) ...[const SizedBox(height: AppSpacing.s4), body!],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.s4),
            action!,
          ],
        ],
      ),
    );
    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        if (!large)
          Positioned(
            top: -artRise,
            right: AppSpacing.s3,
            width: artWidth,
            height: artRise + AppLayout.heroPadding + artZone,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: KeyedSubtree(
                  key: const ValueKey('fx-hero-art'),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // On purple the purple mascot needs a stage to stay visible.
                      if (brand)
                        Container(
                          width: artWidth - 16,
                          height: artWidth - 16,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                        ),
                      FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        child: IllustrationView(art, width: artWidth),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    final padded = Padding(
      padding: const EdgeInsets.only(top: artRise),
      child: stack,
    );
    // Without [onTap] the copy zone is one spoken summary and the body and action keep their
    // own semantics (a real button stays a button).
    if (onTap == null) return padded;
    return Pressable(
      onTap: onTap,
      semanticLabel: spoken,
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.heroCard),
      child: padded,
    );
  }
}

/// The action across a feature card's foot: white with ink text and a chevron, the card's one
/// solid control.
class FxHeroPill extends StatelessWidget {
  const FxHeroPill({super.key, required this.label, this.solid = true});

  final String label;

  /// White with dark text. False draws the quiet translucent version.
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? AppColors.ink : AppColors.inkForeground;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AppSizes.buttonHeightSm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: solid ? AppColors.surface : AppColors.heroTrack,
        borderRadius: AppRadii.all(AppRadii.control),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTypography.buttonSm.copyWith(color: fg, height: 1.2),
            ),
          ),
          const SizedBox(width: AppSpacing.s1),
          NumayaIcon(
            NumayaIcons.chevronRight,
            size: AppSizes.iconSm,
            color: fg,
          ),
        ],
      ),
    );
  }
}

/// The three credit buckets as labelled numbers in spend order: the label says which is which,
/// so nothing depends on telling two purple dots apart.
class FxBalanceColumns extends StatelessWidget {
  const FxBalanceColumns({super.key, required this.data, this.onHero = true});

  final WalletData data;

  /// On a feature card (white text); false for a white surface.
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final buckets = [
      (l10n.walletWeekly, data.weekly),
      (l10n.walletEarned, data.earned),
      (l10n.walletPurchased, data.purchased),
    ];
    final number = AppTypography.card.copyWith(
      color: onHero ? AppColors.inkForeground : AppColors.ink,
    );
    final label = AppTypography.caption.copyWith(
      color: onHero ? AppColors.inkForeground : AppColors.textSecondary,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < buckets.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${buckets[i].$2}', style: number),
                Text(buckets[i].$1, style: label),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The credit buckets as one bar in spend order with its legend, for the dark hero.
class FxCreditBar extends StatelessWidget {
  const FxCreditBar({super.key, required this.data, this.onDark = true});

  final WalletData data;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = data.weekly + data.earned + data.purchased;
    final buckets = [
      (
        l10n.walletWeekly,
        data.weekly,
        onDark ? AppColors.accent : AppColors.accent,
      ),
      (
        l10n.walletEarned,
        data.earned,
        onDark
            ? AppColors.accentLine
            : AppColors.accent.withValues(alpha: 0.55),
      ),
      (
        l10n.walletPurchased,
        data.purchased,
        onDark
            ? AppColors.inkForeground
            : AppColors.accent.withValues(alpha: 0.25),
      ),
    ];
    final legend = AppTypography.caption.copyWith(
      color: onDark ? AppColors.onHeroMuted : AppColors.textSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: AppRadii.all(AppRadii.pill),
            child: SizedBox(
              height: 8,
              child: total == 0
                  ? ColoredBox(
                      color: onDark ? AppColors.heroTrack : AppColors.fill,
                    )
                  : Row(
                      children: [
                        for (final (_, n, c) in buckets)
                          if (n > 0)
                            Expanded(
                              flex: n,
                              child: Container(
                                margin: const EdgeInsets.only(right: 2),
                                color: c,
                              ),
                            ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        Wrap(
          spacing: AppSpacing.s4,
          runSpacing: AppSpacing.s1,
          children: [
            for (final (label, n, c) in buckets)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.s1),
                  Text('$label $n', style: legend),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// B (dark) and C (purple): the one feature card of the Profile tab: credits, number first.
class FxCreditHero extends StatelessWidget {
  const FxCreditHero({
    super.key,
    required this.data,
    required this.onTap,
    this.tone = FxHeroTone.dark,
  });

  final WalletData data;
  final VoidCallback onTap;
  final FxHeroTone tone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = data.weekly + data.earned + data.purchased;
    return FxHeroCard(
      key: const ValueKey('hub-wallet'),
      tone: tone,
      label: l10n.walletTitle,
      value: l10n.walletTotal(total),
      art: NumayaIllustration.mascotWaiting,
      spoken: [
        l10n.walletTitle,
        l10n.walletTotal(total),
        '${l10n.walletWeekly} ${data.weekly}',
        '${l10n.walletEarned} ${data.earned}',
        '${l10n.walletPurchased} ${data.purchased}',
      ].join(', '),
      body: FxBalanceColumns(data: data),
      action: FxHeroPill(label: l10n.fxSeeCredits),
      onTap: onTap,
    );
  }
}

/// B: the two quieter blocks under the hero: the streak and profile setup, as an equal pair.
class FxQuietPair extends StatelessWidget {
  const FxQuietPair({
    super.key,
    required this.streak,
    required this.health,
    required this.onStreak,
    required this.onSetup,
  });

  final StreakData streak;
  final ProfileHealth health;
  final VoidCallback onStreak;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = HealthFactor.values.length;
    final done = total - health.missing.length;
    final next = health.missing.firstOrNull;
    Widget block({
      required Key key,
      required String label,
      required String value,
      required Widget visual,
      required String foot,
      required String spoken,
      required VoidCallback onTap,
    }) => Pressable(
      key: key,
      onTap: onTap,
      semanticLabel: spoken,
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppLayout.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.s1),
            Text(value, style: AppTypography.card),
            const SizedBox(height: AppSpacing.s3),
            visual,
            const SizedBox(height: AppSpacing.s2),
            Text(foot, style: AppTypography.caption),
          ],
        ),
      ),
    );
    final streakBlock = block(
      key: const ValueKey('hub-streak'),
      label: l10n.streakTitle,
      value: l10n.streakDays(streak.length),
      visual: FxStreakDots(data: streak),
      foot: l10n.streakCycle(streak.progress),
      spoken: [
        l10n.streakDays(streak.length),
        l10n.streakCycle(streak.progress),
        streak.todayCounts ? l10n.streakToday : l10n.streakTodayOpen,
      ].join('. '),
      onTap: onStreak,
    );
    final setupBlock = block(
      key: const ValueKey('hub-setup'),
      label: l10n.setupTitle,
      value: l10n.setupProgress(done, total),
      visual: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: AppRadii.all(AppRadii.pill),
          child: LinearProgressIndicator(
            value: done / total,
            minHeight: 6,
            color: AppColors.accent,
            backgroundColor: AppColors.fill,
          ),
        ),
      ),
      foot: next == null
          ? l10n.setupAllDone
          : '${l10n.setupNext}: ${healthFactorLabel(l10n, next)}',
      spoken:
          '${l10n.setupTitle}, ${l10n.setupProgress(done, total)}'
          '${next == null ? '' : '. ${l10n.setupNext}: ${healthFactorLabel(l10n, next)}'}',
      onTap: onSetup,
    );
    return LayoutBuilder(
      builder: (context, box) {
        final stacked =
            MediaQuery.textScalerOf(context).scale(10) > 13 ||
            box.maxWidth < 300;
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              streakBlock,
              const SizedBox(height: AppSpacing.s3),
              setupBlock,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: streakBlock),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: setupBlock),
            ],
          ),
        );
      },
    );
  }
}
