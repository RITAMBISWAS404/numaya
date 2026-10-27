import 'package:flutter/widgets.dart';

import '../tokens/numaya_tokens.g.dart';

/// Durations and curves. Use [AppMotion.duration] so "Remove animations" in system settings
/// (MediaQuery.disableAnimations) turns movement off.
abstract final class AppMotion {
  static const Duration fast = NumayaMotionTokens.motionDurationFast;
  static const Duration base = NumayaMotionTokens.motionDurationBase;
  static const Duration slow = NumayaMotionTokens.motionDurationSlow;
  static const Duration push = NumayaMotionTokens.motionDurationPush;

  static const Curve easeOut = NumayaCurveTokens.motionEaseOut;
  static const Curve emphasized = NumayaCurveTokens.motionEaseEmphasized;
  static const Curve easeInOut = NumayaCurveTokens.motionEaseInOut;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [d], or zero when the person asked the system to remove animations.
  static Duration duration(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}
