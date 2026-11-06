import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'content.dart';

/// Where the Numaya cat appears and why (overnight v3, phase 5). Each purpose maps to one pose,
/// so swapping a drawing later changes one line here, not the screens. The manifest
/// (`docs/design-experiments/ente-design-system/overnight-v3/mascot.csv`) lists each slot's
/// asset, size and replacement notes.
///
/// Never used in settings, safety, reporting, account holds, consent or error states (the
/// Ente Ducky catalog likewise leaves states such as Hidden without a duck).
enum MascotPurpose {
  /// Waiting on someone else (no likes yet; the Likes tile).
  waiting(NumayaIllustration.mascotWaiting),

  /// A new match: supporting the two people, never covering a face.
  matchCelebration(NumayaIllustration.mascotCelebrate),

  /// No conversations yet: a friendly nudge toward the one next action.
  emptyConversations(NumayaIllustration.mascotHello),

  /// Profile completion: small encouragement beside the progress.
  completionEncouragement(NumayaIllustration.mascotCheer);

  const MascotPurpose(this.illustration);

  final NumayaIllustration illustration;
}

/// The cat for [purpose], at most [maxWidth] wide and at most [maxHeightFraction] of the screen
/// height, so it never pushes a screen's main action off a small phone. Decorative by default
/// (the copy beside it carries the meaning); pass [semanticLabel] only when the art says
/// something the text does not. Static: nothing animates, so reduced motion needs no case.
class MascotArt extends StatelessWidget {
  const MascotArt(
    this.purpose, {
    super.key,
    this.maxWidth = 160,
    this.maxHeightFraction = 0.2,
    this.semanticLabel,
  });

  final MascotPurpose purpose;
  final double maxWidth;
  final double maxHeightFraction;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final illustration = purpose.illustration;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return LayoutBuilder(
      builder: (context, box) {
        final width = math.min(
          math.min(maxWidth, box.maxWidth),
          screenHeight * maxHeightFraction * illustration.aspectRatio,
        );
        final art = KeyedSubtree(
          key: ValueKey('mascot-${purpose.name}'),
          child: IllustrationView(illustration, width: width),
        );
        return semanticLabel == null
            ? art
            : Semantics(image: true, label: semanticLabel, child: art);
      },
    );
  }
}
