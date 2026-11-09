// Ente refinement V4 review capture: real Flutter screens on the Android emulator, one fixture set
// and viewport per group. Host protocol as visual_lab_gallery_test.dart: prints
// `@@CAP@@|<file>|<group>|<variant>|<kind>|<scale>|<fixture>|<label>` and waits for the host's
// `adb screencap` (tool/capture_visual_lab.sh with TEST=integration_test/ente_v4_review_test.dart).
// kind: screen (major-route index), variant (a layout alternative), crop (a component state).
// `--dart-define=ONLY=major|variants|states` runs one part; default runs all.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/dating/domain/sample_people.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../test/helpers/journeys.dart';

final _ack = File('/data/user/0/com.numaya.numaya_mobile/cache/ui_review_ack');
const _only = String.fromEnvironment('ONLY');

Future<void> _wait(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(DemoPhotoLibrary.load);

  testWidgets('ente v4 review', (tester) async {
    final c = await quickStartApp(tester);
    c.read(onboardingProvider.notifier).loadSample();
    final lab = c.read(labChoicesProvider.notifier);

    Future<void> cap(
      String file,
      String group,
      String variant,
      String kind,
      String label,
    ) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await _wait(tester, 1200);
      if (_ack.existsSync()) _ack.deleteSync();
      // ignore: avoid_print
      print('@@CAP@@|$file.png|$group|$variant|$kind|1.0|demo|$label');
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
      await _wait(tester, 700);
    }

    Future<void> scrollDown(double px) async {
      await tester.drag(find.byType(Scrollable).first, Offset(0, -px));
      await _wait(tester, 700);
    }

    const board = 'ev-board-games-bandra';

    if (_only.isEmpty || _only == 'major') {
      // slug, label, route, scroll amounts (one capture per entry; 0 is the first viewport).
      const major = <(String, String, String, List<double>)>[
        ('discover', 'Discover', Routes.home, [0, 760]),
        ('heart', 'Heart: Likes', Routes.likes, [0]),
        ('chats', 'Chats', Routes.messages, [0]),
        ('chat', 'Conversation', '${Routes.chat}/priya', [0]),
        ('person', 'Person profile', '${Routes.person}/maya', [0, 900]),
        ('photos', 'Photo viewer', '${Routes.person}/maya/photos?start=1', [0]),
        ('match', 'Match', '${Routes.match}/maya', [0]),
        (
          'compliment',
          'Send a compliment',
          '${Routes.compliment}/maya?kind=prompt&index=0',
          [0],
        ),
        ('request', 'Compliment request', '${Routes.request}/seed-sam', [0]),
        ('archive', 'Archive', Routes.archive, [0]),
        ('events', 'Events feed', Routes.events, [0, 700]),
        ('event', 'Event detail', '${Routes.evEvent}/$board', [0, 620]),
        ('event-full', 'Event full', '${Routes.evEvent}/ev-sunrise-walk', [0]),
        ('reserve', 'Reserve', '${Routes.evEvent}/ev-cycle-ride/reserve', [0]),
        ('mine', 'My events', Routes.evMine, [0]),
        ('notice', 'Event change notice', '${Routes.evNotice}/n-walk-v2', [0]),
        (
          'reservation',
          'Reservation',
          '${Routes.evReservation}/ev-cycle-ride',
          [0],
        ),
        ('met', 'People I met', '${Routes.evMet}/ev-book-swap', [0]),
        ('profile', 'Profile', Routes.profile, [0, 700]),
        ('streak', 'Streak', Routes.streak, [0]),
        ('wallet', 'Wallet', Routes.wallet, [0]),
        ('edit', 'Edit profile', Routes.editProfile, [0, 800]),
        ('basics', 'The basics (form)', Routes.editBasics, [0]),
        ('settings', 'Settings', Routes.settings, [0, 900]),
        ('safety', 'Safety', Routes.safety, [0]),
        ('help', 'Help', Routes.help, [0]),
        ('premium', 'Premium', Routes.premium, [0]),
        ('paywall', 'Paywall', Routes.paywall, [0]),
        ('store', 'Compliments store', Routes.storeCompliments, [0]),
        ('setup', 'Setup hub', Routes.setup, [0]),
        ('for-you', 'For you', Routes.forYou, [0]),
      ];
      for (final (slug, label, path, scrolls) in major) {
        await step('major $slug', () async {
          await go(Routes.home);
          await go(path);
          for (final (i, s) in scrolls.indexed) {
            if (s > 0) await scrollDown(s);
            final name = i == 0 ? slug : '$slug-$i';
            await cap(
              'screen__$name',
              'major',
              name,
              'screen',
              i == 0 ? label : '$label (scrolled)',
            );
          }
        });
      }
      await step('major filters sheet', () async {
        await go(Routes.home);
        await tester.tap(find.bySemanticsLabel('Filters').first);
        await _wait(tester, 900);
        await cap(
          'screen__filters',
          'major',
          'filters',
          'screen',
          'Filters sheet',
        );
      });
      lab.reset();
    }
    if (_only.isEmpty || _only == 'key') {
      // One short pass for the large-text and narrow runs (the host changes the device setting).
      const key = <(String, String)>[
        ('discover', Routes.home),
        ('person', '${Routes.person}/ines'),
        ('composer', '${Routes.compliment}/noor?kind=prompt&index=0'),
        ('request', '${Routes.request}/seed-chloe'),
        ('compliments', '${Routes.likes}?tab=compliments'),
        ('messages', Routes.messages),
        ('chat', '${Routes.chat}/priya'),
        ('profile', Routes.profile),
        ('settings', Routes.settings),
        ('paywall', Routes.paywall),
        ('wallet', Routes.wallet),
      ];
      for (final (slug, path) in key) {
        await step('key $slug', () async {
          await go(Routes.home);
          await go(path);
          await cap('key__$slug', 'key', slug, 'qa', slug);
        });
      }
    }

    if (_only.isEmpty || _only == 'variants') {
      const preview = {'compliment-card', 'v4-welcome'};
      const routes = {
        'v4-photo-label': Routes.home,
        'screen-heart': Routes.likes,
        'screen-chats': Routes.messages,
        'screen-profile': Routes.profile,
      };
      for (final id in [...preview, ...routes.keys]) {
        for (final v in labGroup(id).ids) {
          await step('variant $id $v', () async {
            lab
              ..reset()
              ..choose(id, v);
            await go(Routes.home);
            if (preview.contains(id)) {
              await go('${Routes.visualLabPreview}/$id?v=$v');
              await cap('crop__${id}__$v', id, v, 'crop', '$id $v');
            } else {
              await go(routes[id]!);
              await cap('screen__${id}__$v', id, v, 'screen', '$id $v');
            }
          });
        }
      }
      lab.reset();
    }

    if (_only.isEmpty || _only == 'states') {
      // Bright, dark and busy crops: the five main photos on the person card.
      for (final p in kSamplePeople.take(5)) {
        await step('photo ${p.id}', () async {
          await go(Routes.home);
          await go('${Routes.person}/${p.id}');
          await cap(
            'state__photo-${p.id}',
            'qa',
            p.id,
            'qa',
            'Photo label on ${p.id}',
          );
        });
      }
    }

    // ignore: avoid_print
    print('@@DONE@@');
  });
}
