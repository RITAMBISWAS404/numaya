import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
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
