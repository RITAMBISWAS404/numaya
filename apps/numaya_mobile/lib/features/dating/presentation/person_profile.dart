import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../domain/profile_fact_emoji.dart';
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
    this.photoHeight,
    this.photoAction,
  });

  /// Bumble-style discovery card (Ente reconstruction, ER-01): non-null lays the name, verified
  /// tick, job and shared interests over the bottom of the photo instead of below it. The frame is
  /// the 3:4 portrait in both layouts (UI-011); the value itself is no longer used for height.
  final double? photoHeight;

  /// A control on the photo's top-right corner (Discover's options), as Ente's circular Icon
  /// Button over photos. Only drawn with [photoHeight].
  final Widget? photoAction;

  bool get _overlay => photoHeight != null;

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
          borderRadius: AppRadii.all(
            _overlay ? AppRadii.heroCard : AppRadii.photo,
          ),
          child: _sized(
            Stack(
              children: [
                Positioned.fill(child: _photo(l10n)),
                if (_overlay) ...[
                  // Bumble's identity on the photo: a dark fade under white text, so the name
                  // reads over any photo (white on the fade's base is over 7:1).
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 220,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), AppColors.photoPanel],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.s4,
                    right: AppSpacing.s4,
                    bottom: AppSpacing.s4,
                    child: _overlayIdentity(context, l10n),
                  ),
                ],
                // UI-014: no photo count on the photo. In the overlay layout the status tags sit
                // with the name at the bottom; the plain layout keeps them top-left.
                if (!_overlay)
                  Positioned(
                    top: AppSpacing.s3,
                    left: AppSpacing.s3,
                    right: AppSpacing.s3,
                    child: IgnorePointer(child: _badges(l10n)),
                  ),
                if (_overlay && photoAction != null)
                  Positioned(
                    top: AppSpacing.s2,
                    right: AppSpacing.s2,
                    child: photoAction!,
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
        if (!_overlay)
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
        // UI-015: shared interests are their own section below the photo (personSections),
        // never on or under the photo card.
      ],
    );
  }

  // UI-011: every full profile photo is a 3:4 portrait frame across the content width, in both
  // the overlay (discovery) and plain layouts.
  Widget _sized(Widget child) =>
      AspectRatio(aspectRatio: AppMedia.personPhoto, child: child);

  /// UI-014: the identity group at the bottom of the photo, over its fade: the status tags
  /// ("Sample profile", "New here") immediately above the name, then the name with its verified
  /// tick, then the designation. Absent fields leave no gap. The profile has no college field, so
  /// none is shown (nothing is invented).
  Widget _overlayIdentity(BuildContext context, AppLocalizations l10n) {
    final large = MediaQuery.textScalerOf(context).scale(10) > 16;
    final nameStyle = AppTypography.hero.copyWith(
      fontSize: large ? 24 : 28,
      height: large ? 30 / 24 : 36 / 28,
      color: AppColors.inkForeground,
    );
    final name = Text(
      showAge && person.age > 0
          ? l10n.profileNameAge(person.name, person.age)
          : person.name,
      textWidthBasis: TextWidthBasis.longestLine,
      style: nameStyle,
    );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: name),
              if (person.verified) ...[
                const SizedBox(width: AppLayout.iconLabelGap),
                Semantics(
                  label: l10n.discoverVerified,
                  child: const NumayaIcon(
                    NumayaIcons.verified,
                    size: AppSizes.iconMd,
                    color: AppColors.inkForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (person.job != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s1),
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
                        color: AppColors.inkForeground,
                      ),
                    ),
                  ),
                  TextSpan(text: person.job!),
                ],
              ),
              style: AppTypography.body.copyWith(
                color: AppColors.inkForeground,
              ),
            ),
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _badges(l10n),
        const SizedBox(height: AppSpacing.s2),
        _more(l10n, identity),
      ],
    );
  }

  Widget _badges(AppLocalizations l10n) => Wrap(
    spacing: AppLayout.groupGap,
    runSpacing: AppLayout.groupGap,
    children: [
      // UI-041: no "Sample profile" badge; your own preview keeps its "Preview" label.
      if (own) StatusBadge(label: l10n.previewBadge, tone: BadgeTone.onPhoto),
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
  // UI-007: a profile's prompt is the shared prompt card: small question, dominant answer, no
  // decorative icon.
  Widget prompt(({String question, String answer}) p) =>
      PromptCard(question: p.question, answer: p.answer);
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

  // UI-019: every profile-detail pill leads with its emoji (ProfileFactEmoji).
  final facts = [
    if (person.identity != null) (ProfileFactEmoji.identity, person.identity!),
    if (person.lookingFor != null)
      (ProfileFactEmoji.lookingFor, person.lookingFor!),
    if (person.heightCm > 0)
      (ProfileFactEmoji.height, l10n.heightValue(person.heightCm)),
    if (person.languages != null)
      (ProfileFactEmoji.languages, person.languages!),
    for (final d in person.details.entries)
      (ProfileFactEmoji.detail(d.key, d.value), d.value),
  ];
  final hasBio = person.bio != null && person.bio!.isNotEmpty;
  final sections = <Widget>[
    if (person.prompt != null) prompt(person.prompt!),
    // UI-018: one About me card, the bio first in the primary content style (UI-020), a divider,
    // then the detail pills.
    if (facts.isNotEmpty || hasBio)
      ProfileSectionCard(
        title: l10n.discoverAboutMe,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasBio) Text(person.bio!, style: AppTypography.cardPrimary),
            if (hasBio && facts.isNotEmpty)
              const Padding(
                key: ValueKey('about-divider'),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
                child: ExcludeSemantics(
                  child: SizedBox(
                    height: AppBorders.hairline,
                    child: ColoredBox(color: AppColors.divider),
                  ),
                ),
              ),
            if (facts.isNotEmpty)
              Wrap(
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
                children: [
                  for (final (emoji, text) in facts)
                    InfoChip(label: text, emoji: emoji),
                ],
              ),
          ],
        ),
      ),
    // UI-015: shared interests are their own section below the photo, after the bio, and only
    // when there are some. The member's own preview lists their interests here too.
    if (person.shared.isNotEmpty)
      ProfileSectionCard(
        key: const ValueKey('shared-interests'),
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
    if (person.photoCount > 1) photo(2),
    if (person.photoCount > 2) photo(3),
    for (final p in person.morePrompts) prompt(p),
    if (showDistance || person.livesIn != null)
      ProfileSectionCard(
        title: l10n.discoverLocation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDistance)
              Text(
                l10n.discoverDistance(person.distanceKm),
                style: AppTypography.cardPrimary,
              ),
            if (person.livesIn != null) ...[
              if (showDistance) const SizedBox(height: AppSpacing.s3),
              InfoChip(
                label: l10n.discoverLivesIn(person.livesIn!),
                emoji: ProfileFactEmoji.livesIn,
              ),
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
