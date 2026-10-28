import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';

/// Signed-in shell: five tabs (Home, Events, Likes, Messages, Profile; EVENTS_SCREEN_INVENTORY
/// EN-1) on the stone page, each keeping its
/// own stack, above V16's white tab bar.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final dating = ref.read(datingProvider.notifier);
    final newLikes = dating.unansweredLikes();
    final newMatches = dating.unopenedMatches();
    // Android back on another tab's root returns to Home first; back on Home leaves the app.
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: shell,
        bottomNavigationBar: NumayaTabBar(
          currentIndex: shell.currentIndex,
          onSelect: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          items: [
            TabItem(label: l10n.tabDiscover, icon: NumayaIcons.home),
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

/// Tab-root header (`.theme-withings .topbar--large`): a 30pt bold page title on the stone page,
/// with round white header buttons.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: AppTypography.pageTitle),
              ),
            ),
            for (final a in actions) ...[
              const SizedBox(width: AppSpacing.s2),
              a,
            ],
          ],
        ),
      ),
    );
  }
}
