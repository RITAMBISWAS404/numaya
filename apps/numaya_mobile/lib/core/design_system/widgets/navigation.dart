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

/// Bottom navigation (Meetup): a floating white rounded bar with a soft shadow, inset from the
/// screen edges. The current tab sits on a grey capsule with a purple filled icon and label; the
/// others are muted with the outline icon.
class NumayaTabBar extends StatelessWidget {
  const NumayaTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<TabItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: AppColors.canvas,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s3,
          AppSpacing.s2,
          AppSpacing.s3,
          bottom > 0 ? bottom : AppSpacing.s3,
        ),
        // heightFactor 1: the bar is as tall as its pill, never the whole slot.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.contentMax),
            child: Container(
              height: AppSizes.tabBar,
              padding: const EdgeInsets.all(AppSpacing.s1),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.all(AppRadii.pill),
                border: Border.all(
                  color: AppColors.border,
                  width: AppBorders.hairline,
                ),
                boxShadow: AppElevation.floating,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(child: _tab(context, i)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, int i) {
    final item = items[i];
    final current = i == currentIndex;
    final color = current ? AppColors.accentOnTint : AppColors.textMuted;
    return Semantics(
      selected: current,
      child: Pressable(
        onTap: () => onSelect(i),
        semanticLabel: item.badgeCount > 0
            ? (item.badgeLabel ?? item.label)
            : item.label,
        excludeChildSemantics: true,
        pressedScale: 0.96,
        child: AnimatedContainer(
          duration: AppMotion.duration(context, AppMotion.state),
          curve: AppMotion.easeOut,
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: current ? AppColors.fill : const Color(0x00ECECF0),
            borderRadius: AppRadii.all(AppRadii.pill),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  NumayaIcon(item.icon, outline: !current, color: color),
                  if (item.badgeCount > 0)
                    Positioned(
                      right: -3,
                      top: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.negative,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.weight(
                  AppTypography.micro,
                  current ? AppTypography.semibold : AppTypography.medium,
                ).copyWith(fontSize: 11, height: 13 / 11, color: color),
              ),
            ],
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
        horizontal: AppSpacing.s4,
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
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacing.s4,
                    endIndent: AppSpacing.s4,
                    color: AppColors.border,
                  ),
                children[i],
              ],
            ],
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
