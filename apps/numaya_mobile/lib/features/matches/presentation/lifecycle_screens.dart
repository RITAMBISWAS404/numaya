import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/application/economy_controller.dart';
import '../../commerce/presentation/store_screens.dart';
import '../../dating/application/dating_controller.dart';
import '../../dating/domain/sample_people.dart';
import '../../dating/presentation/person_profile.dart';
import '../../premium/application/premium_controller.dart';
import '../domain/match_lifecycle.dart';

/// The state line for an expired chat in lists.
String expiredStateLabel(
  AppLocalizations l10n,
  DatingController dating,
  DatingState state,
  String id,
) {
  final s = dating.status(id);
  final r = state.reconnects[id];
  if (s.phase == MatchPhase.reconnectPending) {
    return r?.fromMe == true
        ? l10n.expiredStatePending
        : l10n.expiredStateIncoming;
  }
  if (r != null &&
      r.episode == s.expiredAt &&
      r.status == ReconnectStatus.declined) {
    return l10n.expiredStateDeclined;
  }
  return l10n.expiredStateCanAsk;
}

/// S24: expired matches and chats, newest first, with their reconnect state. Each opens its
/// read-only history (S22), where reconnecting is offered.
class ExpiredChatsScreen extends ConsumerWidget {
  const ExpiredChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(datingProvider);
    final dating = ref.read(datingProvider.notifier);
    final people = dating.expiredMatches();
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.expiredTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s4),
        child: people.isEmpty
            ? EmptyState(
                art: const MobileIcon(
                  NumayaMobileIcons.hourglass,
                  size: 36,
                  color: AppColors.ink,
                ),
                title: l10n.expiredEmptyTitle,
                body: l10n.expiredEmptyBody,
              )
            : ListGroup(
                footnote: l10n.chatsExpiredDetail,
                children: [
                  for (final p in people)
                    ListRow(
                      key: ValueKey('expired-${p.id}'),
                      avatar: InitialsAvatar(
                        initial: p.initial,
                        size: 40,
                        image: personAvatarImage(p),
                        imageAlignment: personAvatarFocus(p),
                      ),
                      label: p.name,
                      detail:
                          '${l10n.expiredOn(shortDate(dating.status(p.id).expiredAt!))} · ${expiredStateLabel(l10n, dating, state, p.id)}',
                      onTap: () => context.push(
                        dating.incomingReconnect(p.id) != null
                            ? '${Routes.reconnect}/${p.id}'
                            : '${Routes.chat}/${p.id}',
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// S25: the other person asked to reconnect. Accept reopens the chat (no automatic message, no
/// charge); decline ends this episode.
class ReconnectRequestScreen extends ConsumerWidget {
  const ReconnectRequestScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(datingProvider);
    final dating = ref.read(datingProvider.notifier);
    final person = personById(personId);
    final request = person == null ? null : dating.incomingReconnect(personId);
    final top = NumayaTopBar(onBack: () => context.pop(), backLabel: l10n.back);
    if (person == null || request == null) {
      return NumayaScreen(
        top: top,
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s10),
          child: EmptyState(title: l10n.requestGone, body: ''),
        ),
      );
    }
    final last = [...?state.threads[personId]].reversed
        .take(3)
        .toList()
        .reversed;
    Future<void> decline() async {
      final ok = await showNumayaSheet<bool>(
        context: context,
        title: l10n.reconnectDeclineTitle,
        closeLabel: l10n.close,
        builder: (sheet) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.reconnectDeclineBody(person.name),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s5),
            NumayaButton(
              label: l10n.reconnectDecline,
              onPressed: () => Navigator.of(sheet).pop(true),
            ),
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              label: l10n.cancel,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => Navigator.of(sheet).pop(false),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      dating.respondReconnect(personId, accept: false);
      context.pop();
      NumayaToast.show(context, l10n.reconnectDeclined);
    }

    return NumayaScreen(
      top: top,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            key: const ValueKey('reconnect-accept'),
            label: l10n.reconnectAccept,
            onPressed: () {
              dating.respondReconnect(personId, accept: true);
              AppHaptics.fire(context, HapticMoment.success);
              context.pushReplacement('${Routes.chat}/$personId');
              NumayaToast.show(context, l10n.reconnectAccepted(person.name));
            },
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.reconnectDecline,
            variant: NumayaButtonVariant.secondary,
            onPressed: decline,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Center(
            child: InitialsAvatar(
              initial: person.initial,
              size: 88,
              image: personAvatarImage(person),
              imageAlignment: personAvatarFocus(person),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          ScreenHeader(
            title: l10n.reconnectTitle(person.name),
            lede: l10n.reconnectBody,
          ),
          if (last.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            ListGroup(
              title: l10n.reconnectPrevious,
              children: [
                for (final m in last)
                  ListRow(
                    label: m.text,
                    detail: m.mine ? l10n.chatYou : person.name,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// S23: seven quiet days. Optional reason, shortcuts to pause or preferences, or skip. Shown once
/// per quiet period; the answer never affects ranking.
Future<void> showCheckInSheet(
  BuildContext context,
  WidgetRef ref,
  SamplePerson person, {
  required VoidCallback onWrite,
}) async {
  final l10n = context.l10n;
  ref.read(datingProvider.notifier).markCheckInSeen(person.id);
  String? reason;
  final choice = await showNumayaSheet<int>(
    context: context,
    title: l10n.checkInTitle(person.name),
    closeLabel: l10n.close,
    builder: (sheet) => StatefulBuilder(
      builder: (sheet, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.checkInBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(l10n.checkInReasonLabel, style: AppTypography.fieldLabel),
          const SizedBox(height: AppSpacing.s2),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              for (final r in [
                l10n.checkInReasonInterested,
                l10n.checkInReasonBusy,
                l10n.checkInReasonNotFeeling,
                l10n.checkInReasonSkip,
              ])
                NumayaChip(
                  label: r,
                  selected: reason == r,
                  onTap: () => setState(() => reason = reason == r ? null : r),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            label: l10n.checkInWrite,
            onPressed: () => Navigator.of(sheet).pop(0),
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              Expanded(
                child: NumayaButton(
                  label: l10n.checkInPause,
                  small: true,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () => Navigator.of(sheet).pop(1),
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: NumayaButton(
                  label: l10n.checkInPreferences,
                  small: true,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () => Navigator.of(sheet).pop(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Center(
            child: TextLink(
              label: l10n.checkInSkip,
              muted: true,
              onPressed: () => Navigator.of(sheet).pop(3),
            ),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted) return;
  switch (choice) {
    case 0:
      onWrite();
    case 1:
      await context.push(Routes.privacy);
    case 2:
      await context.push(Routes.settings);
    default:
      break;
  }
}

/// S17: today's likes are used. Shows the reset time and what is still free; offers Premium only
/// to free members, and never implies payment creates new people.
class AllowanceUsedScreen extends ConsumerWidget {
  const AllowanceUsedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(economyProvider);
    final premium = ref.watch(premiumProvider).active;
    final economy = ref.read(economyProvider.notifier);
    final now = ref.read(clockProvider)();
    final left = economy.likesReset().difference(now);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.close,
        closeIcon: true,
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            label: l10n.allowanceToChats,
            onPressed: () {
              context.pop();
              context.go(Routes.messages);
            },
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.allowanceBack,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s6),
          const Center(
            child: MobileIcon(
              NumayaMobileIcons.hourglass,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          ScreenHeader(title: l10n.allowanceTitle, lede: l10n.allowanceBody),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            children: [
              ListRow(
                key: const ValueKey('allowance-reset'),
                leading: NumayaIcons.clock,
                label: l10n.allowanceResetsIn(compactDuration(left)),
                detail: shortDateTime(economy.likesReset()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          if (premium)
            Text(l10n.allowancePremiumHas, style: AppTypography.helper)
          else
            StatusBanner(
              tone: BannerTone.info,
              title: l10n.allowancePremiumTitle,
              body: l10n.allowancePremiumBody,
              action: NumayaButton(
                label: l10n.premiumSeePlans,
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => context.push(
                  '${Routes.paywall}?feature=${PremiumFeature.likes.name}',
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s3),
          Text(l10n.allowanceNoMoreProfiles, style: AppTypography.helper),
        ],
      ),
    );
  }
}
