import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../compliments/domain/compliment.dart';
import '../dating/domain/profile_fact_emoji.dart';
import '../dating/domain/sample_people.dart';
import '../dating/presentation/person_profile.dart';
import '../lab/profile_prompt_card.dart';

/// Fable design lab, group `fx-discover` (docs/design/fable-lab/EXPERIMENTS.md).
///
/// Same person, same data and the same actions as the baseline profile; only order, grouping and
/// where the Compliment action sits change. A: essentials first, labelled actions, facts as rows.
/// B: the photo carries the essentials and a labelled Compliment bar; facts as tiles.

/// The Compliment action with its name written out. [onPhoto] draws white on black glass for use
/// over an image; otherwise the quiet outline of a secondary button with the purple glyph.
class FxComplimentPill extends StatelessWidget {
  const FxComplimentPill({
    super.key,
    required this.name,
    required this.onPressed,
    this.onPhoto = false,
    this.label,
    this.expand = false,
  });

  final String name;
  final VoidCallback onPressed;
  final bool onPhoto;

  /// Defaults to "Compliment".
  final String? label;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fg = onPhoto ? AppColors.inkForeground : AppColors.ink;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MobileIcon(
          NumayaMobileIcons.compliment,
          size: 18,
          color: onPhoto ? AppColors.inkForeground : AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.s2),
        Flexible(
          child: Text(
            label ?? l10n.fxCompliment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.buttonSm.copyWith(color: fg, height: 1.2),
          ),
        ),
      ],
    );
    const pad = EdgeInsets.symmetric(
      horizontal: AppSpacing.s4,
      vertical: AppSpacing.s2,
    );
    final Widget body = onPhoto
        ? PhotoGlass(
            radius: AppRadii.control,
            padding: pad,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 24),
              child: Center(widthFactor: expand ? null : 1, child: content),
            ),
          )
        : Container(
            constraints: const BoxConstraints(
              minHeight: AppSizes.buttonHeightSm,
            ),
            padding: pad,
            decoration: BoxDecoration(
              borderRadius: AppRadii.all(AppRadii.control),
              border: Border.all(
                color: AppColors.buttonOutline,
                width: AppBorders.control,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Center(
              widthFactor: expand ? null : 1,
              heightFactor: 1,
              child: content,
            ),
          );
    return Pressable(
      onTap: onPressed,
      semanticLabel: l10n.complimentActionOn(name),
      excludeChildSemantics: true,
      borderRadius: AppRadii.all(AppRadii.control),
      child: body,
    );
  }
}

String _joined(AppLocalizations l10n, List<String> items) => switch (items) {
  [] => '',
  [final one] => one,
  _ => l10n.fxJoinAnd(
    items.sublist(0, items.length - 1).join(', '),
    items.last,
  ),
};

/// A: what decides a first look, straight under the photo and on the page itself (no card):
/// the bio, where they are and what they want, then what you share, then the one labelled action.
class FxEssentials extends StatelessWidget {
  const FxEssentials({super.key, required this.person, this.onCompliment});

  final SamplePerson person;
  final VoidCallback? onCompliment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = AppTypography.body.copyWith(color: AppColors.textSecondary);
    Widget meta(NumayaIcons icon, String text) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: NumayaIcon(
            icon,
            size: AppSizes.iconSm,
            color: AppColors.iconSupporting,
          ),
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(child: Text(text, style: muted)),
      ],
    );
    final where = [
      l10n.discoverDistance(person.distanceKm),
      if (person.livesIn != null) person.livesIn!,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (person.bio != null && person.bio!.isNotEmpty) ...[
            Text(person.bio!, style: AppTypography.answer),
            const SizedBox(height: AppSpacing.s3),
          ],
          meta(NumayaIcons.location, where),
          if (person.lookingFor != null) ...[
            const SizedBox(height: AppSpacing.s1),
            meta(
              NumayaIcons.heart,
              '${l10n.fxLookingFor}: ${person.lookingFor!}',
            ),
          ],
          if (person.shared.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s1),
            Semantics(
              key: const ValueKey('shared-interests'),
              child: meta(
                NumayaIcons.star,
                l10n.fxBothLike(_joined(l10n, person.shared)),
              ),
            ),
          ],
          if (onCompliment != null) ...[
            const SizedBox(height: AppSpacing.s4),
            FxComplimentPill(
              key: const ValueKey('compliment-photo-0'),
              name: person.name,
              label: l10n.complimentActionOn(person.name),
              expand: true,
              onPressed: onCompliment!,
            ),
          ],
        ],
      ),
    );
  }
}

/// B: the labelled Compliment bar that sits on the foot of the first photo.
class FxPhotoComplimentBar extends StatelessWidget {
  const FxPhotoComplimentBar({
    super.key,
    required this.name,
    required this.onPressed,
  });

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FxComplimentPill(
    name: name,
    onPhoto: true,
    expand: true,
    label: context.l10n.complimentActionOn(name),
    onPressed: onPressed,
  );
}

typedef _Fact = ({String emoji, String label, String value});

List<_Fact> _facts(AppLocalizations l10n, SamplePerson p, {bool intent = true}) => [
  if (p.identity != null)
    (emoji: ProfileFactEmoji.identity, label: '', value: p.identity!),
  if (intent && p.lookingFor != null)
    (
      emoji: ProfileFactEmoji.lookingFor,
      label: l10n.fxLookingFor,
      value: p.lookingFor!,
    ),
  if (p.heightCm > 0)
    (
      emoji: ProfileFactEmoji.height,
      label: l10n.editHeight,
      value: l10n.heightValue(p.heightCm),
    ),
  if (p.languages != null)
    (
      emoji: ProfileFactEmoji.languages,
      label: l10n.editLanguages,
      value: p.languages!,
    ),
  for (final d in p.details.entries)
    (
      emoji: ProfileFactEmoji.detail(d.key, d.value),
      label: d.key.label,
      value: d.value,
    ),
];

/// A: the facts as one card of labelled rows. The label says what a value is, so "Socially" or
/// "Libra" never needs decoding; at large text the value drops under its label.
class FxFactRows extends StatelessWidget {
  const FxFactRows({super.key, required this.person});

  final SamplePerson person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final facts = _facts(l10n, person, intent: false);
    if (facts.isEmpty) return const SizedBox.shrink();
    final stacked = MediaQuery.textScalerOf(context).scale(10) > 13;
    final label = AppTypography.body.copyWith(color: AppColors.textSecondary);
    final value = AppTypography.weight(
      AppTypography.body,
      AppTypography.semibold,
    );
    return ProfileSectionCard(
      title: l10n.fxBasics,
      child: Column(
        children: [
          for (var i = 0; i < facts.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s3),
            MergeSemantics(
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (facts[i].label.isNotEmpty)
                          Text(facts[i].label, style: label),
                        Text(facts[i].value, style: value),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (facts[i].label.isNotEmpty) ...[
                          Text(facts[i].label, style: label),
                          const SizedBox(width: AppSpacing.s4),
                        ],
                        Expanded(
                          child: Text(
                            facts[i].value,
                            textAlign: facts[i].label.isEmpty
                                ? TextAlign.start
                                : TextAlign.end,
                            style: value,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// B: the facts as short tiles, two to a row while both fit (one column at large text or on a
/// narrow phone). Each tile: emoji, a small label, the value.
class FxFactTiles extends StatelessWidget {
  const FxFactTiles({super.key, required this.person});

  final SamplePerson person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final facts = [
      ..._facts(l10n, person, intent: false),
      if (person.livesIn != null)
        (
          emoji: ProfileFactEmoji.livesIn,
          label: l10n.fxLivesInLabel,
          value: person.livesIn!,
        ),
    ];
    if (facts.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, box) {
        final oneColumn =
            MediaQuery.textScalerOf(context).scale(10) > 13 ||
            box.maxWidth < 300;
        const gap = AppSpacing.s2;
        Widget tile(_Fact f) => MergeSemantics(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.all(AppRadii.tile),
            ),
            child: Row(
              children: [
                Emoji(f.emoji, size: 20),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (f.label.isNotEmpty)
                        Text(f.label, style: AppTypography.caption),
                      Text(
                        f.value,
                        style: AppTypography.weight(
                          AppTypography.body,
                          AppTypography.semibold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        if (oneColumn) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < facts.length; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                tile(facts[i]),
              ],
            ],
          );
        }
        // Pairs share a height, so a value that wraps never leaves a ragged row.
        return Column(
          children: [
            for (var i = 0; i < facts.length; i += 2) ...[
              if (i > 0) const SizedBox(height: gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: tile(facts[i])),
                    const SizedBox(width: gap),
                    Expanded(
                      child: i + 1 < facts.length
                          ? tile(facts[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// B: what you share as the one highlighted block of the profile: a solid purple card with the
/// sentence written out, then the interests as chips.
class FxCommonGround extends StatelessWidget {
  const FxCommonGround({super.key, required this.person});

  final SamplePerson person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      key: const ValueKey('shared-interests'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.fxCommonGround,
            style: AppTypography.label.copyWith(
              color: AppColors.accentForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            l10n.fxBothLike(_joined(l10n, person.shared)),
            style: AppTypography.promptAnswer.copyWith(
              color: AppColors.accentForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// The profile below the first photo for `fx-discover` A and B. Photos keep their viewer and
/// every prompt and photo keeps its Compliment action (same keys as the baseline).
List<Widget> fxPersonSections(
  BuildContext context,
  SamplePerson person, {
  required String variant,
  required ValueChanged<int> onPhoto,
  required ValueChanged<ComplimentTarget> onCompliment,
}) {
  final l10n = context.l10n;
  final a = variant == 'A';
  var promptIndex = 0;
  Widget prompt(({String question, String answer}) p) {
    final index = promptIndex++;
    void go() => onCompliment(ComplimentTarget.prompt(index));
    return ProfilePromptCard(
      question: p.question,
      answer: p.answer,
      // B's prompt is the quote card; A keeps the selected card.
      variant: a ? null : 'B',
      action: a
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s3),
              child: FxComplimentPill(
                key: ValueKey('compliment-prompt-$index'),
                name: person.name,
                onPressed: go,
              ),
            )
          : ComplimentAnchor(
              key: ValueKey('compliment-prompt-$index'),
              name: person.name,
              onPressed: go,
            ),
    );
  }

  Widget photo(int position) {
    void go() => onCompliment(ComplimentTarget.photo(position - 1));
    final key = ValueKey('compliment-photo-${position - 1}');
    return Stack(
      children: [
        Pressable(
          onTap: () => onPhoto(position),
          semanticLabel: l10n.discoverOpenPhotos(person.name),
          pressedScale: 1,
          excludeChildSemantics: true,
          child: PhotoPlaceholder(
            label: l10n.discoverPhotoLabel(person.name, position),
            aspectRatio: AppMedia.personPhoto,
            radius: SquircleIconButton.photoRadius,
            child: personPhotoImage(person, position),
          ),
        ),
        Positioned(
          right: a ? AppSpacing.s3 : SquircleIconButton.photoOffset,
          bottom: a ? AppSpacing.s3 : SquircleIconButton.photoOffset,
          child: a
              ? FxComplimentPill(
                  key: key,
                  name: person.name,
                  onPhoto: true,
                  onPressed: go,
                )
              : ComplimentAnchor(key: key, name: person.name, onPressed: go),
        ),
      ],
    );
  }

  final sections = <Widget>[
    if (a) ...[
      FxEssentials(
        person: person,
        onCompliment: () => onCompliment(const ComplimentTarget.photo(0)),
      ),
      if (person.prompt != null) prompt(person.prompt!),
      if (person.photoCount > 1) photo(2),
      FxFactRows(person: person),
    ] else ...[
      if (person.shared.isNotEmpty) FxCommonGround(person: person),
      if (person.prompt != null) prompt(person.prompt!),
      if (person.bio != null && person.bio!.isNotEmpty)
        ProfileSectionCard(
          title: l10n.discoverAboutMe,
          child: Text(person.bio!, style: AppTypography.answer),
        ),
      FxFactTiles(person: person),
      if (person.photoCount > 1) photo(2),
    ],
    if (person.photoCount > 2) photo(3),
    for (final p in person.morePrompts) prompt(p),
    for (var i = 4; i <= person.photoCount; i++) photo(i),
  ];
  return [
    for (var i = 0; i < sections.length; i++) ...[
      if (i > 0)
        SizedBox(
          // A's un-carded essentials sit a little apart from the first card.
          height: a && i == 1 ? AppSpacing.s5 : AppSpacing.s3,
        ),
      sections[i],
    ],
  ];
}
