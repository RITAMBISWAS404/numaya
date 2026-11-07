import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import 'primitives.dart';

/// Ente Tabs (`7497:3078`): a pill track with a white thumb under the selected label, 2 or 3
/// options, 48pt tall (Ente 49). Used for top-level switches inside one tab (Likes / Compliments)
/// and for periods (7 / 28 / 90 days).
///
/// Motion (MOT02): the thumb slides over [AppMotion.state] on the decelerating curve; under reduced
/// motion it jumps. Labels never animate, so nothing relayouts. Activation is immediate on tap
/// (the callback does not wait for the slide). Each option is a selected/unselected tab for screen
/// readers, with its count spoken.
class NumayaSegmented extends StatelessWidget {
  const NumayaSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.label,
  });

  final List<({String label, int? count, Key? key})> options;

  /// The selected option, or -1 for none yet.
  final int selected;
  final ValueChanged<int> onSelect;

  /// Spoken name of the whole control.
  final String? label;

  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    final n = options.length;
    return Semantics(
      label: label,
      container: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: height),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.fill,
          borderRadius: AppRadii.all(AppRadii.pill),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth / n;
            return Stack(
              children: [
                // -1: nothing selected yet, no thumb.
                if (selected >= 0)
                  AnimatedPositionedDirectional(
                    duration: AppMotion.duration(context, AppMotion.state),
                    curve: AppMotion.easeOut,
                    start: w * selected,
                    top: 0,
                    bottom: 0,
                    width: w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.all(AppRadii.pill),
                        boxShadow: AppElevation.subtle,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    for (var i = 0; i < n; i++)
                      Expanded(
                        child: _Option(
                          key: options[i].key,
                          text: options[i].label,
                          count: options[i].count,
                          selected: i == selected,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    super.key,
    required this.text,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.weight(
      AppTypography.body,
      selected ? AppTypography.semibold : AppTypography.medium,
    ).copyWith(color: selected ? AppColors.ink : AppColors.textSecondary);
    return Semantics(
      selected: selected,
      button: true,
      inMutuallyExclusiveGroup: true,
      label: count == null ? text : '$text, $count',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        pressedScale: 1,
        borderRadius: AppRadii.all(AppRadii.pill),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: NumayaSegmented.height - 6,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s2,
            vertical: AppSpacing.s2,
          ),
          alignment: Alignment.center,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: text),
                if (count != null && count! > 0)
                  TextSpan(
                    text: '  $count',
                    style: style.copyWith(
                      color: selected ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      ),
    );
  }
}
