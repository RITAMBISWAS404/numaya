import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/compliments/domain/compliment.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/features/profile/domain/profile_details.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Selections pass (owner export fx-da197b7-2026-11-13, docs/design/selections/FINAL_REVIEW.md):
/// the chosen designs are what an ordinary build shows, with no Design Lab involved.
void main() {
  setUpAll(loadAppFonts);

  String path(ProviderContainer c) =>
      c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;

  test('the registry proposes the owner’s choices', () {
    String p(String id) => kLabGroups.firstWhere((g) => g.id == id).proposed;
    expect(p('fx-discover'), 'O');
    expect(p('fx-profile'), 'A');
    expect(p('fx-messages'), 'A');
    expect(p('fx-compliment-thread'), 'A');
    expect(p('fx-wallet'), 'O');
    expect(p('fx-streak'), 'O');
  });

  testWidgets(
    'without development tools the selected screens are the defaults',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, devTools: false);
      // A Design Lab choice cannot apply when development tools are off.
      c.read(labChoicesProvider.notifier).choose('fx-messages', 'B');

      await goTo(c, tester, Routes.profile);
      await settle(tester);
      expect(
        find.byKey(const ValueKey('profile-completion-pill')),
        findsOneWidget,
      );
      // The pill states the same percentage as Complete your profile.
      final percent = ProfileCompletion.of(
        c.read(onboardingProvider).draft,
        c.read(profileDetailsProvider),
      ).percent;
      expect(find.text('Profile $percent% complete'), findsOneWidget);
      await goTo(c, tester, Routes.completion);
      await settle(tester);
      expect(find.bySemanticsLabel('$percent% complete'), findsWidgets);
      await goTo(c, tester, Routes.profile);
      await settle(tester);
      expect(find.byKey(const ValueKey('hub-wallet')), findsOneWidget);
      expect(find.byKey(const ValueKey('hub-streak')), findsOneWidget);

      await goTo(c, tester, Routes.messages);
      await settle(tester);
      expect(find.textContaining('Your turn'), findsOneWidget);
      expect(find.textContaining('Waiting on them'), findsOneWidget);

      await goTo(c, tester, Routes.wallet);
      await settle(tester);
      expect(find.byKey(const ValueKey('wallet-summary')), findsOneWidget);

      await goTo(c, tester, Routes.streak);
      await settle(tester);
      expect(find.byKey(const ValueKey('streak-summary')), findsOneWidget);
    },
  );

  testWidgets(
    'a received Compliment is an incoming message quoting your photo; replying once is free',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, devTools: false);
      final balance = c.read(creditBalanceProvider);
      await goTo(c, tester, '${Routes.chat}/sam');
      await settle(tester);
      expect(find.byKey(const ValueKey('compliment-bubble')), findsOneWidget);
      expect(find.text('Your photo'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('compliment-sender-photo')),
        findsNothing,
      );
      await tester.enterText(find.byType(TextField).last, 'On a rooftop.');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await settle(tester);
      final n = c.read(complimentsProvider.notifier);
      expect(n.byId('seed-sam')!.status, ComplimentStatus.replied);
      expect(n.reply('seed-sam', 'again'), isFalse);
      expect(c.read(creditBalanceProvider), balance);
    },
  );

  testWidgets(
    'Welcome has a labelled demo entry; sign-out returns to Welcome',
    (tester) async {
      await usePhoneSize(tester);
      await tester.pumpWidget(testApp(devTools: false));
      await settle(tester);
      // Real sign-in stays first.
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.text('I have an account'), findsOneWidget);
      final demo = find.byKey(const ValueKey('welcome-demo'));
      expect(demo, findsOneWidget);
      await tester.ensureVisible(demo);
      await tester.tap(demo);
      await settle(tester);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(path(c), Routes.home);
      expect(c.read(sessionProvider), isNotNull);

      await c.read(sessionProvider.notifier).signOut();
      await settle(tester);
      expect(path(c), Routes.welcome);
      // Re-entry works and shows the same selected Profile.
      await tester.tap(find.byKey(const ValueKey('welcome-demo')));
      await settle(tester);
      await goTo(c, tester, Routes.profile);
      await settle(tester);
      expect(
        find.byKey(const ValueKey('profile-completion-pill')),
        findsOneWidget,
      );
    },
  );

  testWidgets('the credits number agrees on Profile and the credits screen', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, devTools: false);
    final total = c.read(creditBalanceProvider);
    await goTo(c, tester, Routes.profile);
    await settle(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('hub-wallet')),
        matching: find.text('$total'),
      ),
      findsOneWidget,
    );
    await goTo(c, tester, Routes.wallet);
    await settle(tester);
    expect(find.textContaining(RegExp('^$total credit')), findsOneWidget);
  });
}
