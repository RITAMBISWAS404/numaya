import 'package:flutter/widgets.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

/// What an icon tile says about its row (final UX polish, FP-01). One hue per meaning, used the
/// same way on every screen; [neutral] is the default for ordinary settings and navigation.
enum AccentTone {
  /// Numaya itself: events, premium, your profile.
  brand,

  /// Information, location, notifications, how-it-works.
  info,

  /// Verified, active, done.
  positive,

  /// Needs attention soon; never an error.
  caution,

  /// Likes, matches, people.
  social,

  /// Blocking, reporting, deleting.
  danger,

  /// Settings and everything without a meaning of its own.
  neutral;

  /// (tint, foreground): every foreground is at least 4.5:1 on its tint.
  (Color, Color) get colors => switch (this) {
    // V4: one neutral backplate; the glyph alone carries the tone.
    brand => (AppColors.fill, AppColors.accentOnTint),
    info => (AppColors.fill, AppColors.info),
    positive => (AppColors.fill, AppColors.success),
    caution => (AppColors.fill, AppColors.warning),
    social => (AppColors.fill, AppColors.social),
    danger => (AppColors.fill, AppColors.danger),
    neutral => (AppColors.fill, AppColors.textSecondary),
  };
}

/// Ente Menu Item Icon (4055:5652): a 36pt slot ([large]: 48pt, for cards and headers) holding one
/// glyph in its meaning's colour, with no tile behind it ("the colour is on the glyph, not a
/// background"). Neutral glyphs take text/light. Decorative: the row's label says what it is.
class IconTile extends StatelessWidget {
  const IconTile(
    this.icon, {
    super.key,
    this.tone = AccentTone.neutral,
    this.large = false,
  });

  final NumayaIcons icon;
  final AccentTone tone;
  final bool large;

  /// Width of a row tile plus its gap to the text: where a row's text, and its divider, start.
  static const double rowInset = AppSizes.iconTile + AppLayout.tileLabelGap;

  @override
  Widget build(BuildContext context) {
    final (_, fg) = tone.colors;
    final size = large ? AppSizes.iconTileLg : AppSizes.iconTile;
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: NumayaIcon(
          icon,
          size: large ? AppSizes.iconLg : AppSizes.iconMd,
          color: tone == AccentTone.neutral ? AppColors.textMuted : fg,
        ),
      ),
    );
  }
}
