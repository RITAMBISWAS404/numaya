import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../compliments/domain/compliment.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart' show personPhotoImage;

/// V10 pilot (2026-11-16): the profile body below the Discover photo in the two candidate
/// directions. Same person data, order (UI-059: bio, photo 2, prompt 1, photo 3, ...) and exact
/// Compliment targets as [personSections]; only composition and hierarchy differ.
///
/// - `A` People first: one calm white sheet for who they are (bio, labelled facts, what you share),
///   then photos and unboxed prompts with labelled Compliment actions.
/// - `C` Editorial: the first prompt leads as a large pull quote, facts compress to one line,
///   photos and prompts alternate with a varied rhythm.
List<Widget> v10PersonSections(
  BuildContext context,
  SamplePerson person, {
  required String direction,
  ValueChanged<int>? onPhoto,
  ValueChanged<ComplimentTarget>? onCompliment,
  bool own = false,
  bool showDistance = true,
}) => direction == 'C'
    ? _editorial(context, person, onPhoto, onCompliment, own, showDistance)
    : _peopleFirst(context, person, onPhoto, onCompliment, own, showDistance);

/// Facts in a stable order with their own labels (no decorative emoji).
List<(String, String)> _facts(BuildContext context, SamplePerson p) {
  final l10n = context.l10n;
  return [
    // Identity first, as on the baseline (gender and pronouns are product truth, not decoration).
    if (p.identity != null) (l10n.editGender, p.identity!),
    if (p.lookingFor != null) (l10n.profileLookingFor, p.lookingFor!),
    if (p.heightCm > 0) (l10n.editHeight, l10n.heightValue(p.heightCm)),
    if (p.languages != null) (l10n.editLanguages, p.languages!),
    for (final d in p.details.entries) (d.key.label, d.value),
  ];
}

List<({String question, String answer})> _prompts(SamplePerson p) => [
  ?p.prompt,
  ...p.morePrompts,
];

/// A labelled Compliment action: what it does is written, not only drawn (the bare glyph was
/// ambiguous). [onPhoto] puts it on a photo as a dark glass pill.
class V10ComplimentButton extends StatelessWidget {
  const V10ComplimentButton({
    super.key,
    required this.name,
    required this.onPressed,
    this.onPhoto = false,
  });

  final String name;
  final VoidCallback onPressed;
  final bool onPhoto;

  /// Its laid-out size at the current text scale (icon, gap, label, padding; at least the 48pt
  /// target), so an overlay beside it can leave exactly that room.
  static Size measure(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: context.l10n.v8ComplimentTag,
        style: AppTypography.buttonSm.copyWith(height: 1.2),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final size = Size(
      (18 + AppSpacing.s1 + 2 + painter.width + 2 * AppSpacing.s3)
          .ceilToDouble(),
      math.max(
        kMinInteractiveDimension,
        (painter.height + 2 * AppSpacing.s2).ceilToDouble(),
      ),
    );
    painter.dispose();
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fg = onPhoto ? AppColors.inkForeground : AppColors.accentOnTint;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MobileIcon(NumayaMobileIcons.compliment, size: 18, color: fg),
        const SizedBox(width: AppSpacing.s1 + 2),
        Text(
          l10n.v8ComplimentTag,
          style: AppTypography.buttonSm.copyWith(color: fg, height: 1.2),
        ),
      ],
    );
    return Pressable(
      onTap: onPressed,
      semanticLabel: l10n.complimentActionOn(name),
      excludeChildSemantics: true,
      borderRadius: AppRadii.all(AppRadii.pill),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: Center(
          widthFactor: 1,
          child: onPhoto
              ? PhotoGlass(
                  radius: AppRadii.pill,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                    vertical: AppSpacing.s2,
                  ),
                  child: content,
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                    vertical: AppSpacing.s2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: AppRadii.all(AppRadii.pill),
                  ),
                  child: content,
                ),
        ),
      ),
    );
  }
}

Widget _photo(
  BuildContext context,
  SamplePerson person,
  int position, {
  required ValueChanged<int>? onPhoto,
  required ValueChanged<ComplimentTarget>? onCompliment,
  double radius = AppRadii.photo,
}) {
  final l10n = context.l10n;
  Widget tile = PhotoPlaceholder(
    label: l10n.discoverPhotoLabel(person.name, position),
    aspectRatio: AppMedia.personPhoto,
    radius: radius,
    child: personPhotoImage(person, position),
  );
  if (onPhoto != null) {
    tile = Pressable(
      onTap: () => onPhoto(position),
      semanticLabel: l10n.discoverOpenPhotos(person.name),
      pressedScale: 1,
      excludeChildSemantics: true,
      child: tile,
    );
  }
  if (onCompliment == null) return tile;
  return Stack(
    children: [
      tile,
      Positioned(
        right: AppLayout.cardPadding,
        bottom: AppLayout.cardPadding,
        child: V10ComplimentButton(
          key: ValueKey('compliment-photo-${position - 1}'),
          name: person.name,
          onPhoto: true,
          onPressed: () => onCompliment(ComplimentTarget.photo(position - 1)),
        ),
      ),
    ],
  );
}

/// Section and field labels: 14/20 medium in the supporting grey (round 2: 12pt was near the
/// legibility floor). Values stay the 15pt body, so the value still leads.
Widget _label(String text) =>
    Semantics(header: true, child: Text(text, style: _labelStyle));

TextStyle get _labelStyle => AppTypography.weight(
  AppTypography.labelCaps,
  AppTypography.medium,
).copyWith(color: AppColors.textSecondary);

const _hairline = ExcludeSemantics(
  child: SizedBox(
    height: AppBorders.hairline,
    child: ColoredBox(color: AppColors.divider),
  ),
);

// A: people first ------------------------------------------------------------------------------

List<Widget> _peopleFirst(
  BuildContext context,
  SamplePerson person,
  ValueChanged<int>? onPhoto,
  ValueChanged<ComplimentTarget>? onCompliment,
  bool own,
  bool showDistance,
) {
  final l10n = context.l10n;
  final facts = _facts(context, person);
  final hasBio = person.bio?.isNotEmpty ?? false;
  final prompts = _prompts(person);

  Widget factsGrid() => LayoutBuilder(
    builder: (context, box) {
      // Two columns while each holds a readable label; one at large text or narrow widths.
      final twoCols =
          box.maxWidth > 300 && MediaQuery.textScalerOf(context).scale(10) < 14;
      final w = twoCols ? (box.maxWidth - AppSpacing.s4) / 2 : box.maxWidth;
      return Wrap(
        key: const ValueKey('v10-facts'),
        spacing: AppSpacing.s4,
        runSpacing: AppSpacing.s3,
        children: [
          for (final (label, value) in facts)
            SizedBox(
              width:
                  twoCols &&
                      HyphenatedText.wordWidth(
                            context,
                            value,
                            AppTypography.body,
                          ) >
                          w
                  ? box.maxWidth
                  : w,
              child: Semantics(
                label: '$label: $value',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: _labelStyle),
                    const SizedBox(height: 2),
                    Text(value, style: AppTypography.body),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );

  final sheet = Container(
    key: const ValueKey('v10-about-sheet'),
    padding: const EdgeInsets.all(AppSpacing.s5),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasBio) ...[
          _label(l10n.discoverAboutMe),
          const SizedBox(height: AppSpacing.s2),
          BalancedText(person.bio!, style: AppTypography.cardPrimary),
        ],
        if (hasBio && facts.isNotEmpty)
          const Padding(
            key: ValueKey('about-divider'),
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
            child: _hairline,
          ),
        if (facts.isNotEmpty) factsGrid(),
        if (person.shared.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
            child: _hairline,
          ),
          Column(
            key: const ValueKey('shared-interests'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(
                own ? l10n.profileInterestsTitle : l10n.discoverYouBothLike,
              ),
              const SizedBox(height: AppSpacing.s2),
              Wrap(
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
                children: [
                  for (final s in person.shared)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s3,
                        vertical: AppSpacing.s1 + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentTint,
                        borderRadius: AppRadii.all(AppRadii.infoPill),
                      ),
                      child: Text(
                        s,
                        // 14/20: at the 12pt pill size the rendered glyphs measured 1.95:1
                        // against the tint (PR-004 guideline); at 14 they pass.
                        style: _labelStyle.copyWith(
                          color: AppColors.accentOnTint,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ],
    ),
  );

  Widget prompt(int index) {
    final p = prompts[index];
    return V10PromptCard(
      key: ValueKey('v10-prompt-$index'),
      question: p.question,
      answer: p.answer,
      action: onCompliment == null
          ? null
          : V10ComplimentButton(
              key: ValueKey('compliment-prompt-$index'),
              name: person.name,
              onPressed: () => onCompliment(ComplimentTarget.prompt(index)),
            ),
    );
  }

  final sections = <Widget>[
    if (hasBio || facts.isNotEmpty || person.shared.isNotEmpty) sheet,
    for (var k = 0; k < 5; k++) ...[
      if (person.photoCount > k + 1)
        _photo(
          context,
          person,
          k + 2,
          onPhoto: onPhoto,
          onCompliment: onCompliment,
        ),
      if (k < prompts.length) prompt(k),
    ],
    if (showDistance || person.livesIn != null)
      _location(context, person, showDistance),
  ];
  return [
    for (var i = 0; i < sections.length; i++) ...[
      if (i > 0) const SizedBox(height: AppSpacing.s4),
      sections[i],
    ],
  ];
}

Widget _location(BuildContext context, SamplePerson person, bool showDistance) {
  final l10n = context.l10n;
  final text = [
    if (showDistance) l10n.discoverDistance(person.distanceKm),
    if (person.livesIn != null) l10n.discoverLivesIn(person.livesIn!),
  ].join(' · ');
  return Padding(
    key: const ValueKey('v10-location'),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: NumayaIcon(
            NumayaIcons.location,
            size: AppSizes.iconSm,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(child: Text(text, style: AppTypography.helper)),
      ],
    ),
  );
}

// C: editorial ---------------------------------------------------------------------------------

List<Widget> _editorial(
  BuildContext context,
  SamplePerson person,
  ValueChanged<int>? onPhoto,
  ValueChanged<ComplimentTarget>? onCompliment,
  bool own,
  bool showDistance,
) {
  final l10n = context.l10n;
  final facts = _facts(context, person);
  final hasBio = person.bio?.isNotEmpty ?? false;
  final prompts = _prompts(person);

  Widget quote(int index, {required bool lead}) {
    final p = prompts[index];
    return Container(
      key: ValueKey('v10-prompt-$index'),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s5,
        AppSpacing.s5,
        AppSpacing.s5,
        onCompliment == null ? AppSpacing.s5 : AppSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: lead ? AppColors.accentTint : AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(p.question),
          const SizedBox(height: AppSpacing.s3),
          Text(
            '“${p.answer}”',
            style: (lead ? AppTypography.headline : AppTypography.emptyTitle)
                .copyWith(color: AppColors.textPrimary),
          ),
          if (onCompliment != null) ...[
            const SizedBox(height: AppSpacing.s3),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: V10ComplimentButton(
                key: ValueKey('compliment-prompt-$index'),
                name: person.name,
                onPressed: () => onCompliment(ComplimentTarget.prompt(index)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  final about = Padding(
    key: const ValueKey('v10-about'),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasBio) ...[
          _label(l10n.discoverAboutMe),
          const SizedBox(height: AppSpacing.s2),
          Text(person.bio!, style: AppTypography.cardPrimary),
          const SizedBox(height: AppSpacing.s3),
        ],
        if (facts.isNotEmpty)
          Text(
            facts.map((f) => f.$2).join('  ·  '),
            key: const ValueKey('v10-facts'),
            style: AppTypography.helper,
          ),
        if (person.shared.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s3),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      '${own ? l10n.profileInterestsTitle : l10n.discoverYouBothLike} ',
                ),
                TextSpan(
                  text: person.shared.join(', '),
                  style: AppTypography.weight(
                    AppTypography.helper,
                    AppTypography.semibold,
                  ).copyWith(color: AppColors.accentOnTint),
                ),
              ],
            ),
            style: AppTypography.helper,
          ),
        ],
      ],
    ),
  );

  final sections = <Widget>[
    if (prompts.isNotEmpty) quote(0, lead: true),
    if (hasBio || facts.isNotEmpty || person.shared.isNotEmpty) about,
    for (var k = 0; k < 5; k++) ...[
      if (person.photoCount > k + 1)
        _photo(
          context,
          person,
          k + 2,
          onPhoto: onPhoto,
          onCompliment: onCompliment,
        ),
      if (k + 1 < prompts.length) quote(k + 1, lead: false),
    ],
    if (showDistance || person.livesIn != null)
      _location(context, person, showDistance),
  ];
  return [
    for (var i = 0; i < sections.length; i++) ...[
      if (i > 0) const SizedBox(height: AppSpacing.s5),
      sections[i],
    ],
  ];
}

/// V10 A: the one prompt card, wherever a prompt is shown (Discover, previews, own Profile). A
/// small question label, the answer as the reading text, and one action under it (Compliment on
/// someone else's profile, Edit on your own).
class V10PromptCard extends StatelessWidget {
  const V10PromptCard({
    super.key,
    required this.question,
    required this.answer,
    this.action,
    this.onTap,
    this.trailingChevron = false,
  });

  final String question;
  final String answer;
  final Widget? action;
  final VoidCallback? onTap;

  /// The page's row pattern for an editable card (own Profile): a chevron, no text link.
  final bool trailingChevron;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _label(question)),
              if (trailingChevron)
                const ExcludeSemantics(
                  child: NumayaIcon(
                    NumayaIcons.chevronRight,
                    size: AppSizes.iconMd,
                    color: AppColors.iconSupporting,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          BalancedText(answer, style: AppTypography.answer),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.s2),
            action!,
          ],
        ],
      ),
    );
    final tap = onTap;
    if (tap == null) return card;
    return Pressable(
      onTap: tap,
      semanticLabel: '$question. $answer',
      // The label already reads the card; without this TalkBack read it twice (V10 device pass).
      excludeChildSemantics: action == null,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.card),
      child: card,
    );
  }
}
