import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'buttons.dart';
import 'primitives.dart';

enum ScreenTone {
  /// The V16 stone page (`.theme-withings .fl-screen`).
  page,

  /// V16 maps the old wash onto the page colour too (`.theme-withings .screen--wash`).
  wash,
}

/// One full screen (`.screen`): an optional top bar, a scrolling body with the 16pt gutter on the
/// stone page, and an optional footer pinned above the keyboard. Wider screens centre a 430pt
/// column. The top bar sits on the same stone as the page (RD-03); a hairline appears under it
/// only once content has scrolled beneath it.
class NumayaScreen extends StatefulWidget {
  const NumayaScreen({
    super.key,
    required this.body,
    this.top,
    this.footer,
    this.tone = ScreenTone.page,
    this.scrollable = true,
    this.bodyPadding,
    this.scrollController,
  });

  final Widget? top;
  final Widget body;
  final Widget? footer;
  final ScreenTone tone;
  final bool scrollable;
  final EdgeInsetsGeometry? bodyPadding;
  final ScrollController? scrollController;

  @override
  State<NumayaScreen> createState() => _NumayaScreenState();
}

class _NumayaScreenState extends State<NumayaScreen> {
  /// Content has scrolled under the top bar: show its hairline.
  bool _scrolled = false;

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final scrolled = n.metrics.pixels > 0.5;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bodyPadding = widget.bodyPadding;
    final scrollable = widget.scrollable;
    final scrollController = widget.scrollController;
    final body = widget.body;
    final top = widget.top;
    final footer = widget.footer;
    final padding =
        bodyPadding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s2,
          AppSpacing.gutter,
          AppSpacing.s6,
        );
    // On a short screen with very large text a pinned footer can take most of the height and
    // leave the content no room. There the footer scrolls with the content, after it.
    final mq = MediaQuery.of(context);
    final inlineFooter =
        footer != null &&
        scrollable &&
        mq.size.height < 700 &&
        mq.textScaler.scale(10) > 16;
    final content = scrollable
        ? SingleChildScrollView(
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: padding,
            child: inlineFooter
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      body,
                      const SizedBox(height: AppSpacing.s5),
                      footer,
                    ],
                  )
                : body,
          )
        : Padding(padding: padding, child: body);

    Widget column(Widget child) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMax),
        child: child,
      ),
    );

    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          if (top != null)
            AnimatedContainer(
              duration: AppMotion.duration(context, AppMotion.state),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border(
                  bottom: BorderSide(
                    color: _scrolled ? AppColors.border : AppColors.canvas,
                    width: AppBorders.hairline,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: topInset),
                child: column(top),
              ),
            ),
          Expanded(
            child: SafeArea(
              top: top == null,
              child: column(
                Column(
                  children: [
                    // Tapping outside a field dismisses the keyboard. Not a control, so screen
                    // readers don't see a screen-sized button.
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _onScroll,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          excludeFromSemantics: true,
                          onTap: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          child: content,
                        ),
                      ),
                    ),
                    if (footer != null && !inlineFooter)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.gutter,
                          AppSpacing.s3,
                          AppSpacing.gutter,
                          AppSpacing.s4,
                        ),
                        child: footer,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer row of a step: a caption on the left and the round next button on the right.
class StepFooter extends StatelessWidget {
  const StepFooter({super.key, required this.caption, required this.action});

  final String caption;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(caption, style: AppTypography.caption),
          ),
        ),
        const SizedBox(width: AppSpacing.s4),
        action,
      ],
    );
  }
}

/// Inner-page header, Ente Header (v2) in its Collapsed state (11441:5208): a bare back arrow,
/// the title left-aligned beside it in Large (16/20 semibold), and up to three 38pt Icon Buttons on
/// the right, 6-8pt apart. Flow steps put the progress segments in the title's place.
class NumayaTopBar extends StatelessWidget {
  const NumayaTopBar({
    super.key,
    this.onBack,
    this.backLabel = 'Back',
    this.step,
    this.steps,
    this.title,
    this.actions = const [],
    this.closeIcon = false,
  });

  final VoidCallback? onBack;
  final String backLabel;

  /// 1-based current step; with [steps] draws the progress segments.
  final int? step;
  final int? steps;
  final String? title;
  final List<Widget> actions;
  final bool closeIcon;

  @override
  Widget build(BuildContext context) {
    // TC-04: the bar is 56pt and grows when a title wraps at large text, so a title is never cut
    // to "Safety and w…" (it takes two lines before it truncates; the full title is the header's
    // semantic label either way).
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.topBar),
      child: Padding(
        // Back and action buttons are rounded squares that sit on the gutter (Alan, Meetup).
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.barPadding,
          vertical: AppSpacing.s1,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (step != null && steps != null)
              StepProgress(step: step!, steps: steps!),
            Row(
              children: [
                if (onBack != null)
                  NavIconButton(
                    icon: closeIcon
                        ? NumayaIcons.close
                        : NumayaIcons.chevronLeft,
                    label: backLabel,
                    style: NavButtonStyle.plain,
                    onPressed: onBack,
                  )
                else
                  const SizedBox(width: AppSizes.iconButtonSlot),
                if (title != null && (step == null || steps == null))
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s2,
                      ),
                      child: Semantics(
                        header: true,
                        label: title,
                        child: ExcludeSemantics(
                          child: Text(
                            title!,
                            style: AppTypography.appBarTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                // UC-02: one shared action group, so every header spaces its actions alike.
                if (actions.isNotEmpty) HeaderActions(actions: actions),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Trailing header actions (UC-02): the one place header buttons are spaced. Adjacent 38pt
/// tiles show [AppLayout.headerActionGap] (8pt) between them; their 44pt hit boxes sit
/// [AppLayout.headerActionLayoutGap] apart, so each keeps its own target. Order is as given.
/// Used by [NumayaTopBar], the tab-root `TabHeader` and the Discover header.
class HeaderActions extends StatelessWidget {
  const HeaderActions({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppLayout.headerActionLayoutGap),
          actions[i],
        ],
      ],
    );
  }
}

/// Progress segments (`.progress`): ink on the fill (V16); done segments filled, the current one
/// fills in on arrival.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.step, required this.steps});

  final int step;
  final int steps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $step of $steps',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= steps; i++) ...[
              if (i > 1) const SizedBox(width: 4),
              _Segment(state: i < step ? 1 : (i == step ? 0.5 : 0)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.state});

  /// 1 done, 0.5 current (animates in), 0 upcoming.
  final double state;

  @override
  Widget build(BuildContext context) {
    final track = ClipRRect(
      borderRadius: AppRadii.all(AppRadii.pill),
      child: Container(
        width: AppSizes.progressSegmentWidth,
        height: AppSizes.progressSegmentHeight,
        color: AppColors.fill,
        alignment: Alignment.centerLeft,
        child: state == 0
            ? null
            : state == 1
            ? Container(color: AppColors.accent)
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.duration(context, AppMotion.progress),
                curve: AppMotion.easeOut,
                builder: (context, v, _) => FractionallySizedBox(
                  widthFactor: v,
                  heightFactor: 1,
                  child: Container(color: AppColors.accent),
                ),
              ),
      ),
    );
    return track;
  }
}

/// Flow heading (`.screen-header`): a 26pt medium statement, optional lede and a spot illustration.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.lede,
    this.ledeWidget,
    this.art,
    this.eyebrow,
  });

  final String title;
  final String? lede;
  final Widget? ledeWidget;
  final Widget? art;
  final String? eyebrow;

  /// The square region a heading illustration fills above the heading (UI-009).
  static const double artSize = 96;

  @override
  Widget build(BuildContext context) {
    final heading = Semantics(
      header: true,
      child: BalancedText(title, style: AppTypography.flowTitle),
    );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (eyebrow != null) ...[
            Text(eyebrow!.toUpperCase(), style: AppTypography.labelCaps),
            const SizedBox(height: AppSpacing.s3),
          ],
          // UI-009: a decorative illustration gets its own square region above the heading,
          // upper left, instead of squeezing beside it.
          if (art != null) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ExcludeSemantics(
                child: SizedBox.square(
                  dimension: ScreenHeader.artSize,
                  child: FittedBox(child: art),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          heading,
          if (lede != null || ledeWidget != null) ...[
            const SizedBox(height: AppSpacing.s3),
            ledeWidget ??
                Text(
                  lede!,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

/// Titled content section (`.section`): a 22pt medium heading, muted description.
class NumayaSection extends StatelessWidget {
  const NumayaSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: AppTypography.section),
                  ),
                  if (description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        description!,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        child,
      ],
    );
  }
}

/// Vertical stack with a fixed gap.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}
