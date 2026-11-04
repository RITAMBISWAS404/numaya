import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/presentation/person_profile.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Bumble × Meetup pass (docs/design-experiments/overnight-polish/DESIGN_CONTRACT.md).
void main() {
  setUpAll(loadAppFonts);

  testWidgets('BM-01 Verified is a tick beside the name, not a photo badge', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await usePhoneSize(tester);
    await quickStartApp(tester);
    final card = find.byType(PersonHeroCard).first;
    // No "Verified" badge on the photo.
    expect(
      find.descendant(of: card, matching: find.text('Verified')),
      findsNothing,
    );
    // Screen readers still hear it, with the name.
    expect(
      find.descendant(
        of: card,
        matching: find.bySemanticsLabel(RegExp(r'Maya, 29\s+Verified')),
      ),
      findsWidgets,
    );
    final tick = find.descendant(
      of: card,
      matching: find.byWidgetPredicate(
        (w) => w is NumayaIcon && w.icon == NumayaIcons.verified,
      ),
    );
    expect(tick, findsOneWidget);
    // The tick follows the name on its line.
    final name = tester.getRect(find.text('Maya, 29').first);
    final mark = tester.getRect(tick);
    expect(mark.left, greaterThan(name.right));
    expect(mark.center.dy, closeTo(name.center.dy, name.height / 2));
    handle.dispose();
    await settle(tester);
  });

  group('BM-02 list groups on a sheet are flush with the sheet gutter', () {
    Widget group() => ListGroup(
      children: [
        ListRow(label: 'Snooze', switchValue: false, onSwitch: (_) {}),
        ListRow(label: 'Incognito', switchValue: false, onSwitch: (_) {}),
      ],
    );

    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showNumayaSheet<void>(
                  context: context,
                  title: 'Filters',
                  closeLabel: 'Close',
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [const Text('Heading'), group()],
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('row labels start on the heading’s edge', (tester) async {
      await open(tester);
      final heading = tester.getTopLeft(find.text('Heading')).dx;
      expect(tester.getTopLeft(find.text('Snooze')).dx, heading);
      expect(tester.getTopLeft(find.text('Incognito')).dx, heading);
    });

    testWidgets('off a sheet, the group keeps its card inset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [const Text('Heading'), group()],
            ),
          ),
        ),
      );
      final heading = tester.getTopLeft(find.text('Heading')).dx;
      expect(
        tester.getTopLeft(find.text('Snooze')).dx - heading,
        AppLayout.cardPadding,
      );
    });
  });
}
