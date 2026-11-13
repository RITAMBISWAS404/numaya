import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../lab/lab_registry.dart';
import '../application/dating_controller.dart';
import '../data/media_picker.dart';
import '../domain/sample_people.dart';
import 'chat_attachments.dart';
import 'person_profile.dart';
import 'time_format.dart';

/// One conversation in Chats or Archive. Card family `conversation-row` (Visual Lab V2):
/// O Ente list row, A your turn first, B separated cards, C large avatar, D dense single line.
/// Every variant speaks the same label: name, preview, time, unread count and your turn.
class ConversationRow extends ConsumerWidget {
  const ConversationRow({
    super.key,
    required this.person,
    required this.last,
    required this.unread,
    required this.yourMove,
    required this.now,
    required this.onTap,
    this.variant,
    this.compliment = false,
    this.fxStatus,
    this.fxWaiting = false,
    this.fxThumb,
  });

  /// Fable lab `fx-messages` (variants `FA`, `FB`): the Compliment's state in words. In `FA` it
  /// is a third line under the preview; in `FB` it leads the preview and says what it was about.
  final String? fxStatus;

  /// The status is waiting on the other person (drawn muted, not in the brand colour).
  final bool fxWaiting;

  /// `FB`: the complimented photo, at the row's end.
  final Widget? fxThumb;

  /// Where the text starts (avatar 56 + gap 16): the inset of the hairline between rows.
  static const double textInset = 72;

  /// The conversation is a Compliment nobody has answered yet.
  final bool compliment;

  final SamplePerson person;
  final DemoMessage last;
  final int unread;
  final bool yourMove;
  final DateTime now;
  final VoidCallback onTap;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var v = variant ?? ref.watch(labVariantProvider('conversation-row'));
    // The dense single line can't hold a name and a preview at large text: it falls back to the
    // baseline row there (density adapts; nothing is truncated to fit).
    if (v == 'D' && MediaQuery.textScalerOf(context).scale(15) > 22) v = 'O';
    final l10n = context.l10n;
    final text = last.attachment == null
        ? last.text
        : [
            attachmentSummary(l10n, last.attachment!),
            if (last.text.isNotEmpty) last.text,
          ].join(': ');
    final preview = last.mine ? l10n.youPrefix(text) : text;
    final kind = fxStatus ?? (compliment ? l10n.v8ComplimentTag : null);
    final time = shortTime(l10n, last.at, now);
    final semantics = [
      person.verified
          ? '${person.name}, ${l10n.photoVerifiedLabel}'
          : person.name,
      ?kind,
      preview,
      time,
      if (unread > 0) l10n.unreadCount(unread),
      if (yourMove) l10n.yourMoveTag,
    ].join('. ');

    final nameStyle = AppTypography.weight(
      AppTypography.row,
      AppTypography.semibold,
    );
    final previewStyle = AppTypography.weight(
      AppTypography.bodySm,
      unread > 0 ? AppTypography.semibold : AppTypography.regular,
    ).copyWith(color: unread > 0 ? AppColors.ink : AppColors.textMuted);

    Widget name({int? maxLines = 1}) => NameWithBadge(
      name: person.name,
      verified: person.verified,
      style: nameStyle,
      maxLines: maxLines,
    );
    Widget avatar(double size) => InitialsAvatar(
      initial: person.initial,
      size: size,
      image: personAvatarImage(person),
      imageAlignment: personAvatarFocus(person),
    );
    Widget trailingBadge() => unread > 0
        ? CountBadge(count: unread)
        : yourMove
        ? StatusBadge(label: l10n.yourMoveTag)
        : const SizedBox.shrink();

    final statusStyle = AppTypography.weight(
      AppTypography.caption,
      AppTypography.semibold,
    ).copyWith(color: fxWaiting ? AppColors.textMuted : AppColors.accentOnTint);
    final timeText = Text(
      time,
      style: AppTypography.micro.copyWith(
        color: unread > 0 ? AppColors.accentOnTint : AppColors.textMuted,
      ),
    );
    final Widget content;
    switch (v) {
      case 'V8':
        // UI-067/068/035 (V8): one list row. Name, then the preview in the shared muted grey
        // whether read or not; a compact filled grey glyph names a Compliment, photo, video or
        // voice note, with its text when there is some and a short type label otherwise. No
        // time on the row. The unread count is the trailing badge; "Your move" is a compact
        // pill beside the name, so the two never collide.
        final a = last.attachment;
        final Widget? glyph = compliment
            // Tabler has no filled message-heart: the Compliment mark stays the outline glyph
            // rather than an invented filled one (recorded limitation).
            ? const MobileIcon(
                NumayaMobileIcons.compliment,
                size: 16,
                color: AppColors.textMuted,
              )
            : switch (a?.kind) {
                AttachmentKind.photo => const NumayaIcon(
                  NumayaIcons.image,
                  size: 16,
                  filled: true,
                  color: AppColors.textMuted,
                ),
                AttachmentKind.video => const MobileIcon(
                  NumayaMobileIcons.video,
                  size: 16,
                  filled: true,
                  color: AppColors.textMuted,
                ),
                AttachmentKind.voice => const NumayaIcon(
                  NumayaIcons.mic,
                  size: 16,
                  filled: true,
                  color: AppColors.textMuted,
                ),
                null => null,
              };
        final body = a == null
            ? last.text
            : (last.text.isNotEmpty ? last.text : attachmentSummary(l10n, a));
        final line = last.mine ? l10n.youPrefix(body) : body;
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            children: [
              avatar(56),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: name()),
                        if (yourMove) ...[
                          const SizedBox(width: AppSpacing.s2),
                          StatusBadge(
                            key: const ValueKey('row-your-move'),
                            label: l10n.yourMoveTag,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (glyph != null) ...[
                          glyph,
                          const SizedBox(width: AppSpacing.s1 + 2),
                        ],
                        Expanded(
                          child: Text(
                            line,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: AppSpacing.s2),
                          CountBadge(count: unread),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'FA':
        // Lab A (recipe M1, quiet list): name and time, the preview, then a Compliment's state
        // in words. No turn pill: the section heading already says whose turn it is.
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            children: [
              avatar(56),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: name()),
                        const SizedBox(width: AppSpacing.s2),
                        timeText,
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: previewStyle,
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: AppSpacing.s2),
                          CountBadge(count: unread),
                        ],
                      ],
                    ),
                    if (fxStatus != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          MobileIcon(
                            NumayaMobileIcons.compliment,
                            size: 14,
                            color: statusStyle.color!,
                          ),
                          const SizedBox(width: AppSpacing.s1),
                          Expanded(child: Text(fxStatus!, style: statusStyle)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      case 'FB':
        // Lab B (recipe M2, context rows): a Compliment row leads with what it was about and
        // shows that photo; ordinary chats stay as they are.
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            children: [
              avatar(56),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: name()),
                        const SizedBox(width: AppSpacing.s2),
                        timeText,
                      ],
                    ),
                    if (fxStatus != null) ...[
                      const SizedBox(height: 2),
                      Text(fxStatus!, style: statusStyle),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: previewStyle,
                          ),
                        ),
                        // With a photo at the row's end, the unread count sits on the photo.
                        if ((yourMove || unread > 0) &&
                            !(fxThumb != null && unread > 0)) ...[
                          const SizedBox(width: AppSpacing.s2),
                          trailingBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (fxThumb != null) ...[
                const SizedBox(width: AppSpacing.s3),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadii.all(AppRadii.tag),
                      child: SizedBox(width: 44, height: 58, child: fxThumb),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: CountBadge(count: unread),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      case 'A':
        // Your turn first: the turn label takes the time's place; time drops under it.
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            children: [
              avatar(56),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    name(),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: previewStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (yourMove || unread > 0)
                    trailingBadge()
                  else
                    Text(time, style: AppTypography.micro),
                  if (yourMove || unread > 0) ...[
                    const SizedBox(height: AppSpacing.s1),
                    Text(time, style: AppTypography.micro),
                  ],
                ],
              ),
            ],
          ),
        );
      case 'B':
        content = Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s2),
          padding: const EdgeInsets.all(AppSpacing.s3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Row(
            children: [
              avatar(48),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: name()),
                        Text(time, style: AppTypography.micro),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: previewStyle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s2),
                        trailingBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'C':
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar(72),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.s1),
                    Row(
                      children: [
                        Expanded(child: name()),
                        Text(time, style: AppTypography.micro),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: previewStyle,
                    ),
                    if (yourMove || unread > 0) ...[
                      const SizedBox(height: AppSpacing.s2),
                      // A Row lets the badge keep its own width under a stretching Column.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [trailingBadge()],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      case 'D':
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
          child: Row(
            children: [
              avatar(40),
              const SizedBox(width: AppSpacing.s3),
              Flexible(flex: 0, child: name()),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: previewStyle,
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              if (unread > 0 || yourMove)
                trailingBadge()
              else
                Text(time, style: AppTypography.micro),
            ],
          ),
        );
      default:
        // V8 (WhatsApp's list rhythm): 56 avatar, name and time on one line, the preview under
        // it; the time turns purple while something is unread.
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            children: [
              avatar(56),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: name()),
                        const SizedBox(width: AppSpacing.s2),
                        Text(
                          time,
                          style: AppTypography.micro.copyWith(
                            color: unread > 0
                                ? AppColors.accentOnTint
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (compliment) ...[
                          const MobileIcon(
                            NumayaMobileIcons.compliment,
                            size: 16,
                            color: AppColors.accentOnTint,
                          ),
                          const SizedBox(width: AppSpacing.s1),
                        ],
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: previewStyle,
                          ),
                        ),
                        if (yourMove || unread > 0) ...[
                          const SizedBox(width: AppSpacing.s2),
                          trailingBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: semantics,
      excludeChildSemantics: true,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.card),
      child: content,
    );
  }
}
