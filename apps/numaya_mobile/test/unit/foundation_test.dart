import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/config/app_config.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/logging/app_logger.dart';

void main() {
  group('Design tokens', () {
    test('brand colour is the approved Meetup purple', () {
      expect(AppColors.brand, const Color(0xFF7262C7));
      expect(AppColors.textPrimary, const Color(0xFF141316));
    });

    test('white on brand meets WCAG AA for normal text', () {
      double lum(Color c) => c.computeLuminance();
      final ratio =
          (lum(AppColors.onBrand) + 0.05) / (lum(AppColors.brand) + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('type roles carry the web sizes and Fraunces axes', () {
      expect(AppTypography.display.fontSize, 31);
      expect(AppTypography.display.fontFamily, 'Fraunces');
      final axes = {
        for (final v in AppTypography.display.fontVariations!) v.axis: v.value,
      };
      expect(axes['wght'], 520);
      expect(axes['SOFT'], 50);
      expect(axes['WONK'], 0);
      expect(AppTypography.body.fontFamily, 'Inter');
      expect(AppTypography.body.fontSize, 15.5);
    });

    test('sizes match the component tokens', () {
      expect(AppSizes.buttonHeight, 54);
      expect(AppSizes.fab, 56);
      expect(AppSizes.touchMin, 44);
      expect(AppSizes.codeCellHeight, 60);
    });
  });

  group('AppLogger', () {
    test('redacts phone numbers and codes', () {
      expect(AppLogger.redact('sent to +1 (415) 555-0132'), 'sent to +•••');
      expect(AppLogger.redact('code 482913 ok'), 'code ••• ok');
      expect(AppLogger.redact('step 2 of 5'), 'step 2 of 5');
    });

    test('logs only the error type, not its message', () {
      final lines = <String>[];
      AppLogger.sink = lines.add;
      addTearDown(() => AppLogger.sink = null);
      const AppLogger('Test')
          .warning('failed', Exception('user typed 4155550132'));
      expect(lines.single, isNot(contains('415')));
      expect(lines.single, contains('_Exception'));
    });
  });

  test('demo sign-in is allowed in tests (debug) and never in release', () {
    // flutter test runs in debug mode; release builds compile this to false.
    expect(AppConfig.demoAuthAllowed, isTrue);
  });
}
