import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart';

/// EXP-001 match moment: the three alternatives to the refined candidate's body. Every variant
/// keeps the same task: see who you matched with, then Open chat (primary) or View profile in
/// the shared footer, or Close. Only the composition above the footer changes.
///
/// [enter] is the screen's one-shot entrance (any touch finishes it; reduced motion skips it).
typedef MatchEnter = Widget Function(
  Widget child, {
  required double from,
  double rise,
});

/// Shared interests as a centred chip row, without a card (A and B).
class _SharedChips extends StatelessWidget {
  const _SharedChips({required this.person});

  final SamplePerson person;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const ValueKey('match-shared-interests'),
      alignment: WrapAlignment.center,
      spacing: AppSpacing.s2,
      runSpacing: AppSpacing.s2,
      children: [
        // V4-03: on the grey page the chip is white (onPage), so its shape reads.
        for (final s in person.shared)
          InfoChip(label: s, emoji: kInterestEmoji[s], onPage: true),
      ],
    );
  }
}

/// A 3:4 portrait card: the person's photo, or their initial on the photo grey.
class _Portrait extends StatelessWidget {
  const _Portrait({
    super.key,
    required this.label,
    required this.initial,
    required this.width,
    this.image,
    this.fill = false,
    this.initialSize,
  });

  final String label;
  final String initial;
  final double width;
  final Widget? image;

  /// Fill the space given (the photo hero), with no frame or fixed ratio.
  final bool fill;
  final double? initialSize;

  @override
  Widget build(BuildContext context) {
    final glyph = ColoredBox(
      color: AppColors.photo,
      // In the photo hero the name sits on the lower part; the initial stays above it.
      child: Align(
        alignment: fill ? const Alignment(0, -0.45) : Alignment.center,
        child: ExcludeSemantics(
          child: Text(
            initial,
            textScaler: TextScaler.noScaling,
            style: AppTypography.weight(AppTypography.hero, AppTypography.bold)
                .copyWith(
                  fontSize: AppTypography.even(initialSize ?? width * 0.3),
                  height: 1,
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ),
    );
    if (fill) {
      return PhotoPlaceholder(
        label: label,
        aspectRatio: null,
        radius: AppRadii.heroCard,
        child: image ?? glyph,
      );
    }
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: AppRadii.all(AppRadii.heroCard + 4),
        color: AppColors.surface,
        boxShadow: AppElevation.floating,
      ),
      padding: const EdgeInsets.all(4),
      child: PhotoPlaceholder(
        label: label,
        aspectRatio: AppMedia.personPhoto,
        radius: AppRadii.heroCard,
        child: image ?? glyph,
      ),
    );
  }
}

/// A — Paired portraits (Bumble "What a match!", Mobbin d0a3d260): both people as two slightly
/// tilted portrait cards meeting in the middle, with a heart mark on the seam; the headline
/// names both people. Axis: **relationship** (the two of you), not the other person alone.
class MatchPairedPortraits extends StatelessWidget {
  const MatchPairedPortraits({
    super.key,
    required this.person,
    required this.ownInitial,
    required this.ownName,
    required this.enter,
    this.ownPhoto,
  });

  final SamplePerson person;
  final String ownInitial;
  final String ownName;
  final Widget? ownPhoto;
  final MatchEnter enter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screen = MediaQuery.sizeOf(context);
    final column =
        math.min(screen.width, AppSpacing.contentMax) -
        2 * AppLayout.screenGutter;
    // Two cards overlap by a fifth of their width; their height never exceeds 36% of the
    // screen, so the line, interests and both actions stay in view.
    final card = math.min(
      column * 0.5,
      screen.height * 0.36 * AppMedia.personPhoto,
    );
    final reduced = AppMotion.reduced(context);
    Widget tilt(Widget child, double turns) => reduced
        ? child
        : Transform.rotate(angle: turns * 2 * math.pi, child: child);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.s4),
        enter(
          Center(
            child: SizedBox(
              width: card * 1.8,
              height: card / AppMedia.personPhoto + AppSpacing.s6,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    top: AppSpacing.s3,
                    child: tilt(
                      _Portrait(
                        label: ownName,
                        initial: ownInitial,
                        width: card,
                        image: ownPhoto,
                      ),
                      -0.016,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: tilt(
                      _Portrait(
                        label: l10n.discoverPhotoLabel(person.name, 1),
                        initial: person.initial,
                        width: card,
                        image: personPhotoImage(person, 1),
                      ),
                      0.016,
                    ),
                  ),
                  // The seam mark: decorative, the headline says it.
                  Positioned(
                    bottom: 0,
                    child: ExcludeSemantics(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.canvas, width: 4),
                        ),
                        alignment: Alignment.center,
                        child: const NumayaIcon(
                          NumayaIcons.heart,
                          size: AppSizes.iconMd,
                          color: AppColors.accentForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          from: 0.05,
          rise: 0,
        ),
        const SizedBox(height: AppSpacing.s5),
        enter(
          Text(
            l10n.matchPairTitle(person.name),
            textAlign: TextAlign.center,
            style: AppTypography.headline,
          ),
          from: 0.2,
        ),
        const SizedBox(height: AppSpacing.s2),
        enter(
          Text(
            l10n.matchPairBody,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          from: 0.25,
        ),
        if (person.shared.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s4),
          enter(_SharedChips(person: person), from: 0.3),
        ],
        const SizedBox(height: AppSpacing.s2),
      ],
    );
  }
}

/// B — Identity-led photo hero (Numaya's own Discover card, Bumble's photo-first identity): the
/// person's photo fills the column with their name, age and verification on it, as on their
/// card in Discover, so the match is recognisably *them*. Axis: **scale and immersion**.
class MatchIdentityHero extends StatelessWidget {
  const MatchIdentityHero({
    super.key,
    required this.person,
    required this.enter,
  });

  final SamplePerson person;
  final MatchEnter enter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screen = MediaQuery.sizeOf(context);
    // The photo takes up to 54% of the screen height; the line and interests scroll above the
    // pinned actions.
    final height = screen.height * 0.54;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.s2),
        enter(
          SizedBox(
            height: height,
            child: ClipRRect(
              borderRadius: AppRadii.all(AppRadii.heroCard),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // No photo: the person's initial, as in the refined candidate's match photo.
                  _Portrait(
                    key: const ValueKey('match-photo'),
                    label: l10n.discoverPhotoLabel(person.name, 1),
                    initial: person.initial,
                    width: double.infinity,
                    initialSize: height * 0.24,
                    fill: true,
                    image: personPhotoImage(person, 1),
                  ),
                  // The name sits on a scrim that grows with it (TC-07).
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: PhotoScrim(
                      fade: 120,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s5,
                        0,
                        AppSpacing.s5,
                        AppSpacing.s5,
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n.profileNameAge(person.name, person.age),
                              style: AppTypography.weight(
                                AppTypography.hero,
                                AppTypography.bold,
                              ).copyWith(color: AppColors.accentForeground),
                            ),
                          ),
                          if (person.verified) ...[
                            const SizedBox(width: AppSpacing.s2),
                            const NumayaIcon(
                              NumayaIcons.verified,
                              size: AppSizes.iconMd,
                              color: AppColors.accentForeground,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          from: 0.05,
          rise: 0,
        ),
        const SizedBox(height: AppSpacing.s4),
        enter(
          Text(
            l10n.matchBody(person.name),
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          from: 0.2,
        ),
        if (person.shared.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s3),
          enter(_SharedChips(person: person), from: 0.3),
        ],
        const SizedBox(height: AppSpacing.s2),
      ],
    );
  }
}

/// C — Restrained cat celebration (Ente's Ducky placements; the Bumble note sheet's small
/// illustration): the celebrating cat leads, then one white card naming both people with
/// small round photos, then shared interests in the same card. Photos are smaller, so the
/// screen reads as a moment rather than a profile. The cat never covers a face. Axis:
/// **emotional tone through illustration**.
class MatchCatCelebration extends StatelessWidget {
  const MatchCatCelebration({
    super.key,
    required this.person,
    required this.ownInitial,
    required this.enter,
  });

  final SamplePerson person;
  final String ownInitial;
  final MatchEnter enter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const avatar = 56.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.s6),
        enter(
          const Center(
            child: MascotArt(
              MascotPurpose.matchCelebration,
              maxWidth: 220,
              maxHeightFraction: 0.24,
            ),
          ),
          from: 0.05,
          rise: 0,
        ),
        const SizedBox(height: AppSpacing.s5),
        enter(
          Container(
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
                    ExcludeSemantics(
                      child: SizedBox(
                        width: avatar * 1.7,
                        height: avatar,
                        child: Stack(
                          children: [
                            InitialsAvatar(initial: ownInitial, size: avatar),
                            Positioned(
                              left: avatar * 0.7,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 3,
                                  ),
                                ),
                                child: InitialsAvatar(
                                  initial: person.initial,
                                  size: avatar - 6,
                                  image: personAvatarImage(person),
                                  imageAlignment: personAvatarFocus(person),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.matchPairTitle(person.name),
                            style: AppTypography.card,
                          ),
                          const SizedBox(height: AppSpacing.s1),
                          Text(
                            l10n.matchPairBody,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (person.shared.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    l10n.discoverYouBothLike,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Wrap(
                    key: const ValueKey('match-shared-interests'),
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: [
                      for (final s in person.shared)
                        InfoChip(label: s, emoji: kInterestEmoji[s]),
                    ],
                  ),
                ],
              ],
            ),
          ),
          from: 0.2,
        ),
        const SizedBox(height: AppSpacing.s2),
      ],
    );
  }
}
