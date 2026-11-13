import 'package:flutter/painting.dart';

import '../tokens/monochrome_tokens.dart';
import 'app_colors.dart';
import 'type_settings.dart';

/// Numaya type roles. Two families, both variable and bundled: **Figtree** (wght 300-900) for
/// reading text, labels and controls, and **Plus Jakarta Sans** (wght 200-800) for headings,
/// names and metrics.
///
/// The hierarchy is Ente's light-mode text styles (Figma 22AeTw6QiPj2fNYHLhC7MK, Text styles
/// 10854:4420, re-read live on 2026-11-07): Display-1 32/40, Display-2 24/32, Display-3 and H1
/// 20/28, H2 18/24, Large 16/20 (all 600), Body 14/20 500, Body-Bold 14/20 600, Mini 12/16 500,
/// Tiny 10/12 500, all at 0 tracking. Ente sets these in Inter and Outfit; Numaya keeps its own
/// faces at Ente's sizes and weights (Figma type and icons pass, FT-01):
/// - **Authored font sizes are even, with one exception: the body tier is 15** (X15, the 15px
///   experiment, 2026-11-07). Every role that was 14 (body, bodySm, row, input, buttons, label,
///   helper, fieldLabel, metricUnit) is 15 and keeps its 20pt line (multiplier 20/15). Metadata
///   stays Ente's Mini 12/16.
/// - Weights (X15-H): page titles and app-bar titles are Bold (700); buttons are SemiBold (600)
///   so actions lead the 15pt body; reading text, rows and supporting text stay Medium (500).
/// - Dynamic sizes (avatar initials, the Welcome wordmark) go through [even].
/// The role map is in docs/design-experiments/ente-design-system/figma-type-icons/README.md.
///
/// Sizes are logical pixels and scale with the system text size. Every role sets its weight
/// through the `wght` axis as well as [FontWeight]; restyle a role's weight with [weight], never
/// `copyWith(fontWeight:)` alone (that keeps the old axis value; test/typography guards it).
abstract final class AppTypography {
  /// The optional editorial comparison (replacement V8, DECISIONS T-02): Bree Serif for page-level
  /// titles and Google Sans for every functional role. Off in the recommended build; only a build
  /// with `--dart-define=NUMAYA_EDITORIAL_TYPE=true` (the gallery comparison) turns it on.
  static const bool editorial = bool.fromEnvironment('NUMAYA_EDITORIAL_TYPE');

  /// The UI family: the review build's UI font (UI-085) or Figtree.
  static String get family =>
      editorial ? 'Google Sans' : (_settings.ui.family ?? 'Figtree');

  /// The baseline heading face (headings, names and metrics). Roles in UI-085's display group
  /// take the review build's display font over it; section and app-bar titles take the UI font.
  static const String display = editorial ? 'Google Sans' : 'Plus Jakarta Sans';

  // Review-build typography (UI-085 and the 14/15 body decision) ------------------------------

  static TypeSettings _settings = TypeSettings.baseline;
  static final Map<String, TextStyle> _cache = {};

  /// The active typography settings. [TypeSettings.baseline] unless a review build applied
  /// others through the Prototype tools.
  static TypeSettings get settings => _settings;

  /// Switches every role at once. Callers rebuild the widget tree afterwards (the app root does).
  static void apply(TypeSettings settings) {
    if (settings == _settings) return;
    _settings = settings;
    _cache.clear();
  }

  /// The roles that follow the base body size: reading text, list-row labels, field text and
  /// placeholders, field labels, chip-and-tile labels and helper sentences. Headings, buttons,
  /// metadata (12pt), metrics and their units and icons keep their sizes.
  static const List<String> bodyTierRoles = [
    'body',
    'bodySm',
    'row',
    'input',
    'label',
    'helper',
    'fieldLabel',
  ];

  /// The body tier keeps its 20pt line at 14 and 15, so the A/B changes size only.
  static double get _bodySize =>
      MonoType.body14 ? _settings.bodySize.toDouble() : MonoType.bodySize;
  static double get _bodyLine => MonoType.body14 ? 20 : MonoType.bodyLine;

  static String _dsp(String baselineFace) =>
      editorial ? baselineFace : (_settings.display.family ?? baselineFace);
  static String _ui(String baselineFace) =>
      editorial ? baselineFace : (_settings.ui.family ?? baselineFace);

  static TextStyle _memo(String role, TextStyle Function() build) =>
      _cache[role] ??= build();

  /// Faces with a single real weight: never synthetically emboldened.
  static const Set<String> singleWeightFamilies = {
    serif,
    'Instrument Serif',
    'DM Serif Display',
  };

  /// The editorial comparison's title face (one real weight, 400).
  static const String serif = 'Bree Serif';

  static const double regular = 400;
  static const double medium = 500;
  static const double semibold = 600;
  static const double bold = 700;
  static const double extrabold = 800;

  // Headings: Plus Jakarta Sans --------------------------------------------------------------

  /// Ente Display-1. Names on photos ("Maya, 29") and Welcome: 32/40 semibold.
  static TextStyle get hero =>
      _memo('hero', () => _style(_dsp(display), 32, 40, bold, 0));

  /// Ente Display-2. Tab-root titles ("Likes", "Messages"): 24/32 semibold.
  static TextStyle get pageTitle =>
      _memo('pageTitle', () => _style(_dsp(display), 24, 32, bold, 0));

  /// R12 (Visual Lab V2): the expanded large title of Ente Header v2, under the leading control,
  /// collapsing into [appBarTitle]. Plus Jakarta Sans 30/36 bold.
  static TextStyle get largeTitle => _memo(
    'largeTitle',
    () => editorial
        ? _style(serif, 32, 38, regular, 0)
        : _style(_dsp(display), 30, 36, bold, 0),
  );

  /// Ente Display-2. Onboarding and editorial page headings: 24/32 semibold.
  static TextStyle get flowTitle => _memo(
    'flowTitle',
    () => editorial
        ? _style(serif, 28, 34, regular, 0)
        : _style(_dsp(display), 24, 32, bold, 0),
  );

  /// Ente Display-2. Result titles and the Profile name: 24/32 semibold.
  static TextStyle get headline =>
      _memo('headline', () => _style(_dsp(display), 24, 32, bold, 0));

  /// Ente H2 (the Details sheet's "People", "Location"). Section headings inside a page
  /// ("Account", "Your tools", "Photos"): 18/24 semibold. One step under the 20pt sheet and empty
  /// titles, so a section never competes with the page's own title.
  static TextStyle get section =>
      _memo('section', () => _style(_ui(display), 18, 24, semibold, 0));

  /// Ente Display-3. Empty-state titles: 20/28 semibold.
  static TextStyle get emptyTitle => _memo(
    'emptyTitle',
    () => editorial
        ? _style(serif, 22, 28, regular, 0)
        : _style(_dsp(display), 20, 28, semibold, 0),
  );

  // Headings: Figtree -------------------------------------------------------------------------

  /// Ente H1 (the Details sheet's "Details", "Create an account"). Sheet titles: 20/28 semibold.
  static TextStyle get sheetTitle =>
      _memo('sheetTitle', () => _style(_dsp(family), 20, 28, semibold, 0));

  /// Prompt answers on the prompt editor: 20/28 semibold (H1 size).
  static TextStyle get promptAnswer =>
      _memo('promptAnswer', () => _style(family, 20, 28, semibold, 0));

  /// Ente H2. Card titles ("Profile 28% complete", plan names): 18/24 semibold.
  static TextStyle get card =>
      _memo('card', () => _style(family, 18, 24, semibold, 0));

  /// The primary information in a content card, under its small muted label (UI-020): a bio, an
  /// answer. H2 size at medium: larger than the label and the body, lighter than a heading so a
  /// paragraph stays comfortable to read. 18/24 medium.
  static TextStyle get cardPrimary =>
      _memo('cardPrimary', () => _style(family, 18, 24, medium, 0));

  /// R07 (Visual Lab V2): what a person wrote about themselves, both the About me bio and prompt
  /// answers, in one Figtree reading role (18/26 medium). Headings stay Plus Jakarta Sans.
  static TextStyle get answer =>
      _memo('answer', () => _style(family, 18, 26, medium, 0));

  /// App-bar titles on pushed pages ("Settings", "Edit profile", a chat's name): Ente Header v2
  /// collapsed (back arrow, title inline; 11441:5188), Display-3 20/28, in Plus Jakarta Sans at
  /// Bold (X15-H). Was [headerCaps] 16/20 600, which read weaker than the 18pt section headings
  /// below it.
  static TextStyle get appBarTitle =>
      _memo('appBarTitle', () => _style(_ui(display), 20, 28, bold, 0));

  /// Ente Large. Small headings inside a page (Messages list labels, Filters questions). Was also
  /// the top-bar title before X15. 16/20 semibold, sentence case.
  static TextStyle get headerCaps =>
      _memo('headerCaps', () => _style(family, 16, 20, semibold, 0));

  /// The "numaya" logotype: Figtree bold, -0.03em, 28 (22 small). Even sizes (FT-01; were 27
  /// and 21).
  static TextStyle wordmark({bool small = false}) {
    final size = small ? 22.0 : 28.0;
    // The logotype keeps its own face in every type direction.
    return _style('Figtree', size, size, bold, -0.03);
  }

  // Text: Figtree -----------------------------------------------------------------------------

  /// Ente Body. Reading text: 14/20 medium (`MonoType.bodySize`; the 16/24
  /// `NUMAYA_TYPE_SCALE=base` scale exists for comparison only).
  static TextStyle get body =>
      _memo('body', () => _style(family, _bodySize, _bodyLine, medium, 0));

  /// Ente Body. Secondary body (supporting paragraphs, list text): 14/20 medium, the same face
  /// as [body]; callers set the muted or secondary colour.
  static TextStyle get bodySm =>
      _memo('bodySm', () => _style(family, _bodySize, _bodyLine, medium, 0));

  /// Ente Body (menu item label). Grouped-row labels: 14/20 medium, ink.
  static TextStyle get row =>
      _memo('row', () => _style(family, _bodySize, _bodyLine, medium, 0));

  /// Ente Body. Typed field text: 14/20 medium; placeholders use it at regular in the muted
  /// colour.
  static TextStyle get input =>
      _memo('input', () => _style(family, _bodySize, _bodyLine, medium, 0));

  /// Full-width button labels: 15/20 SemiBold (X15-H; Ente's Button Large is Body 14/20 500).
  static TextStyle get button =>
      _memo('button', () => _style(family, 15, 20, semibold, 0));

  /// Small pill buttons ("Complete profile", "Add a prompt"): 15/20 SemiBold (X15-H).
  static TextStyle get buttonSm =>
      _memo('buttonSm', () => _style(family, 15, 20, semibold, 0));

  /// Labels on chips and tiles: 14/20 medium, secondary.
  static TextStyle get label => _memo(
    'label',
    () => _style(
      family,
      _bodySize,
      _bodyLine,
      medium,
      0,
    ).copyWith(color: AppColors.textSecondary),
  );

  /// Informational chips (profile facts, shared interests): the 12/16 [pill] size in ink,
  /// because the chip's text is the content. One chip type size across the app.
  static TextStyle get chip =>
      _memo('chip', () => pill.copyWith(color: AppColors.ink));

  /// Ente Mini. Selectable chip labels (Ente Filter Chip 9524:4352): 12/16 medium in both states;
  /// the selected chip changes fill and colour, not weight. Static fact chips share the size via
  /// [chip]. View tabs are Ente's Tag chip and use [bodySm] (14).
  static TextStyle get pill =>
      _memo('pill', () => _style(family, 12, 16, medium, 0));

  /// Ente Mini. Metadata, timestamps, row details, counters, banner bodies and field notes:
  /// 12/16 medium, secondary (#666: 5.74:1 on white, 5.22:1 on the canvas, 4.77:1 on the field
  /// fill). Was 13/18 before FT-01.
  static TextStyle get caption => _memo(
    'caption',
    () => _style(
      family,
      12,
      16,
      medium,
      0,
    ).copyWith(color: AppColors.textSecondary),
  );

  /// Ente Body in `text/light`. Explanatory sentences that stand on their own: the note under a
  /// list card, a sheet's helper line, a tip under a step. 14/20 medium, secondary (#666). These
  /// used the 13pt caption before FT-01; at Ente's Mini 12 a whole sentence was too small, so
  /// they take the body size and keep the grey that marks them as supporting.
  static TextStyle get helper => _memo(
    'helper',
    () => _style(
      family,
      _bodySize,
      _bodyLine,
      medium,
      0,
    ).copyWith(color: AppColors.textSecondary),
  );

  /// Ente Mini. The smallest text (count badges, photo-slot numbers): 12/16 medium, muted.
  static TextStyle get micro => _memo(
    'micro',
    () =>
        _style(family, 12, 16, medium, 0).copyWith(color: AppColors.textMuted),
  );

  /// Eyebrows ("CHOOSE A PLAN", "SAT, JUL 11"): 12/16 semibold, +0.04em, muted. Apply to
  /// upper-cased text; the tracking opens capitals that would otherwise sit tight at 12pt.
  // R07 (Visual Lab V2): sentence case everywhere. The former all-caps eyebrow (12/16, +0.04em,
  // upper-cased by callers) is now a sentence-case label at 14/20 semibold with no tracking;
  // the name stays so every caller moves together.
  static TextStyle get labelCaps => _memo(
    'labelCaps',
    () => _style(
      family,
      14,
      20,
      semibold,
      0,
    ).copyWith(color: AppColors.textMuted),
  );

  /// Ente Body (the Create-account field labels). Field and option-group labels ("First name"):
  /// 14/20 medium, ink, sentence case.
  static TextStyle get fieldLabel => _memo(
    'fieldLabel',
    () => _style(
      family,
      _bodySize,
      _bodyLine,
      medium,
      0,
    ).copyWith(color: AppColors.textPrimary),
  );

  /// Large numbers on metric cards and the visibility score (Numaya extension): Plus Jakarta Sans
  /// 40/44 bold, -0.02em, tabular figures.
  static TextStyle get metric => _memo(
    'metric',
    () => _style(
      _dsp(display),
      40,
      44,
      bold,
      -0.02,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
  );

  /// The unit beside a metric ("complete", "%"): 14/20 medium, muted.
  static TextStyle get metricUnit => _memo(
    'metricUnit',
    () =>
        _style(family, 15, 20, medium, 0).copyWith(color: AppColors.textMuted),
  );

  /// Rounds a computed font size to the nearest even logical pixel (FT-01): avatar initials and
  /// other proportional text are derived from a box size, so they go through here to keep the
  /// even-size rule. System text scaling still applies on top.
  static double even(double size) => (size / 2).roundToDouble() * 2;

  /// Returns [style] at a different variable-font weight.
  static TextStyle weight(TextStyle style, double weight) =>
      singleWeightFamilies.contains(style.fontFamily)
      // Single-weight faces are never synthetically emboldened.
      ? style
      : style.copyWith(
          fontWeight: _nearest(weight),
          fontVariations: [FontVariation('wght', weight)],
        );

  static TextStyle _style(
    String face,
    double size,
    double line,
    double w,
    double em,
  ) {
    return TextStyle(
      fontFamily: face,
      fontSize: size,
      height: line / size,
      letterSpacing: em * size,
      fontWeight: singleWeightFamilies.contains(face)
          ? FontWeight.w400
          : _nearest(w),
      fontVariations: singleWeightFamilies.contains(face)
          ? null
          : [FontVariation('wght', w)],
      color: AppColors.textPrimary,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  static FontWeight _nearest(double w) {
    final index = ((w / 100).round() - 1).clamp(0, 8);
    return FontWeight.values[index];
  }
}
