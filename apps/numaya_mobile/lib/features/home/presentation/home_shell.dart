import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../compliments/application/compliments_controller.dart';
import '../../dating/application/dating_controller.dart';

/// Signed-in shell: Discover, Likes, Messages and Profile (and Events second when the release
/// includes it, [eventsAvailableProvider]; EVENTS_SCREEN_INVENTORY EN-1) on the stone page, each tab
/// keeping its own stack, above the tab bar.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final dating = ref.read(datingProvider.notifier);
    // R03: the Heart tab counts unanswered likes and pending Compliments together.
    ref.watch(complimentsProvider);
    final newLikes =
        dating.unansweredLikes() +
        ref.read(complimentsProvider.notifier).requests().length;
    final newMatches = dating.unopenedMatches();
    // Android back on another tab's root returns to Home first; back on Home leaves the app.
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        // Tab content scrolls beneath the frosted bar; the bodies add its height to their bottom
        // padding (MediaQuery.paddingOf), so nothing ends hidden behind it.
        extendBody: true,
        body: shell,
        bottomNavigationBar: NumayaTabBar(
          currentIndex: shell.currentIndex,
          onSelect: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          items: [
            TabItem(label: l10n.tabDiscover, icon: NumayaIcons.home),
            if (ref.watch(eventsAvailableProvider))
              TabItem(label: l10n.tabEvents, icon: NumayaIcons.event),
            TabItem(
              label: l10n.tabLikes,
              icon: NumayaIcons.heart,
              badgeCount: newLikes,
              badgeLabel: l10n.tabNewCount(l10n.tabLikes, newLikes),
            ),
            TabItem(
              label: l10n.tabChats,
              icon: NumayaIcons.message,
              badgeCount: newMatches,
              badgeLabel: l10n.tabNewCount(l10n.tabChats, newMatches),
            ),
            TabItem(label: l10n.tabProfile, icon: NumayaIcons.user),
          ],
        ),
      ),
    );
  }
}

/// Tab-root header (`.theme-withings .topbar--large`): a 32pt extrabold page title on the page,
/// with round white header buttons.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    // The tab title is the page-title role (24/32) at every text size (UI-012); the bar grows
    // with its content.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.tabHeader),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenGutter),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: AppTypography.pageTitle),
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.s2),
              HeaderActions(actions: actions),
            ],
          ],
        ),
      ),
    );
  }
}
