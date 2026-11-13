import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/dating_controller.dart';
import 'conversation_row.dart';

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
          // UI-081 (V8): Archive lists archived conversations only: no expired-match section,
          // heading, rows or explanatory copy, even when nothing is archived.
          if (archived.isEmpty)
            EmptyState(
              art: const MobileIcon(
                NumayaMobileIcons.archive,
                size: 36,
                color: AppColors.ink,
              ),
              title: l10n.archiveEmptyTitle,
              body: l10n.archiveEmptyBody,
            )
          else
            for (final (i, p) in archived.indexed) ...[
              // UI-003: the inbox divider, from the text column to the row's end.
              if (i > 0)
                const CardDivider(inset: ConversationRow.textInset, end: 0),
              ConversationRow(
                key: ValueKey('archived-${p.id}'),
                person: p,
                last: dating.lastMessage(p.id)!,
                unread: dating.unread(p.id),
                yourMove: dating.yourMove(p.id),
                now: now,
                variant: 'V8',
                onTap: () => open(p.id),
              ),
            ],
        ],
      ),
    );
  }
}
