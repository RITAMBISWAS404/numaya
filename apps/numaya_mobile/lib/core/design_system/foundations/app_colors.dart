import 'package:flutter/painting.dart';

import '../tokens/numaya_tokens.g.dart';

/// Semantic colours of the approved Numaya design (Meetup visual system, brand purple #7262C7).
///
/// Every value comes from the generated token file, which mirrors `tokens/numaya.tokens.json`.
/// To change a colour, edit the JSON, run `npm run tokens` and
/// `node apps/numaya_mobile/tool/generate_tokens.mjs`. Widgets read these roles, never hex values.
abstract final class AppColors {
  // Brand
  static const Color brand = NumayaColorTokens.colorBrand;
  static const Color brandHover = NumayaColorTokens.colorBrandHover;
  static const Color brandTint = NumayaColorTokens.colorBrandTint;
  static const Color brandTintStrong = NumayaColorTokens.colorBrandTintStrong;
  static const Color brandSubtle = NumayaColorTokens.colorBrandSubtle;
  static const Color onBrand = NumayaColorTokens.colorOnBrand;

  // Controls
  static const Color controlSelected = NumayaColorTokens.colorControlSelected;
  static const Color controlSelectedText =
      NumayaColorTokens.colorControlSelectedText;
  static const Color controlTrackOff = NumayaColorTokens.colorControlTrackOff;

  // Accents: marks and framing only, never text.
  static const Color accentRose = NumayaColorTokens.colorAccentRose;
  static const Color accentPromo = NumayaColorTokens.colorAccentPromo;
  static const Color accentYellow = NumayaColorTokens.colorAccentYellow;

  // Text
  static const Color textPrimary = NumayaColorTokens.colorTextPrimary;
  static const Color textSecondary = NumayaColorTokens.colorTextSecondary;
  static const Color textMuted = NumayaColorTokens.colorTextMuted;
  static const Color textSubtle = NumayaColorTokens.colorTextSubtle;
  static const Color textBrand = NumayaColorTokens.colorTextBrand;
  static const Color textBrandDeep = NumayaColorTokens.colorTextBrandDeep;
  static const Color textOnInverse = NumayaColorTokens.colorTextOnInverse;

  // Surfaces
  static const Color surface = NumayaColorTokens.colorSurface;
  static const Color surfaceSoft = NumayaColorTokens.colorSurfaceSoft;
  static const Color surfaceSunken = NumayaColorTokens.colorSurfaceSunken;
  static const Color surfacePhoto = NumayaColorTokens.colorSurfacePhoto;
  static const Color surfaceBrand = NumayaColorTokens.colorSurfaceBrand;
  static const Color surfaceInverse = NumayaColorTokens.colorSurfaceInverse;

  // Borders and focus
  static const Color borderSubtle = NumayaColorTokens.colorBorderSubtle;
  static const Color borderStrong = NumayaColorTokens.colorBorderStrong;
  static const Color borderControl = NumayaColorTokens.colorBorderControl;
  static const Color focusField = NumayaColorTokens.colorFocusField;
  static const Color focusHalo = NumayaColorTokens.colorFocusHalo;
  static const Color scrim = NumayaColorTokens.colorOverlayScrim;

  // Feedback
  static const Color danger = NumayaColorTokens.colorDanger;
  static const Color dangerTint = NumayaColorTokens.colorDangerTint;
  static const Color success = NumayaColorTokens.colorSuccess;
  static const Color successTint = NumayaColorTokens.colorSuccessTint;
  static const Color warning = NumayaColorTokens.colorWarning;
  static const Color warningTint = NumayaColorTokens.colorWarningTint;
}
