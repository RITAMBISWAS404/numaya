import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/demo/application/demo_motion.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// The motion system (docs/mobile/MOTION_DESIGN_AUDIT.md): one haptics gate, transitions on the
/// tokens, and the same end state with animations removed.
void main() {
  setUpAll(loadAppFonts);

  /// Records every haptic the app asks the platform for.
  List<String> recordHaptics(WidgetTester tester) {
    final log = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          log.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return log;
  }

  group('AppMotion', () {
    testWidgets('durations and sheets collapse under Remove animations', (
      tester,
    ) async {
      late BuildContext reduced;
      late BuildContext normal;
      await tester.pumpWidget(
        Column(
          children: [
            MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (c) {
                  reduced = c;
                  return const SizedBox();
                },
              ),
            ),
            MediaQuery(
              data: const MediaQueryData(),
              child: Builder(
                builder: (c) {
                  normal = c;
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      );
      expect(AppMotion.duration(reduced, AppMotion.push), Duration.zero);
      expect(AppMotion.duration(normal, AppMotion.push), AppMotion.push);
      expect(AppMotion.sheet(reduced).duration, Duration.zero);
      expect(AppMotion.sheet(normal).duration, AppMotion.sheetIn);
      expect(AppMotion.sheet(normal).reverseDuration, AppMotion.sheetOut);
    });

    test(
      'frequent roles stay under 300 ms; exits are quicker than entrances',
      () {
        for (final d in [AppMotion.press, AppMotion.state, AppMotion.exit]) {
          expect(d.inMilliseconds, lessThan(300));
        }
        expect(AppMotion.exit, lessThan(AppMotion.state + AppMotion.press));
        expect(AppMotion.sheetOut, lessThan(AppMotion.sheetIn));
      },
    );
  });

  group('Haptics', () {
    testWidgets(
      'selection controls tick once, and the Vibration switch silences them',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        final log = recordHaptics(tester);
        await goTo(c, tester, Routes.settings);

        await tapOn(tester, find.bySemanticsLabel(RegExp(r'^New messages\.')));
        expect(log, ['HapticFeedbackType.selectionClick']);

        await tapOn(tester, find.bySemanticsLabel(RegExp(r'^Vibration\.')));
        expect(log, hasLength(2)); // turning it off still acknowledges the tap
        expect(find.bySemanticsLabel('Vibration. Off'), findsOneWidget);

        await tapOn(tester, find.bySemanticsLabel(RegExp(r'^New messages\.')));
        expect(log, hasLength(2));
        await settle(tester);
      },
    );

    testWidgets('plain buttons and links are silent', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      final log = recordHaptics(tester);
      await goTo(c, tester, Routes.settings);
      await tapOn(tester, find.text('Help centre'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(log, isEmpty);
      await settle(tester);
    });
  });

  group('Discover decisions', () {
    testWidgets('Pass leaves first, then the next profile; one commit haptic', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await quickStartApp(tester, world: DemoWorld.fresh);
      final log = recordHaptics(tester);
      expect(find.text('Maya, 29'), findsOneWidget);
      await tester.ensureVisible(find.bySemanticsLabel('Pass').last);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.bySemanticsLabel('Pass').last);
      await tester.pump();
      await tester.pump(AppMotion.exit ~/ 2);
      // Mid-exit: still Maya, fading out; a second tap is ignored.
      expect(find.text('Maya, 29'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Pass').last, warnIfMissed: false);
      await tester.pump(AppMotion.exit);
      await tester.pump(AppMotion.state);
      expect(find.text('Sam, 31'), findsOneWidget);
      expect(log, ['HapticFeedbackType.lightImpact']);
      await settle(tester);
    });

    testWidgets('under reduced motion the next profile replaces it at once', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.fresh);
      c.read(demoReduceMotionProvider.notifier).set(true);
      await tester.pump();
      await tester.ensureVisible(find.bySemanticsLabel('Pass').last);
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Pass').last);
      await tester.pump();
      expect(find.text('Sam, 31'), findsOneWidget);
      expect(c.read(datingProvider).seen, contains('maya'));
      await settle(tester);
    });

    testWidgets('a quick flick decides short of the line; crossing it ticks', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await quickStartApp(tester, world: DemoWorld.fresh);
      final log = recordHaptics(tester);
      // A slow 40 pt drag springs back.
      await tester.timedDrag(
        find.text('Maya, 29'),
        const Offset(40, 0),
        const Duration(milliseconds: 600),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Maya, 29'), findsOneWidget);
      expect(log, isEmpty);
      // A fast 60 pt flick to the left passes.
      await tester.fling(find.text('Maya, 29'), const Offset(-60, 0), 1500);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Sam, 31'), findsOneWidget);
      expect(log, ['HapticFeedbackType.lightImpact']);
      // Dragging past the line and back ticks on each crossing.
      log.clear();
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Sam, 31')),
      );
      for (final dx in [...List.filled(8, 30.0), ...List.filled(8, -30.0)]) {
        await gesture.moveBy(Offset(dx, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 400));
      expect(log, [
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.selectionClick',
      ]);
      expect(find.text('Sam, 31'), findsOneWidget);
      await settle(tester);
    });
  });

  group('Match', () {
    Future<void> likeMaya(WidgetTester tester) async {
      await tester.ensureVisible(find.bySemanticsLabel('Like').last);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.bySemanticsLabel('Like').last);
      await tester.pump();
      await tester.pump(AppMotion.exit);
      await tester.pump(); // the match route starts
    }

    double titleOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.text('It’s a match!', skipOffstage: false),
                matching: find.byType(Opacity, skipOffstage: false),
              )
              .first,
        )
        .opacity;

    testWidgets('one success haptic, and a touch finishes the entrance', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await quickStartApp(tester, world: DemoWorld.fresh);
      final log = recordHaptics(tester);
      await likeMaya(tester);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      expect(titleOpacity(tester), lessThan(1));
      await tester.tap(find.text('It’s a match!'), warnIfMissed: true);
      await tester.pump();
      expect(titleOpacity(tester), 1);
      await settle(tester);
      expect(log, [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
      ]);
    });

    testWidgets('under reduced motion it appears complete', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.fresh);
      c.read(demoReduceMotionProvider.notifier).set(true);
      await tester.pump();
      await tester.ensureVisible(find.bySemanticsLabel('Like').last);
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Like').last);
      await tester.pump();
      await tester.pump();
      expect(titleOpacity(tester), 1);
      await settle(tester);
    });
  });

  group('Transitions', () {
    testWidgets(
      'a page push slides in on the tokens, and is instant when reduced',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, Routes.settings);

        unawaited(c.read(routerProvider).push(Routes.help));
        await tester.pump();
        await tester.pump(AppMotion.push ~/ 4);
        // Mid-push the new page is still partly off to the right.
        final mid = tester.getTopLeft(
          find.byType(NumayaScreen, skipOffstage: false).last,
        );
        expect(mid.dx, greaterThan(0));
        await tester.pump(AppMotion.push);
        expect(
          tester.getTopLeft(find.byType(NumayaScreen).last).dx,
          moreOrLessEquals(0),
        );

        // Reduced motion: the same push lands in a single frame.
        c.read(demoReduceMotionProvider.notifier).set(true);
        await tester.pump();
        c.read(routerProvider).pop();
        await tester.pump(AppMotion.slow);
        unawaited(c.read(routerProvider).push(Routes.help));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          tester.getTopLeft(find.byType(NumayaScreen).last).dx,
          moreOrLessEquals(0),
        );
        await settle(tester);
      },
    );

    testWidgets(
      'the Demo Hub switch turns system reduced motion on for the app',
      (tester) async {
        await usePhoneSize(tester);
        final c = await quickStartApp(tester);
        await goTo(c, tester, Routes.demo);
        BuildContext ctx() => tester.element(find.byType(NumayaScreen).last);
        expect(AppMotion.reduced(ctx()), isFalse);
        await tapOn(tester, find.bySemanticsLabel(RegExp('^Reduce motion')));
        expect(AppMotion.reduced(ctx()), isTrue);
        await settle(tester);
      },
    );
  });
}
