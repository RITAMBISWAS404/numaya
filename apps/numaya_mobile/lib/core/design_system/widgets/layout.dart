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
/// column. A [NumayaTopBar] is a white bar that also fills the status-bar area.
class NumayaScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final padding =
        bodyPadding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s2,
          AppSpacing.gutter,
          AppSpacing.s6,
        );
    final content = scrollable
        ? SingleChildScrollView(
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: padding,
            child: body,
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
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                    width: AppBorders.hairline,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: topInset),
                child: column(top!),
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
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        excludeFromSemantics: true,
                        onTap: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        child: content,
                      ),
                    ),
                    if (footer != null)
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

/// Modal and flow header (`.theme-withings .topbar`): a bare ink back icon, centred progress
/// segments or a title in tracked small capitals ("EDIT PROFILE"), optional actions. [NumayaScreen]
/// draws it on a white bar with a hairline under it.
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
    return SizedBox(
      height: AppSizes.topBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (step != null && steps != null)
              StepProgress(step: step!, steps: steps!)
            else if (title != null)
              Semantics(
                header: true,
                label: title,
                child: ExcludeSemantics(
                  child: Text(
                    title!.toUpperCase(),
                    style: AppTypography.headerCaps,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
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
                  const SizedBox(width: AppSizes.iconButton),
                const Spacer(),
                ...actions,
              ],
            ),
          ],
        ),
      ),
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
            ? Container(color: AppColors.ink)
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.reduced(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 560),
                curve: AppMotion.easeOut,
                builder: (context, v, _) => FractionallySizedBox(
                  widthFactor: v,
                  heightFactor: 1,
                  child: Container(color: AppColors.ink),
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
          if (art == null)
            heading
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: heading),
                const SizedBox(width: AppSpacing.s4),
                ExcludeSemantics(child: art!),
              ],
            ),
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
