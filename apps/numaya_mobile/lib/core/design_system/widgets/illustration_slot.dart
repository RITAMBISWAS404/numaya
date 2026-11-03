import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'primitives.dart';

/// A named place for a future illustration or the Numaya mascot (docs/design-experiments/
/// numaya-final-ux-polish/ILLUSTRATION_ASSET_BACKLOG.md lists every slot, its ratio and the
/// mascot's purpose there).
///
/// Until [asset] is set it draws a placeholder: a subtle neutral surface with a dashed edge, a small
/// image glyph and "Illustration: <label>". The box keeps [aspectRatio] (width ÷ height) at any
/// width, so the final SVG drops in without moving anything. Always decorative: the copy around it
/// carries the meaning, so it is excluded from semantics.
class IllustrationSlot extends StatelessWidget {
  const IllustrationSlot({
    super.key,
    required this.slot,
    required this.label,
    this.aspectRatio = empty,
    this.width,
    this.asset,
  });

  /// Page headers and explainers (Opening Moves, Safety, Account Health): wide and calm.
  static const double header = 16 / 9;

  /// Empty and recovery states inside an [EmptyState] card: room for a figure with a prop.
  static const double empty = 4 / 3;

  /// Stable code name for the slot, as listed in the asset backlog (`discover_meaningful`).
  final String slot;

  /// What the illustration should show ("Discover meaningful connections").
  final String label;

  /// Width ÷ height of the reserved area.
  final double aspectRatio;

  /// Fixed width; null fills the available width.
  final double? width;

  /// The final SVG asset path, when one exists.
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final Widget content = asset != null
        ? SvgPicture.asset(asset!, fit: BoxFit.contain)
        : CustomPaint(
            foregroundPainter: _DashedBorderPainter(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: AppRadii.all(AppRadii.card),
              ),
              padding: const EdgeInsets.all(AppSpacing.s4),
              alignment: Alignment.center,
              // At very large text the caption could outgrow the fixed-ratio box; the
              // decorative placeholder scales down instead of overflowing.
              child: LayoutBuilder(
                builder: (context, box) => FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: box.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const NumayaIcon(
                          NumayaIcons.image,
                          size: AppSizes.iconLg,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          'Illustration: $label',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: KeyedSubtree(
            key: ValueKey('illustration-slot-$slot'),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadii.card),
    ).deflate(0.75);
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
