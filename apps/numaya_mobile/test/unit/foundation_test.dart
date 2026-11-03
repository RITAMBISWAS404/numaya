import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/config/app_config.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/logging/app_logger.dart';

void main() {
  group('Monochrome Meetup design tokens', () {
    double ratio(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      final (hi, lo) = la > lb ? (la, lb) : (lb, la);
      return (hi + 0.05) / (lo + 0.05);
    }

    test('roles point at the monochrome palette with the Numaya purple', () {
      expect(AppColors.canvas, const Color(0xFFF4F4F6));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.ink, const Color(0xFF18181B));
      // The canonical brand purple from tokens/numaya.tokens.json (purple.600).
      expect(AppColors.accent, const Color(0xFF7262C7));
      expect(AppColors.brand, AppColors.accent);
      expect(AppColors.controlSelected, AppColors.accent);
      expect(AppColors.textPrimary, AppColors.ink);
      expect(AppColors.surfacePage, AppColors.canvas);
    });

    test('the neutral ramp stays neutral (no warm stone page)', () {
      for (final c in [AppColors.canvas, AppColors.fill, AppColors.photo]) {
        final r = (c.r * 255).round(), b = (c.b * 255).round();
        // Cool or neutral: blue never below red.
        expect(b, greaterThanOrEqualTo(r));
      }
    });

    test('text colours meet WCAG AA on every surface they sit on', () {
      for (final bg in [
        AppColors.surface,
        AppColors.canvas,
        AppColors.fill,
        AppColors.accentTint,
      ]) {
        expect(ratio(AppColors.ink, bg), greaterThan(4.5));
        expect(ratio(AppColors.textSecondary, bg), greaterThan(4.5));
        expect(ratio(AppColors.textMuted, bg), greaterThan(4.5));
        expect(ratio(AppColors.accentOnTint, bg), greaterThan(4.5));
      }
      expect(
        ratio(AppColors.inkForeground, AppColors.accent),
        greaterThan(4.5),
      );
      expect(ratio(AppColors.inkForeground, AppColors.ink), greaterThan(4.5));
      expect(
        ratio(AppColors.inkForeground, AppColors.negative),
        greaterThan(4.5),
      );
      // White text on the photo panel, over the worst case (a white photo).
      final panelOnWhite = Color.alphaBlend(
        AppColors.photoPanel,
        const Color(0xFFFFFFFF),
      );
      expect(ratio(const Color(0xFFFFFFFF), panelOnWhite), greaterThan(4.5));
    });

    test('control boundaries meet 3:1', () {
      expect(ratio(AppColors.outline, AppColors.surface), greaterThan(3));
      expect(ratio(AppColors.outline, AppColors.canvas), greaterThan(3));
      expect(ratio(AppColors.accent, AppColors.surface), greaterThan(3));
      // Filled fields: placeholder and value text stay readable on the field fill.
      expect(ratio(AppColors.textMuted, AppColors.field), greaterThan(4.5));
      expect(ratio(AppColors.ink, AppColors.field), greaterThan(4.5));
      // Selected nav item: purple icon on the tint is a meaningful graphic (3:1).
      expect(
        ratio(AppColors.accentOnTint, AppColors.accentTint),
        greaterThan(3),
      );
    });

    test('Plus Jakarta Sans headings over Figtree text', () {
      expect(AppTypography.pageTitle.fontFamily, 'Plus Jakarta Sans');
      expect(AppTypography.hero.fontFamily, 'Plus Jakarta Sans');
      expect(AppTypography.metric.fontFamily, 'Plus Jakarta Sans');
      expect(AppTypography.body.fontFamily, 'Figtree');
      expect(AppTypography.button.fontFamily, 'Figtree');
      expect(AppTypography.pageTitle.fontSize, 32);
      expect(AppTypography.pageTitle.fontWeight, FontWeight.w800);
      expect(AppTypography.flowTitle.fontSize, 30);
      expect(AppTypography.section.fontSize, 21);
      expect(AppTypography.metric.fontSize, 40);
      expect(AppTypography.labelCaps.fontSize, 12);
      expect(AppTypography.body.fontSize, 16);
      expect(AppTypography.body.height, 1.5);
    });

    test('geometry follows the monochrome radii and sizes', () {
      expect(AppRadii.field, 18);
      expect(AppRadii.control, 16);
      expect(AppRadii.card, 24);
      expect(AppRadii.heroCard, 32);
      expect(AppRadii.photo, 24);
      expect(AppRadii.sheet, 32);
      expect(AppSizes.buttonHeight, 56);
      expect(AppSizes.field, 58);
      expect(AppSizes.row, 60);
      // Navigation targets meet Android's 48dp.
      expect(AppSizes.tabItem, greaterThanOrEqualTo(48));
      expect(AppSizes.iconButton, greaterThanOrEqualTo(44));
      expect(AppSizes.choice, 22);
      expect(AppSizes.touchMin, 44);
      expect(AppLayout.screenGutter, 20);
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
