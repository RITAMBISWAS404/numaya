import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Monochrome Meetup type: one rounded geometric family, Figtree, for everything
/// (docs/design-experiments/monochrome-meetup/TYPOGRAPHY_GUIDELINES.md).
///
/// Bold, slightly tightened headings in the Meetup manner; regular body at a generous 1.5 line; one
/// uppercase role only (eyebrows for dates and group labels); tabular figures for metrics. Sizes
/// are logical pixels and scale with the system text size.
abstract final class AppTypography {
  static const String family = 'Figtree';

  static const double regular = 400;
  static const double medium = 500;
  static const double semibold = 600;
  static const double bold = 700;

  // Headings ----------------------------------------------------------------------------------
  /// Large profile names ("Maya, 29"): 34/40 bold, -0.02em.
  static final TextStyle hero = _style(34, 40, bold, -0.02);

  /// Tab-root page titles ("Events", "Likes"): 30/36 bold, -0.02em.
  static final TextStyle pageTitle = _style(30, 36, bold, -0.02);

  /// Onboarding and editorial page headings: 28/34 bold, -0.015em.
  static final TextStyle flowTitle = _style(28, 34, bold, -0.015);

  /// Result titles ("You're verified"): 24/30 bold, -0.01em.
  static final TextStyle headline = _style(24, 30, bold, -0.01);

  /// Section headings ("Your prompt", "Notifications"): 20/26 bold, -0.01em.
  static final TextStyle section = _style(20, 26, bold, -0.01);

  /// Sheet titles: 20/26 bold.
  static final TextStyle sheetTitle = _style(20, 26, bold, -0.01);

  /// Prompt answers: 20/27 semibold, -0.01em.
  static final TextStyle promptAnswer = _style(20, 27, semibold, -0.01);

  /// Empty-state titles: 20/26 bold.
  static final TextStyle emptyTitle = _style(20, 26, bold, -0.01);

  /// Welcome headline: `clamp(36, 10.4vw, 44)`, line 1.06, bold, -0.03em.
  static TextStyle welcomeTitle(double screenWidth) {
    final size = (screenWidth * 0.104).clamp(36.0, 44.0);
    return _style(size, size * 1.06, bold, -0.03);
  }

  /// The "numaya" wordmark: bold, -0.03em, 27 (21 small).
  static TextStyle wordmark({bool small = false}) {
    final size = small ? 21.0 : 27.0;
    return _style(size, size, bold, -0.03);
  }

  // Text -------------------------------------------------------------------------------------
  /// Grouped-row labels: 16/22 medium.
  static final TextStyle row = _style(16, 22, medium, 0);

  /// Card titles (event titles in lists, prompt questions): 17/22 bold, -0.005em.
  static final TextStyle card = _style(17, 22, bold, -0.005);

  /// Body copy: 16/24 regular.
  static final TextStyle body = _style(16, 24, regular, 0);

  /// Secondary body: 14/20 regular.
  static final TextStyle bodySm = _style(14, 20, regular, 0);

  /// Field text: 16/22 regular.
  static final TextStyle input = _style(16, 22, regular, 0);

  /// Full-width buttons: 16/20 semibold.
  static final TextStyle button = _style(16, 20, semibold, 0);

  /// Small pill buttons and pills: 14/18 semibold.
  static final TextStyle buttonSm = _style(14, 18, semibold, 0);

  /// Labels on chips and tiles: 14/18 medium, secondary.
  static final TextStyle label = _style(
    14,
    18,
    medium,
    0,
  ).copyWith(color: AppColors.textSecondary);

  /// Captions and metadata: 13/18 regular, muted.
  static final TextStyle caption = _style(
    13,
    18,
    regular,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Smallest text (badges, tab labels): 12/16 medium, muted.
  static final TextStyle micro = _style(
    12,
    16,
    medium,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Modal header titles ("Edit profile"): 17/22 semibold, sentence case.
  static final TextStyle headerCaps = _style(17, 22, semibold, -0.005);

  /// Eyebrows ("SAT, JUL 11 · 7:30 PM", "YOUR PROMPT"): 12/16 semibold, 0.06em, muted. Apply to
  /// upper-cased text.
  static final TextStyle labelCaps = _style(
    12,
    16,
    semibold,
    0.06,
  ).copyWith(color: AppColors.textMuted);

  /// Field and option-group labels ("First name"): 14/18 semibold, secondary, sentence case.
  static final TextStyle fieldLabel = _style(
    14,
    18,
    semibold,
    0,
  ).copyWith(color: AppColors.textSecondary);

  /// Large numbers on metric cards (Bevel): 32/36 bold, tabular figures.
  static final TextStyle metric = _style(
    32,
    36,
    bold,
    -0.02,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// The unit beside a metric ("/ 100", "%"): 15/20 medium, muted.
  static final TextStyle metricUnit = _style(
    15,
    20,
    medium,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Returns [style] at a different variable-font weight.
  static TextStyle weight(TextStyle style, double weight) => style.copyWith(
    fontWeight: _nearest(weight),
    fontVariations: [FontVariation('wght', weight)],
  );

  static TextStyle _style(double size, double line, double w, double em) {
    return TextStyle(
      fontFamily: family,
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
