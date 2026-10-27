import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Signs up through the real screens (phone, code, setup hub, basics) and stops on Interests.
///
/// [onScreen] runs on each screen once it has settled (for accessibility checks).
Future<void> signUpToInterests(
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
  await check(); // Basics
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), 'Sam');
  await tester.enterText(fields.at(1), '1995');
  await tapOn(tester, find.text('Woman'));
  await tapOn(tester, find.text('Something casual'));
  await tester.tap(fab);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Interests
}

/// Continues from Interests to Home with three interests, a prompt and two photos.
Future<void> finishProfileToHome(
  WidgetTester tester, {
  Future<void> Function()? onScreen,
}) async {
  final check = onScreen ?? () async {};
  for (final i in ['Jazz', 'Poetry', 'Travel']) {
    await tapOn(tester, find.text(i));
  }
  await tapOn(tester, find.text('Tap to write your answer'));
  await tester.pump(const Duration(milliseconds: 600));
  await check(); // Prompt editor sheet
  await tester.enterText(
    find.byType(TextField).last,
    'Reads the menu out loud.',
  );
  await tester.pump();
  await tapOn(tester, find.text('Save prompt'));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.tap(fab);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tapOn(tester, find.bySemanticsLabel('Add a photo'));
  await tapOn(tester, find.bySemanticsLabel('Add a photo'));
  await check(); // Photos
  await tester.tap(fab);
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
}) async {
  await tester.pumpWidget(testApp(world: world, auth: auth));
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
