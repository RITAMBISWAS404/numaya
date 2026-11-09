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

  /// Enabled off-switch track (SW-01, owner decision 2026-11-07): solid #D6D6D6 with no border or
  /// stroke, a white thumb. Replaces FT-04's #EAEAEA track with a #8A8A8A edge. Measured contrast:
  /// 1.45:1 on a white card (and against the white thumb), 1.32:1 on the #F4F4F4 page; below the
  /// 3:1 non-text target (WCAG 1.4.11). Flagged for owner review; no border is added to make up
  /// for it. State is also carried by thumb position and the row's toggled semantics.
  static const Color switchOff = _M.switchOff;

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
  static const Color onIdentity = iconStrong;

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

  /// Text colour roles (FT-02, Figma type and icons pass 2026-11-07), mapped from Ente's
  /// `text/base` and `text/light` (Design system 57:6281; Menu Item 4055:18734, Bottom sheet
  /// 4809:8074, Settings 12099:96480):
  /// - [textPrimary] #000000: titles, labels, row titles, values the user typed, reading text
  ///   that is the content itself (21:1 on white, 19.3:1 on the page).
  /// - [textSecondary] #666666: subtitles, descriptions, helper and supporting sentences, row
  ///   values and details, metadata and timestamps (5.74:1 on white, 5.22:1 on the page, 4.77:1
  ///   on the #EAEAEA fill). Ente uses the one `text/light` grey for all of these and separates
  ///   metadata by size (Mini 12) rather than by a fainter grey.
  /// - [textMuted]: the same grey, kept as the name most call sites already use.
  /// - Placeholders: [textSecondary] at weight 400. Ente's `text/lighter` #969696 is 2.96:1 on
  ///   white, below 4.5:1, so it is not used for text.
  /// - Disabled: [disabledForeground] #8A8A8A (inactive controls are exempt from the minimum).
  /// - Inverse: [inkForeground] white. Semantic: [negative], [success], [warning], [info].
  /// Before this pass [textSecondary] was #1A1A1A, a near-black that made supporting text as
  /// dark as titles.
  static const Color textPrimary = ink;
  static const Color textSecondary = _M.muted;
  static const Color textMuted = textSecondary;

  /// Supporting icons (X15-I): list-row leading glyphs and row chevrons, the control grey #8A8A8A
  /// (3.45:1 on white cards, 3.14:1 on the page; meaningful graphics need 3:1). One step lighter
  /// than the #666 supporting text, so the row's words lead. Not for icons on the #EAEAEA fill.
  static const Color iconSupporting = _M.iconInactive;

  /// Strong neutral icon ink (#1A1A1A): the selected tab glyph and idle tab icons on the bar.
  /// Over a dark photo the bar's idle icons need more than the grey's 3.38:1.
  static const Color iconStrong = _M.text2;

  /// Icons (Tabler MVP pass): the selected tab's filled glyph is near-black on the very light
  /// neutral selection fill; idle tabs and other inactive icons are a light grey outline.
  static const Color iconSelected = iconStrong;
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

  /// The lower edge of a photo text gradient (10% black; owner cap under 25%).
  static const Color photoScrimEdge = _M.photoScrimEdge;

  /// Round buttons floating on photos.
  static const Color photoButton = _M.photoButton;

  static const Color danger = negative;
  static const Color dangerTint = _M.dangerSubtle;
  static const Color success = positive;
  static const Color successTint = _M.successSubtle;
  static const Color warning = _M.warning;
  static const Color warningTint = _M.warningSubtle;

  /// Owner-approved anchors (Ente alignment V3) and their icon roles; see FOUNDATIONS.md.
  static const Color errorBase = _M.errorBase;
  static const Color dangerIcon = _M.dangerIcon;
  static const Color successBase = _M.successBase;
  static const Color successIcon = _M.successIcon;
  static const Color warningBase = _M.warningBase;
  static const Color warningIcon = _M.warningIcon;

  /// Text on the orange anchor: ink (9.95:1); white on it would be 2.11:1.
  static const Color onWarningBase = _M.ink;

  /// Semantic accents for icon tiles and statuses (never actions): see [AccentTone].
  /// The empty part of a track on the neutral fill.
  static const Color fillStrong = _M.fillStrong;

  static const Color info = _M.info;
  static const Color infoTint = _M.infoSubtle;
  static const Color social = _M.social;
  static const Color socialTint = _M.socialSubtle;

  /// Separators between rows of a grouped list, inset to the text.
  static const Color divider = _M.divider;

  /// The Numaya mark's dot: brand purple.
  static const Color accentRose = accent;
}
