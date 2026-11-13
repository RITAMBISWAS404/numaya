import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/data/demo_auth_repository.dart';

import '../helpers/journeys.dart'
    show finishProfileToHome, setPremium, signUpToInterests, tapNext;
import '../helpers/test_app.dart';

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  await tester.tap(f.first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Signs up through the real screens and stops on the Interests step.
Future<void> _toInterests(WidgetTester tester, DemoAuthRepository auth) =>
    signUpToInterests(tester, auth);

/// Continues from Interests to Home.
Future<void> _toHome(WidgetTester tester) => finishProfileToHome(tester);

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
    // UI-054 (V8): the footer is the count.
    expect(find.text('5/5 interests'), findsOneWidget);
    final travel = tester.widget<NumayaChip>(
      find.ancestor(of: find.text('Travel'), matching: find.byType(NumayaChip)),
    );
    expect(travel.available, isFalse);
    await settle(tester);
  });

  testWidgets('prompt editor: Save stays disabled until there is an answer', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await _toInterests(tester, testAuth());
    for (final i in ['Jazz', 'Poetry', 'Travel']) {
      await _tap(tester, find.text(i));
    }
    await tapNext(tester);
    await _tap(tester, find.text('Add a prompt'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Your prompt'), findsOneWidget);
    // UI-008: the answer is written in the prompt's sheet.
    await _tap(tester, find.text('A perfect first date'));
    await tester.pump(const Duration(milliseconds: 600));
    // UI-055 (V8): no helper line; the outlined disabled Save says it (UI-057).
    expect(find.text('Write an answer to save.'), findsNothing);
    expect(find.text('150 characters left'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Hello');
    await tester.pump();
    expect(find.text('145 characters left'), findsOneWidget);
    // UI-055 (V8): no helper line under Save.
    expect(
      find.text('Saved prompts show on your profile straight away.'),
      findsNothing,
    );
    await _tap(tester, find.text('Save prompt'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Hello'), findsOneWidget);
    // Reopening the saved prompt with nothing changed: no changes yet.
    await _tap(tester, find.text('Hello'));
    await tester.pump(const Duration(milliseconds: 600));
    await _tap(tester, find.text('A perfect first date'));
    await tester.pump(const Duration(milliseconds: 600));
    // UI-055/057 (V8): Save stays outlined and disabled with nothing changed; no helper line.
    expect(find.text('No changes yet.'), findsNothing);
    expect(
      tester
          .widget<NumayaButton>(
            find.widgetWithText(NumayaButton, 'Save prompt'),
          )
          .onPressed,
      isNull,
    );
    await settle(tester);
  });

  testWidgets('Likes empty state (every like answered) sends people to Home', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await _toInterests(tester, testAuth());
    await _toHome(tester);
    await _tap(tester, find.byTooltip('Likes'));
    // S18: answering likes from the grid is a Premium view.
    await setPremium(tester);
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
    await _tap(tester, find.byTooltip('Profile'));
    expect(find.text('Sam, 31'), findsOneWidget);
    // UI-042: the summary holds the name, verification state and Edit profile; gender and
    // intentions stay in Edit profile and the preview.
    expect(
      find.bySemanticsLabel('Woman, Looking for something casual'),
      findsNothing,
    );
    await _tap(tester, find.bySemanticsLabel('Settings'));
    await tester.pump(const Duration(milliseconds: 600));
    await _tap(tester, find.text('Delete account'));
    await tester.pump(const Duration(milliseconds: 600));
    // B-75: a reason first; Continue waits for one.
    expect(find.text('I met someone'), findsOneWidget);
    final cont = find.widgetWithText(NumayaButton, 'Continue');
    expect(tester.widget<NumayaButton>(cont).onPressed, isNull);
    await _tap(tester, find.text('I met someone'));
    await _tap(tester, cont);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Changed your mind? Sign in with the same number within 28 days to restore it.',
      ),
      findsOneWidget,
    );
    await _tap(tester, find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.textContaining('within 28 days to restore'), findsNothing);
    expect(find.text('I met someone'), findsOneWidget);
    await _tap(tester, cont);
    await tester.pumpAndSettle();
    await _tap(tester, find.widgetWithText(NumayaButton, 'Delete account'));
    await settle(tester);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
