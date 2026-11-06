// Capture-only tooling for the manual UI review (not part of the product or the CI suite).
//
// Runs on the emulator: flutter test integration_test/ui_review_capture_test.dart -d <device>
// At each capture point it prints one `@@CAP@@` line with the file name and metadata, then waits
// until the host script has taken a real device screenshot (adb screencap) and touched an ack file
// in the app's cache directory. It drives the production screens with the deterministic demo data
// the widget tests use (fixed clock, demo world); nothing is sent anywhere.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/application/session_controller.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../test/helpers/journeys.dart';
import '../test/helpers/test_app.dart';

const _set = String.fromEnvironment('CAPTURE_SET', defaultValue: 'main');
const _start = int.fromEnvironment('CAPTURE_START', defaultValue: 1);
final _ack = File('/data/user/0/com.numaya.numaya_mobile/cache/ui_review_ack');
var _n = _start;

String _slug(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

Future<void> _wait(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// One capture: settle, announce, wait for the host's screenshot.
Future<void> cap(
  WidgetTester tester, {
  required String flow,
  required String screen,
  required String state,
  String scroll = 'top',
  String steps = '',
  String notes = '',
  int settleMs = 900,
  bool keepFocus = false,
  String? fileName,
}) async {
  // A focused field under the harness text input makes the emulator's IME show its floating
  // toolbar over the app; unfocus unless the focus itself is the state being captured.
  if (!keepFocus) FocusManager.instance.primaryFocus?.unfocus();
  await _wait(tester, settleMs);
  final prefix = _set == 'robust' ? 'R' : 'N';
  final id = '$prefix${_n.toString().padLeft(3, '0')}';
  _n++;
  final file =
      fileName ??
      '${id}__${_slug(screen)}__${_slug(state)}${scroll == 'top' || scroll == '-' ? '' : '__${_slug(scroll)}'}.png';
  if (_ack.existsSync()) _ack.deleteSync();
  // ignore: avoid_print
  print('@@CAP@@|$id|$file|$flow|$screen|$state|$scroll|$steps|$notes');
  for (var i = 0; i < 200; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (_ack.existsSync()) {
      _ack.deleteSync();
      return;
    }
  }
  // ignore: avoid_print
  print('@@MISS@@|$id');
}

// ignore: avoid_print
void skip(String what, String why) => print('@@SKIP@@|$what|$why');

/// The page's main vertical scrollable: the one with the largest viewport.
ScrollPosition? _mainScroll(WidgetTester tester, {bool sheet = false}) {
  ScrollPosition? best;
  var area = 0.0;
  // A sheet is built above the page: its scrollable comes last in the tree.
  if (sheet) {
    for (final e in find.byType(Scrollable).evaluate()) {
      final s = (e as StatefulElement).state as ScrollableState;
      if (s.position.axis == Axis.vertical && s.position.maxScrollExtent > 0) {
        best = s.position;
      }
    }
    return best;
  }
  for (final e in find.byType(Scrollable).evaluate()) {
    final s = (e as StatefulElement).state as ScrollableState;
    if (s.position.axis != Axis.vertical) continue;
    final box = e.renderObject;
    if (box is! RenderBox || !box.hasSize) continue;
    final a = box.size.width * box.size.height;
    if (a > area && s.position.maxScrollExtent > 0) {
      area = a;
      best = s.position;
    }
  }
  return best;
}

/// Top, then further viewports (20% overlap) until the end, at most [max] captures.
Future<void> capPage(
  WidgetTester tester, {
  required String flow,
  required String screen,
  required String state,
  String steps = '',
  String notes = '',
  int max = 4,
  bool sheet = false,
}) async {
  await cap(
    tester,
    flow: flow,
    screen: screen,
    state: state,
    steps: steps,
    notes: notes,
  );
  final pos = _mainScroll(tester, sheet: sheet);
  if (pos == null) return;
  final step = pos.viewportDimension * 0.8;
  var k = 1;
  while (k < max && pos.pixels < pos.maxScrollExtent - 1) {
    final target = (pos.pixels + step).clamp(0.0, pos.maxScrollExtent);
    pos.jumpTo(target);
    final last = target >= pos.maxScrollExtent - 1;
    await cap(
      tester,
      flow: flow,
      screen: screen,
      state: state,
      scroll: last ? 'bottom' : 'scroll-$k',
      steps: '$steps; scroll ${last ? 'to the end' : '$k viewport(s)'}',
      notes: notes,
      settleMs: 700,
    );
    k++;
  }
  if (pos.pixels < pos.maxScrollExtent - 1) {
    skip(
      '$screen beyond ${max - 1} scrolls',
      'capture limit; more content below',
    );
  }
  pos.jumpTo(0);
}

Future<bool> tapLabel(WidgetTester tester, Pattern label) async {
  final f = find.bySemanticsLabel(label).hitTestable();
  if (f.evaluate().isEmpty) {
    skip('tap "$label"', 'not found on screen');
    return false;
  }
  await tester.tap(f.first);
  await _wait(tester, 700);
  return true;
}

Future<bool> tapText(WidgetTester tester, String text) async {
  final f = find.text(text).hitTestable();
  if (f.evaluate().isEmpty) {
    skip('tap text "$text"', 'not found on screen');
    return false;
  }
  await tester.tap(f.first);
  await _wait(tester, 700);
  return true;
}

Future<void> closeSheet(WidgetTester tester) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  nav.maybePop();
  await _wait(tester, 600);
}

String loc(ProviderContainer c) => c.read(routerProvider).state.uri.toString();

Future<void> route(
  WidgetTester tester,
  ProviderContainer c,
  String path, {
  required String flow,
  required String screen,
  String state = 'default',
  int max = 4,
  String notes = '',
}) async {
  await goTo(c, tester, path);
  await capPage(
    tester,
    flow: flow,
    screen: screen,
    state: state,
    steps: 'Quick start; open $path',
    notes: notes,
    max: max,
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  if (_set == 'handoff') {
    // UI review handoff evidence (NUMAYA_UI_REVIEW.md): after screenshots named by issue ID.
    Future<ProviderContainer> onboardingAccount(WidgetTester tester) async {
      await tester.pumpWidget(testApp(auth: testAuth()));
      await _wait(tester, 1200);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp).first),
      );
      c.read(sessionProvider.notifier).quickStartOnboarding();
      await goTo(c, tester, Routes.setup);
      return c;
    }

    Future<void> shot(
      WidgetTester tester,
      String file, {
      String flow = 'Handoff',
      String steps = '',
      bool keepFocus = false,
    }) => cap(
      tester,
      flow: flow,
      screen: file.split('__')[1],
      state: file.split('__').length > 2 ? file.split('__')[2] : 'after',
      scroll: '-',
      steps: steps,
      fileName: '$file.png',
      keepFocus: keepFocus,
    );

    testWidgets('handoff: welcome', (tester) async {
      await tester.pumpWidget(testApp(auth: testAuth()));
      await _wait(tester, 1500);
      await shot(tester, 'UI-001__get-started__after', steps: 'Fresh install');
    });

    testWidgets('handoff: onboarding steps', (tester) async {
      final c = await onboardingAccount(tester);
      await goTo(c, tester, Routes.setupMeet);
      await shot(tester, 'UI-003__signup-setup-meet__after');
      // UI-005: hold each thumb mid-drag so its value pop-up shows.
      final slider = find.byType(RangeSlider);
      final rect = tester.getRect(slider);
      final v = c.read(onboardingProvider).draft;
      // ignore: unused_local_variable
      final _ = v;
      double xFor(double age) =>
          rect.left + 24 + (rect.width - 48) * (age - 18) / (80 - 18);
      final ranges = tester.widget<RangeSlider>(slider).values;
      final lower = await tester.startGesture(
        Offset(xFor(ranges.start), rect.center.dy),
      );
      await lower.moveBy(const Offset(18, 0));
      await shot(
        tester,
        'UI-005__age-range__lower-thumb-active',
        steps: 'Meet; press and drag the lower thumb',
      );
      await lower.up();
      await _wait(tester, 600);
      final now = tester.widget<RangeSlider>(slider).values;
      final upper = await tester.startGesture(
        Offset(xFor(now.end), rect.center.dy),
      );
      await upper.moveBy(const Offset(-18, 0));
      await shot(
        tester,
        'UI-005__age-range__upper-thumb-active',
        steps: 'Meet; press and drag the upper thumb',
      );
      await upper.up();
      await _wait(tester, 600);

      await goTo(c, tester, Routes.setupHeight);
      await shot(
        tester,
        'UI-006__height__centimeters',
        steps: 'Height step on arrival (nothing saved yet)',
      );
      await tapText(tester, 'ft / in');
      await shot(
        tester,
        'UI-006__height__feet-inches',
        steps: 'Height; ft / in',
      );

      await goTo(c, tester, Routes.setupPrompts);
      await shot(tester, 'UI-007__signup-setup-prompts__after');
      await tapText(tester, 'Add a prompt');
      await shot(
        tester,
        'UI-008__prompts__category-browse',
        steps: 'Prompts; Add a prompt',
      );
      await tapText(tester, 'Opinions');
      await shot(
        tester,
        'UI-008__prompts__category-opinions',
        steps: 'Prompt browser; Opinions tab',
      );
      await tapText(tester, 'Let’s debate this');
      await shot(
        tester,
        'UI-008__prompts__answer-sheet',
        steps: 'Opinions; Let’s debate this',
        keepFocus: true,
      );
      await tester.enterText(
        find.byType(TextField).last,
        'Pineapple belongs on pizza, and I will die on this hill.',
      );
      await shot(
        tester,
        'UI-008__prompts__answer-typed',
        steps: 'Answer sheet; type an answer',
        keepFocus: true,
      );
      await tapText(tester, 'Save prompt');
      await _wait(tester, 800);
      await shot(
        tester,
        'UI-007__signup-setup-prompts__answered',
        steps: 'Saved: back on Prompts',
      );

      await goTo(c, tester, Routes.setupVerify);
      await shot(tester, 'UI-009__signup-setup-verify__after');
      await goTo(c, tester, Routes.setupName);
      await shot(
        tester,
        'UI-009__signup-setup-name__after',
        steps: 'About you intro (heading illustration)',
      );
    });

    testWidgets('handoff: app-wide rollout', (tester) async {
      final c = await quickStartApp(tester);
      const f = 'App-wide';
      await goTo(c, tester, Routes.home);
      await shot(tester, 'UI-011__discovery__portrait-photo', flow: f);
      await goTo(c, tester, '${Routes.person}/maya');
      final pos = _mainScroll(tester);
      pos?.jumpTo(pos.viewportDimension * 0.9);
      await shot(
        tester,
        'UI-007-UI-011__person-profile__prompt-and-photo',
        flow: f,
      );
      await goTo(c, tester, Routes.profile);
      final p2 = _mainScroll(tester);
      p2?.jumpTo(p2.maxScrollExtent);
      await shot(tester, 'UI-007__profile-tab__prompt-card', flow: f);
      await goTo(c, tester, Routes.deleteAccount);
      await shot(
        tester,
        'UI-003-UI-010__delete-account__options-and-alert',
        flow: f,
      );
      await goTo(c, tester, Routes.helpContact);
      await shot(tester, 'UI-003__help-contact__options', flow: f);
      await goTo(c, tester, Routes.home);
      if (await tapLabel(tester, 'Filters')) {
        final r = tester.getRect(find.byType(RangeSlider));
        final vals = tester
            .widget<RangeSlider>(find.byType(RangeSlider))
            .values;
        final g = await tester.startGesture(
          Offset(
            r.left + 24 + (r.width - 48) * (vals.start - 18) / 62,
            r.center.dy,
          ),
        );
        await g.moveBy(const Offset(16, 0));
        await shot(tester, 'UI-004-UI-005__filters__age-thumb-active', flow: f);
        await g.up();
        await closeSheet(tester);
      }
      await goTo(c, tester, Routes.verifyPhoto);
      await shot(tester, 'UI-002-UI-009__verify-photo__after', flow: f);
      await goTo(c, tester, Routes.premium);
      await shot(tester, 'UI-010__premium__alert', flow: f);
    });
    return;
  }

  if (_set == 'review2') {
    // Discover / Filters / navigation / New Match review (UI-013 to UI-032): after screenshots
    // named by the current-state asset they answer (A-007 to A-014) and by issue ID.
    Future<void> shot(
      WidgetTester tester,
      String file, {
      String steps = '',
      bool keepFocus = false,
    }) => cap(
      tester,
      flow: 'Review 2',
      screen: file.split('__').length > 1 ? file.split('__')[1] : file,
      state: file.split('__').length > 2 ? file.split('__')[2] : 'after',
      scroll: '-',
      steps: steps,
      fileName: '$file.png',
      keepFocus: keepFocus,
    );

    Offset photoCentre(WidgetTester tester) => tester.getCenter(
      find
          .byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('swipe-'),
          )
          .first,
    );

    Future<TestGesture> hold(WidgetTester tester, Offset at, double dx) async {
      final g = await tester.startGesture(at);
      for (var i = 0; i < 10; i++) {
        await g.moveBy(Offset(dx / 10, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      return g;
    }

    Future<void> scrollSheetTo(WidgetTester tester, double t) async {
      final pos = _mainScroll(tester, sheet: true);
      pos?.jumpTo(pos.maxScrollExtent * t);
      await _wait(tester, 400);
    }

    Future<void> openFilters(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Filters').hitTestable().first);
      await _wait(tester, 900);
    }

    testWidgets('review2: Discover', (tester) async {
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.home);
      await _wait(tester, 800);
      await shot(tester, 'A-007__UI-013-UI-014-UI-016__discover-top__after');
      final pos = _mainScroll(tester);
      final about = find.text('About me');
      if (pos != null && about.evaluate().isNotEmpty) {
        await tester.ensureVisible(about);
        pos.jumpTo((pos.pixels - 120).clamp(0, pos.maxScrollExtent));
        await _wait(tester, 400);
      }
      await shot(
        tester,
        'A-008__UI-007-UI-018-UI-019-UI-020__discover-scrolled__after',
        steps: 'Discover; scroll to About me',
      );
      final shared = find.byKey(const ValueKey('shared-interests'));
      if (pos != null && shared.evaluate().isNotEmpty) {
        await tester.ensureVisible(shared);
        pos.jumpTo((pos.pixels - 220).clamp(0, pos.maxScrollExtent));
        await _wait(tester, 400);
      }
      await shot(
        tester,
        'UI-015__discover__shared-interests-below-photo',
        steps: 'Discover; scroll to You both like',
      );
      pos?.jumpTo(0);
      await _wait(tester, 400);
      await tapLabel(tester, 'Profile options');
      await shot(tester, 'UI-017__discover__profile-menu', steps: 'Photo ⋯');
      await closeSheet(tester);

      final left = await hold(tester, photoCentre(tester), -150);
      await shot(
        tester,
        'UI-016__discover__left-swipe-in-progress',
        steps: 'Drag the photo left and hold',
      );
      await left.up();
      await _wait(tester, 900);
      await shot(
        tester,
        'UI-013__discover__after-left-swipe-backtrack-ready',
        steps: 'Release: Maya passed, Sam next; Backtrack enabled',
      );
      await tester.tap(
        find.byKey(const ValueKey('discover-backtrack')).hitTestable(),
      );
      await _wait(tester, 500);
      await shot(
        tester,
        'UI-013__discover__after-backtrack',
        steps: 'Tap Backtrack: Maya is back',
      );
      final right = await hold(tester, photoCentre(tester), 150);
      await shot(
        tester,
        'UI-016__discover__right-swipe-in-progress',
        steps: 'Drag the photo right and hold',
      );
      await right.up();
      await _wait(tester, 1600);
      await shot(
        tester,
        'A-014__UI-028-UI-029-UI-030-UI-031__new-match__after',
        steps: 'Release: Maya liked you, so a match',
      );
      final mpos = _mainScroll(tester);
      if (mpos != null && mpos.maxScrollExtent > 0) {
        mpos.jumpTo(mpos.maxScrollExtent);
        await _wait(tester, 400);
        await shot(
          tester,
          'UI-029__new-match__shared-interests-card',
          steps: 'New Match scrolled to the end',
        );
      }
      await tester.tap(
        find.byKey(const ValueKey('match-view-profile')).hitTestable(),
      );
      await _wait(tester, 900);
      await shot(
        tester,
        'UI-030__new-match__view-profile-opens-maya',
        steps: 'Tap View profile',
      );
      await tapLabel(tester, 'Back');
      await _wait(tester, 600);
      await tester.tap(
        find.byKey(const ValueKey('match-open-chat')).hitTestable(),
      );
      await _wait(tester, 900);
      await shot(
        tester,
        'UI-030-UI-031__new-match__open-chat-ordinary-messaging',
        steps: 'Back, then Open chat',
      );
      await tapLabel(tester, 'Back to messages');
      await _wait(tester, 900);
      await shot(
        tester,
        'UI-030__new-match__back-to-browsing',
        steps: 'Back from the chat returns to browsing',
      );
    });

    testWidgets('review2: Filters', (tester) async {
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.home);
      await _wait(tester, 600);
      await openFilters(tester);
      await shot(
        tester,
        'A-010__UI-021-UI-022-UI-023-UI-024__filters-basic-top__after',
      );
      await tapText(tester, 'Women');
      await tapText(tester, 'Men');
      await shot(
        tester,
        'UI-021__filters__two-genders-selected',
        steps: 'Basic; select Women and Men',
      );
      final slider = find.byType(RangeSlider);
      if (slider.evaluate().isNotEmpty) {
        final r = tester.getRect(slider);
        final v = tester.widget<RangeSlider>(slider).values;
        const inset = 13.0;
        double x(double age) =>
            r.left + inset + (r.width - 2 * inset) * (age - 18) / 62;
        final lo = await hold(tester, Offset(x(v.start), r.center.dy), -400);
        await shot(
          tester,
          'UI-005-UI-024__filters__age-lower-thumb-at-minimum',
          steps: 'Drag the lower thumb to the left end and hold',
        );
        await lo.up();
        await _wait(tester, 500);
        final v2 = tester.widget<RangeSlider>(slider).values;
        final hi = await hold(tester, Offset(x(v2.end), r.center.dy), 400);
        await shot(
          tester,
          'UI-005-UI-024__filters__age-upper-thumb-at-maximum',
          steps: 'Drag the upper thumb to the right end and hold',
        );
        await hi.up();
        await _wait(tester, 500);
      }
      await scrollSheetTo(tester, 1);
      await shot(
        tester,
        'A-009__UI-023-UI-024-UI-025__filters-basic-bottom__after',
        steps: 'Basic; scroll to the end (switches off)',
      );
      for (final s
          in find.byType(NumayaSwitch).hitTestable().evaluate().toList()) {
        await tester.tap(find.byWidget(s.widget));
        await _wait(tester, 300);
      }
      await shot(
        tester,
        'UI-025__filters__switches-on',
        steps: 'Basic bottom; turn the switches on',
      );
      await scrollSheetTo(tester, 0);
      await tapText(tester, 'Advanced');
      await shot(tester, 'A-011__UI-022-UI-023__filters-advanced__after');
      await scrollSheetTo(tester, 1);
      await shot(
        tester,
        'UI-023__filters__advanced-bottom',
        steps: 'Advanced; scroll to the end',
      );
      await closeSheet(tester);
    });

    testWidgets('review2: navigation and exclusions', (tester) async {
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.home);
      await _wait(tester, 600);
      await shot(tester, 'A-012__UI-026-UI-027__navigation-discover__after');
      for (final (label, file) in [
        ('Events', 'UI-026__navigation__events-selected'),
        ('Likes', 'UI-026__navigation__likes-selected'),
        (
          'Messages',
          'UI-026-UI-031__navigation__messages-selected-no-opening-moves',
        ),
        ('Profile', 'UI-026__navigation__profile-selected'),
      ]) {
        await tester.tap(
          find
              .descendant(
                of: find.byType(NumayaTabBar),
                matching: find.byTooltip(label),
              )
              .first,
        );
        await _wait(tester, 900);
        await shot(tester, file, steps: 'Tap $label');
      }
      final ppos = _mainScroll(tester);
      ppos?.jumpTo(ppos.maxScrollExtent * 0.5);
      await _wait(tester, 400);
      await shot(
        tester,
        'UI-031__profile__no-opening-moves-row',
        steps: 'Profile; scroll to the settings rows',
      );
      await goTo(c, tester, '${Routes.chat}/jo');
      await _wait(tester, 600);
      await shot(
        tester,
        'UI-031__chat__new-match-ordinary-chat',
        steps: 'A new match’s chat (Jo has an Opening Move in data)',
      );
      await goTo(c, tester, Routes.premium);
      await _wait(tester, 600);
      await shot(tester, 'UI-016__premium__no-superswipe');
      await goTo(c, tester, Routes.openingMoves);
      await _wait(tester, 600);
      await shot(
        tester,
        'UI-031__route__opening-moves-redirects-to-profile',
        steps: 'Deep link to /profile/opening-moves',
      );
    });
    return;
  }

  if (_set == 'fixup') {
    // Re-shoots single captures under their original ID (CAPTURE_START), so the index is stable.
    testWidgets('fixup: multi-line composer', (tester) async {
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.chat}/priya');
      await tester.enterText(
        find.byType(TextField).last,
        'Record shops on Sunday? There is a fair near the canal with a few '
        'stalls I have been meaning to try. I could do after lunch, or the '
        'morning if you prefer, and we could get coffee on the way.',
      );
      await cap(
        tester,
        flow: 'Conversations',
        screen: 'chat',
        state: 'composer-multiline',
        scroll: '-',
        steps: 'Chat with Priya; type a long message that wraps',
        keepFocus: true,
        notes: 'The composer takes no line breaks, so growth is shown with wrapping; the floating bar is the emulator IME toolbar',
      );
    });
    return;
  }

  if (_set == 'robust') {
    testWidgets('robustness set', (tester) async {
      final c = await quickStartApp(tester);
      const f = 'Robustness';
      for (final (p, s) in [
        (Routes.home, 'discovery'),
        (Routes.likes, 'likes'),
        (Routes.messages, 'messages'),
        ('${Routes.chat}/priya', 'chat'),
        (Routes.profile, 'profile'),
        (Routes.editProfile, 'edit-profile'),
        (Routes.settings, 'settings'),
        ('${Routes.event}/e-jazz', 'event-detail'),
        (Routes.paywall, 'paywall'),
      ]) {
        await goTo(c, tester, p);
        await capPage(
          tester,
          flow: f,
          screen: s,
          state: 'narrow-large-text',
          steps: 'Device at 320dp, font scale 1.5; quick start; open $p',
          max: 2,
        );
      }
      await goTo(c, tester, Routes.home);
      await tapLabel(tester, 'Filters');
      await cap(
        tester,
        flow: f,
        screen: 'discovery-filters',
        state: 'narrow-large-text',
        scroll: '-',
        steps: 'Device at 320dp, font scale 1.5; Discover; Filters',
      );
      await closeSheet(tester);
    });
    return;
  }

  testWidgets('onboarding and account entry', (tester) async {
    const f = 'Onboarding';
    final auth = testAuth();
    var shot = 0;
    Future<void> onScreen() async {
      shot++;
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp).first),
      );
      final where = loc(c);
      await cap(
        tester,
        flow: f,
        screen: where == '/'
            ? 'welcome'
            : 'signup ${where.replaceAll('/', ' ')}',
        state: 'step $shot',
        scroll: '-',
        steps: 'Fresh install; Create an account; follow sign-up to step $shot',
      );
    }

    await signUpToInterests(tester, auth, onScreen: onScreen);
    await finishProfileToHome(tester, onScreen: onScreen);
  });

  testWidgets('main app, full demo world', (tester) async {
    final c = await quickStartApp(tester);

    // Discovery -----------------------------------------------------------------------------
    const d = 'Discovery';
    await goTo(c, tester, Routes.home);
    await capPage(
      tester,
      flow: d,
      screen: 'discovery',
      state: 'default',
      steps: 'Quick start; Discover tab',
      max: 6,
    );
    if (await tapLabel(tester, 'Filters')) {
      await capPage(
        tester,
        flow: d,
        screen: 'discovery-filters',
        state: 'basic',
        steps: 'Discover; Filters',
        sheet: true,
      );
      if (await tapText(tester, 'Women')) {
        await cap(
          tester,
          flow: d,
          screen: 'discovery-filters',
          state: 'women-selected',
          steps: 'Discover; Filters; tap Women',
        );
      }
      if (await tapText(tester, 'Advanced')) {
        await capPage(
          tester,
          flow: d,
          screen: 'discovery-filters',
          state: 'advanced-locked',
          steps: 'Discover; Filters; Advanced',
          sheet: true,
          notes: 'Advanced filters are a Premium feature in the demo account',
        );
      }
      await closeSheet(tester);
    }
    if (await tapLabel(tester, 'Profile options')) {
      await cap(
        tester,
        flow: d,
        screen: 'discovery-profile-options',
        state: 'sheet-open',
        scroll: '-',
        steps: 'Discover; options on the photo',
      );
      await closeSheet(tester);
    }
    await route(tester, c, Routes.forYou, flow: d, screen: 'for-you');
    c.read(datingProvider.notifier).setSimulateErrors(true);
    await goTo(c, tester, Routes.likes);
    await goTo(c, tester, Routes.home);
    await cap(
      tester,
      flow: d,
      screen: 'discovery',
      state: 'error',
      scroll: '-',
      steps: 'Demo hub: simulate errors on; Discover',
    );
    c.read(datingProvider.notifier).setSimulateErrors(false);
    c.read(datingProvider.notifier).setSnoozed(true);
    await goTo(c, tester, Routes.likes);
    await goTo(c, tester, Routes.home);
    await cap(
      tester,
      flow: d,
      screen: 'discovery',
      state: 'snoozed',
      scroll: '-',
      steps: 'Settings: Snooze on; Discover',
    );
    c.read(datingProvider.notifier).setSnoozed(false);

    // Profiles ------------------------------------------------------------------------------
    const p = 'Profiles';
    await route(
      tester,
      c,
      '${Routes.person}/maya',
      flow: p,
      screen: 'person-profile',
      max: 5,
    );
    await route(
      tester,
      c,
      Routes.personPhotos('maya'),
      flow: p,
      screen: 'person-photos',
      state: 'photo-1',
    );

    // Likes and matches --------------------------------------------------------------------
    const l = 'Likes and Matches';
    await route(
      tester,
      c,
      Routes.likes,
      flow: l,
      screen: 'likes',
      state: 'all',
      max: 3,
    );
    if (await tapLabel(tester, RegExp(r'^New, \d'))) {
      await cap(
        tester,
        flow: l,
        screen: 'likes',
        state: 'new-selected',
        steps: 'Likes; New chip',
      );
    }
    await route(
      tester,
      c,
      '${Routes.like}/kemi',
      flow: l,
      screen: 'liked-profile',
      max: 4,
    );
    await route(
      tester,
      c,
      '${Routes.match}/amara',
      flow: l,
      screen: 'match',
      state: 'new-match',
    );

    // Conversations ------------------------------------------------------------------------
    const m = 'Conversations';
    await route(
      tester,
      c,
      Routes.messages,
      flow: m,
      screen: 'messages',
      state: 'populated',
      max: 3,
    );
    if (await tapLabel(tester, 'Search names and messages')) {
      await cap(
        tester,
        flow: m,
        screen: 'messages',
        state: 'search-open',
        steps: 'Messages; search icon',
        notes: 'Harness text input: no system keyboard; the floating bar is the emulator IME toolbar',
        keepFocus: true,
      );
      await tester.enterText(find.byType(TextField).first, 'zebra');
      await cap(
        tester,
        flow: m,
        screen: 'messages',
        state: 'search-no-results',
        steps: 'Messages; search "zebra"',
      );
      await tapText(tester, 'Cancel');
    }
    if (await tapLabel(tester, RegExp('^Unread'))) {
      await cap(
        tester,
        flow: m,
        screen: 'messages',
        state: 'unread-selected',
        steps: 'Messages; Unread chip',
      );
    }
    await route(
      tester,
      c,
      '${Routes.chat}/priya',
      flow: m,
      screen: 'chat',
      state: 'populated',
      max: 3,
    );
    final field = find.byType(TextField);
    if (field.evaluate().isNotEmpty) {
      await tester.enterText(field.last, 'Record shops on Sunday?');
      await cap(
        tester,
        flow: m,
        screen: 'chat',
        state: 'composer-one-line',
        scroll: '-',
        steps: 'Chat with Priya; type one line',
        notes: 'Field unfocused for the capture; the K set shows the real keyboard',
      );
      await tester.enterText(
        field.last,
        'Record shops on Sunday?\nThere is a fair near the canal.\nI could do after lunch.\nOr the morning, if you prefer.',
      );
      await cap(
        tester,
        flow: m,
        screen: 'chat',
        state: 'composer-multiline',
        scroll: '-',
        steps: 'Chat with Priya; type four lines',
        keepFocus: true,
        notes: 'Kept focused so the field shows all lines; the floating bar is the emulator IME toolbar',
      );
      await tester.enterText(field.last, '');
    }
    if (await tapLabel(tester, 'Add a photo, video or voice note')) {
      await cap(
        tester,
        flow: m,
        screen: 'chat-attachments',
        state: 'sheet-open',
        scroll: '-',
        steps: 'Chat; attach button',
      );
      await closeSheet(tester);
    }
    if (await tapLabel(tester, 'Conversation options')) {
      await cap(
        tester,
        flow: m,
        screen: 'chat-options',
        state: 'sheet-open',
        scroll: '-',
        steps: 'Chat; options (top right)',
      );
      await closeSheet(tester);
    }
    await route(
      tester,
      c,
      '${Routes.chat}/jo',
      flow: m,
      screen: 'chat',
      state: 'new-match-no-messages',
      max: 2,
    );

    // Own profile and editing --------------------------------------------------------------
    const e = 'Profile Editing';
    await route(
      tester,
      c,
      Routes.profile,
      flow: e,
      screen: 'profile-tab',
      max: 5,
    );
    await route(
      tester,
      c,
      Routes.editProfile,
      flow: e,
      screen: 'edit-profile',
      max: 6,
    );
    await route(
      tester,
      c,
      Routes.editBasics,
      flow: e,
      screen: 'edit-basics',
      max: 4,
    );
    await route(
      tester,
      c,
      Routes.editInterests,
      flow: e,
      screen: 'edit-interests',
      max: 4,
    );
    await route(tester, c, Routes.editPhotos, flow: e, screen: 'edit-photos');
    await route(tester, c, Routes.editPrompt, flow: e, screen: 'edit-prompt');
    await route(
      tester,
      c,
      Routes.completion,
      flow: e,
      screen: 'profile-completion',
      max: 3,
    );
    await route(
      tester,
      c,
      Routes.preview,
      flow: e,
      screen: 'profile-preview',
      max: 4,
    );
    await route(
      tester,
      c,
      Routes.openingMoves,
      flow: e,
      screen: 'opening-moves',
    );

    // Settings and account -----------------------------------------------------------------
    const s = 'Settings and Account';
    await route(
      tester,
      c,
      Routes.settings,
      flow: s,
      screen: 'settings',
      max: 6,
    );
    await route(
      tester,
      c,
      Routes.notifications,
      flow: s,
      screen: 'notification-settings',
      max: 3,
    );
    await route(tester, c, Routes.privacy, flow: s, screen: 'privacy', max: 3);
    await route(tester, c, Routes.blocked, flow: s, screen: 'blocked-people');
    await route(
      tester,
      c,
      Routes.visibility,
      flow: s,
      screen: 'profile-visibility',
      max: 3,
    );
    await route(
      tester,
      c,
      Routes.visibilityAbout,
      flow: s,
      screen: 'visibility-about',
      max: 3,
    );
    await route(
      tester,
      c,
      Routes.deleteAccount,
      flow: s,
      screen: 'delete-account',
      max: 3,
    );
    await route(
      tester,
      c,
      Routes.accountBlocked,
      flow: s,
      screen: 'account-blocked',
    );

    // Safety and help ----------------------------------------------------------------------
    const y = 'Safety';
    await route(tester, c, Routes.safety, flow: y, screen: 'safety', max: 3);
    await route(
      tester,
      c,
      Routes.verifyPhoto,
      flow: y,
      screen: 'verify-photo',
      max: 3,
    );
    await route(tester, c, Routes.help, flow: y, screen: 'help-centre', max: 3);
    await route(
      tester,
      c,
      Routes.helpContact,
      flow: y,
      screen: 'help-contact',
      max: 2,
    );
    await goTo(c, tester, Routes.home);
    final report = find.textContaining('Report or block');
    if (report.evaluate().isNotEmpty) {
      await tester.ensureVisible(report.first);
      await _wait(tester, 500);
      await tester.tap(report.first);
      await _wait(tester, 800);
      await cap(
        tester,
        flow: y,
        screen: 'report-block-sheet',
        state: 'options',
        scroll: '-',
        steps: 'Discover; end of Maya’s profile; Report or block',
      );
      if (await tapText(tester, 'Block Maya')) {
        await cap(
          tester,
          flow: y,
          screen: 'block-confirm',
          state: 'destructive-confirmation',
          scroll: '-',
          steps: 'Report or block; Block Maya',
        );
      }
      await closeSheet(tester);
      await closeSheet(tester);
    } else {
      skip('report-block-sheet', 'Report or block link not found on Discover');
    }

    // Premium ------------------------------------------------------------------------------
    const pr = 'Premium';
    await route(tester, c, Routes.premium, flow: pr, screen: 'premium', max: 3);
    await route(
      tester,
      c,
      Routes.paywall,
      flow: pr,
      screen: 'paywall',
      state: 'no-plan-selected',
      max: 3,
    );

    // Events -------------------------------------------------------------------------------
    const ev = 'Events and Other';
    await route(
      tester,
      c,
      Routes.events,
      flow: ev,
      screen: 'events',
      state: 'explore',
      max: 3,
    );
    await route(
      tester,
      c,
      '${Routes.events}?view=mine',
      flow: ev,
      screen: 'events',
      state: 'my-events',
      max: 2,
    );
    await route(
      tester,
      c,
      '${Routes.event}/e-jazz',
      flow: ev,
      screen: 'event-detail',
      max: 4,
    );
    await route(
      tester,
      c,
      '${Routes.event}/e-jazz/people',
      flow: ev,
      screen: 'event-people',
      max: 2,
    );
    await route(
      tester,
      c,
      Routes.eventNew,
      flow: ev,
      screen: 'event-form',
      state: 'empty',
      max: 4,
    );

    // Shared components and development ---------------------------------------------------
    const sc = 'Shared Components';
    await route(tester, c, Routes.demo, flow: sc, screen: 'demo-hub', max: 4);
    await route(
      tester,
      c,
      Routes.designLab,
      flow: sc,
      screen: 'design-lab',
      max: 12,
    );
  });

  testWidgets('signed-out account routes', (tester) async {
    // These redirect to Home for a signed-in member, so they are opened signed out.
    await tester.pumpWidget(testApp(auth: testAuth()));
    await _wait(tester, 1500);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    const s = 'Settings and Account';
    for (final (path, name) in [
      (Routes.restore, 'restore-account'),
      (Routes.reauth, 'sign-in-again'),
    ]) {
      await goTo(c, tester, path);
      await capPage(
        tester,
        flow: s,
        screen: name,
        state: 'signed-out',
        steps: 'Fresh install, signed out; open $path',
        notes: loc(c) == path ? '' : 'Router redirected to ${loc(c)}',
        max: 3,
      );
    }
  });

  testWidgets('fresh account (empty states)', (tester) async {
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    const f = 'Conversations';
    await route(
      tester,
      c,
      Routes.messages,
      flow: f,
      screen: 'messages',
      state: 'empty',
    );
    await route(
      tester,
      c,
      Routes.likes,
      flow: 'Likes and Matches',
      screen: 'likes',
      state: 'fresh-account',
      max: 2,
    );
  });
}
