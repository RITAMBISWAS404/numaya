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
import 'package:numaya_mobile/features/commerce/application/economy_controller.dart';
import 'package:numaya_mobile/features/compliments/application/compliments_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/data/media_picker.dart';
import 'package:numaya_mobile/features/dating/domain/sample_people.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';

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
    final c = await quickStartApp(
      tester,
      mediaPicker: const SampleMediaPicker(),
      // The selected candidate as members get it; the labs need the controls.
      devTools: _only != 'key',
    );
    c.read(sampleMediaProvider.notifier).set(true);
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
        ('streak', Routes.streak),
        ('likes', Routes.likes),
      ];
      for (final (slug, path) in key) {
        await step('key $slug', () async {
          await go(Routes.home);
          await go(path);
          await cap('key__$slug', 'key', slug, 'qa', slug);
        });
      }
      await step('key filters', () async {
        await go(Routes.home);
        await tester.tap(find.bySemanticsLabel('Filters').first);
        await _wait(tester, 900);
        await cap('key__filters', 'key', 'filters', 'qa', 'filters');
        await tester.binding.handlePopRoute();
        await _wait(tester, 500);
      });
    }

    if (_only.isEmpty || _only == 'variants' || _only == 'v7') {
      final dating = c.read(datingProvider.notifier);
      final first = c.read(datingProvider).threads['priya']!.first;
      await dating.send('priya', 'Saturday works for me.', replyToId: first.id);
      await dating.send(
        'priya',
        '',
        attachment: const MessageAttachment(
          kind: AttachmentKind.voice,
          duration: Duration(seconds: 12),
          sample: true,
        ),
      );
      await _wait(tester, 800);
      const screens = {
        'v4-photo-label': Routes.home,
        'v6-quote-style': '${Routes.chat}/priya',
        'v6-voice-bubble': '${Routes.chat}/priya',
        'v6-composer': '${Routes.chat}/priya',
        'v6-page-title': Routes.profile,
        'v6-wallet-header': Routes.wallet,
        'v6-streak-hero': Routes.streak,
        'v6-settings-plan': Routes.settings,
        'v6-discover-margin': Routes.home,
        'v7-nav': Routes.home,
        'v7-discover': Routes.home,
        'v7-compliment': '${Routes.compliment}/noor?kind=prompt&index=0',
        'v7-profile': Routes.profile,
        'v7-streak': Routes.streak,
        'v7-request': '${Routes.request}/seed-chloe',
        'v7-filters': Routes.home,
        'v7-paywall': Routes.paywall,
        'v7-likes-locked': Routes.likes,
        'screen-heart': Routes.likes,
        'screen-chats': Routes.messages,
        'screen-profile': Routes.profile,
        'screen-discover': Routes.home,
      };
      for (final g in kLabGroups) {
        if (isDeferredLabGroup(g.id) || g.kind == LabKind.motion) continue;
        if (_only == 'v7' && !g.id.startsWith('v7-')) continue;
        final component = g.kind == LabKind.component;
        final route = screens[g.id];
        if (!component && route == null) continue;
        // Premium, so the Heart directions differ from one another.
        c.read(premiumProvider.notifier).setActive(g.id == 'screen-heart');
        for (final v in g.ids) {
          await step('variant ${g.id} $v', () async {
            lab
              ..reset()
              ..choose(g.id, v);
            await go(Routes.home);
            if (component) {
              await go('${Routes.visualLabPreview}/${g.id}?v=$v');
              await cap('crop__${g.id}__$v', g.id, v, 'crop', '${g.id} $v');
            } else {
              await go(route!);
              if (g.id == 'v7-filters') {
                await tester.tap(find.bySemanticsLabel('Filters').first);
                await _wait(tester, 900);
              }
              await cap('screen__${g.id}__$v', g.id, v, 'screen', '${g.id} $v');
              if (g.id == 'v7-filters') {
                await tester.binding.handlePopRoute();
                await _wait(tester, 500);
              }
            }
          });
        }
      }
      c.read(premiumProvider.notifier).setActive(false);
      lab.reset();
    }

    if (_only.isEmpty || _only == 'v7') {
      // Journey: entry, main, written, leave with a draft, then send and completion, for each
      // arrangement of the Compliment composer.
      for (final v in const ['O', 'A', 'B', 'C']) {
        Future<void> jc(String n, String label) => cap(
          'journey__v7-compliment__${v}__$n',
          'v7-compliment',
          v,
          'journey',
          label,
        );
        await step('journey compliment $v', () async {
          // Every arrangement starts from the same people and credits.
          c
            ..invalidate(datingProvider)
            ..invalidate(complimentsProvider)
            ..invalidate(economyProvider);
          lab
            ..reset()
            ..choose('v7-compliment', v);
          await go(Routes.home);
          await jc('1-entry', 'Entry: Discover');
          await tester.tap(find.byKey(const ValueKey('compliment-photo-0')));
          await _wait(tester, 900);
          await jc('2-main', 'Main: empty');
          await tester.enterText(
            find.byKey(const ValueKey('compliment-field')),
            'That photo looks like the best kind of Sunday. Where was it taken?',
          );
          await _wait(tester, 500);
          await jc('3-written', 'Written');
          await tester.binding.handlePopRoute();
          await _wait(tester, 800);
          await jc('4-leave', 'Back with a draft: discard choice');
          await tester.binding.handlePopRoute();
          await _wait(tester, 600);
          c.read(datingProvider.notifier).setSimulateErrors(true);
          await tester.tap(find.byKey(const ValueKey('compliment-send')));
          await _wait(tester, 1200);
          await jc('4b-failed', 'Send failed: words kept, no credit used');
          c.read(datingProvider.notifier).setSimulateErrors(false);
          await tester.tap(find.byKey(const ValueKey('compliment-send')));
          await _wait(tester, 1500);
          await jc('5-complete', 'Completion');
          await tester.tap(find.byKey(const ValueKey('compliment-done')));
          await _wait(tester, 900);
          await go(Routes.home);
          await jc('6-next', 'Back on Discover');
          await tester.tap(find.byKey(const ValueKey('compliment-photo-0')));
          await _wait(tester, 900);
          await jc('7-blocked', 'They already sent you one: reply instead');
          await tester.binding.handlePopRoute();
          await _wait(tester, 900);
        });
      }
      // Each named direction across the four benchmark screens, same data and viewport.
      for (final d in const ['O', 'A', 'B', 'C']) {
        await step('direction $d', () async {
          lab
            ..reset()
            ..choose('v7-discover', d)
            ..choose('v7-compliment', d)
            ..choose('v7-profile', d)
            ..choose('v7-streak', d);
          const seq = <(String, String)>[
            ('1-discover', Routes.home),
            ('2-compliment', '${Routes.compliment}/noor?kind=photo&index=0'),
            ('3-profile', Routes.profile),
            ('4-streak', Routes.streak),
          ];
          c
            ..invalidate(datingProvider)
            ..invalidate(complimentsProvider)
            ..invalidate(economyProvider);
          for (final (n, path) in seq) {
            await go(Routes.home);
            if (d == 'B' && n == '2-compliment') {
              await tester.tap(
                find.byKey(const ValueKey('compliment-photo-0')),
              );
              await _wait(tester, 900);
            } else {
              await go(path);
            }
            await cap('direction__${d}__$n', 'direction', d, 'journey', n);
          }
        });
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
