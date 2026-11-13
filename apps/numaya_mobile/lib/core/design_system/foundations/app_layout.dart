import 'package:flutter/widgets.dart';

import '../tokens/monochrome_tokens.dart';
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

  /// Screen side margin: 20 in the monochrome system (was 16), for a more spacious page.
  static const double gutter = MonoSpace.gutter;

  /// Discover's photo card sits 8pt from the edges.
  static const double gutterTight = NumayaSizeTokens.layoutGutterTight;
  static const double stackGap = NumayaSizeTokens.layoutStackGap;
  static const double sectionGap = MonoSpace.section;
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

  /// Inside cards: 20.
  static const double cardPadding = MonoSpace.cardPadding;

  /// Inside hero cards (profile header, health status): 24.
  static const double heroPadding = MonoSpace.heroPadding;

  /// Between a leading icon and its text.
  static const double iconLabelGap = AppSpacing.s2;

  // Compact controls (spacing pass, SP-02). One inset and one icon gap per variant, so the same
  // pill or badge has the same geometry wherever it appears.

  /// Icon (or emoji) to label inside a pill or badge: 4. Rows, fields and buttons use
  /// [iconLabelGap] (8).
  static const double compactIconGap = AppSpacing.s1;

  /// Pill inset (view tabs, selectable chips, fact chips): 12 across, 4 down; the 36pt height
  /// comes from `AppSizes.chip`.
  static const double pillInsetX = AppSpacing.s3;
  static const double pillInsetY = AppSpacing.s1;

  /// Badge inset (status badges, setup tags): 8 across, 4 down; badges are a smaller variant.
  static const double badgeInsetX = AppSpacing.s2;
  static const double badgeInsetY = AppSpacing.s1;

  /// Gap between siblings in a chip or badge group (Wrap spacing and run spacing): 8.
  static const double groupGap = AppSpacing.s2;

  /// Between a leading icon tile (or avatar) and its text.
  static const double tileLabelGap = AppSpacing.s3;

  /// Between metadata lines (date, place, attendance).
  static const double metaGap = AppSpacing.s1;

  /// Between form fields.
  static const double fieldGap = AppSpacing.fieldGap;

  /// Top bars and tab headers: side padding so their buttons line up with the gutter.
  static const double barPadding = AppSpacing.gutter;

  /// UC-02 (UI consistency pass): the *visible* gap between adjacent header action tiles, the 8pt
  /// header-action rule (FD-D1) applied to Ente's 38pt Icon Button tiles. Every header with
  /// trailing actions lays them out through `HeaderActions`.
  static const double headerActionGap = AppSpacing.s2;

  /// [headerActionGap] in layout terms: each action lays out as its 44pt hit box with the 38pt
  /// tile centred, so the tiles' own 3pt margins already supply 6 of the 8pt. The hit boxes stay
  /// 2pt apart and never overlap.
  static const double headerActionLayoutGap =
      headerActionGap - (AppSizes.iconButtonSlot - AppSizes.iconButton);
}

/// Media proportions, width ÷ height (RD-10, RD-12).
abstract final class AppMedia {
  /// Person photos (Discover card, photo viewer, previews): 4:3 width to height, as specified
  /// for this pass. V16 drew a portrait 3:4 card; the conflict is recorded in RD-10.
  /// UI-011: photos of people in profiles are portrait, 3:4 width to height, full content width.
  static const double personPhoto = 3 / 4;

  /// Photos sent in a chat keep their landscape frame (not a profile photo, outside UI-011).
  static const double chatPhoto = 4 / 3;

  /// Small list thumbnails (For you rows) keep their compact landscape frame: a thumbnail, not a
  /// full profile photo, so outside UI-011.
  static const double listThumbnail = 4 / 3;

  /// Event covers in lists.
  static const double eventCover = 16 / 9;
}

/// Monochrome corner radii (`MonoRadii`): tags 8, fields and controls 14, rounded-square icon
/// buttons 14, tiles 16, cards and images 20, dialogs 24, sheets 28; full pills for buttons,
/// filters and tabs. A nested corner is its container's minus the inset.
abstract final class AppRadii {
  static const double tag = MonoRadii.tag;
  static const double chip = MonoRadii.chip;
  static const double badge = MonoRadii.badge;
  static const double navShell = MonoRadii.navShell;
  static const double navItem = MonoRadii.navItem;
  static const double checkbox = MonoRadii.checkbox;
  static const double iconTile = MonoRadii.iconTile;
  static const double iconTileLg = MonoRadii.iconTileLg;
  static const double field = MonoRadii.field;
  static const double control = MonoRadii.control;
  static const double iconButton = MonoRadii.iconButton;
  static const double tile = MonoRadii.tile;
  static const double card = MonoRadii.card;
  static const double heroCard = MonoRadii.heroCard;
  static const double photo = MonoRadii.image;
  static const double sheet = MonoRadii.sheet;
  static const double dialog = MonoRadii.dialog;
  static const double pill = MonoRadii.pill;

  /// Segmented track (UI-050: pill tabs are 8 with a 12 track around a 4pt inset).
  static const double segment = MonoRadii.control;

  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));

  /// The corner of a surface inset [inset] inside one with corner [outer], so both curves share a
  /// centre: `outer - inset`, never below zero (COMPONENT_RULES "Nested corners").
  static double nested(double outer, double inset) =>
      outer - inset < 0 ? 0 : outer - inset;
}

/// Stroke widths.
abstract final class AppBorders {
  static const double hairline = NumayaSizeTokens.borderHairline;

  /// Outlined buttons: 1pt.
  static const double control = 1;
  static const double selected = NumayaSizeTokens.borderSelected;
  static const double focus = NumayaSizeTokens.borderFocus;
}

/// Component and control sizes (shared tokens plus V16's `withings.*`).
abstract final class AppSizes {
  static const double touchMin = NumayaSizeTokens.sizeTouchMin;
  static const double iconSm = NumayaSizeTokens.sizeIconSm;
  static const double iconMd = NumayaSizeTokens.sizeIconMd;
  static const double iconLg = NumayaSizeTokens.sizeIconLg;

  /// Full-width buttons: 52.
  static const double buttonHeight = MonoSizes.button;

  /// Compact pill buttons: 38 visible inside the 44 hit area.
  static const double buttonHeightSm = MonoSizes.buttonSm;
  static const double buttonHeightQuiet = NumayaSizeTokens.buttonHeightQuiet;

  /// Text fields: 54.
  static const double field = MonoSizes.field;

  /// Grouped and selection rows: 56 minimum.
  static const double row = MonoSizes.row;

  /// Leading icon tiles: 40 in rows, 48 in cards and headers.
  static const double iconTile = MonoSizes.iconTile;
  static const double iconTileLg = MonoSizes.iconTileLg;
  static const double fab = NumayaSizeTokens.fabSize;

  /// Header buttons: 42 rounded squares (14 corner) inside a 44 hit area.
  static const double iconButton = MonoSizes.iconButton;

  /// The room an icon button takes in a row: the visible 38pt Ente tile inside its 44pt hit area.
  static const double iconButtonSlot = touchMin > iconButton
      ? touchMin
      : iconButton;
  static const double iconButtonSm = NumayaSizeTokens.iconButtonSizeSm;
  static const double chip = MonoSizes.filterChip;
  static const double tagChip = MonoSizes.tagChip;
  static const double search = MonoSizes.search;
  static const double segmentHeight = MonoSizes.segment;
  static const double segmentInset = MonoSizes.segmentInset;

  /// Radio and checkbox: 22.
  static const double choice = MonoSizes.choice;

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
  static const double switchWidth = MonoSizes.switchWidth;
  static const double switchHeight = MonoSizes.switchHeight;
  static const double switchThumb = MonoSizes.switchThumb;
  static const double sliderThumb = NumayaSizeTokens.withingsThumbSlider;
  static const double avatar = NumayaSizeTokens.sizeAvatarXl;

  /// The member's own avatar in the Profile hero card (premium refinement: beside the name).
  static const double avatarProfile = 96;
  static const double tabBar = MonoSizes.tabBar;
  static const double tabItem = MonoSizes.tabItem;
  static const double tabItemWidth = MonoSizes.tabItemWidth;
  static const double tabPadding = MonoSizes.tabPadding;
  static const double tabItemMin = MonoSizes.tabItemMin;
  static const double tabItemInset = MonoSizes.tabItemInset;
  static const double topBar = 56;

  /// Tab-root headers (UC-04): Likes, Messages and Profile's title row and Discover's wordmark
  /// row share one height, so the header actions don't jump between tabs.
  static const double tabHeader = 64;
}

/// Shadows. Flat by default: cards, groups and fields take none on the grey page. Only things that
/// float (tab bar, sticky bars, toast, buttons over photos) take [floating]; [subtle] is for the
/// rare card that sits on white.
abstract final class AppElevation {
  static const List<BoxShadow> none = MonoShadows.none;
  static const List<BoxShadow> subtle = MonoShadows.subtle;
  static const List<BoxShadow> floating = MonoShadows.floating;

  /// The navigation bar only (UI-027).
  static const List<BoxShadow> navigation = MonoShadows.navigation;

  /// The toast and anything floating over a photo.
  static const List<BoxShadow> withingsFloat = MonoShadows.floating;

  /// The selected segment.
  static const List<BoxShadow> segment = MonoShadows.segment;
  static const List<BoxShadow> thumb = MonoShadows.thumb;
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
