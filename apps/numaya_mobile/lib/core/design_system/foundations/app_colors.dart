import 'package:flutter/painting.dart';

import '../tokens/numaya_tokens.g.dart';

typedef _T = NumayaColorTokens;

/// Colours of Numaya V16, the Withings Health Mate reconstruction.
///
/// The roles are re-pointed exactly as the web does it in the "Roles" block of
/// `src/design-system/styles/theme-withings.css`: a warm stone page, white cards, near-black ink for
/// text, primary actions and selected controls, Withings blue for accents and its light tint for
/// selection, green switches, red for destruction. Values come from the generated tokens
/// (`tokens/numaya.tokens.json` → `color.withings.*`); to change one, edit the JSON and regenerate.
abstract final class AppColors {
  // V16 palette -----------------------------------------------------------------------------
  /// The page behind every screen (`--color-withings-canvas`, #F5F4F1).
  static const Color canvas = _T.colorWithingsCanvas;

  /// Cards, grouped rows, fields, sheets, modal headers, tab bar.
  static const Color surface = _T.colorWithingsSurface;

  /// Segmented track, switch-off track, chips on white cards, slider rail, disabled fields.
  static const Color fill = _T.colorWithingsFill;

  /// Dividers, header and tab-bar edges, outlined info boxes, search field.
  static const Color border = _T.colorWithingsBorder;

  /// Dashed empty photo slots, sheet grabber.
  static const Color borderStrong = _T.colorWithingsBorderStrong;

  /// Photo placeholders.
  static const Color photo = _T.colorWithingsPhoto;

  /// Text-field outline (5.25:1 on white).
  static const Color outline = _T.colorWithingsOutline;

  /// Unselected radio and checkbox rings.
  static const Color control = _T.colorWithingsControl;

  /// Text, headings, primary buttons, selected radios, the active tab.
  static const Color ink = _T.colorWithingsInk;
  static const Color inkForeground = _T.colorWithingsInkForeground;

  static const Color disabled = _T.colorWithingsDisabled;
  static const Color disabledForeground = _T.colorWithingsDisabledForeground;

  /// Withings blue: checked boxes, slider interval, links' hue, focus, the mark.
  static const Color accent = _T.colorWithingsAccent;
  static const Color accentHover = _T.colorWithingsAccentHover;
  static const Color accentForeground = _T.colorWithingsAccentForeground;

  /// Selected chips and tabs, toast, tint buttons, prompt-mark holder.
  static const Color accentTint = _T.colorWithingsAccentTint;

  /// Text and icons on the tint; links.
  static const Color accentOnTint = _T.colorWithingsAccentOnTint;

  /// Initials avatars (navy).
  static const Color identity = _T.colorWithingsIdentity;

  /// Switch on.
  static const Color positive = _T.colorWithingsPositive;

  /// Destructive buttons, notification dots, errors.
  static const Color negative = _T.colorWithingsNegative;

  /// Round holders behind interest-set emoji only, never text.
  static const Color markYellow = _T.colorWithingsMarkYellow;
  static const Color markLavender = _T.colorWithingsMarkLavender;
  static const Color markPink = _T.colorWithingsMarkPink;

  // Shared roles, re-pointed as theme-withings.css does ---------------------------------------
  static const Color surfacePage = canvas;
  static const Color surfaceSoft = fill;
  static const Color surfaceSunken = photo;
  static const Color surfacePhoto = photo;
  static const Color surfaceBrand = accentTint;
  static const Color surfaceInverse = ink;

  static const Color textPrimary = ink;
  static const Color textSecondary = _T.colorWithingsTextSecondary;
  static const Color textMuted = _T.colorWithingsTextMuted;
  static const Color textSubtle = disabledForeground;
  static const Color textBrand = accentOnTint;
  static const Color textBrandDeep = accentOnTint;
  static const Color textOnInverse = inkForeground;

  static const Color borderSubtle = border;
  static const Color borderControl = control;

  static const Color brand = accent;
  static const Color brandHover = accentHover;
  static const Color brandTint = accentTint;
  static const Color brandTintStrong = accentTint;
  static const Color brandSubtle = accentTint;
  static const Color onBrand = accentForeground;

  /// Ink is the selected control (radio, segment) and the primary action.
  static const Color controlSelected = ink;
  static const Color controlSelectedText = inkForeground;
  static const Color controlTrackOff = fill;

  static const Color focusField = accent;

  /// `color-mix(in srgb, accent 24%, transparent)`.
  static const Color focusHalo = Color(0x3D5066CC);
  static const Color scrim = _T.colorOverlayScrim;

  static const Color danger = negative;
  static const Color dangerTint = _T.colorDangerTint;
  static const Color success = positive;
  static const Color warning = _T.colorWarning;
  static const Color warningTint = _T.colorWarningTint;

  /// The Numaya mark's dot (kept from the brand mark).
  static const Color accentRose = _T.colorAccentRose;
}
