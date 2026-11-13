// Capture-only tooling for the MVP PRD screen gallery (not part of the product or the CI suite).
//
// Runs on an emulator: tool/capture_mvp_gallery.sh drives
//   flutter test integration_test/mvp_gallery_test.dart -d <device>
// At each capture point this prints `@@CAP@@|<file>|<S-ID>|<state>` and waits until the host has
// taken a real device screenshot (adb screencap) and touched the ack file in the app's cache. It
// drives the production screens with the deterministic demo world (fixed clock, sample people,
// labelled demo data); nothing is sent anywhere.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/account_health/application/visibility_report.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/commerce/application/economy_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';

import '../test/helpers/journeys.dart';
import '../test/helpers/test_app.dart';

final _ack = File('/data/user/0/com.numaya.numaya_mobile/cache/ui_review_ack');
var _n = 1;

Future<void> _wait(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _slug(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

/// One capture: settle, announce, wait for the host's screenshot.
Future<void> cap(
  WidgetTester tester,
  String sid,
  String state, {
  int settleMs = 1000,
  bool keepFocus = false,
}) async {
  if (!keepFocus) FocusManager.instance.primaryFocus?.unfocus();
  await _wait(tester, settleMs);
  final file =
      '${_n.toString().padLeft(3, '0')}__${_slug(sid)}__${_slug(state)}.png';
  _n++;
  if (_ack.existsSync()) _ack.deleteSync();
  // ignore: avoid_print
  print('@@CAP@@|$file|$sid|$state');
  for (var i = 0; i < 150; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (_ack.existsSync()) {
      _ack.deleteSync();
      return;
    }
  }
  // ignore: avoid_print
  print('@@MISS@@|$file');
}

/// Runs one capture step; a failure is reported and the gallery continues.
Future<void> step(String what, Future<void> Function() body) async {
  try {
    await body();
  } catch (e) {
    // ignore: avoid_print
    print('@@SKIP@@|$what|${e.toString().split('\n').first}');
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(DemoPhotoLibrary.load);

  testWidgets('onboarding S01-S10', (tester) async {
    // Live frames on a device: the fake-timer sign-up journey is not used here; each step is
    // opened by route, as in ui_review_capture_test.dart.
    await tester.pumpWidget(testApp(auth: testAuth()));
    await _wait(tester, 1500);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    await cap(tester, 'S01', 'Welcome');
    await step('S45 signed out', () async {
      await goTo(c, tester, '${Routes.legal}/terms');
      await cap(tester, 'S45', 'Terms readable before login');
    });
    await goTo(c, tester, Routes.phone);
    await cap(tester, 'S02', 'Phone');
    await step('S03', () async {
      await tester.enterText(find.byType(TextField).last, '4155550132');
      await _wait(tester, 300);
      await tapNext(tester);
      await cap(tester, 'S03', 'OTP code resend timer', settleMs: 1500);
    });
    c.read(sessionProvider.notifier).quickStartOnboarding();
    for (final (path, sid, name) in [
      (Routes.setup, 'S04', 'Setup hub'),
      (Routes.setupName, 'S04', 'Name and date of birth 18 plus'),
      (Routes.setupUnderage, 'S04', 'Under 18 no profile'),
      (Routes.setupGender, 'S05', 'Gender and pronouns'),
      (Routes.setupMeet, 'S06', 'Who to meet and age range'),
      (Routes.setupIntentions, 'S06', 'Relationship intention'),
      (Routes.setupLocation, 'S07', 'Location'),
      (Routes.photos, 'S08', 'Photos 2 to 6 demo moderation note'),
      (Routes.setupPrompts, 'S09', 'Prompts'),
      (Routes.setupBio, 'S09', 'Bio required'),
      (Routes.setupReview, 'S10', 'Review missing items'),
    ]) {
      await step(name, () async {
        await goTo(c, tester, path);
        await cap(tester, sid, name);
      });
    }
    await step('S10 complete', () async {
      c.read(onboardingProvider.notifier).loadSample();
      c.read(economyProvider.notifier).grantWelcome();
      await goTo(c, tester, Routes.setupReview);
      await cap(tester, 'S10', 'Review complete');
      await goTo(c, tester, Routes.setupDone);
      await cap(tester, 'S10', 'All set welcome credits');
    });
  });

  testWidgets('product S11-S46', (tester) async {
    final c = await quickStartApp(tester);
    c.read(onboardingProvider.notifier).loadSample();
    // A complete demo profile (the sample has no bio, which the MVP requires).
    c
        .read(profileDetailsProvider.notifier)
        .setBio('Weekend baker, weekday map nerd. Always up for a long walk.');
    Future<void> go(String path) => goTo(c, tester, path);

    await step('S11', () async {
      await go(Routes.home);
      await cap(tester, 'S11', 'Discover card quota and Compliment anchors');
      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, -700));
      await cap(tester, 'S11', 'Discover profile prompt anchors');
    });
    await step('S12', () async {
      await go('${Routes.person}/noor?decide=1');
      await cap(tester, 'S12', 'Profile detail like pass compliment');
    });
    await step('S13', () async {
      await go(Routes.home);
      await tapOn(tester, find.bySemanticsLabel('Filters'));
      await cap(
        tester,
        'S13',
        'Filters free and Premium groups',
        settleMs: 1400,
      );
      await tester.pageBack();
    });
    await step('S14', () async {
      await go('${Routes.compliment}/noor?kind=prompt&index=0');
      await cap(tester, 'S14', 'Compliment composer on a prompt');
      await tester.enterText(
        find.byType(TextField).first,
        'Your sunrise-hike answer is exactly my kind of Sunday.',
      );
      await cap(tester, 'S14', 'Compliment composer typed', keepFocus: true);
      await go('${Routes.compliment}/lea?kind=photo&index=0');
      await cap(tester, 'S14', 'Compliment composer on a photo');
    });
    await step('S15', () async {
      await go('${Routes.match}/maya');
      await cap(tester, 'S15', 'Match with 24h timer');
    });
    await step('S16', () async {
      c
          .read(discoveryFiltersProvider.notifier)
          .save(const DiscoveryFilters(minAge: 60, maxAge: 60));
      await go(Routes.home);
      await cap(tester, 'S16', 'Supply empty no one fits');
      c.read(discoveryFiltersProvider.notifier).reset();
    });
    await step('S17', () async {
      await go(Routes.allowance);
      await cap(tester, 'S17', 'Allowance used free');
    });
    await step('S18', () async {
      await go(Routes.likes);
      await cap(tester, 'S18', 'Likes free locked');
      c.read(premiumProvider.notifier).setActive(true);
      await _wait(tester, 400);
      await cap(tester, 'S18', 'Likes Premium grid');
      await go('${Routes.like}/kemi');
      await cap(tester, 'S19', 'Incoming profile like back');
      c.read(premiumProvider.notifier).setActive(false);
    });
    await step('S20', () async {
      await go(Routes.messages);
      await cap(tester, 'S20', 'Chats requests pending matches conversations');
      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, -600));
      await cap(tester, 'S20', 'Chats expired entry');
    });
    await step('S21', () async {
      await go('${Routes.request}/seed-sam');
      await cap(tester, 'S21', 'Compliment request on a photo');
      await go('${Routes.request}/seed-chloe');
      await cap(tester, 'S21', 'Compliment request on a prompt');
    });
    await step('S22', () async {
      await go('${Routes.chat}/priya');
      await cap(tester, 'S22', 'Conversation active text only');
      await go('${Routes.chat}/lina');
      await cap(tester, 'S22', 'New match first message timer');
      await go('${Routes.chat}/ade');
      await cap(tester, 'S22', 'Expired chat read only history');
      await go('${Routes.chat}/ollie');
      await cap(tester, 'S22', 'Expired before first message');
    });
    // Visual Lab V2 R01: S23-S25 (check-in, expired chats, reconnection) are replaced by Archive.
    await step('S24', () async {
      await go(Routes.archive);
      await cap(tester, 'S24', 'Archive');
    });
    await step('S26', () async {
      await go('${Routes.chat}/priya');
      await tapOn(tester, find.bySemanticsLabel('Conversation options'));
      await cap(tester, 'S26', 'Chat actions mute unmatch block report');
      await tester.tapAt(const Offset(20, 80));
    });
    await step('S27', () async {
      await go(Routes.profile);
      await cap(tester, 'S27', 'Profile hub');
      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, -500));
      await cap(tester, 'S27', 'Profile hub activity');
    });
    await step('S28', () async {
      await go(Routes.editProfile);
      await cap(tester, 'S28', 'Edit profile');
    });
    await step('S29', () async {
      await go(Routes.health);
      await cap(tester, 'S29', 'Profile Health');
      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, -600));
      await cap(tester, 'S29', 'Profile Health last 7 days');
    });
    await step('S30', () async {
      await go(Routes.healthAbout);
      await cap(tester, 'S30', 'Health explanation');
      c.read(accountSignalsProvider.notifier).setNotice(NoticeState.restricted);
      await go(Routes.healthAbout);
      await cap(tester, 'S30', 'Health explanation restricted');
      c
          .read(accountSignalsProvider.notifier)
          .setNotice(NoticeState.unavailable);
      await go(Routes.health);
      await cap(tester, 'S29', 'Profile Health status unknown');
      c.read(accountSignalsProvider.notifier).reset();
    });
    await step('S31', () async {
      await go(Routes.insights);
      await cap(tester, 'S31', 'Insights free 7 days');
      c.read(premiumProvider.notifier).setActive(true);
      await go(Routes.insights);
      await tapOn(tester, find.textContaining('28 days'));
      await cap(tester, 'S31', 'Insights Premium 28 days');
    });
    await step('S32', () async {
      await go(Routes.streak);
      await cap(tester, 'S32', 'Streak with recovery open');
    });
    await step('S33', () async {
      await go(Routes.wallet);
      await cap(tester, 'S33', 'Wallet Premium weekly earned purchased');
      c.read(premiumProvider.notifier).setActive(false);
    });
    await step('S34', () async {
      await go(Routes.paywall);
      await cap(tester, 'S34', 'Premium plans provisional INR');
      await tapOn(tester, find.byKey(const ValueKey('plan-yearly')));
      await cap(tester, 'S34', 'Premium yearly selected renewal terms');
      await tapOn(tester, find.text('Continue with Yearly'));
      await cap(tester, 'S34', 'Demo checkout sheet', settleMs: 1400);
      await tester.tapAt(const Offset(20, 80));
      await go(Routes.premium);
      await cap(tester, 'S34', 'Premium overview free');
    });
    await step('S35', () async {
      await go(Routes.storeCompliments);
      await cap(tester, 'S35', 'Compliment pack');
    });
    await step('S36', () async {
      await go(Routes.storeRecovery);
      await cap(tester, 'S36', 'Streak recovery purchase');
    });
    await step('S37', () async {
      for (final r in [
        'success',
        'pending',
        'failed',
        'cancelled',
        'unavailable',
      ]) {
        await go('${Routes.storeOutcome}?kind=complimentPack&result=$r');
        await cap(tester, 'S37', 'Purchase outcome $r');
      }
    });
    await step('S38', () async {
      await go(Routes.settings);
      await cap(tester, 'S38', 'Settings');
      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, -900));
      await cap(tester, 'S38', 'Settings help legal subscription');
    });
    await step('S39', () async {
      await go(Routes.notifications);
      await cap(tester, 'S39', 'Notifications');
    });
    await step('S40', () async {
      await go(Routes.privacy);
      await cap(tester, 'S40', 'Privacy and pause');
    });
    await step('S41', () async {
      c.read(datingProvider.notifier).end('sasha', EndReason.blocked);
      await go(Routes.blocked);
      await cap(tester, 'S41', 'Blocked accounts');
    });
    await step('S42', () async {
      await go('${Routes.chat}/priya');
      await tapOn(tester, find.bySemanticsLabel('Conversation options'));
      await tapOn(tester, find.text('Report').last);
      await cap(tester, 'S42', 'Report reasons', settleMs: 1400);
      await tester.tapAt(const Offset(20, 80));
    });
    await step('S43', () async {
      await go(Routes.helpContact);
      await cap(tester, 'S43', 'Support and appeal form');
      await go(Routes.supportRequests);
      await cap(tester, 'S43', 'Support requests status');
    });
    await step('S44', () async {
      await go(Routes.deleteAccount);
      await cap(tester, 'S44', 'Delete account');
    });
    await step('S45', () async {
      await go(Routes.legal);
      await cap(tester, 'S45', 'Legal');
      await go('${Routes.legal}/privacy');
      await cap(tester, 'S45', 'Privacy notice draft');
      await go('${Routes.legal}/safety');
      await cap(tester, 'S45', 'Safety contacts');
    });
    await step('S46', () async {
      await go(Routes.accountBlocked);
      await cap(tester, 'S46', 'Account restricted appeal');
    });
    await step('S17-out', () async {
      c.read(economyProvider.notifier).exhaustLikes();
      await go(Routes.home);
      await cap(tester, 'S11', 'Discover out of likes');
    });
  });
}
