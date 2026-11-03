import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_haptics.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
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

/// Bottom navigation: a floating white pill holding icons only, centred above the home indicator.
/// Each destination is a 52pt target with a tooltip (long press) and a screen-reader label; the
/// current one is marked by [indicator] and announced as selected. Notification dots stay red.
class NumayaTabBar extends StatelessWidget {
  const NumayaTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
    this.indicator = TabIndicatorStyle.tint,
  });

  final List<TabItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final TabIndicatorStyle indicator;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: AppColors.canvas,
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
            const inner = 12.0;
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < n; i++) ...[
                      if (i > 0) SizedBox(width: gap),
                      _tab(context, i, item),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, int i, double size) {
    final item = items[i];
    final current = i == currentIndex;
    final duration = AppMotion.duration(context, AppMotion.state);
    final (Color bg, Color fg) = !current
        ? (const Color(0x00FFFFFF), AppColors.textMuted)
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
    final radius = indicator == TabIndicatorStyle.tint
        ? AppRadii.iconButton
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

/// Grouped row (`.theme-withings .list-row`): 56pt minimum, a 16pt regular label, a secondary
/// subtitle, and a trailing switch, value or chevron.
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

  /// A person's avatar in place of [leading] (people lists).
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final isSwitch = switchValue != null;
    final chevron = showChevron ?? (onTap != null && !isSwitch && !danger);
    // 60% of the row (rows fill their group, so the screen's content width stands in).
    final valueMax =
        (MediaQuery.sizeOf(context).width.clamp(0.0, AppSpacing.contentMax) -
            2 * AppSpacing.gutter) *
        0.6;
    final row = Container(
      constraints: const BoxConstraints(minHeight: AppSizes.row),
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.cardPadding,
        vertical: AppSpacing.s3,
      ),
      child: Row(
        children: [
          if (avatar != null) ...[
            avatar!,
            const SizedBox(width: AppSpacing.s3),
          ] else if (leading != null) ...[
            NumayaIcon(leading!, size: AppSizes.iconMd, color: AppColors.ink),
            const SizedBox(width: AppSpacing.s3),
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
      ),
    );
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

/// A titled group of rows (`.list-group`): a 22pt medium ink heading, the rows on one white card
/// with hairline dividers inset 16pt on both sides, a secondary footnote.
class ListGroup extends StatelessWidget {
  const ListGroup({
    super.key,
    this.title,
    required this.children,
    this.footnote,
  });

  final String? title;
  final List<Widget> children;
  final String? footnote;

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
          // No dividers: rows are separated by their own height and padding (outline reduction).
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
            child: Column(children: children),
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
