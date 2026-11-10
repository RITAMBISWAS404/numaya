// The owner's export `v7-71564be-2026-11-10`, applied as the defaults of the normal app.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

const _selected = {
  'v6-composer': 'O',
  'v6-quote-style': 'O',
  'v6-voice-bubble': 'O',
  'discover-photo': 'O',
  'prompt-card': 'O',
  'screen-discover': 'O',
  'v4-photo-label': 'G',
  'v6-discover-margin': 'O',
  'v7-discover': 'O',
  'v7-filters': 'O',
  'compliment-card': 'B',
  'like-tile': 'A',
  'screen-heart': 'O',
  'v7-compliment': 'O',
  'v7-likes-locked': 'O',
  'v7-request': 'B',
  'conversation-row': 'O',
  'match-avatar': 'O',
  'screen-chats': 'O',
  'v4-welcome': 'S',
  'plan-card': 'O',
  'v7-paywall': 'O',
  'profile-header': 'A',
  'profile-setup': 'O',
  'screen-profile': 'O',
  'v7-profile': 'O',
  'v6-settings-plan': 'A',
  'empty-state': 'O',
  'status-banner': 'C',
  'v6-page-title': 'O',
  'v7-nav': 'O',
  'streak-card': 'O',
  'v6-streak-hero': 'O',
  'v7-streak': 'O',
  'v6-wallet-header': 'A',
  'wallet-card': 'A',
};

void main() {
  test('every one of the 36 decisions is the default', () {
    expect(_selected.length, 36);
    for (final e in _selected.entries) {
      expect(labGroup(e.key).proposed, e.value, reason: e.key);
      expect(labGroup(e.key).ids, contains(e.value), reason: e.key);
    }
  });

  group('the normal app has no development controls', () {
    testWidgets('the flag is off without a build define', (tester) async {
      await tester.pumpWidget(testApp(devTools: false));
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(Navigator).first),
      );
      expect(c.read(devToolsAvailableProvider), isFalse);
      expect(
        find.bySemanticsLabel('Demo build. Open the demo hub'),
        findsNothing,
      );
    });

    testWidgets('Settings has no prototype section and labs redirect', (
      tester,
    ) async {
      final c = await quickStartApp(tester, devTools: false);
      await goTo(c, tester, Routes.settings);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.scrollUntilVisible(
        find.text('Delete account'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Demo hub'), findsNothing);
      expect(find.text('Simulate connection problems'), findsNothing);
      for (final path in [Routes.demo, Routes.visualLab]) {
        await goTo(c, tester, path);
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          c.read(routerProvider).routeInformationProvider.value.uri.path,
          isNot(path),
        );
      }
    });

    testWidgets('a stored Lab choice cannot change the normal app', (
      tester,
    ) async {
      final c = await quickStartApp(tester, devTools: false);
      c.read(labChoicesProvider.notifier).choose('v7-request', 'A');
      expect(c.read(labVariantProvider('v7-request')), 'B');
    });
  });
}
