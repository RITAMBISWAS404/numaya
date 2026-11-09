import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/features/events_mvp/application/events_mvp_controller.dart';
import 'package:numaya_mobile/features/events_mvp/domain/event_models.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Events MVP screens (E01–E05) through the real app with a completed demo profile.
void main() {
  const board = 'ev-board-games-bandra';

  Future<void> reserveThroughUi(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('ev-ack')));
    await tester.pump();
    final confirm = find.byKey(const ValueKey('ev-confirm'));
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets(
    'E01: the Events tab is the fourth of five and lists sample events',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, overrides: eventsOn);
      await openTab(tester, 'Events');
      expect(c.read(routerProvider).state.uri.path, Routes.events);
      expect(find.byKey(const ValueKey('ev-sample-banner')), findsOneWidget);
      expect(find.byKey(const ValueKey('ev-card-$board')), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'E02→E03→E05: reserve once, a second reserve returns the same place, cancel',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, overrides: eventsOn);
      final ev = c.read(eventsMvpProvider.notifier);
      final left = ev.placesLeft(board);
      await goTo(c, tester, '${Routes.evEvent}/$board/reserve');
      await reserveThroughUi(tester);
      expect(find.byKey(const ValueKey('ev-reserved')), findsOneWidget);
      expect(ev.placesLeft(board), left - 1);
      expect(
        c.read(eventsMvpProvider).reservations[board]!.status,
        ResStatus.confirmed,
      );

      // A repeated submit never takes a second place.
      final again = ev.reserve(board, discoverable: false);
      await tester.pump(const Duration(milliseconds: 600));
      expect(await again, ReserveResult.alreadyReserved);
      expect(ev.placesLeft(board), left - 1);

      await goTo(c, tester, '${Routes.evReservation}/$board');
      final cancel = find.byKey(const ValueKey('ev-cancel'));
      await tester.scrollUntilVisible(
        cancel,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(cancel);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('ev-cancel-confirm')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ev-cancel-confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final r = c.read(eventsMvpProvider).reservations[board]!;
      expect(r.status, ResStatus.cancelled);
      expect(r.cancelReason, CancelReason.member);
      expect(ev.placesLeft(board), left);
      // Cancelling twice changes nothing.
      expect(ev.cancel(board), isFalse);
      await settle(tester);
    },
  );

  testWidgets(
    'E03: a full event offers no reservation; offline shows an error, then works',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, overrides: eventsOn);
      final ev = c.read(eventsMvpProvider.notifier);
      final full = ev.reserve('ev-coffee-indiranagar', discoverable: false);
      await tester.pump(const Duration(milliseconds: 600));
      expect(await full, ReserveResult.full);
      await goTo(c, tester, '${Routes.evEvent}/ev-coffee-indiranagar');
      expect(find.byKey(const ValueKey('ev-full')), findsOneWidget);
      expect(find.byKey(const ValueKey('ev-reserve')), findsNothing);

      c.read(connectivityProvider.notifier).setOnline(false);
      await goTo(c, tester, '${Routes.evEvent}/$board/reserve');
      await reserveThroughUi(tester);
      expect(find.byKey(const ValueKey('ev-result-error')), findsOneWidget);
      expect(c.read(eventsMvpProvider).reservations[board], isNull);

      c.read(connectivityProvider.notifier).setOnline(true);
      final confirm = find.byKey(const ValueKey('ev-confirm'));
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('ev-reserved')), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'E03: an uncertain result is reconciled, never resubmitted blind',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, overrides: eventsOn);
      final ev = c.read(eventsMvpProvider.notifier)..setDropNextResponse(true);
      final first = ev.reserve(board, discoverable: false);
      await tester.pump(const Duration(milliseconds: 600));
      expect(await first, ReserveResult.uncertain);
      final left = ev.placesLeft(board);
      final second = ev.reserve(board, discoverable: false);
      await tester.pump(const Duration(milliseconds: 600));
      // The place was taken on the server: reconciling finds it, nothing is taken twice.
      expect(
        await second,
        isIn([ReserveResult.confirmed, ReserveResult.alreadyReserved]),
      );
      expect(ev.placesLeft(board), left);
      await settle(tester);
    },
  );

  testWidgets('E04: My events shows upcoming, past and cancelled', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, overrides: eventsOn);
    await goTo(c, tester, Routes.evMine);
    for (final k in ['ev-mine-upcoming', 'ev-mine-past', 'ev-mine-cancelled']) {
      expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
    }
    await settle(tester);
  });

  testWidgets('H01: staff tools carry the internal demo-role banner', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, overrides: eventsOn);
    await goTo(c, tester, Routes.staff);
    expect(find.byKey(const ValueKey('ev-staff-banner')), findsOneWidget);
    await settle(tester);
  });
}
