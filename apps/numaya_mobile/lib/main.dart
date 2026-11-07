import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/design_system/design_system.dart' show AppSystemUi;
import 'core/logging/app_logger.dart';
import 'core/media/demo_photos.dart';

void main() {
  const log = AppLogger('App');
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    unawaited(
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
    // Draw behind transparent system bars on every Android version, as Android 15+ requires;
    // screens keep their content clear of them through MediaQuery padding and SafeArea.
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    SystemChrome.setSystemUIOverlayStyle(AppSystemUi.style);
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      log.error('Flutter error', details.exception, details.stack);
    };
    // The local demo photo set (git-ignored; empty means grey placeholders, as before).
    await DemoPhotoLibrary.load();
    runApp(const ProviderScope(child: NumayaApp()));
  }, (error, stack) => log.error('Uncaught error', error, stack));
}
