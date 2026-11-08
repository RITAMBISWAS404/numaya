import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';

/// Ente alignment V3: shared action groups (EA-B01), picker rows (EA-L01), the owner-approved
/// semantic anchors and their derived roles (EA-C01), and the new Lab groups defaulting to O.
void main() {
  double ratio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
  }

  Widget host(Widget child, {double width = 393, double scale = 1}) =>
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(
            body: Center(
              child: SizedBox(width: width - 32, child: child),
            ),
          ),
        ),
      );

  Widget pair() => NumayaButtonGroup(
    children: [
      NumayaButton(
        key: const ValueKey('a'),
        label: 'Pass',
        small: true,
        expand: true,
        variant: NumayaButtonVariant.secondary,
        onPressed: () {},
      ),
      NumayaButton(
        key: const ValueKey('b'),
        label: 'Interested',
        small: true,
        expand: true,
        onPressed: () {},
      ),
    ],
  );

  group('EA-B01 action groups', () {
    testWidgets('peers share the width equally with a 12pt gap', (
      tester,
    ) async {
      await tester.pumpWidget(host(pair()));
      final a = tester.getRect(find.byKey(const ValueKey('a')));
      final b = tester.getRect(find.byKey(const ValueKey('b')));
      expect(a.width, closeTo(b.width, 0.5));
      expect(b.left - a.right, closeTo(NumayaButtonGroup.gap, 0.5));
      expect(a.top, b.top);
      // Together they fill the row: no arbitrary space.
      expect(a.width + b.width + NumayaButtonGroup.gap, closeTo(393 - 32, 1));
    });

    testWidgets('at 200% text on a 360pt phone the pair stacks, full width', (
      tester,
    ) async {
      await tester.pumpWidget(host(pair(), width: 360, scale: 2));
      final a = tester.getRect(find.byKey(const ValueKey('a')));
      final b = tester.getRect(find.byKey(const ValueKey('b')));
      expect(b.top, greaterThan(a.bottom));
      expect(a.width, closeTo(360 - 32, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a small button still hugs its label unless asked to fill', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          Row(
            children: [
              Expanded(
                child: NumayaButton(
                  key: const ValueKey('hug'),
                  label: 'Edit',
                  small: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      );
      // The visible surface (inside the tap target) hugs the label.
      final surface = find.descendant(
        of: find.byKey(const ValueKey('hug')),
        matching: find.byType(AnimatedContainer),
      );
      expect(tester.getSize(surface).width, lessThan(200));
    });
  });

  group('EA-L01 picker rows', () {
    testWidgets('a selected choice shows one tick, no chevron, and says so', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          ListGroup(
            children: [
              ListRow(label: 'Mumbai', selected: true, onTap: () {}),
              ListRow(label: 'Pune', selected: false, onTap: () {}),
            ],
          ),
        ),
      );
      final icons = tester
          .widgetList<NumayaIcon>(find.byType(NumayaIcon))
          .toList();
      expect(icons.where((i) => i.icon == NumayaIcons.chevronRight), isEmpty);
      expect(icons.where((i) => i.icon == NumayaIcons.verified), hasLength(1));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Mumbai')),
        containsSemantics(label: 'Mumbai', isSelected: true, isButton: true),
      );
      handle.dispose();
    });
  });

  group('EA-C01 semantic palette', () {
    test('the anchors are the owner-approved values, unchanged', () {
      expect(AppColors.errorBase, const Color(0xFFEB2D2F));
      expect(AppColors.warningBase, const Color(0xFFFF9B0F));
      expect(AppColors.successBase, const Color(0xFF0D9F61));
    });

    test('text roles reach 4.5:1 on white, the page and their own tint', () {
      for (final (fg, tint) in [
        (AppColors.danger, AppColors.dangerTint),
        (AppColors.warning, AppColors.warningTint),
        (AppColors.success, AppColors.successTint),
      ]) {
        for (final bg in [Colors.white, AppColors.canvas, tint]) {
          expect(
            ratio(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$fg on $bg',
          );
        }
      }
    });

    test('icon roles reach 3:1 on white, the page and their own tint', () {
      for (final (fg, tint) in [
        (AppColors.dangerIcon, AppColors.dangerTint),
        (AppColors.warningIcon, AppColors.warningTint),
        (AppColors.successIcon, AppColors.successTint),
      ]) {
        for (final bg in [Colors.white, AppColors.canvas, tint]) {
          expect(ratio(fg, bg), greaterThanOrEqualTo(3), reason: '$fg on $bg');
        }
      }
    });

    test('white sits only on the red role; orange carries ink', () {
      expect(
        ratio(Colors.white, AppColors.negative),
        greaterThanOrEqualTo(4.5),
      );
      expect(ratio(Colors.white, AppColors.warningBase), lessThan(3));
      expect(
        ratio(AppColors.onWarningBase, AppColors.warningBase),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  test('V3 Lab groups default to the current layout (O): nothing promoted', () {
    final v3 = kLabGroups.where((g) => g.id.startsWith('ea-')).toList();
    expect(v3.map((g) => g.id), [
      'ea-event-card',
      'ea-event-filters',
      'ea-event-action',
      'ea-met-card',
    ]);
    for (final g in v3) {
      expect(g.proposed, 'O', reason: g.id);
      expect(g.ids.first, 'O', reason: g.id);
    }
  });
}
