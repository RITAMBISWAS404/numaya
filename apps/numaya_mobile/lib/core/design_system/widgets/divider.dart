import 'package:flutter/widgets.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';

/// The one separator (V9, docs/v9/design-decisions.md D-06): a 1px, low-contrast line that runs
/// almost the full width of its content, with the same small margin at each end, so it reads as a
/// deliberate division rather than a stub. [margin] is that end margin: [inCard] inside a card,
/// [onPage] for rows laid straight on the page, 0 where the parent already insets its content.
/// [spacing] adds room above and below for section breaks.
class NumayaDivider extends StatelessWidget {
  const NumayaDivider({super.key, this.margin = inCard, this.spacing = 0});

  /// Inside a card: the card's own padding.
  static const double inCard = AppLayout.cardPadding;

  /// On the page: the screen gutter.
  static const double onPage = AppLayout.screenGutter;

  final double margin;
  final double spacing;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: margin, vertical: spacing),
      child: const SizedBox(
        height: AppBorders.hairline,
        width: double.infinity,
        child: ColoredBox(color: AppColors.divider),
      ),
    ),
  );
}
