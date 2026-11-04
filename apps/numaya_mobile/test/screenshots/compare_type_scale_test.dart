@Tags(['comparison'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/tokens/monochrome_tokens.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';
import '../helpers/worst_case.dart';

/// Controlled type-scale comparison (overnight polish). Identical demo data, viewport, theme and
/// frosted tab bar; only `--dart-define=NUMAYA_TYPE_SCALE` changes between runs. Writes to
/// `test/screenshots/comparison/SCALE/WIDTH-TEXT-SCREEN.png`. Opt-in:
/// `flutter test --tags comparison --run-skipped --update-goldens --dart-define=NUMAYA_TYPE_SCALE=body14`.
void main() {
  setUpAll(loadAppFonts);

  const phones = {320: Size(320, 693), 390: Size(390, 844)};
  const scales = [1.0, 2.0];

  for (final MapEntry(key: width, value: phone) in phones.entries) {
    for (final text in scales) {
      testWidgets('type scale ${MonoType.scale} at ${width}dp, ${text}x text', (
        tester,
      ) async {
        tester.view.physicalSize = phone * 2;
        tester.view.devicePixelRatio = 2;
        tester.platformDispatcher.textScaleFactorTestValue = text;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final c = await quickStartApp(tester);
        final prefix =
            'comparison/${MonoType.scale}/$width-${(text * 100).toInt()}';

        Future<void> shot(String name) async {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 300)),
          );
          await tester.pump(const Duration(milliseconds: 600));
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('$prefix-$name.png'),
          );
        }

        // 1. Discover, top of the card.
        await shot('1-discover');
        // 2. Discover, scrolled to the profile prose.
        await tester.scrollUntilVisible(
          find.text('About me').first,
          240,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await shot('2-discover-prose');
        // 3. Own Profile.
        await goTo(c, tester, Routes.profile);
        await shot('3-profile');
        // 4. Long bio: the worst-case profile in preview, scrolled to its prose.
        applyWorstCase(c);
        await goTo(c, tester, Routes.preview);
        await tester.scrollUntilVisible(
          find.text('About me').first,
          240,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await shot('4-long-bio');
        // 5. Chat with a long message from you and the seeded history.
        unawaited(
          c
              .read(datingProvider.notifier)
              .send(
                'priya',
                'I keep a list of record shops in every city I visit — tell me yours and '
                    'I will add it. Last month it was a tiny basement place in Lisbon.',
              ),
        );
        await tester.pump(const Duration(seconds: 2));
        await goTo(c, tester, '${Routes.chat}/priya');
        await shot('5-chat');
        // 6–7. Pill-heavy screens: selectable chips with the worst-case (longest) interests,
        // and Events' view tabs, date filters and status badges.
        await goTo(c, tester, Routes.editInterests);
        await shot('6-pills-interests');
        await goTo(c, tester, Routes.events);
        await shot('7-pills-events');
        await settle(tester);
      });
    }
  }
}
