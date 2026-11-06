import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../experiments/experiments.dart';

/// EXP-003 empty conversations: the alternatives to the refined candidate's illustrated card on
/// Messages when there are no matches or chats yet. Same copy and the same main way forward
/// (Discover); only what surrounds it changes. No variant invents a feature: Likes and Events
/// are existing tabs.
class EmptyConversations extends StatelessWidget {
  const EmptyConversations({
    super.key,
    required this.variant,
    required this.likes,
    required this.onDiscover,
    required this.onLikes,
    required this.onEvents,
  });

  final ExpVariant variant;

  /// Unanswered likes; the Likes route is offered only when there are some.
  final int likes;
  final VoidCallback onDiscover;
  final VoidCallback onLikes;
  final VoidCallback onEvents;

  @override
  Widget build(BuildContext context) => switch (variant) {
    ExpVariant.a => _catCard(context),
    ExpVariant.b => _nextSteps(context),
    _ => _openPage(context),
  };

  /// A — Cat says hello (Ente's Ducky empty states): the same centred card, with the waving cat
  /// and its speech bubble in place of the generic chat drawing, and a second, quieter way in.
  /// Axis: **character**.
  Widget _catCard(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      key: const ValueKey('empty-chats-cat'),
      art: const MascotArt(
        MascotPurpose.emptyConversations,
        maxWidth: 180,
        maxHeightFraction: 0.2,
      ),
      title: l10n.chatsEmptyTitle,
      body: l10n.chatsEmptyBody,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NumayaButton(label: l10n.findYourPeople, onPressed: onDiscover),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.chatsEmptyEvents,
            variant: NumayaButtonVariant.secondary,
            onPressed: onEvents,
          ),
        ],
      ),
    );
  }

  /// B — Next steps list (Ente's settings list rows; Bumble's "Your matches" prompt above the
  /// empty chat list): no illustration; a short explanation, then the real ways to start a
  /// conversation as one list card. Axis: **actionable choices over mood**.
  Widget _nextSteps(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('empty-chats-steps'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.s4),
        Text(l10n.chatsEmptyTitle, style: AppTypography.emptyTitle),
        const SizedBox(height: AppSpacing.s2),
        Text(
          l10n.chatsEmptyBody,
          style: AppTypography.body.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppLayout.sectionGap),
        ListGroup(
          title: l10n.chatsEmptyNextTitle,
          children: [
            ListRow(
              leading: NumayaIcons.explore,
              label: l10n.chatsEmptyDiscover,
              detail: l10n.chatsEmptyDiscoverDetail,
              onTap: onDiscover,
            ),
            if (likes > 0)
              ListRow(
                leading: NumayaIcons.heart,
                label: l10n.chatsEmptyLikes,
                detail: l10n.chatsEmptyLikesDetail,
                value: '$likes',
                onTap: onLikes,
              ),
            ListRow(
              leading: NumayaIcons.calendar,
              label: l10n.chatsEmptyEvents,
              detail: l10n.chatsEmptyEventsDetail,
              onTap: onEvents,
            ),
          ],
        ),
      ],
    );
  }

  /// C — Open page, one action (Bumble's empty Chats, Mobbin f0fd7cdd): no card. The waving cat
  /// sits left-aligned on the page, then a large title, the body and one pill-width primary.
  /// Axis: **page-level, editorial composition**.
  Widget _openPage(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('empty-chats-page'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s8),
        const MascotArt(
          MascotPurpose.emptyConversations,
          maxWidth: 200,
          maxHeightFraction: 0.22,
        ),
        const SizedBox(height: AppSpacing.s6),
        Semantics(
          header: true,
          child: Text(l10n.chatsEmptyTitle, style: AppTypography.hero),
        ),
        const SizedBox(height: AppSpacing.s3),
        Text(
          l10n.chatsEmptyBody,
          style: AppTypography.body.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.s6),
        NumayaButton(
          label: l10n.findYourPeople,
          expand: false,
          onPressed: onDiscover,
        ),
      ],
    );
  }
}
