// Events MVP review capture: drives the real app on an Android emulator through the member
// journey (browse → reserve → My events → reconfirm → cancel → People I met → mutual → chat), the
// failure scenarios (full, offline), the selected visual components, the Health fallback, and the
// internal demo tools. Same host protocol as visual_lab_gallery_test.dart: at each capture point it
// prints `@@CAP@@|<file>|<group>|<variant>|<kind>|<scale>|<fixture>|<label>` and waits for the host
// (tool/capture_visual_lab.sh with TEST=integration_test/events_review_test.dart) to take a real
// `adb screencap` and touch the ack file. Fixed demo clock (2026-10-27 12:00), full demo world.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/events_mvp/application/events_mvp_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../test/helpers/journeys.dart';

final _ack = File('/data/user/0/com.numaya.numaya_mobile/cache/ui_review_ack');

Future<void> _wait(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(DemoPhotoLibrary.load);

  testWidgets('events review', (tester) async {
    final c = await quickStartApp(tester);
    c.read(onboardingProvider.notifier).loadSample();
    var n = 0;

    Future<void> cap(
      String name,
      String label, {
      String area = 'member',
    }) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await _wait(tester, 900);
      if (_ack.existsSync()) _ack.deleteSync();
      n++;
      final file = area == 'internal'
          ? 'internal__${n.toString().padLeft(2, '0')}-$name'
          : '${n.toString().padLeft(2, '0')}-$name';
      // ignore: avoid_print
      print('@@CAP@@|$file.png|$area|-|screen|1.0|demo|$label');
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

    /// One step; a failure is reported and the journey continues.
    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
      } on Object catch (e) {
        // ignore: avoid_print
        print('@@SKIP@@|$name|${e.toString().split('\n').first}');
      }
    }

    Future<void> go(String path) async {
      await goTo(c, tester, path);
      await _wait(tester, 500);
    }

    Future<void> tapKey(String key) async {
      await tapOn(tester, find.byKey(ValueKey(key)));
      await _wait(tester, 700);
    }

    Future<void> scrollTo(String key) async {
      await tester.scrollUntilVisible(
        find.byKey(ValueKey(key)),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await _wait(tester, 400);
    }

    // Selected visual components (owner's Visual Lab picks).
    await step('discover', () async {
      await go(Routes.home);
      await cap(
        'discover-five-tabs',
        'Discover O, photo O, subtle gradient, five tabs',
      );
    });
    await step('likes', () async {
      await go(Routes.likes);
      await cap(
        'likes-pills-like-tile-a',
        'Heart: Likes / Compliments pills, like tile A',
      );
    });
    await step('compliments', () async {
      await go('${Routes.likes}?tab=compliments');
      await cap(
        'compliments-card-o',
        'Compliment O: chevron card, tap opens detail',
      );
    });
    await step('chats', () async {
      await go(Routes.messages);
      await cap(
        'chats-ring-a-conversation-o',
        'New matches A (squircle 3:4), no likes tile, conversation O',
      );
    });
    await step('profile', () async {
      await go(Routes.profile);
      await cap(
        'profile-header-a',
        'Profile header A, setup D, streak O, wallet A',
      );
    });
    await step('health-fallback', () async {
      await go(Routes.health);
      await cap(
        'health-link-fallback',
        'Old Health link lands on Profile with a note',
      );
    });

    // E01 browse.
    await step('feed', () async {
      await go(Routes.events);
      await cap(
        'e01-events-feed',
        'E01 Events feed: city, date, category, sample label',
      );
    });
    await step('city', () async {
      await tapKey('ev-city');
      await cap('e01-city-sheet', 'E01 City picker (sample cities)');
      await tapKey('sheet-close');
      await _wait(tester, 600);
    });
    await step('empty-city', () async {
      c.read(eventsMvpProvider.notifier).setCity('Jaipur');
      await go(Routes.events);
      await cap(
        'e01-empty-city',
        'E01 Empty city (Jaipur): honest empty state',
      );
      c.read(eventsMvpProvider.notifier).setCity('Mumbai');
    });

    // E02 → E03 reserve.
    const board = 'ev-board-games-bandra';
    await step('detail', () async {
      await go('${Routes.evEvent}/$board');
      await cap('e02-event-detail', 'E02 Event detail');
    });
    await step('reserve', () async {
      await go('${Routes.evEvent}/$board/reserve');
      await tapKey('ev-ack');
      await cap(
        'e03-reserve-ack',
        'E03 Reserve: acknowledgement and event-only discoverability',
      );
      await tapKey('ev-confirm');
      await _wait(tester, 900);
      await cap('e03-reserved', 'E03 Reserved: reference, not a ticket');
    });

    // E04 / E05.
    await step('mine', () async {
      await go(Routes.evMine);
      await cap(
        'e04-my-events-upcoming',
        'E04 My events: upcoming, reconfirm needed',
      );
    });
    await step('reservation', () async {
      await go('${Routes.evReservation}/$board');
      await cap('e05-reservation', 'E05 Reservation detail');
    });

    // E06 material change and reconfirm.
    await step('notice', () async {
      await go('${Routes.evNotice}/n-walk-v2');
      await cap(
        'e06-material-change',
        'E06 Time/place change: reconfirm before the deadline',
      );
      await tapKey('ev-reconfirm');
      await cap('e06-reconfirmed', 'E06 Reconfirmed: the place is kept');
    });
    await step('ordinary-notice', () async {
      await go('${Routes.evNotice}/n-cycle-1');
      await cap('e06-ordinary-notice', 'E06 Ordinary announcement');
    });
    await step('cancelled-notice', () async {
      await go('${Routes.evNotice}/n-pottery-cancel');
      await cap(
        'e06-event-cancelled',
        'E06 Event cancelled; push failed, in-app record kept',
      );
    });

    // Cancellation by the member.
    await step('cancel', () async {
      await go('${Routes.evReservation}/$board');
      await scrollTo('ev-cancel');
      await tapKey('ev-cancel');
      await cap('e05-cancel-confirm', 'E05 Cancel: confirmation first');
      await tapKey('ev-cancel-confirm');
      await go(Routes.evMine);
      await tapKey('ev-mine-cancelled');
      await cap('e04-my-events-cancelled', 'E04 Cancelled, with reasons');
      await tapKey('ev-mine-past');
      await cap(
        'e04-my-events-past',
        'E04 Past: attended, no-show, window closed',
      );
    });

    // Failure scenarios.
    await step('full', () async {
      await go('${Routes.evEvent}/ev-coffee-indiranagar');
      await cap('e02-full', 'E02 Full: no reservation, alternatives offered');
    });
    await step('offline', () async {
      c.read(connectivityProvider.notifier).setOnline(false);
      await go('${Routes.evEvent}/ev-board-games-bandra/reserve');
      await tapKey('ev-ack');
      await tapKey('ev-confirm');
      await _wait(tester, 900);
      await cap(
        'e03-offline-error',
        'E03 Offline: nothing reserved, try again',
      );
      c.read(connectivityProvider.notifier).setOnline(true);
    });

    // E07 / E08 People I met → mutual → chat.
    await step('met', () async {
      await go('${Routes.evMet}/ev-book-swap');
      await cap(
        'e07-people-i-met',
        'E07 People I met: checked in and opted in only',
      );
      await tapKey('ev-interested-tomas');
      await cap(
        'e07-interest-sent',
        'E07 Interest sent privately; allowance shown',
      );
      await tapKey('ev-interested-sam');
      await cap('e08-mutual', 'E08 Mutual: one chat, existing rules');
      await tapKey('ev-mutual-chat');
      await _wait(tester, 600);
      await cap('e08-chat-opened', 'E08 Chat with Sam opened');
    });
    await step('report', () async {
      await go('${Routes.evEvent}/$board');
      await tapOn(tester, find.bySemanticsLabel('Report or get help'));
      await _wait(tester, 700);
      await cap('s01-report', 'S01 Report or get help');
    });

    // M01 / M02 (O1 open).
    await step('proposals', () async {
      await go(Routes.evProposals);
      await cap('m02-proposals', 'M02 Proposals: pending decision O1');
      await go('${Routes.evPropose}/p-chess');
      await cap(
        'm01-proposal-needs-changes',
        'M01 Proposal returned with a note',
      );
    });

    // Internal demo tools.
    await step('staff', () async {
      await go(Routes.staff);
      await cap(
        'h01-staff-home',
        'Internal: demo role banner, queue',
        area: 'internal',
      );
      await go('${Routes.staffProposal}/p-chess');
      await cap('h02-review', 'H02 Review and publish', area: 'internal');
      await go('${Routes.staffEvent}/$board');
      await cap(
        'h03-check-in',
        'H03 Attendance and check-in',
        area: 'internal',
      );
      await scrollTo('ev-staff-announce');
      await cap(
        'h04-announce-change-cancel',
        'H04 Announce, change, cancel',
        area: 'internal',
      );
    });

    // ignore: avoid_print
    print('@@DONE@@');
  });
}
