import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/home_shell.dart';
import '../../home/presentation/tab_screens.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';
import 'safety_sheets.dart';
import 'time_format.dart';

enum _ConvFilter { all, unread, yourMove }

/// Messages (B-42 / B-43, V16 034 / 037 / 052): search, the match queue (countdown rings, the
/// likes tile, expired matches), an Opening Moves prompt and conversations with view tabs.
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _search = TextEditingController();
  String _query = '';
  _ConvFilter _filter = _ConvFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(SamplePerson p) {
    ref.read(datingProvider.notifier).openChat(p.id);
    context.push('${Routes.chat}/${p.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(datingProvider);
    ref.watch(premiumProvider);
    final controller = ref.read(datingProvider.notifier);
    final queued = controller.queuedMatches();
    final expired = controller.expiredMatches();
    final convs = controller.conversations();
    final likes = controller.unansweredLikes();
    final hasMoves = ref.watch(
      profileDetailsProvider.select((d) => d.openingMoves.isNotEmpty),
    );
    final header = TabHeader(title: l10n.tabChats);

    final movesCard = hasMoves
        ? null
        : _OpeningMovesCard(onTap: () => context.push(Routes.openingMoves));

    if (queued.isEmpty && expired.isEmpty && convs.isEmpty) {
      return TabPage(
        header: header,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EmptyState(
              art: const IllustrationView(
                NumayaIllustration.noChats,
                width: 160,
              ),
              title: l10n.chatsEmptyTitle,
              body: l10n.chatsEmptyBody,
              action: NumayaButton(
                label: l10n.findYourPeople,
                small: true,
                onPressed: () => context.go(Routes.home),
              ),
            ),
            if (movesCard != null) ...[
              const SizedBox(height: AppSpacing.s3),
              movesCard,
            ],
          ],
        ),
      );
    }

    final q = _query.trim().toLowerCase();
    bool matches(SamplePerson p) =>
        q.isEmpty ||
        p.name.toLowerCase().contains(q) ||
        (state.threads[p.id] ?? const []).any(
          (m) => m.text.toLowerCase().contains(q),
        );
    final queueShown = queued
        .where((m) => q.isEmpty || m.person.name.toLowerCase().contains(q))
        .toList();
    final expiredShown = expired
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
        .toList();
    final all = convs.where(matches).toList();
    final unread = all.where((p) => controller.unread(p.id) > 0).toList();
    final yourMove = all.where((p) => controller.yourMove(p.id)).toList();
    final rows = switch (_filter) {
      _ConvFilter.all => all,
      _ConvFilter.unread => unread,
      _ConvFilter.yourMove => yourMove,
    };
    final now = ref.read(clockProvider)();

    final Widget list;
    if (rows.isNotEmpty) {
      list = Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 80,
                color: AppColors.border,
              ),
            _ConversationRow(
              person: rows[i],
              last: controller.lastMessage(rows[i].id)!,
              unread: controller.unread(rows[i].id),
              yourMove: controller.yourMove(rows[i].id),
              now: now,
              onTap: () => _open(rows[i]),
            ),
          ],
        ],
      );
    } else if (q.isNotEmpty && all.isEmpty) {
      list = EmptyState(
        art: const NumayaIcon(
          NumayaIcons.search,
          size: 36,
          color: AppColors.ink,
        ),
        title: l10n.searchEmptyTitle(_query.trim()),
        body: l10n.searchEmptyBody,
        action: NumayaButton(
          label: l10n.searchAgain,
          small: true,
          variant: NumayaButtonVariant.secondary,
          onPressed: () {
            _search.clear();
            setState(() => _query = '');
          },
        ),
      );
    } else {
      list = EmptyState(
        art: const NumayaIcon(
          NumayaIcons.message,
          size: 36,
          color: AppColors.ink,
        ),
        title: switch (_filter) {
          _ConvFilter.unread => l10n.caughtUpTitle,
          _ConvFilter.yourMove => l10n.noOneWaitingTitle,
          _ConvFilter.all => l10n.noConvTitle,
        },
        body: _filter == _ConvFilter.all ? l10n.noConvBody : l10n.caughtUpBody,
        action: _filter == _ConvFilter.all
            ? null
            : NumayaButton(
                label: l10n.showAll,
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => setState(() => _filter = _ConvFilter.all),
              ),
      );
    }

    final queueCount = queueShown.length + expiredShown.length;
    return TabPage(
      header: header,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NumayaSearchField(
            controller: _search,
            placeholder: l10n.messagesSearch,
            clearLabel: l10n.close,
            onChanged: (v) => setState(() => _query = v),
          ),
          if (queueCount > 0) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            Semantics(
              header: true,
              child: Text(
                l10n.newMatchesTitle(queueShown.length),
                style: AppTypography.section,
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (likes > 0 && q.isEmpty)
                    _QueueItem(
                      semanticLabel: l10n.queueLikesLabel(likes),
                      caption: l10n.queueLikes,
                      onTap: () => context.go(Routes.likes),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.accentTint,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const NumayaIcon(
                              NumayaIcons.heart,
                              size: 20,
                              color: AppColors.accentOnTint,
                            ),
                            Text(
                              '$likes',
                              style: AppTypography.weight(
                                AppTypography.body,
                                AppTypography.semibold,
                              ).copyWith(color: AppColors.accentOnTint),
                            ),
                          ],
                        ),
                      ),
                    ),
                  for (final m in queueShown)
                    _QueueItem(
                      semanticLabel: l10n.chatPlaceholder(m.person.name),
                      caption: m.person.name,
                      subcaption: timeLeft(l10n, m.remaining),
                      urgent: m.remaining.inHours < 2,
                      onTap: () => _open(m.person),
                      child: CountdownAvatar(
                        initial: m.person.initial,
                        fraction: m.fraction,
                        urgent: m.remaining.inHours < 2,
                      ),
                    ),
                  for (final p in expiredShown)
                    _QueueItem(
                      semanticLabel: l10n.queueExpiredLabel(p.name),
                      caption: p.name,
                      subcaption: l10n.queueExpired,
                      onTap: () => context.push('${Routes.chat}/${p.id}'),
                      child: CountdownAvatar(
                        initial: p.initial,
                        fraction: 0,
                        expired: true,
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (movesCard != null && q.isEmpty) ...[
            const SizedBox(height: AppSpacing.s5),
            movesCard,
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          Semantics(
            header: true,
            child: Text(l10n.conversationsTitle, style: AppTypography.section),
          ),
          const SizedBox(height: AppSpacing.s3),
          ViewTabs(
            label: l10n.conversationsTitle,
            bleed: AppLayout.screenGutter,
            selected: _filter.index,
            onSelect: (i) => setState(() => _filter = _ConvFilter.values[i]),
            options: [
              (label: l10n.convFilterAll, count: all.length),
              (label: l10n.convFilterUnread, count: unread.length),
              (label: l10n.convFilterMove, count: yourMove.length),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          list,
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  const _QueueItem({
    required this.semanticLabel,
    required this.caption,
    required this.onTap,
    required this.child,
    this.subcaption,
    this.urgent = false,
  });

  final String semanticLabel;
  final String caption;
  final String? subcaption;
  final bool urgent;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s3),
      child: Pressable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        excludeChildSemantics: true,
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              child,
              const SizedBox(height: AppSpacing.s2),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.weight(
                  AppTypography.bodySm,
                  AppTypography.medium,
                ),
              ),
              if (subcaption != null)
                Text(
                  subcaption!,
                  maxLines: 1,
                  style: AppTypography.micro.copyWith(
                    color: urgent ? AppColors.negative : AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Skip the small talk" (B-43 Opening Moves card).
class _OpeningMovesCard extends StatelessWidget {
  const _OpeningMovesCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PromptMark(),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Text(l10n.movesPromoTitle, style: AppTypography.card),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            l10n.movesPromoBody,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.movesPromoAction,
            small: true,
            expand: false,
            variant: NumayaButtonVariant.secondary,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    required this.person,
    required this.last,
    required this.unread,
    required this.yourMove,
    required this.now,
    required this.onTap,
  });

  final SamplePerson person;
  final DemoMessage last;
  final int unread;
  final bool yourMove;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = last.mine ? l10n.youPrefix(last.text) : last.text;
    final time = shortTime(l10n, last.at, now);
    return Pressable(
      onTap: onTap,
      semanticLabel: [
        person.name,
        preview,
        time,
        if (unread > 0) l10n.unreadCount(unread),
        if (yourMove) l10n.yourMoveTag,
      ].join('. '),
      excludeChildSemantics: true,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
        child: Row(
          children: [
            InitialsAvatar(
              initial: person.initial,
              size: 64,
              verified: person.verified,
            ),
            const SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          person.name,
                          style: AppTypography.weight(
                            AppTypography.row,
                            AppTypography.semibold,
                          ),
                        ),
                      ),
                      Text(time, style: AppTypography.micro),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTypography.weight(
                                AppTypography.bodySm,
                                unread > 0
                                    ? AppTypography.semibold
                                    : AppTypography.regular,
                              ).copyWith(
                                color: unread > 0
                                    ? AppColors.ink
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ),
                      if (yourMove && unread == 0) ...[
                        const SizedBox(width: AppSpacing.s2),
                        StatusBadge(label: l10n.yourMoveTag),
                      ],
                      if (unread > 0) ...[
                        const SizedBox(width: AppSpacing.s2),
                        CountBadge(count: unread),
                      ],
                    ],
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

/// Conversation (B-44, V16 038 / 039 / 042). Before the first message: the person, time left with
/// Extend, their Opening Move and openers. Sample conversations show both sides, labelled; the
/// member's own messages stay on this device. An expired match offers Rematch. The ⋯ menu offers
/// View profile, Did you meet?, Unmatch, Block and Report.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.personId});

  final String personId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(datingProvider.notifier).openChat(widget.personId);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// "Back to messages", from the button and Android back alike: a chat opened from the match
  /// screen or a profile still returns to Messages, where the conversation now lives.
  void _back() => context.go(Routes.messages);

  /// Messages already on screen when the chat opened; anything newer settles in.
  Set<int>? _known;

  Future<void> _send(String text) async {
    _text.clear();
    AppHaptics.fire(context, HapticMoment.commit);
    final sending = ref
        .read(datingProvider.notifier)
        .send(widget.personId, text);
    _toLatest();
    await sending;
  }

  /// Brings the newest message into view after the frame that lays it out. The list is anchored
  /// to the bottom, so this only moves when the person had scrolled up to read.
  void _toLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients || _scroll.offset == 0) return;
      final duration = AppMotion.duration(context, AppMotion.state);
      if (duration == Duration.zero) {
        _scroll.jumpTo(0);
      } else {
        unawaited(
          _scroll.animateTo(0, duration: duration, curve: AppMotion.easeOut),
        );
      }
    });
  }

  Future<void> _menu(SamplePerson person, {required bool talked}) async {
    final l10n = context.l10n;
    final actions = [
      (
        icon: NumayaIcons.user,
        label: l10n.optionViewProfile,
        destructive: false,
      ),
      (
        icon: NumayaIcons.share,
        label: ref.read(datingProvider).datePlans.containsKey(person.id)
            ? l10n.optionShareDateEdit
            : l10n.optionShareDate,
        destructive: false,
      ),
      if (talked)
        (
          icon: NumayaIcons.event,
          label: l10n.optionDidYouMeet,
          destructive: false,
        ),
      (
        icon: NumayaIcons.userMinus,
        label: l10n.optionUnmatch,
        destructive: false,
      ),
      (
        icon: NumayaIcons.block,
        label: l10n.optionBlockShort,
        destructive: true,
      ),
      (icon: NumayaIcons.flag, label: l10n.optionReport, destructive: true),
    ];
    final choice = await showNumayaActionSheet(
      context: context,
      cancelLabel: l10n.cancel,
      actions: actions,
    );
    if (!mounted || choice == null) return;
    final label = actions[choice].label;
    if (label == l10n.optionViewProfile) {
      unawaited(context.push('${Routes.person}/${person.id}'));
    } else if (label == l10n.optionShareDate ||
        label == l10n.optionShareDateEdit) {
      await showShareDateSheet(context, ref, person);
    } else if (label == l10n.optionDidYouMeet) {
      await showDidYouMeetSheet(context, ref, person);
    } else if (label == l10n.optionUnmatch) {
      final next = await showUnmatchSheet(context, person);
      if (!mounted) return;
      if (next == UnmatchChoice.unmatch) {
        ref.read(datingProvider.notifier).end(person.id, EndReason.unmatched);
        await showUnmatchReasonSheet(context, ref, person);
      } else if (next == UnmatchChoice.report) {
        await showReportSheet(context, ref, person);
      }
    } else if (label == l10n.optionBlockShort) {
      await showBlockSheet(context, ref, person);
    } else {
      await showReportSheet(context, ref, person);
    }
  }

  Future<void> _extend(SamplePerson person) async {
    final l10n = context.l10n;
    final controller = ref.read(datingProvider.notifier);
    final result = controller.isExpired(person.id)
        ? controller.rematch(person.id)
        : controller.extend(person.id);
    if (result == ExtendResult.extended) {
      NumayaToast.show(context, l10n.chatExtended);
    } else if (result == ExtendResult.needsPremium) {
      await context.push(
        '${Routes.paywall}?feature=${PremiumFeature.rematch.name}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(datingProvider);
    final premium = ref.watch(premiumProvider);
    final person = personById(widget.personId);
    if (person == null) return const SizedBox.shrink();
    final ended = state.ended[person.id];
    if (ended != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: _EndedView(person: person, reason: ended, onBack: _back),
      );
    }

    final controller = ref.read(datingProvider.notifier);
    final messages = state.threads[person.id] ?? const <DemoMessage>[];
    final known = _known ??= {for (final m in messages) m.id};
    final expired = controller.isExpired(person.id);
    final sample = messages.any((m) => m.sample);
    final now = ref.read(clockProvider)();

    // V16 sets the chat header 8pt lower than the flow top bar (centre at 36pt).
    final header = SizedBox(
      height: AppSizes.topBar + AppSpacing.s2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenGutter,
          AppSpacing.s2,
          AppLayout.screenGutter,
          0,
        ),
        child: Row(
          children: [
            NavIconButton(
              icon: NumayaIcons.chevronLeft,
              label: l10n.backToMessages,
              onPressed: _back,
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Pressable(
                onTap: () => context.push('${Routes.person}/${person.id}'),
                semanticLabel: l10n.viewProfile(person.name),
                excludeChildSemantics: true,
                pressedScale: 1,
                child: Row(
                  children: [
                    InitialsAvatar(initial: person.initial, size: 36),
                    const SizedBox(width: AppSpacing.s3),
                    Flexible(
                      child: Text(
                        person.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.weight(
                          AppTypography.row,
                          AppTypography.semibold,
                        ),
                      ),
                    ),
                    if (person.verified) ...[
                      const SizedBox(width: 4),
                      const VerifiedMark(),
                    ],
                  ],
                ),
              ),
            ),
            NavIconButton(
              icon: NumayaIcons.more,
              label: l10n.conversationOptions,
              onPressed: () => _menu(person, talked: messages.isNotEmpty),
            ),
          ],
        ),
      ),
    );

    final Widget body;
    if (expired) {
      body = Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CountdownAvatar(
                initial: person.initial,
                fraction: 0,
                expired: true,
                size: 104,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Semantics(
              header: true,
              child: Text(
                l10n.chatExpiredTitle(person.name),
                textAlign: TextAlign.center,
                style: AppTypography.headline,
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              l10n.chatExpiredBody,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            NumayaButton(
              label: premium.active
                  ? l10n.chatRematch
                  : l10n.chatRematchPremium,
              icon: premium.active ? null : NumayaIcons.lock,
              onPressed: () => _extend(person),
            ),
          ],
        ),
      );
    } else if (messages.isEmpty) {
      final left = controller.remaining(person.id);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s6),
          Center(
            child: InitialsAvatar(
              initial: person.initial,
              size: 96,
              verified: person.verified,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.profileNameAge(person.name, person.age),
            textAlign: TextAlign.center,
            style: AppTypography.weight(
              AppTypography.sheetTitle,
              AppTypography.semibold,
            ),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            l10n.chatIntro,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.s4),
          StatusBanner(
            tone: left.inHours < 2 ? BannerTone.pending : BannerTone.info,
            title: l10n.chatExpiresIn(timeLeft(l10n, left)),
            body: premium.active
                ? l10n.chatExtendPremiumNote
                : l10n.chatExtendFreeNote,
            action: NumayaButton(
              label: l10n.chatExtend,
              small: true,
              expand: false,
              variant: NumayaButtonVariant.secondary,
              onPressed: controller.freeExtendAvailable || premium.active
                  ? () => _extend(person)
                  : null,
            ),
          ),
          if (person.openingMove != null) ...[
            const SizedBox(height: AppSpacing.s4),
            PromptCard(
              question: l10n.chatTheirMove(person.name),
              answer: person.openingMove!,
              editLabel: l10n.chatReplyToMove,
              onTap: _focus.requestFocus,
            ),
          ],
          const SizedBox(height: AppSpacing.s6),
          Text(
            l10n.chatOpenersLabel,
            style: AppTypography.weight(
              AppTypography.label,
              AppTypography.semibold,
            ).copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s3),
          for (final o in kOpeners) ...[
            Pressable(
              onTap: () {
                _text.value = TextEditingValue(
                  text: o,
                  selection: TextSelection.collapsed(offset: o.length),
                );
                _focus.requestFocus();
              },
              semanticLabel: o,
              excludeChildSemantics: true,
              pressedScale: 0.99,
              borderRadius: AppRadii.all(AppRadii.card),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.all(AppRadii.card),
                ),
                child: Text(o, style: AppTypography.row),
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
          ],
        ],
      );
    } else {
      final last = messages.last;
      final children = <Widget>[
        const SizedBox(height: AppSpacing.s4),
        if (sample)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s2),
              child: StatusBadge(label: l10n.chatSampleBadge),
            ),
          ),
        Text(
          l10n.chatMatchedWith(person.name),
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ];
      DateTime? day;
      for (var i = 0; i < messages.length; i++) {
        final m = messages[i];
        final d = DateTime(m.at.year, m.at.month, m.at.day);
        if (sample && day != d) {
          day = d;
          children.add(ChatSystemLine(dayLine(l10n, m.at, now)));
        }
        final prev = i > 0 ? messages[i - 1] : null;
        final next = i + 1 < messages.length ? messages[i + 1] : null;
        final grouped = prev != null && prev.mine == m.mine;
        final endsGroup = next == null || next.mine != m.mine;
        final bubble = Semantics(
          label: m.mine
              ? m.text
              : l10n.chatTheirMessageLabel(person.name, m.text),
          child: ExcludeSemantics(
            child: MessageBubble(
              text: m.text,
              mine: m.mine,
              grouped: grouped,
              dimmed:
                  m.status == MessageStatus.sending ||
                  m.status == MessageStatus.waiting,
            ),
          ),
        );
        children.add(
          known.contains(m.id)
              ? bubble
              : _SettleIn(key: ValueKey(m.id), child: bubble),
        );
        if (sample && endsGroup && m != last) {
          children.add(
            Align(
              alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  shortTime(l10n, m.at, now),
                  style: AppTypography.micro,
                ),
              ),
            ),
          );
        }
      }
      children.addAll([
        const SizedBox(height: AppSpacing.s1),
        Align(
          alignment: last.mine ? Alignment.centerRight : Alignment.centerLeft,
          child: !last.mine || last.sample
              ? Text(shortTime(l10n, last.at, now), style: AppTypography.micro)
              : switch (last.status) {
                  MessageStatus.sending => Text(
                    l10n.chatStatusSending,
                    style: AppTypography.micro,
                  ),
                  MessageStatus.onDevice => Text(
                    l10n.chatStatusOnDevice,
                    style: AppTypography.micro,
                  ),
                  MessageStatus.waiting => Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.chatStatusWaiting,
                      style: AppTypography.micro,
                    ),
                  ),
                  MessageStatus.failed => Semantics(
                    liveRegion: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const NumayaIcon(
                          NumayaIcons.alert,
                          size: 16,
                          color: AppColors.negative,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.chatStatusFailed,
                          style: AppTypography.micro.copyWith(
                            color: AppColors.negative,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s2),
                        TextLink(
                          label: l10n.chatRetry,
                          style: AppTypography.micro,
                          onPressed: () => controller.retry(person.id, last.id),
                        ),
                        const SizedBox(width: AppSpacing.s2),
                        TextLink(
                          label: l10n.chatDelete,
                          style: AppTypography.micro,
                          danger: true,
                          onPressed: () =>
                              controller.deleteMessage(person.id, last.id),
                        ),
                      ],
                    ),
                  ),
                },
        ),
      ]);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.contentMax,
              ),
              child: Column(
                children: [
                  header,
                  Expanded(
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      behavior: HitTestBehavior.translucent,
                      excludeFromSemantics: true,
                      // A conversation sits at the bottom, by the composer; the intro reads from
                      // the top (V16 038 / 042).
                      child: LayoutBuilder(
                        builder: (context, box) => SingleChildScrollView(
                          controller: _scroll,
                          // Anchored to the newest message: the chat opens at the latest, and
                          // stays there when the keyboard opens.
                          reverse: messages.isNotEmpty,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppLayout.screenGutter,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: box.maxHeight,
                            ),
                            child: Align(
                              alignment: messages.isEmpty
                                  ? Alignment.topCenter
                                  : Alignment.bottomCenter,
                              child: body,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!expired)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.screenGutter,
                        AppSpacing.s2,
                        AppLayout.screenGutter,
                        AppSpacing.s3,
                      ),
                      child: Column(
                        children: [
                          Composer(
                            controller: _text,
                            focusNode: _focus,
                            placeholder: l10n.chatPlaceholder(person.name),
                            sendLabel: l10n.chatSend,
                            onSend: _send,
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Text(
                            sample
                                ? l10n.chatSampleConversationNote(person.name)
                                : l10n.chatSampleNote(person.name),
                            textAlign: TextAlign.center,
                            style: AppTypography.micro,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EndedView extends StatelessWidget {
  const _EndedView({
    required this.person,
    required this.reason,
    required this.onBack,
  });

  final SamplePerson person;
  final EndReason reason;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (
      String title,
      String body,
      NumayaIllustration art,
    ) = switch (reason) {
      EndReason.unmatched => (
        l10n.endedUnmatchedTitle(person.name),
        l10n.endedUnmatchedBody(person.name),
        NumayaIllustration.unmatched,
      ),
      EndReason.blocked => (
        l10n.endedBlockedTitle(person.name),
        l10n.endedBlockedBody(person.name),
        NumayaIllustration.blocked,
      ),
      EndReason.reported => (
        l10n.endedReportedTitle(person.name),
        l10n.endedReportedBody(person.name),
        NumayaIllustration.blocked,
      ),
    };
    return NumayaScreen(
      top: NumayaTopBar(onBack: onBack, backLabel: l10n.backToMessages),
      footer: NumayaButton(label: l10n.backToMessages, onPressed: onBack),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s10),
        child: ResultPanel(
          illustration: art,
          illustrationWidth: 160,
          title: title,
          body: body,
        ),
      ),
    );
  }
}

/// A message sent while the chat is open rises 8 pt and fades in (MOTION_DESIGN_AUDIT "Message
/// sent"); instant under reduced motion.
class _SettleIn extends StatelessWidget {
  const _SettleIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: AppMotion.duration(context, AppMotion.state),
    curve: AppMotion.easeOut,
    builder: (context, v, child) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, 8 * (1 - v)), child: child),
    ),
    child: child,
  );
}
