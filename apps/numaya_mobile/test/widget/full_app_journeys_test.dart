import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/features/verification/application/verification_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Journeys through the full demo world (seeded matches and conversations), started from the
/// Demo Hub's quick start.
void main() {
  setUpAll(loadAppFonts);

  Future<void> sheetUp(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('Demo Hub: quick start from Welcome, reset and switch world', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp(world: DemoWorld.full));
    await tester.pump();
    await tapOn(tester, find.bySemanticsLabel('Demo build. Open the demo hub'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Development build only'), findsOneWidget);
    // Signed out: session screens are disabled and say why.
    expect(find.text('Sign in or use Quick start first'), findsWidgets);
    await tapOn(tester, find.text('Quick start as Alex (sample account)'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Maya, 29'), findsOneWidget);
    expect(find.bySemanticsLabel('Messages, 3 new'), findsOneWidget);

    await openTab(tester, 'Profile');
    await tapOn(tester, find.bySemanticsLabel('Settings').first);
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('Demo hub'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('Brand-new account'));
    await tapOn(tester, find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Messages');
    expect(find.text('Connections start here'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('unknown links land on a recovery page with a way home', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '/no-such-page');
    expect(find.text('This page isn’t here'), findsOneWidget);
    await tapOn(tester, find.text('Back to Home'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Maya, 29'), findsOneWidget);
    // A deep link to a missing profile doesn't crash either.
    await goTo(c, tester, '${Routes.person}/nobody');
    expect(find.text('This profile isn’t available'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('every tab and For you are reachable from the app itself', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await quickStartApp(tester);
    await tapOn(tester, find.bySemanticsLabel('For you: today’s picks'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('People you have the most in common with, picked once a day.'),
      findsOneWidget,
    );
    await tapOn(tester, find.bySemanticsLabel('Like Maya'));
    // The match rises in as a modal; at its first frame it is still transparent.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('It’s a match!'), findsOneWidget);
    await tapOn(tester, find.text('Keep browsing'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 600));
    for (final tab in ['Likes', 'Messages', 'Profile', 'Home']) {
      await openTab(tester, tab);
    }
    expect(find.text('Sam, 31'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('a sample conversation: unread clears, sending stays on device', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await quickStartApp(tester);
    await openTab(tester, 'Messages');
    expect(find.text('New matches (3)'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Priya. Have you been\\?')),
      findsOneWidget,
    );
    await tapOn(tester, find.bySemanticsLabel('Unread, 1'));
    await tapOn(tester, find.bySemanticsLabel(RegExp('^Priya')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Sample conversation'), findsOneWidget);
    expect(
      find.text('Yes! The cardamom buns sell out by ten.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'Not yet. Saturday?');
    await tester.pump();
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Demo · saved on this device, not sent'), findsOneWidget);
    await tapOn(tester, find.bySemanticsLabel('Back to messages'));
    await tester.pump(const Duration(milliseconds: 600));
    // The Unread view is now empty: Priya's messages have been read.
    expect(find.bySemanticsLabel('Unread, 0'), findsOneWidget);
    expect(find.text('You’re all caught up'), findsOneWidget);
    await tapOn(tester, find.bySemanticsLabel('All, 3'));
    expect(find.text('You: Not yet. Saturday?'), findsOneWidget);
    await settle(tester);
  });

  testWidgets(
    'expiring match: Extend once free; expired: Rematch via paywall',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.chat}/lina');
      expect(find.text('1h left to start the conversation'), findsOneWidget);
      await tapOn(tester, find.text('Extend 24 hours'));
      expect(find.text('Extended: you have 24 more hours'), findsOneWidget);
      expect(find.text('24h left to start the conversation'), findsOneWidget);
      await goTo(c, tester, '${Routes.chat}/amara');
      expect(
        tester
            .widget<NumayaButton>(
              find.widgetWithText(NumayaButton, 'Extend 24 hours'),
            )
            .onPressed,
        isNull,
      );

      await goTo(c, tester, '${Routes.chat}/ollie');
      expect(find.text('Your match with Ollie expired'), findsOneWidget);
      expect(find.byType(Composer), findsNothing);
      await tapOn(tester, find.text('Rematch with Premium'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Rematch comes with Premium'), findsOneWidget);
      final buy = find.widgetWithText(
        NumayaButton,
        'Choose a plan to continue',
      );
      expect(tester.widget<NumayaButton>(buy).onPressed, isNull);
      await tapOn(tester, find.bySemanticsLabel(RegExp('^1 month')));
      await tapOn(tester, find.text('Continue with 1 month · £24.99'));
      await sheetUp(tester);
      await tapOn(tester, find.text('Simulate a failed payment'));
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('The payment didn’t go through'), findsOneWidget);
      expect(c.read(premiumProvider).active, isFalse);
      await tapOn(tester, find.text('Continue with 1 month · £24.99'));
      await sheetUp(tester);
      await tapOn(tester, find.text('Complete demo purchase'));
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('You’re all set'), findsOneWidget);
      await tapOn(tester, find.text('Done'));
      await tester.pump(const Duration(milliseconds: 600));
      await tapOn(tester, find.text('Rematch'));
      expect(find.text('24h left to start the conversation'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'filters: advanced is locked without Premium; verified only applies',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await tapOn(tester, find.bySemanticsLabel('Filters'));
      await sheetUp(tester);
      expect(find.text('Show 10 people'), findsOneWidget);
      await tapOn(
        tester,
        find.bySemanticsLabel(RegExp('^Verified profiles only')),
      );
      expect(find.text('Show 6 people'), findsOneWidget);
      await tapOn(tester, find.bySemanticsLabel('Advanced'));
      expect(find.text('Advanced filters are part of Premium'), findsOneWidget);
      await tapOn(tester, find.bySemanticsLabel('Basic'));
      await tapOn(tester, find.text('Show 6 people'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        c.read(datingProvider.notifier).queue().every((p) => p.verified),
        isTrue,
      );
      expect(find.text('Sam, 31'), findsNothing);
      // The saved filters now differ from the sign-up preferences; Reset returns to those
      // (not to app defaults that would show people the member never asked for).
      await tapOn(
        tester,
        find.bySemanticsLabel('Filters, changed from your preferences'),
      );
      await sheetUp(tester);
      await tapOn(tester, find.text('Reset'));
      expect(find.text('Show 10 people'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'profile: bio, a second prompt and an Opening Move show in preview',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await openTab(tester, 'Profile');
      expect(find.bySemanticsLabel('Profile 28% complete'), findsOneWidget);
      await tapOn(tester, find.text('Edit profile'));
      await tester.pump(const Duration(milliseconds: 600));
      await tapOn(tester, find.bySemanticsLabel('Write a short intro'));
      await sheetUp(tester);
      await tester.enterText(find.byType(TextField).last, 'Weekend baker.');
      await tester.pump();
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Save'));
      await sheetUp(tester);
      expect(find.text('Weekend baker.'), findsOneWidget);

      await tapOn(tester, find.text('Add a prompt'));
      await tester.pump(const Duration(milliseconds: 600));
      await tapOn(tester, find.text('My Sunday ritual'));
      await tester.enterText(
        find.byType(TextField).last,
        'Market, then a nap.',
      );
      await tester.pump();
      await tapOn(tester, find.text('Save prompt'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Market, then a nap.'), findsOneWidget);

      await tapOn(tester, find.text('Drinking'));
      await sheetUp(tester);
      await tapOn(tester, find.text('Socially'));
      await sheetUp(tester);
      expect(
        c.read(profileDetailsProvider).details.values,
        contains('Socially'),
      );

      await tapOn(tester, find.bySemanticsLabel('Preview profile'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('This is how others see you'), findsOneWidget);
      expect(find.text('Weekend baker.'), findsOneWidget);
      expect(find.text('Market, then a nap.'), findsOneWidget);
      await tapOn(tester, find.text('Back to editing'));
      await tester.pump(const Duration(milliseconds: 600));
      await tapOn(tester, find.bySemanticsLabel('Back'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.bySemanticsLabel('Profile 28% complete'), findsNothing);

      await tapOn(tester, find.text('Opening Moves'));
      await tester.pump(const Duration(milliseconds: 600));
      await tapOn(tester, find.text('First Opening Move'));
      await sheetUp(tester);
      await tapOn(tester, find.text('What’s your go-to order at a café?'));
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Save'));
      await sheetUp(tester);
      expect(c.read(profileDetailsProvider).openingMoves, [
        'What’s your go-to order at a café?',
      ]);
      await settle(tester);
    },
  );

  testWidgets('photo verification: declined with tips, then approved', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    c.read(photoVerificationProvider.notifier).setApproveNext(false);
    await goTo(c, tester, Routes.verifyPhoto);
    expect(find.text('Simulated in this demo'), findsOneWidget);
    await tapOn(tester, find.text('Let’s get verified'));
    await tapOn(tester, find.text('Take demo selfie'));
    await tapOn(tester, find.text('Submit for review'));
    expect(find.text('Checking your selfie'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('We couldn’t verify you'), findsOneWidget);
    c.read(photoVerificationProvider.notifier).setApproveNext(true);
    await tapOn(tester, find.text('Try again'));
    await tapOn(tester, find.text('Take demo selfie'));
    await tapOn(tester, find.text('Submit for review'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('You’re verified'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('chat menu: Did you meet? and a report that asks where', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/sasha');
    await tapOn(tester, find.bySemanticsLabel('Conversation options'));
    await sheetUp(tester);
    await tapOn(tester, find.text('Did you meet?'));
    await sheetUp(tester);
    await tapOn(tester, find.text('Yes, we met'));
    await sheetUp(tester);
    expect(c.read(datingProvider).dateFeedback['sasha'], isTrue);

    await tapOn(tester, find.bySemanticsLabel('Conversation options'));
    await sheetUp(tester);
    await tapOn(tester, find.text('Report'));
    await sheetUp(tester);
    await tapOn(tester, find.text('Inappropriate photos or text'));
    await tapOn(tester, find.text('Messages'));
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Send report'));
    await sheetUp(tester);
    expect(find.text('Report saved'), findsOneWidget);
    expect(c.read(datingProvider).reports.single.part, 'Messages');
    await settle(tester);
  });

  testWidgets('settings: log out can be cancelled, then confirmed', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, Routes.settings);
    await tapOn(tester, find.bySemanticsLabel('Log out').last);
    await sheetUp(tester);
    expect(find.text('Log out?'), findsOneWidget);
    await tapOn(tester, find.text('Cancel'));
    await sheetUp(tester);
    expect(find.text('Log out?'), findsNothing);
    await tapOn(tester, find.bySemanticsLabel('Log out').last);
    await sheetUp(tester);
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Log out'));
    await settle(tester);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('a deleted account can be restored by signing in again', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final auth = testAuth();
    await signUpToHome(tester, auth);
    await openTab(tester, 'Profile');
    await tapOn(tester, find.bySemanticsLabel('Settings').first);
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('Delete account'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('I’m taking a break'));
    await tapOn(tester, find.text('Continue'));
    await sheetUp(tester);
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Delete account'));
    await settle(tester);

    await tapOn(tester, find.text('I have an account'));
    await tester.enterText(find.byType(TextField), '4155550132');
    await tester.pump();
    await tester.tap(fab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField), auth.latestMessage!.code);
    await settle(tester);
    expect(find.text('Welcome back'), findsOneWidget);
    await tapOn(tester, find.text('Restore my account'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Your account is back'), findsOneWidget);
    await settle(tester);
    await openTab(tester, 'Profile');
    expect(find.text('Sam, 31'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('Android back on another tab returns to Home before leaving', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await openTab(tester, 'Messages');
    expect(find.text('Conversations'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Conversations'), findsNothing);
    expect(
      c.read(routerProvider).routerDelegate.currentConfiguration.uri.path,
      Routes.home,
    );
    // A pushed page still closes first.
    await openTab(tester, 'Profile');
    await tapOn(tester, find.bySemanticsLabel('Settings'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      c.read(routerProvider).routerDelegate.currentConfiguration.uri.path,
      Routes.profile,
    );
    await settle(tester);
  });
}
