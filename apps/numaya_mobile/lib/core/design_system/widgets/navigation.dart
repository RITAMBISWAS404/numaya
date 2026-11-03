import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_haptics.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import '../tokens/monochrome_tokens.dart';
import 'icon_tile.dart';
import 'people.dart';
import 'primitives.dart';

class TabItem {
  const TabItem({
    required this.label,
    required this.icon,
    this.badgeCount = 0,
    this.badgeLabel,
  });
  final String label;
  final NumayaIcons icon;

  /// Shows V16's red notification dot when above zero.
  final int badgeCount;

  /// Accessible label when badged, e.g. "Likes, 2 new".
  final String? badgeLabel;
}

/// How the current destination is marked in the icon-only navigation pill (compared in the Design
/// Lab; [tint] is the shipped choice, see NAVIGATION_SPEC.md).
enum TabIndicatorStyle {
  /// A subtle purple rounded square behind a purple filled icon.
  tint,

  /// A solid purple circle behind a white filled icon.
  filled,

  /// The current item widens into a purple pill; others stay icon-sized.
  expanded,
}

/// What the navigation pill is made of (frosted-navigation experiment).
enum TabBarSurface {
  /// Frosted glass over content that scrolls beneath it: a clipped blur, a white tint and a
  /// hairline edge. The host scaffold must extend its body behind the bar.
  frosted,

  /// The opaque white pill on a strip of page colour: the approved design, and the fallback.
  opaque,
}

/// Bottom navigation: a floating pill holding icons only, centred above the home indicator.
/// Each destination is a 52pt target with a tooltip (long press) and a screen-reader label; the
/// current one is marked by [indicator] and announced as selected. Notification dots stay red.
/// With [surface] frosted, High Contrast (the only related accessibility setting Flutter exposes;
/// there is no reduce-transparency flag) switches it back to the opaque pill.
class NumayaTabBar extends StatelessWidget {
  const NumayaTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
    this.indicator = TabIndicatorStyle.tint,
    this.surface = TabBarSurface.frosted,
  });

  /// Space between the pill's edge and each item.
  static const double tabInset = 6;

  final List<TabItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final TabIndicatorStyle indicator;
  final TabBarSurface surface;

  /// Whether this build draws glass: frosted, unless the person asked for High Contrast.
  bool frostedIn(BuildContext context) =>
      surface == TabBarSurface.frosted && !MediaQuery.highContrastOf(context);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final frosted = frostedIn(context);
    return _frame(
      frosted: frosted,
      systemInset: bottom,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s4,
          AppSpacing.s2,
          AppSpacing.s4,
          bottom > 0 ? bottom : AppSpacing.s4,
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            // Narrow phones tighten the gaps, then the items (never below 48): labels never come
            // back.
            final n = items.length;
            final extra = indicator == TabIndicatorStyle.expanded
                ? AppSizes.tabItem * 0.7
                : 0.0;
            const inner = 2 * tabInset;
            var gap = AppSpacing.s2;
            var item = AppSizes.tabItem;
            double need() => inner + n * item + extra + (n - 1) * gap;
            if (need() > box.maxWidth) gap = AppSpacing.s1;
            if (need() > box.maxWidth) {
              item = ((box.maxWidth - inner - extra - (n - 1) * gap) / n).clamp(
                48.0,
                AppSizes.tabItem,
              );
            }
            final row = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < n; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  _tab(context, i, item, frosted: frosted),
                ],
              ],
            );
            if (!frosted) {
              return Center(
                heightFactor: 1,
                child: Container(
                  height: AppSizes.tabBar,
                  padding: const EdgeInsets.all(inner / 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.all(AppRadii.pill),
                    boxShadow: AppElevation.subtle,
                  ),
                  child: row,
                ),
              );
            }
            // The blur is bounded by the pill's clip, so only the 64pt-tall pill samples what is
            // beneath it. No shadow: under a translucent fill it would grey the glass.
            return Center(
              heightFactor: 1,
              child: ClipRRect(
                borderRadius: AppRadii.all(AppRadii.pill),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: MonoGlass.blur,
                    sigmaY: MonoGlass.blur,
                  ),
                  child: Container(
                    height: AppSizes.tabBar,
                    padding: const EdgeInsets.all(inner / 2),
                    decoration: BoxDecoration(
                      color: MonoGlass.tint,
                      borderRadius: AppRadii.all(AppRadii.pill),
                    ),
                    // Painted on top, so the hairline takes no room from the items (a border in
                    // the decoration insets the row by 2pt and overflows a 320pt phone).
                    foregroundDecoration: BoxDecoration(
                      borderRadius: AppRadii.all(AppRadii.pill),
                      border: Border.all(
                        color: MonoGlass.edge,
                        width: AppBorders.hairline,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: row,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Opaque: the pill on a strip of page colour, as approved. Frosted: content shows around and
  /// beneath the pill, except under the system navigation (the three buttons or the gesture
  /// handle), which keeps a near-opaque page-colour strip so Android's own controls stay legible
  /// over any photo (found on the emulator in three-button mode).
  Widget _frame({
    required bool frosted,
    required double systemInset,
    required Widget child,
  }) {
    if (!frosted) return ColoredBox(color: AppColors.canvas, child: child);
    return Stack(
      children: [
        if (systemInset > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: systemInset,
            child: const ColoredBox(color: MonoGlass.systemInset),
          ),
        child,
      ],
    );
  }

  Widget _tab(
    BuildContext context,
    int i,
    double size, {
    required bool frosted,
  }) {
    final item = items[i];
    final current = i == currentIndex;
    final duration = AppMotion.duration(context, AppMotion.state);
    // On glass, unselected icons take the stronger secondary ink: the muted grey drops to 3.38:1
    // over a dark photo, text2 stays at 5.46:1 or better.
    final idle = frosted ? AppColors.textSecondary : AppColors.textMuted;
    final (Color bg, Color fg) = !current
        ? (const Color(0x00FFFFFF), idle)
        : switch (indicator) {
            TabIndicatorStyle.tint => (
              AppColors.accentTint,
              AppColors.accentOnTint,
            ),
            TabIndicatorStyle.filled => (
              AppColors.accent,
              AppColors.accentForeground,
            ),
            TabIndicatorStyle.expanded => (
              AppColors.accent,
              AppColors.accentForeground,
            ),
          };
    final itemWidth = current && indicator == TabIndicatorStyle.expanded
        ? size + AppSizes.tabItem * 0.7
        : size;
    // The tint sits 6pt inside a 64pt pill, so its corner is the pill's minus the inset: a 52pt
    // item becomes a circle, concentric with the bar's ends (FP-06).
    final radius = indicator == TabIndicatorStyle.tint
        ? AppRadii.nested(AppSizes.tabBar / 2, tabInset)
        : AppRadii.pill;
    return Semantics(
      selected: current,
      button: true,
      child: Tooltip(
        message: item.label,
        excludeFromSemantics: true,
        child: Pressable(
          onTap: () => onSelect(i),
          semanticLabel: item.badgeCount > 0
              ? (item.badgeLabel ?? item.label)
              : item.label,
          excludeChildSemantics: true,
          pressedScale: 0.92,
          borderRadius: AppRadii.all(radius),
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.easeOut,
            width: itemWidth,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadii.all(radius),
            ),
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                NumayaIcon(item.icon, outline: !current, size: 26, color: fg),
                if (item.badgeCount > 0)
                  Positioned(
                    right: -3,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.negative,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
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

/// Switch: iOS proportions (51 × 31). On: brand purple with a white thumb. Off: the grey fill with
/// a 1.5pt outline in the 3:1 control grey, so the off state still reads as a control.
class NumayaSwitch extends StatelessWidget {
  const NumayaSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.duration(context, AppMotion.base);
    return AnimatedContainer(
      duration: duration,
      width: AppSizes.switchWidth,
      height: AppSizes.switchHeight,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value ? AppColors.accent : AppColors.fill,
        borderRadius: AppRadii.all(AppRadii.pill),
        border: Border.all(
          color: value ? AppColors.accent : AppColors.control,
          width: AppBorders.selected,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: AppMotion.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: AppSizes.switchThumb,
          height: AppSizes.switchThumb,
          decoration: BoxDecoration(
            color: value ? AppColors.surface : AppColors.control,
            shape: BoxShape.circle,
            boxShadow: value ? AppElevation.thumb : null,
          ),
        ),
      ),
    );
  }
}

/// Grouped row (`.theme-withings .list-row`): 60pt minimum, a 16pt regular label, a secondary
/// subtitle, and a trailing switch, value or chevron. A [leading] icon sits in a 40pt [IconTile]
/// coloured by [tone] (neutral by default); [inlineIcon] draws it bare instead, for plain metadata.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.label,
    this.detail,
    this.value,
    this.onTap,
    this.switchValue,
    this.onSwitch,
    this.danger = false,
    this.showChevron,
    this.leading,
    this.tone = AccentTone.neutral,
    this.inlineIcon = false,
    this.avatar,
  });

  final String label;
  final String? detail;
  final String? value;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;
  final bool danger;
  final bool? showChevron;
  final NumayaIcons? leading;

  /// The meaning of the [leading] icon's tile.
  final AccentTone tone;

  /// The [leading] icon without a tile (metadata rows).
  final bool inlineIcon;

  /// Where the label starts, measured from the row's leading padding: dividers in a [ListGroup]
  /// start here so they never cross the icon.
  double get textInset => avatar != null
      ? (avatar is InitialsAvatar ? (avatar! as InitialsAvatar).size : 0) +
            AppLayout.tileLabelGap
      : leading == null
      ? 0
      : inlineIcon
      ? AppSizes.iconMd + AppLayout.tileLabelGap
      : IconTile.rowInset;

  /// A person's avatar in place of [leading] (people lists).
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: AppSizes.row),
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.cardPadding,
        vertical: AppSpacing.s3,
      ),
      // The value may take 60% of what the row has left after its leading tile or avatar.
      child: LayoutBuilder(
        builder: (context, box) =>
            _content((box.maxWidth - textInset).clamp(0.0, box.maxWidth) * 0.6),
      ),
    );
    return _wrap(row);
  }

  Widget _content(double valueMax) {
    final isSwitch = switchValue != null;
    final chevron = showChevron ?? (onTap != null && !isSwitch && !danger);
    return Row(
      children: [
        if (avatar != null) ...[
          avatar!,
          const SizedBox(width: AppLayout.tileLabelGap),
        ] else if (leading != null) ...[
          if (inlineIcon)
            NumayaIcon(leading!, size: AppSizes.iconMd, color: AppColors.ink)
          else
            IconTile(leading!, tone: danger ? AccentTone.danger : tone),
          const SizedBox(width: AppLayout.tileLabelGap),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.row.copyWith(
                  color: danger ? AppColors.negative : AppColors.ink,
                ),
              ),
              if (detail != null && detail!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  detail!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        // A value is a preview of what the row opens (the whole answer is one tap away): its
        // natural width up to 60% of the row and two lines; the label keeps the rest.
        if (value != null)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: valueMax),
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.s3),
              child: Text(
                value!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTypography.row.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
        if (isSwitch)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s3),
            child: NumayaSwitch(value: switchValue!, onChanged: onSwitch),
          ),
        if (chevron)
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.s2),
            child: NumayaIcon(
              NumayaIcons.chevronRight,
              size: AppSizes.iconMd,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }

  Widget _wrap(Widget row) {
    final isSwitch = switchValue != null;
    if (isSwitch) {
      return Pressable(
        onTap: onSwitch == null ? null : () => onSwitch!(!switchValue!),
        haptic: HapticMoment.selection,
        semanticLabel: detail == null ? label : '$label. $detail',
        toggled: switchValue,
        excludeChildSemantics: true,
        pressedScale: 1,
        child: row,
      );
    }
    if (onTap == null) {
      return Semantics(
        label: '$label${value == null ? '' : ', $value'}',
        excludeSemantics: true,
        child: row,
      );
    }
    // The value and detail are read out with the label, as they are seen with it.
    return Pressable(
      onTap: onTap,
      semanticLabel: [
        [label, ?value].join(', '),
        if (detail != null && detail!.isNotEmpty) detail!,
      ].join('. '),
      excludeChildSemantics: true,
      pressedScale: 1,
      child: row,
    );
  }
}

/// A titled group of rows (`.list-group`): a section heading, the rows on one white card, a
/// secondary footnote. Rows are separated by quiet [AppColors.divider] hairlines that start where
/// the row's text starts (never through its icon tile) and stop at the card's padding (FP-02).
class ListGroup extends StatelessWidget {
  const ListGroup({
    super.key,
    this.title,
    required this.children,
    this.footnote,
    this.dividers = true,
  });

  final String? title;
  final List<Widget> children;
  final String? footnote;

  /// Hairlines between rows. Off for groups whose rows are self-contained (cards, previews).
  final bool dividers;

  static double _inset(Widget row) =>
      AppLayout.cardPadding + (row is ListRow ? row.textInset : 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s3),
            child: Semantics(
              header: true,
              child: Text(title!, style: AppTypography.section),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0 && dividers)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: _inset(children[i]),
                        end: AppLayout.cardPadding,
                      ),
                      child: const ExcludeSemantics(
                        child: SizedBox(
                          height: AppBorders.hairline,
                          width: double.infinity,
                          child: ColoredBox(color: AppColors.divider),
                        ),
                      ),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ),
        if (footnote != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s1,
              AppSpacing.s2,
              AppSpacing.s1,
              0,
            ),
            child: Text(
              footnote!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty state (Meetup, Jomo): a white card with the illustration slot, a bold title and the
/// body, centred, and an optional compact action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.art,
    this.action,
  });

  final String title;
  final String body;
  final Widget? art;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.s4),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s8,
        AppSpacing.s6,
        AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (art != null) ...[
            ExcludeSemantics(child: art!),
            const SizedBox(height: AppSpacing.s5),
          ],
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTypography.emptyTitle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.s5),
            action!,
          ],
        ],
      ),
    );
  }
}
