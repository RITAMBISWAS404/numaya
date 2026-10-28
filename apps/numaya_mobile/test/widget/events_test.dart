import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/events/application/events_controller.dart';
import 'package:numaya_mobile/features/events/domain/event.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

Finder _label(Pattern p) => find.bySemanticsLabel(p);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tapOn(tester, f);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _sheet(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('from onboarding: Events is a tab; search narrows the list', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await openTab(tester, 'Events');
    expect(find.text('Late jazz at the Vortex'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'castle');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Bouldering for beginners'), findsOneWidget);
    expect(find.text('Late jazz at the Vortex'), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'karaoke');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No events match'), findsOneWidget);
    await _tap(tester, find.text('Clear search and filters'));
    expect(find.text('Late jazz at the Vortex'), findsWidgets);
    await settle(tester);
  });

  testWidgets('join, see it in My events, leave with confirmation', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, '${Routes.event}/e-jazz');
    expect(find.text('Late jazz at the Vortex'), findsOneWidget);
    expect(find.text('7 going · 2 spots left'), findsOneWidget);
    await _tap(tester, find.widgetWithText(NumayaButton, 'Join'));
    expect(find.text('You’re going'), findsWidgets);
    expect(find.text('8 going · 1 spot left'), findsOneWidget);
    expect(
      c.read(eventsProvider).byId('e-jazz')!.participation,
      Participation.going,
    );

    await goTo(c, tester, '${Routes.events}?view=mine');
    expect(find.text('Late jazz at the Vortex'), findsOneWidget);

    await goTo(c, tester, '${Routes.event}/e-jazz');
    await _tap(tester, find.widgetWithText(NumayaButton, 'Leave'));
    await _sheet(tester);
    expect(find.text('Leave this event?'), findsOneWidget);
    await _tap(tester, find.widgetWithText(NumayaButton, 'Leave').last);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('You’re not going any more'), findsOneWidget);
    expect(find.widgetWithText(NumayaButton, 'Join'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('a full event: join the waitlist, see the position, leave it', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, '${Routes.event}/e-board');
    expect(find.text('7 going · Full'), findsOneWidget);
    await _tap(tester, find.widgetWithText(NumayaButton, 'Join waitlist'));
    expect(find.text('On the waitlist, number 3'), findsOneWidget);
    // A spot opening further up moves the queue; the member is now second.
    c.read(eventsProvider.notifier).openSpot('e-board');
    await tester.pump();
    expect(find.text('On the waitlist, number 2'), findsOneWidget);
    await _tap(tester, find.widgetWithText(NumayaButton, 'Leave waitlist'));
    await _sheet(tester);
    await _tap(
      tester,
      find.widgetWithText(NumayaButton, 'Leave waitlist').last,
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.widgetWithText(NumayaButton, 'Join waitlist'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('the host’s question is answered before joining', (tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, '${Routes.event}/e-climb');
    await _tap(tester, find.widgetWithText(NumayaButton, 'Join'));
    await _sheet(tester);
    expect(find.text('A question from the host'), findsOneWidget);
    final send = find.widgetWithText(NumayaButton, 'Join').last;
    expect(tester.widget<NumayaButton>(send).onPressed, isNull);
    await tester.enterText(find.byType(TextField).last, 'Twice, no injuries');
    await tester.pump();
    await _tap(tester, find.widgetWithText(NumayaButton, 'Join').last);
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(eventsProvider).answers['e-climb'], 'Twice, no injuries');
    expect(find.text('Twice, no injuries'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('closed, live, cancelled and past events can’t be joined', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, '${Routes.event}/e-swim');
    expect(find.text('Registration closed'), findsWidgets);
    expect(find.widgetWithText(NumayaButton, 'Join'), findsNothing);
    await goTo(c, tester, '${Routes.event}/e-runclub');
    expect(find.text('Happening now'), findsWidgets);
    await goTo(c, tester, '${Routes.event}/e-poetry');
    expect(
      find.textContaining('The venue has closed for repairs'),
      findsOneWidget,
    );
    expect(find.text('Nobody can join a cancelled event.'), findsOneWidget);
    await goTo(c, tester, '${Routes.event}/e-roast');
    expect(find.text('This event has ended'), findsWidgets);
    expect(find.text('You went'), findsOneWidget);
    await goTo(c, tester, '${Routes.event}/nope');
    expect(find.text('Event not found'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('a failed join changes nothing and offers Try again', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    c.read(datingProvider.notifier).setSimulateErrors(true);
    await goTo(c, tester, '${Routes.event}/e-jazz');
    await _tap(tester, find.widgetWithText(NumayaButton, 'Join'));
    expect(find.text('Couldn’t save that'), findsOneWidget);
    expect(
      c.read(eventsProvider).byId('e-jazz')!.participation,
      Participation.none,
    );
    c.read(datingProvider.notifier).setSimulateErrors(false);
    await _tap(tester, find.widgetWithText(NumayaButton, 'Try again'));
    expect(
      c.read(eventsProvider).byId('e-jazz')!.participation,
      Participation.going,
    );
    expect(find.text('Couldn’t save that'), findsNothing);

    // Explore's load error and its retry.
    c.read(datingProvider.notifier).setSimulateErrors(true);
    await goTo(c, tester, Routes.events);
    expect(find.text('We couldn’t load events'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.bySemanticsLabel('Loading events'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Still can’t load events'), findsOneWidget);
    c.read(datingProvider.notifier).setSimulateErrors(false);
    await tester.pump();
    expect(find.text('Late jazz at the Vortex'), findsWidgets);
    await settle(tester);
  });

  testWidgets('filters: free only and online change the list and the count', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, Routes.events);
    await _tap(tester, _label('Filters'));
    await _sheet(tester);
    final all = c.read(eventsProvider.notifier).explore().length;
    expect(find.text('Show $all events'), findsOneWidget);
    await _tap(tester, _label(RegExp('^Free only')));
    final free = c
        .read(eventsProvider.notifier)
        .explore(filters: const EventFilters(freeOnly: true))
        .length;
    expect(find.text('Show $free events'), findsOneWidget);
    await _tap(tester, find.text('Show $free events'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Late jazz at the Vortex'), findsNothing); // has a cost
    expect(_label('Filters, 1 on'), findsOneWidget);
    // Distance without an area explains itself.
    await _tap(tester, _label('Filters, 1 on'));
    await _sheet(tester);
    expect(find.text('No area chosen'), findsOneWidget);
    await _tap(tester, find.text('Reset'));
    expect(find.text('Show $all events'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('save from a card; it appears in My events › Saved', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, Routes.events);
    await _tap(tester, _label('Save Late jazz at the Vortex').first);
    expect(c.read(eventsProvider).saved, contains('e-jazz'));
    expect(find.text('Saved'), findsWidgets);
    await goTo(c, tester, '${Routes.events}?view=mine');
    await _tap(tester, _label('Saved, 2'));
    expect(find.text('Late jazz at the Vortex'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('create: errors first, then publish; it appears under Hosting', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, Routes.events);
    await _tap(tester, _label('Create an event'));
    expect(find.text('NEW EVENT'), findsOneWidget);
    await _tap(tester, find.widgetWithText(NumayaButton, 'Publish'));
    expect(find.text('Add a title of at least 4 characters.'), findsOneWidget);
    expect(find.text('Choose a category.'), findsOneWidget);
    expect(find.text('Add the public place you’ll meet.'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Coffee and sketching');
    await _tap(tester, find.text('Arts'));
    await tester.enterText(
      fields.at(1),
      'Pencils, a big table and a slow Sunday morning together.',
    );
    await _tap(tester, find.text('Date'));
    await _sheet(tester);
    await _tap(tester, find.text('Sun 1 Nov'));
    await tester.pump(const Duration(milliseconds: 600));
    await _tap(tester, find.text('Start time'));
    await _sheet(tester);
    await _tap(tester, find.text('10:00'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(fields.at(2), 'Pophams, London Fields');
    await tester.pump();
    await _tap(tester, find.widgetWithText(NumayaButton, 'Publish'));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Your event is live'), findsOneWidget);
    final mine = c.read(eventsProvider.notifier).hosting();
    expect(mine.single.title, 'Coffee and sketching');
    expect(mine.single.status, EventStatus.published);

    await goTo(c, tester, '${Routes.events}?view=mine');
    await _tap(tester, _label('Hosting, 1'));
    expect(find.text('Coffee and sketching'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('leaving a form with changes asks; Save draft keeps it private', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, Routes.events);
    await _tap(tester, _label('Create an event'));
    await tester.enterText(find.byType(TextField).first, 'Picnic plan');
    await tester.pump();
    await tester.binding.handlePopRoute();
    await _sheet(tester);
    expect(find.text('Leave without saving?'), findsOneWidget);
    await _tap(tester, find.widgetWithText(NumayaButton, 'Save draft').last);
    await tester.pump(const Duration(milliseconds: 800));
    final draft = c.read(eventsProvider.notifier).hosting().single;
    expect(draft.status, EventStatus.draft);
    expect(find.text('Draft'), findsWidgets);
    expect(c.read(eventsProvider.notifier).explore(), isNot(contains(draft)));
    // Publishing an incomplete draft sends the host back to finish it.
    await _tap(tester, find.widgetWithText(NumayaButton, 'Publish'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('EDIT EVENT'), findsOneWidget);
    await settle(tester);
  });

  testWidgets(
    'host: remove an attendee promotes the waitlist; cancel the event',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      await goTo(c, tester, '${Routes.event}/e-mine');
      expect(find.text('Hosting'), findsWidgets);
      await _tap(tester, find.widgetWithText(NumayaButton, 'Attendees'));
      expect(find.text('Jo'), findsOneWidget); // waiting
      await _tap(tester, find.bySemanticsLabel(RegExp('^Ollie')));
      await _sheet(tester);
      await _tap(tester, find.widgetWithText(NumayaButton, 'Remove'));
      await tester.pump(const Duration(milliseconds: 600));
      final e = c.read(eventsProvider).byId('e-mine')!;
      expect(e.attendees, contains('jo'));
      expect(e.waitlist, isEmpty);
      c.read(routerProvider).pop();
      await tester.pump(const Duration(milliseconds: 600));

      await _tap(tester, find.text('Cancel event'));
      await _sheet(tester);
      await tester.enterText(find.byType(TextField).last, 'Ill, sorry');
      await _tap(tester, find.widgetWithText(NumayaButton, 'Cancel event'));
      await tester.pump(const Duration(milliseconds: 800));
      expect(
        c.read(eventsProvider).byId('e-mine')!.status,
        EventStatus.cancelled,
      );
      expect(find.textContaining('Ill, sorry'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets('report an event: kept on this device, block offered', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester, world: DemoWorld.fresh);
    await goTo(c, tester, '${Routes.event}/e-jazz');
    await _tap(tester, find.text('Report this event'));
    await _sheet(tester);
    await _tap(tester, find.text('Spam or selling something'));
    await _tap(tester, find.widgetWithText(NumayaButton, 'Send report'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      c.read(eventsProvider).reports.single.reason,
      'Spam or selling something',
    );
    expect(find.text('Block Tomás'), findsOneWidget);
    await _tap(tester, find.text('Done'));
    await settle(tester);
  });
}
