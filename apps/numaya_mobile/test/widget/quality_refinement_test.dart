import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/demo/application/type_settings_controller.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Quality refinement (2026-11-15): owner invariants and accessibility checks across the
/// release screens. QR-003 radius cap, QR-012 guidelines, UI-097 reset boundary.
void main() {
  setUpAll(loadAppFonts);
  tearDown(() => DevModeStyles.apply(TypeSettings.baseline));

  /// Every rendered corner on screen is either finite and at most [AppRadii.maxFinite], or a true
  /// circle or capsule (radius at least half the shorter side, or the pill token).
  List<String> overCap(WidgetTester tester) {
    final problems = <String>[];
    void check(BorderRadiusGeometry? geometry, Element e, String what) {
      if (geometry is! BorderRadius) return;
      final box = e.renderObject;
      if (box is! RenderBox || !box.hasSize) return;
      final half = box.size.shortestSide / 2;
      for (final r in [
        geometry.topLeft,
        geometry.topRight,
        geometry.bottomLeft,
        geometry.bottomRight,
      ]) {
        final v = r.x;
        final capsule = v >= half - 0.5 || v >= AppRadii.pill;
        if (v > AppRadii.maxFinite + 0.01 && !capsule) {
          problems.add('$what ${e.widget.runtimeType} r=$v size=${box.size}');
        }
      }
    }

    for (final e in tester.allElements) {
      final w = e.widget;
      if (w is Container && w.decoration is BoxDecoration) {
        check((w.decoration! as BoxDecoration).borderRadius, e, 'decoration');
      } else if (w is DecoratedBox && w.decoration is BoxDecoration) {
        check((w.decoration as BoxDecoration).borderRadius, e, 'decoration');
      } else if (w is AnimatedContainer && w.decoration is BoxDecoration) {
        check((w.decoration! as BoxDecoration).borderRadius, e, 'decoration');
      } else if (w is ClipRRect) {
        check(w.borderRadius, e, 'clip');
      }
    }
    return problems;
  }

  const routes = [
    Routes.home,
    Routes.likes,
    Routes.messages,
    '${Routes.chat}/priya',
    Routes.profile,
    Routes.preview,
    Routes.settings,
    Routes.premium,
    Routes.wallet,
    Routes.streak,
    Routes.setupName,
    Routes.setupVerify,
    Routes.photos,
    '${Routes.storeOutcome}?kind=premiumMonthly&result=failed',
    Routes.reviewTypography,
  ];

  group('QR-003 finite corners are at most 20 (circles and capsules excepted)', () {
    test('the shared tokens respect the cap', () {
      for (final r in [
        AppRadii.tag,
        AppRadii.chip,
        AppRadii.badge,
        AppRadii.field,
        AppRadii.control,
        AppRadii.iconButton,
        AppRadii.tile,
        AppRadii.card,
        AppRadii.heroCard,
        AppRadii.photo,
        AppRadii.sheet,
        AppRadii.dialog,
        SquircleIconButton.photoRadius,
      ]) {
        expect(r, lessThanOrEqualTo(AppRadii.maxFinite));
      }
      expect(SquircleIconButton.photoRadius, 20);
      // The floating control keeps its own geometry (not nested in the photo).
      expect(AppRadii.iconButton, 12);
      expect(SquircleIconButton.photoInset, AppLayout.cardPadding);
    });

    for (final route in routes) {
      for (final pill in [false, true]) {
        testWidgets('$route${pill ? ' (Fully rounded buttons)' : ''}', (
          tester,
        ) async {
          await usePhoneSize(tester);
          final c = await quickStartApp(tester, world: DemoWorld.full);
          c.read(onboardingProvider.notifier).loadSample();
          if (pill) {
            c
                .read(typeSettingsProvider.notifier)
                .restore(const TypeSettings(shape: ButtonShape.pill));
          }
          await goTo(c, tester, route);
          await tester.pump(const Duration(milliseconds: 500));
          expect(overCap(tester), isEmpty);
          await settle(tester);
        });
      }
    }
  });

  group('QR-012 Android accessibility guidelines', () {
    for (final route in [
      Routes.messages,
      Routes.settings,
      Routes.reviewTypography,
      '${Routes.storeOutcome}?kind=premiumMonthly&result=failed',
      Routes.setupName,
      Routes.home,
    ]) {
      testWidgets('$route: tap targets, labels and text contrast', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await usePhoneSize(tester);
        final c = await quickStartApp(tester, world: DemoWorld.full);
        await goTo(c, tester, route);
        await tester.pump(const Duration(milliseconds: 500));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // Discover's card runs below the fold; the contrast guideline samples off-screen
        // nodes (a black-on-#F4F4F4 chip at y=906 on an 852pt screen read as 2.47:1), so it
        // is measured on the screens that fit. Tap targets and labels are checked everywhere.
        if (route != Routes.home) {
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        }
        handle.dispose();
        await settle(tester);
      });
    }
  });

  testWidgets('UI-097 Reset all restores Dev Mode only, never account data', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.full);
    c.read(onboardingProvider.notifier).loadSample();
    final draft = c.read(onboardingProvider).draft;
    final threads = c.read(datingProvider).threads.length;
    final controller = c.read(typeSettingsProvider.notifier);
    controller.restore(
      const TypeSettings(
        pairing: FontPairing.yesevaJosefin,
        bodySize: 14,
        brand: BrandOption.lilac,
        shape: ButtonShape.pill,
        secondary: SecondarySurface.filled,
      ),
    );
    // reset() also deletes the saved file: real IO needs a real async zone in a widget test.
    await tester.runAsync(controller.reset);
    expect(c.read(typeSettingsProvider), TypeSettings.baseline);
    expect(AppColors.accent, const Color(0xFF7262C7));
    expect(c.read(onboardingProvider).draft, draft);
    expect(c.read(datingProvider).threads.length, threads);
    await settle(tester);
  });

  testWidgets(
    'DEF-QR-01 signed in, /verify with no code request goes home, not black',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, Routes.verify);
      await tester.pump(const Duration(milliseconds: 500));
      expect(c.read(routerProvider).state.uri.path, Routes.home);
      await settle(tester);
    },
  );
}
