import 'package:flutter/painting.dart';

/// Ente design-system tokens (experiment/numaya-ente-design-system): the Flutter-only source of
/// truth. Values come from the Ente Figma file (22AeTw6QiPj2fNYHLhC7MK: colours 10871:4421, type
/// 10854:4420, spacing 11107:37840, radius 11112:4508) with Numaya purple in Ente's
/// `primary/*` role. Every mapping and exception is in
/// `docs/design-experiments/ente-design-system/TOKENS.md`. Names are kept from the monochrome
/// system so the widgets did not need renaming.
///
/// Hand-authored on purpose. The generated `numaya_tokens.g.dart` mirrors the web prototype's
/// `tokens/numaya.tokens.json`, and this experiment must not change the web. Each value's role,
/// contrast and reference are documented in
/// `docs/design-experiments/monochrome-meetup/TOKENS.md`; change both together.
abstract final class MonoColors {
  // Neutrals: a cool grey ramp (slightly violet-leaning so purple sits in it naturally).
  /// Page behind every screen: soft cool grey, never the old warm stone.
  static const Color canvas = Color(0xFFF4F4F4);

  /// Cards, rows, sheets, fields, bars.
  static const Color surface = Color(0xFFFFFFFF);

  /// Secondary surface: idle pills, segmented track, tiles, switch-off track, chips on white.
  static const Color fill = Color(0xFFEAEAEA);

  /// Stronger fill: photo placeholders, pressed fill, slider rail.
  static const Color fillStrong = Color(0xFFDEDEDE);

  /// Hairlines: dividers, card edges, bar edges.
  static const Color line = Color(0xFFE0E0E0);

  /// Filled form fields and filled secondary buttons: a neutral one step deeper than [fill], so
  /// it reads on white surfaces and on the canvas alike.
  static const Color field = Color(0xFFEAEAEA);

  /// Pressed state of filled neutral controls.
  static const Color fieldPressed = Color(0xFFDEDEDE);

  /// Dashed add slots, grabber, decorative strong lines (not a control boundary).
  static const Color lineStrong = Color(0xFFD2D2D2);

  /// Control boundaries that must meet 3:1: fields, unselected radios and checkboxes (3.38:1 on
  /// white, 3.07:1 on the canvas).
  static const Color outline = Color(0xFF8A8A8A);

  /// Near-black charcoal: text, headings, strong icons (17.72:1 on white).
  static const Color ink = Color(0xFF000000);

  /// Body copy and row labels (8.77:1 on white).
  static const Color text2 = Color(0xFF1A1A1A);

  /// Captions, metadata, eyebrows (5.43:1 on white, 4.95:1 canvas, 4.61:1 fill, 4.78:1 tint).
  static const Color muted = Color(0xFF666666);

  /// Disabled fills and their labels (labels 3.42:1; disabled controls are exempt from 1.4.3).
  static const Color disabled = Color(0xFFEAEAEA);
  static const Color disabledText = Color(0xFF8A8A8A);

  /// An unselected icon that still works (the idle tabs): a light grey at 3.46:1 on white, above
  /// the 3:1 needed by meaningful non-text graphics (WCAG 1.4.11). Same value as [disabledText],
  /// a separate role so "idle" never reads as "unavailable" in code.
  static const Color iconInactive = Color(0xFF8A8A8A);

  // Purple: the Numaya brand (#7262C7, canonical in tokens/numaya.tokens.json `purple.600`).
  /// Primary actions, selected pills and segments, active tab, switch on, progress.
  static const Color brand = Color(0xFF7262C7);

  /// Pressed / hovered primary.
  static const Color brandPressed = Color(0xFF5F50B8);

  /// Purple as text or icon on light surfaces: links, selected text, badges (6.82:1 on white,
  /// 6.21:1 canvas, 6.00:1 tint). Plain brand is 4.46:1 on the canvas, short of AA for text.
  static const Color brandText = Color(0xFF5B4BB0);

  /// Subtle purple surface: badges, info cards, selected chip fill, promo cards.
  static const Color brandSubtle = Color(0xFFF1EFF9);

  /// Edge of a selected chip on the subtle surface.
  static const Color brandLine = Color(0xFFCBC4EC);
  static const Color onBrand = Color(0xFFFFFFFF);

  // States.
  static const Color success = Color(0xFF036614);
  static const Color successSubtle = Color(0xFFDDEEDF);
  static const Color danger = Color(0xFFC52E2E);
  static const Color dangerSubtle = Color(0xFFFAEBEB);
  static const Color warning = Color(0xFF8A5A00);
  static const Color warningSubtle = Color(0xFFFAF4EB);

  // Semantic accents (final UX polish, FP-01): restrained hues for icon tiles, statuses and
  // illustrations only. Purple stays the one action colour. Each foreground meets 4.5:1 on its own
  // tint and on white, so it may carry a label as well as an icon.
  /// Information, location, notifications: muted blue (5.92:1 on its tint, 6.78:1 on white).
  static const Color info = Color(0xFF0E5FD9);
  static const Color infoSubtle = Color(0xFFE7EFFA);

  /// Social and heart moments (likes, matches, people): muted coral (5.40:1 on its tint).
  static const Color social = Color(0xFFA8402F);
  static const Color socialSubtle = Color(0xFFFCEEEA);

  /// Separators inside grouped lists: decorative, deliberately quiet (1.18:1 on white).
  static const Color divider = Color(0xFFEBEBEB);

  /// Modal barrier: ink at 45%.
  static const Color scrim = Color(0x66000000);

  /// Solid translucent panel for text over photos (replaces gradient scrims): ink at 72%. White text
  /// on it stays above 4.5:1 even over a white photo (blend ≈ #585859, 7.2:1).
  static const Color photoPanel = Color(0xB8000000);

  /// Round buttons floating on photos: white at 90%.
  static const Color photoButton = Color(0xE6FFFFFF);
}

/// Frosted navigation (frosted-navigation experiment, FN-04): the only glass in the app, on the
/// floating tab bar. Content scrolls beneath it; the tint keeps unselected icons (`text2`) at
/// 5.46:1 or better even over a black photo (80% white composites to #CCCCCC there).
/// Body size (overnight polish, OP-01). The default is `body14`: a 14/20 semantic body.
/// `--dart-define=NUMAYA_TYPE_SCALE=base` reproduces the earlier 16/24 body for comparison with
/// identical data, viewport and navigation (docs/design-experiments/overnight-polish/).
abstract final class MonoType {
  static const String scale = String.fromEnvironment(
    'NUMAYA_TYPE_SCALE',
    defaultValue: 'body14',
  );
  static const bool body14 = scale != 'base';

  /// The semantic default body role (`AppTypography.body`).
  static const double bodySize = body14 ? 14 : 16;
  static const double bodyLine = body14 ? 20 : 24;
}

abstract final class MonoGlass {
  /// Gaussian blur of whatever passes beneath the bar, in logical pixels.
  static const double blur = 20;

  /// White at 80% over the blur.
  static const Color tint = Color(0xCCFFFFFF);

  /// Hairline that keeps the bar's edge visible over white content: ink at 8%.
  static const Color edge = Color(0x1418181B);

  /// Restrained top highlight (overnight polish, OP-05): a 1pt white line at 70% along the
  /// straight top edge, inset from the rounded ends. Invisible over white; over dark or busy
  /// content it reads as the lit edge of a pane. A solid line, not a gradient.
  static const Color highlight = Color(0xB3FFFFFF);
  static const double highlightInset = 24;

  /// Under the system navigation (three buttons or the gesture handle): the page colour at 95%, so
  /// Android's own controls never sit on a photo.
  static const Color systemInset = Color(0xF2F4F4F6);
}

/// Corner radii: generous, role-specific (premium TOKENS.md "Shape"). Larger surfaces take larger
/// corners; nested corners are the container's minus the inset.
abstract final class MonoRadii {
  static const double tag = 12;

  /// Ente Checkbox: radius/sm (4) on 16, scaled with the 20pt mark.
  static const double checkbox = 5;

  /// Rounded-square icon tiles in rows (40pt tile; 14 for the 48pt one).
  static const double iconTile = 12;
  static const double iconTileLg = 12;
  static const double field = 16;
  static const double control = 20;
  static const double iconButton = 12;
  static const double tile = 16;
  static const double card = 20;
  static const double heroCard = 24;
  static const double image = 16;
  static const double sheet = 24;
  static const double dialog = 20;
  static const double pill = 999;
}

/// Sizes that change with the new rhythm.
abstract final class MonoSizes {
  static const double button = 52;
  static const double buttonSm = 40;
  static const double field = 52;
  static const double row = 60;

  /// Leading icon tiles: 40 in rows, 48 in cards and headers; the icon inside is 20 / 22.
  static const double iconTile = 36;
  static const double iconTileLg = 48;
  static const double iconButton = 38;
  static const double search = 52;
  static const double segment = 44;
  static const double segmentInset = 4;

  /// The navigation bar (UC-03, UI consistency pass 2026-11-07; supersedes the Tabler MVP's
  /// square-tile geometry): a fully rounded (stadium) bar with [tabPadding] on all four sides,
  /// holding four equal item surfaces edge to edge. Each item surface is its tap target,
  /// [tabItem] tall and up to [tabItemWidth] wide (never under [tabItemMin]); inside it the
  /// selected destination's stadium pill sits [tabItemInset] in on all four sides. The bar is
  /// 8 + 48 + 8 = 64 tall; four items make a 304pt bar, and at 320pt they narrow to 68.
  static const double tabBar = 64;
  static const double tabItem = 48;
  static const double tabItemWidth = 72;
  static const double tabItemMin = 48;
  static const double tabPadding = 8;
  static const double tabItemInset = 4;

  /// Ente Toggle Switch (31 x 18) at 1.5x; Ente Checkbox and Radio (16) at 1.25x.
  static const double switchWidth = 46;
  static const double switchHeight = 27;
  static const double switchThumb = 23;
  static const double choice = 20;

  /// Ente Filter Chip (9524:4352) 40 tall; Tag Chip (2482:6479) 44 tall.
  static const double filterChip = 40;
  static const double tagChip = 44;
}

/// Spacing roles on the 4pt scale (LAYOUT_GUIDELINES.md).
abstract final class MonoSpace {
  static const double gutter = 16;
  static const double section = 24;
  static const double cardPadding = 16;
  static const double heroPadding = 20;
  static const double item = 12;
  static const double field = 16;
}

/// Elevation: flat by default. Only things that float get a shadow, and it is soft.
abstract final class MonoShadows {
  static const List<BoxShadow> none = [];

  /// Cards that need separation from a white page (grouped settings, event cards on white).
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0A18181B), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0818181B), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Floating bars and buttons over content: tab bar, sticky action bar, photo buttons, toast.
  /// Ente Nav Bar (7634:54194): drop-shadow 0 4 8.75 black at 25%.
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x40000000), blurRadius: 8.75, offset: Offset(0, 4)),
  ];

  /// The navigation bar (UI-027): a very light, soft, diffuse shadow, one definition for every
  /// consumer. Replaces the Ente nav bar's 25% drop shadow, which read heavy on the grey page.
  static const List<BoxShadow> navigation = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 6)),
  ];

  /// The selected segment in a segmented control.
  static const List<BoxShadow> segment = [
    BoxShadow(color: Color(0x1418181B), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Slider and switch thumbs.
  static const List<BoxShadow> thumb = [
    BoxShadow(color: Color(0x2918181B), blurRadius: 4, offset: Offset(0, 1)),
  ];
}
