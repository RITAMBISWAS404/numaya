import '../../profile/domain/profile_details.dart';

/// Height conversions for the inline height wheel (UI-006). Height is always stored in whole
/// centimetres; feet and inches are a view of it.
///
/// Rounding rule (one rule both ways): centimetres to inches rounds to the nearest whole inch, and
/// inches to centimetres rounds to the nearest whole centimetre. A value picked in either unit is
/// clamped to the existing limits ([DetailRules.minHeight] to [DetailRules.maxHeight]).
abstract final class HeightUnits {
  static const double cmPerInch = 2.54;

  /// The wheel's starting position when no height is saved. Only shown: nothing is recorded until
  /// the member moves the wheel.
  static const int defaultCm = 170;

  static int inchesFromCm(int cm) => (cm / cmPerInch).round();

  static int cmFromInches(int inches) => (inches * cmPerInch).round().clamp(
    DetailRules.minHeight,
    DetailRules.maxHeight,
  );

  /// Every whole centimetre in the supported range.
  static List<int> get cmOptions => [
    for (var cm = DetailRules.minHeight; cm <= DetailRules.maxHeight; cm++) cm,
  ];

  /// Every whole inch whose centimetre value falls in the supported range.
  static List<int> get inchOptions => [
    for (
      var i = inchesFromCm(DetailRules.minHeight);
      i <= inchesFromCm(DetailRules.maxHeight);
      i++
    )
      i,
  ];

  static ({int feet, int inches}) feetInches(int totalInches) =>
      (feet: totalInches ~/ 12, inches: totalInches % 12);
}
