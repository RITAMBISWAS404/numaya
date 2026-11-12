import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../l10n/l10n.dart';

/// Fable design lab, group `fx-compliment-thread`: the first event of a conversation that a
/// Compliment started, before the recipient has answered. Same data in every option; the rules
/// (reply is free, the sender cannot write until you reply, Dismiss/Report/Block stay available)
/// are untouched.
///
/// A (recipe C1, compact context): no separate sender photo (the header already carries the
/// avatar and name). One full-width card: what was complimented as an inset block with your photo
/// or your own answer, then their words in the reading role.
class FxComplimentCard extends StatefulWidget {
  const FxComplimentCard({
    super.key,
    required this.label,
    required this.words,
    required this.time,
    this.contextTitle,
    this.contextBody,
    this.thumbnail,
  });

  /// "On your photo" / "On your answer".
  final String label;

  /// "Photo 1", the prompt's question, or the unavailable notice.
  final String? contextTitle;

  /// Your own answer to the prompt, when it is still available.
  final String? contextBody;
  final Widget? thumbnail;
  final String words;
  final String time;

  /// Answers longer than this collapse to two lines behind an explicit Show more.
  static const int collapseAt = 90;

  @override
  State<FxComplimentCard> createState() => _FxComplimentCardState();
}

class _FxComplimentCardState extends State<FxComplimentCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final body = widget.contextBody;
    final long = body != null && body.length > FxComplimentCard.collapseAt;
    return Container(
      key: const ValueKey('compliment-bubble'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The owner's quote style (block with inset stripe), at card width.
          ClipRRect(
            borderRadius: AppRadii.all(AppRadii.tag),
            child: ColoredBox(
              color: AppColors.canvas,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      width: 3,
                      child: ColoredBox(color: AppColors.accent),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.s3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.label,
                              style: AppTypography.weight(
                                AppTypography.caption,
                                AppTypography.semibold,
                              ).copyWith(color: AppColors.accentOnTint),
                            ),
                            if (widget.contextTitle != null)
                              Text(
                                widget.contextTitle!,
                                style: AppTypography.caption,
                              ),
                            if (body != null) ...[
                              const SizedBox(height: AppSpacing.s1),
                              Text(
                                body,
                                maxLines: long && !_open ? 2 : null,
                                overflow: long && !_open
                                    ? TextOverflow.ellipsis
                                    : null,
                                style: AppTypography.bodySm,
                              ),
                              if (long)
                                TextLink(
                                  label: _open
                                      ? l10n.fxShowLess
                                      : l10n.fxShowMore,
                                  onPressed: () =>
                                      setState(() => _open = !_open),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (widget.thumbnail != null)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.s2),
                        child: ClipRRect(
                          borderRadius: AppRadii.all(AppRadii.tag - 4),
                          child: SizedBox(
                            width: 54,
                            height: 72,
                            child: widget.thumbnail,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(widget.words, style: AppTypography.answer),
          const SizedBox(height: AppSpacing.s1),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(widget.time, style: AppTypography.micro),
          ),
        ],
      ),
    );
  }
}

/// B (recipe C2, decide first): the sender's photo with their name on it, their words as the
/// one large line, what it was about as a small line with its thumbnail. The answer is a pair of
/// explicit actions (see `ComplimentThread`): Dismiss and Reply.
class FxIntroduction extends StatelessWidget {
  const FxIntroduction({
    super.key,
    required this.photo,
    required this.photoLabel,
    required this.sample,
    required this.name,
    required this.detail,
    required this.words,
    required this.contextLine,
    required this.time,
    required this.onOpenProfile,
    required this.profileLabel,
    this.thumbnail,
  });

  final Widget? photo;
  final String photoLabel;
  final ImageProvider? sample;
  final String name;
  final String? detail;
  final String words;
  final String contextLine;
  final Widget? thumbnail;
  final String time;
  final VoidCallback onOpenProfile;
  final String profileLabel;

  @override
  Widget build(BuildContext context) {
    final white = AppColors.inkForeground;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pressable(
          key: const ValueKey('compliment-sender-photo'),
          onTap: onOpenProfile,
          semanticLabel: profileLabel,
          excludeChildSemantics: true,
          pressedScale: 0.98,
          borderRadius: AppRadii.all(AppRadii.heroCard),
          child: ClipRRect(
            borderRadius: AppRadii.all(AppRadii.heroCard),
            child: Stack(
              children: [
                PhotoPlaceholder(
                  label: photoLabel,
                  aspectRatio: 4 / 3,
                  radius: 0,
                  child: photo,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: PhotoScrim(
                    fade: 72,
                    sample: sample,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s4,
                      0,
                      AppSpacing.s4,
                      AppSpacing.s4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: AppTypography.headline.copyWith(
                            color: white,
                            shadows: PhotoText.shadows,
                          ),
                        ),
                        if (detail != null)
                          Text(
                            detail!,
                            style: AppTypography.bodySm.copyWith(
                              color: white,
                              shadows: PhotoText.shadows,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Container(
          key: const ValueKey('compliment-bubble'),
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(words, style: AppTypography.emptyTitle),
              const SizedBox(height: AppSpacing.s3),
              Row(
                children: [
                  if (thumbnail != null) ...[
                    ClipRRect(
                      borderRadius: AppRadii.all(8),
                      child: SizedBox(width: 28, height: 28, child: thumbnail),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                  ] else ...[
                    const MobileIcon(
                      NumayaMobileIcons.compliment,
                      size: 16,
                      color: AppColors.accentOnTint,
                    ),
                    const SizedBox(width: AppSpacing.s1),
                  ],
                  Expanded(
                    child: Text(
                      contextLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Text(time, style: AppTypography.micro),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
