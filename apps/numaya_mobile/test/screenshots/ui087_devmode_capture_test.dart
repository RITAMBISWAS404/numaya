@Tags(['comparison'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/demo/application/type_settings_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// UI-085/095/096/097/098 evidence (2026-11-15): every Dev Mode preset on the same screens and
/// data at 393 x 852 logical, 3x. The setting goes through the real controller, as a tap in Dev
/// Mode does, so the app root's apply-and-rebuild path is the one exercised. Writes
/// `test/screenshots/ui087/dev/<id>.png` (git-ignored).
///
///     flutter test --tags comparison --run-skipped --update-goldens \
///       test/screenshots/ui087_devmode_capture_test.dart
const _only = String.fromEnvironment('UI_ONLY');

const List<(String, String)> _screens = [
  ('discover', Routes.home),
  ('chat', '${Routes.chat}/priya'),
  ('form', Routes.setupName),
  ('settings', Routes.settings),
];

class _DevScene {
  const _DevScene(this.id, this.route, this.settings, {this.setup});
  final String id;
  final String route;
  final TypeSettings settings;
  final Future<void> Function(WidgetTester t)? setup;
}

Future<void> _openFilters(WidgetTester t) async {
  await t.tap(find.bySemanticsLabel(RegExp('^Filters')).first);
  await t.pump();
  await t.pump(const Duration(milliseconds: 700));
}

final List<_DevScene> _scenes = [
  for (final p in FontPairing.values)
    for (final (name, route) in _screens)
      _DevScene('ui085-${p.id}--$name', route, TypeSettings(pairing: p)),
  for (final b in BrandOption.values) ...[
    _DevScene('ui095-${b.id}--form', Routes.setupName, TypeSettings(brand: b)),
    _DevScene(
      'ui095-${b.id}--filters',
      Routes.home,
      TypeSettings(brand: b),
      setup: _openFilters,
    ),
    _DevScene(
      'ui095-${b.id}--messages',
      Routes.messages,
      TypeSettings(brand: b),
    ),
    _DevScene(
      'ui095-${b.id}--interests',
      Routes.interests,
      TypeSettings(brand: b),
    ),
  ],
  for (final s in ButtonShape.values)
    for (final f in SecondarySurface.values) ...[
      _DevScene(
        'ui096-098-${s.id}-${f.id}--filters',
        Routes.home,
        TypeSettings(shape: s, secondary: f),
        setup: _openFilters,
      ),
      _DevScene(
        'ui096-098-${s.id}-${f.id}--payment-failed',
        '${Routes.storeOutcome}?kind=premiumMonthly&result=failed',
        TypeSettings(shape: s, secondary: f),
      ),
      _DevScene(
        'ui096-098-${s.id}-${f.id}--devmode',
        Routes.reviewTypography,
        TypeSettings(shape: s, secondary: f),
      ),
    ],
  const _DevScene(
    'ui097-combined--setup-location',
    Routes.setupLocation,
    TypeSettings(
      pairing: FontPairing.halantNunito,
      brand: BrandOption.lilac,
      shape: ButtonShape.pill,
      secondary: SecondarySurface.filled,
    ),
  ),
  const _DevScene(
    'ui097-combined--devmode',
    Routes.reviewTypography,
    TypeSettings(
      pairing: FontPairing.breeDmSans,
      bodySize: 14,
      brand: BrandOption.periwinkle,
      shape: ButtonShape.pill,
      secondary: SecondarySurface.filled,
    ),
  ),
];

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await DemoPhotoLibrary.load();
  });
  tearDown(() => DevModeStyles.apply(TypeSettings.baseline));

  for (final s in _scenes) {
    if (_only.isNotEmpty && !_only.split(',').any((p) => s.id.startsWith(p))) {
      continue;
    }
    testWidgets(s.id, (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(393, 852) * 3;
      addTearDown(tester.view.reset);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      c.read(onboardingProvider.notifier).loadSample();
      await c.read(typeSettingsProvider.notifier).set(s.settings);
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
        await s.setup!(tester);
        await decode(3);
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('ui087/dev/${s.id}.png'),
      );
      await settle(tester);
    });
  }
}
