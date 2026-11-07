import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/test_app.dart';

/// Figma type and icons pass (docs/design-experiments/ente-design-system/figma-type-icons/):
/// guards for even authored font sizes (FT-01), the text colour roles (FT-02), the Tabler outline
/// stroke classes (FT-03) and the light off-switch track (FT-04; see also component_cleanup_test).
void main() {
  setUpAll(loadAppFonts);

  double ratio(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
  }

  group('FT-01 even font sizes', () {
    final roles = <String, TextStyle>{
      'hero': AppTypography.hero,
      'pageTitle': AppTypography.pageTitle,
      'flowTitle': AppTypography.flowTitle,
      'headline': AppTypography.headline,
      'section': AppTypography.section,
      'emptyTitle': AppTypography.emptyTitle,
      'sheetTitle': AppTypography.sheetTitle,
      'promptAnswer': AppTypography.promptAnswer,
      'card': AppTypography.card,
      'cardPrimary': AppTypography.cardPrimary,
      'headerCaps': AppTypography.headerCaps,
      'wordmark': AppTypography.wordmark(),
      'wordmark small': AppTypography.wordmark(small: true),
      'body': AppTypography.body,
      'bodySm': AppTypography.bodySm,
      'row': AppTypography.row,
      'input': AppTypography.input,
      'button': AppTypography.button,
      'buttonSm': AppTypography.buttonSm,
      'label': AppTypography.label,
      'chip': AppTypography.chip,
      'pill': AppTypography.pill,
      'caption': AppTypography.caption,
      'helper': AppTypography.helper,
      'micro': AppTypography.micro,
      'labelCaps': AppTypography.labelCaps,
      'fieldLabel': AppTypography.fieldLabel,
      'metric': AppTypography.metric,
      'metricUnit': AppTypography.metricUnit,
    };

    test('every shared role is even except the 15pt body tier (X15), and none is under 12', () {
      for (final e in roles.entries) {
        final size = e.value.fontSize!;
        expect(
          size % 2 == 0 || size == 15,
          isTrue,
          reason: '${e.key} is $size',
        );
        expect(size, greaterThanOrEqualTo(12), reason: e.key);
      }
      // X15: every former 14pt role is 15 and keeps its 20pt line.
      for (final s in [
        AppTypography.body,
        AppTypography.bodySm,
        AppTypography.row,
        AppTypography.input,
        AppTypography.button,
        AppTypography.buttonSm,
        AppTypography.label,
        AppTypography.helper,
        AppTypography.fieldLabel,
        AppTypography.metricUnit,
      ]) {
        expect(s.fontSize, 15);
        expect(s.fontSize! * s.height!, closeTo(20, 0.001));
      }
    });

    test('Ente measured sizes and weights (Text styles 10854:4420)', () {
      double line(TextStyle s) => s.fontSize! * s.height!;
      // Mini 12/16 500 for metadata; helper 15/20 500 (X15); buttons 15/20 600 (X15-H).
      expect(AppTypography.caption.fontSize, 12);
      expect(line(AppTypography.caption), 16);
      expect(AppTypography.caption.fontWeight, FontWeight.w500);
      expect(AppTypography.helper.fontSize, 15);
      expect(line(AppTypography.helper), closeTo(20, 0.001));
      expect(AppTypography.button.fontWeight, FontWeight.w600);
      expect(AppTypography.buttonSm.fontWeight, FontWeight.w600);
      // The variable axis carries the same weight as FontWeight.
      expect(AppTypography.button.fontVariations, const [
        FontVariation('wght', 600),
      ]);
      // X15-H: page and app-bar titles are Bold; the app-bar title is Ente's Display-3 size.
      expect(AppTypography.appBarTitle.fontSize, 20);
      expect(line(AppTypography.appBarTitle), closeTo(28, 0.001));
      expect(AppTypography.appBarTitle.fontWeight, FontWeight.w700);
      expect(AppTypography.appBarTitle.fontFamily, AppTypography.display);
      expect(AppTypography.pageTitle.fontWeight, FontWeight.w700);
      expect(AppTypography.section.fontWeight, FontWeight.w600);
      expect(AppTypography.row.fontWeight, FontWeight.w500);
    });

    test('dynamic sizes round to even numbers', () {
      expect(AppTypography.even(13), 14);
      expect(AppTypography.even(26.88), 26);
      expect(AppTypography.even(40.32), 40);
      expect(AppTypography.even(15), 16);
    });

    // The token file can pass while a widget sets its own size, so the source is scanned too.
    test('no odd literal font size or emoji size anywhere in lib/', () {
      final odd = <String>[];
      final literal = RegExp(
        r'(?:fontSize:|Emoji\([^)]*size:|_style\(\s*(?:family|display),)\s*(\d+(?:\.\d+)?)\b',
      );
      final dynamicSize = RegExp(r'fontSize:\s*([^,\n]+)');
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final src = f.readAsStringSync();
        for (final m in literal.allMatches(src)) {
          final v = double.parse(m.group(1)!);
          if (v % 2 != 0 && v != 15) odd.add('${f.path}: ${m.group(0)}');
        }
        // A computed size must go through AppTypography.even, or be the Emoji's own parameter.
        for (final m in dynamicSize.allMatches(src)) {
          final expr = m.group(1)!.trim();
          final isLiteral = RegExp(r'^\d').hasMatch(expr);
          final isConditional = RegExp(r'^\w+\s*\?\s*\d+\s*:\s*\d+$')
              .hasMatch(expr);
          if (isLiteral || isConditional) {
            for (final n in RegExp(r'\d+(?:\.\d+)?').allMatches(expr)) {
              final n2 = double.parse(n.group(0)!);
              if (n2 % 2 != 0 && n2 != 15) {
                odd.add('${f.path}: fontSize: $expr');
              }
            }
            continue;
          }
          if (expr.startsWith('AppTypography.even(') || expr == 'size') {
            continue;
          }
          odd.add('${f.path}: fontSize: $expr (not rounded)');
        }
      }
      expect(odd, isEmpty);
    });
  });

  group('FT-02 text colour roles', () {
    test('primary #000, secondary and metadata #666, both at 4.5:1 on every surface', () {
      expect(AppColors.textPrimary, const Color(0xFF000000));
      expect(AppColors.textSecondary, const Color(0xFF666666));
      expect(AppColors.textMuted, AppColors.textSecondary);
      expect(AppTypography.caption.color, AppColors.textSecondary);
      expect(AppTypography.helper.color, AppColors.textSecondary);
      for (final surface in [
        AppColors.surface,
        AppColors.canvas,
        AppColors.fill,
      ]) {
        expect(
          ratio(AppColors.textSecondary, surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          ratio(AppColors.textPrimary, surface),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('semantic text colours reach 4.5:1 on white and the page', () {
      for (final c in [
        AppColors.negative,
        AppColors.success,
        AppColors.warning,
        AppColors.info,
        AppColors.accentOnTint,
      ]) {
        expect(ratio(c, AppColors.surface), greaterThanOrEqualTo(4.5));
        expect(ratio(c, AppColors.canvas), greaterThanOrEqualTo(4.5));
      }
    });

    testWidgets('a destructive row draws its icon and label in one red', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListRow(
              label: 'Delete account',
              leading: NumayaIcons.trash,
              danger: true,
              onTap: () {},
            ),
          ),
        ),
      );
      final label = tester.widget<Text>(find.text('Delete account'));
      final icon = tester.widget<NumayaIcon>(
        find.descendant(
          of: find.byType(ListRow),
          matching: find.byType(NumayaIcon),
        ),
      );
      expect(label.style!.color, AppColors.negative);
      expect(icon.color, AppColors.negative);
    });

    testWidgets('a list footnote is a helper sentence, not 12pt metadata', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListGroup(
              footnote: 'Snooze hides your profile.',
              children: [ListRow(label: 'Snooze')],
            ),
          ),
        ),
      );
      final note = tester.widget<Text>(find.text('Snooze hides your profile.'));
      expect(note.style!.fontSize, 15);
      expect(note.style!.color, AppColors.textSecondary);
    });
  });

  group('X15-I Tabler outline strokes', () {
    test('1.5 up to 24pt, 1.25 for larger art; always within 1.25-1.5', () {
      expect(tablerOutlineStroke(14), 1.5);
      expect(tablerOutlineStroke(16), 1.5);
      expect(tablerOutlineStroke(AppSizes.iconMd), 1.5);
      expect(tablerOutlineStroke(AppSizes.iconLg), 1.5);
      expect(tablerOutlineStroke(36), 1.25);
      for (var s = 8.0; s <= 64; s += 2) {
        expect(tablerOutlineStroke(s), inInclusiveRange(1.25, 1.5));
      }
    });

    test('supporting icons are the lighter control grey at 3:1 on cards and the page', () {
      expect(AppColors.iconSupporting, const Color(0xFF8A8A8A));
      expect(
        ratio(AppColors.iconSupporting, AppColors.surface),
        greaterThanOrEqualTo(3),
      );
      expect(
        ratio(AppColors.iconSupporting, AppColors.canvas),
        greaterThanOrEqualTo(3),
      );
    });

    test(
      'outline files set the stroke once on the root; filled files have none',
      () {
        final outline = Directory('assets/icons/tabler/outline').listSync();
        expect(outline, isNotEmpty);
        for (final f in outline.whereType<File>()) {
          final s = f.readAsStringSync();
          expect(
            RegExp('stroke-width=').allMatches(s).length,
            1,
            reason: f.path,
          );
          final root = RegExp(r'<svg\s[^>]*>').firstMatch(s)!.group(0)!;
          expect(root, contains('stroke-width="2"'), reason: f.path);
          expect(root, contains('stroke-linecap="round"'), reason: f.path);
          expect(root, contains('viewBox="0 0 24 24"'), reason: f.path);
        }
        for (final f in Directory(
          'assets/icons/tabler/filled',
        ).listSync().whereType<File>()) {
          expect(f.readAsStringSync(), isNot(contains('stroke-width')));
        }
      },
    );

    test('the rewrite changes only the root stroke-width', () async {
      final src = await rootBundle.loadString(
        'assets/icons/tabler/outline/settings.svg',
      );
      final out = withTablerStroke(src, 1.5);
      expect(out, contains('stroke-width="1.5"'));
      expect(out, isNot(contains('stroke-width="2"')));
      expect(out.length, src.length + 2);
      expect(withTablerStroke(src, 1), contains('stroke-width="1"'));
      // Everything after the root tag is untouched.
      final rest = src.substring(src.indexOf('>') + 1);
      expect(out.endsWith(rest), isTrue);
    });

    testWidgets('outline icons load through the stroke loader; filled do not', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Row(
            children: [
              NumayaIcon(NumayaIcons.settings, size: 20),
              NumayaIcon(NumayaIcons.flag, size: 16),
              NumayaIcon(NumayaIcons.home, size: 20, filled: true),
            ],
          ),
        ),
      );
      final loaders = tester
          .widgetList<TablerSvg>(find.byType(TablerSvg))
          .map((t) => (t.asset, isTablerOutline(t.asset), t.size))
          .toList();
      expect(loaders[0].$2, isTrue);
      expect(loaders[1].$2, isTrue);
      expect(loaders[2].$2, isFalse);
      expect(
        const TablerOutlineLoader('a.svg', stroke: 1),
        isNot(const TablerOutlineLoader('a.svg', stroke: 1.5)),
      );
    });

    test('the filled assignments are unchanged by this pass', () {
      final filled = {
        for (final e in kTablerIcons.entries)
          if (e.value.filled != null) e.key.name,
      };
      expect(filled, {
        'alert', 'bell', 'calendar', 'camera', 'cards', 'clock', 'delete', //
        'draft',
        'edit',
        'explore',
        'filter',
        'flag',
        'games',
        'heart',
        'help',
        'home',
        'image', 'info', 'interests', 'location', 'lock', 'message', 'mic',
        'nearby', 'palette', 'premium', 'public', 'settings', 'shield',
        'sparkle', 'star', 'tag', 'trash', 'user', 'verified', 'waitlist',
      });
    });
  });
}
