import 'package:flutter/painting.dart';

import '../tokens/monochrome_tokens.dart';

typedef _M = MonoColors;

/// Colours of the Monochrome Meetup experiment.
///
/// A cool neutral system (soft grey page, white surfaces, charcoal text) with Numaya's purple
/// (#7262C7) as the one brand colour: primary actions, selection, the active tab, links and key
/// states. No gradients. The role names are the ones every screen already uses, re-pointed onto
/// `MonoColors` (tokens/monochrome_tokens.dart); see
/// docs/design-experiments/monochrome-meetup/TOKENS.md for each role and its contrast.
abstract final class AppColors {
  // Surfaces ---------------------------------------------------------------------------------
  /// The page behind every screen.
  static const Color canvas = _M.canvas;

  /// Cards, grouped rows, fields, sheets, bars.
  static const Color surface = _M.surface;

  /// Idle pills, segmented track, switch-off track, tiles, chips on white.
  static const Color fill = _M.fill;

  /// Hairlines: dividers, card and bar edges.
  static const Color border = _M.line;

  /// Dashed add slots, the sheet grabber.
  static const Color borderStrong = _M.lineStrong;

  /// Photo placeholders.
  static const Color photo = _M.fillStrong;

  /// Border of a tinted card (CL-03): the card's own hue at 15%, so the edge reads against both
  /// white cards and the grey page without a second colour.
  static Color tintBorder(Color hue) => hue.withValues(alpha: 0.15);

  /// Off switch track (CL-01): light grey (#DDDDE3), no outline. One step deeper than the card
  /// fill so an off switch still reads on a white card; the thumb's edge does the rest.
  static const Color switchOff = _M.fieldPressed;

  /// Filled fields and filled secondary buttons.
  static const Color field = _M.field;
  static const Color fieldPressed = _M.fieldPressed;

  /// Field outline (3.38:1 on white): focus-free boundaries where one is still needed.
  static const Color outline = _M.outline;

  /// Unselected radio and checkbox rings (3:1).
  static const Color control = _M.outline;

  // Text and ink -------------------------------------------------------------------------------
  /// Text, headings and strong icons. Strong neutral buttons where purple would compete.
  static const Color ink = _M.ink;
  static const Color inkForeground = _M.onBrand;

  static const Color disabled = _M.disabled;
  static const Color disabledForeground = _M.disabledText;

  // Purple -----------------------------------------------------------------------------------
  /// The brand purple: primary actions, selected controls, active tab, progress, switch on.
  static const Color accent = _M.brand;
  static const Color accentHover = _M.brandPressed;
  static const Color accentForeground = _M.onBrand;

  /// Subtle purple surface: badges, info cards, selected chips.
  static const Color accentTint = _M.brandSubtle;

  /// Purple text and icons on light surfaces; links.
  static const Color accentOnTint = _M.brandText;

  /// Edge of a selected chip.
  static const Color accentLine = _M.brandLine;

  /// Initials avatars: the neutral photo grey with a charcoal initial (purple is kept for
  /// actions; a dark disc was too heavy at profile size).
  static const Color identity = _M.fillStrong;
  static const Color onIdentity = _M.text2;

  /// Outline of secondary buttons and other quiet controls: ink at 30%.
  static const Color outlineSoft = Color(0x4D18181B);

  /// Success and confirmations.
  static const Color positive = _M.success;

  /// Destructive buttons, notification dots, errors.
  static const Color negative = _M.danger;

  /// Round holders behind interest-set emoji: one neutral fill (no competing hues).
  static const Color markYellow = _M.fill;
  static const Color markLavender = _M.fill;
  static const Color markPink = _M.fill;

  // Shared roles -------------------------------------------------------------------------------
  static const Color surfacePage = canvas;
  static const Color surfaceSoft = fill;
  static const Color surfaceSunken = photo;
  static const Color surfacePhoto = photo;
  static const Color surfaceBrand = accentTint;
  static const Color surfaceInverse = ink;

  static const Color textPrimary = ink;
  static const Color textSecondary = _M.text2;
  static const Color textMuted = _M.muted;

  /// Icons (Tabler MVP pass): the selected tab's filled glyph is near-black on the very light
  /// neutral selection fill; idle tabs and other inactive icons are a light grey outline.
  static const Color iconSelected = _M.text2;
  static const Color iconSelectedFill = _M.fill;
  static const Color iconInactive = _M.iconInactive;
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

  /// Purple is the selected control (radio, segment, pill) and the primary action.
  static const Color controlSelected = accent;
  static const Color controlSelectedText = accentForeground;
  static const Color controlTrackOff = fill;

  static const Color focusField = accent;

  /// Brand at 24%.
  static const Color focusHalo = Color(0x3D7262C7);
  static const Color scrim = _M.scrim;

  /// Solid translucent panel for text over photos (no gradient scrims).
  static const Color photoPanel = _M.photoPanel;

  /// Round buttons floating on photos.
  static const Color photoButton = _M.photoButton;

  static const Color danger = negative;
  static const Color dangerTint = _M.dangerSubtle;
  static const Color success = positive;
  static const Color successTint = _M.successSubtle;
  static const Color warning = _M.warning;
  static const Color warningTint = _M.warningSubtle;

  /// Semantic accents for icon tiles and statuses (never actions): see [AccentTone].
  static const Color info = _M.info;
  static const Color infoTint = _M.infoSubtle;
  static const Color social = _M.social;
  static const Color socialTint = _M.socialSubtle;

  /// Separators between rows of a grouped list, inset to the text.
  static const Color divider = _M.divider;

  /// The Numaya mark's dot: brand purple.
  static const Color accentRose = accent;
}
