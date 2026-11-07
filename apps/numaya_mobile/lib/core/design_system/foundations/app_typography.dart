import 'package:flutter/painting.dart';

import '../tokens/monochrome_tokens.dart';
import 'app_colors.dart';

/// Numaya type roles. Two families, both variable and bundled: **Figtree** (wght 300-900) for
/// reading text, labels and controls, and **Plus Jakarta Sans** (wght 200-800) for headings,
/// names and metrics.
///
/// The hierarchy is Ente's light-mode text styles (Figma 22AeTw6QiPj2fNYHLhC7MK, Text styles
/// 10854:4420, re-read live on 2026-11-07): Display-1 32/40, Display-2 24/32, Display-3 and H1
/// 20/28, H2 18/24, Large 16/20 (all 600), Body 14/20 500, Body-Bold 14/20 600, Mini 12/16 500,
/// Tiny 10/12 500, all at 0 tracking. Ente sets these in Inter and Outfit; Numaya keeps its own
/// faces at Ente's sizes and weights (Figma type and icons pass, FT-01):
/// - **Every authored font size is an even number of logical pixels.** The earlier 13/18 caption
///   (an optical adjustment for Figtree's smaller x-height) is retired: metadata is Ente's Mini
///   12/16, and explanatory sentences that used it are [helper] at Body 14/20.
/// - [button] and [buttonSm] are Ente's Body (500), as Button Large and Button Small specify;
///   the earlier Body-Bold (600) deviation is retired.
/// - Dynamic sizes (avatar initials, the Welcome wordmark) go through [even].
/// The role map is in docs/design-experiments/ente-design-system/figma-type-icons/README.md.
///
/// Sizes are logical pixels and scale with the system text size. Every role sets its weight
/// through the `wght` axis as well as [FontWeight]; restyle a role's weight with [weight], never
/// `copyWith(fontWeight:)` alone (that keeps the old axis value; test/typography guards it).
abstract final class AppTypography {
  static const String family = 'Figtree';

  /// Headings, names and metrics.
  static const String display = 'Plus Jakarta Sans';

  static const double regular = 400;
  static const double medium = 500;
  static const double semibold = 600;
  static const double bold = 700;
  static const double extrabold = 800;

  // Headings: Plus Jakarta Sans --------------------------------------------------------------

  /// Ente Display-1. Names on photos ("Maya, 29") and Welcome: 32/40 semibold.
  static final TextStyle hero = _style(display, 32, 40, semibold, 0);

  /// Ente Display-2. Tab-root titles ("Likes", "Messages"): 24/32 semibold.
  static final TextStyle pageTitle = _style(display, 24, 32, semibold, 0);

  /// Ente Display-2. Onboarding and editorial page headings: 24/32 semibold.
  static final TextStyle flowTitle = _style(display, 24, 32, semibold, 0);

  /// Ente Display-2. Result titles and the Profile name: 24/32 semibold.
  static final TextStyle headline = _style(display, 24, 32, semibold, 0);

  /// Ente H2 (the Details sheet's "People", "Location"). Section headings inside a page
  /// ("Account", "Your tools", "Photos"): 18/24 semibold. One step under the 20pt sheet and empty
  /// titles, so a section never competes with the page's own title.
  static final TextStyle section = _style(display, 18, 24, semibold, 0);

  /// Ente Display-3. Empty-state titles: 20/28 semibold.
  static final TextStyle emptyTitle = _style(display, 20, 28, semibold, 0);

  // Headings: Figtree -------------------------------------------------------------------------

  /// Ente H1 (the Details sheet's "Details", "Create an account"). Sheet titles: 20/28 semibold.
  static final TextStyle sheetTitle = _style(family, 20, 28, semibold, 0);

  /// Prompt answers on the prompt editor: 20/28 semibold (H1 size).
  static final TextStyle promptAnswer = _style(family, 20, 28, semibold, 0);

  /// Ente H2. Card titles ("Profile 28% complete", plan names): 18/24 semibold.
  static final TextStyle card = _style(family, 18, 24, semibold, 0);

  /// The primary information in a content card, under its small muted label (UI-020): a bio, an
  /// answer. H2 size at medium: larger than the label and the body, lighter than a heading so a
  /// paragraph stays comfortable to read. 18/24 medium.
  static final TextStyle cardPrimary = _style(family, 18, 24, medium, 0);

  /// Ente Large. Top-bar titles ("Settings", "Edit profile"): 16/20 semibold, sentence case.
  static final TextStyle headerCaps = _style(family, 16, 20, semibold, 0);

  /// The "numaya" logotype: Figtree bold, -0.03em, 28 (22 small). Even sizes (FT-01; were 27
  /// and 21).
  static TextStyle wordmark({bool small = false}) {
    final size = small ? 22.0 : 28.0;
    return _style(family, size, size, bold, -0.03);
  }

  // Text: Figtree -----------------------------------------------------------------------------

  /// Ente Body. Reading text: 14/20 medium (`MonoType.bodySize`; the 16/24
  /// `NUMAYA_TYPE_SCALE=base` scale exists for comparison only).
  static final TextStyle body = _style(
    family,
    MonoType.bodySize,
    MonoType.bodyLine,
    medium,
    0,
  );

  /// Ente Body. Secondary body (supporting paragraphs, list text): 14/20 medium, the same face
  /// as [body]; callers set the muted or secondary colour.
  static final TextStyle bodySm = _style(family, 14, 20, medium, 0);

  /// Ente Body (menu item label). Grouped-row labels: 14/20 medium, ink.
  static final TextStyle row = _style(family, 14, 20, medium, 0);

  /// Ente Body. Typed field text: 14/20 medium; placeholders use it at regular in the muted
  /// colour.
  static final TextStyle input = _style(family, 14, 20, medium, 0);

  /// Ente Body. Full-width button labels: 14/20 medium, as Button Large (2207:41759) specifies.
  static final TextStyle button = _style(family, 14, 20, medium, 0);

  /// Ente Body. Small pill buttons ("Complete profile", "Add a prompt"): 14/20 medium, as Button
  /// Small (2207:41578) specifies.
  static final TextStyle buttonSm = _style(family, 14, 20, medium, 0);

  /// Labels on chips and tiles: 14/20 medium, secondary.
  static final TextStyle label = _style(
    family,
    14,
    20,
    medium,
    0,
  ).copyWith(color: AppColors.textSecondary);

  /// Informational chips (profile facts, shared interests): the 12/16 [pill] size in ink,
  /// because the chip's text is the content. One chip type size across the app.
  static final TextStyle chip = pill.copyWith(color: AppColors.ink);

  /// Ente Mini. Selectable chip labels (Ente Filter Chip 9524:4352): 12/16 medium in both states;
  /// the selected chip changes fill and colour, not weight. Static fact chips share the size via
  /// [chip]. View tabs are Ente's Tag chip and use [bodySm] (14).
  static final TextStyle pill = _style(family, 12, 16, medium, 0);

  /// Ente Mini. Metadata, timestamps, row details, counters, banner bodies and field notes:
  /// 12/16 medium, secondary (#666: 5.74:1 on white, 5.22:1 on the canvas, 4.77:1 on the field
  /// fill). Was 13/18 before FT-01.
  static final TextStyle caption = _style(
    family,
    12,
    16,
    medium,
    0,
  ).copyWith(color: AppColors.textSecondary);

  /// Ente Body in `text/light`. Explanatory sentences that stand on their own: the note under a
  /// list card, a sheet's helper line, a tip under a step. 14/20 medium, secondary (#666). These
  /// used the 13pt caption before FT-01; at Ente's Mini 12 a whole sentence was too small, so
  /// they take the body size and keep the grey that marks them as supporting.
  static final TextStyle helper = _style(
    family,
    14,
    20,
    medium,
    0,
  ).copyWith(color: AppColors.textSecondary);

  /// Ente Mini. The smallest text (count badges, photo-slot numbers): 12/16 medium, muted.
  static final TextStyle micro = _style(
    family,
    12,
    16,
    medium,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Eyebrows ("CHOOSE A PLAN", "SAT, JUL 11"): 12/16 semibold, +0.04em, muted. Apply to
  /// upper-cased text; the tracking opens capitals that would otherwise sit tight at 12pt.
  static final TextStyle labelCaps = _style(
    family,
    12,
    16,
    semibold,
    0.04,
  ).copyWith(color: AppColors.textMuted);

  /// Ente Body (the Create-account field labels). Field and option-group labels ("First name"):
  /// 14/20 medium, ink, sentence case.
  static final TextStyle fieldLabel = _style(
    family,
    14,
    20,
    medium,
    0,
  ).copyWith(color: AppColors.textPrimary);

  /// Large numbers on metric cards and the visibility score (Numaya extension): Plus Jakarta Sans
  /// 40/44 bold, -0.02em, tabular figures.
  static final TextStyle metric = _style(
    display,
    40,
    44,
    bold,
    -0.02,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// The unit beside a metric ("complete", "%"): 14/20 medium, muted.
  static final TextStyle metricUnit = _style(
    family,
    14,
    20,
    medium,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Rounds a computed font size to the nearest even logical pixel (FT-01): avatar initials and
  /// other proportional text are derived from a box size, so they go through here to keep the
  /// even-size rule. System text scaling still applies on top.
  static double even(double size) => (size / 2).roundToDouble() * 2;

  /// Returns [style] at a different variable-font weight.
  static TextStyle weight(TextStyle style, double weight) => style.copyWith(
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
      fontWeight: _nearest(w),
      fontVariations: [FontVariation('wght', w)],
      color: AppColors.textPrimary,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  static FontWeight _nearest(double w) {
    final index = ((w / 100).round() - 1).clamp(0, 8);
    return FontWeight.values[index];
  }
}
