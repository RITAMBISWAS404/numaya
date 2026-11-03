import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../domain/sample_people.dart';

/// The first photo of a sample profile (premium refinement): an image-first card in Meetup's manner.
/// The 4:3 photo stays clear, carrying only small white badges (sample, verified, new) and the photo
/// count; the name on the hero scale, the job and an optional [action] sit below it on the card's
/// own surface. No overlay or scrim is needed, and large text simply makes the text block taller.
class PersonHeroCard extends StatelessWidget {
  const PersonHeroCard({
    super.key,
    required this.person,
    this.action,
    this.stamp,
    this.own = false,
    this.showAge = true,
    this.onOpenPhotos,
    this.onMore,
  });

  /// Tapping the photo opens the photo viewer; a photo count shows on the photo.
  final VoidCallback? onOpenPhotos;

  /// Tapping the name shows the rest of the profile.
  final VoidCallback? onMore;

  final SamplePerson person;
  final Widget? action;

  /// The member's own profile in the preview: a "Preview" badge instead of "Sample profile".
  final bool own;
  final bool showAge;

  /// "Like" / "Pass" while dragging.
  final String? stamp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppRadii.all(AppRadii.photo),
          child: AspectRatio(
            aspectRatio: AppMedia.personPhoto,
            child: Stack(
              children: [
                Positioned.fill(child: _photo(l10n)),
                Positioned(
                  top: AppSpacing.s3,
                  left: AppSpacing.s3,
                  right: 96,
                  child: IgnorePointer(child: _badges(l10n)),
                ),
                if (onOpenPhotos != null && person.photoCount > 1)
                  Positioned(
                    top: AppSpacing.s3,
                    right: AppSpacing.s3,
                    child: IgnorePointer(
                      child: StatusBadge(
                        label: l10n.discoverPhotoCount(person.photoCount),
                        icon: NumayaIcons.image,
                        tone: BadgeTone.onPhoto,
                      ),
                    ),
                  ),
                if (stamp != null)
                  Positioned.fill(
                    child: Center(
                      child: StatusBadge(
                        label: stamp!,
                        tone: BadgeTone.onPhoto,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s3,
            AppSpacing.s4,
            AppSpacing.s3,
            AppSpacing.s1,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _more(l10n, _identity(l10n))),
              if (action != null) ...[
                const SizedBox(width: AppSpacing.s3),
                action!,
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _badges(AppLocalizations l10n) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      StatusBadge(
        label: own ? l10n.previewBadge : l10n.discoverSampleBadge,
        tone: BadgeTone.onPhoto,
      ),
      if (person.verified)
        StatusBadge(
          label: l10n.discoverVerified,
          icon: NumayaIcons.verified,
          tone: BadgeTone.onPhoto,
        ),
      if (person.isNew)
        StatusBadge(label: l10n.discoverNewHere, tone: BadgeTone.onPhoto),
    ],
  );

  Widget _identity(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        header: true,
        child: Text(
          showAge && person.age > 0
              ? l10n.profileNameAge(person.name, person.age)
              : person.name,
          style: AppTypography.hero.copyWith(fontSize: 32, height: 38 / 32),
        ),
      ),
      if (person.job != null)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              const NumayaIcon(
                NumayaIcons.user,
                size: AppSizes.iconSm,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  person.job!,
                  style: AppTypography.weight(
                    AppTypography.body,
                    AppTypography.medium,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
    ],
  );

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
      child: _real(person.photoAt(1)),
    );
    if (onOpenPhotos == null) return photo;
    return Pressable(
      onTap: onOpenPhotos,
      semanticLabel: l10n.discoverOpenPhotos(person.name),
      pressedScale: 1,
      excludeChildSemantics: true,
      child: photo,
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
      aspectRatio: AppMedia.personPhoto,
      child: _real(person.photoAt(position)),
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

/// The member's own photo over the placeholder, when they chose one on this phone.
Widget? _real(String? source) => source == null
    ? null
    : Image(
        image: localImage(source, width: 1080),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
