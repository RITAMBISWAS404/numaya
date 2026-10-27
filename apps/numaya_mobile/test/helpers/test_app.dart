import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/app.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/features/auth/data/demo_auth_repository.dart';

final testNow = DateTime(2026, 10, 27, 12);

/// A demo auth service with no latency and a seeded random source.
DemoAuthRepository testAuth() => DemoAuthRepository(
  random: Random(3),
  clock: () => testNow,
  latency: Duration.zero,
);

/// The real app with deterministic dependencies.
Widget testApp({DemoAuthRepository? auth}) {
  final repo = auth ?? testAuth();
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(() => testNow),
      demoAuthProvider.overrideWithValue(repo),
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

/// Loads the bundled Fraunces and Inter so screenshots show real type.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  for (final (family, file) in [
    ('Fraunces', 'assets/fonts/Fraunces-Variable.ttf'),
    ('Inter', 'assets/fonts/Inter-Variable.ttf'),
  ]) {
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
