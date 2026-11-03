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
    brand => (AppColors.accentTint, AppColors.accentOnTint),
    info => (AppColors.infoTint, AppColors.info),
    positive => (AppColors.successTint, AppColors.success),
    caution => (AppColors.warningTint, AppColors.warning),
    social => (AppColors.socialTint, AppColors.social),
    danger => (AppColors.dangerTint, AppColors.danger),
    neutral => (AppColors.fill, AppColors.textSecondary),
  };
}

/// A rounded-square tile holding one icon: the leading mark of a list row (40pt, 20pt icon, 12
/// corner) or of a card or header ([large]: 48pt, 22pt icon, 14 corner). Decorative: the row's
/// label says what it is.
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
    final (bg, fg) = tone.colors;
    final size = large ? AppSizes.iconTileLg : AppSizes.iconTile;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.all(
          large ? AppRadii.iconTileLg : AppRadii.iconTile,
        ),
      ),
      child: NumayaIcon(icon, size: large ? 22 : AppSizes.iconMd, color: fg),
    );
  }
}
