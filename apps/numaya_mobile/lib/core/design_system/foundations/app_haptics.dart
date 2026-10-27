import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The moments that may vibrate. Call sites name a moment, never an intensity, so haptics can't
/// drift stronger one call at a time.
enum HapticMoment {
  /// A toggle, chip or option changed, or a swipe crossed its threshold.
  selection,

  /// A decision took effect (like, pass, a message sent).
  commit,

  /// Input was refused (a wrong code). Light: a mistake is acknowledged, not punished.
  reject,

  /// A rare success (a match, a verified photo, a purchase).
  success,
}

/// Whether haptics are on, from the in-app setting. One gate for every haptic in the app.
class HapticsScope extends InheritedWidget {
  const HapticsScope({super.key, required this.enabled, required super.child});

  final bool enabled;

  @override
  bool updateShouldNotify(HapticsScope old) => old.enabled != enabled;
}

/// Fires one haptic for a committed moment. Call it on the frame the state changed, never from an
/// animation listener, so one event is one pulse.
abstract final class AppHaptics {
  static bool enabled(BuildContext context) =>
      context.getInheritedWidgetOfExactType<HapticsScope>()?.enabled ?? true;

  static void fire(BuildContext context, HapticMoment moment) {
    if (!enabled(context)) return;
    unawaited(switch (moment) {
      HapticMoment.selection => HapticFeedback.selectionClick(),
      HapticMoment.commit => HapticFeedback.lightImpact(),
      HapticMoment.reject => HapticFeedback.lightImpact(),
      HapticMoment.success => HapticFeedback.mediumImpact(),
    });
  }
}
