import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../lab/lab_registry.dart';
import '../application/dating_controller.dart';
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
  });

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
    final time = shortTime(l10n, last.at, now);
    final semantics = [
      person.verified
          ? '${person.name}, ${l10n.photoVerifiedLabel}'
          : person.name,
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

    final Widget content;
    switch (v) {
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
                      trailingBadge(),
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
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            children: [
              avatar(64),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: name()),
                        const SizedBox(width: AppSpacing.s2),
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
