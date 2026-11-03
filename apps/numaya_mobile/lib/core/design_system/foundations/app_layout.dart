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

/// Monochrome corner radii (`MonoRadii`): tags 8, fields and controls 14, rounded-square icon
/// buttons 14, tiles 16, cards and images 20, dialogs 24, sheets 28; full pills for buttons,
/// filters and tabs. A nested corner is its container's minus the inset.
abstract final class AppRadii {
  static const double tag = MonoRadii.tag;
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

  /// Segmented track: a full pill; segments are pills inside it.
  static const double segment = MonoRadii.pill;

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

  /// Full-width buttons: 52.
  static const double buttonHeight = MonoSizes.button;

  /// Compact pill buttons: 38 visible inside the 44 hit area.
  static const double buttonHeightSm = MonoSizes.buttonSm;
  static const double buttonHeightQuiet = NumayaSizeTokens.buttonHeightQuiet;

  /// Text fields: 54.
  static const double field = MonoSizes.field;

  /// Grouped and selection rows: 56 minimum.
  static const double row = MonoSizes.row;
  static const double fab = NumayaSizeTokens.fabSize;

  /// Header buttons: 42 rounded squares (14 corner) inside a 44 hit area.
  static const double iconButton = MonoSizes.iconButton;
  static const double iconButtonSm = NumayaSizeTokens.iconButtonSizeSm;
  static const double chip = NumayaSizeTokens.chipHeight;
  static const double search = MonoSizes.search;
  static const double segmentHeight = MonoSizes.segment;
  static const double segmentInset = MonoSizes.segmentInset;

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
  static const double tabBar = MonoSizes.tabBar;
  static const double tabItem = MonoSizes.tabItem;
  static const double topBar = 56;
}

/// Shadows. Flat by default: cards, groups and fields take none on the grey page. Only things that
/// float (tab bar, sticky bars, toast, buttons over photos) take [floating]; [subtle] is for the
/// rare card that sits on white.
abstract final class AppElevation {
  static const List<BoxShadow> none = MonoShadows.none;
  static const List<BoxShadow> subtle = MonoShadows.subtle;
  static const List<BoxShadow> floating = MonoShadows.floating;

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
