import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';

/// Signed-in shell: four tabs (Home, Likes, Messages, Profile) on the stone page, each keeping its
/// own stack, above V16's white tab bar.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: shell,
      bottomNavigationBar: NumayaTabBar(
        currentIndex: shell.currentIndex,
        onSelect: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          TabItem(label: l10n.tabDiscover, icon: NumayaIcons.home),
          TabItem(label: l10n.tabLikes, icon: NumayaIcons.heart),
          TabItem(label: l10n.tabChats, icon: NumayaIcons.message),
          TabItem(label: l10n.tabProfile, icon: NumayaIcons.user),
        ],
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
