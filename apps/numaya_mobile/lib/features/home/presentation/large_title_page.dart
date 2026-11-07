import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

/// R12 (Visual Lab V2): Ente Header v2 (`11439:5040`) on a scrolling page. The expanded large
/// title sits under the leading control (or at the top of a tab root) and scrolls away with the
/// content; as it leaves, the same title fades into the 56pt bar and a hairline appears. Both are
/// driven by the scroll offset, not by a timed animation, so the title never re-animates and the
/// offset is kept like any scroll view. Under reduced motion the bar title switches at the
/// threshold instead of cross-fading. Used where hierarchy benefits (Profile, Insights, Likes),
/// not on chat or composer pages.
///
/// When [tabRoot], content scrolls clear of the floating tab bar (as in `TabPage`); pushed pages
/// pad for the system inset only.
class LargeTitlePage extends StatefulWidget {
  const LargeTitlePage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.onBack,
    this.backLabel = 'Back',
    this.tabRoot = true,
    this.scrollController,
    this.pinned,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final String backLabel;
  final bool tabRoot;
  final ScrollController? scrollController;

  /// Shown under the large title and kept under the bar once the title collapses (the Likes /
  /// Compliments switch).
  final Widget? pinned;

  @override
  State<LargeTitlePage> createState() => _LargeTitlePageState();
}

class _LargeTitlePageState extends State<LargeTitlePage> {
  ScrollController? _own;
  ScrollController get _scroll =>
      widget.scrollController ?? (_own ??= ScrollController());
  final _collapse = ValueNotifier<double>(0);

  /// The distance over which the large title (36pt line + gap) hands over to the bar.
  static const double _titleBand = 44;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(LargeTitlePage old) {
    super.didUpdateWidget(old);
    if (old.scrollController != widget.scrollController) {
      (old.scrollController ?? _own)?.removeListener(_onScroll);
      _scroll.addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onScroll();
      });
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final t = ((_scroll.offset - 4) / (_titleBand - 4)).clamp(0.0, 1.0);
    if (t != _collapse.value) _collapse.value = t;
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _own?.dispose();
    _collapse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final under = widget.tabRoot ? MediaQuery.paddingOf(context).bottom : 0.0;
    final bottom = widget.tabRoot ? 0.0 : MediaQuery.paddingOf(context).bottom;
    final bar = ValueListenableBuilder<double>(
      valueListenable: _collapse,
      builder: (context, t, _) {
        final shown = reduced ? (t >= 0.5 ? 1.0 : 0.0) : t;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withValues(alpha: shown),
                width: AppBorders.hairline,
              ),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.topBar),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.barPadding,
                vertical: AppSpacing.s1,
              ),
              child: Row(
                children: [
                  if (widget.onBack != null)
                    NavIconButton(
                      icon: NumayaIcons.chevronLeft,
                      label: widget.backLabel,
                      style: NavButtonStyle.plain,
                      onPressed: widget.onBack,
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.onBack == null ? 0 : AppSpacing.s2,
                      ),
                      // The bar title is decorative: the large title is the page header.
                      child: ExcludeSemantics(
                        child: Opacity(
                          opacity: shown,
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.appBarTitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.actions.isNotEmpty)
                    HeaderActions(actions: widget.actions),
                ],
              ),
            ),
          ),
        );
      },
    );
    final large = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              widget.title,
              key: const ValueKey('large-title'),
              style: AppTypography.largeTitle,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: AppSpacing.s1),
            Text(
              widget.subtitle!,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
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
                bar,
                Expanded(
                  child: CustomScrollView(
                    controller: _scroll,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppLayout.screenGutter,
                        ),
                        sliver: SliverToBoxAdapter(child: large),
                      ),
                      if (widget.pinned != null)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedDelegate(
                            child: widget.pinned!,
                            extent:
                                MediaQuery.textScalerOf(context).scale(20) +
                                28 +
                                AppSpacing.s2 * 2,
                          ),
                        ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          AppLayout.screenGutter,
                          widget.pinned == null ? 0 : AppSpacing.s3,
                          AppLayout.screenGutter,
                          AppSpacing.s6 + under + bottom,
                        ),
                        sliver: SliverToBoxAdapter(child: widget.child),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps a control (the segmented switch) under the bar once the large title has gone. Its height
/// follows the control at the current text size.
class _PinnedDelegate extends SliverPersistentHeaderDelegate {
  _PinnedDelegate({required this.child, required this.extent});
  final Widget child;
  final double extent;

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      ColoredBox(
        color: AppColors.canvas,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenGutter,
            vertical: AppSpacing.s2,
          ),
          child: Center(child: child),
        ),
      );

  @override
  bool shouldRebuild(_PinnedDelegate old) =>
      old.child != child || old.extent != extent;
}
