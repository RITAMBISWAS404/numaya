import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/router.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/home/application/discovery_filters.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

Finder _action(String label) => find.bySemanticsLabel(label);

/// Round Pass / Like / SuperSwipe buttons that can be tapped right now (on screen and not hidden).
Finder _tappable(String label) => find
    .byWidgetPredicate((w) => w is RoundAction && w.label == label)
    .hitTestable();

/// The Pass / Like / SuperSwipe circles at the end of the profile.
Future<void> _decide(WidgetTester tester, String label) async {
  await tapOn(tester, _action(label).last);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Taps something already on screen without scrolling it into view first (tapOn aligns its
/// target to the top, which would scroll Discover's profile).
Future<void> _tapHere(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  // Anything that started on that last frame (the floating actions fading in) finishes.
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Scrolls Discover's profile by [dy] (positive reads further down).
Future<void> _scrollProfile(WidgetTester tester, double dy) async {
  await tester.drag(find.byType(SingleChildScrollView).first, Offset(0, -dy));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'from onboarding: the first card shows the swipe tip and a photo count; Hide tip removes it',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      expect(find.text('Maya, 29'), findsOneWidget);
      expect(
        find.text(
          'Swipe right to like, left to pass. Scroll for more about them.',
        ),
        findsOneWidget,
      );
      expect(find.text('4 photos'), findsOneWidget);
      await _tapHere(tester, _action('Hide tip'));
      expect(find.textContaining('Swipe right to like'), findsNothing);
      // Filters match the sign-up preferences: no "changed" mark.
      expect(_action('Filters'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'photos: the card opens the viewer; next / previous / back; a section photo opens at itself',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await _tapHere(tester, _action('See Maya’s photos').first);
      expect(find.text('MAYA’S PHOTOS'), findsOneWidget);
      expect(find.text('Photo 1 of 4'), findsOneWidget);
      await _tapHere(tester, _action('Next photo'));
      expect(find.text('Photo 2 of 4'), findsOneWidget);
      // Swiping sideways pages too.
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Photo 3 of 4'), findsOneWidget);
      await _tapHere(tester, _action('Previous photo'));
      expect(find.text('Photo 2 of 4'), findsOneWidget);
      await _systemBack(tester);
      expect(find.text('Maya, 29'), findsOneWidget);
      expect(find.text('Photo 2 of 4'), findsNothing);

      // A photo further down the profile opens the viewer at that photo.
      await _scrollProfile(tester, 900);
      await _tapHere(
        tester,
        find.bySemanticsLabel('See Maya’s photos').hitTestable().first,
      );
      expect(find.text('Photo 2 of 4'), findsOneWidget);
      await _tapHere(tester, _action('Back'));
      expect(find.text('Photo 2 of 4'), findsNothing);
      await settle(tester);
    },
  );

  testWidgets(
    'reading a profile: actions float over it, back returns to the photo, then Home stays',
    (tester) async {
      await usePhoneSize(tester);
      await signUpToHome(tester, testAuth());
      await _tapHere(tester, _action('Hide tip'));
      // Over the photo card no Pass can be tapped: the inline row is far below, the floating
      // one hidden.
      expect(_tappable('Pass'), findsNothing);

      // "Show more about Maya" on the name band scrolls to the profile.
      await _tapHere(
        tester,
        find.bySemanticsLabel(RegExp('^Show more about Maya')),
      );
      expect(_tappable('Pass'), findsOneWidget); // floating over the profile
      await _tapHere(tester, _tappable('Pass'));
      // The next person starts at their photo, with the floating bar hidden again.
      expect(find.text('Sam, 31'), findsOneWidget);
      expect(_tappable('Pass'), findsNothing);

      // Android back deep in a profile returns to the top first; at the top Home stays put
      // (the shell, not Discover, decides to leave the app).
      await _scrollProfile(tester, 600);
      expect(_tappable('Pass'), findsOneWidget);
      await _systemBack(tester);
      expect(_tappable('Pass'), findsNothing);
      expect(find.text('Sam, 31'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets('undo brings the pass back with a message; one step only', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await _decide(tester, 'Pass');
    await _decide(tester, 'Pass');
    expect(find.text('Noor, 28'), findsOneWidget);
    await tapOn(tester, _action('Undo: bring back Sam'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Sam, 31'), findsOneWidget);
    expect(find.text('Sam is back'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Undo')), findsNothing);
    // A like is sent: nothing to undo after it.
    await _decide(tester, 'Like');
    expect(find.bySemanticsLabel(RegExp('^Undo')), findsNothing);
    await settle(tester);
  });

  testWidgets(
    'SuperSwipe sends a like with a credit; out of credits opens the paywall',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.fresh);
      c.read(datingProvider.notifier).dismissCoach();
      await tester.pump();
      for (var left = 2; left >= 0; left--) {
        final person = c.read(datingProvider.notifier).queue().first;
        await _decide(tester, 'SuperSwipe');
        await tester.pump(const Duration(milliseconds: 600));
        expect(c.read(datingProvider).superSwiped, contains(person.id));
        expect(c.read(datingProvider).superSwipes, left);
        if (person.likesYou) {
          // Someone who liked you: a match. Keep browsing returns to Home.
          expect(
            c.read(routerProvider).state.uri.path,
            startsWith(Routes.match),
          );
          await tapOn(tester, find.text('Keep browsing'));
          await tester.pump(const Duration(milliseconds: 600));
        } else {
          expect(
            find.textContaining('SuperSwipe sent to ${person.name}'),
            findsOneWidget,
          );
        }
        await tester.pump(const Duration(seconds: 4));
      }
      await _decide(tester, 'SuperSwipe');
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.read(routerProvider).state.uri.path, Routes.paywall);
      await settle(tester);
    },
  );

  testWidgets('report and block from the end of a profile', (tester) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await _tapHere(tester, _action('Hide tip'));
    await tapOn(tester, find.text('Report or block Maya'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Report'), findsOneWidget);
    await tapOn(tester, find.text('Block Maya'));
    await tester.pump(const Duration(milliseconds: 400));
    // The block sheet confirms first.
    expect(find.text('Block Maya?'), findsOneWidget);
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Block Maya'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Maya, 29'), findsNothing);
    expect(find.text('Sam, 31'), findsOneWidget);
    await settle(tester);
  });

  testWidgets(
    'everyone liked: no "show again", and a way to the people who like you',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.fresh);
      final dating = c.read(datingProvider.notifier);
      c.read(discoveryFiltersProvider.notifier).broaden();
      for (final p in dating.queue()) {
        dating.decide(p.id, liked: true);
      }
      await tester.pump();
      expect(find.text('You’ve seen everyone for now'), findsOneWidget);
      expect(find.text('Show them again'), findsNothing);
      expect(dating.unansweredLikes(), greaterThan(0));
      await tapOn(tester, find.text('See who likes you'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.read(routerProvider).state.uri.path, Routes.likes);
      await settle(tester);
    },
  );

  testWidgets(
    'exhausted after passes: show them again brings back passes only',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester, world: DemoWorld.fresh);
      final dating = c.read(datingProvider.notifier);
      c.read(discoveryFiltersProvider.notifier).broaden();
      final ids = [for (final p in dating.queue()) p.id];
      dating.decide(ids.first, liked: true);
      for (final id in ids.skip(1)) {
        dating.decide(id, liked: false);
      }
      await tester.pump();
      expect(find.text('You’ve seen everyone for now'), findsOneWidget);
      await tapOn(tester, find.text('Show them again'));
      expect(dating.queue().map((p) => p.id), ids.skip(1));
      await settle(tester);
    },
  );

  testWidgets(
    'the name band and photo are labelled buttons for screen readers',
    (tester) async {
      await usePhoneSize(tester);
      final handle = tester.ensureSemantics();
      await signUpToHome(tester, testAuth());
      final band = tester
          .getSemantics(
            find.bySemanticsLabel(RegExp('^Show more about Maya')).first,
          )
          .getSemanticsData();
      expect(band.flagsCollection.isButton, isTrue);
      expect(band.hasAction(SemanticsAction.tap), isTrue);
      expect(_action('See Maya’s photos'), findsWidgets);
      handle.dispose();
      await settle(tester);
    },
  );
}
