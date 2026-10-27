@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

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
    await tester.tapAt(const Offset(200, 40));
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
    await tester.tapAt(const Offset(200, 40));
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
    await shot('23-delete-sheet');
    await tester.tapAt(const Offset(200, 40));
    await tester.pump(const Duration(seconds: 3));
  });
}
