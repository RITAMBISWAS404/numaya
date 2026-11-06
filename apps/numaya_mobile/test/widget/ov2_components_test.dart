import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/test_app.dart';

/// Overnight v2 shared components: OV-03 (Ente Action Sheet v2) and OV-04 (Ente neutral Toast).
void main() {
  setUpAll(loadAppFonts);

  testWidgets('OV-03 action sheet: one sheet attached to the bottom, red '
      'destructive rows, a working Cancel', (tester) async {
    int? picked = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => picked = await showNumayaActionSheet(
                context: context,
                cancelLabel: 'Cancel',
                actions: const [
                  (icon: NumayaIcons.user, label: 'View', destructive: false),
                  (icon: NumayaIcons.block, label: 'Block', destructive: true),
                ],
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.backgroundColor, AppColors.surface);
    // Attached: the sheet reaches the bottom edge of the screen.
    final screen = tester.getSize(find.byType(Scaffold));
    expect(tester.getBottomLeft(find.byType(BottomSheet)).dy, screen.height);
    expect(
      tester.widget<Text>(find.text('Block')).style!.color,
      AppColors.negative,
    );
    expect(tester.widget<Text>(find.text('View')).style!.color, AppColors.ink);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(picked, isNull);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    expect(picked, 1);
  });

  testWidgets('OV-04 toast: white with ink text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => NumayaToast.show(context, 'Saved'),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.widget<Text>(find.text('Saved')).style!.color, AppColors.ink);
    final box = tester
        .widgetList<Container>(
          find.ancestor(
            of: find.text('Saved'),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .first;
    expect(box.color, AppColors.surface);
    await tester.pump(const Duration(seconds: 3));
  });
}
