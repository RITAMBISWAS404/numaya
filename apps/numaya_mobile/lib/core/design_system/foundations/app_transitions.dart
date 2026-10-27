import 'package:flutter/material.dart';

import 'app_layout.dart';
import 'app_motion.dart';

/// Page push (V16 `--motion-duration-push` on the drawer curve): the new page slides in from the
/// trailing edge while the one underneath drifts 30% the other way. Nothing moves under reduced
/// motion.
class NumayaPageTransitionsBuilder extends PageTransitionsBuilder {
  const NumayaPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.push;

  @override
  Duration get reverseTransitionDuration => AppMotion.slow;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduced(context)) return child;
    final textDirection = Directionality.of(context);
    final incoming = CurvedAnimation(
      parent: animation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.emphasized.flipped,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.emphasized.flipped,
    );
    return SlideTransition(
      position: Tween(
        begin: Offset.zero,
        end: const Offset(-0.3, 0),
      ).animate(outgoing),
      textDirection: textDirection,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(incoming),
        textDirection: textDirection,
        // The edge of the incoming page reads against the one underneath.
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: AppElevation.sm),
          child: child,
        ),
      ),
    );
  }
}

/// A modal moment (a match, the paywall, verification): rises a little and fades in over the page
/// it interrupts, and leaves the same way. Instant under reduced motion.
Widget modalTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  if (AppMotion.reduced(context)) return child;
  final curved = CurvedAnimation(
    parent: animation,
    curve: AppMotion.emphasized,
    reverseCurve: AppMotion.easeOut.flipped,
  );
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}
