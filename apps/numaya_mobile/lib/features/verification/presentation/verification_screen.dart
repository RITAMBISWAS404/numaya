import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../help/domain/help_articles.dart';
import '../application/verification_controller.dart';

enum _Step { intro, capture, review }

/// Photo verification (B-56 prompt, B-57 pose capture, B-58 help; Mobbin "Verifying a photo").
/// Simulated: the camera isn't used and no one reviews the selfie. The screen says so, and the
/// demo review resolves after a moment (outcome set in the Demo Hub; approve by default).
class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  _Step _step = _Step.intro;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(photoVerificationProvider);
    final controller = ref.read(photoVerificationProvider.notifier);
    final pose = kVerificationPoses[state.pose];
    final help = TextLink(
      label: l10n.verifyHelp,
      onPressed: () =>
          context.push('${Routes.help}/${HelpArticleId.verification.name}'),
    );

    Widget? footer;
    final List<Widget> body;
    switch (state.status) {
      case PhotoVerificationStatus.pending:
        body = [
          const SizedBox(height: AppSpacing.s8),
          const Center(
            child: SizedBox.square(
              dimension: 48,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          StatusBanner(
            tone: BannerTone.pending,
            title: l10n.verifyPendingTitle,
            body: l10n.verifyPendingBody,
          ),
        ];
      case PhotoVerificationStatus.verified:
        body = [
          const SizedBox(height: AppSpacing.s6),
          ResultPanel(
            illustration: NumayaIllustration.verified,
            title: l10n.verifyDoneTitle,
            body: l10n.verifyDoneBody,
          ),
        ];
        footer = NumayaButton(label: l10n.done, onPressed: () => context.pop());
      case PhotoVerificationStatus.rejected when _step == _Step.intro:
        final support =
            state.attempts >= PhotoVerificationController.maxAttempts;
        body = [
          const SizedBox(height: AppSpacing.s4),
          StatusBanner(
            tone: BannerTone.error,
            title: l10n.verifyRejectedTitle,
            body: support
                ? l10n.verifyRejectedSupport
                : l10n.verifyRejectedBody(
                    PhotoVerificationController.maxAttempts - state.attempts,
                  ),
          ),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            title: l10n.verifyTipsTitle,
            children: [
              ListRow(label: l10n.verifyTip1),
              ListRow(label: l10n.verifyTip2),
              ListRow(label: l10n.verifyTip3),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          Align(alignment: Alignment.centerLeft, child: help),
        ];
        footer = support
            ? NumayaButton(
                label: l10n.helpContact,
                onPressed: () => context.push(Routes.helpContact),
              )
            : NumayaButton(
                label: l10n.verifyTryAgain,
                onPressed: () {
                  controller.nextPose();
                  setState(() => _step = _Step.capture);
                },
              );
      case PhotoVerificationStatus.notStarted ||
          PhotoVerificationStatus.rejected:
        switch (_step) {
          case _Step.intro:
            body = [
              const SizedBox(height: AppSpacing.s6),
              ResultPanel(
                illustration: NumayaIllustration.verified,
                title: l10n.verifyIntroTitle,
                body: l10n.verifyIntroBody,
              ),
              const SizedBox(height: AppSpacing.s5),
              InfoCard(
                icon: NumayaIcons.camera,
                title: l10n.verifyDemoTitle,
                body: l10n.verifyDemoBody,
              ),
              const SizedBox(height: AppSpacing.s3),
              Center(child: help),
            ];
            footer = NumayaButton(
              label: l10n.verifyStart,
              onPressed: () => setState(() => _step = _Step.capture),
            );
          case _Step.capture:
            body = [
              const SizedBox(height: AppSpacing.s4),
              Text(l10n.verifyCopyPose, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.s2),
              Text(
                pose.instruction,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              _Viewfinder(
                pose: pose.emoji,
                label: l10n.verifyViewfinderLabel(pose.instruction),
                note: l10n.verifyCameraOff,
              ),
            ];
            footer = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NumayaButton(
                  label: l10n.verifyTakeSelfie,
                  icon: NumayaIcons.camera,
                  onPressed: () => setState(() => _step = _Step.review),
                ),
                const SizedBox(height: AppSpacing.s2),
                NumayaButton(
                  label: l10n.verifyOtherPose,
                  variant: NumayaButtonVariant.quiet,
                  onPressed: controller.nextPose,
                ),
              ],
            );
          case _Step.review:
            body = [
              const SizedBox(height: AppSpacing.s4),
              Text(l10n.verifyReviewTitle, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.s2),
              Text(
                l10n.verifyReviewBody,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Row(
                children: [
                  Expanded(
                    child: PhotoPlaceholder(
                      label: l10n.verifyDemoSelfie,
                      aspectRatio: 3 / 4,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.accentTint,
                        borderRadius: AppRadii.all(AppRadii.photo),
                      ),
                      alignment: Alignment.center,
                      child: Semantics(
                        label: pose.instruction,
                        child: Emoji(pose.emoji, size: 56),
                      ),
                    ),
                  ),
                ],
              ),
            ];
            footer = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NumayaButton(
                  label: l10n.photoVerifySubmit,
                  onPressed: () {
                    setState(() => _step = _Step.intro);
                    unawaited(controller.submit());
                  },
                ),
                const SizedBox(height: AppSpacing.s2),
                NumayaButton(
                  label: l10n.verifyRetake,
                  variant: NumayaButtonVariant.quiet,
                  onPressed: () => setState(() => _step = _Step.capture),
                ),
              ],
            );
        }
    }

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => _step == _Step.intro
            ? context.pop()
            : setState(() => _step = _Step.intro),
        backLabel: l10n.back,
        title: l10n.photoVerifyTitle,
      ),
      footer: footer,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: body,
      ),
    );
  }
}

/// The pose capture area (B-57): an ink frame with the pose to copy. No camera preview: the camera
/// isn't connected in this build, and the frame says so.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.pose,
    required this.label,
    required this.note,
  });

  final String pose;
  final String label;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: AppRadii.all(AppRadii.photo),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s6),
                  child: Text(
                    note,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.inkForeground,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: AppSpacing.s4,
                bottom: AppSpacing.s4,
                child: Container(
                  width: 72,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: AppRadii.all(AppRadii.control),
                  ),
                  alignment: Alignment.center,
                  child: Emoji(pose, size: 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
