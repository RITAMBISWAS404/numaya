import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Alternative onboarding paths (docs/mobile/ONBOARDING_EDGE_CASES.md): the age check, invalid
/// dates and names, going back without losing answers, Android system back, and the keyboard.
void main() {
  setUpAll(loadAppFonts);

  Future<void> typeDate(
    WidgetTester tester,
    String d,
    String m,
    String y,
  ) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), d);
    await tester.enterText(fields.at(2), m);
    await tester.enterText(fields.at(3), y);
    await tester.pump();
  }

  testWidgets(
    'invalid, future and over-100 dates and digit names are refused',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToSetup(tester, testAuth());
      await tester.enterText(find.byType(TextField).first, 'Sam2');
      await tester.pump();
      expect(
        find.text('Use letters only, without numbers or emoji.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField).first, 'Zoë');
      await typeDate(tester, '31', '02', '1996');
      expect(
        find.text('That date doesn’t exist. Check the day and month.'),
        findsOneWidget,
      );
      expect(fabEnabled(tester), isFalse);
      await typeDate(tester, '01', '01', '2030');
      expect(find.text('That date is in the future.'), findsOneWidget);
      expect(fabEnabled(tester), isFalse);
      await typeDate(tester, '01', '01', '1900');
      expect(
        find.text('Check the year: that’s more than 100 years ago.'),
        findsOneWidget,
      );
      expect(fabEnabled(tester), isFalse);
      await typeDate(tester, '29', '02', '1996');
      expect(find.text('You’re 30'), findsOneWidget);
      expect(fabEnabled(tester), isTrue);
      await settle(tester);
    },
  );

  testWidgets(
    'under 18: Edit fixes a typo; Confirm locks setup with no way back in',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToSetup(tester, testAuth());
      await tester.enterText(find.byType(TextField).first, 'Sam');
      await typeDate(tester, '01', '06', '2012');
      expect(
        find.text('You need to be 18 or over to use Numaya.'),
        findsOneWidget,
      );
      await tapNext(tester);
      expect(find.text('You’re 14'), findsOneWidget);
      // Edit closes the card and keeps the answers.
      await tapOn(tester, find.text('Edit'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Let’s start with an intro'), findsOneWidget);
      await tapNext(tester);
      await tapOn(tester, find.text('Confirm'));
      await settle(tester);
      expect(find.text('Numaya is for adults'), findsOneWidget);

      // System back and deep links stay on the explanation.
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Numaya is for adults'), findsOneWidget);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      for (final path in [Routes.home, Routes.setupGender, Routes.setup]) {
        c.read(routerProvider).go(path);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Numaya is for adults'), findsOneWidget, reason: path);
      }
      await tapOn(tester, find.text('Sign out'));
      await settle(tester);
      expect(find.text('Create an account'), findsOneWidget);
    },
  );

  testWidgets(
    'back from Interests to the first step keeps every answer, forward keeps picks',
    (tester) async {
      await usePhoneSize(tester);
      final c = await () async {
        await signUpToInterests(tester, testAuth());
        return ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
      }();
      await tapOn(tester, find.text('Jazz'));
      // Back through Photos, Location, Height, Intentions, Meet, Gender to Name.
      for (var i = 0; i < 7; i++) {
        await tester.binding.handlePopRoute();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }
      expect(find.text('Let’s start with an intro'), findsOneWidget);
      final fields = find.byType(TextField);
      String text(int i) =>
          tester.widget<TextField>(fields.at(i)).controller!.text;
      expect([text(0), text(1), text(2), text(3)], ['Sam', '12', '04', '1995']);
      expect(fabEnabled(tester), isTrue);

      // Forward again: Gender keeps Woman; Interests keeps Jazz.
      await tapNext(tester);
      await tapOn(tester, find.text('Confirm'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Woman'))),
        isSemantics(isChecked: true),
      );
      c.read(routerProvider).go(Routes.interests);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Add your photos'), findsOneWidget);
    await tapNext(tester);
    await finishProfileToHome(tester);

    await tapOn(tester, find.bySemanticsLabel('Like').last);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField), 'Hi');
    await tester.pump();
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Demo · saved on this device, not sent'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Conversations'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('tapping outside a field dismisses the keyboard', (tester) async {
    await usePhoneSize(tester);
    await signUpToSetup(tester, testAuth());
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    await tester.tapAt(
      tester.getCenter(find.text('Let’s start with an intro')),
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
