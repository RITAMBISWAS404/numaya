import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/release_scope.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../core/time/ist.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/application/economy_controller.dart';
import '../../commerce/presentation/wallet_screen.dart';
import '../../fable_lab/fx_profile.dart';
import '../../health/application/health_providers.dart';
import '../../home/presentation/large_title_page.dart';
import '../../lab/activity_cards.dart';
import '../../lab/lab_registry.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../premium/application/premium_controller.dart';
import '../../verification/application/verification_controller.dart';
import '../application/profile_details_controller.dart';
import 'profile_header_more.dart';
import 'profile_setup_card.dart';
import 'profile_variants.dart';

/// B-23 Profile tab: the summary card (UI-042: a large round photo over the card, name,
/// verification state, Edit profile), the completion card, the profile rows (visibility,
/// verification, Premium; Opening Moves only when the release includes it, UI-031), the prompt,
/// then one support group.
/// Everything shown is what the member entered; no score or activity is invented.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final details = ref.watch(profileDetailsProvider);
    final premium = ref.watch(premiumProvider);
    final verification = ref.watch(photoVerificationProvider).status;
    final age = draft.ageOn(ref.read(onboardingProvider.notifier).today);
    final mainPhoto = draft.photos.isEmpty ? null : draft.photos.first.source;
    final initial = draft.firstName.trim().isEmpty
        ? '?'
        : draft.firstName.trim().characters.first.toUpperCase();

    ProfileHeaderData header() => ProfileHeaderData(
      photo: mainPhoto,
      initial: initial,
      name: age == null
          ? draft.firstName
          : l10n.profileNameAge(draft.firstName, age),
      verification: verification,
      onEdit: () => context.push(Routes.editProfile),
      onVerify: () => context.push(Routes.verifyPhoto),
      onPreview: () => context.push(Routes.preview),
    );
    final direction = ref.watch(labVariantProvider('screen-profile'));
    final economy = ref.watch(economyProvider);
    final now = ref.read(clockProvider)();
    final run = economy.streak.run(now);
    final cycle = ref.read(economyProvider.notifier).policy.streakCycleDays;
    final StreakData streak = (
      length: run.length,
      progress: run.progress(cycle),
      cycle: cycle,
      todayCounts: economy.streak.qualifies(istDay(now)),
    );
    final ledger = economy.ledger;
    final WalletData wallet = (
      weekly: ledger.weekly,
      earned: ledger.earned,
      purchased: ledger.purchased,
      recent: [
        for (final e in ledger.entries.reversed.take(3))
          (label: walletEntryLabel(context.l10n, e), amount: e.amount),
      ],
    );
    final health = ref.watch(profileHealthProvider);
    void toStreak() => context.push(Routes.streak);
    void toWallet() => context.push(Routes.wallet);

    // Direction-fixed component variants inside this screen (registry `requires`).
    final headerV = ref.watch(labVariantProvider('profile-header'));
    final String? setupV = switch (direction) {
      'A' => 'D',
      'C' => 'A',
      _ => null,
    };

    // 1. Identity. R06: the verified mark follows the name in every variant.
    final Widget identity = switch (headerV) {
      'A' => ProfileHeaderCover(data: header()),
      'B' => ProfileHeaderCompact(data: header()),
      'C' => ProfileHeaderWithStreak(
        data: header(),
        streakDays: run.length,
        credits: ledger.total,
        onStreak: toStreak,
        onWallet: toWallet,
      ),
      _ => _ProfileSummary(
        photo: mainPhoto,
        initial: initial,
        name: age == null
            ? draft.firstName
            : l10n.profileNameAge(draft.firstName, age),
        verification: verification,
        onEdit: () => context.push(Routes.editProfile),
        onVerify: () => context.push(Routes.verifyPhoto),
      ),
    };
    final v7 = ref.watch(labVariantProvider('v7-profile'));
    final Widget hero = switch (v7) {
      'A' => EdgeBleed(
        inset: AppLayout.screenGutter,
        child: ProfileHeaderCover(data: header(), square: true),
      ),
      'B' => ProfileHeaderCompact(data: header()),
      'C' => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          identity,
          const SizedBox(height: AppSpacing.s3),
          _ActivityStrip(
            streak: l10n.hubStreakDetail(run.length),
            credits: l10n.hubCreditsDetail(ledger.total),
            streakLabel: l10n.streakTitle,
            creditsLabel: l10n.walletTitle,
            onStreak: toStreak,
            onCredits: toWallet,
          ),
        ],
      ),
      _ => identity,
    };
    final headerHasActivity = headerV == 'C';

    final profileGroup = ListGroup(
      title: l10n.profileYourProfile,
      children: [
        if (ReleaseScope.openingMoves)
          ListRow(
            leading: NumayaIcons.message,
            label: l10n.openingMovesTitle,
            detail: l10n.openingMovesCount(details.openingMoves.length),
            onTap: () => context.push(Routes.openingMoves),
          ),
        ListRow(
          leading: NumayaIcons.verified,
          label: l10n.editVerify,
          detail: switch (verification) {
            PhotoVerificationStatus.verified => l10n.verifyStatusVerified,
            PhotoVerificationStatus.pending => l10n.verifyStatusPending,
            PhotoVerificationStatus.rejected => l10n.verifyStatusRejected,
            PhotoVerificationStatus.notStarted => l10n.verifyStatusNone,
          },
          onTap: () => context.push(Routes.verifyPhoto),
        ),
        ListRow(
          leading: NumayaIcons.premium,
          label: l10n.premiumName,
          detail: premium.active ? l10n.premiumActive : l10n.premiumExplore,
          onTap: () => context.push(Routes.premium),
        ),
      ],
    );
    final activityGroup = ListGroup(
      title: l10n.hubActivity,
      children: [
        ListRow(
          key: const ValueKey('hub-wallet'),
          leadingMobile: NumayaMobileIcons.wallet,
          label: l10n.walletTitle,
          detail: l10n.hubCreditsDetail(ledger.total),
          onTap: toWallet,
        ),
        ListRow(
          key: const ValueKey('hub-streak'),
          leadingMobile: NumayaMobileIcons.flame,
          label: l10n.streakTitle,
          detail: l10n.hubStreakDetail(run.length),
          onTap: toStreak,
        ),
      ],
    );
    final supportGroup = ListGroup(
      title: l10n.profileSafetySupport,
      children: [
        ListRow(
          leading: NumayaIcons.shield,
          label: l10n.safetyTitle,
          onTap: () => context.push(Routes.safety),
        ),
        ListRow(
          leading: NumayaIcons.help,
          label: l10n.helpTitle,
          onTap: () => context.push(Routes.help),
        ),
        ListRow(
          leading: NumayaIcons.settings,
          label: l10n.profileSettings,
          onTap: () => context.push(Routes.settings),
        ),
      ],
    );
    const gap = SizedBox(height: AppLayout.sectionGap);
    const small = SizedBox(height: AppSpacing.s3);
    final setup = ProfileSetupCard(health: health, variant: setupV);
    // Fable lab `fx-profile`: A compact hub, B credit hero (lib/features/fable_lab).
    final fx = ref.watch(labVariantProvider('fx-profile'));
    final promptSection = draft.prompt == null
        ? null
        : NumayaSection(
            title: l10n.profilePromptTitle,
            child: PromptCard(
              question: draft.prompt!.question,
              answer: draft.prompt!.answer,
              editLabel: l10n.promptEditLabel,
              onTap: () => context.push(Routes.editPrompt),
            ),
          );
    final premiumCard = premium.active
        ? _PremiumCard(
            active: premium.active,
            until: premium.activeUntil,
            onTap: () => context.push(Routes.premium),
          )
        : null;
    void openSetup() {
      final next = health.missing.firstOrNull;
      context.push(
        next == null ? Routes.completion : healthFactorRoute(next),
      );
    }
    // Owner selections wallet-card A and streak-card O, inside the selected baseline Profile.
    final activityCards = NumayaSection(
      title: l10n.hubActivity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WalletSummaryCard(data: wallet, onTap: toWallet),
          small,
          StreakSummaryCard(data: streak, onTap: toStreak),
        ],
      ),
    );

    final body = <Widget>[
      ...switch (direction) {
        // A: identity and its two actions, then credits and streak in the first screen.
        _ when fx == 'A' => [
          FxIdentityRow(data: header()),
          const SizedBox(height: AppSpacing.s5),
          FxStatTiles(
            wallet: wallet,
            streak: streak,
            onWallet: toWallet,
            onStreak: toStreak,
          ),
          small,
          ProfileSetupCard(health: health, variant: 'B'),
          gap,
          profileGroup,
          gap,
          if (promptSection != null) ...[promptSection, gap],
          if (premiumCard != null) ...[premiumCard, gap],
          supportGroup,
        ],
        // B: a short cover, one dark credit hero, then two quieter blocks.
        _ when fx == 'B' => [
          ProfileHeaderCover(data: header(), compact: true),
          small,
          FxCreditHero(data: wallet, onTap: toWallet),
          small,
          FxQuietPair(
            streak: streak,
            health: health,
            onStreak: toStreak,
            onSetup: openSetup,
          ),
          gap,
          profileGroup,
          gap,
          if (promptSection != null) ...[promptSection, gap],
          if (premiumCard != null) ...[premiumCard, gap],
          supportGroup,
        ],
        // Quiet editorial: one identity block, one line of activity, then plain groups.
        'A' => [
          hero,
          small,
          setup,
          gap,
          profileGroup,
          gap,
          activityGroup,
          gap,
          supportGroup,
        ],
        // Connected cards: each activity is its own card with one destination.
        'B' => [
          hero,
          small,
          setup,
          gap,
          if (!headerHasActivity) ...[
            StreakSummaryCard(data: streak, onTap: toStreak),
            small,
            WalletSummaryCard(data: wallet, onTap: toWallet),
            small,
          ],
          gap,
          profileGroup,
          gap,
          supportGroup,
        ],
        // Visual insights: the identity carries this week's numbers; bars for streak and credits.
        'C' => [
          hero,
          small,
          StreakSummaryCard(data: streak, onTap: toStreak, variant: 'B'),
          small,
          WalletSummaryCard(data: wallet, onTap: toWallet, variant: 'A'),
          small,
          setup,
          gap,
          profileGroup,
          gap,
          supportGroup,
        ],
        // Current-rules baseline: today's order with Your insights and the setup card.
        _ => [
          hero,
          const SizedBox(height: AppSpacing.s4),
          setup,
          gap,
          profileGroup,
          gap,
          if (!headerHasActivity) ...[activityCards, gap],
          if (draft.prompt != null) ...[
            NumayaSection(
              title: l10n.profilePromptTitle,
              child: PromptCard(
                question: draft.prompt!.question,
                answer: draft.prompt!.answer,
                editLabel: l10n.promptEditLabel,
                onTap: () => context.push(Routes.editPrompt),
              ),
            ),
            gap,
          ],
          if (premium.active) ...[
            _PremiumCard(
              active: premium.active,
              until: premium.activeUntil,
              onTap: () => context.push(Routes.premium),
            ),
            gap,
          ],
          supportGroup,
        ],
      },
    ];

    // R12: the expanded title collapses into the bar on scroll.
    return LargeTitlePage(
      title: l10n.tabProfile,
      actions: [
        // Replacement V8 comparison r8-profile-bar: A keeps Settings alone in the bar, since Help
        // is also the Safety and support row. O is the owner's V7 bar.
        if (ref.watch(labVariantProvider('r8-profile-bar')) != 'A')
          NavIconButton(
            icon: NumayaIcons.help,
            label: l10n.helpTitle,
            onPressed: () => context.push(Routes.help),
          ),
        NavIconButton(
          icon: NumayaIcons.settings,
          label: l10n.profileSettings,
          onPressed: () => context.push(Routes.settings),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: body,
      ),
    );
  }
}

/// The Premium entry (B-23 pay-plan card): what it adds, or until when it's active.
class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.active,
    required this.until,
    required this.onTap,
  });

  final bool active;
  final DateTime? until;
  final VoidCallback onTap;

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
              const IconTile(NumayaIcons.premium, tone: AccentTone.brand),
              const SizedBox(width: AppLayout.tileLabelGap),
              Expanded(
                child: Text(l10n.premiumName, style: AppTypography.emptyTitle),
              ),
              if (active)
                StatusBadge(label: l10n.premiumActive, tone: BadgeTone.brand),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            active && until != null
                ? l10n.premiumActiveUntil(
                    MaterialLocalizations.of(context).formatMediumDate(until!),
                  )
                : l10n.premiumCardBody,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: active ? l10n.premiumManage : l10n.premiumExplore,
            small: true,
            expand: false,
            variant: active
                ? NumayaButtonVariant.secondary
                : NumayaButtonVariant.brand,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

/// The Profile tab's summary card (UI-042). The photo is [diameter] across and sits half above
/// the card, ringed in the page colour so its edge reads against both the page and the card.
class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.photo,
    required this.initial,
    required this.name,
    required this.verification,
    required this.onEdit,
    required this.onVerify,
  });

  final String? photo;
  final String initial;
  final String name;
  final PhotoVerificationStatus verification;
  final VoidCallback onEdit;
  final VoidCallback onVerify;

  static const double diameter = 128;
  static const double ring = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outer = diameter + ring * 2;
    final initialText = Text(
      initial,
      style: AppTypography.hero.copyWith(
        fontSize: 48,
        height: 1,
        color: AppColors.onIdentity,
      ),
    );
    final verified = verification == PhotoVerificationStatus.verified;
    final status = switch (verification) {
      PhotoVerificationStatus.verified => l10n.verifyStatusVerified,
      PhotoVerificationStatus.pending => l10n.verifyStatusPending,
      PhotoVerificationStatus.rejected => l10n.verifyStatusRejected,
      PhotoVerificationStatus.notStarted => l10n.verifyStatusNone,
    };
    final badge = StatusBadge(
      label: status,
      icon: verified ? NumayaIcons.verified : NumayaIcons.shield,
      tone: verified ? BadgeTone.brand : BadgeTone.neutral,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The card starts at the photo's middle.
        Container(
          margin: EdgeInsets.only(top: outer / 2),
          padding: EdgeInsets.fromLTRB(
            AppLayout.heroPadding,
            outer / 2 + AppSpacing.s3,
            AppLayout.heroPadding,
            AppLayout.heroPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.heroCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: NameWithBadge(
                  name: name,
                  verified: verification == PhotoVerificationStatus.verified,
                  verifiedLabel: l10n.photoVerifiedLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Center(
                // Unverified: the pill opens verification, so the state is also the way to
                // change it.
                child: verified
                    ? badge
                    : Pressable(
                        onTap: onVerify,
                        semanticLabel: '$status. ${l10n.editVerify}',
                        excludeChildSemantics: true,
                        borderRadius: AppRadii.all(AppRadii.pill),
                        child: badge,
                      ),
              ),
              const SizedBox(height: AppSpacing.s5),
              NumayaButton(
                label: l10n.profileEdit,
                icon: NumayaIcons.edit,
                onPressed: onEdit,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ExcludeSemantics(
            child: Container(
              key: const ValueKey('profile-summary-photo'),
              width: outer,
              height: outer,
              padding: const EdgeInsets.all(ring),
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                shape: BoxShape.circle,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.identity,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: photo != null
                    ? Image(
                        image: localImage(localImageAvatar(photo!), width: 400),
                        width: diameter,
                        height: diameter,
                        fit: BoxFit.cover,
                        alignment: localImageFocus(localImageAvatar(photo!)),
                        // V4-01: a photo file that has gone (cache cleared, file deleted) shows
                        // the initial, never Flutter's red error box.
                        errorBuilder: (_, _, _) => Center(child: initialText),
                      )
                    : initialText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Direction C: streak and credits as one purple strip, each half its own target.
class _ActivityStrip extends StatelessWidget {
  const _ActivityStrip({
    required this.streak,
    required this.credits,
    required this.streakLabel,
    required this.creditsLabel,
    required this.onStreak,
    required this.onCredits,
  });

  final String streak;
  final String credits;
  final String streakLabel;
  final String creditsLabel;
  final VoidCallback onStreak;
  final VoidCallback onCredits;

  Widget _half(String label, String value, VoidCallback onTap) => Expanded(
    child: Pressable(
      onTap: onTap,
      semanticLabel: '$label, $value',
      excludeChildSemantics: true,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.section.copyWith(
                color: AppColors.accentForeground,
              ),
            ),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.accentForeground,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: AppRadii.all(AppRadii.card),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _half(streakLabel, streak, onStreak),
        _half(creditsLabel, credits, onCredits),
      ],
    ),
  );
}
