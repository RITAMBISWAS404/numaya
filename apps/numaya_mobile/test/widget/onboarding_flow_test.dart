import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/test_app.dart';

Finder fab() => find.byType(NumayaFab);
bool fabEnabled(WidgetTester tester) =>
    tester.widget<NumayaFab>(fab()).onPressed != null;

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.tap(find.text(text).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('welcome shows the approved copy and both entry points', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp());
    await tester.pump();
    expect(find.text('Fewer swipes.\nBetter first dates.'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('I have an account'), findsOneWidget);
    expect(find.text('Demo build'), findsOneWidget);
  });

  testWidgets('phone step: next stays disabled until the number is complete', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp());
    await tester.pump();
    await tapText(tester, 'Create an account');
    expect(find.text('Can we get your number, please?'), findsOneWidget);
    expect(fabEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField), '415555');
    await tester.pump();
    expect(find.text('(415) 555'), findsOneWidget);
    expect(fabEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField), '4155550132');
    await tester.pump();
    expect(find.text('(415) 555-0132'), findsOneWidget);
    expect(fabEnabled(tester), isTrue);
  });

  testWidgets('changing country trims the number', (tester) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp());
    await tester.pump();
    await tapText(tester, 'Create an account');
    await tester.enterText(find.byType(TextField), '4155550132');
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Country: United States, plus 1'));
    await tester.pumpAndSettle();
    expect(find.text('Country or region'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'sing');
    await tester.pump();
    await tester.tap(find.text('Singapore'));
    await tester.pumpAndSettle();
    expect(find.text('4155 5501'), findsOneWidget);
    expect(find.text('+65'), findsOneWidget);
  });

  testWidgets(
    'an unusable number shows an error and keeps the person on the step',
    (tester) async {
      await usePhoneSize(tester);
      await tester.pumpWidget(testApp());
      await tester.pump();
      await tapText(tester, 'Create an account');
      await tester.enterText(find.byType(TextField), '0000000000');
      await tester.pump();
      await tester.tap(fab());
      await tester.pump();
      await tester.pump();
      expect(
        find.text('That number can’t be used. Check it and try again.'),
        findsOneWidget,
      );
      await settle(tester);
    },
  );

  testWidgets(
    'full sign-up: phone, wrong code, right code, basics, interests, prompt, photos',
    (tester) async {
      await usePhoneSize(tester);
      final auth = testAuth();
      await tester.pumpWidget(testApp(auth: auth));
      await tester.pump();

      // Phone
      await tapText(tester, 'Create an account');
      await tester.enterText(find.byType(TextField), '4155550132');
      await tester.pump();
      await tester.tap(fab());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify: the demo banner shows the code; a wrong code is rejected first.
      expect(find.text('Verify your number'), findsOneWidget);
      expect(find.textContaining('+1 (415) 555-0132'), findsWidgets);
      final code = auth.latestMessage!.code;
      expect(find.textContaining(code), findsOneWidget);
      final wrong = code == '000000' ? '111111' : '000000';
      await tester.enterText(find.byType(TextField), wrong);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.text('That code doesn’t match. Try the latest one we sent.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 700));

      await tester.enterText(find.byType(TextField), code);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Number verified'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Setup hub
      expect(find.text('You’re verified'), findsOneWidget);
      expect(find.text('0 of 3 done'), findsOneWidget);
      await tapText(tester, 'Build my profile');
      await tester.pumpAndSettle();

      // Basics: underage is refused.
      expect(find.text('Let’s start with the basics'), findsOneWidget);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Sam');
      await tester.enterText(fields.at(1), '2012');
      await tester.pump();
      expect(
        find.text('You need to be 18 or older to use Numaya.'),
        findsOneWidget,
      );
      await tester.enterText(fields.at(1), '1995');
      await tester.pump();
      await tapText(tester, 'Nonbinary');
      expect(fabEnabled(tester), isFalse);
      await tapText(tester, 'Open to seeing where it goes');
      expect(fabEnabled(tester), isTrue);
      await tester.tap(fab());
      await tester.pumpAndSettle();

      // Interests: three picks, then the prompt.
      expect(find.text('What are you into?'), findsOneWidget);
      expect(find.text('Pick 3 more'), findsOneWidget);
      await tapText(tester, 'Jazz');
      await tapText(tester, 'Cooking');
      await tapText(tester, 'Climbing');
      expect(find.text('Now answer your prompt'), findsOneWidget);
      expect(fabEnabled(tester), isFalse);
      await tapText(tester, 'Tap to write your answer');
      await tester.pumpAndSettle();
      await tapText(tester, 'My Sunday ritual');
      await tester.enterText(
        find.byType(TextField).last,
        'Pastries, then a very long walk.',
      );
      await tester.pump();
      await tapText(tester, 'Save prompt');
      await tester.pumpAndSettle();
      expect(find.text('Pastries, then a very long walk.'), findsOneWidget);
      expect(find.text('3/5 interests'), findsOneWidget);
      expect(fabEnabled(tester), isTrue);
      await tester.tap(fab());
      await tester.pumpAndSettle();

      // Photos: two minimum.
      expect(find.text('Add your photos'), findsOneWidget);
      expect(fabEnabled(tester), isFalse);
      await tester.tap(find.bySemanticsLabel('Add a photo').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(fabEnabled(tester), isFalse);
      await tester.tap(find.bySemanticsLabel('Add a photo').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Add 2 more for the best results'), findsOneWidget);
      expect(fabEnabled(tester), isTrue);
      await tester.tap(fab());
      await tester.pumpAndSettle();

      // Home: the first sample profile.
      expect(find.text('Maya, 29'), findsOneWidget);
      expect(find.text('Sample profile'), findsOneWidget);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Sam, 31'), findsOneWidget);
      expect(find.text('Pastries, then a very long walk.'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets('change number returns to the phone step with the number kept', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp());
    await tester.pump();
    await tapText(tester, 'Create an account');
    await tester.enterText(find.byType(TextField), '4155550132');
    await tester.pump();
    await tester.tap(fab());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tapText(tester, 'Change number');
    await tester.pumpAndSettle();
    expect(find.text('Can we get your number, please?'), findsOneWidget);
    expect(find.text('(415) 555-0132'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('sign-in with an unknown number offers to create an account', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final auth = testAuth();
    await tester.pumpWidget(testApp(auth: auth));
    await tester.pump();
    await tapText(tester, 'I have an account');
    expect(find.text('Welcome back. What’s your number?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '4155550132');
    await tester.pump();
    await tester.tap(fab());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField), auth.latestMessage!.code);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    // The verify screen's countdown keeps ticking under the sheet: pump fixed steps.
    await settle(tester);
    expect(find.text('No account for this number yet'), findsOneWidget);
    await tapText(tester, 'Create an account');
    await settle(tester);
    expect(find.text('You’re verified'), findsOneWidget);
    await settle(tester);
  });
}
