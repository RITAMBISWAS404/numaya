import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';

/// Settings › Blocked people (V16 112 "Privacy and safety"): everyone blocked or reported, with
/// Unblock. Unblocking never restores a match or messages.
class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final controller = ref.read(datingProvider.notifier);
    final people = controller.blocked();
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.settingsBlocked,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s4),
        child: people.isEmpty
            ? EmptyState(
                art: const NumayaIcon(
                  NumayaIcons.shield,
                  size: 36,
                  color: AppColors.ink,
                ),
                title: l10n.blockedEmptyTitle,
                body: l10n.blockedEmptyBody,
              )
            : ListGroup(
                children: [
                  for (final p in people)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s4,
                        vertical: AppSpacing.s2,
                      ),
                      child: Row(
                        children: [
                          InitialsAvatar(initial: p.initial, size: 40),
                          const SizedBox(width: AppSpacing.s3),
                          Expanded(
                            child: Text(p.name, style: AppTypography.row),
                          ),
                          NumayaButton(
                            label: l10n.unblock,
                            small: true,
                            variant: NumayaButtonVariant.secondary,
                            onPressed: () {
                              controller.unblock(p.id);
                              NumayaToast.show(
                                context,
                                l10n.unblockedToast(p.name),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
