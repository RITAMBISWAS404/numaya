import 'package:flutter/foundation.dart';

/// A country or region the phone step supports. [pattern] is the national number format, one `X`
/// per digit (ported from src/data/countries.js).
@immutable
class Country {
  const Country({
    required this.iso,
    required this.name,
    required this.dialCode,
    required this.pattern,
  });

  final String iso;
  final String name;

  /// Digits only, without "+".
  final String dialCode;
  final String pattern;

  int get digitCount => 'X'.allMatches(pattern).length;

  /// Example number for the field placeholder: first three digits 5, the rest 0.
  String get placeholder {
    var i = 0;
    return pattern.replaceAllMapped('X', (_) => (i++ < 3) ? '5' : '0');
  }

  /// Formats up to [digitCount] digits; never leaves a dangling separator.
  String formatNational(String digits) {
    if (digits.isEmpty) return '';
    final out = StringBuffer();
    var d = 0;
    for (final ch in pattern.split('')) {
      if (d >= digits.length) break;
      if (ch == 'X') {
        out.write(digits[d++]);
      } else {
        out.write(ch);
      }
    }
    return out.toString();
  }

  bool matches(String query) {
    final q = query.trim().toLowerCase().replaceAll('+', '');
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        iso.toLowerCase() == q ||
        dialCode.startsWith(q);
  }

  @override
  bool operator ==(Object other) => other is Country && other.iso == iso;

  @override
  int get hashCode => iso.hashCode;
}

/// Supported countries, in the order the web prototype lists them.
const List<Country> kCountries = [
  Country(
    iso: 'US',
    name: 'United States',
    dialCode: '1',
    pattern: '(XXX) XXX-XXXX',
  ),
  Country(
    iso: 'GB',
    name: 'United Kingdom',
    dialCode: '44',
    pattern: 'XXXX XXXXXX',
  ),
  Country(iso: 'CA', name: 'Canada', dialCode: '1', pattern: '(XXX) XXX-XXXX'),
  Country(iso: 'AU', name: 'Australia', dialCode: '61', pattern: 'XXX XXX XXX'),
  Country(iso: 'IN', name: 'India', dialCode: '91', pattern: 'XXXXX XXXXX'),
  Country(iso: 'SG', name: 'Singapore', dialCode: '65', pattern: 'XXXX XXXX'),
  Country(
    iso: 'AE',
    name: 'United Arab Emirates',
    dialCode: '971',
    pattern: 'XX XXX XXXX',
  ),
  Country(iso: 'DE', name: 'Germany', dialCode: '49', pattern: 'XXXX XXXXXXX'),
  Country(iso: 'FR', name: 'France', dialCode: '33', pattern: 'X XX XX XX XX'),
  Country(iso: 'ES', name: 'Spain', dialCode: '34', pattern: 'XXX XXX XXX'),
  Country(
    iso: 'NL',
    name: 'Netherlands',
    dialCode: '31',
    pattern: 'X XXXX XXXX',
  ),
  Country(iso: 'JP', name: 'Japan', dialCode: '81', pattern: 'XX XXXX XXXX'),
  Country(iso: 'BR', name: 'Brazil', dialCode: '55', pattern: 'XX XXXXX XXXX'),
  Country(iso: 'MX', name: 'Mexico', dialCode: '52', pattern: 'XX XXXX XXXX'),
];

/// Default country until locale-based detection is added.
const Country kDefaultCountry = Country(
  iso: 'US',
  name: 'United States',
  dialCode: '1',
  pattern: '(XXX) XXX-XXXX',
);
