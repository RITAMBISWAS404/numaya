import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../compliments/application/compliments_controller.dart';
import '../../dating/application/dating_controller.dart';
import '../../events_mvp/application/events_mvp_controller.dart';

/// The bottom bar's destinations, by identity rather than position. Events exists only when the
/// release includes it, so the branch order matches this list (see the shell routes in router.dart).
enum AppTab {
  discover,
  likes,
  chats,
  events,
  profile;

  static List<AppTab> active({required bool events}) => [
    discover,
    likes,
    chats,
    if (events) AppTab.events,
    profile,
  ];
}

/// Signed-in shell: Discover, Likes, Chats and Profile on the stone page, each tab keeping its own
/// stack, above the tab bar. (Events is deferred, [eventsAvailableProvider].)
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
    final tabs = AppTab.active(events: ref.watch(eventsAvailableProvider));
    final home = tabs.indexOf(AppTab.discover);
    // Android back on another tab's root returns to Home first; back on Home leaves the app.
    return PopScope(
      canPop: shell.currentIndex == home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(home);
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
            for (final tab in tabs)
              switch (tab) {
                AppTab.discover => TabItem(
                  label: l10n.tabDiscover,
                  icon: NumayaIcons.home,
                ),
                AppTab.likes => TabItem(
                  label: l10n.tabLikes,
                  icon: NumayaIcons.heart,
                  badgeCount: newLikes,
                  badgeLabel: l10n.tabNewCount(l10n.tabLikes, newLikes),
                ),
                AppTab.chats => TabItem(
                  label: l10n.tabChats,
                  icon: NumayaIcons.message,
                  badgeCount: newMatches,
                  badgeLabel: l10n.tabNewCount(l10n.tabChats, newMatches),
                ),
                AppTab.events => TabItem(
                  label: l10n.tabEvents,
                  icon: NumayaIcons.event,
                  badgeCount: ref.watch(
                    eventsMvpProvider.select(
                      (s) => s.notices.where((n) => !n.read).length,
                    ),
                  ),
                  badgeLabel: l10n.tabNewCount(l10n.tabEvents, 0),
                ),
                AppTab.profile => TabItem(
                  label: l10n.tabProfile,
                  icon: NumayaIcons.user,
                ),
              },
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
