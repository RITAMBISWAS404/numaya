import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/config/app_config.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/logging/app_logger.dart';

void main() {
  group('Ente design tokens (Ente experiment)', () {
    double ratio(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      final (hi, lo) = la > lb ? (la, lb) : (lb, la);
      return (hi + 0.05) / (lo + 0.05);
    }

    test('roles point at the Ente palette with the Numaya purple', () {
      // Ente background/base, fill/light, text/base (Figma 10871:4421).
      expect(AppColors.canvas, const Color(0xFFF4F4F4));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.ink, const Color(0xFF000000));
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
      // State colours as text on their own tints (banners, badges).
      expect(ratio(AppColors.danger, AppColors.dangerTint), greaterThan(4.5));
      expect(ratio(AppColors.warning, AppColors.warningTint), greaterThan(4.5));
      expect(ratio(AppColors.success, AppColors.successTint), greaterThan(4.5));
    });

    test('Plus Jakarta Sans headings over Figtree text', () {
      expect(AppTypography.pageTitle.fontFamily, 'Plus Jakarta Sans');
      expect(AppTypography.hero.fontFamily, 'Plus Jakarta Sans');
      expect(AppTypography.metric.fontFamily, 'Plus Jakarta Sans');
      expect(AppTypography.body.fontFamily, 'Figtree');
      expect(AppTypography.button.fontFamily, 'Figtree');
      // Ente text styles: Display-1 32/40, Display-2 24/32, Display-3 / H1 20/28, H2 18/24.
      expect(AppTypography.hero.fontSize, 32);
      expect(AppTypography.pageTitle.fontSize, 24);
      expect(AppTypography.pageTitle.fontWeight, FontWeight.w600);
      expect(AppTypography.flowTitle.fontSize, 24);
      expect(AppTypography.headline.fontSize, 24);
      expect(AppTypography.card.fontSize, 18);
      // Typography pass: sections are Ente H2 (18/24), a step under the 20pt sheet title.
      expect(AppTypography.section.fontSize, 18);
      expect(AppTypography.emptyTitle.fontSize, 20);
      expect(AppTypography.sheetTitle.fontSize, 20);
      expect(AppTypography.metric.fontSize, 40);
      expect(AppTypography.labelCaps.fontSize, 12);
      // Ente Body 14/20 medium for body, typing and buttons (FT-01); metadata is Ente's Mini
      // 12/16, under the body.
      expect(AppTypography.body.fontSize, 14);
      expect(AppTypography.body.height! * AppTypography.body.fontSize!, 20);
      expect(AppTypography.body.fontWeight, FontWeight.w500);
      expect(AppTypography.input.fontSize, 14);
      expect(AppTypography.button.fontSize, 14);
      expect(AppTypography.button.fontWeight, FontWeight.w500);
      expect(AppTypography.caption.fontSize, 12);
      expect(
        AppTypography.caption.height! * AppTypography.caption.fontSize!,
        16,
      );
      expect(
        AppTypography.caption.fontSize!,
        lessThan(AppTypography.body.fontSize!),
      );
    });

    test('geometry follows the Ente radii and sizes', () {
      // radius/lg 16, radius/xl 20 (11112:4508); 24 for the hero card and sheet top (NX).
      expect(AppRadii.field, 16);
      expect(AppRadii.control, 20);
      expect(AppRadii.card, 20);
      expect(AppRadii.heroCard, 24);
      expect(AppRadii.photo, 16); // nested: hero 24 minus its 8pt inset
      expect(AppRadii.sheet, 24);
      expect(AppRadii.iconButton, 12);
      // Button Large 52, Text Input 52, Menu Item 60, Icon Button 38; the nav bar is the UC-03
      // stadium: 8 + 48pt items + 8 = 64 tall.
      expect(AppSizes.buttonHeight, 52);
      expect(AppSizes.field, 52);
      expect(AppSizes.row, 60);
      expect(AppSizes.iconButton, 38);
      expect(AppSizes.tabBar, 64);
      // Visible tiles may be compact; every hit area stays at least 44 (Pressable.minSize).
      expect(AppSizes.touchMin, 44);
      expect(AppSizes.choice, 20);
      expect(AppLayout.screenGutter, 16);
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
