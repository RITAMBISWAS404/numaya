import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';

/// V16 slider thumb (`.theme-withings .slider__track input::-webkit-slider-thumb`): a round 26pt
/// white thumb with the soft thumb shadow, no outline.
class V16SliderThumb extends SliderComponentShape {
  const V16SliderThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.square(AppSizes.sliderThumb);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) => paintV16Thumb(context.canvas, center);
}

/// The same thumb for range sliders.
class V16RangeThumb extends RangeSliderThumbShape {
  const V16RangeThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.square(AppSizes.sliderThumb);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) => paintV16Thumb(context.canvas, center);
}

void paintV16Thumb(Canvas canvas, Offset center) {
  const radius = AppSizes.sliderThumb / 2;
  for (final shadow in AppElevation.thumb) {
    canvas.drawCircle(
      center + shadow.offset,
      radius + shadow.spreadRadius,
      shadow.toPaint(),
    );
  }
  canvas.drawCircle(center, radius, Paint()..color = AppColors.surface);
}
