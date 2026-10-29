import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/app.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/features/auth/data/demo_auth_repository.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

final testNow = DateTime(2026, 10, 27, 12);

/// A demo auth service with no latency and a seeded random source.
DemoAuthRepository testAuth() => DemoAuthRepository(
  random: Random(3),
  clock: () => testNow,
  latency: Duration.zero,
);

/// A fixed sample world for tests.
class FixedWorld extends DemoWorldController {
  FixedWorld(this.world);
  final DemoWorld world;

  @override
  DemoWorld build() => world;
}

/// The real app with deterministic dependencies. [world] defaults to a brand-new account (no
/// matches); the full demo world adds seeded matches and conversations.
Widget testApp({
  DemoAuthRepository? auth,
  DemoWorld world = DemoWorld.fresh,
  List<Override> overrides = const [],
}) {
  final repo = auth ?? testAuth();
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(() => testNow),
      demoAuthProvider.overrideWithValue(repo),
      demoWorldProvider.overrideWith(() => FixedWorld(world)),
      ...overrides,
    ],
    child: const NumayaApp(),
  );
}

/// Phone-sized surface (393 x 852, as the web gallery).
Future<void> usePhoneSize(
  WidgetTester tester, {
  Size size = const Size(393, 852),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

bool _fontsLoaded = false;

/// Loads the bundled Hanken Grotesk (and the system colour-emoji font, when present) so
/// screenshots show real type and emoji.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  for (final (family, file) in [
    ('Hanken Grotesk', 'assets/fonts/HankenGrotesk-Variable.ttf'),
    ('Noto Color Emoji', '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf'),
    // Flutter's Material Icons (the app's icons, RD-04), from the SDK running the tests.
    (
      'MaterialIcons',
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter-sdk/flutter'}'
          '/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ),
  ]) {
    if (!File(file).existsSync()) continue;
    final bytes = File(file).readAsBytesSync();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

/// Lets timers (toasts, hand-over delays) finish so no timer is pending at the end of a test.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}
