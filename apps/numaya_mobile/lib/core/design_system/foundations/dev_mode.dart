import 'app_colors.dart';
import 'app_typography.dart';
import 'type_settings.dart';

/// The single entry point for the review build's Dev Mode comparisons (UI-085, UI-095, UI-096,
/// UI-098 and the 14/15 body size). Applying a [TypeSettings] updates the typography roles, the
/// brand palette, the button shape and the secondary surface together; the app root then rebuilds
/// every element so explicit styles follow, not only the theme. Release builds never call it with
/// anything but [TypeSettings.baseline].
abstract final class DevModeStyles {
  static TypeSettings _active = TypeSettings.baseline;

  static TypeSettings get active => _active;

  static void apply(TypeSettings settings) {
    AppTypography.apply(settings);
    AppColors.applyBrand(settings.brand.palette);
    _active = settings;
  }

  /// UI-096: every shaped button takes capsule ends.
  static bool get pillButtons => _active.shape == ButtonShape.pill;

  /// UI-098: secondary, quiet and brand buttons take the subtle neutral fill.
  static bool get filledSecondary =>
      _active.secondary == SecondarySurface.filled;
}
