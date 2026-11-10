import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/features/verification/application/verification_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Review batch 3: Messages (UI-033, UI-034), Profile (UI-042, UI-031), completion (UI-046), the
/// basics (UI-044, UI-045) and the copy sweep (UI-041).
void main() {
  setUpAll(loadAppFonts);

  Future<ProviderContainer> open(WidgetTester tester, String route) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, route);
    return c;
  }

  group('UI-033/034 New matches', () {
    testWidgets(
      'no Likes tile (owner selection); R02: each match is a 3:4 photo in a '
      'squircle progress ring with no countdown or name below',
      (tester) async {
        final c = await open(tester, Routes.messages);
        final likes = c.read(datingProvider.notifier).unansweredLikes();
        // The Likes tile was removed from Chats (Likes has its own tab).
        expect(
          find.bySemanticsLabel(RegExp('^$likes people like you')),
          findsNothing,
        );
        // Owner selection O (v7 export): a circle inside a ring that empties.
        expect(find.byType(CountdownAvatar), findsWidgets);
        // R02 supersedes the MVP caption: no time under the avatar; it is spoken instead.
        expect(find.text('21h left'), findsNothing);
        expect(
          find.bySemanticsLabel(RegExp('^Jo, new match, 21h left')),
          findsOneWidget,
        );
        expect(find.text('Jo'), findsNothing);
        await settle(tester);
      },
    );
  });

  group('UI-042 Profile summary', () {
    testWidgets('large round photo over the card; name, state, Edit profile; '
        'no interests, details or globe', (tester) async {
      final c = await open(tester, Routes.profile);
      // Pins the O header this test describes; the owner's A is covered in visual_lab_v2.
      c.read(labChoicesProvider.notifier).choose('profile-header', 'O');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Alex, 30'), findsOneWidget);
      expect(find.text('Not verified'), findsWidgets);
      // The removed elements.
      expect(find.text('Jazz'), findsNothing);
      expect(find.textContaining('Looking for'), findsNothing);
      expect(find.bySemanticsLabel('Preview your profile'), findsNothing);
      // The photo is centred and overlaps the top edge of the card.
      final photo = tester.getRect(
        find.byKey(const ValueKey('profile-summary-photo')),
      );
      final name = tester.getRect(find.text('Alex, 30'));
      expect(photo.width, greaterThanOrEqualTo(128));
      expect(photo.center.dx, closeTo(name.center.dx, 1));
      expect(photo.bottom, lessThan(name.top));
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      expect(find.text('Edit profile'), findsWidgets);
      await settle(tester);
    });

    testWidgets('a verified profile says Verified', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      c.read(photoVerificationProvider.notifier).setApproveNext(true);
      final done = c.read(photoVerificationProvider.notifier).submit();
      await tester.pump(const Duration(seconds: 3));
      await done;
      await goTo(c, tester, Routes.profile);
      expect(find.text('Verified'), findsWidgets);
      expect(find.text('Not verified'), findsNothing);
      await settle(tester);
    });

    testWidgets('UI-031: no Opening Moves entry on the Profile tab', (
      tester,
    ) async {
      await open(tester, Routes.profile);
      expect(find.text('Opening Moves'), findsNothing);
      await settle(tester);
    });
  });

  group('UI-046 Complete your profile', () {
    testWidgets('percentage, bar and all six parts with counts', (
      tester,
    ) async {
      await open(tester, Routes.completion);
      expect(find.bySemanticsLabel(RegExp(r'^\d+% complete$')), findsWidgets);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      for (final part in [
        'Photos',
        'Prompts',
        'Interests',
        'Bio',
        'About you',
        'More about you',
      ]) {
        expect(find.text(part), findsOneWidget, reason: part);
        expect(
          find.descendant(
            of: find.byKey(ValueKey('completion-$part')),
            matching: find.textContaining(RegExp(r'\d+ of \d+ added')),
          ),
          findsOneWidget,
          reason: '$part count',
        );
      }
      // Type roles: the percentage is the metric, counts are muted captions.
      final metric =
          tester
                  .widget<Text>(
                    find
                        .byWidgetPredicate(
                          (w) =>
                              w is Text &&
                              w.textSpan != null &&
                              w.textSpan!.toPlainText().startsWith(
                                RegExp(r'\d+%'),
                              ),
                        )
                        .first,
                  )
                  .textSpan!
              as TextSpan;
      expect(
        metric.children!.first.style!.fontSize,
        AppTypography.metric.fontSize,
      );
      await settle(tester);
    });

    for (final (part, landmark) in [
      ('Photos', 'Edit profile'),
      ('Interests', 'Interests'),
      ('About you', 'Edit profile'),
      ('More about you', 'Edit profile'),
    ]) {
      testWidgets('$part opens its editor', (tester) async {
        await open(tester, Routes.completion);
        await tester.tap(find.text(part));
        await tester.pumpAndSettle();
        expect(find.text('Complete your profile'), findsNothing);
        expect(find.text(landmark), findsWidgets);
        await settle(tester);
      });
    }

    testWidgets('Prompts opens the prompt editor', (tester) async {
      await open(tester, Routes.completion);
      await tester.tap(find.text('Prompts'));
      await tester.pumpAndSettle();
      // The prompt browser (UI-008) opens first.
      expect(find.text('Complete your profile'), findsNothing);
      await settle(tester);
    });

    testWidgets('finishing the bio updates the progress on return', (
      tester,
    ) async {
      final c = await open(tester, Routes.completion);
      // Starts without a bio (the quick-start demo now has one, Visual Lab V2).
      c.read(profileDetailsProvider.notifier).setBio('');
      await tester.pump();
      String percent() => tester
          .widgetList<Semantics>(find.byType(Semantics))
          .map((s) => s.properties.label)
          .whereType<String>()
          .firstWhere((l) => RegExp(r'^\d+% complete$').hasMatch(l));
      final before = percent();
      await tester.tap(find.text('Bio'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Record shops, long walks and anything with cardamom.',
      );
      await tester.pump();
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect(percent(), isNot(before));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('completion-Bio')),
          matching: find.text('Done'),
        ),
        findsOneWidget,
      );
      await settle(tester);
    });
  });

  testWidgets('UI-044/045: Birthday sits on the list-card inset; its note is '
      'muted', (tester) async {
    await open(tester, Routes.editBasics);
    final card = tester.getRect(
      find.ancestor(of: find.text('Birthday'), matching: find.byType(ListRow)),
    );
    expect(
      tester.getTopLeft(find.text('Birthday')).dx - card.left,
      AppLayout.cardPadding,
    );
    expect(
      card.right - tester.getTopRight(find.text('April 12, 1996')).dx,
      closeTo(AppLayout.cardPadding, 0.5),
    );
    final note = tester.widget<Text>(
      find.text('Your birthday can’t be changed after setup.'),
    );
    expect(note.style!.color, AppColors.textMuted);
    await settle(tester);
  });

  testWidgets('UI-041: no sample or demo copy on Discover, Likes, Chat and '
      'Profile', (tester) async {
    final c = await open(tester, Routes.home);
    Future<void> check(String where) async {
      for (final s in [
        'Sample profile',
        'Sample profiles',
        'sample profile',
        'scripted',
        'Demo:',
        'Demo build',
        '(placeholder)',
      ]) {
        expect(find.textContaining(s), findsNothing, reason: '$where: $s');
      }
    }

    await check('Discover');
    await goTo(c, tester, Routes.likes);
    await check('Likes');
    await goTo(c, tester, '${Routes.chat}/priya');
    await check('Chat');
    await goTo(c, tester, Routes.profile);
    await check('Profile');
    await settle(tester);
  });
}
