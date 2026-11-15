@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// QR-013 (2026-11-15): every route a member can reach in the release build, opened directly in
/// the full demo world, one render each (first viewport, default state). This is the route sweep
/// behind docs/quality-refinement/ROUTE_STATE_COVERAGE.csv; other states (sheets, typed, errors)
/// are in ui087/qr captures. Writes `test/screenshots/qr/routes[/stress]/<nn>-<name>.png`.
///
///     flutter test --tags comparison --run-skipped --update-goldens \
///       test/screenshots/qr_routes_capture_test.dart [--dart-define=QR_WIDTH=320 QR_SCALE=2]
const _scale = String.fromEnvironment('QR_SCALE', defaultValue: '1');
const _width = String.fromEnvironment('QR_WIDTH', defaultValue: '393');

final List<(String, String)> releaseRoutes = [
  ('welcome', Routes.welcome),
  ('phone', Routes.phone),
  ('verify-code', Routes.verify),
  ('setup-hub', Routes.setup),
  ('setup-name', Routes.setupName),
  ('setup-underage', Routes.setupUnderage),
  ('setup-gender', Routes.setupGender),
  ('setup-meet', Routes.setupMeet),
  ('setup-intentions', Routes.setupIntentions),
  ('setup-height', Routes.setupHeight),
  ('setup-location', Routes.setupLocation),
  ('setup-photos', Routes.photos),
  ('setup-interests', Routes.interests),
  ('setup-prompts', Routes.setupPrompts),
  ('setup-prompt-editor', Routes.prompt),
  ('setup-bio', Routes.setupBio),
  ('setup-verify', Routes.setupVerify),
  ('setup-notifications', Routes.setupNotifications),
  ('setup-review', Routes.setupReview),
  ('setup-done', Routes.setupDone),
  ('discover', Routes.home),
  ('likes', Routes.likes),
  ('messages', Routes.messages),
  ('archive', Routes.archive),
  ('chat', '${Routes.chat}/priya'),
  ('compliment-photo', '${Routes.compliment}/noor?kind=photo&index=1'),
  ('compliment-prompt', '${Routes.compliment}/maya?kind=prompt&index=0'),
  ('like-profile', '${Routes.like}/noor'),
  ('match', '${Routes.match}/maya'),
  ('person', '${Routes.person}/noor'),
  ('person-photos', '${Routes.person}/noor/photos'),
  ('profile', Routes.profile),
  ('profile-edit', Routes.editProfile),
  ('edit-basics', Routes.editBasics),
  ('edit-interests', Routes.editInterests),
  ('edit-photos', Routes.editPhotos),
  ('edit-prompt', Routes.editPrompt),
  ('preview', Routes.preview),
  ('completion', Routes.completion),
  ('verify-photo', Routes.verifyPhoto),
  ('visibility', Routes.visibility),
  ('visibility-about', Routes.visibilityAbout),
  ('premium', Routes.premium),
  ('paywall', Routes.paywall),
  ('streak', Routes.streak),
  ('wallet', Routes.wallet),
  ('allowance', Routes.allowance),
  ('store-compliments', Routes.storeCompliments),
  ('store-recovery', Routes.storeRecovery),
  for (final r in [
    'success',
    'pending',
    'failed',
    'cancelled',
    'unavailable',
    'ineligible',
  ])
    ('outcome-$r', '${Routes.storeOutcome}?kind=premiumMonthly&result=$r'),
  ('settings', Routes.settings),
  ('settings-notifications', Routes.notifications),
  ('settings-privacy', Routes.privacy),
  ('settings-blocked', Routes.blocked),
  ('settings-delete', Routes.deleteAccount),
  ('safety', Routes.safety),
  ('help', Routes.help),
  ('help-article', '${Routes.help}/verification'),
  ('help-contact', Routes.helpContact),
  ('help-requests', Routes.supportRequests),
  ('legal', Routes.legal),
  ('legal-privacy', '${Routes.legal}/privacy'),
  ('restore', Routes.restore),
  ('reauth', Routes.reauth),
  ('account-blocked', Routes.accountBlocked),
];

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await DemoPhotoLibrary.load();
  });

  final stress = _scale != '1' || _width != '393';
  final dir = stress ? 'qr/routes/stress/w${_width}_x$_scale' : 'qr/routes';

  for (final (i, (name, route)) in releaseRoutes.indexed) {
    testWidgets(name, (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(double.parse(_width), 852) * 3;
      tester.platformDispatcher.textScaleFactorTestValue = double.parse(_scale);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      c.read(onboardingProvider.notifier).loadSample();
      await goTo(c, tester, route);
      for (var k = 0; k < 4; k++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }
      final n = (i + 1).toString().padLeft(2, '0');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('$dir/$n-$name.png'),
      );
      await settle(tester);
    });
  }
}
