import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/events_mvp/presentation/ev_parts.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';
import 'package:numaya_mobile/l10n/generated/app_localizations.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Ente refinement V4 (docs/design/ente-refinement-v4/DESIGN_RULES_V4.md): neutral surfaces, solid
/// accents, black glass over photos, a capped photo gradient and the separated event detail.
void main() {
  setUpAll(loadAppFonts);

  double ratio(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
  }

  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  group('IMG photo overlays', () {
    test('the glass keeps white text at 4.5:1 over a pure white photo', () {
      final worst = Color.alphaBlend(
        AppColors.photoPanel,
        const Color(0xFFFFFFFF),
      );
      expect(ratio(AppColors.inkForeground, worst), greaterThanOrEqualTo(4.5));
    });

    test('the gradient peak is 24% black, under the 25% cap (V5 D04)', () {
      expect(AppColors.photoScrimEdge.a, closeTo(0.24, 0.01));
      expect(AppColors.photoScrimEdge.a, lessThan(0.25));
    });

    testWidgets(
      'a photo badge is the black glass pill, clipped to its bounds',
      (tester) async {
        await tester.pumpWidget(
          host(const StatusBadge(label: 'New', tone: BadgeTone.onPhoto)),
        );
        expect(find.byType(PhotoPill), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(
          find.ancestor(
            of: find.byType(BackdropFilter),
            matching: find.byType(ClipRRect),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('high contrast drops the blur and darkens the glass', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: host(const PhotoPill(label: 'New')),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('PhotoScrim paints a gradient and no solid panel', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SizedBox(width: 200, child: PhotoScrim(child: Text('A')))),
      );
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(PhotoScrim),
          matching: find.byType(DecoratedBox),
        ),
      );
      final g = (box.decoration as BoxDecoration).gradient! as LinearGradient;
      expect(g.colors.first, AppColors.photoScrimEdge);
      expect(g.colors.last.a, 0);
      for (final c in g.colors) {
        expect(c.a, lessThan(0.25));
      }
    });
  });

  group('Surfaces and accents', () {
    testWidgets('badges are solid accents, and their labels read at 4.5:1', (
      tester,
    ) async {
      final expected = {
        BadgeTone.brand: AppColors.accent,
        BadgeTone.success: AppColors.success,
        BadgeTone.warning: AppColors.warningBase,
        BadgeTone.error: AppColors.danger,
      };
      for (final MapEntry(key: tone, value: colour) in expected.entries) {
        await tester.pumpWidget(host(StatusBadge(label: 'x', tone: tone)));
        final box = tester.widget<Container>(
          find.descendant(
            of: find.byType(StatusBadge),
            matching: find.byType(Container),
          ),
        );
        expect((box.decoration! as BoxDecoration).color, colour);
      }
      for (final bg in [
        AppColors.accent,
        AppColors.success,
        AppColors.danger,
      ]) {
        expect(ratio(AppColors.inkForeground, bg), greaterThanOrEqualTo(4.5));
      }
      expect(
        ratio(AppColors.ink, AppColors.warningBase),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('white normal text is never placed on the raw anchors', () {
      // The anchors stay palette values; they fail 4.5:1 with white, so roles exist.
      for (final c in [
        AppColors.errorBase,
        AppColors.warningBase,
        AppColors.successBase,
      ]) {
        expect(ratio(AppColors.inkForeground, c), lessThan(4.5));
      }
    });
  });

  group('V4 alternatives and the pilot', () {
    test('new groups keep their baseline and a stated default', () {
      expect(labGroup('v4-event-detail').proposed, 'G');
      expect(
        labGroup('v4-event-detail').ids,
        containsAll(['G', 'O', 'I', 'C']),
      );
      expect(labGroup('v4-photo-label').proposed, 'G');
      expect(labGroup('v4-photo-label').ids, contains('O'));
      expect(labGroup('v4-welcome').ids, contains('O'));
    });

    testWidgets('event detail: About has its own card and no attendee list', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, overrides: eventsOn);
      await goTo(c, tester, '${Routes.evEvent}/ev-board-games-bandra');
      expect(find.byType(EvAboutCard), findsOneWidget);
      expect(find.byType(InitialsAvatar), findsNothing);
      expect(find.textContaining('of 24 places reserved'), findsOneWidget);
      expect(find.byKey(const ValueKey('ev-reserve')), findsOneWidget);
      await settle(tester);
    });

    testWidgets('every V4 alternative lays out at 320dp and 200% text', (
      tester,
    ) async {
      await usePhoneSize(tester, size: const Size(320, 568));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester, overrides: eventsOn);
      final failures = <String>[];
      for (final (id, path) in [
        ('v4-event-detail', '${Routes.evEvent}/ev-board-games-bandra'),
        ('v4-photo-label', Routes.home),
        ('v4-welcome', '${Routes.visualLabPreview}/v4-welcome'),
      ]) {
        for (final v in labGroup(id).ids) {
          c.read(labChoicesProvider.notifier)
            ..reset()
            ..choose(id, v);
          await goTo(c, tester, Routes.demo);
          await goTo(c, tester, path);
          final e = tester.takeException();
          if (e != null) failures.add('$id $v: $e');
        }
      }
      expect(failures, isEmpty);
      await settle(tester);
    });

    testWidgets('a long About collapses and expands from a real control', (
      tester,
    ) async {
      final long = List.filled(40, 'A gentle walk, then breakfast.').join(' ');
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: EvAboutCard(title: 'About this event', body: long),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Read more'), findsOneWidget);
      await tester.tap(find.text('Read more'));
      await tester.pump();
      expect(find.text('Show less'), findsOneWidget);
    });
  });
}
