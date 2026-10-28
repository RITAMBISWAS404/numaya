import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

/// A tab root on the stone page: its header, an optional subtitle, then the content column.
class TabPage extends StatelessWidget {
  const TabPage({
    super.key,
    required this.header,
    required this.child,
    this.subtitle,
    this.centered = false,
    this.scrollController,
    this.topGap = true,
    this.gutter = AppSpacing.gutter,
    this.overlay,
  });

  /// Floats over the bottom of the scrolling area (Discover's action bar while reading a
  /// profile).
  final Widget? overlay;

  final Widget header;
  final String? subtitle;
  final Widget child;

  /// Centre the content vertically (empty states on Home).
  final bool centered;
  final ScrollController? scrollController;

  /// A 16pt gap under the header when there is no subtitle.
  final bool topGap;

  /// Side margin: 16pt, or 8pt on Discover.
  final double gutter;

  /// The height of the scrolling area below the header, for content that fills it (Discover's
  /// photo card, V16 `100cqh`).
  static double viewportOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TabViewport>()!.height;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => _TabViewport(
                      height: box.maxHeight,
                      child: _withOverlay(
                        SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.fromLTRB(
                            gutter,
                            0,
                            gutter,
                            AppSpacing.s6,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: centered
                                  ? box.maxHeight - AppSpacing.s6
                                  : 0,
                            ),
                            child: Column(
                              mainAxisAlignment: centered
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (subtitle != null) ...[
                                  Text(
                                    subtitle!,
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s4),
                                ] else if (!centered && topGap)
                                  const SizedBox(height: AppSpacing.s4),
                                child,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _withOverlay(Widget scroll) => overlay == null
      ? scroll
      : Stack(
          children: [
            Positioned.fill(child: scroll),
            Positioned(left: 0, right: 0, bottom: 0, child: overlay!),
          ],
        );
}

class _TabViewport extends InheritedWidget {
  const _TabViewport({required this.height, required super.child});

  final double height;

  @override
  bool updateShouldNotify(_TabViewport old) => old.height != height;
}
