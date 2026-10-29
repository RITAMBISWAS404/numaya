import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Every signed-in route of the full demo, opened directly at the sizes Android users actually
/// have: a small phone with large text, and a regular phone at the largest text Android 14 offers
/// (200%). Collects every route that overflows, then fails listing them all.
const _routes = [
  Routes.home,
  Routes.forYou,
  Routes.events,
  '${Routes.events}?view=mine',
  '${Routes.event}/e-jazz',
  '${Routes.event}/e-jazz/people',
  Routes.eventNew,
  Routes.likes,
  Routes.messages,
  '${Routes.chat}/priya',
  '${Routes.chat}/jo',
  '${Routes.person}/maya',
  '${Routes.like}/kemi',
  Routes.profile,
  Routes.editProfile,
  Routes.completion,
  Routes.preview,
  Routes.openingMoves,
  Routes.verifyPhoto,
  Routes.premium,
  Routes.paywall,
  Routes.safety,
  Routes.visibility,
  Routes.visibilityAbout,
  Routes.settings,
  Routes.notifications,
  Routes.privacy,
  Routes.blocked,
  Routes.deleteAccount,
  Routes.help,
  Routes.helpContact,
  Routes.accountBlocked,
  Routes.demo,
];

Future<void> _sweep(WidgetTester tester, Size size, double text) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = text;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final c = await quickStartApp(tester);
  final broken = <String>[];
  for (final route in _routes) {
    await goTo(c, tester, route);
    await tester.pump(const Duration(milliseconds: 400));
    final e = tester.takeException();
    if (e != null) broken.add('$route: $e');
  }
  await settle(tester);
  expect(broken, isEmpty, reason: broken.join('\n'));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'every route lays out on a 320 × 568 phone at 150% text',
    (tester) => _sweep(tester, const Size(320, 568), 1.5),
  );

  testWidgets(
    'every route lays out on a 393 × 852 phone at 200% text',
    (tester) => _sweep(tester, const Size(393, 852), 2),
  );

  for (final (size, text) in [
    (const Size(393, 852), 2.0),
    (const Size(320, 568), 1.5),
  ]) {
    testWidgets('sign-up, every step, lays out on ${size.width.toInt()} × '
        '${size.height.toInt()} at ${(text * 100).toInt()}% text', (
      tester,
    ) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = text;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      Future<void> check() async => expect(tester.takeException(), isNull);
      await signUpToInterests(tester, testAuth(), onScreen: check);
      await finishProfileToHome(tester, onScreen: check);
      await settle(tester);
    });
  }
}
