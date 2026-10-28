import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/auth_copy.dart';
import '../../dating/application/dating_controller.dart';
import '../../dating/presentation/person_profile.dart';
import '../../home/application/discovery_filters.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../profile/presentation/own_profile.dart';
import '../../settings/application/account_prefs.dart';
import '../../verification/application/verification_controller.dart';
import '../application/device_permissions.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'permission_prompt.dart';
import 'step_scaffold.dart';

String _verificationLabel(AppLocalizations l10n, PhotoVerificationStatus s) =>
    switch (s) {
      PhotoVerificationStatus.notStarted => l10n.obReviewNotVerified,
      PhotoVerificationStatus.pending => l10n.obVerifyPending,
      PhotoVerificationStatus.verified => l10n.obVerifyDone,
      PhotoVerificationStatus.rejected => l10n.obVerifyFailed,
    };

/// OB-20: offers photo verification (B-55 [O]; Hinge Face Check consent [O]); skippable (OD-12).
/// "Verify now" opens the existing simulated flow, which says it is simulated; the result is only
/// ever labelled as simulated.
class VerifyOfferScreen extends ConsumerWidget {
  const VerifyOfferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(photoVerificationProvider.select((s) => s.status));
    final started = status != PhotoVerificationStatus.notStarted;
    return OnboardingStepScaffold(
      step: SetupStep.verify,
      title: l10n.obVerifyTitle,
      lede: l10n.obVerifyLede,
      art: const IllustrationView(NumayaIllustration.verified, width: 72),
      caption: started ? _verificationLabel(l10n, status) : l10n.obVerifyLater,
      canContinue: true,
      onContinue: () => continueFrom(context, ref, SetupStep.verify),
      onSkip: () => continueFrom(context, ref, SetupStep.verify),
      children: [
        InfoCard(icon: NumayaIcons.shield, title: l10n.obVerifyPrivacy),
        const SizedBox(height: AppSpacing.s3),
        InfoCard(icon: NumayaIcons.info, title: l10n.obVerifyDemo),
        const SizedBox(height: AppSpacing.s6),
        if (started) ...[
          StatusBanner(
            tone: switch (status) {
              PhotoVerificationStatus.verified => BannerTone.success,
              PhotoVerificationStatus.rejected => BannerTone.error,
              _ => BannerTone.pending,
            },
            title: l10n.obVerifyStatus(_verificationLabel(l10n, status)),
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
        if (status == PhotoVerificationStatus.notStarted ||
            status == PhotoVerificationStatus.rejected)
          NumayaButton(
            label: l10n.obVerifyNow,
            onPressed: () => context.push(Routes.verifyPhoto),
          ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.obVerifyLater,
          variant: NumayaButtonVariant.quiet,
          onPressed: () => continueFrom(context, ref, SetupStep.verify),
        ),
      ],
    );
  }
}

/// OB-21: notifications primer, then the (simulated) prompt (Bumble "Don't miss a beat… Not now"
/// [O]). Optional; the answer sets the push switches in Settings (OD-13).
class NotificationsPrimerScreen extends ConsumerWidget {
  const NotificationsPrimerScreen({super.key});

  Future<void> _allow(BuildContext context, WidgetRef ref) async {
    final status = await requestPermission(
      context,
      ref,
      DevicePermission.notifications,
    );
    final prefs = ref.read(accountPrefsProvider.notifier);
    for (final c in NotificationCategory.values) {
      prefs.setChannel(c, NotificationChannel.push, status.isGranted);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(
      devicePermissionsProvider.select(
        (p) => p.of(DevicePermission.notifications),
      ),
    );
    final message = switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.grantedPrecise => l10n.obNotifAllowed,
      PermissionStatus.denied => l10n.obNotifDenied,
      PermissionStatus.permanentlyDenied => l10n.obNotifBlocked,
      PermissionStatus.notAsked => null,
    };
    return OnboardingStepScaffold(
      step: SetupStep.notifications,
      title: l10n.obNotifTitle,
      lede: l10n.obNotifLede,
      art: const IllustrationView(NumayaIllustration.noChats, width: 72),
      caption: message ?? l10n.obNotifLater,
      canContinue: true,
      onContinue: () => continueFrom(context, ref, SetupStep.notifications),
      onSkip: () => continueFrom(context, ref, SetupStep.notifications),
      children: [
        if (message != null) ...[
          StatusBanner(
            tone: status.isGranted ? BannerTone.success : BannerTone.info,
            title: message,
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
        if (status.canAsk)
          NumayaButton(
            label: l10n.obNotifAllow,
            onPressed: () => _allow(context, ref),
          ),
        if (status == PermissionStatus.permanentlyDenied)
          NumayaButton(
            label: l10n.obOpenSettings,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => NumayaToast.show(context, l10n.obOpenSettingsDemo),
          ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.obNotifLater,
          variant: NumayaButtonVariant.quiet,
          onPressed: () => continueFrom(context, ref, SetupStep.notifications),
        ),
        const SizedBox(height: AppSpacing.s5),
        InfoCard(icon: NumayaIcons.info, title: l10n.obNotifDemo),
      ],
    );
  }
}

/// Where Edit on the review screen goes for each missing item.
SetupStep _stepFor(MissingItem item) => switch (item) {
  MissingItem.name || MissingItem.birthday => SetupStep.name,
  MissingItem.gender => SetupStep.gender,
  MissingItem.openTo => SetupStep.meet,
  MissingItem.intentions => SetupStep.intentions,
  MissingItem.photos => SetupStep.photos,
  MissingItem.interests => SetupStep.interests,
  MissingItem.prompt => SetupStep.prompts,
};

/// OB-22: the profile as others will see it, what's missing, the private choices, and Create my
/// profile (Hinge's "how what you share will appear" [O]). Creating is guarded: once at a time,
/// only when nothing required is missing; a simulated connection problem shows a retry.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _failed = false;

  void _edit(SetupStep step) =>
      unawaited(context.push('${routeForStep(step)}?return=$kReturnToReview'));

  Future<void> _create() async {
    setState(() => _failed = false);
    try {
      final created = await ref
          .read(onboardingProvider.notifier)
          .create(simulateFailure: ref.read(datingProvider).simulateErrors);
      if (!mounted || !created) return;
      AppHaptics.fire(context, HapticMoment.success);
      context.go(Routes.setupDone);
    } on ProfileCreationFailed {
      if (!mounted) return;
      AppHaptics.fire(context, HapticMoment.reject);
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final state = ref.watch(onboardingProvider);
    final details = ref.watch(profileDetailsProvider);
    final filters = ref.watch(discoveryFiltersProvider);
    final verification = ref.watch(
      photoVerificationProvider.select((s) => s.status),
    );
    final notifications = ref.watch(
      devicePermissionsProvider.select(
        (p) => p.of(DevicePermission.notifications),
      ),
    );
    final draft = state.draft;
    final missing = draft.missing(controller.today);
    final me = memberAsPerson(
      draft: draft,
      details: details,
      today: controller.today,
      verified: false,
    );
    String missingLabel(MissingItem m) => switch (m) {
      MissingItem.name => l10n.obMissingName,
      MissingItem.birthday => l10n.obMissingBirthday,
      MissingItem.gender => l10n.obMissingGender,
      MissingItem.openTo => l10n.obMissingOpenTo,
      MissingItem.intentions => l10n.obMissingIntentions,
      MissingItem.photos => l10n.obMissingPhotos(ProfileRules.minPhotos),
      MissingItem.interests => l10n.obMissingInterests(
        ProfileRules.minInterests,
        ProfileRules.maxInterests,
      ),
      MissingItem.prompt => l10n.obMissingPrompt,
    };
    final openTo = draft.openTo;
    final meet = openTo == null
        ? l10n.obReviewNotSet
        : openTo.isEmpty
        ? l10n.obEveryone
        : [
            for (final g in Gender.values)
              if (openTo.contains(g))
                switch (g) {
                  Gender.woman => l10n.filtersWomen,
                  Gender.man => l10n.filtersMen,
                  Gender.nonbinary => l10n.filtersNonbinary,
                },
          ].join(', ');

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: state.creating ? null : () => backFromStep(context),
        backLabel: l10n.back,
        step: SignUpProgress.forSection(SetupSection.finish),
        steps: SignUpProgress.total,
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            label: l10n.obReviewCreate,
            loading: state.creating,
            onPressed: missing.isEmpty && !state.creating ? _create : null,
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            l10n.obReviewSaved,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: l10n.obReviewTitle, lede: l10n.obReviewLede),
          const SizedBox(height: AppSpacing.s6),
          if (_failed) ...[
            StatusBanner(tone: BannerTone.error, title: l10n.obReviewFailed),
            const SizedBox(height: AppSpacing.s4),
          ],
          if (missing.isNotEmpty) ...[
            ListGroup(
              title: l10n.obReviewMissingTitle,
              children: [
                for (final m in missing)
                  ListRow(
                    leading: NumayaIcons.alert,
                    label: missingLabel(m),
                    onTap: () => _edit(_stepFor(m)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
          Semantics(
            header: true,
            child: Text(l10n.obReviewPublicTitle, style: AppTypography.section),
          ),
          const SizedBox(height: AppSpacing.s3),
          PersonHeroCard(person: me, own: true, showAge: details.showAge),
          const SizedBox(height: AppSpacing.s3),
          ...personSections(context, me, own: true, showDistance: false),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            children: [
              for (final (step, label) in [
                (SetupStep.photos, l10n.setupPhotosLabel),
                (SetupStep.interests, l10n.setupInterestsLabel),
                (SetupStep.prompts, l10n.obPromptsTitle),
                (SetupStep.bio, l10n.obBioLabel),
                (SetupStep.gender, l10n.obGenderTitle),
                (SetupStep.height, l10n.obHeightTitle),
              ])
                ListRow(
                  label: l10n.obReviewEditItem(label),
                  onTap: () => _edit(step),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.obReviewPrivateTitle,
            children: [
              ListRow(
                label: l10n.obReviewMeet,
                value: meet,
                onTap: () => _edit(SetupStep.meet),
              ),
              ListRow(
                label: l10n.obAgesLabel,
                value: l10n.obReviewAges(filters.minAge, filters.maxAge),
                onTap: () => _edit(SetupStep.meet),
              ),
              ListRow(
                label: l10n.obReviewArea,
                value: details.area ?? l10n.obReviewNotSet,
                onTap: () => _edit(SetupStep.location),
              ),
              ListRow(
                label: l10n.obReviewVerification,
                value: _verificationLabel(l10n, verification),
                onTap: () => _edit(SetupStep.verify),
              ),
              ListRow(
                label: l10n.obReviewNotifications,
                value: notifications.isGranted
                    ? l10n.obReviewOn
                    : l10n.obReviewOff,
                onTap: () => _edit(SetupStep.notifications),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// OB-23: the profile is created. Start discovering goes to Home; back goes there too, never into
/// setup again.
class AllSetScreen extends ConsumerWidget {
  const AllSetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = ref.watch(
      onboardingProvider.select((s) => s.draft.firstName.trim()),
    );
    void start() => context.go(Routes.home);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) start();
      },
      child: NumayaScreen(
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NumayaButton(label: l10n.obDoneStart, onPressed: start),
            const SizedBox(height: AppSpacing.s3),
            Text(
              l10n.obDoneSample,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s8),
            ResultPanel(
              illustration: NumayaIllustration.verified,
              title: l10n.obDoneTitle(name),
              body: l10n.obDoneBody,
            ),
          ],
        ),
      ),
    );
  }
}
