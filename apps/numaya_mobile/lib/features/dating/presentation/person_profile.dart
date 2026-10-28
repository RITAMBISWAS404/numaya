import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../domain/sample_people.dart';

/// The first photo of a sample profile (UI_REFINEMENT_DECISIONS RD-10, RD-11): a 4:3 photo with a
/// gradient scrim rising from the bottom, so badges, the name on the hero scale and the job sit on
/// the photo itself rather than on a solid band. An optional [action] sits beside the name; the
/// photo count and the drag stamp sit on top. When large text needs more room than the 4:3 photo
/// gives, the card grows taller instead of squeezing the text.
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

  /// The scrim: clear over the top of the photo, darkening towards the bottom.
  static const _scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 0.62, 1],
    colors: [Color(0x00121212), Color(0x59121212), Color(0xC7121212)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        final photoHeight = width / AppMedia.personPhoto;
        return ClipRRect(
          borderRadius: AppRadii.all(AppRadii.photo),
          child: Stack(
            children: [
              Positioned.fill(child: _photo(l10n)),
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: _scrim),
                  ),
                ),
              ),
              // Sizes the card: the 4:3 photo, or taller when the text needs it.
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: photoHeight,
                  minWidth: width,
                  maxWidth: width,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.cardPadding,
                      AppSpacing.s12,
                      AppLayout.cardPadding,
                      AppLayout.cardPadding,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _more(l10n, _identity(l10n))),
                        if (action != null) ...[
                          const SizedBox(width: AppSpacing.s3),
                          action!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (stamp != null)
                Positioned(
                  top: AppSpacing.s6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: StatusBadge(label: stamp!, tone: BadgeTone.onPhoto),
                  ),
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
            ],
          ),
        );
      },
    );
  }

  Widget _identity(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          StatusBadge(
            label: own ? l10n.previewBadge : l10n.discoverSampleBadge,
            tone: BadgeTone.onDark,
          ),
          if (person.verified)
            StatusBadge(
              label: l10n.discoverVerified,
              icon: NumayaIcons.verified,
              tone: BadgeTone.onDark,
            ),
          if (person.isNew)
            StatusBadge(label: l10n.discoverNewHere, tone: BadgeTone.onDark),
        ],
      ),
      const SizedBox(height: AppSpacing.s2),
      Semantics(
        header: true,
        child: Text(
          showAge && person.age > 0
              ? l10n.profileNameAge(person.name, person.age)
              : person.name,
          style: AppTypography.hero.copyWith(color: AppColors.inkForeground),
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
