import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Alternative onboarding paths: correcting an under-18 year, going back without losing answers,
/// Android system back, and dismissing the keyboard.
void main() {
  setUpAll(loadAppFonts);

  Future<void> toBasics(WidgetTester tester) async {
    final auth = testAuth();
    await tester.pumpWidget(testApp(auth: auth));
    await tester.pump();
    await tapOn(tester, find.text('Create an account'));
    await tester.enterText(find.byType(TextField), '4155550132');
    await tester.pump();
    await tester.tap(fab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField), auth.latestMessage!.code);
    await settle(tester);
    await tapOn(tester, find.text('Build my profile'));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('under 18: an inline error, Next disabled, fixable in place', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await toBasics(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Sam');
    await tester.enterText(fields.at(1), '2012');
    await tester.pump();
    await tapOn(tester, find.text('Woman'));
    await tapOn(tester, find.text('Something casual'));
    expect(
      find.text('You need to be 18 or older to use Numaya.'),
      findsOneWidget,
    );
    expect(fabEnabled(tester), isFalse);

    await tester.enterText(fields.at(1), '1850');
    await tester.pump();
    expect(find.text('Enter a real year, like 1995.'), findsOneWidget);
    expect(fabEnabled(tester), isFalse);

    await tester.enterText(fields.at(1), '1995');
    await tester.pump();
    expect(
      find.text('You need to be 18 or older to use Numaya.'),
      findsNothing,
    );
    expect(fabEnabled(tester), isTrue);
    await settle(tester);
  });

  testWidgets(
    'back from Interests keeps every Basics answer, and forward keeps picks',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToInterests(tester, testAuth());
      await tapOn(tester, find.text('Jazz'));
      await tapOn(tester, find.bySemanticsLabel('Back'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Let’s start with the basics'), findsOneWidget);
      final fields = find.byType(TextField);
      expect(tester.widget<TextField>(fields.at(0)).controller!.text, 'Sam');
      expect(tester.widget<TextField>(fields.at(1)).controller!.text, '1995');
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Woman'))),
        isSemantics(isChecked: true),
      );
      expect(fabEnabled(tester), isTrue);

      await tester.tap(fab);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('What are you into?'), findsOneWidget);
      expect(find.textContaining('1/5'), findsWidgets);
      await settle(tester);
    },
  );

  testWidgets('Android back pops a step, then a chat back to Messages', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToInterests(tester, testAuth());
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Let’s start with the basics'), findsOneWidget);
    await tester.tap(fab);
    await tester.pump(const Duration(milliseconds: 600));
    await finishProfileToHome(tester);

    await tapOn(tester, find.bySemanticsLabel('Like').last);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField), 'Hi');
    await tester.pump();
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Demo · saved on this device, not sent'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Conversations'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('tapping outside a field dismisses the keyboard', (tester) async {
    await usePhoneSize(tester);
    await toBasics(tester);
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    await tester.tapAt(
      tester.getCenter(find.text('Let’s start with the basics')),
    );
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.context?.widget,
      isNot(isA<EditableText>()),
    );
    expect(tester.testTextInput.isVisible, isFalse);
    await settle(tester);
  });
}
