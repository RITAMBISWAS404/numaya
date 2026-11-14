import 'package:flutter/painting.dart';

import '../tokens/monochrome_tokens.dart';
import 'type_settings.dart';

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
  ///
  /// UI-095 (Dev Mode): the brand roles are read from the active [BrandPalette], so the review
  /// build can compare #7262C7, #7E77F8 and #A07ADD live. [BrandPalette.baseline] is the verified
  /// palette and the only one release builds use. Neutral and semantic roles never change.
  static BrandPalette _brand = BrandPalette.baseline;
  static BrandPalette get brandPalette => _brand;
  static void applyBrand(BrandPalette palette) => _brand = palette;

  static Color get accent => _brand.brand;
  static Color get accentHover => _brand.pressed;
  static const Color accentForeground = _M.onBrand;

  /// Subtle purple surface: badges, info cards, selected chips.
  static Color get accentTint => _brand.subtle;

  /// Purple text and icons on light surfaces; links.
  static Color get accentOnTint => _brand.text;

  /// Edge of a selected chip.
  static Color get accentLine => _brand.line;

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
  static Color get surfaceBrand => accentTint;
  static const Color surfaceInverse = ink;

  /// Fable lab: the dark feature card (Ente's storage card, 12099:96480). White on it is
  /// 17.4:1; [onHeroMuted] (70% white) is 9.0:1; [heroTrack] is an empty track or a quiet pill.
  static const Color surfaceHero = _M.text2;
  static const Color onHeroMuted = Color(0xB3FFFFFF);
  static const Color heroTrack = Color(0x29FFFFFF);

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
  ///
  /// UI-012 (new build, 2026-11-15): three emphasis levels on light surfaces, assigned by
  /// purpose. [textPrimary] near-black for headings and main information; [textSecondary] a dark
  /// grey #4D4D4D for supporting copy, subtitles and helper sentences (8.45:1 on white, 7.69:1 on
  /// the page, 7.03:1 on the #EAEAEA fill); [textTertiary] the lighter readable #666666 for
  /// low-emphasis metadata, counters, timestamps and placeholders (5.74 / 5.22 / 4.77:1, all
  /// above 4.5:1, so small metadata stays readable). Before this pass secondary and metadata
  /// shared #666 and were told apart by size alone.
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF4D4D4D);
  static const Color textTertiary = _M.muted;

  /// The name most call sites use for muted text (previews, placeholders, metadata): tertiary.
  static const Color textMuted = textTertiary;

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
  static Color get textBrand => accentOnTint;
  static Color get textBrandDeep => accentOnTint;
  static const Color textOnInverse = inkForeground;

  static const Color borderSubtle = border;
  static const Color borderControl = control;

  static Color get brand => accent;
  static Color get brandHover => accentHover;
  static Color get brandTint => accentTint;
  static Color get brandTintStrong => accentTint;
  static Color get brandSubtle => accentTint;
  static const Color onBrand = accentForeground;

  /// Purple is the selected control (radio, segment, pill) and the primary action.
  static Color get controlSelected => accent;
  static const Color controlSelectedText = accentForeground;
  static const Color controlTrackOff = fill;

  static Color get focusField => accent;

  /// Brand at 24%.
  static Color get focusHalo => accent.withValues(alpha: 0x3D / 255);
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

  /// Outlined secondary and quiet buttons (replacement V8, C-03).
  static const Color buttonOutline = MonoButtons.outline;

  /// UI-060: passive callouts (no outline): one step darker than the #F4F4F4 page.
  static const Color calloutFill = _M.fill;

  /// UI-098 (Dev Mode Filled): the subtle secondary surface, black at 8% over its background, and
  /// its disabled state at 4%.
  static const Color secondaryFill = Color(0x14000000);
  static const Color secondaryFillDisabled = Color(0x0A000000);

  /// UI-057: the outlined disabled button: a light edge, no fill, grey label.
  static const Color disabledOutline = MonoButtons.disabledOutline;

  /// The outlined brand button.
  static Color get accentOutline => accent.withValues(alpha: 0x73 / 255);

  /// The Numaya mark's dot: brand purple.
  static Color get accentRose => accent;
}
