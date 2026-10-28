import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/session_controller.dart';
import '../application/onboarding_controller.dart';
import 'step_scaffold.dart';

/// OB-05 (B-21, Numaya form): "You're verified" and the four setup sections. Continue opens the
/// first step not passed yet, so leaving setup and coming back resumes where the member stopped.
class SetupHubScreen extends ConsumerWidget {
  const SetupHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(onboardingProvider);
    final session = ref.watch(sessionProvider);
    final next = state.nextStep;
    final done = SetupSection.values.where(state.sectionDone).length;

    SetupStepStatus status(SetupSection section) => state.sectionDone(section)
        ? SetupStepStatus.done
        : section == next?.section
        ? SetupStepStatus.active
        : SetupStepStatus.upcoming;

    final steps = [
      for (final (section, label, detail, icon) in [
        (
          SetupSection.aboutYou,
          l10n.setupSectionAboutLabel,
          l10n.setupSectionAboutDetail,
          NumayaIcons.user,
        ),
        (
          SetupSection.lookingFor,
          l10n.setupSectionLookingLabel,
          l10n.setupSectionLookingDetail,
          NumayaIcons.heart,
        ),
        (
          SetupSection.profile,
          l10n.setupSectionProfileLabel,
          l10n.setupSectionProfileDetail,
          NumayaIcons.camera,
        ),
        (
          SetupSection.finish,
          l10n.setupSectionFinishLabel,
          l10n.setupSectionFinishDetail,
          NumayaIcons.verified,
        ),
      ])
        SetupStepData(
          label: label,
          detail: detail,
          icon: icon,
          status: status(section),
        ),
    ];

    return NumayaScreen(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            label: state.completed.isEmpty
                ? l10n.setupBuild
                : next != null
                ? l10n.setupContinue
                : l10n.setupGoHome,
            onPressed: () => next != null
                ? context.push(routeForStep(next))
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
            countLabel: l10n.setupCount(done, SetupSection.values.length),
            steps: steps,
            upNextLabel: l10n.setupUpNext,
            doneLabel: l10n.setupStepDone,
          ),
        ],
      ),
    );
  }
}
