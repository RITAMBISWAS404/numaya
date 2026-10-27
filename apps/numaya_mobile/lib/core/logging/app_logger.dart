import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Minimal logger. Rules (docs/mobile/ARCHITECTURE.md#logging):
/// - Log events and error types, never personal data: no phone numbers, codes, names or answers.
/// - Every message also passes through [redact], which masks runs of 4+ digits as a safety net.
/// - Release builds keep warnings and errors only.
class AppLogger {
  const AppLogger(this.tag);

  final String tag;

  static LogLevel minimumLevel = kReleaseMode
      ? LogLevel.warning
      : LogLevel.debug;

  /// Test hook: receives every emitted line.
  @visibleForTesting
  static void Function(String line)? sink;

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warning(String message, [Object? error]) =>
      _log(LogLevel.warning, message, error);
  void error(String message, [Object? error, StackTrace? stack]) =>
      _log(LogLevel.error, message, error, stack);

  /// Masks digit runs (phone numbers, codes) that slipped into a message.
  static String redact(String input) =>
      input.replaceAll(RegExp(r'\d[\d\s\-().]{2,}\d'), '•••');

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stack,
  ]) {
    if (level.index < minimumLevel.index) return;
    // Only the error's type is logged: messages can carry user input.
    final suffix = error == null ? '' : ' (${error.runtimeType})';
    final line = '[${level.name}] $tag: ${redact(message)}$suffix';
    sink?.call(line);
    developer.log(
      line,
      name: 'numaya',
      level: 500 + level.index * 300,
      stackTrace: stack,
    );
  }
}
