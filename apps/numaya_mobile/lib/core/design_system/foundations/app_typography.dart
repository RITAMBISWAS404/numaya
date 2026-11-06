import 'package:flutter/painting.dart';

import '../tokens/monochrome_tokens.dart';
import 'app_colors.dart';

/// Monochrome Meetup type: Plus Jakarta Sans for headings, names and metrics; Figtree for reading
/// text, labels and controls
/// (docs/design-experiments/monochrome-meetup/TYPOGRAPHY_GUIDELINES.md).
///
/// Bold, slightly tightened headings in the Meetup manner; regular body at a generous 1.5 line; one
/// uppercase role only (eyebrows for dates and group labels); tabular figures for metrics. Sizes
/// are logical pixels and scale with the system text size.
abstract final class AppTypography {
  static const String family = 'Figtree';

  /// Headings, names and metrics: Plus Jakarta Sans (premium refinement type trial, see
  /// docs/design-experiments/monochrome-meetup-premium/TYPOGRAPHY_GUIDELINES.md).
  static const String display = 'Plus Jakarta Sans';

  static const double regular = 400;
  static const double medium = 500;
  static const double semibold = 600;
  static const double bold = 700;
  static const double extrabold = 800;

  // Headings ----------------------------------------------------------------------------------
  // Ente text styles (Figma 10854:4420) with Numaya's families: Ente's Outfit display roles use
  // Plus Jakarta Sans, its Inter roles use Figtree. Display-1 32/40, Display-2 24/32, Display-3
  // 20/28, H1 20/28, H2 18/24, Large 16/20, Body 14/20 medium, Mini 12/16 medium. Intentional
  // exceptions (Numaya extensions): metric. Welcome now uses hero (UI-012).

  /// Display: large profile names ("Maya, 29"): 32/38 extrabold, -0.03em.
  static final TextStyle hero = _style(display, 32, 40, semibold, 0);

  /// Prominent: tab-root page titles ("Events", "Likes"): 28/34 extrabold, -0.03em.
  static final TextStyle pageTitle = _style(display, 24, 32, semibold, 0);

  /// Screen: onboarding and editorial page headings: 24/30 bold, -0.02em.
  static final TextStyle flowTitle = _style(display, 24, 32, semibold, 0);

  /// Screen: result titles and the Profile name: 24/30 bold, -0.02em.
  static final TextStyle headline = _style(display, 24, 32, semibold, 0);

  /// Section headings ("Your prompt", "Notifications"): 20/26 bold, -0.015em.
  static final TextStyle section = _style(display, 20, 28, semibold, 0);

  /// Sheet titles: 20/26 bold (the section size).
  static final TextStyle sheetTitle = _style(family, 20, 28, semibold, 0);

  /// Prompt answers: 20/26 semibold, -0.01em.
  static final TextStyle promptAnswer = _style(family, 20, 28, semibold, 0);

  /// Empty-state titles: 20/26 bold (the section size).
  static final TextStyle emptyTitle = _style(display, 20, 28, semibold, 0);

  /// Welcome headline: `clamp(36, 10.4vw, 44)`, line 1.06, bold, -0.03em.

  /// The "numaya" wordmark: bold, -0.03em, 27 (21 small).
  static TextStyle wordmark({bool small = false}) {
    final size = small ? 21.0 : 27.0;
    return _style(family, size, size, bold, -0.03);
  }

  // Text -------------------------------------------------------------------------------------
  /// Grouped-row labels: 16/22 medium.
  static final TextStyle row = _style(family, 14, 20, medium, 0);

  /// Card titles (event titles in lists, prompt questions): 18/24 bold, -0.01em.
  static final TextStyle card = _style(family, 18, 24, semibold, 0);

  /// The primary information in a content card, under its small muted label (UI-020): a bio, an
  /// answer, a distance. 18/24 medium in ink: larger than the 14pt label and the 14pt body, lighter
  /// than a heading so a paragraph stays comfortable to read.
  static final TextStyle cardPrimary = _style(family, 18, 24, medium, 0);

  /// Body copy: 16/24 regular.
  static final TextStyle body = _style(
    family,
    MonoType.bodySize,
    MonoType.bodyLine,
    medium,
    0,
  );

  /// Secondary body: 14/20 regular.
  static final TextStyle bodySm = _style(family, 14, 20, medium, 0);

  /// Field text: 16/22 regular.
  static final TextStyle input = _style(family, 14, 20, medium, 0);

  /// Full-width buttons: 16/20 semibold.
  static final TextStyle button = _style(family, 14, 20, medium, 0);

  /// Small pill buttons and pills: 14/18 semibold.
  static final TextStyle buttonSm = _style(family, 14, 20, medium, 0);

  /// Labels on chips and tiles: 14/18 medium, secondary.
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

  /// Interactive pill labels (view tabs, filters, selectable chips): Figtree 12/16 medium;
  /// selected pills use semibold (TR-03). Static fact chips share the size via [chip].
  static final TextStyle pill = _style(family, 12, 16, medium, 0);

  /// Captions and metadata: 13/18 regular, muted.
  static final TextStyle caption = _style(
    family,
    12,
    16,
    medium,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Smallest text (badges, tab labels): 12/16 medium, muted.
  static final TextStyle micro = _style(
    family,
    12,
    16,
    medium,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Modal header titles ("Edit profile"): 17/22 semibold, sentence case.
  static final TextStyle headerCaps = _style(family, 16, 20, semibold, 0);

  /// Eyebrows ("SAT, JUL 11 · 7:30 PM", "YOUR PROMPT"): 12/16 semibold, 0.06em, muted. Apply to
  /// upper-cased text.
  static final TextStyle labelCaps = _style(
    family,
    12,
    16,
    semibold,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Field and option-group labels ("First name"): 14/18 semibold, secondary, sentence case.
  static final TextStyle fieldLabel = _style(
    family,
    14,
    20,
    medium,
    0,
  ).copyWith(color: AppColors.textPrimary);

  /// Large numbers on metric cards and hero status (Bevel): 40/44 bold, tabular figures.
  static final TextStyle metric = _style(
    display,
    40,
    44,
    bold,
    -0.02,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// The unit beside a metric ("/ 100", "%"): 15/20 medium, muted.
  static final TextStyle metricUnit = _style(
    family,
    14,
    20,
    medium,
    0,
  ).copyWith(color: AppColors.textMuted);

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
