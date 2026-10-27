import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/features/auth/domain/country.dart';
import 'package:numaya_mobile/features/auth/domain/phone_number.dart';

Country byIso(String iso) => kCountries.firstWhere((c) => c.iso == iso);

void main() {
  group('Country', () {
    test('counts digits in the pattern', () {
      expect(byIso('US').digitCount, 10);
      expect(byIso('SG').digitCount, 8);
      expect(byIso('AE').digitCount, 9);
    });

    test('placeholder uses 5 for the first three digits and 0 after', () {
      expect(byIso('US').placeholder, '(555) 000-0000');
      expect(byIso('GB').placeholder, '5550 000000');
    });

    test('formats partial input without a dangling separator', () {
      final us = byIso('US');
      expect(us.formatNational(''), '');
      expect(us.formatNational('4'), '(4');
      expect(us.formatNational('415'), '(415');
      expect(us.formatNational('4155'), '(415) 5');
      expect(us.formatNational('4155550132'), '(415) 555-0132');
      expect(byIso('FR').formatNational('612345678'), '6 12 34 56 78');
    });

    test('search matches name, ISO code and dial code', () {
      final de = byIso('DE');
      expect(de.matches('ger'), isTrue);
      expect(de.matches('de'), isTrue);
      expect(de.matches('+49'), isTrue);
      expect(de.matches('spain'), isFalse);
    });

    test('every country has a unique ISO code', () {
      expect(kCountries.map((c) => c.iso).toSet().length, kCountries.length);
    });
  });

  group('PhoneNumber', () {
    const empty = PhoneNumber(country: kDefaultCountry, digits: '');

    test('keeps digits only and caps them at the country length', () {
      final p = empty.withDigits('(415) 555-0132 99');
      expect(p.digits, '4155550132');
      expect(p.isComplete, isTrue);
    });

    test('changing country trims the digits to the new length', () {
      final p = empty.withDigits('4155550132').withCountry(byIso('SG'));
      expect(p.digits, '41555501');
      expect(p.isComplete, isTrue);
    });

    test('display and E.164 forms', () {
      final p = empty.withDigits('4155550132');
      expect(p.display, '+1 (415) 555-0132');
      expect(p.e164, '+14155550132');
    });

    test('toString never contains the number', () {
      final p = empty.withDigits('4155550132');
      expect(p.toString(), isNot(contains('415')));
    });
  });
}
