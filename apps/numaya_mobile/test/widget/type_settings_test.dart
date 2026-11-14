import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

void main() {
  tearDown(() => DevModeStyles.apply(TypeSettings.baseline));

  test('baseline: current families and the 15pt body tier', () {
    DevModeStyles.apply(TypeSettings.baseline);
    expect(AppTypography.body.fontSize, 15);
    expect(AppTypography.body.fontFamily, 'Figtree');
    expect(AppTypography.pageTitle.fontFamily, 'Plus Jakarta Sans');
    expect(AppTypography.section.fontFamily, 'Plus Jakarta Sans');
    expect(AppTypography.sheetTitle.fontFamily, 'Figtree');
  });

  test('14pt changes only the body tier, at the same 20pt line', () {
    DevModeStyles.apply(const TypeSettings(bodySize: 14));
    for (final s in [
      AppTypography.body,
      AppTypography.bodySm,
      AppTypography.row,
      AppTypography.input,
      AppTypography.label,
      AppTypography.helper,
      AppTypography.fieldLabel,
    ]) {
      expect(s.fontSize, 14);
      expect(s.fontSize! * s.height!, closeTo(20, 0.001));
    }
    expect(AppTypography.button.fontSize, 15);
    expect(AppTypography.caption.fontSize, 12);
    expect(AppTypography.pageTitle.fontSize, 24);
    expect(AppTypography.metricUnit.fontSize, 15);
    expect(AppTypography.body.fontWeight, FontWeight.w500);
    expect(AppTypography.body.letterSpacing, 0);
  });

  group('UI-085 fixed pairings', () {
    test('exactly four presets, Default first', () {
      expect(FontPairing.values.map((p) => p.label), [
        'Default',
        'Halant + Nunito Sans',
        'Yeseva One + Josefin Sans',
        'Bree Serif + DM Sans',
      ]);
    });

    for (final p in FontPairing.values.skip(1)) {
      test('${p.label}: both families change together', () {
        DevModeStyles.apply(TypeSettings(pairing: p));
        // Display group.
        expect(AppTypography.hero.fontFamily, p.display);
        expect(AppTypography.pageTitle.fontFamily, p.display);
        expect(AppTypography.sheetTitle.fontFamily, p.display);
        expect(AppTypography.metric.fontFamily, p.display);
        // UI group.
        expect(AppTypography.body.fontFamily, p.ui);
        expect(AppTypography.section.fontFamily, p.ui);
        expect(AppTypography.appBarTitle.fontFamily, p.ui);
        expect(AppTypography.button.fontFamily, p.ui);
        expect(AppTypography.caption.fontFamily, p.ui);
        expect(AppTypography.family, p.ui);
        // Sizes do not move with the family.
        expect(AppTypography.pageTitle.fontSize, 24);
        expect(AppTypography.caption.fontSize, 12);
      });
    }

    test('single-weight display faces are never synthetically emboldened', () {
      for (final p in [FontPairing.yesevaJosefin, FontPairing.breeDmSans]) {
        DevModeStyles.apply(TypeSettings(pairing: p));
        final title = AppTypography.pageTitle;
        expect(title.fontWeight, FontWeight.w400, reason: p.label);
        expect(title.fontVariations, isNull);
        expect(AppTypography.weight(title, 700).fontWeight, FontWeight.w400);
      }
    });

    test('Halant uses its real static Bold for page titles', () {
      DevModeStyles.apply(
        const TypeSettings(pairing: FontPairing.halantNunito),
      );
      expect(AppTypography.pageTitle.fontWeight, FontWeight.w700);
      expect(FontPairing.halantNunito.displayWeights, contains(700));
    });
  });

  group('UI-095 brand colour', () {
    test('Default restores the verified palette; seeds are exact', () {
      DevModeStyles.apply(TypeSettings.baseline);
      expect(AppColors.accent, const Color(0xFF7262C7));
      expect(AppColors.accentOnTint, const Color(0xFF5B4BB0));
      expect(AppColors.accentTint, const Color(0xFFF1EFF9));
      DevModeStyles.apply(const TypeSettings(brand: BrandOption.periwinkle));
      expect(AppColors.accent, const Color(0xFF7E77F8));
      DevModeStyles.apply(const TypeSettings(brand: BrandOption.lilac));
      expect(AppColors.accent, const Color(0xFFA07ADD));
      expect(BrandOption.values, hasLength(3));
    });

    test('neutral and semantic roles never follow the brand', () {
      final before = [
        AppColors.canvas,
        AppColors.surface,
        AppColors.ink,
        AppColors.textSecondary,
        AppColors.negative,
        AppColors.success,
        AppColors.warning,
      ];
      for (final b in BrandOption.values) {
        DevModeStyles.apply(TypeSettings(brand: b));
        expect([
          AppColors.canvas,
          AppColors.surface,
          AppColors.ink,
          AppColors.textSecondary,
          AppColors.negative,
          AppColors.success,
          AppColors.warning,
        ], before);
      }
    });
  });

  test('UI-096 / UI-098 shape and surface switch the shared button rules', () {
    DevModeStyles.apply(TypeSettings.baseline);
    expect(NumayaButton.radiusFor(small: false), AppRadii.control);
    expect(NumayaButton.radiusFor(small: true), AppRadii.tag);
    expect(NumayaButton.outlinedSecondary, isTrue);
    DevModeStyles.apply(
      const TypeSettings(
        shape: ButtonShape.pill,
        secondary: SecondarySurface.filled,
      ),
    );
    expect(NumayaButton.radiusFor(small: false), AppRadii.pill);
    expect(NumayaButton.radiusFor(small: true), AppRadii.pill);
    expect(NumayaButton.outlinedSecondary, isFalse);
    expect(ButtonShape.values, hasLength(2), reason: 'no invented third shape');
  });

  test('settings round-trip; retired keys fall back to the baseline', () {
    const s = TypeSettings(
      pairing: FontPairing.breeDmSans,
      bodySize: 14,
      brand: BrandOption.lilac,
      shape: ButtonShape.pill,
      secondary: SecondarySurface.filled,
    );
    expect(s.toJson(), {
      'fontPairing': 'bree-serif-dm-sans',
      'baseBodySize': 14,
      'brandColor': 'a07add',
      'buttonShape': 'fully-rounded',
      'secondarySurface': 'filled',
    });
    expect(TypeSettings.fromJson(s.toJson()), s);
    expect(
      TypeSettings.fromJson({
        'displayFamily': 'fraunces',
        'uiFamily': 'manrope',
        'baseBodySize': 13,
      }),
      TypeSettings.baseline,
    );
  });
}
