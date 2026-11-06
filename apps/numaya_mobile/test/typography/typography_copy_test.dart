import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Typography and copy pass (docs/design-experiments/ente-design-system/typography-copy/):
/// guards for the shared type roles, the rendered weights of the bundled variable fonts, text
/// contrast on every real surface, and the large-text placements this pass fixed (TC-04 to TC-07).
void main() {
  setUpAll(loadAppFonts);

  /// 320 x 693 logical at 200% text: the narrow harness case (V3_VIEW=narrow).
  void narrow(WidgetTester tester) {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(640, 1386);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  group('type roles', () {
    test('the hierarchy steps down by purpose; body stays 14/20', () {
      double line(TextStyle s) => s.fontSize! * s.height!;
      expect(AppTypography.body.fontSize, 14);
      expect(line(AppTypography.body), 20);
      // Display-1 > Display-2 > Display-3/H1 > H2 > Large > Body > metadata > Mini.
      final ladder = [
        AppTypography.hero,
        AppTypography.pageTitle,
        AppTypography.emptyTitle,
        AppTypography.section,
        AppTypography.headerCaps,
        AppTypography.body,
        AppTypography.caption,
        AppTypography.micro,
      ];
      for (var i = 1; i < ladder.length; i++) {
        expect(
          ladder[i].fontSize!,
          lessThan(ladder[i - 1].fontSize!),
          reason: 'role $i must be smaller than role ${i - 1}',
        );
      }
      // Headings are Plus Jakarta Sans; reading text and controls are Figtree.
      for (final s in [
        AppTypography.hero,
        AppTypography.pageTitle,
        AppTypography.section,
        AppTypography.emptyTitle,
        AppTypography.metric,
      ]) {
        expect(s.fontFamily, AppTypography.display);
      }
      for (final s in [
        AppTypography.body,
        AppTypography.row,
        AppTypography.input,
        AppTypography.button,
        AppTypography.caption,
        AppTypography.sheetTitle,
        AppTypography.headerCaps,
      ]) {
        expect(s.fontFamily, AppTypography.family);
      }
      // Action labels lead the body they share a size with.
      expect(AppTypography.button.fontWeight, FontWeight.w600);
      expect(AppTypography.buttonSm.fontWeight, FontWeight.w600);
      expect(AppTypography.body.fontWeight, FontWeight.w500);
    });

    test('every role sets the wght axis to the weight it names', () {
      for (final s in [
        AppTypography.hero,
        AppTypography.pageTitle,
        AppTypography.section,
        AppTypography.sheetTitle,
        AppTypography.card,
        AppTypography.body,
        AppTypography.button,
        AppTypography.caption,
        AppTypography.labelCaps,
        AppTypography.metric,
        AppTypography.weight(AppTypography.body, AppTypography.bold),
      ]) {
        final axis = s.fontVariations!.singleWhere((v) => v.axis == 'wght');
        expect(FontWeight.values[(axis.value / 100).round() - 1], s.fontWeight);
      }
    });

    test('no screen restyles a weight without its wght axis', () {
      // `role.copyWith(fontWeight: …)` keeps the role's old wght value and renders differently
      // from `AppTypography.weight(role, …)` (measured in this pass). Any direct weight must set
      // the axis in the same call.
      final offenders = <String>[];
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        if (f.path.endsWith('app_typography.dart')) continue;
        final src = f.readAsStringSync();
        for (final m in RegExp(r'fontWeight:').allMatches(src)) {
          final window = src.substring(
            m.start,
            (m.start + 200).clamp(0, src.length),
          );
          if (!window.contains('fontVariations')) {
            offenders.add(
              '${f.path}:${'\n'.allMatches(src.substring(0, m.start)).length + 1}',
            );
          }
        }
      }
      expect(offenders, isEmpty);
    });
  });

  group('bundled fonts render distinct weights', () {
    Future<double> ink(WidgetTester tester, TextStyle style) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: ColoredBox(
                color: Colors.white,
                child: Text(
                  'Hamburgefonstiv 0123',
                  style: style.copyWith(
                    color: Colors.black,
                    fontSize: 28,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      late double coverage;
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final data = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        var sum = 0.0;
        for (var i = 0; i < data.lengthInBytes; i += 4) {
          sum += 255 - data.getUint8(i);
        }
        coverage = sum / (image.width * image.height * 255);
        image.dispose();
      });
      return coverage;
    }

    for (final family in [AppTypography.family, AppTypography.display]) {
      testWidgets('$family: regular < medium < semibold < bold', (
        tester,
      ) async {
        final weights = [
          AppTypography.regular,
          AppTypography.medium,
          AppTypography.semibold,
          AppTypography.bold,
        ];
        final measured = <double>[];
        for (final w in weights) {
          measured.add(
            await ink(
              tester,
              AppTypography.weight(TextStyle(fontFamily: family), w),
            ),
          );
        }
        for (var i = 1; i < measured.length; i++) {
          // Each step adds visible ink (over 8% more than the step below).
          expect(measured[i], greaterThan(measured[i - 1] * 1.08));
        }
      });
    }
  });

  group('contrast (WCAG AA, composited)', () {
    double ratio(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      return (la > lb ? la + 0.05 : lb + 0.05) /
          (la > lb ? lb + 0.05 : la + 0.05);
    }

    test('text colours meet 4.5:1 on every surface they sit on', () {
      const surfaces = {
        'surface': AppColors.surface,
        'canvas': AppColors.canvas,
        'field': AppColors.field,
        'fill': AppColors.fill,
        'accentTint': AppColors.accentTint,
        'dangerTint': AppColors.dangerTint,
        'successTint': AppColors.successTint,
        'warningTint': AppColors.warningTint,
        'infoTint': AppColors.infoTint,
        'socialTint': AppColors.socialTint,
      };
      const texts = {
        'ink': AppColors.ink,
        'textSecondary': AppColors.textSecondary,
        'textMuted': AppColors.textMuted,
        'accentOnTint': AppColors.accentOnTint,
        'negative': AppColors.negative,
        'positive': AppColors.positive,
        'warning': AppColors.warning,
        'info': AppColors.info,
        'social': AppColors.social,
      };
      for (final t in texts.entries) {
        for (final s in surfaces.entries) {
          expect(
            ratio(t.value, s.value),
            greaterThanOrEqualTo(4.5),
            reason: '${t.key} on ${s.key}',
          );
        }
      }
      // White labels on the filled actions.
      expect(
        ratio(AppColors.accentForeground, AppColors.accent),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        ratio(AppColors.inkForeground, AppColors.negative),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('white text on the photo panel holds over bright and dark photos', () {
      for (final photo in const [
        Color(0xFFFFFFFF), // a white wall
        Color(0xFFF5E6C8), // sand, skin, warm light
        Color(0xFFD9D9D9), // the demo's placeholder grey
        Color(0xFF808080),
        Color(0xFF000000),
      ]) {
        final panel = Color.alphaBlend(AppColors.photoPanel, photo);
        expect(
          ratio(Colors.white, panel),
          greaterThanOrEqualTo(7),
          reason: '$photo',
        );
      }
    });
  });

  group('large-text placement (320pt, 200%)', () {
    testWidgets('TC-04: a long top-bar title wraps instead of truncating', (
      tester,
    ) async {
      narrow(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.safety);
      final title = find.descendant(
        of: find.byType(NumayaTopBar),
        matching: find.byType(Text),
      );
      final paragraph = tester.renderObject<RenderParagraph>(title.first);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
      await settle(tester);
    });

    testWidgets('TC-05: the visibility score never breaks inside "28%"', (
      tester,
    ) async {
      narrow(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.visibility);
      bool hasMetric(InlineSpan root) {
        var found = false;
        root.visitChildren((span) {
          if (span.style?.fontSize == AppTypography.metric.fontSize) {
            found = true;
          }
          return !found;
        });
        return found;
      }

      final score = find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            hasMetric(w.text) &&
            w.text.toPlainText().contains('%'),
      );
      expect(score, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(score);
      // The score is the first word ("28%"), drawn in the metric role.
      final number = paragraph.text.toPlainText().split(' ').first;
      expect(number, contains('%'));
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: number.length),
      );
      expect(
        boxes.map((b) => b.top).toSet(),
        hasLength(1),
        reason: 'the number "$number" must sit on one line',
      );
      expect(tester.takeException(), isNull);
      await settle(tester);
    });

    testWidgets('TC-07: a name on a photo stays on the solid scrim', (
      tester,
    ) async {
      narrow(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.person}/maya');
      final scrim = find.byType(PhotoScrim).first;
      final panel = tester.getRect(
        find.descendant(of: scrim, matching: find.byType(Padding)).first,
      );
      final texts = find.descendant(of: scrim, matching: find.byType(RichText));
      expect(texts, findsWidgets);
      for (final e in texts.evaluate()) {
        final r = tester.getRect(find.byWidget(e.widget));
        expect(r.top, greaterThanOrEqualTo(panel.top - 0.5));
      }
      expect(tester.takeException(), isNull);
      await settle(tester);
    });

    testWidgets('TC-06: Day, Month and Year sit under the Birthday label', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NumayaTextField(label: 'First name'),
                NumayaTextField(label: 'Day', subLabel: true),
              ],
            ),
          ),
        ),
      );
      final lead = tester.widget<Text>(find.text('First name')).style!;
      final part = tester.widget<Text>(find.text('Day')).style!;
      expect(lead, AppTypography.fieldLabel);
      expect(part, AppTypography.caption);
      expect(part.fontSize!, lessThan(lead.fontSize!));
    });
  });
}
