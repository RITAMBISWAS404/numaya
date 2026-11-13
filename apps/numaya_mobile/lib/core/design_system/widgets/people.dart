import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/semantics.dart' show CustomSemanticsAction;

import '../foundations/app_colors.dart';
import '../foundations/app_haptics.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'buttons.dart' show NavButtonStyle, NavIconButton;
import 'content.dart' show MetaText;
import 'photo_overlays.dart';
import 'primitives.dart';

/// Initials avatar (`.theme-withings .avatar`): a circle, white initial on navy. [ring] draws the
/// thin blue ring of an unopened new match.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initial,
    this.size = 48,
    this.ring = false,
    this.image,
    this.imageAlignment = Alignment.center,
  });

  final String initial;
  final double size;
  final bool ring;

  /// A photo for the circle (a face crop works best); the initial shows while it loads, and if it
  /// fails.
  final ImageProvider? image;
  final Alignment imageAlignment;

  @override
  Widget build(BuildContext context) {
    final letter = Text(
      initial,
      style: AppTypography.weight(AppTypography.body, AppTypography.bold)
          .copyWith(
            fontSize: AppTypography.even(size * 0.42),
            height: 1,
            color: AppColors.onIdentity,
          ),
    );
    Widget circle = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.identity,
        shape: BoxShape.circle,
      ),
      clipBehavior: image == null ? Clip.none : Clip.antiAlias,
      alignment: Alignment.center,
      child: image == null
          ? letter
          : Stack(
              fit: StackFit.expand,
              children: [
                Center(child: letter),
                Image(
                  image: image!,
                  fit: BoxFit.cover,
                  alignment: imageAlignment,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ],
            ),
    );
    if (ring) {
      circle = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 2),
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppColors.canvas,
            shape: BoxShape.circle,
          ),
          child: circle,
        ),
      );
    }
    // R06: the verified mark follows the name ([NameWithBadge]); avatars carry no corner badge.
    return ExcludeSemantics(child: circle);
  }
}

/// The verified mark: Tabler's filled rosette check in brand purple (R06). Decorative; the name
/// beside it carries the spoken meaning ([NameWithBadge]).
class VerifiedMark extends StatelessWidget {
  const VerifiedMark({super.key, this.size = 18, this.color});
  final double size;

  /// Defaults to brand purple; white on a photo scrim.
  final Color? color;

  @override
  Widget build(BuildContext context) => NumayaIcon(
    NumayaIcons.verified,
    size: size,
    filled: true,
    color: color ?? AppColors.accent,
  );
}

/// A display name followed by the verified mark (R06): one gap ([AppLayout.iconLabelGap]), the
/// mark sized to the type tier and centred on the last line's x-height band. The name hugs its
/// longest line, so after a wrap the mark sits at the end of the text block's last line instead
/// of the card edge. [verifiedLabel] is spoken after the name ("Maya, 29, photo verified"); it
/// must say what was actually checked (photo, not identity).
class NameWithBadge extends StatelessWidget {
  const NameWithBadge({
    super.key,
    required this.name,
    required this.style,
    this.verified = false,
    this.verifiedLabel,
    this.maxLines,
    this.badgeColor,
    this.textAlign = TextAlign.start,
  });

  final String name;
  final TextStyle style;
  final bool verified;
  final String? verifiedLabel;
  final int? maxLines;
  final Color? badgeColor;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      name,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: textAlign,
      textWidthBasis: TextWidthBasis.longestLine,
      style: style,
    );
    if (!verified) return text;
    final fontSize = style.fontSize ?? 15;
    // 18 for body-sized names, 20 for titles, 24 for the hero: one step per type tier.
    final badge = fontSize >= 28
        ? 24.0
        : fontSize >= 18
        ? 20.0
        : 18.0;
    final line = MediaQuery.textScalerOf(context)
        .scale(fontSize * (style.height ?? 1.3));
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(child: text),
        const SizedBox(width: AppLayout.iconLabelGap),
        Padding(
          padding: EdgeInsets.only(bottom: ((line - badge) / 2).clamp(0, 40)),
          child: VerifiedMark(size: badge, color: badgeColor),
        ),
      ],
    );
    return Semantics(
      label: verifiedLabel == null ? name : '$name, $verifiedLabel',
      excludeSemantics: true,
      child: textAlign == TextAlign.center ? Center(child: row) : row,
    );
  }
}

/// A photo placeholder (no licensed photography exists): warm photo grey with an image glyph.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.label,
    this.aspectRatio = AppMedia.personPhoto,
    this.radius = AppRadii.photo,
    this.child,
  });

  final String label;

  /// Null fills the space it is given.
  final double? aspectRatio;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tile = ClipRRect(
      borderRadius: AppRadii.all(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.photo),
          // Only an empty slot shows the image glyph (it drew behind the lock on locked tiles).
          child ??
              const Center(
                child: NumayaIcon(
                  NumayaIcons.image,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              ),
        ],
      ),
    );
    return Semantics(
      image: true,
      label: label,
      child: aspectRatio == null
          ? tile
          : AspectRatio(aspectRatio: aspectRatio!, child: tile),
    );
  }
}

enum BadgeTone {
  /// Filled neutral grey with ink text (neutral state).
  neutral,

  /// Purple tint, purple semibold ("New").
  brand,

  /// On a photo: white fill.
  onPhoto,

  /// On the dark photo band: translucent white text pill.
  onDark,

  /// Ente alignment V3 semantic statuses: the subtle tint with the derived text role (4.99:1 or
  /// better). Pair with a filled icon or a word that states the status; colour is never alone.
  success,
  warning,
  error,
}

/// Status label (`.theme-withings .badge`).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = BadgeTone.neutral,
  });

  final String label;
  final NumayaIcons? icon;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, double weight) = switch (tone) {
      // Filled neutral, no outline (outline reduction).
      BadgeTone.neutral => (
        AppColors.fill,
        AppColors.ink,
        AppTypography.semibold,
      ),
      // V4: solid accents only (white on these fills: 4.90, 5.60, 5.81; ink on the amber: 9.95).
      BadgeTone.brand => (
        AppColors.accent,
        AppColors.accentForeground,
        AppTypography.semibold,
      ),
      BadgeTone.onPhoto || BadgeTone.onDark => (
        AppColors.photoPanel,
        AppColors.inkForeground,
        AppTypography.semibold,
      ),
      BadgeTone.success => (
        AppColors.success,
        AppColors.accentForeground,
        AppTypography.semibold,
      ),
      BadgeTone.warning => (
        AppColors.warningBase,
        AppColors.ink,
        AppTypography.semibold,
      ),
      BadgeTone.error => (
        AppColors.danger,
        AppColors.accentForeground,
        AppTypography.semibold,
      ),
    };
    // V4 rule IMG-1: anything over a photo is the shared black glass pill.
    if (tone == BadgeTone.onPhoto || tone == BadgeTone.onDark) {
      return PhotoPill(label: label, icon: icon);
    }
    // 26 tall at normal sizes; grows and wraps under large text instead of overflowing.
    return Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.badgeInsetX,
        vertical: AppLayout.badgeInsetY,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.all(AppRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            NumayaIcon(icon!, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              // Status labels are 12/16 (TR-04); the 8/12 micro trial was rejected.
              style: AppTypography.weight(
                AppTypography.micro,
                weight,
              ).copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// A white content card (`.theme-withings .profile-section`): someone's "About me", "You both
/// like", "My location", an event answer.
///
/// UI-020: the card's [title] is a small muted label above the content, and the content carries
/// the emphasis (callers set its text in [AppTypography.cardPrimary] or show chips), the same
/// hierarchy as the prompt card (UI-007). [explainer] keeps the title as a real heading for cards
/// whose body explains the title (help-style "how it works" cards), where the title is the point.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.explainer = false,
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final bool explainer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.s2),
              ],
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: explainer
                        ? AppTypography.card
                        : AppTypography.label.copyWith(
                            color: AppColors.textMuted,
                          ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: explainer ? AppSpacing.s3 : AppSpacing.s2),
          child,
        ],
      ),
    );
  }
}

/// A non-interactive chip on a white card (fill background, 12pt corner).
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    this.emoji,
    this.icon,
    this.onPage = false,
  });

  final String label;
  final String? emoji;
  final NumayaIcons? icon;

  /// On the stone page the chip is white; on a white card it takes the fill.
  final bool onPage;

  /// The emoji's size and its gap to the label, shared by every emoji pill (UI-019).
  static const double emojiSize = 16;
  static const double emojiGap = 6;

  @override
  Widget build(BuildContext context) {
    // At least the chip height, and taller when a long value wraps at large text: a person's own
    // details are never cut off with an ellipsis (frosted-navigation experiment, FN-02).
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.chip),
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.pillInsetX,
        vertical: AppLayout.pillInsetY,
      ),
      // On a white card the chip takes the stone page colour, a step lighter than the fill
      // (RD-05); on the page it's white.
      decoration: BoxDecoration(
        color: onPage ? AppColors.surface : AppColors.canvas,
        borderRadius: AppRadii.all(AppRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // UI-019: profile-detail pills lead with an emoji (an explicit exception to the Lucide
          // icon family, which every other app icon keeps), one size and one 6pt gap for all of
          // them. The emoji is decorative: the label alone is announced.
          if (emoji != null) ...[
            Emoji(emoji!, size: InfoChip.emojiSize),
            const SizedBox(width: InfoChip.emojiGap),
          ],
          if (icon != null) ...[
            NumayaIcon(icon!, size: 16, color: AppColors.textMuted),
            const SizedBox(width: AppLayout.compactIconGap),
          ],
          // The shared chip label (Figtree 14/18 medium), the same role as the selectable chips,
          // in ink because the value is the content. Was the 18pt bold card heading.
          Flexible(child: Text(label, style: AppTypography.chip)),
        ],
      ),
    );
  }
}

enum ActionKind { pass, superSwipe, like }

/// Discover's decision row (UI_REFINEMENT_DECISIONS RD-12): one full-width group of pills,
/// Pass (outlined), SuperSwipe (accent, compact, star only) and Like (ink, the primary). Pass and
/// Like carry their labels when there is room; under large text or on narrow screens every pill
/// shows its icon only, keeping its spoken label. [floating] lifts the row over content with the
/// float shadow (the only place it needs depth).
class DecisionBar extends StatelessWidget {
  const DecisionBar({
    super.key,
    required this.passLabel,
    required this.superLabel,
    required this.likeLabel,
    required this.onPass,
    required this.onSuper,
    required this.onLike,
    this.floating = false,
  });

  final String passLabel;
  final String superLabel;
  final String likeLabel;
  final VoidCallback? onPass;
  final VoidCallback? onSuper;
  final VoidCallback? onLike;
  final bool floating;

  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    // Floating over a profile being read (final design run FD-B2): three compact 56pt circles,
    // centred, icon-only (labels stay in the tooltip and semantics). The full-width labelled row
    // stacked on top of the tab bar covered about 190pt of the profile on a phone; the reading view
    // needs the actions present, not dominant (Bumble keeps one compact action over content).
    if (floating) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, kind) in ActionKind.values.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s4),
              SizedBox.square(
                dimension: height,
                child: _DecisionPill(
                  kind: kind,
                  label: switch (kind) {
                    ActionKind.pass => passLabel,
                    ActionKind.superSwipe => superLabel,
                    ActionKind.like => likeLabel,
                  },
                  showLabel: false,
                  floating: true,
                  onPressed: switch (kind) {
                    ActionKind.pass => onPass,
                    ActionKind.superSwipe => onSuper,
                    ActionKind.like => onLike,
                  },
                ),
              ),
            ],
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, box) {
        // Labels need about 112pt per wide pill at the current text size.
        final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final wide = (box.maxWidth - 2 * AppSpacing.s2) * 2 / 5;
        final labels = wide >= 112 * scale;
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: _DecisionPill(
                kind: ActionKind.pass,
                label: passLabel,
                showLabel: labels,
                floating: floating,
                onPressed: onPass,
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Expanded(
              child: _DecisionPill(
                kind: ActionKind.superSwipe,
                label: superLabel,
                showLabel: false,
                floating: floating,
                onPressed: onSuper,
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Expanded(
              flex: 2,
              child: _DecisionPill(
                kind: ActionKind.like,
                label: likeLabel,
                showLabel: labels,
                floating: floating,
                onPressed: onLike,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DecisionPill extends StatelessWidget {
  const _DecisionPill({
    required this.kind,
    required this.label,
    required this.showLabel,
    required this.floating,
    required this.onPressed,
  });

  final ActionKind kind;
  final String label;
  final bool showLabel;
  final bool floating;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color? edge, NumayaIcons icon) = switch (kind) {
      // Pass is filled neutral: it reads on the white hero card and floating over the page.
      ActionKind.pass => (
        AppColors.field,
        AppColors.ink,
        null,
        NumayaIcons.close,
      ),
      // SuperSwipe is special but secondary: a white surface with a purple star (V4: no tint).
      ActionKind.superSwipe => (
        AppColors.surface,
        AppColors.accentOnTint,
        null,
        NumayaIcons.star,
      ),
      // Like is the screen's primary action: brand purple.
      ActionKind.like => (
        AppColors.accent,
        AppColors.accentForeground,
        null,
        NumayaIcons.heart,
      ),
    };
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: label,
        excludeChildSemantics: true,
        pressedScale: 0.96,
        borderRadius: AppRadii.all(floating ? AppRadii.pill : AppRadii.control),
        // Ente Button Large geometry inline (20pt corners); the floating trio stays circular, as
        // Ente's Icon Button Type=Circular for controls over photos.
        child: Container(
          height: DecisionBar.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.all(
              floating ? AppRadii.pill : AppRadii.control,
            ),
            border: edge == null
                ? null
                : Border.all(
                    color: edge,
                    width: AppBorders.hairline,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
            boxShadow: floating ? AppElevation.withingsFloat : const [],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumayaIcon(icon, size: AppSizes.iconLg, color: fg),
              if (showLabel) ...[
                const SizedBox(width: AppLayout.iconLabelGap),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppTypography.button.copyWith(color: fg, height: 1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A list of consequences with icons (`ConsequenceList`): what an unmatch or block will do.
class ConsequenceList extends StatelessWidget {
  const ConsequenceList({super.key, required this.items});

  final List<(NumayaIcons, String)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (icon, text) in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                NumayaIcon(
                  icon,
                  size: AppSizes.iconMd,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Text(
                    text,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Message composer (`.theme-withings .composer`): a white 44pt pill field with a hairline beside a
/// round ink send button (disabled warm grey).
class Composer extends StatefulWidget {
  const Composer({
    this.idleAction,
    super.key,
    required this.controller,
    required this.placeholder,
    required this.sendLabel,
    required this.onSend,
    this.focusNode,
    this.enabled = true,
    this.leading,
    this.hasAttachment = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String placeholder;
  final String sendLabel;
  final ValueChanged<String> onSend;
  final bool enabled;

  /// A control before the field (the attachment button in chat).
  final Widget? leading;

  /// Shown in Send's place while there is nothing to send (the microphone in chat), so the slot
  /// never moves.
  final Widget? idleAction;

  /// An attachment is waiting, so Send works with an empty field (the text is its caption).
  final bool hasAttachment;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  FocusNode? _own;
  FocusNode get _focus => widget.focusNode ?? (_own ??= FocusNode());

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _focus.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focus.removeListener(_rebuild);
    _own?.dispose();
    super.dispose();
  }

  void _send() {
    final text = widget.controller.text.trim();
    if (text.isEmpty && !widget.hasAttachment) return;
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final canSend =
        widget.enabled &&
        (widget.controller.text.trim().isNotEmpty || widget.hasAttachment);
    final focused = _focus.hasFocus;
    // Restrained composer (CL-06): attachment, a filled pill field and send on the page, with
    // no surrounding tray. Bottom-aligned, so the actions stay level with the last line as the
    // field grows.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: AppSpacing.s2),
        ],
        Expanded(
          child: AnimatedContainer(
            duration: AppMotion.duration(context, AppMotion.base),
            // V16 draws a 44pt field; on Android the field itself is the 48dp tap target, so the
            // text padding lives inside the TextField and the pill is 48 tall.
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            // UI-037/UI-038: Ente Text Input's Default state (2275:11693) has no idle stroke. The
            // field sits in the white composer bar, so it takes the light fill to read as a field
            // (as Bumble's composer does); focused keeps the 2pt Numaya-purple edge.
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: AppRadii.all(AppRadii.field),
              border: Border.all(
                color: focused ? AppColors.focusField : const Color(0x00EAEAEA),
                width: AppBorders.focus,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Semantics(
              label: widget.placeholder,
              textField: true,
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: AppTypography.row,
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                    vertical: 14, // a 20pt line plus 28: the 48dp target
                  ),
                  hintText: widget.placeholder,
                  hintStyle: AppTypography.row.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
        // 8pt to the circle, as in V16 (the tap target adds 2pt).
        const SizedBox(width: AppSpacing.s2 - 2),
        if (!canSend && widget.idleAction != null)
          widget.idleAction!
        else
          Pressable(
            onTap: canSend ? _send : null,
            semanticLabel: widget.sendLabel,
            excludeChildSemantics: true,
            pressedScale: 0.92,
            borderRadius: AppRadii.all(AppRadii.control),
            // A 44pt rounded square (RD-02) inside a 48dp tap target.
            child: SizedBox.square(
              dimension: kMinInteractiveDimension,
              child: Center(
                child: AnimatedContainer(
                  duration: AppMotion.duration(context, AppMotion.base),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: canSend ? AppColors.accent : AppColors.disabled,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  // UI-039: a plain upward arrow.
                  child: NumayaIcon(
                    NumayaIcons.arrowUp,
                    size: 22,
                    color: canSend
                        ? AppColors.inkForeground
                        : AppColors.disabledForeground,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A chat bubble. The member's (`.theme-withings .message--me`): Withings blue, white text, 14pt
/// corners with a 6pt tail corner at the bottom right. The other person's (`.message--them`):
/// white with ink text and the tail at the bottom left.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    this.grouped = false,
    this.dimmed = false,
    this.mine = true,
    this.replyThumbnail,
    this.onQuoteTap,
    this.quoteStyle = QuoteStyle.block,
    this.replyAuthor,
    this.replyText,
    this.time,
  });

  final String text;

  /// "14:02", drawn small at the bubble's end.
  final String? time;
  final bool grouped;
  final bool dimmed;
  final bool mine;

  final QuoteStyle quoteStyle;

  /// A small picture of the quoted photo, at the end of the quote.
  final Widget? replyThumbnail;

  /// Jumps to the quoted message when it is still available.
  final VoidCallback? onQuoteTap;

  /// The message this one answers (UI-036): who wrote it and its text, quoted at the top.
  final String? replyAuthor;
  final String? replyText;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Opacity(
          opacity: dimmed ? AppOpacity.pending : 1,
          child: Container(
            margin: EdgeInsets.only(top: grouped ? 4 : AppSpacing.s3),
            // Ente Comment Bubble (5412:23548 / 5412:23575): 20pt corners with one 6pt corner on
            // the sender's side. UI-040: Numaya purple for your own, white for theirs.
            // Inset 16 across and 12 down (Ente uses 16 all round; tightened for chat density).
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s3,
            ),
            decoration: BoxDecoration(
              color: mine ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(mine ? AppRadii.card : 6),
                topRight: Radius.circular(mine ? 6 : AppRadii.card),
                bottomLeft: const Radius.circular(AppRadii.card),
                bottomRight: const Radius.circular(AppRadii.card),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (replyText != null) ...[
                  _QuotedReply(
                    author: replyAuthor ?? '',
                    text: replyText!,
                    onAccent: mine,
                    thumbnail: replyThumbnail,
                    onTap: onQuoteTap,
                    style: quoteStyle,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                ],
                Text(
                  text,
                  style: AppTypography.body.copyWith(
                    color: mine ? AppColors.accentForeground : AppColors.ink,
                  ),
                ),
                if (time != null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        time!,
                        style: AppTypography.micro.copyWith(
                          color: mine
                              ? AppColors.accentForeground.withValues(
                                  alpha: 0.78,
                                )
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// How a quote is drawn inside a bubble.
enum QuoteStyle { block, stripe, plain }

/// A replied-to message quoted inside a bubble (UI-036, V6): the stripe is a rounded capsule held
/// inside the block's inset, so it can never reach the block's corners.
class _QuotedReply extends StatelessWidget {
  const _QuotedReply({
    required this.author,
    required this.text,
    required this.onAccent,
    this.thumbnail,
    this.onTap,
    this.style = QuoteStyle.block,
  });

  final QuoteStyle style;
  final String author;
  final String text;
  final bool onAccent;
  final Widget? thumbnail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = onAccent ? AppColors.accentForeground : AppColors.ink;
    final sub = onAccent ? AppColors.accentForeground : AppColors.textSecondary;
    final body = _QuoteBlock(
      color: style == QuoteStyle.stripe
          ? null
          : (onAccent ? const Color(0x2EFFFFFF) : AppColors.canvas),
      stripe: style == QuoteStyle.plain
          ? null
          : (onAccent ? AppColors.accentForeground : AppColors.accent),
      radius: AppRadii.tile,
      trailing: thumbnail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (author.isNotEmpty)
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.weight(
                AppTypography.caption,
                AppTypography.semibold,
              ).copyWith(color: fg),
            ),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: sub),
          ),
        ],
      ),
    );
    return onTap == null ? body : GestureDetector(onTap: onTap, child: body);
  }
}

/// The reply being written (UI-036), shown at the top of the composer: who is being answered,
/// their text on one line, and a cancel button.
class ReplyPreview extends StatelessWidget {
  const ReplyPreview({
    super.key,
    required this.title,
    required this.text,
    required this.cancelLabel,
    required this.onCancel,
    this.thumbnail,
  });

  final String title;
  final String text;
  final String cancelLabel;
  final VoidCallback onCancel;

  /// A small picture of the photo being answered.
  final Widget? thumbnail;

  @override
  Widget build(BuildContext context) {
    return _QuoteBlock(
      color: AppColors.canvas,
      stripe: AppColors.accent,
      radius: AppRadii.tile,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?thumbnail,
          NavIconButton(
            icon: NumayaIcons.close,
            label: cancelLabel,
            style: NavButtonStyle.plain,
            onPressed: onCancel,
          ),
        ],
      ),
      child: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.weight(
                AppTypography.caption,
                AppTypography.semibold,
              ).copyWith(color: AppColors.accentOnTint),
            ),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

/// A quoted block: rounded surface, an inset capsule stripe, then the copy. Its height comes from
/// the copy, and the stripe stretches inside the inset.
class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({
    required this.color,
    required this.stripe,
    required this.radius,
    required this.child,
    this.trailing,
  });

  final Color? color;
  final Color? stripe;
  final double radius;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.all(radius),
      ),
      padding: const EdgeInsets.all(AppSpacing.s2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stripe != null) ...[
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: stripe,
                  borderRadius: AppRadii.all(2),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
            ],
            Flexible(
              fit: FlexFit.tight,
              child: Align(alignment: Alignment.centerLeft, child: child),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.s2),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// One chat message with its two horizontal gestures (UI-035, UI-036).
///
/// - Drag **left**: reveals the message's exact send [time] at the right edge of the row. Your own
///   bubble slides left to make room; the other person's bubble barely moves (it already leaves
///   the right of the row free). The time hides again on release.
/// - Drag **right** past [replyThreshold]: starts a reply to this message ([onReply]). A reply
///   glyph fades in behind the bubble while dragging; crossing the threshold gives one selection
///   haptic, and the bubble springs back on release.
///
/// Movement is bounded, and the drag only claims horizontal gestures, so vertical scrolling keeps
/// working. [timeShown] pins the time open without a gesture (the long-press and screen-reader
/// alternatives); [semanticActions] carries those alternatives for assistive technology.
class SwipeableMessage extends StatefulWidget {
  const SwipeableMessage({
    super.key,
    required this.child,
    required this.mine,
    required this.time,
    required this.onReply,
    this.timeShown = false,
    this.onLongPress,
    this.semanticActions = const {},
  });

  final Widget child;
  final bool mine;
  final String time;
  final VoidCallback onReply;
  final bool timeShown;
  final VoidCallback? onLongPress;
  final Map<CustomSemanticsAction, VoidCallback> semanticActions;

  /// How far right a drag must travel to start a reply.
  static const double replyThreshold = 56;

  /// The furthest a bubble moves either way.
  static const double maxRight = 72;
  static const double maxLeft = 64;

  @override
  State<SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<SwipeableMessage>
    with SingleTickerProviderStateMixin {
  double _dx = 0;
  bool _armed = false;
  late final AnimationController _settle = AnimationController(vsync: this)
    ..addListener(() => setState(() => _dx = _from * (1 - _settle.value)));
  double _from = 0;

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails d) {
    _settle.stop();
    setState(() {
      _dx = (_dx + (d.primaryDelta ?? 0)).clamp(
        -SwipeableMessage.maxLeft,
        SwipeableMessage.maxRight,
      );
    });
    final armed = _dx >= SwipeableMessage.replyThreshold;
    if (armed && !_armed) AppHaptics.fire(context, HapticMoment.selection);
    _armed = armed;
  }

  void _end([DragEndDetails? _]) {
    if (_armed) widget.onReply();
    _armed = false;
    _from = _dx;
    if (_from == 0) return;
    final duration = AppMotion.duration(context, AppMotion.state);
    if (duration == Duration.zero) {
      setState(() => _dx = 0);
      return;
    }
    _settle
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final left = (-_dx).clamp(0.0, SwipeableMessage.maxLeft);
    final right = _dx.clamp(0.0, SwipeableMessage.maxRight);
    final timeOpacity = widget.timeShown
        ? 1.0
        : (left / (SwipeableMessage.maxLeft * 0.6)).clamp(0.0, 1.0);
    // Your bubble slides fully; theirs only a quarter as far (they already leave room).
    final shownLeft = widget.timeShown && left == 0
        ? (widget.mine ? SwipeableMessage.maxLeft * 0.75 : 0.0)
        : (widget.mine ? left : left * 0.25);
    return Semantics(
      customSemanticsActions: widget.semanticActions,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: _update,
        onHorizontalDragEnd: _end,
        onHorizontalDragCancel: _end,
        onLongPress: widget.onLongPress,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The reply glyph, behind the bubble's leading edge.
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: (right / SwipeableMessage.replyThreshold).clamp(
                    0.0,
                    1.0,
                  ),
                  child: Center(
                    child: NumayaIcon(
                      NumayaIcons.undo,
                      size: AppSizes.iconMd,
                      color: _armed ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            // The exact time, at the right edge of the row.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: ExcludeSemantics(
                excluding: timeOpacity == 0,
                child: Opacity(
                  opacity: timeOpacity,
                  child: Center(
                    child: Text(
                      widget.time,
                      style: AppTypography.micro.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(right - shownLeft, 0),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

/// The match portrait placeholder (`.organic-portrait`): a scalloped shape in the warm photo grey
/// with an ink initial.
class ScallopPortrait extends StatelessWidget {
  const ScallopPortrait({super.key, required this.initial, this.size = 230});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ScallopClipper(),
      child: Container(
        width: size,
        height: size,
        // A neutral portrait ground (V4: no decorative tint).
        color: AppColors.identity,
        alignment: Alignment.center,
        child: Text(
          initial,
          style:
              AppTypography.weight(
                AppTypography.pageTitle,
                AppTypography.bold,
              ).copyWith(
                fontSize: AppTypography.even(size / 3),
                height: 1,
                color: AppColors.accentOnTint,
              ),
        ),
      ),
    );
  }
}

class _ScallopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // V16's organic frame (`scallop(10, 46.5, 3)` in a 100 box): ten soft lobes, 3% deep.
    const lobes = 10;
    final c = size.center(Offset.zero);
    final unit = size.width / 100;
    final path = Path();
    const steps = 200;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps * 2 * math.pi;
      final rr = unit * (46.5 + 3 * math.cos(lobes * t));
      final p = c + Offset(math.cos(t) * rr, math.sin(t) * rr);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Action sheet, as Ente's Action Sheet (v2) (25316:7380, OV-03): one white sheet attached to the
/// bottom edge with a grabber, rows of a 20pt muted glyph and a Body label (destructive rows in
/// red), then Ente's hairline and a quiet centred Cancel row. Cancel stays visible (Ente relies on
/// tapping outside): it is the explicit, accessible way out. Returns the chosen index.
Future<int?> showNumayaActionSheet({
  required BuildContext context,
  required List<({NumayaIcons icon, String label, bool destructive})> actions,
  required String cancelLabel,
}) {
  return showModalBottomSheet<int>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet(context),
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
    ),
    builder: (context) {
      Widget row(int i) {
        final a = actions[i];
        final label = a.destructive ? AppColors.negative : AppColors.ink;
        final glyph = a.destructive ? AppColors.negative : AppColors.textMuted;
        return Pressable(
          onTap: () => Navigator.of(context).pop(i),
          semanticLabel: a.label,
          excludeChildSemantics: true,
          pressedScale: 1,
          // At least a row tall; grows with large text instead of clipping the label.
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.touchMin + 4),
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenGutter,
              vertical: AppSpacing.s2,
            ),
            child: Row(
              children: [
                NumayaIcon(a.icon, size: AppSizes.iconMd, color: glyph),
                const SizedBox(width: AppSpacing.s4),
                Expanded(
                  child: Text(
                    a.label,
                    style: AppTypography.weight(
                      AppTypography.body,
                      AppTypography.medium,
                    ).copyWith(color: label),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        // The white runs behind the system navigation bar; the rows stay above it.
        padding: EdgeInsets.only(
          bottom: AppSpacing.s2 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(
                top: AppSpacing.s2,
                bottom: AppSpacing.s3,
              ),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: AppRadii.all(AppRadii.pill),
              ),
            ),
            // Scrolls when the actions don't fit (small phone, large text); Cancel stays put.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [for (var i = 0; i < actions.length; i++) row(i)],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppLayout.screenGutter,
                vertical: AppSpacing.s2,
              ),
              child: ExcludeSemantics(
                child: SizedBox(
                  height: AppBorders.hairline,
                  width: double.infinity,
                  child: ColoredBox(color: AppColors.divider),
                ),
              ),
            ),
            Pressable(
              onTap: () => Navigator.of(context).pop(),
              semanticLabel: cancelLabel,
              excludeChildSemantics: true,
              pressedScale: 1,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: AppSizes.touchMin + 4,
                ),
                alignment: Alignment.center,
                child: Text(
                  cancelLabel,
                  style: AppTypography.weight(
                    AppTypography.body,
                    AppTypography.semibold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// View tabs (`.theme-withings .filter-chips` without emoji): plain ink labels with a count; the
/// selected one is a blue-tint pill with deep-blue text (the reference's "Week Month Year").
class ViewTabs extends StatelessWidget {
  const ViewTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.label,
    this.bleed = 0,
    this.onWhite = false,
    this.keys,
  });

  /// How far the row scrolls past its own edges: the page gutter for a row that sits in a padded
  /// page, so options scroll to the screen edge instead of being cut at the gutter (RR-1). The
  /// first option still lines up with the gutter.
  final double bleed;

  /// UI-047: the tabs sit on a white surface. Inactive pills are white, so only then do they
  /// need a subtle edge; on the grey page and grey sheets (every current caller) the white fill
  /// alone is the boundary.
  final bool onWhite;

  /// Optional keys, one per option (tests and capture scripts find pills by key).
  final List<Key>? keys;

  /// A null count shows the label alone (segmented choices such as Basic / Advanced).
  final List<({String label, int? count})> options;
  final int selected;
  final ValueChanged<int> onSelect;

  /// Accessible name of the group ("Filter likes").
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      child: _Bleed(
        bleed: bleed,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: bleed),
          // The row owns the gap between pills (8, `groupGap`); each pill owns its 12pt inset.
          // Before this, adjacent pills touched ("Unread 1" ran into "Your move 2").
          child: Row(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: AppLayout.groupGap),
                Pressable(
                  key: keys == null ? null : keys![i],
                  onTap: () => onSelect(i),
                  haptic: HapticMoment.selection,
                  semanticLabel: options[i].count == null
                      ? options[i].label
                      : '${options[i].label}, ${options[i].count}',
                  selected: i == selected,
                  excludeChildSemantics: true,
                  pressedScale: 0.97,
                  borderRadius: AppRadii.all(AppRadii.tile),
                  // Ente Tag Chip (2482:6479): 44 tall, 16pt corners, 20pt insets, Body label;
                  // exactly one selected, in the primary (Numaya purple) with a white label.
                  child: AnimatedContainer(
                    duration: AppMotion.duration(context, AppMotion.base),
                    height: AppSizes.tagChip,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s5,
                    ),
                    // UI-022/UI-047: the inactive pill is white. On the grey page and grey sheets
                    // that fill is its boundary, with no stroke; on a white surface ([onWhite])
                    // a subtle hairline edge marks it.
                    decoration: BoxDecoration(
                      color: i == selected
                          ? AppColors.accent
                          : AppColors.surface,
                      borderRadius: AppRadii.all(AppRadii.tile),
                    ),
                    // Painted on top, so the edge takes no room from the label's inset.
                    foregroundDecoration: i == selected || !onWhite
                        ? null
                        : BoxDecoration(
                            borderRadius: AppRadii.all(AppRadii.tile),
                            border: Border.all(
                              color: AppColors.borderStrong,
                              width: AppBorders.hairline,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: options[i].label),
                          if (options[i].count != null)
                            TextSpan(
                              text: '  ${options[i].count}',
                              style: TextStyle(
                                color: i == selected
                                    ? AppColors.accentForeground
                                    : AppColors.textMuted,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                        ],
                      ),
                      style: AppTypography.bodySm.copyWith(
                        color: i == selected
                            ? AppColors.accentForeground
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A person tile (`.theme-withings .person-tile`): a 3:4 photo placeholder (14pt corner) with an
/// optional tag, the name with a verified mark, and a caption.
class PersonTile extends StatelessWidget {
  const PersonTile({
    super.key,
    required this.title,
    required this.caption,
    required this.semanticLabel,
    required this.onTap,
    this.verified = false,
    this.badge,
    this.image,
    this.imageAlignment = Alignment.center,
  });

  final String title;
  final String caption;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool verified;
  final Widget? badge;

  /// The person's main photo; the tile stays the placeholder grey without one.
  final ImageProvider? image;
  final Alignment imageAlignment;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      pressedScale: 0.98,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.photo,
                borderRadius: AppRadii.all(AppRadii.card),
                image: image == null
                    ? null
                    : DecorationImage(
                        image: image!,
                        fit: BoxFit.cover,
                        alignment: imageAlignment,
                      ),
              ),
              padding: const EdgeInsets.all(AppSpacing.s2),
              alignment: Alignment.topLeft,
              child: badge,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.weight(
                    AppTypography.row,
                    AppTypography.semibold,
                  ),
                ),
              ),
              if (verified) ...[
                const SizedBox(width: 4),
                const VerifiedMark(size: 18),
              ],
            ],
          ),
          const SizedBox(height: 2),
          MetaText(caption, style: AppTypography.caption),
        ],
      ),
    );
  }
}

/// Lets a horizontal scroller extend [bleed] past both sides of its slot (ViewTabs.bleed).
class _Bleed extends StatelessWidget {
  const _Bleed({required this.bleed, required this.child});

  final double bleed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (bleed == 0) return child;
    return LayoutBuilder(
      builder: (context, box) => OverflowBox(
        fit: OverflowBoxFit.deferToChild,
        minWidth: box.maxWidth + 2 * bleed,
        maxWidth: box.maxWidth + 2 * bleed,
        child: child,
      ),
    );
  }
}

/// How bright the lower part of a photo is (replacement V8 adaptive scrim, C-07). The photo is decoded once at 12x16
/// and the bottom 40% averaged as relative luminance (0 dark, 1 white). Cached per image, so each
/// photo is measured once per launch.
abstract final class PhotoLuma {
  static final Map<ImageProvider, double> _cache = {};

  /// The cached value, or null when [image] has not been measured yet.
  static double? cached(ImageProvider image) => _cache[image];

  static Future<double?> measure(ImageProvider image) async {
    final hit = _cache[image];
    if (hit != null) return hit;
    final small = ResizeImage(
      image,
      width: 12,
      height: 16,
      policy: ResizeImagePolicy.exact,
    );
    final completer = Completer<ui.Image?>();
    final stream = small.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(info.image.clone());
        info.dispose();
      },
      onError: (_, _) {
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);
    final decoded = await completer.future;
    stream.removeListener(listener);
    if (decoded == null) return null;
    try {
      final data = await decoded.toByteData();
      if (data == null) return null;
      final w = decoded.width, h = decoded.height;
      var sum = 0.0;
      var n = 0;
      for (var y = (h * 0.6).floor(); y < h; y++) {
        for (var x = 0; x < w; x++) {
          final i = (y * w + x) * 4;
          double lin(int c) {
            final v = c / 255;
            return v <= 0.04045
                ? v / 12.92
                : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
          }

          sum +=
              0.2126 * lin(data.getUint8(i)) +
              0.7152 * lin(data.getUint8(i + 1)) +
              0.0722 * lin(data.getUint8(i + 2));
          n++;
        }
      }
      final luma = n == 0 ? 0.0 : sum / n;
      _cache[image] = luma;
      return luma;
    } finally {
      decoded.dispose();
    }
  }
}

/// The gradient behind content on a photo (replacement V8, C-07; V4 IMG-2 was a fixed 24%).
/// It covers only the band under the content and eases to clear above it, so the rest of the
/// photograph is never darkened. Given [sample] (the photo underneath), its strength follows how
/// bright the photo's lower part is: a dark photo keeps the light 24% edge, a bright or white one
/// rises to 52% at the very bottom so white names stay readable (with [PhotoText.shadows]).
/// Without a sample, or before the photo has been measured, the light edge is used.
class PhotoScrim extends StatefulWidget {
  const PhotoScrim({
    super.key,
    required this.child,
    this.fade = 72,
    this.padding = EdgeInsets.zero,
    this.sample,
  });

  final Widget child;
  final double fade;

  /// Space around [child] inside the gradient.
  final EdgeInsets padding;

  /// The photo under the scrim, measured to set the gradient's strength.
  final ImageProvider? sample;

  /// Adapt to the photo (default). False keeps V7's fixed 24% edge for comparison (lab group
  /// r8-photo-scrim); set once from the app root.
  static bool adaptive = true;

  /// The bottom-edge opacity for a photo whose lower part has relative luminance [luma].
  static double edgeFor(double? luma) {
    // Owner note (selections pass): no text shadow, so the gradient carries the contrast alone.
    // UI-066 (V8): about 10% darker optically than the selections scrim (40%, 32 to 62%), on the
    // same eased stops: unmeasured 46%; dark photos 37%, bright ones up to 70%.
    if (luma == null || !adaptive) return 0.46;
    final t = ((luma - 0.18) / 0.42).clamp(0.0, 1.0);
    return 0.37 + 0.33 * t;
  }

  @override
  State<PhotoScrim> createState() => _PhotoScrimState();
}

class _PhotoScrimState extends State<PhotoScrim> {
  double? _luma;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  @override
  void didUpdateWidget(PhotoScrim old) {
    super.didUpdateWidget(old);
    if (old.sample != widget.sample) _measure();
  }

  void _measure() {
    final sample = widget.sample;
    if (sample == null) {
      _luma = null;
      return;
    }
    _luma = PhotoLuma.cached(sample);
    if (_luma != null) return;
    unawaited(
      PhotoLuma.measure(sample)
          .then((v) {
            if (mounted && widget.sample == sample) setState(() => _luma = v);
          })
          .catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final edge = PhotoScrim.edgeFor(_luma);
    Color at(double share) => Color.fromRGBO(0, 0, 0, edge * share);
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: AppMotion.duration(context, AppMotion.base),
              curve: AppMotion.easeOut,
              decoration: BoxDecoration(
                // Eased (an ease-out curve sampled at five stops), so no edge shows where it
                // ends: strongest under the text, gone by the top of the band.
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [at(1), at(0.72), at(0.4), at(0.14), at(0)],
                  stops: const [0, 0.3, 0.56, 0.8, 1],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: widget.padding.add(EdgeInsets.only(top: widget.fade)),
          child: widget.child,
        ),
      ],
    );
  }
}
