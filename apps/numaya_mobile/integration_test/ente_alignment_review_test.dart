// Ente alignment V3 review capture: real Flutter variants on the Android emulator, same fixture
// data, viewport and text scale per group. Host protocol as visual_lab_gallery_test.dart: prints
// `@@CAP@@|<file>|<group>|<variant>|<kind>|<scale>|<fixture>|<label>` and waits for the host's
// `adb screencap` (tool/capture_visual_lab.sh with TEST=integration_test/ente_alignment_review_test.dart).
// kind: crop (Visual Lab preview of the component), screen (the whole screen with the variant
// chosen in the Lab), qa (alignment evidence: specimen, states, narrow width, large text).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
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

  testWidgets('ente alignment review', (tester) async {
    final c = await quickStartApp(tester);
    c.read(onboardingProvider.notifier).loadSample();
    final lab = c.read(labChoicesProvider.notifier);
    var scale = '1.0';

    Future<void> cap(
      String file,
      String group,
      String variant,
      String kind,
      String label,
    ) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await _wait(tester, 900);
      if (_ack.existsSync()) _ack.deleteSync();
      // ignore: avoid_print
      print('@@CAP@@|$file.png|$group|$variant|$kind|$scale|demo|$label');
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

    Future<void> scrollTo(Finder f) async {
      await tester.scrollUntilVisible(
        f,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await _wait(tester, 400);
    }

    const board = 'ev-board-games-bandra';
    final groups = <String, (List<String>, String)>{
      'ea-event-card': (['O', 'A', 'B', 'C'], Routes.events),
      'ea-event-filters': (['O', 'A', 'B'], Routes.events),
      'ea-event-action': (['O', 'A', 'B'], '${Routes.evEvent}/$board'),
      'ea-met-card': (['O', 'A', 'B'], '${Routes.evMet}/ev-book-swap'),
    };

    // 1. Component crops (Visual Lab preview, identical fixtures).
    for (final id in ['ea-event-card', 'ea-met-card']) {
      for (final v in groups[id]!.$1) {
        await step('crop $id $v', () async {
          await go('${Routes.visualLabPreview}/$id?v=$v');
          await cap('crop__${id}__$v', id, v, 'crop', '$id $v (component)');
        });
      }
    }

    // 2. Whole screens with the variant chosen (everything else at its current default).
    for (final MapEntry(key: id, value: (variants, path)) in groups.entries) {
      for (final v in variants) {
        await step('screen $id $v', () async {
          lab
            ..reset()
            ..choose(id, v);
          await go(Routes.home);
          await go(path);
          // Tabs keep their scroll position: start each screen at the top.
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, 3000),
          );
          await _wait(tester, 400);
          if (id == 'ea-event-card') {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -420),
            );
            await _wait(tester, 500);
          }
          await cap('screen__${id}__$v', id, v, 'screen', '$id $v (screen)');
        });
      }
    }
    lab.reset();

    // 3. QA evidence for the aligned default.
    await step('specimen', () async {
      await go(Routes.visualLabSpecimen);
      await cap(
        'qa__01-specimen-anchors-banners',
        'qa',
        'specimen',
        'qa',
        'Semantic anchors, roles and banners',
      );
      await scrollTo(find.text('Badges'));
      await cap(
        'qa__02-specimen-badges-field',
        'qa',
        'specimen',
        'qa',
        'Badges and inline field error',
      );
      await scrollTo(find.text('Actions'));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await _wait(tester, 400);
      await cap(
        'qa__03-specimen-rows-actions',
        'qa',
        'specimen',
        'qa',
        'Picker row, destructive row, action groups, disabled',
      );
    });
    await step('met', () async {
      await go('${Routes.evMet}/ev-book-swap');
      await cap(
        'qa__04-people-met-paired',
        'qa',
        'after',
        'qa',
        'People I met: equal-width paired actions (before: content-width, far apart)',
      );
    });
    await step('request', () async {
      await go('${Routes.request}/seed-sam');
      await scrollTo(find.byKey(const ValueKey('request-dismiss')));
      await cap(
        'qa__05-request-paired',
        'qa',
        'after',
        'qa',
        'Compliment request: View profile and Dismiss as a peer group',
      );
    });
    await step('city', () async {
      await go(Routes.events);
      await tapOn(tester, find.byKey(const ValueKey('ev-city')));
      await _wait(tester, 700);
      await cap(
        'qa__06-city-picker-tick',
        'qa',
        'after',
        'qa',
        'City picker: one selection tick, no chevron (before: tick and chevron)',
      );
      await tapOn(tester, find.byKey(const ValueKey('sheet-close')));
      await _wait(tester, 600);
    });
    await step('cancel sheet', () async {
      await go('${Routes.evEvent}/$board/reserve');
      await tapOn(tester, find.byKey(const ValueKey('ev-ack')));
      await tapOn(tester, find.byKey(const ValueKey('ev-confirm')));
      await _wait(tester, 900);
      await go('${Routes.evReservation}/$board');
      await scrollTo(find.byKey(const ValueKey('ev-cancel')));
      await tapOn(tester, find.byKey(const ValueKey('ev-cancel')));
      await _wait(tester, 700);
      await cap(
        'qa__07-sheet-radius-stacked',
        'qa',
        'after',
        'qa',
        'Confirmation sheet: radius 20, stacked actions, main on top',
      );
      await tapOn(tester, find.byKey(const ValueKey('sheet-close')));
      await _wait(tester, 600);
    });
    await step('offline', () async {
      c.read(connectivityProvider.notifier).setOnline(false);
      await go('${Routes.evEvent}/ev-art-walk-chennai/reserve');
      await tapOn(tester, find.byKey(const ValueKey('ev-ack')));
      await tapOn(tester, find.byKey(const ValueKey('ev-confirm')));
      await _wait(tester, 900);
      await cap(
        'qa__08-status-error',
        'qa',
        'after',
        'qa',
        'Status O: error banner, filled icon, derived red',
      );
      c.read(connectivityProvider.notifier).setOnline(true);
    });
    await step('reconfirm', () async {
      await go(Routes.evMine);
      await cap(
        'qa__09-status-warning',
        'qa',
        'after',
        'qa',
        'Status O: warning banner for reconfirmation',
      );
    });
    await step('plan', () async {
      await go(Routes.paywall);
      await cap(
        'qa__10-plan-o',
        'qa',
        'after',
        'qa',
        'Plan O: plan cards (previously uncaptured)',
      );
    });
    await step('nav', () async {
      await go(Routes.profile);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await _wait(tester, 600);
      await cap(
        'qa__11-profile-bottom-nav',
        'qa',
        'after',
        'qa',
        'Profile scrolled to the end: last row clear of the floating bar',
      );
    });

    // 4. Events at 360dp and 200% text (R21).
    tester.view.devicePixelRatio = tester.view.physicalSize.width / 360;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    scale = '2.0';
    await _wait(tester, 600);
    for (final (path, name, label) in [
      (Routes.events, 'feed', 'Events feed'),
      ('${Routes.evEvent}/ev-sunrise-walk', 'detail', 'Event detail'),
      ('${Routes.evEvent}/ev-cycle-ride/reserve', 'reserve', 'Reserve'),
      (Routes.evMine, 'mine', 'My events'),
      ('${Routes.evNotice}/n-walk-v2', 'notice', 'Change notice'),
      ('${Routes.evMet}/ev-book-swap', 'met', 'People I met'),
    ]) {
      await step('large $name', () async {
        await go(path);
        await cap(
          'qa__large-360-$name',
          'qa',
          'large',
          'qa',
          '$label at 360dp, 200% text',
        );
      });
    }
    await step('large met bottom', () async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await _wait(tester, 500);
      await cap(
        'qa__large-360-met-actions',
        'qa',
        'large',
        'qa',
        'People I met actions stacked at 200% text',
      );
    });
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    tester.view.resetDevicePixelRatio();

    // ignore: avoid_print
    print('@@DONE@@');
  });
}
