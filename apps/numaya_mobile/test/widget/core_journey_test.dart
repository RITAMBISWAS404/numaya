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

  testWidgets(
    'DX-02: shared interests sit with identity, once, before the decision',
    (tester) async {
      await usePhoneSize(tester);
      await quickStartApp(tester);
      expect(inHero(find.text('You both like')), findsOneWidget);
      // Not repeated in the profile body.
      expect(find.text('You both like'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'DX-02: above 160% text they return to the body, so actions stay visible',
    (tester) async {
      await usePhoneSize(tester, size: const Size(320, 693));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await quickStartApp(tester);
      expect(inHero(find.text('You both like')), findsNothing);
      // The decision row is on screen on arrival.
      final like = tester.getRect(find.bySemanticsLabel('Like').last);
      expect(like.bottom, lessThan(693));
      await settle(tester);
    },
  );

  testWidgets('DX-03: the Opening Moves suggestion follows the conversations', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.messages);
    final promo = find.text('Skip the small talk');
    await tester.ensureVisible(promo);
    await tester.pump();
    expect(
      tester.getTopLeft(promo).dy,
      greaterThan(tester.getTopLeft(find.text('Priya')).dy),
    );
    await settle(tester);
  });
}
