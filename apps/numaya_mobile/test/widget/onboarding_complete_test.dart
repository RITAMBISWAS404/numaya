import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/device_permissions.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/features/settings/application/account_prefs.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// The onboarding screens' states and recovery paths (ONBOARDING_MASTER_INVENTORY OB-05–OB-23,
/// ONBOARDING_EDGE_CASES). Each test starts a new demo account from the Demo Hub's "Start a new
/// sign-up", then opens the step under test.
void main() {
  setUpAll(loadAppFonts);

  Future<ProviderContainer> newAccount(WidgetTester tester) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(testApp());
    await tester.pump();
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    c.read(sessionProvider.notifier).quickStartOnboarding();
    await goTo(c, tester, Routes.setup);
    return c;
  }

  ProfileDraft draft(ProviderContainer c) => c.read(onboardingProvider).draft;

  /// Everything required, as the helpers' journey would leave it.
  void fillRequired(ProviderContainer c) {
    final o = c.read(onboardingProvider.notifier)
      ..setFirstName('Sam')
      ..setBirthDate(DateTime(1995, 4, 12))
      ..setGender(Gender.woman)
      ..setOpenToEveryone()
      ..toggleLookingFor(LookingFor.casual)
      ..addPhoto()
      ..addPhoto()
      ..setPrompt('A green flag', 'Remembers names.');
    for (final i in ['Jazz', 'Poetry', 'Travel']) {
      o.toggleInterest(i);
    }
  }

  testWidgets('every step opens from the Demo Hub and from the hub resume', (
    tester,
  ) async {
    final c = await newAccount(tester);
    expect(find.text('0 of 4 done'), findsOneWidget);
    await goTo(c, tester, Routes.demo);
    for (final title in [
      'Let’s start with an intro',
      'How do you identify?',
      'Who do you want to meet?',
      'What are you hoping to find?',
      'How tall are you?',
      'Where do you want to meet people?',
      'Pick prompts to share your story',
      'Write a short bio',
      'Verify your photos?',
      'Don’t miss a match',
    ]) {
      await tapOn(tester, find.text(title).first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text(title), findsWidgets, reason: title);
      expect(find.bySemanticsLabel('Next'), findsOneWidget, reason: title);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    // Resume: with About you done, the hub continues at Who you want to meet.
    fillRequired(c);
    c.read(onboardingProvider.notifier)
      ..completeStep(SetupStep.name)
      ..completeStep(SetupStep.gender);
    await goTo(c, tester, Routes.setup);
    expect(find.text('1 of 4 done'), findsOneWidget);
    await tapOn(tester, find.text('Continue my profile'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Who do you want to meet?'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('repeated Continue taps open one age confirmation', (
    tester,
  ) async {
    final c = await newAccount(tester);
    await goTo(c, tester, Routes.setupName);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Sam');
    await tester.enterText(fields.at(1), '12');
    await tester.enterText(fields.at(2), '04');
    await tester.enterText(fields.at(3), '1995');
    await tester.pump();
    await tester.tap(fab);
    await tester.tap(fab, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Confirm'), findsOneWidget);
    await tapOn(tester, find.text('Confirm'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('How do you identify?'), findsOneWidget);
    expect(draft(c).birthDate, DateTime(1995, 4, 12));
    await settle(tester);
  });

  testWidgets(
    'location: denied, then blocked, then a manual area; a grant sets the sample area',
    (tester) async {
      final c = await newAccount(tester);
      await goTo(c, tester, Routes.setupLocation);
      await tapOn(tester, find.text('Use my location'));
      expect(
        find.text('Allow Numaya to access this device’s location?'),
        findsOneWidget,
      );
      await tapOn(tester, find.text('Don’t allow'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Location is off'), findsOneWidget);
      await tapOn(tester, find.text('Try again'));
      await tapOn(tester, find.text('Don’t allow'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Location is blocked for Numaya'), findsOneWidget);
      expect(find.text('Use my location'), findsNothing);
      await tapOn(tester, find.text('Open settings'));
      expect(
        find.text('Demo build: this would open Numaya’s Android settings.'),
        findsOneWidget,
      );

      // Manual area: search, no results, then a pick.
      await tapOn(tester, find.text('Choose my area instead'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField).last, 'zzz');
      await tester.pump();
      expect(find.text('No areas match “zzz”'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'bris');
      await tester.pump();
      await tapOn(tester, find.text('Bristol'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.read(profileDetailsProvider).area, 'Bristol');
      expect(c.read(profileDetailsProvider).areaFromDevice, isFalse);
      expect(find.text('Location is blocked for Numaya'), findsNothing);

      // A fresh grant (approximate) sets the sample area, labelled as such.
      c.read(devicePermissionsProvider.notifier).reset();
      c.read(profileDetailsProvider.notifier).setArea(null);
      await tester.pump();
      await tapOn(tester, find.text('Use my location'));
      await tapOn(tester, find.text('While using the app · approximate'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Hackney, London (sample area)'), findsOneWidget);
      expect(
        c.read(devicePermissionsProvider).of(DevicePermission.location),
        PermissionStatus.granted,
      );
      await settle(tester);
    },
  );

  testWidgets('photos: camera denied adds nothing; library and cancel', (
    tester,
  ) async {
    final c = await newAccount(tester);
    await goTo(c, tester, Routes.photos);
    await tapOn(tester, find.bySemanticsLabel('Add a photo').first);
    await tapOn(tester, find.text('Take a photo'));
    await tapOn(tester, find.text('Don’t allow'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(draft(c).photos, isEmpty);
    expect(find.text('Camera is off for Numaya'), findsOneWidget);
    // Cancelling the source sheet changes nothing.
    await tapOn(tester, find.bySemanticsLabel('Add a photo').first);
    await tapOn(tester, find.bySemanticsLabel('Cancel').last);
    await tester.pump(const Duration(milliseconds: 600));
    expect(draft(c).photos, isEmpty);
    await addLibraryPhoto(tester);
    expect(draft(c).photos, hasLength(1));
    // Tips are guidance, not a scan.
    await tapOn(tester, find.text('Photo tips'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('These are tips. Numaya doesn’t scan your photos.'),
      findsOneWidget,
    );
    await settle(tester);
  });

  testWidgets('notifications: allow sets push on; a denial turns it off', (
    tester,
  ) async {
    final c = await newAccount(tester);
    await goTo(c, tester, Routes.setupNotifications);
    await tapOn(tester, find.text('Allow notifications'));
    await tapOn(tester, find.text('Don’t allow'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('Notifications are off. You can turn them on in Settings.'),
      findsWidgets,
    );
    expect(
      c
          .read(accountPrefsProvider)
          .isOn(NotificationCategory.messages, NotificationChannel.push),
      isFalse,
    );
    await tapOn(tester, find.text('Allow notifications'));
    await tapOn(tester, find.text('Allow'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Notifications are on.'), findsWidgets);
    expect(
      c
          .read(accountPrefsProvider)
          .isOn(NotificationCategory.messages, NotificationChannel.push),
      isTrue,
    );
    // Optional: continuing without answering is allowed too.
    expect(fabEnabled(tester), isTrue);
    await settle(tester);
  });

  testWidgets('prompts: a question can only be used once; up to three', (
    tester,
  ) async {
    final c = await newAccount(tester);
    await goTo(c, tester, Routes.setupPrompts);
    expect(fabEnabled(tester), isFalse);
    await tapOn(tester, find.text('Add a prompt'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('A green flag'));
    await tester.enterText(find.byType(TextField).last, 'Remembers names.');
    await tester.pump();
    await tapOn(tester, find.text('Save prompt'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('1 of 3 answered'), findsOneWidget);

    await tapOn(tester, find.text('Add a prompt'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Already answered'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('^A green flag'))),
      isSemantics(isEnabled: false, hasEnabledState: true),
    );
    // Leaving without Save keeps nothing.
    await tester.enterText(find.byType(TextField).last, 'Draft only');
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(profileDetailsProvider).extraPrompts, isEmpty);

    for (final answer in ['Pastries.', 'Pineapple on pizza.']) {
      await tapOn(tester, find.text('Add a prompt'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField).last, answer);
      await tester.pump();
      await tapOn(tester, find.text('Save prompt'));
      await tester.pump(const Duration(milliseconds: 600));
    }
    expect(find.text('3 of 3 answered'), findsOneWidget);
    expect(find.text('Add a prompt'), findsNothing);
    final questions = {
      draft(c).prompt!.question,
      for (final p in c.read(profileDetailsProvider).extraPrompts) p.question,
    };
    expect(questions, hasLength(3));
    await settle(tester);
  });

  testWidgets('interests: search, no results, clear', (tester) async {
    final c = await newAccount(tester);
    await goTo(c, tester, Routes.interests);
    await tester.enterText(find.byType(TextField), 'ja');
    await tester.pump();
    expect(find.text('Jazz'), findsOneWidget);
    expect(find.text('Cooking'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No interests match “zzz”'), findsOneWidget);
    await tapOn(tester, find.text('Clear search').last);
    expect(find.text('Cooking'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('height: units, limits, remove; skip clears it', (tester) async {
    final c = await newAccount(tester);
    await goTo(c, tester, Routes.setupHeight);
    await tapOn(tester, find.text('Add my height'));
    expect(find.text('170 cm'), findsOneWidget);
    await tapOn(tester, find.text('ft / in'));
    expect(find.text('5′ 7″'), findsOneWidget);
    await tapOn(tester, find.bySemanticsLabel('Shorter'));
    expect(c.read(profileDetailsProvider).heightCm, 169);
    c.read(profileDetailsProvider.notifier).setHeight(140);
    await tester.pump();
    final shorter = tester.getSemantics(find.bySemanticsLabel('Shorter'));
    expect(shorter, isSemantics(isEnabled: false, hasEnabledState: true));
    await tapOn(tester, find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(profileDetailsProvider).heightCm, isNull);
    expect(find.text('Where do you want to meet people?'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('bio: whitespace is no bio; text shows a preview; clear', (
    tester,
  ) async {
    final c = await newAccount(tester);
    await goTo(c, tester, Routes.setupBio);
    await tester.enterText(find.byType(TextField), '    ');
    await tester.pump();
    expect(c.read(profileDetailsProvider).bio, isEmpty);
    expect(find.text('How it reads on your profile'), findsNothing);
    await tester.enterText(find.byType(TextField), ' Weekend baker. ');
    await tester.pump();
    expect(c.read(profileDetailsProvider).bio, 'Weekend baker.');
    expect(find.text('How it reads on your profile'), findsOneWidget);
    await tapOn(tester, find.text('Clear'));
    expect(c.read(profileDetailsProvider).bio, isEmpty);
    await settle(tester);
  });

  testWidgets(
    'review: missing items block Create; Edit returns to the review',
    (tester) async {
      final c = await newAccount(tester);
      await goTo(c, tester, Routes.setupReview);
      expect(find.text('Before you can finish'), findsOneWidget);
      for (final item in [
        'Add your first name',
        'Choose who you want to meet',
        'Add at least 2 photos',
        'Answer a prompt',
      ]) {
        expect(find.text(item), findsOneWidget, reason: item);
      }
      final create = find.widgetWithText(NumayaButton, 'Create my profile');
      expect(tester.widget<NumayaButton>(create).onPressed != null, isFalse);

      fillRequired(c);
      c.read(onboardingProvider.notifier).setFirstName('');
      await tester.pump();
      expect(find.text('Add your first name'), findsOneWidget);
      await tapOn(tester, find.text('Add your first name'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField).first, 'Sam');
      await tester.pump();
      await tapNext(tester);
      await tapOn(tester, find.text('Confirm'));
      await tester.pump(const Duration(milliseconds: 600));
      // Back on the review, not on to Gender.
      expect(find.text('Before you can finish'), findsNothing);
      expect(find.text('Create my profile'), findsOneWidget);
      expect(tester.widget<NumayaButton>(create).onPressed != null, isTrue);
      await settle(tester);
    },
  );

  testWidgets(
    'create: a failure keeps everything and retries; double taps create once',
    (tester) async {
      final c = await newAccount(tester);
      fillRequired(c);
      c.read(datingProvider.notifier).setSimulateErrors(true);
      await goTo(c, tester, Routes.setupReview);
      await tapOn(tester, find.text('Create my profile'));
      await tester.pump(const Duration(milliseconds: 800));
      expect(
        find.text(
          'Couldn’t create your profile. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(c.read(sessionProvider)!.hasProfile, isFalse);
      expect(draft(c).firstName, 'Sam');

      c.read(datingProvider.notifier).setSimulateErrors(false);
      await tester.ensureVisible(find.text('Create my profile'));
      await tester.pump();
      await tester.tap(find.text('Create my profile'));
      await tester.tap(find.text('Create my profile'), warnIfMissed: false);
      await tester.pump();
      expect(c.read(onboardingProvider).creating, isTrue);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('You’re all set, Sam'), findsOneWidget);
      expect(c.read(sessionProvider)!.hasProfile, isTrue);
      // Back from All set goes to Home, never into setup.
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        c.read(routerProvider).routerDelegate.currentConfiguration.uri.path,
        Routes.home,
      );
      await settle(tester);
    },
  );

  testWidgets('verification offer opens the simulated flow and can wait', (
    tester,
  ) async {
    final c = await newAccount(tester);
    await goTo(c, tester, Routes.setupVerify);
    expect(
      find.textContaining('Demo build: verification is simulated.'),
      findsOneWidget,
    );
    await tapOn(tester, find.text('Verify now'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.bySemanticsLabel('Photo verification'), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('Maybe later'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Don’t miss a match'), findsOneWidget);
    expect(c.read(onboardingProvider).completed, contains(SetupStep.verify));
    await settle(tester);
  });
}
