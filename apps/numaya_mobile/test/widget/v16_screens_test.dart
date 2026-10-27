import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/data/demo_auth_repository.dart';

import '../helpers/test_app.dart';

Finder get _fab => find.byType(NumayaFab);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  await tester.tap(f.first);
  await tester.pump(const Duration(milliseconds: 500));
}

/// Signs up through the real screens and stops on the Interests step.
Future<void> _toInterests(WidgetTester tester, DemoAuthRepository auth) async {
  await tester.pumpWidget(testApp(auth: auth));
  await tester.pump();
  await _tap(tester, find.text('Create an account'));
  await tester.enterText(find.byType(TextField), '4155550132');
  await tester.pump();
  await tester.tap(_fab);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.enterText(find.byType(TextField), auth.latestMessage!.code);
  await settle(tester);
  await _tap(tester, find.text('Build my profile'));
  await tester.pump(const Duration(milliseconds: 600));
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), 'Sam');
  await tester.enterText(fields.at(1), '1995');
  await _tap(tester, find.text('Woman'));
  await _tap(tester, find.text('Something casual'));
  await tester.tap(_fab);
  await tester.pump(const Duration(milliseconds: 600));
}

/// Continues from Interests to Home.
Future<void> _toHome(WidgetTester tester) async {
  for (final i in ['Jazz', 'Poetry', 'Travel']) {
    await _tap(tester, find.text(i));
  }
  await _tap(tester, find.text('Tap to write your answer'));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.enterText(
    find.byType(TextField).last,
    'Reads the menu out loud.',
  );
  await tester.pump();
  await _tap(tester, find.text('Save prompt'));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.tap(_fab);
  await tester.pump(const Duration(milliseconds: 600));
  await _tap(tester, find.bySemanticsLabel('Add a photo'));
  await _tap(tester, find.bySemanticsLabel('Add a photo'));
  await tester.tap(_fab);
  await settle(tester);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('interests: the sixth pick is unavailable at 5/5', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await _toInterests(tester, testAuth());
    for (final i in ['Natural wine', 'Cooking', 'Jazz', 'Poetry', 'Climbing']) {
      await _tap(tester, find.text(i));
    }
    expect(find.text('5/5 SELECTED'), findsOneWidget);
    final travel = tester.widget<NumayaChip>(
      find.ancestor(of: find.text('Travel'), matching: find.byType(NumayaChip)),
    );
    expect(travel.available, isFalse);
    await settle(tester);
  });

  testWidgets('prompt editor explains why Save is disabled', (tester) async {
    await usePhoneSize(tester);
    await _toInterests(tester, testAuth());
    await _tap(tester, find.text('Tap to write your answer'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('YOUR PROMPT'), findsOneWidget);
    expect(find.text('Write an answer to save.'), findsOneWidget);
    expect(find.text('150 characters left'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Hello');
    await tester.pump();
    expect(find.text('145 characters left'), findsOneWidget);
    expect(
      find.text('Saved prompts show on your profile straight away.'),
      findsOneWidget,
    );
    await _tap(tester, find.text('Save prompt'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Hello'), findsOneWidget);
    // Reopening with nothing changed: no changes yet.
    await _tap(tester, find.text('Hello'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('No changes yet.'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('Likes empty state (every like answered) sends people to Home', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await _toInterests(tester, testAuth());
    await _toHome(tester);
    await _tap(tester, find.text('Likes'));
    for (final name in [
      'Maya, 29',
      'Kemi, 27',
      'Noor, 28',
      'Inés, 24',
      'Tomás, 41',
    ]) {
      await _tap(tester, find.bySemanticsLabel(RegExp('^$name')));
      await tester.pump(const Duration(milliseconds: 600));
      await _tap(tester, find.widgetWithText(NumayaButton, 'Pass'));
      await tester.pump(const Duration(milliseconds: 600));
    }
    expect(find.text('No new likes right now'), findsOneWidget);
    await _tap(tester, find.text('Go to Home'));
    // Passing on Likes also passes them in Discover, so Home starts with Sam.
    expect(find.text('Sam, 31'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('delete account: the sheet can be cancelled, then confirmed', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await _toInterests(tester, testAuth());
    await _toHome(tester);
    await _tap(tester, find.text('Profile'));
    expect(find.text('Sam, 31'), findsOneWidget);
    expect(find.text('Woman · Looking for something casual'), findsOneWidget);
    await _tap(tester, find.bySemanticsLabel('Settings'));
    await tester.pump(const Duration(milliseconds: 600));
    await _tap(tester, find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    await _tap(tester, find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Delete your account?'), findsNothing);
    await _tap(tester, find.text('Delete account'));
    await tester.pumpAndSettle();
    await _tap(tester, find.widgetWithText(NumayaButton, 'Delete account'));
    await settle(tester);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
