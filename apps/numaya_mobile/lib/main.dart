import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/design_system/design_system.dart' show AppSystemUi;
import 'core/logging/app_logger.dart';
import 'core/media/demo_photos.dart';
import 'features/demo/application/type_settings_controller.dart';
import 'features/lab/lab_registry.dart'
    show LabChoicesStore, labChoicesProvider;

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
    final container = ProviderContainer();
    runApp(
      UncontrolledProviderScope(container: container, child: const NumayaApp()),
    );
    // Review builds: the saved typography comparison (UI-085, 14/15 body) and Design Lab choices.
    // Read after the first frame and never awaited before it: the app-support folder lookup must
    // not hold up startup (a launch-screen hang found on the emulator, 2026-11-14).
    unawaited(_restoreReviewSettings(container, log));
  }, (error, stack) => log.error('Uncaught error', error, stack));
}

Future<void> _restoreReviewSettings(
  ProviderContainer container,
  AppLogger log,
) async {
  try {
    final type = await const TypeSettingsStore().read().timeout(
      const Duration(seconds: 5),
    );
    container.read(typeSettingsProvider.notifier).restore(type);
    final lab = await LabChoicesStore.load().timeout(
      const Duration(seconds: 5),
    );
    container.read(labChoicesProvider.notifier).restore(lab);
    log.info('Review settings restored: $type, ${lab.length} lab choices');
  } on Object catch (e) {
    log.warning('Review settings not restored: $e');
  }
}
