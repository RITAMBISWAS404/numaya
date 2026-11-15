import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../test/helpers/journeys.dart';
import '../test/helpers/test_app.dart';

/// Runs on a phone or emulator:
///   `flutter test integration_test/onboarding_test.dart -d DEVICE_ID`
/// Drives sign-up from Welcome to Home with the demo auth service, through the current
/// onboarding (the same maintained journey the widget tests use, so the two cannot drift).
///
/// 2026-11-15: the previous step-by-step body followed an onboarding layout retired long ago
/// (name, year and gender on one screen) and failed on the iPhone_16_Custom emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign-up reaches Home', (tester) async {
    final auth = testAuth();
    await signUpToHome(tester, auth);
    await tester.pump(const Duration(seconds: 1));
    // Home: the floating tab bar with its four destinations.
    expect(find.byKey(NumayaTabBar.pillKey), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Profile')), findsWidgets);
  });
}
