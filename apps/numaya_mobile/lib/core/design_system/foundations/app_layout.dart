import 'package:flutter/widgets.dart';

import '../tokens/numaya_tokens.g.dart';

/// 4 pt spacing scale and layout rhythm.
abstract final class AppSpacing {
  static const double s1 = NumayaSizeTokens.space1;
  static const double s2 = NumayaSizeTokens.space2;
  static const double s3 = NumayaSizeTokens.space3;
  static const double s4 = NumayaSizeTokens.space4;
  static const double s5 = NumayaSizeTokens.space5;
  static const double s6 = NumayaSizeTokens.space6;
  static const double s7 = NumayaSizeTokens.space7;
  static const double s8 = NumayaSizeTokens.space8;
  static const double s10 = NumayaSizeTokens.space10;
  static const double s12 = NumayaSizeTokens.space12;

  /// Screen side margin.
  static const double gutter = NumayaSizeTokens.layoutGutter;

  /// Discover's photo card sits 8pt from the edges.
  static const double gutterTight = NumayaSizeTokens.layoutGutterTight;
  static const double stackGap = NumayaSizeTokens.layoutStackGap;
  static const double sectionGap = NumayaSizeTokens.layoutSectionGap;
  static const double fieldGap = NumayaSizeTokens.layoutFieldGap;

  /// Widest content column; wider screens centre it.
  static const double contentMax = NumayaSizeTokens.layoutContentMax;
}

/// Semantic layout roles built on the spacing scale (docs/mobile/UI_REFINEMENT_DECISIONS.md RD-01).
/// Screens use these instead of picking scale steps one by one.
abstract final class AppLayout {
  /// Side margin of every screen, Discover included.
  static const double screenGutter = AppSpacing.gutter;

  /// Space under a top bar or tab header before the first content.
  static const double screenTop = AppSpacing.s4;

  /// Space after the last content before the screen ends.
  static const double screenBottom = AppSpacing.s6;

  /// Between sections of a page (a heading starts a new section).
  static const double sectionGap = AppSpacing.sectionGap;

  /// Between a section heading and its content.
  static const double headingGap = AppSpacing.s3;

  /// Between related items (cards in a list, rows of chips).
  static const double itemGap = AppSpacing.s3;

  /// Inside cards.
  static const double cardPadding = AppSpacing.s4;

  /// Between a leading icon and its text.
  static const double iconLabelGap = AppSpacing.s2;

  /// Between metadata lines (date, place, attendance).
  static const double metaGap = AppSpacing.s1;

  /// Between form fields.
  static const double fieldGap = AppSpacing.fieldGap;

  /// Top bars and tab headers: side padding so their buttons line up with the gutter.
  static const double barPadding = AppSpacing.gutter;
}

/// Media proportions, width ÷ height (RD-10, RD-12).
abstract final class AppMedia {
  /// Person photos (Discover card, photo viewer, previews): 4:3 width to height, as specified
  /// for this pass. V16 drew a portrait 3:4 card; the conflict is recorded in RD-10.
  static const double personPhoto = 4 / 3;

  /// Event covers in lists.
  static const double eventCover = 16 / 9;
}

/// V16 corner radii (`withings.radius.*`): tags 6, fields 8, buttons and chips 12, cards 14, photos and
/// sheets 16; full pills only for compact actions, view tabs and the toast. A nested corner is its
/// container's minus the inset.
abstract final class AppRadii {
  static const double tag = NumayaSizeTokens.withingsRadiusTag;
  static const double field = NumayaSizeTokens.withingsRadiusField;
  static const double control = NumayaSizeTokens.withingsRadiusControl;
  static const double card = NumayaSizeTokens.withingsRadiusCard;
  static const double photo = NumayaSizeTokens.withingsRadiusPhoto;
  static const double pill = NumayaSizeTokens.withingsRadiusPill;

  /// Segmented track; a segment is this minus the inset.
  static const double segment = NumayaSizeTokens.withingsSegmentRadius;

  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));
}

/// Stroke widths.
abstract final class AppBorders {
  static const double hairline = NumayaSizeTokens.borderHairline;
  static const double selected = NumayaSizeTokens.borderSelected;
  static const double focus = NumayaSizeTokens.borderFocus;
}

/// Component and control sizes (shared tokens plus V16's `withings.*`).
abstract final class AppSizes {
  static const double touchMin = NumayaSizeTokens.sizeTouchMin;
  static const double iconSm = NumayaSizeTokens.sizeIconSm;
  static const double iconMd = NumayaSizeTokens.sizeIconMd;
  static const double iconLg = NumayaSizeTokens.sizeIconLg;

  /// Full-width buttons: 50.
  static const double buttonHeight = NumayaSizeTokens.withingsButtonHeight;

  /// Compact pill buttons: 36 visible inside the 44 hit area.
  static const double buttonHeightSm = NumayaSizeTokens.withingsButtonHeightSm;
  static const double buttonHeightQuiet = NumayaSizeTokens.buttonHeightQuiet;

  /// Text fields: 54.
  static const double field = NumayaSizeTokens.withingsFieldHeight;

  /// Grouped and selection rows: 56 minimum.
  static const double row = NumayaSizeTokens.withingsRowHeight;
  static const double fab = NumayaSizeTokens.fabSize;

  /// Header buttons: 40 rounded squares (12 corner) inside a 44 hit area.
  static const double iconButton = NumayaSizeTokens.withingsHeaderButton;
  static const double iconButtonSm = NumayaSizeTokens.iconButtonSizeSm;
  static const double chip = NumayaSizeTokens.chipHeight;
  static const double search = NumayaSizeTokens.withingsSearchHeight;
  static const double segmentHeight = NumayaSizeTokens.withingsSegmentHeight;
  static const double segmentInset = NumayaSizeTokens.withingsSegmentInset;

  /// Radio and checkbox: 22.
  static const double choice = NumayaSizeTokens.withingsChoiceSize;

  /// Interest-set emoji holder: 28 circle.
  static const double mark = NumayaSizeTokens.withingsMarkSize;

  /// Prompt-mark holder: 24 circle.
  static const double promptMark = NumayaSizeTokens.withingsPromptMarkSize;
  static const double progressSegmentWidth =
      NumayaSizeTokens.progressSegmentWidth;
  static const double progressSegmentHeight =
      NumayaSizeTokens.progressSegmentHeight;
  static const double codeCellHeight = NumayaSizeTokens.codeCellHeight;
  static const double codeCellRadius = NumayaSizeTokens.codeCellRadius;
  static const double switchWidth = NumayaSizeTokens.switchWidth;
  static const double switchHeight = NumayaSizeTokens.switchHeight;
  static const double switchThumb = NumayaSizeTokens.withingsThumbSwitch;
  static const double sliderThumb = NumayaSizeTokens.withingsThumbSlider;
  static const double avatar = NumayaSizeTokens.sizeAvatarXl;

  /// The member's own avatar on the Profile tab: about twice [avatar] (RD-15).
  static const double avatarProfile = 176;
  static const double tabBar = NumayaSizeTokens.tabBarHeight;
  static const double topBar = 56;
}

/// Shadows. V16 cards, groups and fields take none; only floating things do.
abstract final class AppElevation {
  /// The toast and anything floating over a photo.
  static const List<BoxShadow> withingsFloat =
      NumayaShadowTokens.shadowWithingsFloat;

  /// The selected segment.
  static const List<BoxShadow> segment =
      NumayaShadowTokens.shadowWithingsSegment;
  static const List<BoxShadow> thumb = NumayaShadowTokens.shadowThumb;
  static const List<BoxShadow> xs = NumayaShadowTokens.shadowXs;
  static const List<BoxShadow> sm = NumayaShadowTokens.shadowSm;
  static const List<BoxShadow> md = NumayaShadowTokens.shadowMd;
  static const List<BoxShadow> float = NumayaShadowTokens.shadowFloat;
  static const List<BoxShadow> lg = NumayaShadowTokens.shadowLg;
  static const List<BoxShadow> button = NumayaShadowTokens.shadowButton;
  static const List<BoxShadow> brand = NumayaShadowTokens.shadowBrand;
}

/// Opacity roles.
abstract final class AppOpacity {
  static const double disabled = NumayaNumberTokens.opacityDisabled;
  static const double pending = NumayaNumberTokens.opacityPending;
}
