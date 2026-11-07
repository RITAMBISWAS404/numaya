import 'package:flutter/widgets.dart';

import '../tokens/numaya_tokens.g.dart';

/// Durations and curves. Use [AppMotion.duration] so "Remove animations" in system settings
/// (MediaQuery.disableAnimations) turns movement off. The moment each role serves is catalogued in
/// docs/mobile/MOTION_DESIGN_AUDIT.md.
/// Motion presets compared in the Visual Lab (M0 reduced/static, M1 restrained, M2 quicker).
enum MotionPreset { m0, m1, m2 }

abstract final class AppMotion {
  static const Duration fast = NumayaMotionTokens.motionDurationFast;
  static const Duration base = NumayaMotionTokens.motionDurationBase;
  static const Duration slow = NumayaMotionTokens.motionDurationSlow;
  static const Duration push = NumayaMotionTokens.motionDurationPush;

  static const Curve easeOut = NumayaCurveTokens.motionEaseOut;
  static const Curve emphasized = NumayaCurveTokens.motionEaseEmphasized;
  static const Curve easeInOut = NumayaCurveTokens.motionEaseInOut;

  // Roles: what a duration is for. Feature code picks a role, never a number.
  //
  // Visual Lab V2 (brief 08) MotionTokens: one preset decides the role durations app-wide.
  // M1 (proposed default): feedback 120ms, state 200ms, route and sheet 280ms. M2 (alternative):
  // 100 / 160 / 240. M0: no movement (as the system "remove animations"). These are Numaya
  // tuning values, not Apple or Material requirements. Set from the app root ([preset]); the
  // Design Lab switches it in debug builds only.

  /// The active preset. Release builds always use [MotionPreset.m1].
  static MotionPreset preset = MotionPreset.m1;

  /// Press acknowledgement (scale on finger down).
  static Duration get press => preset == MotionPreset.m2
      ? const Duration(milliseconds: 100)
      : const Duration(milliseconds: 120);

  /// A control changing state: fills, borders, thumbs, segment indicators, a new item settling in.
  static Duration get state => preset == MotionPreset.m2
      ? const Duration(milliseconds: 160)
      : const Duration(milliseconds: 200);

  /// Route pushes and sheets rising.
  static Duration get route => preset == MotionPreset.m2
      ? const Duration(milliseconds: 240)
      : const Duration(milliseconds: 280);

  /// Something leaving because of a decision (a profile flying out). Shorter than its entrance.
  static const Duration exit = Duration(milliseconds: 200);

  /// A sheet rising.
  static Duration get sheetIn => route;

  /// A sheet leaving (quicker than it arrived).
  static Duration get sheetOut => state;

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

  /// Reduced motion: the platform's flag (Android "Remove animations"; iOS "Reduce Motion", which
  /// Flutter reports through the same `disableAnimations`), the in-app setting (the app root sets
  /// the same flag), or the M0 preset.
  static bool reduced(BuildContext context) =>
      preset == MotionPreset.m0 ||
      (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  /// [d] mapped onto the preset's roles (raw tokens [fast], [base], [slow], [push] become
  /// feedback, state and route), or zero under reduced motion.
  static Duration duration(BuildContext context, Duration d) {
    if (reduced(context)) return Duration.zero;
    if (d == fast) return press;
    if (d == base) return state;
    if (d == slow || d == push) return route;
    return d;
  }

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
