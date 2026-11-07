import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_haptics.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import '../tokens/monochrome_tokens.dart';
import 'content.dart' show MetaText;
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

  /// Ente Nav Bar (7634:54194): an opaque white bar with 20pt corners and Ente's soft drop shadow,
  /// floating over content (no glass, no page strip), 38pt icon tiles with 12pt corners. The
  /// shipped surface on the Ente experiment.
  ente,
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
    this.surface = TabBarSurface.ente,
  });

  /// Space between the pill's edge and each item.
  static const double tabInset = 6;

  /// Marks the visible bar (any surface), so layouts and tests can find its bounds.
  static const Key pillKey = ValueKey('numaya-tab-bar-pill');

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
    final ente = surface == TabBarSurface.ente;
    if (ente) return _compact(context, bottom);
    return _frame(
      frosted: frosted || ente,
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
            // The Ente bar insets its row 12 each side; the other pills 6.
            final inner = ente ? 2 * (15.0 - 3) : 2 * tabInset;
            var gap = ente ? AppSpacing.s6 : AppSpacing.s2;
            var item = AppSizes.tabItem;
            // Each item lays out at least its 44pt hit area (Pressable.minSize), even when the
            // visible Ente tile is 38.
            double need() =>
                inner +
                n * (item > AppSizes.touchMin ? item : AppSizes.touchMin) +
                extra +
                (n - 1) * gap;
            if (ente && need() > box.maxWidth) gap = AppSpacing.s4;
            if (ente && need() > box.maxWidth) gap = AppSpacing.s2;
            if (need() > box.maxWidth) gap = AppSpacing.s1;
            if (need() > box.maxWidth) {
              item = ((box.maxWidth - inner - extra - (n - 1) * gap) / n).clamp(
                AppSizes.tabItem,
                AppSizes.tabItem,
              );
            }
            final row = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < n; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  _tab(context, i, item, frosted: frosted, ente: ente),
                ],
              ],
            );
            if (ente) {
              // Ente's bar insets its tiles 15pt from the ends; the 44pt hit areas centre in it.
              return Center(
                heightFactor: 1,
                child: Container(
                  key: pillKey,
                  height: AppSizes.tabBar,
                  padding: const EdgeInsets.symmetric(horizontal: 15 - 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.all(AppRadii.control),
                    boxShadow: AppElevation.floating,
                  ),
                  child: row,
                ),
              );
            }
            if (!frosted) {
              return Center(
                heightFactor: 1,
                child: Container(
                  height: AppSizes.tabBar,
                  padding: EdgeInsets.all(inner / 2),
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
                  child: Stack(
                    children: [
                      Container(
                        height: AppSizes.tabBar,
                        padding: EdgeInsets.all(inner / 2),
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
                      const Positioned(
                        top: 1,
                        left: MonoGlass.highlightInset,
                        right: MonoGlass.highlightInset,
                        height: 1,
                        child: IgnorePointer(
                          child: ColoredBox(color: MonoGlass.highlight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// The shipped bar (UC-03, UI consistency pass): a white stadium with Ente's soft shadow,
  /// sized by its items. [AppSizes.tabPadding] (8) on all four sides inside the bar, then four
  /// equal item surfaces edge to edge, each its own tap target ([AppSizes.tabItem] = 48 tall,
  /// [AppSizes.tabItemMin]..[AppSizes.tabItemWidth] wide, so never under 48 x 48 and never
  /// overlapping a neighbour). Inside each item the selected destination's stadium pill sits
  /// [AppSizes.tabItemInset] (4) in on all four sides. The bar's screen margin and the system
  /// inset are applied outside it, once.
  ///
  /// On a narrow screen the items narrow (to 68 at 320pt); the touch targets never shrink below
  /// 48.
  Widget _compact(BuildContext context, double bottom) {
    return _frame(
      frosted: true,
      systemInset: bottom,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s4,
          AppSpacing.s2,
          AppSpacing.s4,
          bottom > 0 ? bottom : AppSpacing.s4,
        ),
        child: Center(
          heightFactor: 1,
          child: LayoutBuilder(
            builder: (context, box) {
              final n = items.length;
              final room = box.maxWidth - 2 * AppSizes.tabPadding;
              final width = n == 0
                  ? AppSizes.tabItemWidth
                  : (room / n).clamp(
                      AppSizes.tabItemMin,
                      AppSizes.tabItemWidth,
                    );
              return Container(
                key: pillKey,
                padding: const EdgeInsets.all(AppSizes.tabPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.all(AppRadii.pill),
                  boxShadow: AppElevation.navigation,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < n; i++)
                      _compactTab(context, i, width.toDouble()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _compactTab(BuildContext context, int i, double width) {
    final item = items[i];
    final current = i == currentIndex;
    final duration = AppMotion.duration(context, AppMotion.state);
    // Tabler MVP pass, kept: the selected destination is Tabler's filled glyph in near-black on a
    // very light neutral pill; the others are outline glyphs in a light grey (3.46:1 on white).
    // The state is carried by shape (filled vs outline, pill vs none) as well as colour, and
    // announced as selected.
    final fg = current ? AppColors.iconSelected : AppColors.iconInactive;
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
          pressedScale: 0.95,
          borderRadius: AppRadii.all(AppRadii.pill),
          child: SizedBox(
            key: ValueKey('tab-item-$i'),
            width: width,
            height: AppSizes.tabItem,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.tabItemInset),
              child: AnimatedContainer(
                key: ValueKey('tab-tile-$i'),
                duration: duration,
                curve: AppMotion.easeOut,
                decoration: BoxDecoration(
                  color: current
                      ? AppColors.iconSelectedFill
                      : const Color(0x00FFFFFF),
                  borderRadius: AppRadii.all(AppRadii.pill),
                ),
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    NumayaIcon(
                      item.icon,
                      filled: current,
                      size: AppSizes.iconMd,
                      color: fg,
                    ),
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
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
    bool ente = false,
  }) {
    final item = items[i];
    final current = i == currentIndex;
    final duration = AppMotion.duration(context, AppMotion.state);
    // On glass, unselected icons take the stronger secondary ink: the muted grey drops to 3.38:1
    // over a dark photo, text2 stays at 5.46:1 or better.
    final idle = frosted || ente ? AppColors.iconStrong : AppColors.textMuted;
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
    final radius = ente
        ? AppRadii.iconButton
        : indicator == TabIndicatorStyle.tint
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
          // Subtle press feedback (0.95-0.98 range); 0.92 squashed the 26pt icon (FD-B3).
          pressedScale: 0.95,
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
                NumayaIcon(
                  item.icon,
                  filled: current,
                  size: ente ? AppSizes.iconMd : 26,
                  color: fg,
                ),
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

/// Ente Toggle Switch (2482:6644) at 1.5x its 31 x 18 drawing (46 x 27, a Numaya extension so the
/// knob reads on a phone). On: Numaya purple (Ente's primary) with a white knob. Off (UI-025): a
/// solid grey track with a white knob and no outline, as Ente's Selected=False (2482:6647).
class NumayaSwitch extends StatelessWidget {
  const NumayaSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Component cleanup (CL-01). States, resolved here so every switch matches:
  /// - **on:** brand track, white thumb with a soft shadow;
  /// - **off** (UC-01, 2026-11-07): Ente's solid grey track (`switchOff`, 3:1 on white and on the
  ///   grey page) with a plain white knob and no outline on either;
  /// - **disabled** (`onChanged == null`): the same shape at 45% opacity;
  /// - **pressed and focused:** owned by the row around the switch (`ListRow`/`Pressable`
  ///   press scale and focus ring), so the whole row is the hit area.
  /// State is also carried by thumb position and by the row's `toggled` semantics, not by
  /// colour alone.
  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.duration(context, AppMotion.base);
    final track = AnimatedContainer(
      duration: duration,
      width: AppSizes.switchWidth,
      height: AppSizes.switchHeight,
      // 1pt of padding plus the 1pt edge (which Container adds to its padding) keeps the knob
      // 2pt in from the track, as before.
      padding: const EdgeInsets.all(2 - AppBorders.hairline),
      decoration: BoxDecoration(
        // FT-04: off is Ente's light fill track (2482:6644, "fill/dark") with a 1pt control-grey
        // edge drawn inside it, so the boundary keeps 3:1 on white cards and the grey page. On
        // keeps the brand track with no edge.
        color: value ? AppColors.accent : AppColors.switchOff,
        borderRadius: AppRadii.all(AppRadii.pill),
        border: Border.all(
          color: value ? AppColors.accent : AppColors.switchOffEdge,
          width: AppBorders.hairline,
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
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: AppElevation.thumb,
          ),
        ),
      ),
    );
    return onChanged == null ? Opacity(opacity: 0.45, child: track) : track;
  }
}

/// Grouped row (Ente Menu Item 4055:18734): 60pt minimum, a 14/20 medium label ([AppTypography.row]),
/// a Mini 12/16 secondary detail, and a trailing switch, value or chevron. A [leading] icon is a
/// plain 20pt glyph in a 36pt slot, secondary grey (red on destructive rows).
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

  /// Kept for API compatibility: rows no longer colour their icon (CL-02). Tiles elsewhere
  /// (Profile's grid) still use [AccentTone].
  final AccentTone tone;

  /// Kept for API compatibility: every row icon is now drawn bare (CL-02).
  final bool inlineIcon;

  /// Where the label starts, measured from the row's leading padding: dividers in a [ListGroup]
  /// start here so they never cross the icon.
  double get textInset => avatar != null
      ? (avatar is InitialsAvatar ? (avatar! as InitialsAvatar).size : 0) +
            AppLayout.tileLabelGap
      : leading == null
      ? 0
      : AppSizes.iconTile + AppLayout.tileLabelGap;

  /// A person's avatar in place of [leading] (people lists).
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final flush =
        context.dependOnInheritedWidgetOfExactType<_FlushRows>() != null;
    final row = Container(
      constraints: const BoxConstraints(minHeight: AppSizes.row),
      padding: EdgeInsets.symmetric(
        // UI-044: one inset for the list-card family: 16pt across (the card padding, as option
        // rows and fields use) and 12pt down, inside its own white card. Flush rows sit inside a
        // card that already pads them.
        horizontal: flush ? 0 : AppLayout.cardPadding,
        vertical: AppSpacing.s3,
      ),
      // The value may take 60% of what the row has left after its leading tile or avatar.
      child: LayoutBuilder(
        builder: (context, box) {
          final room = (box.maxWidth - textInset).clamp(0.0, box.maxWidth);
          // A row with a detail line and a long value (an email address) stacks the value under
          // the label: beside it, the value took 60% and squeezed the label and detail into a
          // narrow column ("Recovery / email"). Short values stay trailing.
          var stack = false;
          if (value != null) {
            double widthOf(String text) {
              final painter = TextPainter(
                text: TextSpan(text: text, style: AppTypography.row),
                textScaler: MediaQuery.textScalerOf(context),
                textDirection: Directionality.of(context),
                maxLines: 1,
              )..layout();
              final w = painter.width;
              painter.dispose();
              return w;
            }

            final valueWidth = widthOf(value!);
            if (detail != null && detail!.isNotEmpty) {
              stack = valueWidth > room * 0.4;
            }
            // V4-02: at large text a trailing value could squeeze the label until a word broke
            // inside itself ("Phone numb / er"). When the label's longest word can't fit beside
            // the value (and the chevron), the value moves under the label instead.
            if (!stack) {
              final longestWord = label
                  .split(RegExp(r'\s+'))
                  .map(widthOf)
                  .fold<double>(0, (a, b) => a > b ? a : b);
              final beside =
                  room -
                  (valueWidth < room * 0.6 ? valueWidth : room * 0.6) -
                  AppSpacing.s3 -
                  AppSpacing.s2 -
                  AppSizes.iconLg;
              stack = longestWord > beside;
            }
          }
          return _content(room * 0.6, stackValue: stack);
        },
      ),
    );
    return _wrap(row);
  }

  Widget _content(double valueMax, {bool stackValue = false}) {
    final isSwitch = switchValue != null;
    final chevron = showChevron ?? (onTap != null && !isSwitch && !danger);
    return Row(
      children: [
        if (avatar != null) ...[
          avatar!,
          const SizedBox(width: AppLayout.tileLabelGap),
        ] else if (leading != null) ...[
          // Ente Menu Item Icon (4055:5652): a 36pt slot, the glyph alone in text/light (no tile
          // background), red on a destructive row.
          SizedBox.square(
            dimension: AppSizes.iconTile,
            child: Center(
              child: NumayaIcon(
                leading!,
                size: AppSizes.iconMd,
                color: danger ? AppColors.negative : AppColors.textMuted,
              ),
            ),
          ),
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
              if (stackValue) ...[
                const SizedBox(height: 2),
                Text(
                  value!,
                  style: AppTypography.row.copyWith(color: AppColors.textMuted),
                ),
              ],
              if (detail != null && detail!.isNotEmpty) ...[
                const SizedBox(height: 2),
                MetaText(
                  detail!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        // A value is a preview of what the row opens (the whole answer is one tap away): its
        // natural width up to 60% of the row and two lines; the label keeps the rest.
        if (value != null && !stackValue)
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
              size: AppSizes.iconLg,
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
        if (detail != null && detail!.isNotEmpty)
          detail!.replaceAll(MetaText.joiner, ', '),
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
    this.flush,
  });

  final String? title;
  final List<Widget> children;
  final String? footnote;

  /// BM-02: rows on the surface's own colour, aligned to the content gutter, for a group that sits
  /// on a white sheet. A white card on a white sheet draws nothing but still indents its rows, so
  /// their labels started 20pt inside the headings above them.
  /// Defaults to false everywhere, sheets included (UI-023).
  final bool? flush;

  /// Hairlines between rows. Off for groups whose rows are self-contained (cards, previews).
  final bool dividers;

  static double _inset(Widget row, bool flush) =>
      (flush ? 0 : AppLayout.cardPadding) +
      (row is ListRow ? row.textInset : 0);

  @override
  Widget build(BuildContext context) {
    // UI-023: sheets are the grey page surface now, so groups default to white cards there too.
    final flush = this.flush ?? false;
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
        // OV-02: related rows share one white 20pt card with no hairlines, as Ente's newer
        // Settings composition (Updated screens, 12099:96480) groups them; a one-row group is the
        // single-row card of its Account screen. (The older menu item list, 5906:38912, gave
        // every row its own card; on long menus that read as a tower of separate buttons.)
        // Selectable option lists keep their separate cards (UI-003, OptionGroup).
        // On a white surface ([flush]) the rows sit on it, divided by hairlines.
        if (!flush)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.all(AppRadii.card),
            ),
            child: ClipRRect(
              borderRadius: AppRadii.all(AppRadii.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0 && dividers)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: _inset(children[i], flush),
                    ),
                    child: const ExcludeSemantics(
                      child: SizedBox(
                        height: AppBorders.hairline,
                        width: double.infinity,
                        child: ColoredBox(color: AppColors.divider),
                      ),
                    ),
                  ),
                _FlushRows(child: children[i]),
              ],
            ],
          ),
        if (footnote != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s1,
              AppSpacing.s2,
              AppSpacing.s1,
              0,
            ),
            // UI-045 / FT-01: helper copy under a list card is a whole sentence: Body 14 in the
            // secondary grey.
            child: Text(footnote!, style: AppTypography.helper),
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
    // V3-D02: at large text the 24pt side insets left too little room, and the title broke
    // inside a word ("Connection s") at 320pt and 200%. The insets narrow to 16pt there.
    final side = MediaQuery.textScalerOf(context).scale(14) > 21
        ? AppSpacing.s4
        : AppSpacing.s6;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.s4),
      padding: EdgeInsets.fromLTRB(side, AppSpacing.s8, side, AppSpacing.s8),
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

/// Marks rows of a flush [ListGroup], so [ListRow] drops its horizontal card padding.
class _FlushRows extends InheritedWidget {
  const _FlushRows({required super.child});

  @override
  bool updateShouldNotify(_FlushRows oldWidget) => false;
}
