import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';

/// Fable design lab, group `fx-compliment-thread`: the first event of a conversation that a
/// Compliment started, before the recipient has answered. Same data in every option; the rules
/// (reply is free, the sender cannot write until you reply, Dismiss/Report/Block stay available)
/// are untouched.
///
/// A (selected) is drawn by `ComplimentThread` itself as an incoming `MessageBubble` that quotes
/// your photo or prompt (owner note, selections pass 2026-11-13).

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
