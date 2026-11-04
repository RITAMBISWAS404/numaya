import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../domain/sample_people.dart';

/// The first photo of a sample profile (premium refinement): an image-first card in Meetup's manner.
/// The 4:3 photo stays clear, carrying only small white badges (sample, new) and the photo
/// count; the name on the hero scale with its verified tick, the job and an optional [action] sit below it on the card's
/// own surface. No overlay or scrim is needed, and large text simply makes the text block taller.
class PersonHeroCard extends StatelessWidget {
  const PersonHeroCard({
    super.key,
    required this.person,
    this.action,
    this.swipe = 0,
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

  /// How far the card has been dragged toward a decision while swiping: -1 (pass) to 1 (like), 0
  /// at rest. Past a quarter of the way the decision appears on the photo (Bumble's check and
  /// cross), fully opaque at the threshold.
  final double swipe;

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
                // Badges and the photo count share one row, so the count's real width (it grows
                // with the text size) is reserved instead of a fixed 96pt that large text overran
                // (OP-04).
                Positioned(
                  top: AppSpacing.s3,
                  left: AppSpacing.s3,
                  right: AppSpacing.s3,
                  child: IgnorePointer(
                    child: Builder(
                      builder: (context) {
                        final count =
                            onOpenPhotos != null && person.photoCount > 1
                            ? StatusBadge(
                                label: l10n.discoverPhotoCount(
                                  person.photoCount,
                                ),
                                icon: NumayaIcons.image,
                                tone: BadgeTone.onPhoto,
                              )
                            : null;
                        // At very large text the count goes under the badges, so neither
                        // squeezes the other into breaking inside words.
                        if (MediaQuery.textScalerOf(context).scale(10) > 16) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _badges(l10n),
                              if (count != null) ...[
                                const SizedBox(height: AppLayout.groupGap),
                                count,
                              ],
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _badges(l10n)),
                            if (count != null) ...[
                              const SizedBox(width: AppSpacing.s2),
                              count,
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
                if (swipe.abs() >= 0.25)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _SwipeStamp(
                        like: swipe > 0,
                        label: swipe > 0
                            ? l10n.discoverLike
                            : l10n.discoverPass,
                        strength: ((swipe.abs() - 0.25) / 0.75).clamp(0.0, 1.0),
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
        // DX-02: shared ground sits with identity, before the decision (Bumble's "things in
        // common" under the photo). The body no longer repeats it for other people.
        // Above 160% text the chips would push the decision row under the tab bar, so they stay
        // in the profile body instead.
        if (!own &&
            person.shared.isNotEmpty &&
            MediaQuery.textScalerOf(context).scale(10) <= 16)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s3,
              AppSpacing.s3,
              AppSpacing.s3,
              AppSpacing.s1,
            ),
            child: Semantics(
              container: true,
              label: context.l10n.discoverYouBothLike,
              child: Wrap(
                spacing: AppLayout.groupGap,
                runSpacing: AppLayout.groupGap,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    context.l10n.discoverYouBothLike,
                    style: AppTypography.caption,
                  ),
                  for (final s in person.shared)
                    InfoChip(label: s, emoji: kInterestEmoji[s]),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _badges(AppLocalizations l10n) => Wrap(
    spacing: AppLayout.groupGap,
    runSpacing: AppLayout.groupGap,
    children: [
      StatusBadge(
        label: own ? l10n.previewBadge : l10n.discoverSampleBadge,
        tone: BadgeTone.onPhoto,
      ),
      // BM-01: Verified moved from the photo to a tick beside the name (Bumble), so the photo
      // carries at most the sample/preview notice, "New here" and the photo count.
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
        // At very large text sizes the 32pt name is stepped down to 24pt, so a long single-word
        // name still scales up (to 48pt at 200%) but no longer breaks inside the word.
        child: Builder(
          builder: (context) {
            final large = MediaQuery.textScalerOf(context).scale(10) > 16;
            final line = large ? 30.0 : 38.0;
            final name = Text(
              showAge && person.age > 0
                  ? l10n.profileNameAge(person.name, person.age)
                  : person.name,
              // Hugs its longest line, so the tick follows the text, not the card edge.
              textWidthBasis: TextWidthBasis.longestLine,
              style: AppTypography.hero.copyWith(
                fontSize: large ? 24 : 32,
                height: line / (large ? 24 : 32),
              ),
            );
            if (!person.verified) return name;
            // The tick sits at the end of the name's last line: a long name that wraps keeps it
            // beside its final word instead of orphaning it on a line of its own.
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: name),
                const SizedBox(width: AppLayout.iconLabelGap),
                Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        (MediaQuery.textScalerOf(context).scale(line) -
                            AppSizes.iconMd) /
                        2,
                  ),
                  child: Semantics(
                    label: l10n.discoverVerified,
                    child: const NumayaIcon(
                      NumayaIcons.verified,
                      size: AppSizes.iconMd,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      if (person.job != null)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          // The icon is an inline span so it stays on the first line when the job wraps.
          child: Text.rich(
            TextSpan(
              children: [
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: NumayaIcon(
                      NumayaIcons.user,
                      size: AppSizes.iconSm,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                TextSpan(text: person.job!),
              ],
            ),
            style: AppTypography.weight(
              AppTypography.body,
              AppTypography.medium,
            ).copyWith(color: AppColors.textSecondary),
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

/// The decision a swipe is heading for, on the photo: a white disc with a check (like, purple) or a
/// cross (pass, charcoal) and its word, fading in with [strength] and growing slightly. The card's
/// movement already says the direction; this names it, so colour is never the only signal.
class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({
    required this.like,
    required this.label,
    required this.strength,
  });

  final bool like;
  final String label;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final fg = like ? AppColors.accentOnTint : AppColors.ink;
    return Opacity(
      opacity: 0.4 + 0.6 * strength,
      child: Center(
        child: Transform.scale(
          scale: 0.85 + 0.15 * strength,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.photoButton,
                  shape: BoxShape.circle,
                  boxShadow: AppElevation.floating,
                ),
                alignment: Alignment.center,
                child: NumayaIcon(
                  like ? NumayaIcons.check : NumayaIcons.close,
                  size: 38,
                  color: fg,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              StatusBadge(label: label, tone: BadgeTone.onPhoto),
            ],
          ),
        ),
      ),
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
    // Others' shared interests are in the hero card (DX-02), except above 160% text; your own
    // stay here.
    if (person.shared.isNotEmpty &&
        (own || MediaQuery.textScalerOf(context).scale(10) > 16))
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

/// A sample person's photo at [position] (1-based) for use inside a [PhotoPlaceholder], or null
/// when there is none (the placeholder then shows).
Widget? personPhotoImage(SamplePerson person, int position) =>
    _real(person.photoAt(position));

/// The member's own photo over the placeholder, when they chose one on this phone.
Widget? _real(String? source) => source == null
    ? null
    : Image(
        image: localImage(source, width: 1080),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
