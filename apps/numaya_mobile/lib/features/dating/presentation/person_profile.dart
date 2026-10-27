import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../domain/sample_people.dart';

/// The first photo of a sample profile with V16's dark band (screenshot 019): badges, the name on
/// the hero scale in white, the job, and an optional floating action (the SuperSwipe). As V16's
/// `.profile-card`, the band sits inside a 3:4 photo box at least 420pt tall; Discover passes
/// [height] so the card fills the screen.
class PersonHeroCard extends StatelessWidget {
  const PersonHeroCard({
    super.key,
    required this.person,
    this.action,
    this.stamp,
    this.height,
  });

  final SamplePerson person;
  final Widget? action;
  final double? height;

  /// "Like" / "Pass" while dragging.
  final String? stamp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, box) => SizedBox(
        height: height ?? math.max(420, box.maxWidth * 4 / 3),
        child: _card(l10n),
      ),
    );
  }

  Widget _card(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: AppRadii.all(AppRadii.photo),
      child: Column(
        children: [
          Expanded(
            child: PhotoPlaceholder(
              label: l10n.discoverPhotoLabel(person.name, 1),
              aspectRatio: null,
              radius: 0,
              child: stamp == null
                  ? null
                  : Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.s6),
                        child: StatusBadge(
                          label: stamp!,
                          tone: BadgeTone.onPhoto,
                        ),
                      ),
                    ),
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.textSecondary,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s5,
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          StatusBadge(
                            label: l10n.discoverSampleBadge,
                            tone: BadgeTone.onDark,
                          ),
                          if (person.verified)
                            StatusBadge(
                              label: l10n.discoverVerified,
                              icon: NumayaIcons.verified,
                              tone: BadgeTone.onDark,
                            ),
                          if (person.isNew)
                            StatusBadge(
                              label: l10n.discoverNewHere,
                              tone: BadgeTone.onDark,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.profileNameAge(person.name, person.age),
                          style: AppTypography.hero.copyWith(
                            color: AppColors.inkForeground,
                          ),
                        ),
                      ),
                      if (person.job != null)
                        Row(
                          children: [
                            const NumayaIcon(
                              NumayaIcons.user,
                              size: 16,
                              color: AppColors.inkForeground,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                person.job!,
                                style: AppTypography.weight(
                                  AppTypography.body,
                                  AppTypography.medium,
                                ).copyWith(color: AppColors.inkForeground),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: AppSpacing.s3),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The sections of a sample profile below the first photo, in the web order: prompt, about me,
/// photo, you both like, photo, location, remaining photos.
List<Widget> personSections(BuildContext context, SamplePerson person) {
  final l10n = context.l10n;
  Widget photo(int position) => PhotoPlaceholder(
    label: l10n.discoverPhotoLabel(person.name, position),
    aspectRatio: 4 / 5,
  );
  final facts = [
    if (person.lookingFor != null) (NumayaIcons.heart, person.lookingFor!),
    if (person.languages != null) (NumayaIcons.message, person.languages!),
  ];
  final sections = <Widget>[
    if (person.prompt != null)
      ProfileSectionCard(
        title: person.prompt!.question,
        leading: const PromptMark(),
        child: Text(
          person.prompt!.answer,
          style: AppTypography.weight(
            AppTypography.section,
            AppTypography.semibold,
          ),
        ),
      ),
    if (facts.isNotEmpty)
      ProfileSectionCard(
        title: l10n.discoverAboutMe,
        child: Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final (icon, text) in facts) InfoChip(label: text, icon: icon),
          ],
        ),
      ),
    if (person.photoCount > 1) photo(2),
    if (person.shared.isNotEmpty)
      ProfileSectionCard(
        title: l10n.discoverYouBothLike,
        child: Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final s in person.shared)
              InfoChip(label: s, emoji: kInterestEmoji[s]),
          ],
        ),
      ),
    if (person.photoCount > 2) photo(3),
    ProfileSectionCard(
      title: l10n.discoverLocation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NumayaIcon(
                NumayaIcons.location,
                size: AppSizes.iconMd,
                color: AppColors.ink,
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(
                l10n.discoverDistance(person.distanceKm),
                style: AppTypography.row,
              ),
            ],
          ),
          if (person.livesIn != null) ...[
            const SizedBox(height: AppSpacing.s3),
            InfoChip(label: l10n.discoverLivesIn(person.livesIn!)),
          ],
        ],
      ),
    ),
    for (var i = 4; i <= person.photoCount; i++) photo(i),
  ];
  return [
    for (var i = 0; i < sections.length; i++) ...[
      if (i > 0) const SizedBox(height: AppSpacing.s3),
      sections[i],
    ],
  ];
}
