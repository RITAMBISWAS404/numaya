@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';

import '../helpers/test_app.dart';

/// The Monochrome Meetup Design Lab as one tall page (393 wide @2x), into goldens/m01-*.png, for
/// docs/design-experiments/monochrome-meetup/. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture design lab', (tester) async {
    tester.view.physicalSize = const Size(786, 9600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp());
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(routerProvider).go(Routes.designLab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/m01-design-lab.png'),
    );
    await settle(tester);
  });
}
