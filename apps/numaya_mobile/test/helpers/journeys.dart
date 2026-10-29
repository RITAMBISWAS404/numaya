import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/auth/data/demo_auth_repository.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import 'test_app.dart';

Finder get fab => find.byType(NumayaFab);

bool fabEnabled(WidgetTester tester) =>
    tester.widget<NumayaFab>(fab).onPressed != null;

/// Scrolls to and taps [f], then lets the animation run. A running scroll (for example a focused
/// field revealing its caret on a short screen) ignores taps, so wait for it to finish first.
Future<void> tapOn(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.tap(f.first);
  // One frame to start any route transition, then let it run.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Taps the round next button and lets the next step slide in.
Future<void> tapNext(WidgetTester tester) async {
  await tester.ensureVisible(fab);
  await tester.pump();
  await tester.tap(fab);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Signs up through the real screens (phone, code, setup hub) and stops on the first setup step,
/// Name and birthday (OB-06).
Future<void> signUpToSetup(
  WidgetTester tester,
  DemoAuthRepository auth, {
  Future<void> Function()? onScreen,
}) async {
  final check = onScreen ?? () async {};
  await tester.pumpWidget(testApp(auth: auth));
  await tester.pump();
  await check(); // Welcome
  await tapOn(tester, find.text('Create an account'));
  await check(); // Phone
  await tester.enterText(find.byType(TextField), '4155550132');
  await tester.pump();
  await tester.tap(fab);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Code
  await tester.enterText(find.byType(TextField), auth.latestMessage!.code);
  await settle(tester);
  await check(); // Setup hub
  await tapOn(tester, find.text('Build my profile'));
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Name and birthday
}

/// Fills Name and birthday (Sam, 12 April 1995) and confirms the age; stops on Gender.
Future<void> enterNameAndBirthday(
  WidgetTester tester, {
  String name = 'Sam',
  String day = '12',
  String month = '04',
  String year = '1995',
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), day);
  await tester.enterText(fields.at(2), month);
  await tester.enterText(fields.at(3), year);
  await tester.pump();
  await tapNext(tester);
  await tapOn(tester, find.text('Confirm'));
  await tester.pump(const Duration(milliseconds: 600));
}

/// Signs up and answers About you and Looking for (woman, everyone, something casual, no height,
/// no location), then adds two photos; stops on Interests.
Future<void> signUpToInterests(
  WidgetTester tester,
  DemoAuthRepository auth, {
  Future<void> Function()? onScreen,
}) async {
  await signUpToSetup(tester, auth, onScreen: onScreen);
  await setupFromNameToInterests(tester, onScreen: onScreen);
}

/// From Name and birthday to Interests (see [signUpToInterests]).
Future<void> setupFromNameToInterests(
  WidgetTester tester, {
  Future<void> Function()? onScreen,
}) async {
  final check = onScreen ?? () async {};
  await enterNameAndBirthday(tester);
  await check(); // Gender
  await tapOn(tester, find.text('Woman'));
  await tapNext(tester);
  await check(); // Who you want to meet
  await tapOn(tester, find.text('Everyone'));
  await tapNext(tester);
  await check(); // Intentions
  await tapOn(tester, find.text('Something casual'));
  await tapNext(tester);
  await check(); // Height
  await tapOn(tester, find.text('Skip'));
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Location
  await tapOn(tester, find.text('Skip'));
  await tester.pump(const Duration(milliseconds: 600));
  await addLibraryPhoto(tester);
  await addLibraryPhoto(tester);
  await check(); // Photos
  await tapNext(tester);
  await check(); // Interests
}

/// "+" on the photo grid, then "Choose from library" (adds a placeholder tile).
Future<void> addLibraryPhoto(WidgetTester tester) async {
  await tapOn(tester, find.bySemanticsLabel('Add a photo'));
  await tester.pump(const Duration(milliseconds: 400));
  await tapOn(tester, find.text('Choose from library'));
  await tester.pump(const Duration(milliseconds: 400));
}

/// From Interests to Home: three interests, one prompt, then skips bio, verification and
/// notifications, creates the profile on the review and starts discovering.
Future<void> finishProfileToHome(
  WidgetTester tester, {
  Future<void> Function()? onScreen,
}) async {
  final check = onScreen ?? () async {};
  for (final i in ['Jazz', 'Poetry', 'Travel']) {
    await tapOn(tester, find.text(i));
  }
  await tapNext(tester);
  await check(); // Prompts
  await tapOn(tester, find.text('Add a prompt'));
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Answer editor
  await tester.enterText(
    find.byType(TextField).last,
    'Reads the menu out loud.',
  );
  await tester.pump();
  await tapOn(tester, find.text('Save prompt'));
  await tester.pump(const Duration(milliseconds: 600));
  await tapNext(tester);
  await check(); // Bio
  await tapOn(tester, find.text('Skip'));
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Verify your photos
  await tapOn(tester, find.text('Skip'));
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Notifications
  await tapOn(tester, find.text('Skip'));
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Review
  await tapOn(tester, find.text('Create my profile'));
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // All set
  await tapOn(tester, find.text('Start discovering'));
  await settle(tester);
}

Future<void> signUpToHome(WidgetTester tester, DemoAuthRepository auth) async {
  await signUpToInterests(tester, auth);
  await finishProfileToHome(tester);
}

/// Taps a tab in the bottom bar by its label.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NumayaTabBar), matching: find.text(label)),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Starts the app in the full demo world, signed in through the Demo Hub's quick start, on Home.
/// Returns the provider container for state checks.
Future<ProviderContainer> quickStartApp(
  WidgetTester tester, {
  DemoWorld world = DemoWorld.full,
  DemoAuthRepository? auth,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    testApp(world: world, auth: auth, overrides: overrides),
  );
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  await container.read(sessionProvider.notifier).quickStart();
  container.read(routerProvider).go(Routes.home);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  return container;
}

/// Goes straight to [path] (as a deep link would).
Future<void> goTo(ProviderContainer c, WidgetTester tester, String path) async {
  c.read(routerProvider).go(path);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}
