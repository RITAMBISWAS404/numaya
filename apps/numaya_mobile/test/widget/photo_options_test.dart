import 'package:flutter_test/flutter_test.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(loadAppFonts);

  Finder tile(int position) => find.bySemanticsLabel('Photo $position options');

  testWidgets('photos step: make main, remove, cancel', (tester) async {
    await usePhoneSize(tester);
    await signUpToInterests(tester, testAuth());
    // Back from Interests to Photos, which already has two.
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await addLibraryPhoto(tester);
    expect(tile(3), findsOneWidget);

    // The main photo offers only Remove.
    await tapOn(tester, tile(1));
    await tester.pumpAndSettle();
    expect(find.text('Make main photo'), findsNothing);
    await tapOn(tester, find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tile(3), findsOneWidget);

    await tapOn(tester, tile(3));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Make main photo'));
    await tester.pump();
    expect(find.text('Main photo updated'), findsOneWidget);
    await settle(tester);

    // During sign-up, removing is allowed below the minimum; Next waits for 2 again.
    await tapOn(tester, tile(2));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Remove photo'));
    await tester.pumpAndSettle();
    await tapOn(tester, tile(2));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Remove photo'));
    await tester.pumpAndSettle();
    expect(tile(2), findsNothing);
    expect(fabEnabled(tester), isFalse);
    await settle(tester);
  });

  testWidgets('edit profile keeps at least 2 photos', (tester) async {
    await usePhoneSize(tester);
    await signUpToHome(tester, testAuth());
    await openTab(tester, 'Profile');
    await tapOn(tester, find.text('Edit profile'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('Tap a photo to make it your main one. Keep at least 2.'),
      findsOneWidget,
    );
    await tapOn(tester, tile(2));
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Remove photo'));
    await tester.pump();
    expect(find.text('Keep at least 2 photos'), findsOneWidget);
    expect(tile(2), findsOneWidget);
    await settle(tester);
  });
}
