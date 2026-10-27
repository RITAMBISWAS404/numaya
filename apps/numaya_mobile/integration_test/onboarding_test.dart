import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../test/helpers/test_app.dart';

/// Runs on a phone or emulator:
///   flutter test integration_test
/// Drives sign-up from Welcome to Home with the demo auth service.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign-up reaches Home', (tester) async {
    final auth = testAuth();
    await tester.pumpWidget(testApp(auth: auth));
    await tester.pumpAndSettle();

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f.first);
      await tester.tap(f.first);
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
    }

    Future<void> wait([int ms = 1500]) async {
      for (var i = 0; i < ms ~/ 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    final fab = find.byType(NumayaFab);
    await tap(find.text('Create an account'));
    await tester.enterText(find.byType(TextField), '4155550132');
    await tester.tap(fab);
    await wait();
    await tester.enterText(find.byType(TextField), auth.latestMessage!.code);
    await wait(2000);
    expect(find.text('You’re verified'), findsOneWidget);

    await tester.tap(find.text('Build my profile'));
    await wait();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Sam');
    await tester.enterText(fields.at(1), '1995');
    FocusManager.instance.primaryFocus?.unfocus();
    await wait(500);
    for (final t in ['Woman', 'Something casual']) {
      await tester.ensureVisible(find.text(t));
      await tester.tap(find.text(t));
      await wait(300);
    }
    await tester.tap(fab);
    await wait();

    for (final t in ['Jazz', 'Poetry', 'Travel']) {
      await tester.ensureVisible(find.text(t));
      await tester.tap(find.text(t));
      await wait(300);
    }
    await tester.ensureVisible(find.text('Tap to write your answer'));
    await tester.tap(find.text('Tap to write your answer'));
    await wait();
    await tester.enterText(
      find.byType(TextField).last,
      'Someone who reads the menu out loud.',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await wait(500);
    await tester.tap(find.text('Save prompt'));
    await wait();
    await tester.tap(fab);
    await wait();

    await tester.tap(find.bySemanticsLabel('Add a photo').first);
    await wait(300);
    await tester.tap(find.bySemanticsLabel('Add a photo').first);
    await wait(300);
    await tester.tap(fab);
    await wait(3500);
    expect(find.text('Maya, 29'), findsOneWidget);
  });
}
