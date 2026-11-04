import 'package:flutter/painting.dart';

/// Monochrome Meetup tokens: the Flutter-only source of truth for the experimental visual system on
/// `experiment/numaya-monochrome-meetup`.
///
/// Hand-authored on purpose. The generated `numaya_tokens.g.dart` mirrors the web prototype's
/// `tokens/numaya.tokens.json`, and this experiment must not change the web. Each value's role,
/// contrast and reference are documented in
/// `docs/design-experiments/monochrome-meetup/TOKENS.md`; change both together.
abstract final class MonoColors {
  // Neutrals: a cool grey ramp (slightly violet-leaning so purple sits in it naturally).
  /// Page behind every screen: soft cool grey, never the old warm stone.
  static const Color canvas = Color(0xFFF4F4F6);

  /// Cards, rows, sheets, fields, bars.
  static const Color surface = Color(0xFFFFFFFF);

  /// Secondary surface: idle pills, segmented track, tiles, switch-off track, chips on white.
  static const Color fill = Color(0xFFECECF0);

  /// Stronger fill: photo placeholders, pressed fill, slider rail.
  static const Color fillStrong = Color(0xFFE2E2E7);

  /// Hairlines: dividers, card edges, bar edges.
  static const Color line = Color(0xFFE4E4E9);

  /// Filled form fields and filled secondary buttons: a neutral one step deeper than [fill], so
  /// it reads on white surfaces and on the canvas alike.
  static const Color field = Color(0xFFEAEAEF);

  /// Pressed state of filled neutral controls.
  static const Color fieldPressed = Color(0xFFDDDDE3);

  /// Dashed add slots, grabber, decorative strong lines (not a control boundary).
  static const Color lineStrong = Color(0xFFC7C7CE);

  /// Control boundaries that must meet 3:1: fields, unselected radios and checkboxes (3.38:1 on
  /// white, 3.07:1 on the canvas).
  static const Color outline = Color(0xFF8B8B94);

  /// Near-black charcoal: text, headings, strong icons (17.72:1 on white).
  static const Color ink = Color(0xFF18181B);

  /// Body copy and row labels (8.77:1 on white).
  static const Color text2 = Color(0xFF4A4A53);

  /// Captions, metadata, eyebrows (5.43:1 on white, 4.95:1 canvas, 4.61:1 fill, 4.78:1 tint).
  static const Color muted = Color(0xFF696972);

  /// Disabled fills and their labels (labels 3.42:1; disabled controls are exempt from 1.4.3).
  static const Color disabled = Color(0xFFE4E4E9);
  static const Color disabledText = Color(0xFF8A8A93);

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
  static const Color success = Color(0xFF2B774B);
  static const Color successSubtle = Color(0xFFE8F3EC);
  static const Color danger = Color(0xFFC8383B);
  static const Color dangerSubtle = Color(0xFFFBEDED);
  static const Color warning = Color(0xFF8A5A00);
  static const Color warningSubtle = Color(0xFFFBF3E2);

  // Semantic accents (final UX polish, FP-01): restrained hues for icon tiles, statuses and
  // illustrations only. Purple stays the one action colour. Each foreground meets 4.5:1 on its own
  // tint and on white, so it may carry a label as well as an icon.
  /// Information, location, notifications: muted blue (5.92:1 on its tint, 6.78:1 on white).
  static const Color info = Color(0xFF2C5C99);
  static const Color infoSubtle = Color(0xFFEAF0FA);

  /// Social and heart moments (likes, matches, people): muted coral (5.40:1 on its tint).
  static const Color social = Color(0xFFA8402F);
  static const Color socialSubtle = Color(0xFFFCEEEA);

  /// Separators inside grouped lists: decorative, deliberately quiet (1.18:1 on white).
  static const Color divider = Color(0xFFECECF0);

  /// Modal barrier: ink at 45%.
  static const Color scrim = Color(0x7318181B);

  /// Solid translucent panel for text over photos (replaces gradient scrims): ink at 72%. White text
  /// on it stays above 4.5:1 even over a white photo (blend ≈ #585859, 7.2:1).
  static const Color photoPanel = Color(0xB818181B);

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
  static const double tag = 8;

  /// Rounded-square icon tiles in rows (40pt tile; 14 for the 48pt one).
  static const double iconTile = 12;
  static const double iconTileLg = 14;
  static const double field = 18;
  static const double control = 16;
  static const double iconButton = 16;
  static const double tile = 18;
  static const double card = 24;
  static const double heroCard = 32;
  static const double image = 24;
  static const double sheet = 32;
  static const double dialog = 28;
  static const double pill = 999;
}

/// Sizes that change with the new rhythm.
abstract final class MonoSizes {
  static const double button = 56;
  static const double buttonSm = 40;
  static const double field = 58;
  static const double row = 60;

  /// Leading icon tiles: 40 in rows, 48 in cards and headers; the icon inside is 20 / 22.
  static const double iconTile = 40;
  static const double iconTileLg = 48;
  static const double iconButton = 46;
  static const double search = 52;
  static const double segment = 46;
  static const double segmentInset = 4;

  /// The floating icon-only navigation pill: 64 tall, 48pt targets.
  static const double tabBar = 64;
  static const double tabItem = 52;
}

/// Spacing roles on the 4pt scale (LAYOUT_GUIDELINES.md).
abstract final class MonoSpace {
  static const double gutter = 20;
  static const double section = 40;
  static const double cardPadding = 20;
  static const double heroPadding = 24;
  static const double item = 12;
  static const double field = 20;
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
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x0F18181B), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1418181B), blurRadius: 24, offset: Offset(0, 8)),
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
