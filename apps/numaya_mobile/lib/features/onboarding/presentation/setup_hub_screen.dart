import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/session_controller.dart';
import '../application/onboarding_controller.dart';

/// B-21 (Numaya form): "You're verified" and the three setup steps. Each step's next button marks
/// it done; the first step not done is "Up next".
class SetupHubScreen extends ConsumerWidget {
  const SetupHubScreen({super.key});

  static String routeFor(SetupStep step) => switch (step) {
    SetupStep.basics => Routes.basics,
    SetupStep.interests => Routes.interests,
    SetupStep.photos => Routes.photos,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(onboardingProvider);
    final session = ref.watch(sessionProvider);
    final next = state.nextStep;
    final done = state.completed.length;

    SetupStepStatus status(SetupStep step) => state.completed.contains(step)
        ? SetupStepStatus.done
        : step == next
        ? SetupStepStatus.active
        : SetupStepStatus.upcoming;

    final steps = [
      SetupStepData(
        label: l10n.setupBasicsLabel,
        detail: l10n.setupBasicsDetail,
        icon: NumayaIcons.user,
        status: status(SetupStep.basics),
      ),
      SetupStepData(
        label: l10n.setupInterestsLabel,
        detail: l10n.setupInterestsDetail,
        icon: NumayaIcons.interests,
        status: status(SetupStep.interests),
      ),
      SetupStepData(
        label: l10n.setupPhotosLabel,
        detail: l10n.setupPhotosDetail,
        icon: NumayaIcons.camera,
        status: status(SetupStep.photos),
      ),
    ];

    return NumayaScreen(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            label: done == 0
                ? l10n.setupBuild
                : next != null
                ? l10n.setupContinue
                : l10n.setupGoHome,
            onPressed: () => next != null
                ? context.push(routeFor(next))
                : context.go(Routes.home),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            next != null ? l10n.setupCaptionTime : l10n.setupCaptionReady,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          const Center(child: Wordmark()),
          ResultPanel(
            illustration: NumayaIllustration.verified,
            illustrationWidth: 128,
            compact: true,
            title: l10n.setupVerifiedTitle,
            body: l10n.setupVerifiedBody(session?.phone.display ?? ''),
          ),
          const SizedBox(height: AppSpacing.s6),
          SetupProgress(
            title: l10n.setupProfileTitle,
            countLabel: l10n.setupCount(done, SetupStep.values.length),
            steps: steps,
            upNextLabel: l10n.setupUpNext,
            doneLabel: l10n.setupStepDone,
          ),
        ],
      ),
    );
  }
}
