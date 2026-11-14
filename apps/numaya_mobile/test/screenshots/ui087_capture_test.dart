@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/presentation/match_avatar.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/premium/application/premium_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';
import 'v8_scenes.dart' show V8Scene;

/// UI-087..102 review phase (2026-11-15): the same scenes, data and viewport (393 x 852 logical
/// at 3x = 1179 x 2556) rendered on the checkpoint (`before`) and on the implementation branch
/// (`after`). This file uses only APIs both revisions share, so it is copied unchanged into a
/// checkout of `checkpoint/pre-ui087-102-20261115-0309` for the before set. Writes
/// `test/screenshots/ui087/<id>.png` (git-ignored: the images show the private demo photos).
///
///     flutter test --tags comparison --run-skipped --update-goldens \
///       test/screenshots/ui087_capture_test.dart [--dart-define=UI_ONLY=<id prefix>]
const _only = String.fromEnvironment('UI_ONLY');
const _scale = String.fromEnvironment('UI_SCALE', defaultValue: '1');
const _width = String.fromEnvironment('UI_WIDTH', defaultValue: '393');

Future<void> _tapLabel(WidgetTester t, String label) async {
  await t.tap(find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}')).first);
  await t.pump();
  await t.pump(const Duration(milliseconds: 700));
}

Future<void> _tapText(WidgetTester t, String text) async {
  await t.tap(find.text(text).last);
  await t.pump();
  await t.pump(const Duration(milliseconds: 700));
}

final List<V8Scene> ui087Scenes = [
  // UI-087 pills.
  const V8Scene('ui087-pronouns', Routes.setupGender),
  const V8Scene('ui087-interests', Routes.interests),
  const V8Scene('ui087-profile-review', Routes.setupReview),
  const V8Scene('ui087-discover', Routes.home, scroll: 640),
  const V8Scene('ui087-preview', Routes.preview, scroll: 500),
  // UI-088 menu and list-card row icons.
  const V8Scene('ui088-profile-menu', Routes.profile, scroll: 620),
  const V8Scene('ui088-streak', Routes.streak),
  const V8Scene('ui088-streak-more', Routes.streak, scroll: 600),
  const V8Scene('ui088-wallet', Routes.wallet),
  const V8Scene('ui088-wallet-history', Routes.wallet, scroll: 600),
  const V8Scene('ui088-premium', Routes.premium, scroll: 400),
  const V8Scene('ui088-settings', Routes.settings),
  // UI-089 birthday, UI-101 header progress.
  const V8Scene('ui089-birthday', Routes.setupName),
  // UI-090 sliders.
  const V8Scene('ui090-their-age', Routes.setupMeet),
  V8Scene(
    'ui090-filters-basic',
    Routes.home,
    setup: (t, c) => _tapLabel(t, 'Filters'),
  ),
  V8Scene(
    'ui090-filters-advanced',
    Routes.home,
    premium: true,
    setup: (t, c) async {
      await _tapLabel(t, 'Filters');
      await _tapText(t, 'Advanced');
    },
  ),
  const V8Scene('ui090-setup-height', Routes.setupHeight),
  // UI-091/092/093/073 Compliment composer (A-088) and chat composer.
  V8Scene(
    'ui091-compliment-typed',
    '${Routes.compliment}/noor?kind=photo&index=1',
    setup: (t, c) async {
      await t.enterText(
        find.byType(EditableText).last,
        'Where was this taken?',
      );
      await t.pump(const Duration(milliseconds: 400));
    },
  ),
  const V8Scene(
    'ui091-compliment-empty',
    '${Routes.compliment}/noor?kind=photo&index=1',
  ),
  const V8Scene('ui072-chat-empty', '${Routes.chat}/priya'),
  V8Scene(
    'ui093-chat-typed',
    '${Routes.chat}/priya',
    setup: (t, c) async {
      await t.enterText(find.byType(EditableText).last, 'Saturday works.');
      await t.pump(const Duration(milliseconds: 400));
    },
  ),
  const V8Scene('ui070-chat-sam', '${Routes.chat}/sam'),
  // UI-094 status and empty screens.
  for (final r in ['failed', 'pending', 'success'])
    V8Scene(
      'ui094-payment-$r',
      '${Routes.storeOutcome}?kind=premiumMonthly&result=$r',
    ),
  V8Scene(
    'ui094-discover-no-results',
    Routes.home,
    setup: (t, c) async {
      final f = c.read(discoveryFiltersProvider);
      c
          .read(discoveryFiltersProvider.notifier)
          .save(f.copyWith(minAge: 60, maxAge: 61));
      await t.pump(const Duration(milliseconds: 700));
    },
  ),
  // UI-010/060 informational cards.
  const V8Scene('ui060-setup-verify', Routes.setupVerify),
  const V8Scene('ui060-setup-location', Routes.setupLocation),
  const V8Scene('ui060-photos', Routes.photos),
  const V8Scene('ui060-setup-done', Routes.setupDone),
  // UI-026 navigation, UI-049 overlays.
  const V8Scene('ui026-discover', Routes.home),
  const V8Scene('ui049-likes-premium', Routes.likes, premium: true),
  // UI-033/067/068 Messages, UI-086 countdown.
  const V8Scene('ui067-messages', Routes.messages),
  const V8Scene('ui067-archive', Routes.archive),
  // Opened the way a person does: tap the first New matches photo in Messages.
  V8Scene(
    'ui086-new-match-chat',
    Routes.messages,
    setup: (t, c) async {
      await t.tap(find.byType(MatchAvatarTile).first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 900));
    },
  ),
  // UI-102 scrolled top bars.
  const V8Scene('ui102-settings-scrolled', Routes.settings, scroll: 300),
  const V8Scene('ui102-edit-basics-scrolled', Routes.editBasics, scroll: 300),
];

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await DemoPhotoLibrary.load();
  });

  final stress = _scale != '1' || _width != '393';
  final dir = stress ? 'ui087/stress/w${_width}_x$_scale' : 'ui087';

  for (final s in ui087Scenes) {
    if (_only.isNotEmpty && !_only.split(',').any((p) => s.id.startsWith(p))) {
      continue;
    }
    testWidgets(s.id, (tester) async {
      final w = double.parse(_width);
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(w, s.height) * 3;
      tester.platformDispatcher.textScaleFactorTestValue = double.parse(_scale);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      c.read(onboardingProvider.notifier).loadSample();
      if (s.premium) c.read(premiumProvider.notifier).setActive(true);
      await goTo(c, tester, s.route);
      Future<void> decode([int n = 4]) async {
        for (var i = 0; i < n; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 150)),
          );
          await tester.pump(const Duration(milliseconds: 300));
        }
      }

      await decode();
      if (s.setup != null) {
        await s.setup!(tester, c);
        await decode(3);
      }
      if (s.scroll > 0) {
        await tester.drag(find.byType(Scrollable).first, Offset(0, -s.scroll));
        await decode(3);
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('$dir/${s.id}.png'),
      );
      await settle(tester);
    });
  }
}
