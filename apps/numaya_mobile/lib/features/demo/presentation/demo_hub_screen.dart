import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/session_controller.dart';
import '../../dating/application/dating_controller.dart';
import '../../home/presentation/filters_sheet.dart';
import '../../premium/application/premium_controller.dart';
import '../../verification/application/verification_controller.dart';

/// DEVELOPMENT ONLY. A catalogue of every screen, grouped by area, with the demo's data controls:
/// quick start, the sample world, reset, premium, simulated errors and the next verification
/// result. Reached from Settings › Prototype tools and from the Welcome screen in demo builds;
/// the router refuses it when demo sign-in isn't allowed (release builds).
class DemoHubScreen extends ConsumerWidget {
  const DemoHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);
    final signedIn = session != null && session.hasProfile;
    final world = ref.watch(demoWorldProvider);
    final premium = ref.watch(premiumProvider);
    final dating = ref.watch(datingProvider);
    final verification = ref.watch(photoVerificationProvider);
    final needsSession = l10n.demoNeedsSession;

    ListRow link(String label, String route, {bool session = true}) => ListRow(
      label: label,
      detail: session && !signedIn ? needsSession : null,
      onTap: session && !signedIn ? null : () => context.push(route),
    );

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.canPop()
            ? context.pop()
            : context.go(signedIn ? Routes.home : Routes.welcome),
        backLabel: l10n.back,
        title: l10n.demoHubTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          StatusBanner(title: l10n.demoHubBanner, body: l10n.demoHubBody),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.demoStart,
            footnote: signedIn ? l10n.demoSignedIn : l10n.demoQuickStartNote,
            children: [
              ListRow(
                leading: NumayaIcons.userAdd,
                label: l10n.demoQuickStart,
                onTap: () async {
                  await ref.read(sessionProvider.notifier).quickStart();
                  if (context.mounted) context.go(Routes.home);
                },
              ),
              if (session != null)
                ListRow(
                  label: l10n.settingsSignOut,
                  onTap: () async {
                    await ref.read(sessionProvider.notifier).signOut();
                    if (context.mounted) context.go(Routes.demo);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          OptionGroup(
            legend: l10n.demoWorld,
            children: [
              OptionCard(
                label: l10n.demoWorldFull,
                description: l10n.demoWorldFullBody,
                selected: world == DemoWorld.full,
                onTap: () =>
                    ref.read(demoWorldProvider.notifier).set(DemoWorld.full),
              ),
              OptionCard(
                label: l10n.demoWorldFresh,
                description: l10n.demoWorldFreshBody,
                selected: world == DemoWorld.fresh,
                onTap: () =>
                    ref.read(demoWorldProvider.notifier).set(DemoWorld.fresh),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          ListGroup(
            children: [
              ListRow(
                leading: NumayaIcons.refresh,
                label: l10n.demoReset,
                onTap: () {
                  ref.read(sessionProvider.notifier).resetDemoData();
                  NumayaToast.show(context, l10n.demoResetDone);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.demoSwitches,
            children: [
              ListRow(
                label: l10n.demoPremium,
                detail: l10n.demoPremiumNote,
                switchValue: premium.active,
                onSwitch: ref.read(premiumProvider.notifier).setActive,
              ),
              ListRow(
                label: l10n.settingsSimulate,
                switchValue: dating.simulateErrors,
                onSwitch: ref.read(datingProvider.notifier).setSimulateErrors,
              ),
              ListRow(
                label: l10n.demoApproveVerification,
                detail: verification.approveNext
                    ? l10n.demoApproveOn
                    : l10n.demoApproveOff,
                switchValue: verification.approveNext,
                onSwitch: ref
                    .read(photoVerificationProvider.notifier)
                    .setApproveNext,
              ),
              ListRow(
                label: l10n.demoResetVerification,
                onTap: ref.read(photoVerificationProvider.notifier).reset,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.demoAreaAccount,
            children: [
              link(l10n.demoWelcome, Routes.welcome, session: false),
              link(l10n.setupBasicsLabel, Routes.editBasics),
              link(l10n.setupInterestsLabel, Routes.editInterests),
              link(l10n.editPhotosTitle, Routes.editPhotos),
              link(
                l10n.blockedAccountTitle,
                Routes.accountBlocked,
                session: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(l10n.demoRestoreHow, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.demoAreaDiscover,
            children: [
              ListRow(
                label: l10n.tabDiscover,
                detail: signedIn ? null : needsSession,
                onTap: signedIn ? () => context.go(Routes.home) : null,
              ),
              link(l10n.forYouTitle, Routes.forYou),
              ListRow(
                label: l10n.filtersTitle,
                detail: signedIn ? null : needsSession,
                onTap: signedIn ? () => showFiltersSheet(context, ref) : null,
              ),
              link(l10n.demoSampleProfile, '${Routes.person}/ben?decide=1'),
              link(l10n.paywallTitle, Routes.paywall),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.demoAreaMatching,
            footnote: world == DemoWorld.full ? null : l10n.demoFullOnly,
            children: [
              ListRow(
                label: l10n.tabLikes,
                detail: signedIn ? null : needsSession,
                onTap: signedIn ? () => context.go(Routes.likes) : null,
              ),
              link(l10n.demoLikeProfile, '${Routes.like}/maya'),
              link(l10n.demoMatchScreen, '${Routes.match}/maya'),
              ListRow(
                label: l10n.tabChats,
                detail: signedIn ? null : needsSession,
                onTap: signedIn ? () => context.go(Routes.messages) : null,
              ),
              link(l10n.demoChatHistory, '${Routes.chat}/priya'),
              link(l10n.demoChatNew, '${Routes.chat}/jo'),
              link(l10n.demoChatExpiring, '${Routes.chat}/lina'),
              link(l10n.demoChatExpired, '${Routes.chat}/ollie'),
              link(l10n.openingMovesTitle, Routes.openingMoves),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.demoAreaProfile,
            children: [
              ListRow(
                label: l10n.tabProfile,
                detail: signedIn ? null : needsSession,
                onTap: signedIn ? () => context.go(Routes.profile) : null,
              ),
              link(l10n.completionTitle, Routes.completion),
              link(l10n.editTitle, Routes.editProfile),
              link(l10n.previewTitle, Routes.preview),
              link(l10n.photoVerifyTitle, Routes.verifyPhoto),
              link(l10n.premiumName, Routes.premium),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.demoAreaSettings,
            children: [
              link(l10n.settingsTitle, Routes.settings),
              link(l10n.settingsNotifications, Routes.notifications),
              link(l10n.privacyTitle, Routes.privacy),
              link(l10n.settingsBlocked, Routes.blocked),
              link(l10n.safetyTitle, Routes.safety),
              link(l10n.helpTitle, Routes.help, session: false),
              link(l10n.helpContact, Routes.helpContact, session: false),
              link(l10n.settingsDelete, Routes.deleteAccount),
              link(
                l10n.demoNotFound,
                '/this-page-does-not-exist',
                session: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }
}
