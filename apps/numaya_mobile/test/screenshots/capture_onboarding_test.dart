@Tags(['screenshots'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/device_permissions.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';

import '../helpers/test_app.dart';

/// Every onboarding screen and its main states at 393 x 852 @2x, into goldens/oNN-*.png, for
/// docs/mobile/ONBOARDING_VISUAL_QA.md. Opt-in: `--tags screenshots --run-skipped`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('capture onboarding', (tester) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp(world: DemoWorld.fresh));
    await tester.pump();
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final o = c.read(onboardingProvider.notifier);
    final d = c.read(profileDetailsProvider.notifier);
    final perms = c.read(devicePermissionsProvider.notifier);

    Future<void> settleShot(String name) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/o$name.png'),
      );
    }

    Future<void> go(String path) async {
      c.read(routerProvider).go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    // Not awaited: push completes only when the page is closed.
    void push(String path) => unawaited(c.read(routerProvider).push(path));

    Future<void> tap(String text) async {
      await tester.ensureVisible(find.text(text).last);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(text).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> typeDate(String n, String dd, String mm, String yyyy) async {
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), n);
      await tester.enterText(fields.at(1), dd);
      await tester.enterText(fields.at(2), mm);
      await tester.enterText(fields.at(3), yyyy);
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
    }

    c.read(sessionProvider.notifier).quickStartOnboarding();
    await go(Routes.setup);
    await settleShot('01-hub-start');

    await go(Routes.setupName);
    await settleShot('02-name-empty');
    await typeDate('Sam', '31', '02', '1996');
    await settleShot('03-name-invalid-date');
    await typeDate('Sam', '01', '06', '2012');
    await settleShot('04-name-underage');
    await typeDate('Sam', '12', '04', '1995');
    await settleShot('05-name-valid');
    await tester.tap(find.bySemanticsLabel('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await settleShot('06-confirm-age');
    await tap('Confirm');

    await settleShot('07-gender');
    await tap('Nonbinary');
    for (final p in ['they', 'them']) {
      await tap(p);
    }
    await settleShot('08-gender-pronouns');

    await go(Routes.setupMeet);
    await settleShot('09-meet-empty');
    o
      ..toggleOpenTo(Gender.woman)
      ..toggleOpenTo(Gender.nonbinary);
    await tester.pump();
    await settleShot('10-meet-picked');

    await go(Routes.setupIntentions);
    o
      ..toggleLookingFor(LookingFor.longTerm)
      ..toggleLookingFor(LookingFor.open);
    await tester.pump();
    await settleShot('11-intentions-max');

    await go(Routes.setupHeight);
    await settleShot('12-height-empty');
    d.setHeight(172);
    await tester.pump();
    await settleShot('13-height-set');

    await go(Routes.setupLocation);
    await settleShot('14-location');
    perms.set(DevicePermission.location, PermissionStatus.denied);
    await tester.pump();
    await settleShot('15-location-denied');
    perms.set(DevicePermission.location, PermissionStatus.permanentlyDenied);
    await tester.pump();
    await settleShot('16-location-blocked');
    perms.set(DevicePermission.location, PermissionStatus.notAsked);
    await tester.pump();
    await tap('Use my location');
    await settleShot('17-location-prompt');
    await tap('While using the app · approximate');
    await settleShot('18-location-set');
    await tap('Change area');
    await settleShot('19-area-sheet');
    await tester.tap(find.bySemanticsLabel('Close').last);
    await tester.pump(const Duration(milliseconds: 600));

    await go(Routes.photos);
    await settleShot('20-photos-empty');
    await tester.tap(find.bySemanticsLabel('Add a photo').first);
    await tester.pump(const Duration(milliseconds: 600));
    await settleShot('21-photo-source');
    await tap('Choose from library');
    o.addPhoto();
    await tester.pump();
    perms.set(DevicePermission.camera, PermissionStatus.denied);
    await tester.pump();
    await settleShot('22-photos-two-camera-denied');
    perms.set(DevicePermission.camera, PermissionStatus.granted);
    await tap('Photo tips');
    await settleShot('23-photo-tips');
    await tester.tap(find.bySemanticsLabel('Close').last);
    await tester.pump(const Duration(milliseconds: 600));

    await go(Routes.interests);
    await settleShot('24-interests-empty');
    for (final i in ['Jazz', 'Cooking', 'Climbing', 'Poetry', 'Travel']) {
      o.toggleInterest(i);
    }
    await tester.pump();
    await settleShot('25-interests-max');
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await settleShot('26-interests-no-results');

    await go(Routes.setupPrompts);
    await settleShot('27-prompts-empty');
    o.setPrompt('A green flag', 'Remembers the name of your dog.');
    await tester.pump();
    await settleShot('28-prompts-one');
    push('${Routes.prompt}?slot=1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await settleShot('29-prompt-editor-used-question');
    c.read(routerProvider).pop();
    await tester.pump(const Duration(milliseconds: 600));

    await go(Routes.setupBio);
    await settleShot('30-bio-empty');
    await tester.enterText(
      find.byType(TextField),
      'Weekday baker, weekend hill walker. Will trade cardamom buns for good book tips.',
    );
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await settleShot('31-bio-preview');

    await go(Routes.setupVerify);
    await settleShot('32-verify-offer');

    await go(Routes.setupNotifications);
    await settleShot('33-notifications');
    perms.set(DevicePermission.notifications, PermissionStatus.denied);
    await tester.pump();
    await settleShot('34-notifications-denied');

    await go(Routes.setupReview);
    o.setFirstName('Sam');
    await tester.pump();
    await settleShot('35-review');
    o.setFirstName('');
    await tester.pump();
    await settleShot('36-review-missing');
    o.setFirstName('Sam');
    c.read(datingProvider.notifier).setSimulateErrors(true);
    await tester.pump();
    await tap('Create my profile');
    await tester.pump(const Duration(milliseconds: 800));
    await settleShot('37-review-failed');
    c.read(datingProvider.notifier).setSimulateErrors(false);
    await tap('Create my profile');
    await tester.pump(const Duration(milliseconds: 800));
    await settleShot('38-all-set');

    // Under 18 (a new sign-up).
    c.read(sessionProvider.notifier).quickStartOnboarding();
    await go(Routes.setupName);
    await typeDate('Kit', '01', '06', '2012');
    await tester.tap(find.bySemanticsLabel('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tap('Confirm');
    await settleShot('39-underage');
  });
}
