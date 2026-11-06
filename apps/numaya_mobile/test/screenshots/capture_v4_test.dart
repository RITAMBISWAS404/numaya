@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/experiments/experiments.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Overnight v4 changed-screen evidence. The same scenes run on the V3 candidate
/// (`--dart-define=V4_SET=before`) and on V4 (`after`). Writes
/// `test/screenshots/comparison/v4/<set>/<id>__<scene>.png`.
/// Opt-in: `flutter test --tags comparison --run-skipped --update-goldens <this file>`.
void main() {
  setUpAll(loadAppFonts);
  const set = String.fromEnvironment('V4_SET', defaultValue: 'after');

  final scenes =
      <
        (
          String id,
          String scene,
          String route,
          bool narrow,
          bool brokenPhoto,
          String? name,
          Experiment? exp,
          ExpVariant? variant,
        )
      >[
        (
          'V4-01',
          'profile-missing-photo',
          Routes.profile,
          false,
          true,
          null,
          null,
          null,
        ),
        (
          'V4-01',
          'exp002A-missing-photo',
          Routes.profile,
          false,
          true,
          null,
          Experiment.profileHeader,
          ExpVariant.a,
        ),
        (
          'V4-02',
          'settings-320-200pct',
          Routes.settings,
          true,
          false,
          null,
          null,
          null,
        ),
        (
          'V4-02',
          'notifications-320-200pct',
          Routes.notifications,
          true,
          false,
          null,
          null,
          null,
        ),
        (
          'V4-02',
          'edit-profile-320-200pct',
          Routes.editProfile,
          true,
          false,
          null,
          null,
          null,
        ),
        (
          'V4-02',
          'edit-basics-320-200pct',
          Routes.editBasics,
          true,
          false,
          null,
          null,
          null,
        ),
        (
          'V4-02',
          'settings-390-100pct-unchanged',
          Routes.settings,
          false,
          false,
          null,
          null,
          null,
        ),
        (
          'V4-03',
          'exp001A-chips',
          '${Routes.match}/maya',
          false,
          false,
          null,
          Experiment.matchMoment,
          ExpVariant.a,
        ),
        (
          'V4-03',
          'exp001B-chips',
          '${Routes.match}/maya',
          false,
          false,
          null,
          Experiment.matchMoment,
          ExpVariant.b,
        ),
        (
          'V4-04',
          'exp002A-long-name-320-200pct',
          Routes.profile,
          true,
          false,
          'Maximiliana-Alexandria',
          Experiment.profileHeader,
          ExpVariant.a,
        ),
        (
          'V4-04',
          'exp002A-390',
          Routes.profile,
          false,
          false,
          null,
          Experiment.profileHeader,
          ExpVariant.a,
        ),
      ];

  for (final (id, scene, route, narrow, broken, name, exp, variant) in scenes) {
    testWidgets('v4 $id $scene', (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = narrow
          ? const Size(640, 1386)
          : const Size(780, 1688);
      if (narrow) tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      final onboarding = c.read(onboardingProvider.notifier);
      if (broken) {
        onboarding.replacePhoto(
          c.read(onboardingProvider).draft.photos.first.id,
          source: '/no/such/photo.jpg',
        );
      }
      if (name != null) onboarding.setFirstName(name);
      if (exp != null) {
        c.read(experimentChoicesProvider.notifier).choose(exp, variant!);
      }
      await goTo(c, tester, route);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 1200));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('comparison/v4/$set/${id}__$scene.png'),
      );
      await settle(tester);
    });
  }
}
