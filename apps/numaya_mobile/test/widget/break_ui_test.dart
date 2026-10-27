import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';
import '../helpers/worst_case.dart';

/// Worst-case data through the real screens (break-ui): every value is plausible or at the
/// app's own limit, entered through the same controllers the screens use.
void main() {
  setUpAll(loadAppFonts);

  const routes = [
    Routes.profile,
    Routes.completion,
    Routes.editProfile,
    Routes.preview,
    Routes.openingMoves,
    Routes.messages,
    '${Routes.chat}/priya',
    Routes.settings,
    Routes.premium,
  ];

  for (final (size, scale) in [
    (const Size(320, 568), 1.0),
    (const Size(375, 667), 1.3),
    (const Size(393, 852), 2.0),
  ]) {
    testWidgets(
      'worst-case profile lays out at ${size.width.toInt()} pt and ${(scale * 100).round()}% text',
      (tester) async {
        await usePhoneSize(tester, size: size);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final c = await quickStartApp(tester);
        applyWorstCase(c);
        // A long unbroken message in a conversation.
        unawaited(
          c
              .read(datingProvider.notifier)
              .send(
                'priya',
                'https://maps.example.com/place/Columbia+Road+Flower+Market/@51.5291,-0.0700,17z',
              ),
        );
        await tester.pump(const Duration(seconds: 2));
        // Collect layout errors with the widget that raised them, per route.
        final errors = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (d) => errors.add(
          d
              .toString()
              .split('\n')
              .where(
                (l) =>
                    l.contains('overflowed') || l.contains('numaya_mobile/lib'),
              )
              .join(' '),
        );
        final failures = <String, List<String>>{};
        for (final route in routes) {
          await goTo(c, tester, route);
          await tester.pump(const Duration(milliseconds: 300));
          if (errors.isNotEmpty) failures[route] = [...errors];
          errors.clear();
        }
        await settle(tester);
        FlutterError.onError = previous;
        expect(failures, isEmpty);
      },
    );
  }
}
