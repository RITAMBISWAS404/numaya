import 'package:flutter/painting.dart';

import '../tokens/numaya_tokens.g.dart';
import 'app_colors.dart';

typedef _S = NumayaSizeTokens;

/// V16 type: one grotesk, Hanken Grotesk, for everything (theme-withings.css "Type" rules). Bold page
/// titles, medium headings, regular body; modal headers in tracked capitals; short field labels in
/// small bold capitals. Sizes and tracking come from the `withings.type.*` tokens.
abstract final class AppTypography {
  static const String family = 'Hanken Grotesk';

  static const double regular = 400;
  static const double medium = 500;
  static const double semibold = 600;

  /// V16 sets `--font-weight-bold: 700`.
  static const double bold = 700;

  // Headings ----------------------------------------------------------------------------------
  /// Profile name, "Alex, 31": 32/38 bold.
  static final TextStyle hero = _style(
    _S.withingsTypeHeroSize,
    _S.withingsTypeHeroLine,
    bold,
    _S.withingsTypeTrackingTitle,
  );

  /// Tab-root page titles ("Likes", "Profile"): 30/36 bold.
  static final TextStyle pageTitle = _style(
    _S.withingsTypePageSize,
    _S.withingsTypePageLine,
    bold,
    _S.withingsTypeTrackingTitle,
  );

  /// Onboarding flow headings ("Let's start with the basics"): 26/32 medium.
  static final TextStyle flowTitle = _style(
    _S.withingsTypeFlowSize,
    _S.withingsTypeFlowLine,
    medium,
    _S.withingsTypeTrackingFlow,
  );

  /// Result titles ("You're verified"): 24/30 semibold.
  static final TextStyle headline = _style(
    _S.withingsTypeHeadlineSize,
    _S.withingsTypeHeadlineLine,
    semibold,
    _S.withingsTypeTrackingFlow,
  );

  /// Section and group headings ("Your prompt", "Notifications"): 22/28 medium.
  static final TextStyle section = _style(
    _S.withingsTypeSectionSize,
    _S.withingsTypeSectionLine,
    medium,
    _S.withingsTypeTrackingHeading,
  );

  /// Sheet titles and the setup list title: 20/26 medium.
  static final TextStyle sheetTitle = _style(
    _S.withingsTypeSheetSize,
    _S.withingsTypeSheetLine,
    medium,
    _S.withingsTypeTrackingHeading,
  );

  /// Prompt answers: the sheet size, semibold, flow tracking.
  static final TextStyle promptAnswer = _style(
    _S.withingsTypeSheetSize,
    _S.withingsTypeSheetLine,
    semibold,
    _S.withingsTypeTrackingFlow,
  );

  /// Empty-state titles: 18/24 semibold.
  static final TextStyle emptyTitle = _style(
    _S.withingsTypeEmptySize,
    _S.withingsTypeEmptyLine,
    semibold,
    _S.withingsTypeTrackingHeading,
  );

  /// Welcome headline: `clamp(36px, 10.4vw, 42px)`, line 1.04, bold, -0.03em.
  static TextStyle welcomeTitle(double screenWidth) {
    final size = (screenWidth * 0.104).clamp(36.0, 42.0);
    return _style(size, size * 1.04, bold, -0.03);
  }

  /// The "numaya" wordmark: bold, -0.03em, 27 (21 small).
  static TextStyle wordmark({bool small = false}) {
    final size = small ? 21.0 : 27.0;
    return _style(size, size, bold, -0.03);
  }

  // Text -------------------------------------------------------------------------------------
  /// Grouped-row labels: 16/22 regular.
  static final TextStyle row = _style(
    _S.withingsTypeRowSize,
    _S.withingsTypeRowLine,
    regular,
    0,
  );

  /// Card titles (prompt question, profile sections): 15/20 medium ink.
  static final TextStyle card = _style(
    _S.withingsTypeCardSize,
    _S.withingsTypeCardLine,
    medium,
    0,
  );
  static final TextStyle body = _style(
    _S.withingsTypeBodySize,
    _S.withingsTypeBodyLine,
    regular,
    0,
  );
  static final TextStyle bodySm = _style(
    _S.withingsTypeBodySmSize,
    _S.withingsTypeBodySmLine,
    regular,
    0,
  );

  /// Field text: the row size, regular.
  static final TextStyle input = row;

  /// Full-width buttons: 16 semibold.
  static final TextStyle button = _style(16, 20, semibold, 0);

  /// Small pill buttons: 14 medium.
  static final TextStyle buttonSm = _style(
    _S.withingsTypeButtonSmSize,
    18,
    medium,
    0,
  );
  static final TextStyle label = _style(
    _S.withingsTypeLabelSize,
    _S.withingsTypeLabelLine,
    medium,
    0,
  ).copyWith(color: AppColors.textSecondary);
  static final TextStyle caption = _style(
    _S.withingsTypeCaptionSize,
    _S.withingsTypeCaptionLine,
    regular,
    0,
  ).copyWith(color: AppColors.textMuted);
  static final TextStyle micro = _style(
    _S.withingsTypeMicroSize,
    17,
    regular,
    0,
  ).copyWith(color: AppColors.textMuted);

  /// Modal header titles ("EDIT PROFILE"): 12.5/16 bold, 0.16em. Apply to upper-cased text.
  static final TextStyle headerCaps = _style(
    _S.withingsTypeHeaderCapsSize,
    _S.withingsTypeHeaderCapsLine,
    bold,
    _S.withingsTypeTrackingHeaderCaps,
  );

  /// Field, legend and chip-set labels ("FIRST NAME"): 11.5/14 bold, 0.06em, ink.
  static final TextStyle labelCaps = _style(
    _S.withingsTypeLabelCapsSize,
    _S.withingsTypeLabelCapsLine,
    bold,
    _S.withingsTypeTrackingLabelCaps,
  );

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
