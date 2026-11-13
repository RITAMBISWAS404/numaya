import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

void main() {
  tearDown(() => AppTypography.apply(TypeSettings.baseline));

  test('baseline: current families and the 15pt body tier', () {
    AppTypography.apply(TypeSettings.baseline);
    expect(AppTypography.body.fontSize, 15);
    expect(AppTypography.body.fontFamily, 'Figtree');
    expect(AppTypography.pageTitle.fontFamily, 'Plus Jakarta Sans');
    expect(AppTypography.section.fontFamily, 'Plus Jakarta Sans');
    expect(AppTypography.sheetTitle.fontFamily, 'Figtree');
  });

  test('14pt changes only the body tier, at the same 20pt line', () {
    AppTypography.apply(const TypeSettings(bodySize: 14));
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
    // Not body: buttons, metadata, headings and metrics keep their sizes.
    expect(AppTypography.button.fontSize, 15);
    expect(AppTypography.caption.fontSize, 12);
    expect(AppTypography.pageTitle.fontSize, 24);
    expect(AppTypography.metricUnit.fontSize, 15);
    // Weight and tracking are unchanged by the size toggle.
    expect(AppTypography.body.fontWeight, FontWeight.w500);
    expect(AppTypography.body.letterSpacing, 0);
  });

  test('display and UI groups switch independently', () {
    AppTypography.apply(const TypeSettings(display: DisplayFace.fraunces));
    expect(AppTypography.pageTitle.fontFamily, 'Fraunces');
    expect(AppTypography.sheetTitle.fontFamily, 'Fraunces');
    expect(AppTypography.section.fontFamily, 'Plus Jakarta Sans');
    expect(AppTypography.body.fontFamily, 'Figtree');

    AppTypography.apply(const TypeSettings(ui: UiFace.manrope));
    expect(AppTypography.pageTitle.fontFamily, 'Plus Jakarta Sans');
    expect(AppTypography.section.fontFamily, 'Manrope');
    expect(AppTypography.appBarTitle.fontFamily, 'Manrope');
    expect(AppTypography.body.fontFamily, 'Manrope');
    expect(AppTypography.sheetTitle.fontFamily, 'Manrope');
    expect(AppTypography.family, 'Manrope');
  });

  test('single-weight serifs are never synthetically emboldened', () {
    for (final face in [DisplayFace.instrumentSerif, DisplayFace.dmSerifDisplay]) {
      AppTypography.apply(TypeSettings(display: face));
      final title = AppTypography.pageTitle;
      expect(title.fontWeight, FontWeight.w400);
      expect(title.fontVariations, isNull);
      expect(AppTypography.weight(title, 700).fontWeight, FontWeight.w400);
    }
  });

  test('settings round-trip through the export JSON', () {
    const s = TypeSettings(
      display: DisplayFace.dmSerifDisplay,
      ui: UiFace.poppins,
      bodySize: 14,
    );
    expect(s.toJson(), {
      'displayFamily': 'dm-serif-display',
      'uiFamily': 'poppins',
      'baseBodySize': 14,
    });
    expect(TypeSettings.fromJson(s.toJson()), s);
    expect(
      TypeSettings.fromJson({'displayFamily': 'nope', 'baseBodySize': 13}),
      TypeSettings.baseline,
    );
  });
}
