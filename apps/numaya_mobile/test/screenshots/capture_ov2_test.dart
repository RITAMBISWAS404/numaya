@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Overnight v2 route inventory: every route, onboarding step and main overlay, rendered with
/// the deterministic demo data at 390pt wide and 1400pt tall (2x) so most scroll ranges fit in
/// one frame. Writes `test/screenshots/comparison/ov2/<set>/<name>.png`, where `<set>` is
/// `--dart-define=OV2_SET=before|after`.
/// Opt-in: `flutter test --tags comparison --run-skipped --update-goldens <this file>`.
void main() {
  setUpAll(loadAppFonts);
  const set = String.fromEnvironment('OV2_SET', defaultValue: 'after');

  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(780, 2800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('comparison/ov2/$set/$name.png'),
    );
  }

  // Signed in with the full demo (quick start as Alex).
  const signedIn = <(String, String)>[
    ('b01-discover', Routes.home),
    ('b02-for-you', Routes.forYou),
    ('b03-person-maya', '${Routes.person}/maya'),
    ('b04-like-kemi', '${Routes.like}/kemi'),
    ('b05-match-maya', '${Routes.match}/maya'),
    ('c01-likes', Routes.likes),
    ('c02-messages', Routes.messages),
    ('c03-chat-priya', '${Routes.chat}/priya'),
    ('c04-chat-jo', '${Routes.chat}/jo'),
    ('d01-profile', Routes.profile),
    ('d02-edit-profile', Routes.editProfile),
    ('d03-edit-basics', Routes.editBasics),
    ('d04-edit-interests', Routes.editInterests),
    ('d05-edit-photos', Routes.editPhotos),
    ('d06-edit-prompt', Routes.editPrompt),
    ('d07-completion', Routes.completion),
    ('d08-preview', Routes.preview),
    ('d09-verify-photo', Routes.verifyPhoto),
    ('d10-visibility', Routes.visibility),
    ('d11-visibility-about', Routes.visibilityAbout),
    ('e01-settings', Routes.settings),
    ('e02-notifications', Routes.notifications),
    ('e03-privacy', Routes.privacy),
    ('e04-blocked', Routes.blocked),
    ('e05-delete-account', Routes.deleteAccount),
    ('e06-help', Routes.help),
    ('e07-help-contact', Routes.helpContact),
    ('e08-safety', Routes.safety),
    ('e09-account-blocked', Routes.accountBlocked),
    ('f01-premium', Routes.premium),
    ('f02-paywall', Routes.paywall),
    ('g01-events', Routes.events),
    ('g02-events-mine', '${Routes.events}?view=mine'),
    ('g03-event-jazz', '${Routes.event}/e-jazz'),
    ('g04-event-people', '${Routes.event}/e-jazz/people'),
    ('g05-event-new', Routes.eventNew),
    ('h01-demo-hub', Routes.demo),
  ];
  for (final (name, route) in signedIn) {
    testWidgets('ov2 $name', (tester) async {
      tall(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, route);
      await shot(tester, name);
      await settle(tester);
    });
  }

  // Signed out.
  for (final (name, route) in const [
    ('a01-welcome', Routes.welcome),
    ('a02-phone', Routes.phone),
  ]) {
    testWidgets('ov2 $name', (tester) async {
      tall(tester);
      await tester.pumpWidget(testApp());
      await tester.pump();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      await goTo(c, tester, route);
      await shot(tester, name);
      await settle(tester);
    });
  }

  // Onboarding steps for a new account.
  for (final (name, route) in const [
    ('a03-setup-hub', Routes.setup),
    ('a04-setup-name', Routes.setupName),
    ('a05-setup-gender', Routes.setupGender),
    ('a06-setup-meet', Routes.setupMeet),
    ('a07-setup-intentions', Routes.setupIntentions),
    ('a08-setup-height', Routes.setupHeight),
    ('a09-setup-location', Routes.setupLocation),
    ('a10-setup-interests', Routes.interests),
    ('a11-setup-photos', Routes.photos),
    ('a12-setup-prompts', Routes.setupPrompts),
    ('a13-setup-bio', Routes.setupBio),
    ('a14-setup-verify', Routes.setupVerify),
    ('a15-setup-notifications', Routes.setupNotifications),
  ]) {
    testWidgets('ov2 $name', (tester) async {
      tall(tester);
      await tester.pumpWidget(testApp());
      await tester.pump();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      c.read(sessionProvider.notifier).quickStartOnboarding();
      await goTo(c, tester, route);
      await shot(tester, name);
      await settle(tester);
    });
  }

  // Overlays.
  Future<void> overlay(
    WidgetTester tester,
    String route,
    Finder open,
    String name,
  ) async {
    tall(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, route);
    await tester.tap(open.first);
    await tester.pumpAndSettle();
    await shot(tester, name);
    await settle(tester);
  }

  testWidgets('ov2 o01-filters', (tester) async {
    await overlay(
      tester,
      Routes.home,
      find.bySemanticsLabel('Filters'),
      'o01-filters',
    );
  });
  testWidgets('ov2 o02-chat-menu', (tester) async {
    await overlay(
      tester,
      '${Routes.chat}/priya',
      find.bySemanticsLabel('Conversation options'),
      'o02-chat-menu',
    );
  });
  testWidgets('ov2 o03-unmatch-sheet', (tester) async {
    tall(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    await tester.tap(find.bySemanticsLabel('Conversation options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unmatch').last);
    await tester.pumpAndSettle();
    await shot(tester, 'o03-unmatch-sheet');
    await settle(tester);
  });
  testWidgets('ov2 o04-report-sheet', (tester) async {
    tall(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    await tester.tap(find.bySemanticsLabel('Conversation options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report').last);
    await tester.pumpAndSettle();
    await shot(tester, 'o04-report-sheet');
    await settle(tester);
  });
  testWidgets('ov2 o05-attach-menu', (tester) async {
    await overlay(
      tester,
      '${Routes.chat}/priya',
      find.bySemanticsLabel('Add a photo'),
      'o05-attach-menu',
    );
  });
  testWidgets('ov2 o06-recovery-email', (tester) async {
    await overlay(
      tester,
      Routes.settings,
      find.text('Recovery email'),
      'o06-recovery-email',
    );
  });
}
