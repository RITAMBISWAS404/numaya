import 'package:flutter/painting.dart';

import '../tokens/numaya_tokens.g.dart';
import 'app_colors.dart';

/// Type roles of the approved design: Fraunces (display, variable axes SOFT 50, WONK 0) for
/// headings and Inter for everything else. Sizes, line heights, weights and tracking come from the
/// generated tokens; tracking is stored in em and converted here.
abstract final class AppTypography {
  static const String displayFamily = 'Fraunces';
  static const String textFamily = 'Inter';

  // Display (Fraunces)
  static final TextStyle hero = _display(
    NumayaSizeTokens.typeHeroSize,
    NumayaSizeTokens.typeHeroLine,
    NumayaSizeTokens.typeHeroTracking,
    NumayaWeightTokens.typeHeroWeight,
  );
  static final TextStyle display = _display(
    NumayaSizeTokens.typeDisplaySize,
    NumayaSizeTokens.typeDisplayLine,
    NumayaSizeTokens.typeDisplayTracking,
    NumayaWeightTokens.typeDisplayWeight,
  );
  static final TextStyle headline = _display(
    NumayaSizeTokens.typeHeadlineSize,
    NumayaSizeTokens.typeHeadlineLine,
    NumayaSizeTokens.typeHeadlineTracking,
    NumayaWeightTokens.typeHeadlineWeight,
  );
  static final TextStyle titleSm = _display(
    NumayaSizeTokens.typeTitleSmSize,
    NumayaSizeTokens.typeTitleSmLine,
    NumayaSizeTokens.typeTitleSmTracking,
    NumayaWeightTokens.typeTitleSmWeight,
  );
  static final TextStyle title = _display(
    NumayaSizeTokens.typeTitleSize,
    NumayaSizeTokens.typeTitleLine,
    NumayaSizeTokens.typeTitleTracking,
    NumayaWeightTokens.typeTitleWeight,
  );

  /// Welcome headline: `clamp(36px, 10.4vw, 42px)`, line 1.04, -0.03em.
  static TextStyle welcomeTitle(double screenWidth) {
    final size = (screenWidth * 0.104).clamp(36.0, 42.0);
    return _display(
      size,
      size * 1.04,
      -0.03,
      NumayaWeightTokens.typeDisplayWeight,
    );
  }

  /// The "numaya" wordmark text: 27 (21 small), weight 540, -0.03em, line 1.
  static TextStyle wordmark({bool small = false}) {
    final size = small ? 21.0 : 27.0;
    return _display(size, size, -0.03, 540);
  }

  // Text (Inter)
  static final TextStyle body = _text(
    NumayaSizeTokens.typeBodySize,
    NumayaSizeTokens.typeBodyLine,
    NumayaSizeTokens.typeBodyTracking,
    NumayaWeightTokens.typeBodyWeight,
  );
  static final TextStyle bodySm = _text(
    NumayaSizeTokens.typeBodySmSize,
    NumayaSizeTokens.typeBodySmLine,
    NumayaSizeTokens.typeBodySmTracking,
    NumayaWeightTokens.typeBodySmWeight,
  );
  static final TextStyle input = _text(
    NumayaSizeTokens.typeInputSize,
    NumayaSizeTokens.typeInputLine,
    NumayaSizeTokens.typeInputTracking,
    NumayaWeightTokens.typeInputWeight,
  );
  static final TextStyle button = _text(
    NumayaSizeTokens.typeButtonSize,
    NumayaSizeTokens.typeButtonLine,
    NumayaSizeTokens.typeButtonTracking,
    NumayaWeightTokens.typeButtonWeight,
  );
  static final TextStyle label = _text(
    NumayaSizeTokens.typeLabelSize,
    NumayaSizeTokens.typeLabelLine,
    NumayaSizeTokens.typeLabelTracking,
    NumayaWeightTokens.typeLabelWeight,
  ).copyWith(color: AppColors.textSecondary);
  static final TextStyle caption = _text(
    NumayaSizeTokens.typeCaptionSize,
    NumayaSizeTokens.typeCaptionLine,
    NumayaSizeTokens.typeCaptionTracking,
    NumayaWeightTokens.typeCaptionWeight,
  ).copyWith(color: AppColors.textMuted);
  static final TextStyle micro = _text(
    NumayaSizeTokens.typeMicroSize,
    NumayaSizeTokens.typeMicroLine,
    NumayaSizeTokens.typeMicroTracking,
    NumayaWeightTokens.typeMicroWeight,
  ).copyWith(color: AppColors.textMuted);
  static final TextStyle eyebrow = _text(
    NumayaSizeTokens.typeEyebrowSize,
    NumayaSizeTokens.typeEyebrowLine,
    NumayaSizeTokens.typeEyebrowTracking,
    NumayaWeightTokens.typeEyebrowWeight,
  ).copyWith(color: AppColors.textBrandDeep);

  /// Returns [style] at a different variable-font weight (keeps every other axis).
  static TextStyle weight(TextStyle style, double weight) {
    final axes = [
      for (final v in style.fontVariations ?? const <FontVariation>[])
        if (v.axis != 'wght') v,
      FontVariation('wght', weight),
    ];
    return style.copyWith(fontWeight: _nearest(weight), fontVariations: axes);
  }

  static const double semibold = 600;
  static const double medium = 500;
  static const double bold = 680;

  static TextStyle _display(double size, double line, double em, double w) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: size,
      height: line / size,
      letterSpacing: em * size,
      fontWeight: _nearest(w),
      color: AppColors.textPrimary,
      leadingDistribution: TextLeadingDistribution.even,
      fontVariations: [
        FontVariation('wght', w),
        // Browsers apply the optical-size axis automatically (font-optical-sizing: auto).
        FontVariation('opsz', size.clamp(9.0, 144.0)),
        for (final (tag, value) in NumayaFontTokens.displayAxes)
          FontVariation(tag, value),
      ],
    );
  }

  static TextStyle _text(double size, double line, double em, double w) {
    return TextStyle(
      fontFamily: textFamily,
      fontSize: size,
      height: line / size,
      letterSpacing: em * size,
      fontWeight: _nearest(w),
      color: AppColors.textPrimary,
      leadingDistribution: TextLeadingDistribution.even,
      fontVariations: [FontVariation('wght', w)],
    );
  }

  static FontWeight _nearest(double w) {
    final index = ((w / 100).round() - 1).clamp(0, 8);
    return FontWeight.values[index];
  }
}
