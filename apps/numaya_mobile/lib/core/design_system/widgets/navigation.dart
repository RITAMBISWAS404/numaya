import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

class TabItem {
  const TabItem({required this.label, required this.icon});
  final String label;
  final NumayaIcons icon;
}

/// Floating pill tab bar (`.tab-bar`): the current tab is a sunken pill with a filled purple icon;
/// others use the outline glyph.
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s3,
        AppSpacing.s2,
        AppSpacing.s3,
        bottom + AppSpacing.s2,
      ),
      child: Container(
        height: AppSizes.tabBar,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.pill),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: AppBorders.hairline,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: AppElevation.float,
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s1),
              Expanded(child: _tab(context, i)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, int i) {
    final item = items[i];
    final current = i == currentIndex;
    return Semantics(
      selected: current,
      child: Pressable(
        onTap: () => onSelect(i),
        semanticLabel: item.label,
        excludeChildSemantics: true,
        pressedScale: 0.96,
        borderRadius: AppRadii.all(AppRadii.pill),
        child: AnimatedContainer(
          duration: AppMotion.duration(context, AppMotion.base),
          height: double.infinity,
          decoration: BoxDecoration(
            color: current ? AppColors.surfaceSunken : Colors.transparent,
            borderRadius: AppRadii.all(AppRadii.pill),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumayaIcon(
                item.icon,
                outline: !current,
                color: current ? AppColors.brand : AppColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    AppTypography.weight(
                      AppTypography.micro,
                      current ? AppTypography.semibold : AppTypography.medium,
                    ).copyWith(
                      fontSize: 11,
                      height: 13 / 11,
                      color: current
                          ? AppColors.textBrandDeep
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Switch (`.switch`): 51 × 31, purple when on, white thumb.
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
        color: value ? AppColors.controlSelected : AppColors.controlTrackOff,
        borderRadius: AppRadii.all(AppRadii.pill),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: AppMotion.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 27,
          height: 27,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: AppElevation.thumb,
          ),
        ),
      ),
    );
  }
}

/// Settings-style row: label, optional detail, and a trailing switch, value or chevron.
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
  });

  final String label;
  final String? detail;
  final String? value;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;
  final bool danger;
  final bool? showChevron;

  @override
  Widget build(BuildContext context) {
    final isSwitch = switchValue != null;
    final chevron = showChevron ?? (onTap != null && !isSwitch && !danger);
    final row = Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      AppTypography.weight(
                        AppTypography.body,
                        AppTypography.medium,
                      ).copyWith(
                        color: danger
                            ? AppColors.danger
                            : AppColors.textPrimary,
                      ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(detail!, style: AppTypography.caption),
                ],
              ],
            ),
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.s3),
              child: Text(
                value!,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textMuted,
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
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      excludeChildSemantics: true,
      pressedScale: 1,
      child: row,
    );
  }
}

/// Group of rows on a soft card (`.list-group`), with an optional heading.
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
            padding: const EdgeInsets.only(
              left: AppSpacing.s1,
              bottom: AppSpacing.s2,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title!,
                style: AppTypography.weight(
                  AppTypography.label,
                  AppTypography.semibold,
                ),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: AppRadii.all(AppRadii.lg),
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
                    color: AppColors.borderSubtle,
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
            child: Text(footnote!, style: AppTypography.caption),
          ),
      ],
    );
  }
}

/// Empty state: illustration (optional), serif title, body, optional action.
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (art != null) ExcludeSemantics(child: art!),
            const SizedBox(height: AppSpacing.s5),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.headline,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.s6),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
