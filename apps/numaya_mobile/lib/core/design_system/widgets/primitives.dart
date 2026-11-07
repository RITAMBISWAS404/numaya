import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_haptics.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../icons/numaya_icon_data.g.dart';
import '../icons/tabler_icons.dart';

/// A Tabler icon, named by the shared icon set and mapped in [kTablerIcons]: the outline by
/// default, Tabler's filled artwork when [filled] (selected and emphasised states). Decorative:
/// icon-only controls carry their own label.
class NumayaIcon extends StatelessWidget {
  const NumayaIcon(
    this.icon, {
    super.key,
    this.size = AppSizes.iconLg,
    this.color,
    this.filled = false,
  });

  final NumayaIcons icon;
  final double size;
  final Color? color;

  /// Tabler's solid artwork for a selected or emphasised state (the current tab). Names without
  /// a filled twin keep their outline ([kTablerIcons]).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color ?? AppColors.textPrimary;
    return ExcludeSemantics(
      child: TablerSvg(
        tablerAsset(kTablerIcons[icon]!, filled: filled),
        size: size,
        color: tint,
      ),
    );
  }
}

/// A mobile-only glyph ([NumayaMobileIcons]), decorative like [NumayaIcon].
class MobileIcon extends StatelessWidget {
  const MobileIcon(
    this.icon, {
    super.key,
    this.size = AppSizes.iconLg,
    this.color,
    this.filled = false,
  });

  final NumayaMobileIcons icon;
  final double size;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: TablerSvg(
      tablerAsset(kTablerMobileIcons[icon]!, filled: filled),
      size: size,
      color: color ?? IconTheme.of(context).color ?? AppColors.textPrimary,
    ),
  );
}

/// One bundled Tabler SVG in a [size] square, tinted [color] with `srcIn`: the colour replaces the
/// artwork's own ink while transparent areas (a filled glyph's holes) stay transparent. The box
/// is the icon's layout size; hit areas belong to the control around it.
///
/// Outline assets are loaded through [TablerOutlineLoader], which sets the stroke for the size
/// role ([tablerOutlineStroke], FT-03). Filled assets load as shipped.
class TablerSvg extends StatelessWidget {
  const TablerSvg(
    this.asset, {
    super.key,
    required this.size,
    required this.color,
  });

  final String asset;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: isTablerOutline(asset)
        ? SvgPicture(
            TablerOutlineLoader(asset, stroke: tablerOutlineStroke(size)),
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          )
        : SvgPicture.asset(
            asset,
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
  );
}

/// Whether [asset] is a Tabler outline file (the stroke classes apply only to these).
bool isTablerOutline(String asset) =>
    asset.startsWith('assets/icons/tabler/outline/');

/// Loads a Tabler outline asset with its root `stroke-width` set to [stroke] (24-grid units).
/// The stroke is part of the cache key, so the same glyph at two size classes caches twice.
@immutable
class TablerOutlineLoader extends SvgAssetLoader {
  const TablerOutlineLoader(super.assetName, {required this.stroke});

  /// Stroke width in the asset's 24 x 24 viewBox units.
  final double stroke;

  @override
  String provideSvg(ByteData? message) =>
      withTablerStroke(super.provideSvg(message), stroke);

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    final base = super.cacheKey(context);
    return SvgCacheKey(
      theme: base.theme,
      colorMapper: base.colorMapper,
      keyData: (base.keyData, stroke),
    );
  }

  @override
  int get hashCode => Object.hash(super.hashCode, stroke);

  @override
  bool operator ==(Object other) =>
      other is TablerOutlineLoader &&
      other.assetName == assetName &&
      other.stroke == stroke &&
      super == other;
}

/// An emoji glyph, decorative (the adjacent label carries the meaning). Falls back to the platform
/// colour-emoji font (Noto Color Emoji on Android, Apple Color Emoji on iOS).
class Emoji extends StatelessWidget {
  const Emoji(this.emoji, {super.key, this.size = 16});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Text(
      emoji,
      style: TextStyle(
        fontSize: size,
        height: 1,
        fontFamilyFallback: const ['Noto Color Emoji', 'Apple Color Emoji'],
      ),
    ),
  );
}

/// Text that wraps into lines of even length, like CSS `text-wrap: balance` (the web uses it on
/// titles). It finds the narrowest width that keeps the same number of lines.
class BalancedText extends StatelessWidget {
  const BalancedText(
    String this.text, {
    super.key,
    required this.style,
    this.textAlign,
  }) : span = null;

  /// Balanced rich text ([span]'s own styles apply on top of [style]).
  const BalancedText.rich(
    InlineSpan this.span, {
    super.key,
    required this.style,
    this.textAlign,
  }) : text = null;

  final String? text;
  final InlineSpan? span;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final content = TextSpan(text: text, style: style, children: [?span]);
    return LayoutBuilder(
      builder: (context, box) {
        if (!box.hasBoundedWidth) {
          return Text.rich(content, textAlign: textAlign);
        }
        final scaler = MediaQuery.textScalerOf(context);
        final direction = Directionality.of(context);
        int lines(double width) {
          final painter = TextPainter(
            text: content,
            textDirection: direction,
            textScaler: scaler,
          )..layout(maxWidth: width);
          final count = painter.computeLineMetrics().length;
          painter.dispose();
          return count;
        }

        final target = lines(box.maxWidth);
        var width = box.maxWidth;
        if (target > 1) {
          var lo = box.maxWidth / 2;
          var hi = box.maxWidth;
          while (hi - lo > 1) {
            final mid = (lo + hi) / 2;
            if (lines(mid) > target) {
              lo = mid;
            } else {
              hi = mid;
            }
          }
          width = hi;
        }
        return Align(
          alignment: textAlign == TextAlign.center
              ? Alignment.topCenter
              : AlignmentDirectional.topStart,
          child: SizedBox(
            width: width,
            child: Text.rich(content, textAlign: textAlign),
          ),
        );
      },
    );
  }
}

/// Tap target with the design system's press feedback (a small scale-down), keyboard activation,
/// a focus ring and button semantics. The base for every custom control.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.pressedScale = 0.98,
    this.borderRadius,
    this.selected,
    this.toggled,
    this.excludeChildSemantics = false,
    this.minSize = AppSizes.touchMin,
    this.haptic,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double pressedScale;

  /// Shape of the focus ring.
  final BorderRadius? borderRadius;
  final bool? selected;
  final bool? toggled;
  final bool excludeChildSemantics;

  /// Minimum hit area (44 by default, as the web's `--size-touch-min`).
  final double minSize;

  /// The haptic a tap commits, if any. Plain presses are silent; selection controls pass
  /// [HapticMoment.selection].
  final HapticMoment? haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  void _activate() {
    final haptic = widget.haptic;
    if (haptic != null) AppHaptics.fire(context, haptic);
    widget.onTap?.call();
  }

  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed && _enabled ? widget.pressedScale : 1.0;
    Widget child = AnimatedScale(
      scale: scale,
      duration: AppMotion.duration(context, AppMotion.fast),
      curve: AppMotion.easeOut,
      child: widget.child,
    );
    if (_focused) {
      child = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: AppColors.focusField,
            width: AppBorders.focus,
          ),
        ),
        child: child,
      );
    }
    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      excludeSemantics: widget.excludeChildSemantics,
      child: FocusableActionDetector(
        enabled: _enabled,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          onTap: _enabled ? _activate : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minSize,
              minHeight: widget.minSize,
            ),
            child: Center(widthFactor: 1, heightFactor: 1, child: child),
          ),
        ),
      ),
    );
  }
}
