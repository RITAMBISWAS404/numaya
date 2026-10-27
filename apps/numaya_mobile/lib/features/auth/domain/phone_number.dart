import 'package:flutter/foundation.dart';

import 'country.dart';

/// A phone number being entered: a country and its national digits.
@immutable
class PhoneNumber {
  const PhoneNumber({required this.country, required this.digits});

  final Country country;

  /// National digits only.
  final String digits;

  bool get isComplete => digits.length == country.digitCount;

  /// "+1 (415) 555-0132".
  String get display =>
      '+${country.dialCode} ${country.formatNational(digits)}';

  /// "+14155550132": what a backend receives.
  String get e164 => '+${country.dialCode}$digits';

  /// Same digits, trimmed to the new country's length.
  PhoneNumber withCountry(Country next) {
    final max = next.digitCount;
    return PhoneNumber(
      country: next,
      digits: digits.length > max ? digits.substring(0, max) : digits,
    );
  }

  PhoneNumber withDigits(String raw) {
    final clean = raw.replaceAll(RegExp(r'\D'), '');
    final max = country.digitCount;
    return PhoneNumber(
      country: country,
      digits: clean.length > max ? clean.substring(0, max) : clean,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber &&
      other.country == country &&
      other.digits == digits;

  @override
  int get hashCode => Object.hash(country, digits);

  /// Never prints the number (protects logs and crash reports).
  @override
  String toString() => 'PhoneNumber(${country.iso}, ${digits.length} digits)';
}
