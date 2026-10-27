import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_haptics.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

/// Initials avatar (`.theme-withings .avatar`): a circle, white initial on navy. [ring] draws the
/// thin blue ring of an unopened new match.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initial,
    this.size = 48,
    this.ring = false,
    this.verified = false,
  });

  final String initial;
  final double size;
  final bool ring;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    Widget circle = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.identity,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.weight(AppTypography.body, AppTypography.semibold)
            .copyWith(
              fontSize: size * 0.42,
              height: 1,
              color: AppColors.inkForeground,
            ),
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
    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          if (verified)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  color: AppColors.canvas,
                  shape: BoxShape.circle,
                ),
                child: VerifiedMark(size: size * 0.32),
              ),
            ),
        ],
      ),
    );
  }
}

/// The verified mark: Withings blue (the web's `VerifiedBadge compact`).
class VerifiedMark extends StatelessWidget {
  const VerifiedMark({super.key, this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) =>
      NumayaIcon(NumayaIcons.verified, size: size, color: AppColors.accent);
}

/// A photo placeholder (no licensed photography exists): warm photo grey with an image glyph.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.label,
    this.aspectRatio = 4 / 5,
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
          const Center(
            child: NumayaIcon(
              NumayaIcons.image,
              size: 32,
              color: AppColors.textSecondary,
            ),
          ),
          ?child,
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
  /// Outlined 1pt ink, 6pt corner (neutral state).
  neutral,

  /// Blue tint, deep-blue semibold ("New").
  brand,

  /// On a photo: white fill.
  onPhoto,

  /// On the dark photo band: translucent white text pill.
  onDark,
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
    final (Color? bg, Color fg, Color? edge, double weight) = switch (tone) {
      BadgeTone.neutral => (
        null,
        AppColors.ink,
        AppColors.ink,
        AppTypography.medium,
      ),
      BadgeTone.brand => (
        AppColors.accentTint,
        AppColors.accentOnTint,
        null,
        AppTypography.semibold,
      ),
      BadgeTone.onPhoto => (
        AppColors.surface,
        AppColors.accentOnTint,
        null,
        AppTypography.semibold,
      ),
      BadgeTone.onDark => (
        const Color(0x33121212),
        AppColors.inkForeground,
        null,
        AppTypography.semibold,
      ),
    };
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg ?? Colors.transparent,
        borderRadius: AppRadii.all(AppRadii.tag),
        border: edge == null
            ? null
            : Border.all(color: edge, width: AppBorders.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            NumayaIcon(icon!, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.weight(
              AppTypography.caption,
              weight,
            ).copyWith(color: fg, height: 1),
          ),
        ],
      ),
    );
  }
}

/// A white card with a card title (`.theme-withings .profile-section`): someone's prompt, "You
/// both like", "About me", "My location".
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.leading,
  });

  final String title;
  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s4),
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
                  child: Text(title, style: AppTypography.card),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.chip,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
      decoration: BoxDecoration(
        color: onPage ? AppColors.surface : AppColors.fill,
        borderRadius: AppRadii.all(AppRadii.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Emoji(emoji!, size: 15.5),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            NumayaIcon(icon!, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.card,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

enum ActionKind { pass, superSwipe, like }

/// Discover actions (`.theme-withings .action-bar`): 56pt circles: Pass outlined, SuperSwipe
/// Withings blue, Like ink.
class RoundAction extends StatelessWidget {
  const RoundAction({
    super.key,
    required this.kind,
    required this.label,
    required this.onPressed,
    this.floating = false,
  });

  final ActionKind kind;
  final String label;
  final VoidCallback? onPressed;

  /// Over a photo the SuperSwipe floats (float shadow).
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color? edge, NumayaIcons icon) = switch (kind) {
      ActionKind.pass => (
        AppColors.surface,
        AppColors.ink,
        AppColors.ink,
        NumayaIcons.close,
      ),
      ActionKind.superSwipe => (
        AppColors.accent,
        AppColors.accentForeground,
        null,
        NumayaIcons.star,
      ),
      ActionKind.like => (
        AppColors.ink,
        AppColors.inkForeground,
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
        pressedScale: 0.92,
        borderRadius: AppRadii.all(AppRadii.pill),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: edge == null
                ? null
                : Border.all(color: edge, width: AppBorders.hairline),
            boxShadow: floating ? AppElevation.withingsFloat : const [],
          ),
          alignment: Alignment.center,
          child: NumayaIcon(icon, size: 26, color: fg),
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
    super.key,
    required this.controller,
    required this.placeholder,
    required this.sendLabel,
    required this.onSend,
    this.focusNode,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String placeholder;
  final String sendLabel;
  final ValueChanged<String> onSend;
  final bool enabled;

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
    if (text.isEmpty) return;
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.enabled && widget.controller.text.trim().isNotEmpty;
    final focused = _focus.hasFocus;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: AppMotion.duration(context, AppMotion.base),
            // V16 draws a 44pt field; on Android the field itself is the 48dp tap target, so the
            // text padding lives inside the TextField and the pill is 48 tall.
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.all(22),
              border: Border.all(
                color: focused ? AppColors.focusField : AppColors.border,
                width: focused ? AppBorders.focus : AppBorders.hairline,
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
                    vertical: 13,
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
        Pressable(
          onTap: canSend ? _send : null,
          semanticLabel: widget.sendLabel,
          excludeChildSemantics: true,
          pressedScale: 0.92,
          borderRadius: AppRadii.all(AppRadii.pill),
          // The V16 44pt circle inside a 48dp tap target.
          child: SizedBox.square(
            dimension: kMinInteractiveDimension,
            child: Center(
              child: AnimatedContainer(
                duration: AppMotion.duration(context, AppMotion.base),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: canSend ? AppColors.ink : AppColors.disabled,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: NumayaIcon(
                  NumayaIcons.send,
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
  });

  final String text;
  final bool grouped;
  final bool dimmed;
  final bool mine;

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
            margin: EdgeInsets.only(top: grouped ? 4 : AppSpacing.s2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: mine ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadii.card),
                topRight: const Radius.circular(AppRadii.card),
                bottomLeft: Radius.circular(mine ? AppRadii.card : 6),
                bottomRight: Radius.circular(mine ? 6 : AppRadii.card),
              ),
            ),
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                color: mine ? AppColors.accentForeground : AppColors.ink,
              ),
            ),
          ),
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
        color: AppColors.photo,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: AppTypography.weight(
            AppTypography.pageTitle,
            AppTypography.bold,
            // 88pt in the 264pt V16 frame.
          ).copyWith(fontSize: size / 3, height: 1),
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

/// Action sheet (`.theme-withings .sheet--actions`): a white group of rows with dividers and a
/// separate white Cancel block, both with the card corner. Returns the chosen index.
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
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    elevation: 0,
    builder: (context) {
      Widget row(int i) {
        final a = actions[i];
        final color = a.destructive ? AppColors.negative : AppColors.ink;
        return Pressable(
          onTap: () => Navigator.of(context).pop(i),
          semanticLabel: a.label,
          excludeChildSemantics: true,
          pressedScale: 1,
          child: Container(
            height: AppSizes.row,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Row(
              children: [
                NumayaIcon(a.icon, size: AppSizes.iconMd, color: color),
                const SizedBox(width: AppSpacing.s4),
                Expanded(
                  child: Text(
                    a.label,
                    style: AppTypography.row.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s3,
          0,
          AppSpacing.s3,
          AppSpacing.s2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.all(AppRadii.card),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                    row(i),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
            Pressable(
              onTap: () => Navigator.of(context).pop(),
              semanticLabel: cancelLabel,
              excludeChildSemantics: true,
              pressedScale: 0.99,
              borderRadius: AppRadii.all(AppRadii.card),
              child: Container(
                width: double.infinity,
                height: AppSizes.row,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.all(AppRadii.card),
                ),
                alignment: Alignment.center,
                child: Text(cancelLabel, style: AppTypography.button),
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
  });

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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++)
              Pressable(
                onTap: () => onSelect(i),
                haptic: HapticMoment.selection,
                semanticLabel: options[i].count == null
                    ? options[i].label
                    : '${options[i].label}, ${options[i].count}',
                selected: i == selected,
                excludeChildSemantics: true,
                pressedScale: 0.97,
                borderRadius: AppRadii.all(AppRadii.pill),
                child: AnimatedContainer(
                  duration: AppMotion.duration(context, AppMotion.base),
                  height: AppSizes.chip,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.accentTint
                        : Colors.transparent,
                    borderRadius: AppRadii.all(AppRadii.pill),
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
                                  ? AppColors.accentOnTint
                                  : AppColors.textMuted,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                      ],
                    ),
                    style:
                        AppTypography.weight(
                          AppTypography.card,
                          AppTypography.medium,
                        ).copyWith(
                          color: i == selected
                              ? AppColors.accentOnTint
                              : AppColors.ink,
                        ),
                  ),
                ),
              ),
          ],
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
  });

  final String title;
  final String caption;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool verified;
  final Widget? badge;

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
          Text(
            caption,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
