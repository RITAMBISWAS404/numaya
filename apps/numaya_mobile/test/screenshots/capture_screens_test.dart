@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Walks the onboarding flow and captures each state at 393 x 852 @2x (the web gallery's size)
/// into test/screenshots/goldens/. Used for docs/mobile/VISUAL_COMPARISON.md.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture onboarding screens', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final auth = testAuth();
    await tester.pumpWidget(testApp(auth: auth));

    Future<void> shot(String name) async {
      // SVG pictures decode asynchronously.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    }

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f.first);
      await tester.tap(f.first);
      await tester.pump(const Duration(milliseconds: 500));
    }

    final fab = find.byType(NumayaFab);

    await shot('01-welcome');
    await tap(find.text('Create an account'));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('02-phone-entry');
    await tester.enterText(find.byType(TextField), '4155550132');
    await shot('03-phone-complete');
    await tap(find.bySemanticsLabel('Country: United States, plus 1'));
    await shot('04-country-sheet');
    await tester.tap(find.bySemanticsLabel('Close').last);
    await tester.pump(const Duration(milliseconds: 600));

    await tap(fab);
    await tester.pump(const Duration(milliseconds: 600));
    final code = auth.latestMessage!.code;
    await tester.enterText(find.byType(TextField), code.substring(0, 3));
    await shot('05-verify-typing');
    final wrong = code == '000000' ? '111111' : '000000';
    await tester.enterText(find.byType(TextField), wrong);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/06-verify-error.png'),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.enterText(find.byType(TextField), code);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/07-verify-success.png'),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('08-setup-hub');

    await tap(find.text('Build my profile'));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('09-basics-empty');
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Sam');
    await tester.enterText(fields.at(1), '2012');
    await shot('10-basics-underage');
    await tester.enterText(fields.at(1), '1995');
    await tap(find.text('Nonbinary'));
    await tap(find.text('A long-term relationship'));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('11-basics-complete');
    await tap(fab);
    await tester.pump(const Duration(milliseconds: 600));

    await shot('12-interests-empty');
    for (final i in ['Natural wine', 'Cooking', 'Jazz', 'Poetry', 'Climbing']) {
      await tap(find.text(i));
    }
    await shot('12b-interests-max');
    for (final i in ['Poetry', 'Climbing']) {
      await tap(find.text(i));
    }
    for (final i in <String>[]) {
      await tap(find.text(i));
    }
    await tap(find.text('Tap to write your answer'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(
      find.byType(TextField).last,
      'A record shop, a long walk, and nowhere to be after.',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('13-prompt-editor');
    await tap(find.text('Save prompt'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 600),
    );
    await shot('14-interests-complete');
    await tap(fab);
    await tester.pump(const Duration(milliseconds: 600));

    await tap(find.bySemanticsLabel('Add a photo').first);
    await tap(find.bySemanticsLabel('Add a photo').first);
    await tap(find.bySemanticsLabel('Add a photo').first);
    await shot('15-photos');
    await tap(fab);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 3));
    await shot('16-home');
    await tap(find.bySemanticsLabel('Filters'));
    await shot('17-filters');
    await tester.tap(find.bySemanticsLabel('Close').last);
    await tester.pump(const Duration(seconds: 3));
    await tap(find.text('Likes'));
    await shot('18-likes');
    await tap(find.text('Messages'));
    await shot('19-messages');
    await tap(find.text('Profile'));
    await shot('20-profile');
    await tap(find.text('Edit profile'));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('21-edit-profile');
    await tap(find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 600));
    await tap(find.bySemanticsLabel('Settings').first);
    await tester.pump(const Duration(milliseconds: 600));
    await shot('22-settings');
    await tap(find.text('Delete account'));
    await tester.pump(const Duration(milliseconds: 600));
    await tap(find.text('I met someone'));
    await tap(find.text('Continue'));
    await shot('23-delete-sheet');
    await tester.tap(find.bySemanticsLabel('Close').last);
    await tester.pump(const Duration(seconds: 3));
  });

  /// Dating screens, named after the V16 capture they compare with (019 Discover … 113 Snooze).
  testWidgets('capture dating screens', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await signUpToHome(tester, testAuth());

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/d$name.png'),
      );
    }

    Future<void> sheetShot(String name) async {
      await tester.pumpAndSettle();
      await shot(name);
    }

    Future<void> closeSheet() async {
      await tester.tap(find.bySemanticsLabel('Close').last);
      await tester.pumpAndSettle();
    }

    await shot('019-discover');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -900),
    );
    await shot('021-discover-you-both-like');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -3000),
    );
    await shot('022-discover-actions');
    await tapOn(tester, find.bySemanticsLabel('Filters'));
    await sheetShot('023-discover-filters-sheet');
    await closeSheet();
    await tapOn(tester, find.bySemanticsLabel('Profile options'));
    await sheetShot('027-home-profile-options');
    await tapOn(tester, find.text('Cancel'));
    await tester.pumpAndSettle();

    // Likes before any match.
    await openTab(tester, 'Likes');
    await shot('054-likes');
    await tapOn(tester, find.bySemanticsLabel(RegExp('^Maya, 29')));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('059-like-profile');
    await tapOn(tester, find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Messages');
    await shot('037-chats-empty');

    // Match with Maya from Home.
    await openTab(tester, 'Home');
    await tapOn(tester, find.bySemanticsLabel('Like').last);
    await tester.pump(const Duration(milliseconds: 600));
    await shot('030-match');
    await tester.enterText(find.byType(TextField), 'Which record shop?');
    await shot('032-match-typing');
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(milliseconds: 600));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('038-chat-conversation');
    await tapOn(tester, find.bySemanticsLabel('Conversation options'));
    await sheetShot('044-chat-options-menu');
    await tapOn(tester, find.text('Unmatch'));
    await sheetShot('045-chat-unmatch-sheet');
    await closeSheet();
    await tapOn(tester, find.bySemanticsLabel('Conversation options'));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Report'));
    await sheetShot('047-chat-report-sheet');
    await closeSheet();
    await tapOn(tester, find.bySemanticsLabel('Back to messages'));
    await tester.pump(const Duration(milliseconds: 600));

    // Kemi from Likes: a new match with no messages.
    await openTab(tester, 'Likes');
    await tapOn(tester, find.bySemanticsLabel(RegExp('^Kemi, 27')));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('Like back'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('Keep browsing'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Messages');
    await shot('034-chats');
    await tapOn(tester, find.bySemanticsLabel('Message Kemi'));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('042-chat-new-match');
    await tapOn(tester, find.bySemanticsLabel('Back to messages'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Messages');
    await tapOn(tester, find.bySemanticsLabel('Unread, 0'));
    await shot('052-chats-filter-empty');

    // Discover: no one fits, then the snooze state.
    await openTab(tester, 'Home');
    while (find.text('No one fits your filters').evaluate().isEmpty) {
      await tapOn(tester, find.bySemanticsLabel('Pass').last);
      await tester.pump(const Duration(milliseconds: 300));
    }
    await shot('024-discover-no-one-fits');
    await openTab(tester, 'Profile');
    await tapOn(tester, find.bySemanticsLabel('Settings').first);
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.bySemanticsLabel(RegExp('^Snooze')));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Until I turn it off'));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('No thanks'));
    await tester.pumpAndSettle();
    await shot('113-settings-snooze-on');
    await tapOn(tester, find.text('Blocked people'));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('112b-blocked-empty');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('capture small-screen QA states (375 x 667)', (tester) async {
    tester.view.physicalSize = const Size(750, 1334);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await signUpToHome(tester, testAuth());

    Future<void> shot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/q$name.png'),
      );
    }

    await shot('145-qa-discover');
    await tapOn(tester, find.bySemanticsLabel('Like').last);
    await tester.pump(const Duration(milliseconds: 600));
    await shot('146-qa-match');
    await tester.enterText(
      find.byType(TextField),
      'I keep a list of record shops in every city I visit — tell me yours and I will add it.',
    );
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(milliseconds: 600));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('148-qa-chat-long-messages');
    await tapOn(tester, find.bySemanticsLabel('Back to messages'));
    await tester.pump(const Duration(milliseconds: 600));
    await openTab(tester, 'Messages');
    await shot('147-qa-chats');
    await openTab(tester, 'Likes');
    await shot('157-qa-likes');
    await openTab(tester, 'Profile');
    await shot('158-qa-profile');
    await tapOn(tester, find.bySemanticsLabel('Settings').first);
    await tester.pump(const Duration(milliseconds: 600));
    await shot('149-qa-settings');
    await tester.pump(const Duration(seconds: 3));
  });
}
