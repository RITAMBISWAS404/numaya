@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Discovery's screens and states at 393 x 852 @2x, into goldens/xNN-*.png, for
/// docs/mobile/DISCOVERY_QA_REPORT.md. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture discovery', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    final dating = c.read(datingProvider.notifier);

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/x$name.png'),
      );
    }

    Future<void> tapHere(Finder f) async {
      await tester.tap(f);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Finder inline(String label) => find.descendant(
      of: find.byWidgetPredicate((w) => w is DecisionBar && !w.floating),
      matching: find.byWidgetPredicate(
        (w) => w is Pressable && w.semanticLabel == label,
      ),
    );

    Future<void> scroll(double dy) async {
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        Offset(0, -dy),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    // The first card, with the first-visit tip and the photo count.
    await shot('01-card-tip');
    await tapHere(find.bySemanticsLabel('Hide tip'));
    await shot('02-card');

    // Reading the profile: progress under the header, actions floating.
    await tapHere(find.bySemanticsLabel(RegExp('^Show more about Maya')));
    await shot('03-reading-floating-actions');
    await scroll(4000);
    await shot('04-profile-end-report');

    // Report or block from the end of the profile.
    await tapOn(tester, find.text('Report or block Maya'));
    await tester.pumpAndSettle();
    await shot('05-report-block-sheet');
    await tapOn(tester, find.text('Cancel'));
    await tester.pumpAndSettle();

    // Photos.
    await scroll(-8000);
    await tapHere(find.bySemanticsLabel('See Maya’s photos').first);
    await shot('06-photo-viewer');
    await tapHere(find.bySemanticsLabel('Next photo'));
    await shot('07-photo-viewer-second');
    await tapHere(find.bySemanticsLabel('Back'));

    // Pass, then Undo.
    await tapOn(tester, inline('Pass'));
    await tester.pump(const Duration(milliseconds: 400));
    await tapHere(find.bySemanticsLabel('Undo: bring back Maya'));
    await shot('08-undo-toast');
    await tester.pump(const Duration(seconds: 4));

    // Filters changed from the member's preferences.
    c
        .read(discoveryFiltersProvider.notifier)
        .save(c.read(discoveryFiltersProvider).copyWith(verifiedOnly: true));
    await tester.pump();
    await shot('09-filters-changed');
    c.read(discoveryFiltersProvider.notifier).reset();
    await tester.pump();

    // Out of people: passes can come back round.
    c.read(discoveryFiltersProvider.notifier).broaden();
    for (final p in dating.queue()) {
      dating.decide(p.id, liked: false);
    }
    await tester.pump();
    await shot('10-seen-everyone');
    dating.resetDiscovery();

    // Out of people, all liked: nothing comes back; Likes is the way on.
    for (final p in dating.queue()) {
      dating.decide(p.id, liked: true);
    }
    await tester.pump();
    await shot('11-seen-everyone-liked');

    // A connection problem that persists after a retry.
    dating.resetDiscovery();
    c.read(datingProvider.notifier).setSimulateErrors(true);
    c.read(routerProvider).go(Routes.home);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tapHere(find.text('Try again'));
    await tester.pump(const Duration(milliseconds: 800));
    await shot('12-error-still');
    c.read(datingProvider.notifier).setSimulateErrors(false);
    await tester.pump();
  });
}
