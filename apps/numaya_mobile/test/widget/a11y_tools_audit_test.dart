import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/app.dart';
import 'package:numaya_mobile/app/routes.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Runtime accessibility checkers from `accessibility_tools` (dev dependency only) over the core
/// journey. The package reports through debugPrint ("Accessibility issue N: ..."); this test
/// captures that output per route. It covers semantic labels, tap areas, input labels and image
/// labels. Contrast, focus order and speech are covered elsewhere (guideline tests, device notes).
void main() {
  setUpAll(loadAppFonts);

  const routes = [
    Routes.home,
    Routes.likes,
    '${Routes.like}/kemi',
    Routes.messages,
    '${Routes.chat}/priya',
    '${Routes.match}/amara',
    Routes.events,
    '${Routes.event}/e-jazz',
    Routes.profile,
    Routes.editProfile,
    Routes.settings,
    Routes.safety,
    Routes.openingMoves,
    Routes.premium,
  ];

  testWidgets('accessibility_tools reports no issues on the core journey', (
    tester,
  ) async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    NumayaApp.debugWrapper = (context, child) =>
        AccessibilityTools(child: child);
    final found = <String, List<String>>{};
    try {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      for (final route in routes) {
        logs.clear();
        await goTo(c, tester, route);
        // The checkers run after layout settles.
        await tester.pump(const Duration(seconds: 2));
        final issues = logs
            .where((l) => l.startsWith('Accessibility issue'))
            .toList();
        if (issues.isNotEmpty) found[route] = issues;
      }
      await settle(tester);
    } finally {
      // Flutter requires debug globals to be restored before the test body ends.
      debugPrint = original;
      NumayaApp.debugWrapper = null;
    }
    // Report every finding in the test output before asserting.
    found.forEach((route, issues) {
      debugPrint('[a11y_tools] $route: ${issues.length}');
      for (final i in issues) {
        debugPrint('  $i');
      }
    });
    expect(found, isEmpty);
  });

  // Negative control: proves the checkers run in this harness, so the clean result above is real.
  testWidgets('the checkers do flag an unlabelled, undersized tap target', (
    tester,
  ) async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    try {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => AccessibilityTools(child: child),
          home: Scaffold(
            body: Center(
              child: GestureDetector(
                onTap: () {},
                child: const SizedBox(width: 20, height: 20),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
    } finally {
      debugPrint = original;
    }
    expect(logs.where((l) => l.startsWith('Accessibility issue')), isNotEmpty);
  });
}
