import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../../compliments/domain/compliment.dart';
import '../../lab/profile_prompt_card.dart';
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
    this.complimentAction,
    this.layout,
  });

  /// R05: the Compliment squircle, bottom-right on the photo. The identity text reserves its
  /// width, so the name never runs under it.
  final Widget? complimentAction;

  /// Card family `discover-photo` (Visual Lab V2) for the discovery card: 'O' name on the scrim,
  /// 'A' name below the photo, 'B' name chip at the top, 'C' name with fact pills on the scrim,
  /// 'D' framed photo with a caption. Null keeps the plain layout for other screens.
  final String? layout;

  /// Bumble-style discovery card (Ente reconstruction, ER-01): non-null lays the name, verified
  /// tick, job and shared interests over the bottom of the photo instead of below it. The frame is
  /// the 3:4 portrait in both layouts (UI-011); the value itself is no longer used for height.
  final double? photoHeight;

  /// A control on the photo's top-right corner (Discover's options), as Ente's circular Icon
  /// Button over photos. Only drawn with [photoHeight].
  final Widget? photoAction;

  bool get _overlay =>
      photoHeight != null && layout != 'A' && layout != 'B' && layout != 'D';

  /// The discovery card's controls (overflow, Compliment) are drawn for every discover layout.
  bool get _discover => photoHeight != null;

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
    final framed = layout == 'D' && _discover;
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppRadii.all(
            _discover ? SquircleIconButton.photoRadius : AppRadii.photo,
          ),
          child: _sized(
            Stack(
              children: [
                Positioned.fill(child: _photo(l10n)),
                if (_overlay) ...[
                  // Bumble's identity on the photo, on a scrim that grows with it (TC-07): the
                  // name and job stay on the solid panel at any text size.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: PhotoScrim(
                      fade: 48,
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.s4,
                        0,
                        // R05: room for the 48pt Compliment target plus a gap.
                        complimentAction == null
                            ? AppSpacing.s4
                            : SquircleIconButton.target + AppSpacing.s2,
                        AppSpacing.s4,
                      ),
                      child: _overlayIdentity(context, l10n),
                    ),
                  ),
                ],
                // UI-014: no photo count on the photo. In the overlay layout the status tags sit
                // with the name at the bottom; the plain layout keeps them top-left.
                if (!_overlay)
                  // `discover-photo` B keeps the name chip at the top, so its tags sit at the
                  // bottom left, clear of the Compliment action.
                  Positioned(
                    top: layout == 'B' ? null : AppSpacing.s3,
                    bottom: layout == 'B' ? AppSpacing.s3 : null,
                    left: AppSpacing.s3,
                    right: layout == 'B' ? 64 : AppSpacing.s3,
                    child: IgnorePointer(child: _badges(l10n)),
                  ),
                if (layout == 'B' && _discover)
                  Positioned(
                    top: AppSpacing.s3,
                    left: AppSpacing.s3,
                    right: 64,
                    child: _nameChip(context, l10n),
                  ),
                // Owner note: controls sit on one inset from the photo edge, and the photo's
                // corner radius is the button radius plus that inset (concentric corners).
                if (_discover && photoAction != null)
                  Positioned(
                    top: SquircleIconButton.photoOffset,
                    right: SquircleIconButton.photoOffset,
                    child: photoAction!,
                  ),
                if (_discover && complimentAction != null)
                  Positioned(
                    right: SquircleIconButton.photoOffset,
                    bottom: SquircleIconButton.photoOffset,
                    child: complimentAction!,
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
    if (!framed) return card;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.heroCard),
      ),
      child: card,
    );
  }

  /// `discover-photo` B: a small white chip with the name and verified mark at the top left.
  Widget _nameChip(BuildContext context, AppLocalizations l10n) => Align(
    alignment: Alignment.topLeft,
    child: _more(
      l10n,
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s1,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.pill),
          boxShadow: AppElevation.subtle,
        ),
        child: NameWithBadge(
          name: showAge && person.age > 0
              ? l10n.profileNameAge(person.name, person.age)
              : person.name,
          verified: person.verified,
          verifiedLabel: l10n.photoVerifiedLabel,
          style: AppTypography.weight(
            AppTypography.body,
            AppTypography.semibold,
          ),
        ),
      ),
    ),
  );

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
          // R06: the filled mark follows the name and wraps with its last word.
          child: NameWithBadge(
            name: name.data!,
            verified: person.verified,
            verifiedLabel: l10n.photoVerifiedLabel,
            badgeColor: AppColors.inkForeground,
            style: nameStyle,
          ),
        ),
        // `discover-photo` C: distance and intention as pills on the scrim.
        if (layout == 'C')
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s2),
            child: Wrap(
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s1,
              children: [
                StatusBadge(
                  label: l10n.discoverDistanceKm(person.distanceKm),
                  tone: BadgeTone.onPhoto,
                ),
                if (person.lookingFor != null)
                  StatusBadge(
                    label: person.lookingFor!,
                    tone: BadgeTone.onPhoto,
                  ),
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
  ValueChanged<ComplimentTarget>? onCompliment,
  String? promptVariant,
}) {
  final l10n = context.l10n;
  // UI-007: a profile's prompt is the shared prompt card: small question, dominant answer, no
  // decorative icon. With [onCompliment], each prompt and photo carries a Compliment anchor (S11).
  var promptIndex = 0;
  // R05: a prompt reserves a footer row for the Compliment action, so the answer never runs
  // under it (card family `prompt-card`).
  Widget prompt(({String question, String answer}) p) {
    final index = promptIndex++;
    return ProfilePromptCard(
      question: p.question,
      answer: p.answer,
      variant: promptVariant,
      action: onCompliment == null
          ? null
          : ComplimentAnchor(
              key: ValueKey('compliment-prompt-$index'),
              name: person.name,
              onPressed: () => onCompliment(ComplimentTarget.prompt(index)),
            ),
    );
  }

  Widget photoTile(int position) {
    final tile = PhotoPlaceholder(
      label: l10n.discoverPhotoLabel(person.name, position),
      aspectRatio: AppMedia.personPhoto,
      radius: onCompliment == null
          ? AppRadii.photo
          : SquircleIconButton.photoRadius,
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

  Widget photo(int position) => onCompliment == null
      ? photoTile(position)
      : _WithAnchor(
          anchor: ComplimentAnchor(
            key: ValueKey('compliment-photo-${position - 1}'),
            name: person.name,
            onPressed: () => onCompliment(ComplimentTarget.photo(position - 1)),
          ),
          child: photoTile(position),
        );

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
            // R07: the bio and prompt answers share one Figtree reading role.
            if (hasBio) Text(person.bio!, style: AppTypography.answer),
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

/// The Compliment control on a photo or prompt: a round white button with the message-heart
/// glyph, 48pt target, named for the person.
class ComplimentAnchor extends StatelessWidget {
  const ComplimentAnchor({
    super.key,
    required this.name,
    required this.onPressed,
  });

  final String name;
  final VoidCallback onPressed;

  /// R05: the shared white squircle ([SquircleIconButton]) with the purple message-heart glyph:
  /// legible on any photo, the same size and tap target as the overflow and close controls.
  /// Owner note: a purple squircle with a white glyph, on cards and on photos alike.
  @override
  Widget build(BuildContext context) => SquircleIconButton(
    mobileIcon: NumayaMobileIcons.compliment,
    onBrand: true,
    label: context.l10n.complimentActionOn(name),
    onPressed: onPressed,
  );
}

/// [child] (a photo) with [anchor] in its bottom-right corner. The 48pt target sits 4pt in, so the
/// 38pt squircle is 9pt from the photo's edges.
class _WithAnchor extends StatelessWidget {
  const _WithAnchor({required this.anchor, required this.child});

  final Widget anchor;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      Positioned(
        right: SquircleIconButton.photoOffset,
        bottom: SquircleIconButton.photoOffset,
        child: anchor,
      ),
    ],
  );
}

/// [person]'s photo for a circle or square (avatars, conversation rows, thumbnails): the demo
/// set's face crop of the main photo, or null for the initial / placeholder.
ImageProvider? personAvatarImage(SamplePerson person, {int width = 256}) {
  final source = person.avatarPhoto;
  return source == null ? null : localImage(source, width: width);
}

/// Where to anchor [person]'s avatar crop (centred for face crops).
Alignment personAvatarFocus(SamplePerson person) {
  final source = person.avatarPhoto;
  return source == null ? Alignment.center : localImageFocus(source);
}

/// [person]'s main photo for a portrait tile (the Likes grid), or null for the placeholder.
ImageProvider? personTileImage(SamplePerson person) {
  final source = person.photoAt(1);
  return source == null ? null : localImage(source, width: 540);
}

/// Where to anchor [person]'s main-photo crop so the face stays in frame.
Alignment personTileFocus(SamplePerson person) {
  final source = person.photoAt(1);
  return source == null ? Alignment.center : localImageFocus(source);
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
        alignment: localImageFocus(source),
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
