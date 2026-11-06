import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import 'slider_thumbs.dart';

/// Horizontal inset at each end of every slider track (UI-024): half the thumb, so a thumb at
/// either end sits flush with its container's content edge and the track uses the rest of the
/// width. Flutter's default reserved the 24pt press halo on top of the card's own padding.
const double kSliderInset = AppSizes.sliderThumb / 2;

/// The app's slider styling, for every slider: brand track, V16 white thumbs, the full content
/// width (UI-024) and a small value pop-up above the thumb being moved (UI-005). The pop-up is
/// Flutter's own value indicator, painted in the overlay, so a surrounding card never clips it.
/// The 9pt vertical padding keeps the slider 44pt tall, the minimum touch height.
SliderThemeData numayaSliderTheme(BuildContext context) =>
    SliderTheme.of(context).copyWith(
      padding: const EdgeInsets.symmetric(
        horizontal: kSliderInset,
        vertical: (AppSizes.touchMin - AppSizes.sliderThumb) / 2,
      ),
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.fill,
      thumbColor: AppColors.surface,
      overlayColor: AppColors.focusHalo,
      trackHeight: 4,
      rangeThumbShape: const V16RangeThumb(),
      thumbShape: const V16SliderThumb(),
      disabledActiveTrackColor: AppColors.borderStrong,
      disabledInactiveTrackColor: AppColors.fill,
      disabledThumbColor: AppColors.fill,
      // Shown only while a thumb is pressed or dragged.
      showValueIndicator: ShowValueIndicator.onDrag,
      // UI-005: Ente's Tooltip with a bottom pointer (A-024): white, dark text, soft shadow.
      valueIndicatorColor: AppColors.surface,
      valueIndicatorTextStyle: AppTypography.weight(
        AppTypography.bodySm,
        AppTypography.semibold,
      ).copyWith(color: AppColors.ink),
      rangeValueIndicatorShape: const _ActiveThumbIndicator(),
      rangeTrackShape: const _FullWidthRangeTrack(),
    );

/// RangeSlider's rounded track without its own overlay inset: the theme's [kSliderInset] padding
/// already reserves the thumb's room, and the default shape added the 24pt press halo again on
/// each side (found on the emulator: the age track stopped well short of the card edges while the
/// single sliders reached them).
class _FullWidthRangeTrack extends RoundedRectRangeSliderTrackShape {
  const _FullWidthRangeTrack();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final height = sliderTheme.trackHeight ?? 4;
    final top = offset.dy + (parentBox.size.height - height) / 2;
    return Rect.fromLTWH(offset.dx, top, parentBox.size.width, height);
  }
}

/// The value pop-up above the active thumb (UI-005): Ente's Tooltip variant with a bottom
/// pointer (A-024) in place of Flutter's black paddle. A white rounded rectangle with a small
/// downward pointer whose tip sits just above the thumb, the value in dark semibold text and a
/// soft shadow so it reads on white cards and grey sheets. It is drawn only for a thumb that has a
/// label: [AgeRangeSlider] labels the active thumb and leaves the other empty. It scales in with
/// the press and keeps inside the slider's width.
class _ActiveThumbIndicator extends RangeSliderValueIndicatorShape {
  const _ActiveThumbIndicator();

  static const double _padX = 12;
  static const double _padY = 6;
  static const double _radius = 10;
  static const double _pointer = 6;
  static const double _gap = 6;

  @override
  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete, {
    required TextPainter labelPainter,
    required double textScaleFactor,
  }) => Size(
    labelPainter.width + _padX * 2,
    labelPainter.height + _padY * 2 + _pointer,
  );

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    bool? isOnTop,
    required TextPainter labelPainter,
    double? textScaleFactor,
    Size? sizeWithOverflow,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    double? value,
    Thumb? thumb,
  }) {
    if ((labelPainter.text?.toPlainText() ?? '').isEmpty) return;
    final t = activationAnimation.value;
    if (t == 0) return;
    final canvas = context.canvas;
    final tip = Offset(center.dx, center.dy - AppSizes.sliderThumb / 2 - _gap);
    final w = labelPainter.width + _padX * 2;
    final h = labelPainter.height + _padY * 2;
    // Keep the body inside the slider; the pointer stays on the thumb.
    final origin = parentBox.localToGlobal(Offset.zero);
    final left = (tip.dx - w / 2).clamp(
      origin.dx,
      origin.dx + parentBox.size.width - w,
    );
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, tip.dy - _pointer - h, w, h),
      const Radius.circular(_radius),
    );
    final path = Path()
      ..addRRect(body)
      ..moveTo(tip.dx - _pointer, body.bottom)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + _pointer, body.bottom)
      ..close();
    canvas
      ..save()
      ..translate(tip.dx, tip.dy)
      ..scale(t)
      ..translate(-tip.dx, -tip.dy);
    canvas.drawShadow(path, const Color(0x40000000), 4, false);
    canvas.drawPath(
      path,
      Paint()..color = sliderTheme.valueIndicatorColor ?? AppColors.surface,
    );
    labelPainter.paint(canvas, Offset(body.left + _padX, body.top + _padY));
    canvas.restore();
  }
}

/// Shared age-range slider (UI-004/UI-005): two thumbs over whole ages. While a thumb is pressed
/// or dragged, a pop-up above that thumb shows its exact age; the other thumb shows none. The
/// active thumb is the one nearer the press, then whichever end changes. Value rules (the bounds,
/// and any minimum gap the caller enforces in [onChanged]) are unchanged.
class AgeRangeSlider extends StatefulWidget {
  const AgeRangeSlider({
    super.key,
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final RangeValues values;
  final int min;
  final int max;
  final ValueChanged<RangeValues>? onChanged;

  @override
  State<AgeRangeSlider> createState() => _AgeRangeSliderState();
}

class _AgeRangeSliderState extends State<AgeRangeSlider> {
  /// The thumb being adjusted, if any.
  Thumb? _active;

  /// The track inset at each end ([kSliderInset]).
  static const double _inset = kSliderInset;

  void _pressAt(double dx, double width) {
    final span = (width - 2 * _inset).clamp(1.0, double.infinity);
    double x(double v) =>
        _inset + span * (v - widget.min) / (widget.max - widget.min);
    final toStart = (dx - x(widget.values.start)).abs();
    final toEnd = (dx - x(widget.values.end)).abs();
    setState(() => _active = toStart <= toEnd ? Thumb.start : Thumb.end);
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.values;
    return LayoutBuilder(
      builder: (context, box) => Listener(
        onPointerDown: (e) => _pressAt(e.localPosition.dx, box.maxWidth),
        child: SliderTheme(
          data: numayaSliderTheme(context),
          child: RangeSlider(
            values: v,
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: widget.max - widget.min,
            labels: RangeLabels(
              _active == Thumb.start ? '${v.start.round()}' : '',
              _active == Thumb.end ? '${v.end.round()}' : '',
            ),
            semanticFormatterCallback: (value) => '${value.round()}',
            onChanged: widget.onChanged == null
                ? null
                : (next) {
                    // Whichever end moved is the active one.
                    if (next.start != v.start) {
                      _active = Thumb.start;
                    } else if (next.end != v.end) {
                      _active = Thumb.end;
                    }
                    widget.onChanged!(next);
                  },
            onChangeEnd: (_) => setState(() => _active = null),
          ),
        ),
      ),
    );
  }
}
