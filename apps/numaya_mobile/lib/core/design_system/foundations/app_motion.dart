import 'package:flutter/widgets.dart';

import '../tokens/numaya_tokens.g.dart';

/// Durations and curves. Use [AppMotion.duration] so "Remove animations" in system settings
/// (MediaQuery.disableAnimations) turns movement off. The moment each role serves is catalogued in
/// docs/mobile/MOTION_DESIGN_AUDIT.md.
abstract final class AppMotion {
  static const Duration fast = NumayaMotionTokens.motionDurationFast;
  static const Duration base = NumayaMotionTokens.motionDurationBase;
  static const Duration slow = NumayaMotionTokens.motionDurationSlow;
  static const Duration push = NumayaMotionTokens.motionDurationPush;

  static const Curve easeOut = NumayaCurveTokens.motionEaseOut;
  static const Curve emphasized = NumayaCurveTokens.motionEaseEmphasized;
  static const Curve easeInOut = NumayaCurveTokens.motionEaseInOut;

  // Roles: what a duration is for. Feature code picks a role, never a number.

  /// Press acknowledgement (scale on finger down).
  static const Duration press = fast;

  /// A control changing state: fills, borders, thumbs, a new item settling in.
  static const Duration state = base;

  /// Something leaving because of a decision (a profile flying out). Shorter than its entrance.
  static const Duration exit = Duration(milliseconds: 200);

  /// A sheet rising.
  static const Duration sheetIn = slow;

  /// A sheet leaving.
  static const Duration sheetOut = base;

  /// A rejected input's shake.
  static const Duration reject = Duration(milliseconds: 440);

  /// A progress bar or ring filling to its new value.
  static const Duration progress = Duration(milliseconds: 560);

  /// A rare success moment (a match, a verified photo). Never on a frequent action.
  static const Duration celebrate = Duration(milliseconds: 560);

  /// The gap between items entering one after another.
  static const Duration stagger = Duration(milliseconds: 60);

  /// One blink of a text caret.
  static const Duration caretBlink = Duration(milliseconds: 1050);

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [d], or zero when the person asked the system to remove animations.
  static Duration duration(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;

  /// Bottom sheets: rise on the drawer curve, leave quicker; none under reduced motion.
  static AnimationStyle sheet(BuildContext context) => reduced(context)
      ? AnimationStyle.noAnimation
      : AnimationStyle(
          duration: sheetIn,
          reverseDuration: sheetOut,
          curve: emphasized,
          // Played backwards, so flipped: it leaves fast and slows into the edge.
          reverseCurve: easeOut.flipped,
        );
}
