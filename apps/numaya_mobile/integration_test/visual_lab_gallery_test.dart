// Capture-only tooling for the Visual Lab V2 review gallery (not part of the product or CI).
//
// Runs on an emulator: tool/capture_visual_lab.sh drives
//   flutter test integration_test/visual_lab_gallery_test.dart -d <device>
// At each capture point it prints `@@CAP@@|<file>|<group>|<variant>|<kind>|<scale>|<fixture>|<label>`
// and waits until the host has taken a real device screenshot (adb screencap) and touched the ack
// file in the app's cache. Motion clips print `@@REC@@|start|<name>` / `@@REC@@|stop|<name>`; the
// host records with `adb shell screenrecord`. Deterministic demo world and fixed demo clock; the
// Lab state is reset between groups.
// Capture-only script: compact `if (_want(...)) for (...)` guards read better here.
// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/insights/application/insights_providers.dart';
import 'package:numaya_mobile/features/insights/domain/insights_fixture.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';

import '../test/helpers/journeys.dart';

final _ack = File('/data/user/0/com.numaya.numaya_mobile/cache/ui_review_ack');

/// `--dart-define=ONLY=default,card,screen,large,motion,scenario` (or card group IDs such as
/// `prompt-card`) limits a run to those parts, for targeted recaptures.
const _only = String.fromEnvironment('ONLY');
bool _want(String part, [String? group]) {
  if (_only.isEmpty) return true;
  final parts = _only.split(',');
  return parts.contains(part) || (group != null && parts.contains(group));
}

Future<void> _wait(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// One capture: settle, announce, wait for the host's screenshot.
Future<void> cap(
  WidgetTester tester, {
  required String file,
  required String group,
  required String variant,
  required String kind,
  String scale = '1.0',
  String fixture = 'demo',
  required String label,
  int settleMs = 900,
}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await _wait(tester, settleMs);
  if (_ack.existsSync()) _ack.deleteSync();
  // ignore: avoid_print
  print('@@CAP@@|$file.png|$group|$variant|$kind|$scale|$fixture|$label');
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

Future<void> rec(WidgetTester tester, String what, String name) async {
  if (_ack.existsSync()) _ack.deleteSync();
  // ignore: avoid_print
  print('@@REC@@|$what|$name');
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (_ack.existsSync()) {
      _ack.deleteSync();
      return;
    }
  }
}

Future<void> step(String what, Future<void> Function() body) async {
  try {
    await body();
  } catch (e) {
    // ignore: avoid_print
    print('@@SKIP@@|$what|${e.toString().split('\n').first}');
  }
}

/// Where each component family is seen in context, and how to get the family on screen.
const _context = <String, (String, double)>{
  'match-avatar': (Routes.messages, 0),
  'conversation-row': (Routes.messages, 260),
  'compliment-card': ('${Routes.likes}?tab=compliments', 0),
  'like-tile': (Routes.likes, 0),
  'profile-header': (Routes.profile, 0),
  'insights-summary': (Routes.insights, 0),
  'metric-widget': (Routes.insights, 520),
  'profile-setup': (Routes.profile, 160),
  'prompt-card': (Routes.home, 640),
  'discover-photo': (Routes.home, 0),
  'streak-card': (Routes.profile, 260),
  'wallet-card': (Routes.profile, 420),
  'plan-card': (Routes.paywall, 260),
  'status-banner': ('${Routes.chat}/rafa', 0),
  'empty-state': ('${Routes.likes}?tab=compliments', 0),
};

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(DemoPhotoLibrary.load);

  testWidgets('visual lab gallery', (tester) async {
    final c = await quickStartApp(tester);
    c.read(onboardingProvider.notifier).loadSample();
    c
        .read(profileDetailsProvider.notifier)
        .setBio('Weekend baker, weekday map nerd. Always up for a long walk.');
    final lab = c.read(labChoicesProvider.notifier);
    Future<void> go(String path) => goTo(c, tester, path);
    // The Compliments part, scrolled to the first dismiss button, then the sheet opened.
    Future<void> openDismissSheet() async {
      await go(Routes.home);
      await go(Routes.likes);
      await _wait(tester, 500);
      await tapOn(tester, find.byKey(const ValueKey('heart-tab-compliments')));
      await _wait(tester, 600);
      final dismiss = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(
              'compliment-dismiss-',
            ),
      );
      await tester.ensureVisible(dismiss.first);
      await _wait(tester, 400);
      await tester.tap(dismiss.first);
      await _wait(tester, 300);
    }

    Future<void> scrollBy(double dy) async {
      if (dy <= 0) return;
      final s = find.byType(Scrollable);
      if (s.evaluate().isEmpty) return;
      await tester.drag(s.first, Offset(0, -dy));
      await _wait(tester, 400);
    }

    // 1. Proposed default: the five priority screens and the required-change evidence.
    lab.reset();
    if (_want('default'))
      for (final (path, name, dy) in [
        (Routes.home, 'discover', 0.0),
        (Routes.home, 'discover-prompt', 640.0),
        (Routes.likes, 'heart-likes-free', 0.0),
        ('${Routes.likes}?tab=compliments', 'heart-compliments', 0.0),
        (Routes.messages, 'chats', 0.0),
        (Routes.archive, 'archive', 0.0),
        ('${Routes.chat}/rafa', 'chat-archived', 0.0),
        ('${Routes.chat}/ollie', 'chat-expired-initial', 0.0),
        ('${Routes.chat}/jo', 'chat-new-match-time', 0.0),
        ('${Routes.chat}/priya', 'chat-header-verified', 0.0),
        (Routes.profile, 'profile', 0.0),
        (Routes.profile, 'profile-collapsed-title', 220.0),
        (Routes.insights, 'insights', 0.0),
        (Routes.insights, 'insights-scrolled', 600.0),
        (Routes.wallet, 'wallet', 0.0),
        (Routes.streak, 'streak', 0.0),
        (Routes.paywall, 'paywall', 0.0),
        (Routes.visualLab, 'design-lab', 0.0),
      ]) {
        await step(name, () async {
          await go(path);
          await scrollBy(dy);
          await cap(
            tester,
            file: 'default__$name',
            group: 'default',
            variant: 'proposed',
            kind: 'screen',
            label: name,
          );
        });
      }
    if (_want('default') || _want('sheet'))
      await step('sheet', () async {
        await openDismissSheet();
        await cap(
          tester,
          file: 'default__sheet-close-squircle',
          group: 'default',
          variant: 'proposed',
          kind: 'screen',
          label: 'sheet close',
          settleMs: 1200,
        );
        await tapOn(tester, find.byKey(const ValueKey('sheet-close')));
        await _wait(tester, 600);
      });
    if (_want('default'))
      await step('premium heart', () async {
        c.read(premiumProvider.notifier).setActive(true);
        await go(Routes.likes);
        await cap(
          tester,
          file: 'default__heart-likes-premium',
          group: 'default',
          variant: 'proposed',
          kind: 'screen',
          fixture: 'premium',
          label: 'heart likes premium',
        );
        await go(Routes.insights);
        await tapOn(tester, find.byKey(const ValueKey('period-28')));
        await cap(
          tester,
          file: 'default__insights-premium-28',
          group: 'default',
          variant: 'proposed',
          kind: 'screen',
          fixture: 'premium-28',
          label: 'insights premium 28 days',
        );
        c.read(premiumProvider.notifier).setActive(false);
      });
    if (_want('default'))
      await step('free 28 locked', () async {
        await go(Routes.profile);
        await go(Routes.insights);
        await tapOn(tester, find.byKey(const ValueKey('period-28')));
        await cap(
          tester,
          file: 'default__insights-free-28-locked',
          group: 'default',
          variant: 'proposed',
          kind: 'screen',
          fixture: 'free',
          label: 'insights 28 days locked',
        );
      });

    // 2. Insights scenarios (all sample-labelled).
    if (_want('scenario'))
      for (final s in InsightsScenario.values) {
        await step('scenario ${s.name}', () async {
          c.read(insightsScenarioProvider.notifier).choose(s);
          final premium = s == InsightsScenario.premiumHistory;
          c.read(premiumProvider.notifier).setActive(premium);
          await go(Routes.profile);
          await go(Routes.insights);
          if (premium) {
            await tapOn(tester, find.byKey(const ValueKey('period-28')));
            await _wait(tester, 500);
          }
          await cap(
            tester,
            file: 'scenario__${s.name}',
            group: 'insights-scenario',
            variant: s.name,
            kind: 'screen',
            fixture: s.name,
            label: s.name,
          );
        });
      }
    c.read(insightsScenarioProvider.notifier).choose(null);
    c.read(premiumProvider.notifier).setActive(false);

    // 3. Card families: isolated crop (preview) and in context, every variant.
    for (final g in kLabGroups.where(
      (g) => g.kind == LabKind.component && _want('card', g.id),
    )) {
      for (final v in g.ids) {
        await step('${g.id} $v', () async {
          lab.reset();
          await go('${Routes.visualLabPreview}/${g.id}?v=$v');
          await cap(
            tester,
            file: 'card__${g.id}__${v}__crop',
            group: g.id,
            variant: v,
            kind: 'crop',
            label: '${g.title} $v isolated',
          );
          lab.choose(g.id, v);
          final (path, dy) = _context[g.id]!;
          // Like tiles are a Premium surface; free members see the locked count instead.
          c.read(premiumProvider.notifier).setActive(g.id == 'like-tile');
          await go(Routes.demo);
          await go(path);
          await scrollBy(dy);
          await cap(
            tester,
            file: 'card__${g.id}__${v}__context',
            group: g.id,
            variant: v,
            kind: 'context',
            label: '${g.title} $v in context',
          );
          c.read(premiumProvider.notifier).setActive(false);
        });
      }
    }

    // 4. Screen directions: O, A, B, C for each priority screen (plus the Compliments part).
    for (final g in kLabGroups.where(
      (g) => g.kind == LabKind.screen && _want('screen', g.id),
    )) {
      for (final v in g.ids) {
        await step('${g.id} $v', () async {
          lab
            ..reset()
            ..choose(g.id, v);
          // The Likes grid is a Premium surface: capture each Heart direction as a Premium member,
          // so its like-tile layout is visible (free members see the same locked count).
          c.read(premiumProvider.notifier).setActive(g.id == 'screen-heart');
          final paths = switch (g.id) {
            'screen-heart' => [Routes.likes, '${Routes.likes}?tab=compliments'],
            'screen-discover' => [Routes.home],
            'screen-chats' => [Routes.messages],
            'screen-insights' => [Routes.insights],
            _ => [Routes.profile],
          };
          for (var i = 0; i < paths.length; i++) {
            await go(Routes.demo);
            await go(paths[i]);
            await cap(
              tester,
              file: 'screen__${g.id}__${v}__${i + 1}',
              group: g.id,
              variant: v,
              kind: 'screen',
              label: '${g.title} $v',
            );
            if (g.id != 'screen-heart' && g.id != 'screen-chats') {
              await scrollBy(560);
              await cap(
                tester,
                file: 'screen__${g.id}__${v}__${i + 1}b',
                group: g.id,
                variant: v,
                kind: 'screen',
                label: '${g.title} $v scrolled',
              );
            }
          }
          c.read(premiumProvider.notifier).setActive(false);
        });
      }
    }

    // 5. Large text: the proposed default at 200%.
    lab.reset();
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    if (_want('large'))
      for (final (path, name) in [
        (Routes.home, 'discover'),
        ('${Routes.likes}?tab=compliments', 'heart-compliments'),
        (Routes.messages, 'chats'),
        (Routes.profile, 'profile'),
        (Routes.insights, 'insights'),
        ('${Routes.chat}/rafa', 'chat-archived'),
      ]) {
        await step('200 $name', () async {
          await go(Routes.demo);
          await go(path);
          await cap(
            tester,
            file: 'large-text__$name',
            group: 'large-text',
            variant: 'proposed',
            kind: 'screen',
            scale: '2.0',
            label: '$name at 200% text',
          );
        });
      }
    tester.platformDispatcher.clearTextScaleFactorTestValue();

    // 6. Motion clips: M1 (proposed), M2 and M0 (reduced) for the four key interactions.
    if (_want('motion') || _want('motion-sheet'))
      for (final m in ['M1', 'M2', 'M0']) {
        lab
          ..reset()
          ..choose('motion', m);
        await _wait(tester, 400);
        if (_want('motion'))
          await step('motion $m tabs', () async {
            await go(Routes.likes);
            await _wait(tester, 600);
            await rec(tester, 'start', 'tabs__$m');
            await _wait(tester, 600);
            await tapOn(
              tester,
              find.byKey(const ValueKey('heart-tab-compliments')),
            );
            await _wait(tester, 900);
            await tapOn(tester, find.byKey(const ValueKey('heart-tab-likes')));
            await _wait(tester, 900);
            await tapOn(
              tester,
              find.byKey(const ValueKey('heart-tab-compliments')),
            );
            await _wait(tester, 900);
            await rec(tester, 'stop', 'tabs__$m');
          });
        if (_want('motion'))
          await step('motion $m title', () async {
            await go(Routes.profile);
            await _wait(tester, 600);
            await rec(tester, 'start', 'title__$m');
            await _wait(tester, 500);
            final s = find.byType(Scrollable).first;
            for (var i = 0; i < 6; i++) {
              await tester.drag(s, const Offset(0, -60));
              await _wait(tester, 120);
            }
            await _wait(tester, 600);
            for (var i = 0; i < 6; i++) {
              await tester.drag(s, const Offset(0, 60));
              await _wait(tester, 120);
            }
            await _wait(tester, 700);
            await rec(tester, 'stop', 'title__$m');
          });
        await step('motion $m sheet', () async {
          await rec(tester, 'start', 'sheet__$m');
          await _wait(tester, 300);
          await openDismissSheet();
          await _wait(tester, 1200);
          await tapOn(tester, find.byKey(const ValueKey('sheet-close')));
          await _wait(tester, 1000);
          await rec(tester, 'stop', 'sheet__$m');
        });
        if (_want('motion'))
          await step('motion $m route', () async {
            await go(Routes.messages);
            await _wait(tester, 600);
            await rec(tester, 'start', 'route__$m');
            await _wait(tester, 500);
            await tapOn(tester, find.byKey(const ValueKey('chats-archive')));
            await _wait(tester, 1000);
            await tester.pageBack();
            await _wait(tester, 1000);
            await rec(tester, 'stop', 'route__$m');
          });
      }
    lab.reset();
    // ignore: avoid_print
    print('@@DONE@@');
  });
}
