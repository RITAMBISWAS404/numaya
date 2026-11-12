import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

Finder _action(String label) => find.bySemanticsLabel(label);

/// UI-016: a swipe on the photo (no decision buttons).
Future<void> _decide(WidgetTester tester, String label) =>
    swipeDecide(tester, like: label == 'Like');

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Discover: sample profile, pass, undo, like without a match', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    expect(find.text('Maya, 29'), findsOneWidget);
    // UI-041: no "Sample profile" badge.
    expect(find.text('Sample profile'), findsNothing);
    // ER-01: the photo's "Sample profile" badge is the notice; the repeated line at the end of
    // the profile is gone.
    expect(
      find.text(
        'Sample profiles. Photos are placeholders; distances are illustrative.',
      ),
      findsNothing,
    );

    await _decide(tester, 'Pass');
    expect(find.text('Sam, 31'), findsOneWidget);
    await tapOn(tester, _action('Backtrack: bring back Maya'));
    expect(find.text('Maya, 29'), findsOneWidget);

    await _decide(tester, 'Pass');
    await _decide(tester, 'Like'); // Sam hasn't liked you: no match.
    expect(find.text('You liked Sam'), findsOneWidget);
    expect(find.text('Noor, 28'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('Discover: swipe right on the photo likes, left passes', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await tester.drag(find.text('Maya, 29'), const Offset(-200, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Sam, 31'), findsOneWidget);
    await tester.drag(find.text('Sam, 31'), const Offset(200, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('You liked Sam'), findsOneWidget);
    // A short drag springs back without deciding.
    await tester.drag(find.text('Noor, 28'), const Offset(40, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Noor, 28'), findsOneWidget);
    await settle(tester);
  });

  testWidgets(
    'mutual like → match → message stays on device → conversation listed',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await _decide(tester, 'Like'); // Maya already liked you.
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('It’s a match!'), findsOneWidget);
      expect(
        find.text('Maya is a sample profile: messages stay on this device.'),
        findsNothing, // UI-041
      );

      await openChatFromMatch(tester);
      await tester.enterText(find.byType(TextField), 'Which record shop?');
      await tester.pump();
      await tapOn(tester, _action('Send'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Which record shop?'), findsOneWidget);
      expect(find.text('Not sent: saved on this device'), findsOneWidget);
      // No reply is ever invented.
      expect(
        find.text(
          'Maya is a sample profile. Messages stay on this device and no one replies.',
        ),
        findsNothing, // UI-041
      );

      await tapOn(tester, _action('Back to messages'));
      await tester.pump(const Duration(milliseconds: 600));
      await openTab(tester, 'Messages');
      // Selections pass: Messages A groups by turn (no Conversations heading).
      expect(find.textContaining(RegExp('Your turn|Waiting on them')), findsWidgets);
      expect(find.text('You: Which record shop?'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'keep browsing after a match: the match waits in Messages with openers',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await _decide(tester, 'Like');
      await tester.pump(const Duration(milliseconds: 600));
      await closeMatch(tester);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Sam, 31'), findsOneWidget);
      expect(find.bySemanticsLabel('Messages, 1 new'), findsOneWidget);

      await openTab(tester, 'Messages');
      expect(find.text('New matches (1)'), findsOneWidget);
      await tapOn(tester, find.bySemanticsLabel(RegExp(r'^Maya, new match')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.text('You matched. Say hello and make it personal.'),
        findsOneWidget,
      );
      await tapOn(tester, find.text('Plans for the weekend, or happily none?'));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Plans for the weekend, or happily none?',
      );
      await settle(tester);
    },
  );

  testWidgets('filters: no one fits → widen; seen everyone → show again', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    // Onboarding set ages 26–38 around the member's own age (31, OB-09); with 25 km that leaves
    // Inés (24) and Tomás (41, 38 km) out.
    for (final name in ['Maya, 29', 'Sam, 31', 'Noor, 28', 'Léa, 35']) {
      expect(find.text(name), findsOneWidget);
      await _decide(tester, 'Pass');
    }
    expect(find.text('No one fits your filters'), findsOneWidget);
    expect(
      find.text('2 people are just outside ages 26–38 or 25 km.'),
      findsOneWidget,
    );
    await tapOn(tester, find.text('Widen age and distance'));
    expect(find.text('Inés, 24'), findsOneWidget);
    await _decide(tester, 'Pass');
    expect(find.text('Tomás, 41'), findsOneWidget);
    await _decide(tester, 'Pass');
    expect(find.text('You’ve seen everyone for now'), findsOneWidget);
    await tapOn(tester, find.text('Show them again'));
    expect(find.text('Maya, 29'), findsOneWidget);

    // Widened filters differ from the sign-up preferences, and the button says so.
    await tapOn(tester, _action('Filters, changed from your preferences'));
    await tester.pumpAndSettle();
    expect(find.text('Show 6 people'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('Likes: grid, like back opens the match, pass removes the tile', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    expect(find.bySemanticsLabel('Likes, 5 new'), findsOneWidget);
    await openTab(tester, 'Likes');
    // S18: free members see the count and a locked grid; Premium sees who.
    expect(find.byKey(const ValueKey('likes-locked')), findsOneWidget);
    expect(find.text('5 people like you'), findsOneWidget);
    expect(find.text('Maya, 29'), findsNothing);
    ProviderScope.containerOf(
      tester.element(find.byKey(const ValueKey('likes-locked'))),
    ).read(premiumProvider.notifier).setActive(true);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Maya, 29'), findsOneWidget);
    expect(find.text('Kemi, 27'), findsOneWidget);

    await tapOn(tester, find.bySemanticsLabel(RegExp('^Kemi, 27')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Liked your profile'), findsOneWidget);
    await tapOn(tester, find.text('Like back'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('It’s a match!'), findsOneWidget);
    await closeMatch(tester);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.bySemanticsLabel(RegExp('^Kemi, 27. Matched')), findsOneWidget);

    await tapOn(tester, find.bySemanticsLabel(RegExp('^Tomás, 41')));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Pass'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.bySemanticsLabel(RegExp('^Tomás, 41')), findsNothing);

    // Nearby: within 5 km (Maya 2 km, Kemi 4 km).
    await tapOn(tester, find.bySemanticsLabel('Nearby, 2'));
    expect(find.text('Noor, 28'), findsNothing);
    await settle(tester);
  });

  testWidgets('chat: unmatch from the menu ends the conversation', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await _decide(tester, 'Like');
    await tester.pump(const Duration(milliseconds: 600));
    await openChatFromMatch(tester);
    await tester.enterText(find.byType(TextField), 'Hi!');
    await tester.pump();
    await tapOn(tester, _action('Send'));
    await tester.pump(const Duration(milliseconds: 600));

    await tapOn(tester, _action('Conversation options'));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Unmatch'));
    await tester.pumpAndSettle();
    expect(find.text('Unmatch Maya?'), findsOneWidget);
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Unmatch'));
    await tester.pumpAndSettle();
    // B-54: an optional reason, kept on this device.
    expect(
      find.text('Could you tell us why? Maya won’t know.'),
      findsOneWidget,
    );
    await tapOn(tester, find.text('They didn’t reply'));
    await tester.pumpAndSettle();
    expect(find.text('Thanks for telling us.'), findsOneWidget);
    expect(find.text('You’ve unmatched Maya'), findsOneWidget);
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Back to messages'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Messages');
    expect(find.text('Connections start here'), findsOneWidget);
    await settle(tester);
  });

  testWidgets(
    'report from chat blocks, is saved on device only, and can be unblocked',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await _decide(tester, 'Like');
      await tester.pump(const Duration(milliseconds: 600));
      await openChatFromMatch(tester);
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tapOn(tester, _action('Send'));
      await tester.pump(const Duration(milliseconds: 600));

      await tapOn(tester, _action('Conversation options'));
      await tester.pumpAndSettle();
      await tapOn(tester, find.text('Report'));
      await tester.pumpAndSettle();
      expect(find.text('Report Maya'), findsOneWidget);
      expect(
        tester
            .widget<NumayaButton>(
              find.widgetWithText(NumayaButton, 'Send report'),
            )
            .onPressed,
        isNull,
      );
      await tapOn(tester, find.text('Fake profile'));
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Send report'));
      await tester.pumpAndSettle();
      expect(find.text('Report saved'), findsOneWidget);
      expect(
        find.textContaining(
          'Thanks for telling us. In this demo the report is kept on this device only',
        ),
        findsOneWidget,
      );
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Done'));
      await tester.pumpAndSettle();
      expect(find.text('You’ve reported and blocked Maya'), findsOneWidget);

      await tapOn(
        tester,
        find.widgetWithText(NumayaButton, 'Back to messages'),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await openTab(tester, 'Profile');
      await tapOn(tester, find.bySemanticsLabel('Settings').first);
      await tester.pump(const Duration(milliseconds: 600));
      await tapOn(tester, find.text('Blocked people'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Maya'), findsOneWidget);
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Unblock'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('No one is blocked'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets('block from the profile options removes the person from Home', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await tapOn(tester, _action('Profile options'));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Block Maya'));
    await tester.pumpAndSettle();
    expect(find.text('Block Maya?'), findsOneWidget);
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Block Maya'));
    await tester.pumpAndSettle();
    expect(find.text('Sam, 31'), findsOneWidget);
    expect(find.text('Maya, 29'), findsNothing);
    await settle(tester);
  });

  testWidgets(
    'simulated connection problems: Home error and a failed send with retry',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await _decide(tester, 'Like');
      await tester.pump(const Duration(milliseconds: 600));
      await closeMatch(tester);
      await tester.pump(const Duration(milliseconds: 600));

      await openTab(tester, 'Profile');
      await tapOn(tester, find.bySemanticsLabel('Settings').first);
      await tester.pump(const Duration(milliseconds: 600));
      await tapOn(
        tester,
        find.bySemanticsLabel(RegExp('^Simulate connection problems')),
      );
      await tapOn(tester, find.bySemanticsLabel('Back'));
      await tester.pump(const Duration(milliseconds: 600));

      await openTab(tester, 'Home');
      expect(find.text('We couldn’t load profiles'), findsOneWidget);
      await tapOn(tester, find.text('Try again'));
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      // The retry failed again, and the error says so.
      expect(find.text('Still can’t load profiles'), findsOneWidget);

      await openTab(tester, 'Messages');
      await tapOn(tester, find.bySemanticsLabel(RegExp(r'^Maya, new match')));
      await tester.pump(const Duration(milliseconds: 600));
      await openChatFromMatch(tester);
      await tester.enterText(find.byType(TextField), 'Hi');
      await tester.pump();
      await tapOn(tester, _action('Send'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Not sent'), findsOneWidget);
      await tapOn(tester, find.text('Delete'));
      expect(find.text('Hi'), findsNothing);
      await settle(tester);
    },
  );

  testWidgets('snooze pauses Home and Resume brings it back', (tester) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await openTab(tester, 'Profile');
    await tapOn(tester, find.bySemanticsLabel('Settings').first);
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.bySemanticsLabel(RegExp('^Snooze')));
    await tester.pumpAndSettle();
    // B-71: how long, then an optional away status.
    await tapOn(tester, find.text('72 hours'));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('I’m travelling'));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp('Until .*I’m travelling')),
      findsOneWidget,
    );
    await tapOn(tester, find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Home');
    expect(find.text('Home is paused'), findsOneWidget);
    await tapOn(tester, find.text('Resume'));
    expect(find.text('Maya, 29'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('Messages search finds names and message text', (tester) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await _decide(tester, 'Like');
    await tester.pump(const Duration(milliseconds: 600));
    await openChatFromMatch(tester);
    await tester.enterText(find.byType(TextField), 'Record shops?');
    await tester.pump();
    await tapOn(tester, _action('Send'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, _action('Back to messages'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Messages');
    // ER-03: search opens from the header icon (Bumble's Chats).
    await tapOn(
      tester,
      find.bySemanticsLabel('Search names and messages').first,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await openChatFromMatch(tester);
    await tester.enterText(find.byType(TextField), 'record');
    await tester.pump();
    expect(find.text('You: Record shops?'), findsOneWidget);
    await openChatFromMatch(tester);
    await tester.enterText(find.byType(TextField), 'zebra');
    await tester.pump();
    expect(find.text('Nothing matches “zebra”'), findsOneWidget);
    // The Unread filter is part of Messages O (kept in the Design Lab); A has no filter row.
    ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    ).read(labChoicesProvider.notifier).choose('fx-messages', 'O');
    await tester.pump(const Duration(milliseconds: 300));
    await tapOn(tester, find.bySemanticsLabel('Unread, 0'));
    await openChatFromMatch(tester);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.text('You’re all caught up'), findsOneWidget);
    await settle(tester);
  });
}
