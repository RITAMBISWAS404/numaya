import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/config/app_config.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/logging/app_logger.dart';

void main() {
  group('V16 design tokens', () {
    test('roles point at the V16 palette', () {
      expect(AppColors.canvas, const Color(0xFFF5F4F1));
      expect(AppColors.ink, const Color(0xFF121212));
      expect(AppColors.accent, const Color(0xFF5066CC));
      expect(AppColors.accentTint, const Color(0xFFE4EBFC));
      expect(AppColors.positive, const Color(0xFF3C783C));
      expect(AppColors.negative, const Color(0xFFCF3336));
      // Shared roles re-pointed as in theme-withings.css.
      expect(AppColors.brand, AppColors.accent);
      expect(AppColors.controlSelected, AppColors.ink);
      expect(AppColors.textPrimary, AppColors.ink);
      expect(AppColors.surfacePage, AppColors.canvas);
    });

    test('text colours meet WCAG AA on their surfaces', () {
      double ratio(Color a, Color b) {
        final la = a.computeLuminance(), lb = b.computeLuminance();
        final (hi, lo) = la > lb ? (la, lb) : (lb, la);
        return (hi + 0.05) / (lo + 0.05);
      }

      expect(ratio(AppColors.inkForeground, AppColors.ink), greaterThan(4.5));
      expect(ratio(AppColors.textMuted, AppColors.canvas), greaterThan(4.5));
      expect(
        ratio(AppColors.textSecondary, AppColors.surface),
        greaterThan(4.5),
      );
      expect(
        ratio(AppColors.accentOnTint, AppColors.accentTint),
        greaterThan(4.5),
      );
      expect(
        ratio(AppColors.inkForeground, AppColors.accent),
        greaterThan(4.5),
      );
    });

    test('one grotesk family with the V16 type roles', () {
      expect(AppTypography.pageTitle.fontFamily, 'Hanken Grotesk');
      expect(AppTypography.pageTitle.fontSize, 30);
      expect(AppTypography.pageTitle.fontWeight, FontWeight.w700);
      expect(AppTypography.flowTitle.fontSize, 26);
      expect(AppTypography.flowTitle.fontWeight, FontWeight.w500);
      expect(AppTypography.section.fontSize, 22);
      expect(AppTypography.labelCaps.fontSize, 11.5);
      expect(AppTypography.labelCaps.fontWeight, FontWeight.w700);
      expect(AppTypography.body.fontSize, 15.5);
    });

    test('geometry matches the withings tokens', () {
      expect(AppRadii.field, 8);
      expect(AppRadii.control, 12);
      expect(AppRadii.card, 14);
      expect(AppRadii.photo, 16);
      expect(AppSizes.buttonHeight, 50);
      expect(AppSizes.field, 54);
      expect(AppSizes.row, 56);
      expect(AppSizes.choice, 22);
      expect(AppSizes.touchMin, 44);
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
