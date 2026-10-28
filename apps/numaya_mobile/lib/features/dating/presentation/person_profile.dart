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
    this.own = false,
    this.showAge = true,
    this.onOpenPhotos,
    this.onMore,
    this.hint,
  });

  /// Tapping the photo opens the photo viewer; a photo count shows on the photo.
  final VoidCallback? onOpenPhotos;

  /// Tapping the name band shows the rest of the profile.
  final VoidCallback? onMore;

  /// Shown over the bottom of the photo (Discover's first-visit swipe tip).
  final Widget? hint;

  final SamplePerson person;
  final Widget? action;
  final double? height;

  /// The member's own profile in the preview: a "Preview" badge instead of "Sample profile".
  final bool own;
  final bool showAge;

  /// "Like" / "Pass" while dragging.
  final String? stamp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      // At least this tall; taller only when large text needs more room for the name band.
      builder: (context, box) => ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: height ?? math.max(420, box.maxWidth * 4 / 3),
          minWidth: box.maxWidth,
        ),
        child: _card(l10n),
      ),
    );
  }

  Widget _card(AppLocalizations l10n) {
    // The card is at least its design height; a name band that grows with large text makes the
    // card taller (IntrinsicHeight measures it) rather than squeezing the photo to nothing.
    return ClipRRect(
      borderRadius: AppRadii.all(AppRadii.photo),
      child: IntrinsicHeight(
        child: Column(
          children: [
            Expanded(child: _photo(l10n)),
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
                    child: _more(
                      l10n,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              StatusBadge(
                                label: own
                                    ? l10n.previewBadge
                                    : l10n.discoverSampleBadge,
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
                              showAge && person.age > 0
                                  ? l10n.profileNameAge(person.name, person.age)
                                  : person.name,
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
      ),
    );
  }
}

extension on PersonHeroCard {
  Widget _more(AppLocalizations l10n, Widget child) => onMore == null
      ? child
      : Pressable(
          onTap: onMore,
          semanticLabel: l10n.discoverMoreAbout(person.name),
          pressedScale: 1,
          child: child,
        );

  Widget _photo(AppLocalizations l10n) {
    final photo = PhotoPlaceholder(
      label: l10n.discoverPhotoLabel(person.name, 1),
      aspectRatio: null,
      radius: 0,
      child: Stack(
        children: [
          if (stamp != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s6),
                child: StatusBadge(label: stamp!, tone: BadgeTone.onPhoto),
              ),
            ),
          if (onOpenPhotos != null && person.photoCount > 1)
            Positioned(
              top: AppSpacing.s3,
              right: AppSpacing.s3,
              child: StatusBadge(
                label: l10n.discoverPhotoCount(person.photoCount),
                icon: NumayaIcons.image,
                tone: BadgeTone.onPhoto,
              ),
            ),
          if (hint != null && onOpenPhotos == null)
            Positioned(
              left: AppSpacing.s3,
              right: AppSpacing.s3,
              bottom: AppSpacing.s3,
              child: hint!,
            ),
        ],
      ),
    );
    if (onOpenPhotos == null) return photo;
    return Stack(
      fit: StackFit.expand,
      children: [
        Pressable(
          onTap: onOpenPhotos,
          semanticLabel: l10n.discoverOpenPhotos(person.name),
          pressedScale: 1,
          excludeChildSemantics: true,
          child: photo,
        ),
        // The tip stays reachable on its own (its button is not part of the photo's tap).
        if (hint != null)
          Positioned(
            left: AppSpacing.s3,
            right: AppSpacing.s3,
            bottom: AppSpacing.s3,
            child: hint!,
          ),
      ],
    );
  }
}

/// The sections of a sample profile below the first photo, in the web order: prompt, about me,
/// photo, you both like, photo, location, remaining photos.
List<Widget> personSections(
  BuildContext context,
  SamplePerson person, {
  bool own = false,
  bool showDistance = true,
  ValueChanged<int>? onPhoto,
}) {
  final l10n = context.l10n;
  Widget prompt(({String question, String answer}) p) => ProfileSectionCard(
    title: p.question,
    leading: const PromptMark(),
    child: Text(
      p.answer,
      style: AppTypography.weight(
        AppTypography.section,
        AppTypography.semibold,
      ),
    ),
  );
  Widget photo(int position) {
    final tile = PhotoPlaceholder(
      label: l10n.discoverPhotoLabel(person.name, position),
      aspectRatio: 4 / 5,
    );
    return onPhoto == null
        ? tile
        : Pressable(
            onTap: () => onPhoto(position),
            semanticLabel: l10n.discoverOpenPhotos(person.name),
            pressedScale: 1,
            excludeChildSemantics: true,
            child: tile,
          );
  }

  final facts = [
    if (person.identity != null) (NumayaIcons.user, person.identity!),
    if (person.lookingFor != null) (NumayaIcons.heart, person.lookingFor!),
    if (person.heightCm > 0)
      (NumayaIcons.user, l10n.heightValue(person.heightCm)),
    if (person.languages != null) (NumayaIcons.message, person.languages!),
    for (final d in person.details.values) (NumayaIcons.tag, d),
  ];
  final sections = <Widget>[
    if (person.prompt != null) prompt(person.prompt!),
    if (facts.isNotEmpty)
      ProfileSectionCard(
        title: l10n.discoverAboutMe,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (person.bio != null) ...[
              Text(person.bio!, style: AppTypography.body),
              const SizedBox(height: AppSpacing.s3),
            ],
            Wrap(
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              children: [
                for (final (icon, text) in facts)
                  InfoChip(label: text, icon: icon),
              ],
            ),
          ],
        ),
      ),
    if (person.photoCount > 1) photo(2),
    if (person.shared.isNotEmpty)
      ProfileSectionCard(
        title: own ? l10n.profileInterestsTitle : l10n.discoverYouBothLike,
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
    for (final p in person.morePrompts) prompt(p),
    if (showDistance || person.livesIn != null)
      ProfileSectionCard(
        title: l10n.discoverLocation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDistance)
              Row(
                children: [
                  const NumayaIcon(
                    NumayaIcons.location,
                    size: AppSizes.iconMd,
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Flexible(
                    child: Text(
                      l10n.discoverDistance(person.distanceKm),
                      style: AppTypography.row,
                    ),
                  ),
                ],
              ),
            if (person.livesIn != null) ...[
              if (showDistance) const SizedBox(height: AppSpacing.s3),
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
