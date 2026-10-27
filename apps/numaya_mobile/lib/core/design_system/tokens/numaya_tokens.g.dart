// GENERATED FILE. DO NOT EDIT.
// Source: tokens/numaya.tokens.json -> src/design-system/tokens.js -> tool/generate_tokens.mjs
// Regenerate: node apps/numaya_mobile/tool/generate_tokens.mjs
// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// color tokens of the Numaya design system (81).
abstract final class NumayaColorTokens {
  /// Meetup primary purple: selected pills and chips, outgoing bubbles, progress, links, send and confirm actions, switches' focus. White text and glyphs on it are 4.90:1 (AA).
  static const Color colorBrand = Color(0xFF7262C7);

  /// Hover and pressed state of solid purple actions and controls.
  static const Color colorBrandHover = Color(0xFF5F50B3);

  /// Palest lavender surface for selected states and soft buttons; purple text 4.7:1.
  static const Color colorBrandTint = Color(0xFFFAF8FF);

  /// Stronger lavender: pressed tints and illustration framing.
  static const Color colorBrandTintStrong = Color(0xFFE9E4FB);

  /// Lavender borders and tinted placeholders.
  static const Color colorBrandSubtle = Color(0xFFDDD6F7);

  /// Soft lavender secondary-button fill (Meetup 'Sign up with email').
  static const Color colorBrandSoft = Color(0xFFFAF8FF);

  /// Large decorative purple (hero washes, illustration framing). Never behind small text.
  static const Color colorBrandHero = Color(0xFF9C85E6);

  /// Checked radio, checkbox and switch track, slider interval, selected pill fill.
  static const Color colorControlSelected = Color(0xFF7262C7);

  /// Text, ticks and thumbs on a selected control (4.90:1).
  static const Color colorControlSelectedText = Color(0xFFFFFFFF);

  /// Off switch track and empty slider rail (neutral).
  static const Color colorControlTrackOff = Color(0xFFDADADD);

  /// Text and glyphs on a solid brand-purple fill: white, 4.90:1.
  static const Color colorOnBrand = Color(0xFFFFFFFF);

  /// Periwinkle framing: avatar pastels and illustration accents (Meetup secondary palette). Never text.
  static const Color colorAccentPromo = Color(0xFFD6DCFD);

  /// Badges, category marks and the wordmark dot (Meetup accent rose).
  static const Color colorAccentRose = Color(0xFFEA698C);
  static const Color colorAccentRoseTint = Color(0xFFFDE8EE);

  /// Illustration framing.
  static const Color colorAccentYellow = Color(0xFFFCD284);

  /// Avatar framing.
  static const Color colorAccentYellowTint = Color(0xFFFDF0D0);

  /// Time and status icons.
  static const Color colorAccentOrange = Color(0xFFD58B50);

  /// Confirmation marks.
  static const Color colorAccentGreen = Color(0xFF5D946A);
  static const Color colorTextPrimary = Color(0xFF141316);
  static const Color colorTextSecondary = Color(0xFF3C3B40);

  /// Body copy, ledes, meta. 5.8:1 on white.
  static const Color colorTextMuted = Color(0xFF66656B);

  /// Placeholders and disabled labels only (2.8:1, documented exception).
  static const Color colorTextSubtle = Color(0xFF9B9BA0);

  /// Links and brand-context text on white (Meetup 'See all', legal links). 4.90:1.
  static const Color colorTextBrand = Color(0xFF7262C7);

  /// Text on lavender tints (7.1:1).
  static const Color colorTextBrandDeep = Color(0xFF4F4296);
  static const Color colorTextOnInverse = Color(0xFFFFFFFF);
  static const Color colorSurface = Color(0xFFFFFFFF);

  /// Meetup grey fills: fields, search, unselected filter pills, incoming bubbles, quote cards.
  static const Color colorSurfaceSoft = Color(0xFFF2F2F2);

  /// Tracks, disabled fills, the active tab pill.
  static const Color colorSurfaceSunken = Color(0xFFE9E8EB);

  /// Neutral grey placeholder for a profile photo until licensed photography is supplied.
  static const Color colorSurfacePhoto = Color(0xFFDADADD);

  /// App page background (Meetup: white pages; cards separate with a hairline and a faint shadow).
  static const Color colorSurfacePage = Color(0xFFFFFFFF);

  /// Background behind app frames and showcase pages.
  static const Color colorSurfaceCanvas = Color(0xFFF2F2F2);

  /// Lavender wash at the top of brand screens (Meetup Home header).
  static const Color colorSurfaceBrand = Color(0xFFF3F0FD);

  /// Ink fills: primary CTAs, checked checkboxes, switches, toasts.
  static const Color colorSurfaceInverse = Color(0xFF141316);

  /// Card and chip hairlines (Meetup).
  static const Color colorBorderSubtle = Color(0xFFE9E8EB);
  static const Color colorBorderStrong = Color(0xFFDADADD);
  static const Color colorBorderBrand = Color(0xFF7262C7);

  /// Outlines of unchecked checkboxes and radios (3.4:1, meets non-text contrast).
  static const Color colorBorderControl = Color(0xFF8A8A90);

  /// Keyboard focus indicator: brand purple, 4.90:1 on white.
  static const Color colorFocusRing = Color(0xFF7262C7);

  /// Soft lavender ring around a focused control.
  static const Color colorFocusHalo = Color(0x3D7262C7);

  /// Focus stroke of fields, search, code cells and the composer: one 2px purple stroke plus the halo.
  static const Color colorFocusField = Color(0xFF7262C7);
  static const Color colorOverlayScrim = Color(0x57141316);
  static const Color colorOverlayHoverLight = Color(0x8CFFFFFF);

  /// Bottom legibility overlay for text on photos (functional, not decorative).
  static const Color colorOverlayPhoto = Color(0x9E141316);
  static const Color colorDanger = Color(0xFFB93A36);
  static const Color colorDangerTint = Color(0xFFFCEFEE);

  /// Unread and notification count badges (Meetup red), white numerals 4.9:1.
  static const Color colorDangerBadge = Color(0xFFB93A36);
  static const Color colorSuccess = Color(0xFF336E48);
  static const Color colorSuccessTint = Color(0xFFEBF4EE);
  static const Color colorWarning = Color(0xFF9A5B00);
  static const Color colorWarningTint = Color(0xFFFFF6E5);

  /// The page behind every screen (#F5F4F1).
  static const Color colorWithingsCanvas = Color(0xFFF5F4F1);

  /// Cards, grouped rows, fields, sheets, the tab bar and modal headers (#FFFFFF). No border or shadow on the stone page.
  static const Color colorWithingsSurface = Color(0xFFFFFFFF);

  /// Segmented-control track, unselected filter and interest pills, recessed placeholders (#EAE9E6).
  static const Color colorWithingsFill = Color(0xFFEAE9E6);

  /// Row dividers inside cards, modal header and tab bar edges, outlined boxes on the page (#E6E5E2).
  static const Color colorWithingsBorder = Color(0xFFE6E5E2);

  /// Dashed empty photo slots, the sheet grabber (#D3D0CC). Decorative edges only.
  static const Color colorWithingsBorderStrong = Color(0xFFD3D0CC);

  /// Photo placeholders and missing activity images (#DFDDD9).
  static const Color colorWithingsPhoto = Color(0xFFDFDDD9);

  /// Text-field outline (#6D6C6A).
  static const Color colorWithingsOutline = Color(0xFF6D6C6A);

  /// Unselected radio and checkbox rings (#8A8784).
  static const Color colorWithingsControl = Color(0xFF8A8784);

  /// Primary text and headings, primary buttons, selected radios and option rings, the active tab (#121212).
  static const Color colorWithingsInk = Color(0xFF121212);

  /// Text on ink (#FFFFFF, 18.7:1).
  static const Color colorWithingsInkForeground = Color(0xFFFFFFFF);

  /// Row subtitles, helper text, descriptions (#5E5C59).
  static const Color colorWithingsTextSecondary = Color(0xFF5E5C59);

  /// Metadata, timestamps, inactive tab labels (#6B6966); 4.5:1 or better on every V16 surface.
  static const Color colorWithingsTextMuted = Color(0xFF6B6966);

  /// Disabled button fill (#D6D2CE).
  static const Color colorWithingsDisabled = Color(0xFFD6D2CE);

  /// Disabled button label (#77736F).
  static const Color colorWithingsDisabledForeground = Color(0xFF77736F);

  /// Withings blue (#5066CC): your message bubbles, the SuperSwipe, checked checkboxes, slider fills, unread counts, links and focus.
  static const Color colorWithingsAccent = Color(0xFF5066CC);
  static const Color colorWithingsAccentHover = Color(0xFF4357B8);

  /// Text on Withings blue (#FFFFFF, 5.11:1).
  static const Color colorWithingsAccentForeground = Color(0xFFFFFFFF);

  /// Selected filter and period pills, selected interests, the tinted action row (#E4EBFC).
  static const Color colorWithingsAccentTint = Color(0xFFE4EBFC);

  /// Text and icons on the blue tint (#3E4A8F, 6.8:1).
  static const Color colorWithingsAccentOnTint = Color(0xFF3E4A8F);

  /// Initial avatars and portrait fallbacks (#203068) with white initials.
  static const Color colorWithingsIdentity = Color(0xFF203068);

  /// Switch on, completion checks (#3C783C).
  static const Color colorWithingsPositive = Color(0xFF3C783C);

  /// Destructive buttons, notification dots (#CF3336).
  static const Color colorWithingsNegative = Color(0xFFCF3336);

  /// Round holder behind an emoji mark (category headings). Never text or controls.
  static const Color colorWithingsMarkYellow = Color(0xFFFCEAB7);

  /// Round holder behind an emoji mark. Never text or controls.
  static const Color colorWithingsMarkLavender = Color(0xFFE4C9ED);

  /// Round holder behind an emoji mark. Never text or controls.
  static const Color colorWithingsMarkPink = Color(0xFFFCCCC4);
  static const Color buttonPrimaryBgTop = Color(0xFF7262C7);
  static const Color buttonPrimaryBgBottom = Color(0xFF7262C7);
  static const Color buttonPrimaryBgHoverTop = Color(0xFF5F50B3);
  static const Color buttonPrimaryBgHoverBottom = Color(0xFF5F50B3);
  static const Color buttonInkBgTop = Color(0xFF2D2C2F);
  static const Color buttonInkBgBottom = Color(0xFF141316);
}

/// dimension tokens of the Numaya design system (153).
abstract final class NumayaSizeTokens {
  static const double typeHeroSize = 34.0;
  static const double typeHeroLine = 38.0;
  static const double typeHeroTracking = -0.022;
  static const double typeDisplaySize = 31.0;
  static const double typeDisplayLine = 35.0;
  static const double typeDisplayTracking = -0.02;
  static const double typeHeadlineSize = 26.0;
  static const double typeHeadlineLine = 30.0;
  static const double typeHeadlineTracking = -0.02;
  static const double typeTitleSize = 20.0;
  static const double typeTitleLine = 25.0;
  static const double typeTitleTracking = -0.012;
  static const double typeTitleSmSize = 23.0;
  static const double typeTitleSmLine = 28.0;
  static const double typeTitleSmTracking = -0.015;
  static const double typeBodySize = 15.5;
  static const double typeBodyLine = 23.0;
  static const double typeBodyTracking = -0.006;
  static const double typeBodySmSize = 15.0;
  static const double typeBodySmLine = 21.0;
  static const double typeBodySmTracking = -0.006;
  static const double typeInputSize = 18.0;
  static const double typeInputLine = 24.0;
  static const double typeInputTracking = 0.0;
  static const double typeButtonSize = 16.0;
  static const double typeButtonLine = 20.0;
  static const double typeButtonTracking = -0.01;
  static const double typeLabelSize = 13.5;
  static const double typeLabelLine = 18.0;
  static const double typeLabelTracking = 0.0;
  static const double typeCaptionSize = 13.0;
  static const double typeCaptionLine = 18.0;
  static const double typeCaptionTracking = 0.0;
  static const double typeMicroSize = 12.5;
  static const double typeMicroLine = 17.0;
  static const double typeMicroTracking = 0.0;
  static const double typeEyebrowSize = 11.0;
  static const double typeEyebrowLine = 14.0;
  static const double typeEyebrowTracking = 0.12;
  static const double space0 = 0.0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space7 = 28.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;

  /// Screen side padding.
  static const double layoutGutter = 16.0;

  /// Edge-to-edge content: the Discover card, chat header controls.
  static const double layoutGutterTight = 8.0;

  /// Max content width on phones; wider viewports centre the column.
  static const double layoutContentMax = 430.0;

  /// Gap between stacked controls.
  static const double layoutStackGap = 12.0;

  /// Gap between distinct content sections and grouped lists (Meetup rhythm), clearly larger than the 20px between form fields, so a group's footnote reads with its group.
  static const double layoutSectionGap = 28.0;

  /// Gap between form fields and between a field group and the next field.
  static const double layoutFieldGap = 20.0;

  /// Text input height.
  static const double sizeControl = 56.0;

  /// Minimum touch target.
  static const double sizeTouchMin = 44.0;
  static const double sizeIconSm = 16.0;
  static const double sizeIconMd = 20.0;
  static const double sizeIconLg = 24.0;
  static const double sizeAvatarXs = 24.0;
  static const double sizeAvatarSm = 36.0;
  static const double sizeAvatarMd = 48.0;
  static const double sizeAvatarLg = 64.0;
  static const double sizeAvatarXl = 96.0;
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radius2xl = 32.0;

  /// Large photography and hero images (Discover card, profile photos, match photos): the softest corner in the system.
  static const double radiusPhoto = 32.0;

  /// Major content containers: section cards, grouped rows, prompt cards, the floating options menu, reserved illustration areas. Between photo (32) and controls (md 16).
  static const double radiusCard = 24.0;
  static const double radiusPill = 999.0;
  static const double borderHairline = 1.0;
  static const double borderSelected = 1.5;
  static const double borderFocus = 2.0;
  static const double buttonHeight = 54.0;
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightQuiet = 48.0;
  static const double fabSize = 56.0;
  static const double iconButtonSize = 40.0;
  static const double iconButtonSizeSm = 36.0;
  static const double chipHeight = 36.0;
  static const double progressSegmentWidth = 18.0;
  static const double progressSegmentHeight = 8.0;
  static const double codeCellHeight = 60.0;

  /// Six separate soft cells (chosen over one segmented group, whose empty positions disappeared): about a third of the 52px cell width, softer than fields' old 16px but not a capsule.
  static const double codeCellRadius = 18.0;
  static const double switchWidth = 51.0;
  static const double switchHeight = 31.0;
  static const double tabBarHeight = 64.0;

  /// Outlined labels ('Withings+' badge), status labels, the checkbox.
  static const double withingsRadiusTag = 6.0;

  /// Text fields, search, the composer (measured ≈8pt).
  static const double withingsRadiusField = 8.0;

  /// Full-width buttons, tinted action rows, chips and interest pills (measured 10–12pt).
  static const double withingsRadiusControl = 12.0;

  /// Cards, grouped rows, the prompt, information boxes, photo tiles, message bubbles (measured 12–14pt).
  static const double withingsRadiusCard = 14.0;

  /// Full-width profile photographs and sheets.
  static const double withingsRadiusPhoto = 16.0;

  /// Compact outlined actions ('Add a Reminder', 'Share'), period and filter tabs, segmented options, counts.
  static const double withingsRadiusPill = 999.0;

  /// Full-width buttons (measured 46–49pt).
  static const double withingsButtonHeight = 50.0;

  /// Text fields (measured 55pt).
  static const double withingsFieldHeight = 54.0;

  /// Circular header buttons (measured 40pt).
  static const double withingsHeaderButton = 40.0;

  /// Single-line rows in a grouped card (measured 56pt).
  static const double withingsRowHeight = 56.0;

  /// Small outlined pills ('Add a Reminder'), visible height inside the 44px target.
  static const double withingsButtonHeightSm = 36.0;

  /// Segmented-control track corner (Programs / Library).
  static const double withingsSegmentRadius = 10.0;

  /// Gap between the segmented track and its segments; a segment's corner is the track's minus this.
  static const double withingsSegmentInset = 2.0;

  /// Segment height (track = this + 2 × inset).
  static const double withingsSegmentHeight = 32.0;

  /// Search field height.
  static const double withingsSearchHeight = 46.0;

  /// Composer field corner: half its 44px height, a pill beside the round send button.
  static const double withingsComposerRadius = 22.0;

  /// Discover action circles and the step button.
  static const double withingsActionSize = 56.0;

  /// New-match portraits (round).
  static const double withingsPortraitSize = 72.0;

  /// Round pastel holder behind an interest-set emoji.
  static const double withingsMarkSize = 28.0;

  /// Round tint holder behind the prompt mark.
  static const double withingsPromptMarkSize = 24.0;

  /// Radio and checkbox size.
  static const double withingsChoiceSize = 22.0;

  /// Switch thumb (iOS proportions in a 51 × 31 track).
  static const double withingsThumbSwitch = 27.0;

  /// Slider thumb.
  static const double withingsThumbSlider = 26.0;
  static const double withingsTypeHeroSize = 32.0;
  static const double withingsTypeHeroLine = 38.0;

  /// Tab-root page titles
  static const double withingsTypePageSize = 30.0;
  static const double withingsTypePageLine = 36.0;
  static const double withingsTypeHeadlineSize = 24.0;
  static const double withingsTypeHeadlineLine = 30.0;

  /// Onboarding flow headings
  static const double withingsTypeFlowSize = 26.0;
  static const double withingsTypeFlowLine = 32.0;

  /// Section and group headings, profile prompt answers
  static const double withingsTypeSectionSize = 22.0;
  static const double withingsTypeSectionLine = 28.0;

  /// Sheet titles
  static const double withingsTypeSheetSize = 20.0;
  static const double withingsTypeSheetLine = 26.0;

  /// Empty-state card titles
  static const double withingsTypeEmptySize = 18.0;
  static const double withingsTypeEmptyLine = 24.0;

  /// Row labels, inputs
  static const double withingsTypeRowSize = 16.0;
  static const double withingsTypeRowLine = 22.0;

  /// Card titles, chips
  static const double withingsTypeCardSize = 15.0;
  static const double withingsTypeCardLine = 20.0;
  static const double withingsTypeBodySize = 15.5;
  static const double withingsTypeBodyLine = 22.0;
  static const double withingsTypeBodySmSize = 15.0;
  static const double withingsTypeBodySmLine = 21.0;
  static const double withingsTypeButtonSmSize = 14.0;
  static const double withingsTypeLabelSize = 14.0;
  static const double withingsTypeLabelLine = 18.0;
  static const double withingsTypeCaptionSize = 13.5;
  static const double withingsTypeCaptionLine = 18.0;
  static const double withingsTypeMicroSize = 12.5;

  /// Modal header capitals
  static const double withingsTypeHeaderCapsSize = 12.5;
  static const double withingsTypeHeaderCapsLine = 16.0;

  /// Field and legend capitals
  static const double withingsTypeLabelCapsSize = 11.5;
  static const double withingsTypeLabelCapsLine = 14.0;

  /// Upper bound of the match title clamp (the lower bound is hero-size).
  static const double withingsTypeMatchMax = 36.0;
  static const double withingsTypeTrackingTitle = -0.02;
  static const double withingsTypeTrackingFlow = -0.015;
  static const double withingsTypeTrackingHeading = -0.01;
  static const double withingsTypeTrackingHeaderCaps = 0.16;
  static const double withingsTypeTrackingLabelCaps = 0.06;
}

/// fontWeight tokens of the Numaya design system (17).
abstract final class NumayaWeightTokens {
  static const double fontWeightRegular = 400.0;
  static const double fontWeightMedium = 500.0;
  static const double fontWeightSemibold = 600.0;
  static const double fontWeightBold = 680.0;
  static const double typeHeroWeight = 520.0;
  static const double typeDisplayWeight = 520.0;
  static const double typeHeadlineWeight = 520.0;
  static const double typeTitleWeight = 520.0;
  static const double typeTitleSmWeight = 520.0;
  static const double typeBodyWeight = 400.0;
  static const double typeBodySmWeight = 400.0;
  static const double typeInputWeight = 500.0;
  static const double typeButtonWeight = 600.0;
  static const double typeLabelWeight = 500.0;
  static const double typeCaptionWeight = 400.0;
  static const double typeMicroWeight = 400.0;
  static const double typeEyebrowWeight = 600.0;
}

/// number tokens of the Numaya design system (8).
abstract final class NumayaNumberTokens {
  /// Default icon stroke width (24px grid).
  static const double iconStroke = 1.75;

  /// Icons inside filled buttons and small sizes.
  static const double iconStrokeBold = 2.0;
  static const double opacityDisabled = 0.45;

  /// Content locked while a request is checking.
  static const double opacityPending = 0.55;
  static const double zRaised = 1.0;
  static const double zSticky = 5.0;
  static const double zOverlay = 10.0;
  static const double zToast = 20.0;
}

/// duration tokens of the Numaya design system (4).
abstract final class NumayaMotionTokens {
  static const Duration motionDurationFast = Duration(milliseconds: 140);
  static const Duration motionDurationBase = Duration(milliseconds: 220);
  static const Duration motionDurationSlow = Duration(milliseconds: 380);

  /// Screen push/pop, sheets, keyboard.
  static const Duration motionDurationPush = Duration(milliseconds: 460);
}

/// cubicBezier tokens of the Numaya design system (3).
abstract final class NumayaCurveTokens {
  /// Default for entering and state changes.
  static const Cubic motionEaseOut = Cubic(0.22, 1.0, 0.36, 1.0);

  /// Navigation, sheets.
  static const Cubic motionEaseEmphasized = Cubic(0.32, 0.72, 0.0, 1.0);

  /// Exits.
  static const Cubic motionEaseInOut = Cubic(0.65, 0.0, 0.35, 1.0);
}

/// shadow tokens of the Numaya design system (10).
abstract final class NumayaShadowTokens {
  /// White switch and slider thumbs: a barely-there edge and a soft drop so the white thumb reads on ink, purple, grey and white without an outline.
  static const List<BoxShadow> shadowThumb = [
    BoxShadow(
      color: Color(0x0F141316),
      offset: Offset(0.0, 0.0),
      blurRadius: 0.0,
      spreadRadius: 0.5,
    ),
    BoxShadow(
      color: Color(0x29141316),
      offset: Offset(0.0, 2.0),
      blurRadius: 6.0,
      spreadRadius: 0.0,
    ),
  ];

  /// Tiny lift for small moving parts: switch knob, slider thumb, selected segment, selected option card.
  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Color(0x0D141316),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
  ];

  /// Raised cards and list groups, floating icon buttons. Replaces outlines: no ring, just a soft contact shadow.
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A141316),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Color(0x14141316),
      offset: Offset(0.0, 6.0),
      blurRadius: 16.0,
      spreadRadius: -6.0,
    ),
  ];

  /// Bottom sheets and bottom panels (shadow falls upward).
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0A141316),
      offset: Offset(0.0, -1.0),
      blurRadius: 0.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Color(0x1A141316),
      offset: Offset(0.0, -6.0),
      blurRadius: 20.0,
      spreadRadius: -8.0,
    ),
  ];

  /// Persistent chrome that floats over the page: the bottom tab bar and the hero profile card.
  static const List<BoxShadow> shadowFloat = [
    BoxShadow(
      color: Color(0x0D141316),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Color(0x24141316),
      offset: Offset(0.0, 12.0),
      blurRadius: 32.0,
      spreadRadius: -12.0,
    ),
  ];

  /// Dialogs, toasts and popovers: the only tier that must clearly read as layered.
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x0F141316),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Color(0x33141316),
      offset: Offset(0.0, 10.0),
      blurRadius: 28.0,
      spreadRadius: -8.0,
    ),
  ];

  /// Primary ink buttons: a faint top highlight and a contact shadow.
  static const List<BoxShadow> shadowButton = [
    BoxShadow(
      color: Color(0x24141316),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
  ];

  /// Floating purple actions (Meetup 'Map' pill, confirm FAB): a contact shadow and a soft purple drop. Flat purple pills inside content use none.
  static const List<BoxShadow> shadowBrand = [
    BoxShadow(
      color: Color(0x14141316),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Color(0x667262C7),
      offset: Offset(0.0, 6.0),
      blurRadius: 16.0,
      spreadRadius: -6.0,
    ),
  ];

  /// V16: the one elevation, for controls that float over a photograph (the SuperSwipe) and the toast. Cards on the page never take it.
  static const List<BoxShadow> shadowWithingsFloat = [
    BoxShadow(
      color: Color(0x0F121212),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Color(0x24121212),
      offset: Offset(0.0, 4.0),
      blurRadius: 14.0,
      spreadRadius: -4.0,
    ),
  ];

  /// V16: lifts the selected segment off the segmented control's grey track (the reference's 'Programs / Library').
  static const List<BoxShadow> shadowWithingsSegment = [
    BoxShadow(
      color: Color(0x14121212),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Color(0x0A121212),
      offset: Offset(0.0, 0.0),
      blurRadius: 0.0,
      spreadRadius: 0.5,
    ),
  ];
}

/// Fraunces axis settings shared by every display style ("SOFT" 50, "WONK" 0).
abstract final class NumayaFontTokens {
  static const List<(String, double)> displayAxes = [
    ('SOFT', 50.0),
    ('WONK', 0.0),
  ];
}
