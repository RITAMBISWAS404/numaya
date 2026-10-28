import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Tap-target and label guidelines on the dating screens, and layout on a small phone with large
/// text (a RenderFlex overflow fails the test).
void main() {
  setUpAll(loadAppFonts);

  Future<void> checkGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  }

  /// Home → match → chat with one message → Messages → Likes → a like's profile.
  Future<void> walkDatingScreens(
    WidgetTester tester,
    Future<void> Function() check,
  ) async {
    await signUpToHome(tester, testAuth());
    await check(); // Home: a sample profile
    await tapOn(tester, find.bySemanticsLabel('Like').last);
    await tester.pump(const Duration(milliseconds: 600));
    await check(); // It's a match
    await tester.enterText(find.byType(TextField), 'Hi there');
    await tester.pump();
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(milliseconds: 600));
    await check(); // Chat
    await tapOn(tester, find.bySemanticsLabel('Back to messages'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Messages');
    await check(); // Messages
    await openTab(tester, 'Likes');
    await check(); // Likes grid
    await tapOn(tester, find.bySemanticsLabel(RegExp('^Kemi, 27')));
    await tester.pump(const Duration(milliseconds: 600));
    await check(); // A like's profile
    await settle(tester);
  }

  testWidgets('onboarding screens meet tap-target and label guidelines', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final handle = tester.ensureSemantics();
    final auth = testAuth();
    Future<void> check() => checkGuidelines(tester);
    await signUpToInterests(tester, auth, onScreen: check);
    await finishProfileToHome(tester, onScreen: check);
    await settle(tester);
    handle.dispose();
  });

  testWidgets('onboarding lays out on a 375 × 667 phone at 130% text', (
    tester,
  ) async {
    await usePhoneSize(tester, size: const Size(375, 667));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    Future<void> check() async => expect(tester.takeException(), isNull);
    await signUpToInterests(tester, testAuth(), onScreen: check);
    await finishProfileToHome(tester, onScreen: check);
    await settle(tester);
  });

  testWidgets('dating screens meet tap-target and label guidelines', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final handle = tester.ensureSemantics();
    await walkDatingScreens(tester, () => checkGuidelines(tester));
    handle.dispose();
  });

  testWidgets('dating screens lay out on a 375 × 667 phone at 130% text', (
    tester,
  ) async {
    await usePhoneSize(tester, size: const Size(375, 667));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await walkDatingScreens(tester, () async {
      expect(tester.takeException(), isNull);
    });
  });

  fullAppAccessibilityTests();
}

/// The full-app screens (Demo Hub, seeded inbox and chats, profile tools, premium, settings, help).
const fullAppRoutes = [
  Routes.demo,
  Routes.messages,
  '${Routes.chat}/priya',
  '${Routes.chat}/jo',
  '${Routes.chat}/ollie',
  Routes.forYou,
  Routes.events,
  '${Routes.events}?view=mine',
  '${Routes.event}/e-jazz',
  '${Routes.event}/e-board',
  '${Routes.event}/e-mine',
  '${Routes.event}/e-mine/people',
  Routes.eventNew,
  Routes.visibility,
  Routes.visibilityAbout,
  '${Routes.person}/maya/photos?start=2',
  Routes.profile,
  Routes.completion,
  Routes.editProfile,
  Routes.preview,
  Routes.openingMoves,
  Routes.verifyPhoto,
  Routes.premium,
  Routes.paywall,
  Routes.settings,
  Routes.notifications,
  Routes.privacy,
  Routes.deleteAccount,
  Routes.help,
  '${Routes.help}/verification',
  Routes.helpContact,
  Routes.safety,
  Routes.accountBlocked,
  '/no-such-page',
];

void fullAppAccessibilityTests() {
  testWidgets('full-app screens meet tap-target and label guidelines', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final handle = tester.ensureSemantics();
    final c = await quickStartApp(tester);
    for (final route in fullAppRoutes) {
      await goTo(c, tester, route);
      await expectLater(
        tester,
        meetsGuideline(labeledTapTargetGuideline),
        reason: route,
      );
      await expectLater(
        tester,
        meetsGuideline(androidTapTargetGuideline),
        reason: route,
      );
    }
    await settle(tester);
    handle.dispose();
  });

  testWidgets('full-app screens lay out on a 375 × 667 phone at 130% text', (
    tester,
  ) async {
    await usePhoneSize(tester, size: const Size(375, 667));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await quickStartApp(tester);
    for (final route in fullAppRoutes) {
      await goTo(c, tester, route);
      expect(tester.takeException(), isNull, reason: route);
    }
    await settle(tester);
  });
}
