import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/auth_copy.dart';
import '../application/onboarding_controller.dart';

/// Where each onboarding step lives.
String routeForStep(SetupStep step) => switch (step) {
  SetupStep.name => Routes.setupName,
  SetupStep.gender => Routes.setupGender,
  SetupStep.meet => Routes.setupMeet,
  SetupStep.intentions => Routes.setupIntentions,
  SetupStep.height => Routes.setupHeight,
  SetupStep.location => Routes.setupLocation,
  SetupStep.photos => Routes.photos,
  SetupStep.interests => Routes.interests,
  SetupStep.prompts => Routes.setupPrompts,
  SetupStep.bio => Routes.setupBio,
  SetupStep.verify => Routes.setupVerify,
  SetupStep.notifications => Routes.setupNotifications,
  SetupStep.review => Routes.setupReview,
};

/// Opened from the review screen's Edit links: Continue goes back to the review.
const String kReturnToReview = 'review';

bool _returnsToReview(BuildContext context) =>
    GoRouterState.of(context).uri.queryParameters['return'] == kReturnToReview;

/// Marks [step] passed and moves on: to the next step, or back to the review when the step was
/// opened from it.
void continueFrom(BuildContext context, WidgetRef ref, SetupStep step) {
  ref.read(onboardingProvider.notifier).completeStep(step);
  if (_returnsToReview(context)) {
    context.pop();
    return;
  }
  final next = SetupStep.values.elementAtOrNull(step.index + 1);
  unawaited(context.push(next == null ? Routes.setupDone : routeForStep(next)));
}

/// Back from a step: one step back, or the hub when the step was opened directly (a deep link or
/// the Demo Hub).
void backFromStep(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(Routes.setup);

/// One onboarding step: the progress header (this step's section), a flow heading, the content,
/// and the round next button with a caption saying what's missing. Optional steps add Skip.
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.step,
    required this.title,
    this.lede,
    this.art,
    required this.caption,
    required this.canContinue,
    required this.onContinue,
    this.onSkip,
    this.busy = false,
    required this.children,
  });

  final SetupStep step;
  final String title;
  final String? lede;
  final Widget? art;
  final String caption;
  final bool canContinue;
  final VoidCallback onContinue;

  /// Shown as "Skip" in the header for optional steps.
  final VoidCallback? onSkip;
  final bool busy;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: busy ? null : () => backFromStep(context),
        backLabel: l10n.back,
        step: SignUpProgress.forSection(step.section),
        steps: SignUpProgress.total,
        actions: [
          if (onSkip != null)
            TextLink(label: l10n.obSkip, onPressed: busy ? null : onSkip),
        ],
      ),
      footer: StepFooter(
        caption: caption,
        action: NumayaFab(
          semanticLabel: l10n.next,
          loading: busy,
          onPressed: canContinue && !busy ? onContinue : null,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: title, lede: lede, art: art),
          const SizedBox(height: AppSpacing.s6),
          ...children,
        ],
      ),
    );
  }
}
