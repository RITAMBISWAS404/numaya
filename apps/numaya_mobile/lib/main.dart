import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/logging/app_logger.dart';

void main() {
  const log = AppLogger('App');
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      log.error('Flutter error', details.exception, details.stack);
    };
    runApp(const ProviderScope(child: NumayaApp()));
  }, (error, stack) => log.error('Uncaught error', error, stack));
}
