import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/presentation/person_profile.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Core journey decisions (docs/design-experiments/overnight-polish/CORE_JOURNEY.md).
void main() {
  setUpAll(loadAppFonts);

  Finder inHero(Finder f) =>
      find.descendant(of: find.byType(PersonHeroCard), matching: f);

  // DX-02 is superseded by UI-015: shared interests are their own section below the photo.
  testWidgets('UI-015: shared interests are a section below the photo, once', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await quickStartApp(tester);
    expect(inHero(find.text('You both like')), findsNothing);
    final shared = find.byKey(const ValueKey('shared-interests'));
    await tester.scrollUntilVisible(
      shared,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    expect(find.text('You both like'), findsOneWidget);
    await settle(tester);
  });

  testWidgets(
    'UI-015: at 200% text on a 320pt phone the section still follows',
    (tester) async {
      await usePhoneSize(tester, size: const Size(320, 693));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await quickStartApp(tester);
      expect(inHero(find.text('You both like')), findsNothing);
      // UI-016: no decision row to keep on screen; the name is on the photo on arrival.
      expect(find.text('Maya, 29'), findsOneWidget);
      expect(tester.getRect(find.text('Maya, 29')).bottom, lessThan(693));
      await settle(tester);
    },
  );

  // DX-03 is superseded by UI-031: no Opening Moves promotion in the first release.
  testWidgets('UI-031: Messages shows no Opening Moves suggestion', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.messages);
    expect(find.text('Skip the small talk'), findsNothing);
    expect(find.text('Priya'), findsWidgets);
    await settle(tester);
  });
}
