import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/test_app.dart';

/// Spacing pass (docs/design-experiments/overnight-polish/SPACING_AND_SHAPE.md): the same pill or
/// badge variant has the same geometry wherever it appears (SP-02).
void main() {
  setUpAll(loadAppFonts);

  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  double gap(WidgetTester tester, Finder a, Finder b) =>
      tester.getRect(b).left - tester.getRect(a).right;

  testWidgets(
    'selectable chip: 12pt insets, 4pt icon gap, 36pt pill, 44pt target',
    (tester) async {
      await tester.pumpWidget(
        host(NumayaChip(label: 'Jazz', selected: false, onTap: () {})),
      );
      final chip = tester.getRect(find.byType(NumayaChip));
      final label = tester.getRect(find.text('Jazz'));
      final icon = find.byType(NumayaIcon).last;
      expect(label.left - chip.left, closeTo(AppLayout.pillInsetX, 0.5));
      expect(gap(tester, find.text('Jazz'), icon), closeTo(4, 0.5));
      expect(
        chip.right - tester.getRect(icon).right,
        closeTo(AppLayout.pillInsetX, 0.5),
      );
      expect(chip.height, greaterThanOrEqualTo(AppSizes.chip));
      expect(chip.height, greaterThanOrEqualTo(44));
    },
  );

  testWidgets(
    'fact chip and status badge use their variant insets and a 4pt icon gap',
    (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoChip(label: 'Long-term', icon: NumayaIcons.heart),
              StatusBadge(
                label: 'Verified',
                icon: NumayaIcons.verified,
                tone: BadgeTone.brand,
              ),
            ],
          ),
        ),
      );
      final infoIcon = find.descendant(
        of: find.byType(InfoChip),
        matching: find.byType(NumayaIcon),
      );
      final badgeIcon = find.descendant(
        of: find.byType(StatusBadge),
        matching: find.byType(NumayaIcon),
      );
      expect(gap(tester, infoIcon, find.text('Long-term')), closeTo(4, 0.5));
      expect(gap(tester, badgeIcon, find.text('Verified')), closeTo(4, 0.5));
      expect(
        tester.getRect(infoIcon).left -
            tester.getRect(find.byType(InfoChip)).left,
        closeTo(AppLayout.pillInsetX, 0.5),
      );
      expect(
        tester.getRect(badgeIcon).left -
            tester.getRect(find.byType(StatusBadge)).left,
        closeTo(AppLayout.badgeInsetX, 0.5),
      );
    },
  );

  testWidgets('view tabs: 12pt label inset inside each 36pt pill', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        ViewTabs(
          label: 'Show',
          options: const [
            (label: 'Explore', count: null),
            (label: 'My events', count: null),
          ],
          selected: 0,
          onSelect: (_) {},
        ),
      ),
    );
    final pill = find.ancestor(
      of: find.text('Explore'),
      matching: find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxHeight == AppSizes.chip,
      ),
    );
    expect(pill, findsOneWidget);
    expect(
      tester.getRect(find.text('Explore')).left - tester.getRect(pill).left,
      closeTo(AppLayout.pillInsetX, 0.5),
    );
  });

  testWidgets(
    'view tabs: an 8pt gap between adjacent pills; edge taps pick the right one',
    (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) => ViewTabs(
              label: 'Conversations',
              options: const [
                (label: 'All', count: 3),
                (label: 'Unread', count: 1),
                (label: 'Your move', count: 2),
              ],
              selected: selected,
              onSelect: (i) => set(() => selected = i),
            ),
          ),
        ),
      );
      Rect pill(String label) => tester.getRect(
        find.ancestor(
          of: find.textContaining(label),
          matching: find.byWidgetPredicate(
            (w) =>
                w is AnimatedContainer &&
                w.constraints?.maxHeight == AppSizes.chip,
          ),
        ),
      );
      final unread = pill('Unread');
      final move = pill('Your move');
      expect(move.left - unread.right, closeTo(AppLayout.groupGap, 0.5));
      expect(unread.left - pill('All').right, closeTo(AppLayout.groupGap, 0.5));
      // Taps 2pt inside each side of the shared gap select the pill they land on.
      await tester.tapAt(Offset(unread.right - 2, unread.center.dy));
      await tester.pump(const Duration(milliseconds: 300));
      expect(selected, 1);
      await tester.tapAt(Offset(move.left + 2, move.center.dy));
      await tester.pump(const Duration(milliseconds: 300));
      expect(selected, 2);
    },
  );
}
