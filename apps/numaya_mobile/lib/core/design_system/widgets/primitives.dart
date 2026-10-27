import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../icons/numaya_icon_data.g.dart';

/// A Material Symbol from the shared icon set, filled by default (outline where the unfilled
/// drawing carries a different state). Decorative: icon-only controls carry their own label.
class NumayaIcon extends StatelessWidget {
  const NumayaIcon(
    this.icon, {
    super.key,
    this.size = AppSizes.iconLg,
    this.color,
    this.outline = false,
  });

  final NumayaIcons icon;
  final double size;
  final Color? color;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final (filled, open) = icon.paths;
    final tint = color ?? IconTheme.of(context).color ?? AppColors.textPrimary;
    return ExcludeSemantics(
      child: SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -960 960 960">'
        '<path d="${outline ? open : filled}"/></svg>',
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      ),
    );
  }
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
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (!box.hasBoundedWidth) {
          return Text(text, style: style, textAlign: textAlign);
        }
        final scaler = MediaQuery.textScalerOf(context);
        final direction = Directionality.of(context);
        int lines(double width) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
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
            child: Text(text, style: style, textAlign: textAlign),
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

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

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
              widget.onTap?.call();
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
          onTap: widget.onTap,
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
