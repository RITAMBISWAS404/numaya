import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/presentation/store_screens.dart' show shortDate;
import '../application/dating_controller.dart';
import 'conversation_row.dart';
import 'person_profile.dart';

/// R01: Archive. Started conversations with no message for 7 days. Either person can write as
/// usual; an accepted message moves the chat back to Chats for both. No request, fee or timer.
/// Initial matches that ran out before anyone wrote (R02) are listed separately below as
/// "Matches that ran out": never called archived, never revivable.
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final dating = ref.read(datingProvider.notifier);
    final archived = dating.archivedConversations();
    final expired = dating.expiredMatches();
    final now = ref.read(clockProvider)();
    void open(String id) {
      dating.openChat(id);
      context.push('${Routes.chat}/$id');
    }

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.archiveTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          if (archived.isEmpty && expired.isEmpty)
            EmptyState(
              art: const MobileIcon(
                NumayaMobileIcons.archive,
                size: 36,
                color: AppColors.ink,
              ),
              title: l10n.archiveEmptyTitle,
              body: l10n.archiveEmptyBody,
            )
          else ...[
            if (archived.isNotEmpty) ...[
              Text(
                l10n.archiveExplainer,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              for (final p in archived)
                ConversationRow(
                  key: ValueKey('archived-${p.id}'),
                  person: p,
                  last: dating.lastMessage(p.id)!,
                  unread: dating.unread(p.id),
                  yourMove: dating.yourMove(p.id),
                  now: now,
                  onTap: () => open(p.id),
                ),
            ],
            if (expired.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sectionGap),
              ListGroup(
                title: l10n.expiredMatchesTitle,
                footnote: l10n.expiredMatchesFootnote,
                children: [
                  for (final p in expired)
                    ListRow(
                      key: ValueKey('expired-${p.id}'),
                      avatar: Opacity(
                        opacity: 0.6,
                        child: InitialsAvatar(
                          initial: p.initial,
                          size: 40,
                          image: personAvatarImage(p),
                          imageAlignment: personAvatarFocus(p),
                        ),
                      ),
                      label: p.name,
                      detail: l10n.expiredOn(
                        shortDate(dating.status(p.id).expiredAt!),
                      ),
                      onTap: () => open(p.id),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
