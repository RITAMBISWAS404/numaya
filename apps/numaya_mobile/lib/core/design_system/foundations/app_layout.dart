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
  static const double stackGap = NumayaSizeTokens.layoutStackGap;
  static const double sectionGap = NumayaSizeTokens.layoutSectionGap;
  static const double fieldGap = NumayaSizeTokens.layoutFieldGap;

  /// Widest content column; wider screens centre it.
  static const double contentMax = NumayaSizeTokens.layoutContentMax;
}

/// Corner radii.
abstract final class AppRadii {
  static const double xs = NumayaSizeTokens.radiusXs;
  static const double sm = NumayaSizeTokens.radiusSm;
  static const double md = NumayaSizeTokens.radiusMd;
  static const double lg = NumayaSizeTokens.radiusLg;
  static const double xl = NumayaSizeTokens.radiusXl;
  static const double card = NumayaSizeTokens.radiusCard;
  static const double photo = NumayaSizeTokens.radiusPhoto;
  static const double pill = NumayaSizeTokens.radiusPill;

  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));
}

/// Stroke widths.
abstract final class AppBorders {
  static const double hairline = NumayaSizeTokens.borderHairline;
  static const double selected = NumayaSizeTokens.borderSelected;
  static const double focus = NumayaSizeTokens.borderFocus;
}

/// Component and control sizes.
abstract final class AppSizes {
  static const double control = NumayaSizeTokens.sizeControl;
  static const double touchMin = NumayaSizeTokens.sizeTouchMin;
  static const double iconSm = NumayaSizeTokens.sizeIconSm;
  static const double iconMd = NumayaSizeTokens.sizeIconMd;
  static const double iconLg = NumayaSizeTokens.sizeIconLg;
  static const double buttonHeight = NumayaSizeTokens.buttonHeight;
  static const double buttonHeightSm = NumayaSizeTokens.buttonHeightSm;
  static const double buttonHeightQuiet = NumayaSizeTokens.buttonHeightQuiet;
  static const double fab = NumayaSizeTokens.fabSize;
  static const double iconButton = NumayaSizeTokens.iconButtonSize;
  static const double iconButtonSm = NumayaSizeTokens.iconButtonSizeSm;
  static const double chip = NumayaSizeTokens.chipHeight;
  static const double progressSegmentWidth =
      NumayaSizeTokens.progressSegmentWidth;
  static const double progressSegmentHeight =
      NumayaSizeTokens.progressSegmentHeight;
  static const double codeCellHeight = NumayaSizeTokens.codeCellHeight;
  static const double codeCellRadius = NumayaSizeTokens.codeCellRadius;
  static const double switchWidth = NumayaSizeTokens.switchWidth;
  static const double switchHeight = NumayaSizeTokens.switchHeight;
  static const double tabBar = NumayaSizeTokens.tabBarHeight;
  static const double topBar = 56;
}

/// Shadows. Flutter has no inset shadow, so the 1px highlight inside primary buttons is omitted.
abstract final class AppElevation {
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
