import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../data/media_picker.dart';
import 'chat_voice.dart';

/// Opens the attachment menu (library or camera) and returns the chosen photo, or null
/// when cancelled. Picker failures are explained in a toast and return null.
Future<MessageAttachment?> chooseAttachment(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = context.l10n;
  final choice = await showNumayaActionSheet(
    context: context,
    cancelLabel: l10n.cancel,
    actions: [
      (
        icon: NumayaIcons.image,
        label: l10n.chatAttachPhoto,
        destructive: false,
      ),
      (
        icon: NumayaIcons.camera,
        label: l10n.chatAttachTakePhoto,
        destructive: false,
      ),
    ],
  );
  if (choice == null || !context.mounted) return null;
  final picker = ref.read(mediaPickerProvider);
  try {
    return choice == 0 ? await picker.pickPhoto() : await picker.takePhoto();
  } on MediaPickException catch (e) {
    if (context.mounted) {
      NumayaToast.show(context, mediaFailureMessage(l10n, e.reason));
    }
    return null;
  }
}

String mediaFailureMessage(AppLocalizations l10n, MediaFailure f) =>
    switch (f) {
      MediaFailure.permissionDenied => l10n.mediaPermissionDenied,
      MediaFailure.unsupported => l10n.mediaUnsupported,
      MediaFailure.tooLarge => l10n.mediaTooLarge,
      MediaFailure.unreadable => l10n.mediaUnreadable,
      MediaFailure.unavailable => l10n.mediaUnavailable,
    };

/// "Photo", "Video" or "Voice note, 0:07": the inbox preview and the screen-reader name.
String attachmentSummary(AppLocalizations l10n, MessageAttachment a) =>
    switch (a.kind) {
      AttachmentKind.photo => l10n.chatAttachmentPhoto,
      AttachmentKind.video => l10n.chatAttachmentVideo,
      AttachmentKind.voice => l10n.chatVoiceLabel(
        formatClock(a.duration ?? Duration.zero),
      ),
    };

/// 0:07, 1:42.
String formatClock(Duration d) =>
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

/// 8.4 MB, 312 KB.
String formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024).ceil()} KB';
}

ImageProvider _imageFor(MessageAttachment a) => localImage(a.source!);

/// A photo from the device or the sample, decoded at the size it is shown.
class AttachmentImage extends StatelessWidget {
  const AttachmentImage({
    super.key,
    required this.attachment,
    required this.width,
  });

  final MessageAttachment attachment;
  final double width;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Image(
      image: ResizeImage(_imageFor(attachment), width: (width * dpr).round()),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, _, _) => ColoredBox(
        color: AppColors.photo,
        child: Center(
          child: Text(
            context.l10n.mediaMissing,
            textAlign: TextAlign.center,
            style: AppTypography.helper,
          ),
        ),
      ),
    );
  }
}

/// The attachment waiting above the composer: a small preview, what it is, and remove.
class PendingAttachment extends StatelessWidget {
  const PendingAttachment({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  final MessageAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = attachment;
    final detail = MetaText.join([
      if (a.sizeBytes != null && a.kind != AttachmentKind.voice)
        formatBytes(a.sizeBytes!),
      if (a.kind == AttachmentKind.voice) l10n.chatVoiceDemo,
    ]);
    // The description and Remove are separate nodes, so Remove can be reached on its own.
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              label: l10n.chatPendingLabel(attachmentSummary(l10n, a)),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadii.all(AppRadii.tag),
                      child: SizedBox.square(
                        dimension: 64,
                        child:
                            a.kind == AttachmentKind.photo && a.source != null
                            ? AttachmentImage(attachment: a, width: 64)
                            : ColoredBox(
                                color: AppColors.canvas,
                                child: Center(
                                  child: a.kind == AttachmentKind.video
                                      ? const MobileIcon(
                                          NumayaMobileIcons.video,
                                          size: AppSizes.iconMd,
                                        )
                                      : const NumayaIcon(
                                          NumayaIcons.mic,
                                          size: AppSizes.iconMd,
                                        ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.name ?? attachmentSummary(l10n, a),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.weight(
                              AppTypography.bodySm,
                              AppTypography.semibold,
                            ),
                          ),
                          if (detail.isNotEmpty)
                            MetaText(detail, style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          NavIconButton(
            icon: NumayaIcons.close,
            label: l10n.chatAttachmentRemove,
            style: NavButtonStyle.plain,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

/// An attachment inside the conversation, with its caption. Photos open full screen; videos are a
/// file card (no player in this build); demo voice notes say they carry no sound.
class AttachmentMessage extends StatelessWidget {
  const AttachmentMessage({
    super.key,
    required this.attachment,
    required this.caption,
    required this.mine,
    this.grouped = false,
    this.dimmed = false,
  });

  final MessageAttachment attachment;
  final String caption;
  final bool mine;
  final bool grouped;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = attachment;
    final width = (MediaQuery.sizeOf(context).width * 0.62).clamp(160.0, 260.0);
    final fg = mine ? AppColors.accentForeground : AppColors.ink;
    final muted = mine
        ? AppColors.accentForeground.withValues(alpha: 0.8)
        : AppColors.textSecondary;
    final Widget media = switch (a.kind) {
      AttachmentKind.photo => Pressable(
        onTap: a.source == null
            ? null
            : () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => _PhotoViewer(attachment: a),
                ),
              ),
        semanticLabel: l10n.chatOpenPhoto,
        excludeChildSemantics: true,
        pressedScale: 0.98,
        borderRadius: AppRadii.all(AppRadii.card),
        child: ClipRRect(
          borderRadius: AppRadii.all(AppRadii.card),
          child: SizedBox(
            width: width,
            height: width / AppMedia.chatPhoto,
            child: a.source == null
                ? const ColoredBox(color: AppColors.photo)
                : AttachmentImage(attachment: a, width: width),
          ),
        ),
      ),
      AttachmentKind.video => Pressable(
        onTap: () => NumayaToast.show(context, l10n.chatVideoNoPlayback),
        semanticLabel: '${l10n.chatAttachmentVideo}, ${a.name ?? ''}',
        excludeChildSemantics: true,
        pressedScale: 0.98,
        borderRadius: AppRadii.all(AppRadii.card),
        child: _FileCard(
          width: width,
          mine: mine,
          leading: MobileIcon(NumayaMobileIcons.play, size: 28, color: fg),
          title: a.name ?? l10n.chatAttachmentVideo,
          detail: MetaText.join([
            l10n.chatAttachmentVideo,
            if (a.sizeBytes != null) formatBytes(a.sizeBytes!),
          ]),
          fg: fg,
          muted: muted,
        ),
      ),
      AttachmentKind.voice => VoiceMessage(
        attachment: a,
        mine: mine,
        width: width,
      ),
    };
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: dimmed ? AppOpacity.pending : 1,
        child: Padding(
          padding: EdgeInsets.only(top: grouped ? 4 : AppSpacing.s2),
          child: Column(
            crossAxisAlignment: mine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              media,
              if (caption.isNotEmpty)
                MessageBubble(text: caption, mine: mine, grouped: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.width,
    required this.mine,
    required this.leading,
    required this.title,
    required this.detail,
    required this.fg,
    required this.muted,
  });

  final double width;
  final bool mine;
  final Widget leading;
  final String title;
  final String detail;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: mine ? AppColors.accent : AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.weight(
                    AppTypography.bodySm,
                    AppTypography.semibold,
                  ).copyWith(color: fg),
                ),
                MetaText(
                  detail,
                  style: AppTypography.caption.copyWith(color: muted),
                  separatorColor: muted.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.attachment});

  final MessageAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 4,
                child: Center(
                  child: Image(
                    image: _imageFor(attachment),
                    fit: BoxFit.contain,
                    semanticLabel: l10n.chatAttachmentPhoto,
                    // V4-01: a missing file says so instead of drawing an error box.
                    errorBuilder: (context, _, _) => Text(
                      l10n.mediaMissing,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.accentForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.s2,
              left: AppSpacing.s2,
              child: NavIconButton(
                icon: NumayaIcons.close,
                label: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
