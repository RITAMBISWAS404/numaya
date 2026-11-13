import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/profile_draft.dart' show kInterestEmoji;
import '../domain/sample_people.dart';
import 'person_profile.dart';

/// UI-082 (V8): six Match screen directions for review, from the source preview. Every option
/// shows the same identity (photo, "It's a match!", name), the same shared interests when there
/// are some (and nothing when there are none) and the same two actions: Open chat, View profile.
/// No inline composer and no Opening Moves.
///
/// M1 photo spotlight, M2 two portraits, M3 shared interests first, M4 match ticket,
/// M5 celebration sheet (actions inside the panel), M6 framed portrait.
class MatchV8Body extends StatelessWidget {
  const MatchV8Body({
    super.key,
    required this.variant,
    required this.person,
    required this.shared,
    required this.ownName,
    required this.ownInitial,
    required this.ownPhoto,
    required this.actions,
  });

  final String variant;
  final SamplePerson person;

  /// The shared interests to show (empty: the interests block is left out).
  final List<String> shared;
  final String ownName;
  final String ownInitial;
  final Widget? ownPhoto;

  /// Open chat and View profile, already built (M5 places them in its panel).
  final Widget actions;

  /// M5 carries the actions itself; the others leave them to the screen's footer.
  static bool actionsInBody(String v) => v == 'M5';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = Semantics(
      header: true,
      child: Text(
        l10n.matchTitle,
        textAlign: TextAlign.center,
        style: AppTypography.flowTitle,
      ),
    );
    final name = Text(
      l10n.matchBody(person.name),
      textAlign: TextAlign.center,
      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
    );
    Widget photo({double radius = AppRadii.photo, double ratio = 3 / 4}) =>
        PhotoPlaceholder(
          key: const ValueKey('match-photo'),
          label: l10n.discoverPhotoLabel(person.name, 1),
          aspectRatio: ratio,
          radius: radius,
          child: personPhotoImage(person, 1),
        );
    Widget chips() => Wrap(
      spacing: AppSpacing.s2,
      runSpacing: AppSpacing.s2,
      children: [
        for (final s in shared) InfoChip(label: s, emoji: kInterestEmoji[s]),
      ],
    );
    final interests = shared.isEmpty
        ? null
        : ProfileSectionCard(
            key: const ValueKey('match-shared-interests'),
            title: l10n.discoverYouBothLike,
            child: chips(),
          );
    return LayoutBuilder(
      builder: (context, box) {
        final h = MediaQuery.sizeOf(context).height;
        final w = box.maxWidth;
        // The portrait never takes more than ~45% of the screen, so interests and actions stay
        // near the first view.
        final portraitW = math.min(w, h * 0.45 * 3 / 4);
        switch (variant) {
          case 'M2':
            final each = (w - AppSpacing.s3) / 2;
            Widget mine() => PhotoPlaceholder(
              label: ownName,
              aspectRatio: 3 / 4,
              radius: AppRadii.photo,
              child:
                  ownPhoto ??
                  ColoredBox(
                    color: AppColors.photo,
                    child: Center(
                      child: Text(ownInitial, style: AppTypography.headline),
                    ),
                  ),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s4),
                title,
                const SizedBox(height: AppSpacing.s2),
                name,
                const SizedBox(height: AppSpacing.s5),
                Row(
                  children: [
                    SizedBox(width: each, child: mine()),
                    const SizedBox(width: AppSpacing.s3),
                    SizedBox(width: each, child: photo()),
                  ],
                ),
                if (interests != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  interests,
                ],
              ],
            );
          case 'M3':
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s4),
                title,
                const SizedBox(height: AppSpacing.s2),
                name,
                const SizedBox(height: AppSpacing.s5),
                Container(
                  padding: const EdgeInsets.all(AppLayout.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.all(AppRadii.heroCard),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: photo(radius: AppRadii.control),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shared.isEmpty
                                  ? person.name
                                  : l10n.discoverYouBothLike,
                              style: AppTypography.card,
                            ),
                            const SizedBox(height: AppSpacing.s3),
                            if (shared.isNotEmpty)
                              chips()
                            else
                              Text(
                                l10n.v8MatchSayHello,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          case 'M4':
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s2),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.all(AppRadii.heroCard),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.s3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 20pt card, 12pt inset: the photo's corners are 8 (UI-050 nested).
                      photo(
                        radius: AppRadii.nested(AppRadii.heroCard, 12),
                        ratio: 4 / 3,
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      title,
                      const SizedBox(height: AppSpacing.s1),
                      name,
                      if (shared.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s4),
                        const CardDivider(inset: AppSpacing.s2),
                        const SizedBox(height: AppSpacing.s4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.discoverYouBothLike,
                                style: AppTypography.label,
                              ),
                              const SizedBox(height: AppSpacing.s2),
                              chips(),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s2),
                    ],
                  ),
                ),
              ],
            );
          case 'M5':
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s2),
                Center(
                  child: SizedBox(width: portraitW, child: photo()),
                ),
                Transform.translate(
                  offset: const Offset(0, -AppSpacing.s6),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.cardPadding,
                      AppSpacing.s5,
                      AppLayout.cardPadding,
                      AppLayout.cardPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.all(AppRadii.heroCard),
                      // The restrained purple accent at the join.
                      border: const Border(
                        top: BorderSide(color: AppColors.accent, width: 3),
                      ),
                      boxShadow: AppElevation.subtle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        title,
                        const SizedBox(height: AppSpacing.s1),
                        name,
                        if (shared.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s4),
                          Center(child: chips()),
                        ],
                        const SizedBox(height: AppSpacing.s5),
                        actions,
                      ],
                    ),
                  ),
                ),
              ],
            );
          case 'M6':
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s4),
                Center(
                  child: SizedBox(
                    width: portraitW,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // The small purple accent behind an offset frame.
                        Positioned(
                          left: AppSpacing.s3,
                          top: AppSpacing.s3,
                          right: -AppSpacing.s3,
                          bottom: -AppSpacing.s3,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.accentTint,
                              borderRadius: AppRadii.all(AppRadii.photo),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s2),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadii.all(AppRadii.photo),
                          ),
                          child: photo(
                            radius: AppRadii.nested(AppRadii.photo, 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                title,
                const SizedBox(height: AppSpacing.s1),
                name,
                if (shared.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Center(child: chips()),
                ],
              ],
            );
          default: // M1 photo spotlight
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s2),
                ClipRRect(
                  borderRadius: AppRadii.all(AppRadii.photo),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 5,
                        child: photo(radius: 0, ratio: 4 / 5),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: PhotoScrim(
                          sample: personTileImage(person),
                          padding: const EdgeInsets.all(AppLayout.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.matchTitle,
                                style: AppTypography.flowTitle.copyWith(
                                  color: AppColors.accentForeground,
                                ),
                              ),
                              Text(
                                l10n.profileNameAge(person.name, person.age),
                                style: AppTypography.body.copyWith(
                                  color: AppColors.accentForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (interests != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  interests,
                ],
              ],
            );
        }
      },
    );
  }
}
