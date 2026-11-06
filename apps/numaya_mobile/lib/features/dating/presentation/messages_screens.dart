import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/release_scope.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/home_shell.dart';
import '../../home/presentation/tab_screens.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../application/dating_controller.dart';
import '../data/media_picker.dart';
import '../domain/sample_people.dart';
import 'chat_attachments.dart';
import 'person_profile.dart';
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

  /// Bumble's Chats keep search behind a header icon (ER-03); the field opens on demand.
  bool _searching = false;

  void _closeSearch() {
    _search.clear();
    setState(() {
      _query = '';
      _searching = false;
    });
  }

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
    final header = TabHeader(
      title: l10n.tabChats,
      actions: [
        if (!_searching)
          NavIconButton(
            icon: NumayaIcons.search,
            label: l10n.messagesSearch,
            onPressed: () => setState(() => _searching = true),
          ),
      ],
    );
    // Bumble's list labels ("Your matches (10)", "Chats") are small headings, not page sections.
    final listHeading = AppTypography.headerCaps;

    // UI-031: no Opening Moves promotion in the first release.
    final movesCard = hasMoves || !ReleaseScope.openingMoves
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
          if (_searching) ...[
            Row(
              children: [
                Expanded(
                  child: NumayaSearchField(
                    controller: _search,
                    placeholder: l10n.messagesSearch,
                    clearLabel: l10n.close,
                    autofocus: true,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                TextLink(
                  label: l10n.cancel,
                  muted: true,
                  onPressed: _closeSearch,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          if (queueCount > 0) ...[
            Semantics(
              header: true,
              child: Text(
                l10n.newMatchesTitle(queueShown.length),
                style: listHeading,
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UI-034: Likes stays first, as an illustrated rounded square with the real
                  // count at the top.
                  if (likes > 0 && q.isEmpty)
                    _LikesTile(
                      count: likes,
                      semanticLabel: l10n.queueLikesLabel(likes),
                      onTap: () => context.go(Routes.likes),
                    ),
                  // UI-033: each match is a larger rounded-square photo with no visible name,
                  // countdown or ring. Name and time left stay in the spoken label.
                  for (final m in queueShown)
                    _MatchTile(
                      key: ValueKey('match-tile-${m.person.id}'),
                      person: m.person,
                      semanticLabel: l10n.queueMatchLabel(
                        m.person.name,
                        timeLeft(l10n, m.remaining),
                      ),
                      onTap: () => _open(m.person),
                    ),
                  for (final p in expiredShown)
                    _MatchTile(
                      key: ValueKey('match-tile-${p.id}'),
                      person: p,
                      expired: true,
                      semanticLabel: l10n.queueExpiredLabel(p.name),
                      onTap: () => context.push('${Routes.chat}/${p.id}'),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          Semantics(
            header: true,
            child: Text(l10n.conversationsTitle, style: listHeading),
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
          // DX-03: the Opening Moves suggestion follows the conversations (Bumble's inbox keeps
          // matches and chats together); it no longer pushes them down.
          if (movesCard != null && q.isEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            movesCard,
          ],
        ],
      ),
    );
  }
}

/// The New matches row's tile size and corner (UI-033, A-016): a rounded square the photo fills.
const double _tileSize = 96;
const double _tileGap = AppSpacing.s3;

/// One new match (UI-033): their first photo in a rounded square, or their initial on the photo
/// grey. An expired match is dimmed; its state is in the spoken label.
class _MatchTile extends StatelessWidget {
  const _MatchTile({
    super.key,
    required this.person,
    required this.semanticLabel,
    required this.onTap,
    this.expired = false,
  });

  final SamplePerson person;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final image = personPhotoImage(person, 1);
    return Padding(
      padding: const EdgeInsets.only(right: _tileGap),
      child: Pressable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        excludeChildSemantics: true,
        borderRadius: AppRadii.all(AppRadii.card),
        child: Opacity(
          opacity: expired ? AppOpacity.disabled : 1,
          child: ClipRRect(
            borderRadius: AppRadii.all(AppRadii.card),
            child: SizedBox.square(
              dimension: _tileSize,
              child:
                  image ??
                  ColoredBox(
                    color: AppColors.photo,
                    child: Center(
                      child: Text(
                        person.initial,
                        textScaler: TextScaler.noScaling,
                        style: AppTypography.weight(
                          AppTypography.headline,
                          AppTypography.semibold,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The Likes tile (UI-034, A-016's illustrated first tile): the same rounded square, the real
/// count large at the top, and the Numaya mascot (existing approved artwork) anchored at the foot.
class _LikesTile extends StatelessWidget {
  const _LikesTile({
    required this.count,
    required this.semanticLabel,
    required this.onTap,
  });

  final int count;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: _tileGap),
      child: Pressable(
        key: const ValueKey('likes-tile'),
        onTap: onTap,
        semanticLabel: semanticLabel,
        excludeChildSemantics: true,
        borderRadius: AppRadii.all(AppRadii.card),
        child: ClipRRect(
          borderRadius: AppRadii.all(AppRadii.card),
          child: Container(
            width: _tileSize,
            height: _tileSize,
            color: AppColors.accentTint,
            child: Stack(
              children: [
                const Positioned(
                  left: 10,
                  right: 10,
                  bottom: -6,
                  child: IllustrationView(
                    NumayaIllustration.mascotWaiting,
                    width: _tileSize - 20,
                  ),
                ),
                Positioned(
                  top: AppSpacing.s2,
                  left: AppSpacing.s3,
                  right: AppSpacing.s2,
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    key: const ValueKey('likes-tile-count'),
                    maxLines: 1,
                    textScaler: TextScaler.noScaling,
                    style: AppTypography.weight(
                      AppTypography.headline,
                      AppTypography.bold,
                    ).copyWith(color: AppColors.accentOnTint),
                  ),
                ),
              ],
            ),
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
    final text = last.attachment == null
        ? last.text
        : [
            attachmentSummary(l10n, last.attachment!),
            if (last.text.isNotEmpty) last.text,
          ].join(': ');
    final preview = last.mine ? l10n.youPrefix(text) : text;
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
                                // UI-045: a read preview is muted metadata; unread stays ink.
                                color: unread > 0
                                    ? AppColors.ink
                                    : AppColors.textMuted,
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

  /// A photo, video or voice note waiting to be sent with the next message.
  MessageAttachment? _pending;

  /// The message being answered (UI-036), set by a right swipe or the Reply action.
  DemoMessage? _replyTo;

  /// Messages whose exact time is pinned open by the Show time action (UI-035's alternative to
  /// the left swipe).
  final Set<int> _timeShown = {};

  void _startReply(DemoMessage m) {
    setState(() => _replyTo = m);
    _focus.requestFocus();
  }

  void _toggleTime(DemoMessage m) => setState(
    () => _timeShown.contains(m.id)
        ? _timeShown.remove(m.id)
        : _timeShown.add(m.id),
  );

  /// The long-press alternative to both swipes: Reply, or Show / Hide time.
  Future<void> _messageActions(DemoMessage m) async {
    final l10n = context.l10n;
    final shown = _timeShown.contains(m.id);
    final choice = await showNumayaActionSheet(
      context: context,
      cancelLabel: l10n.cancel,
      actions: [
        (icon: NumayaIcons.undo, label: l10n.chatReply, destructive: false),
        (
          icon: NumayaIcons.clock,
          label: shown ? l10n.chatHideTime : l10n.chatShowTime,
          destructive: false,
        ),
      ],
    );
    if (!mounted || choice == null) return;
    if (choice == 0) {
      _startReply(m);
    } else {
      _toggleTime(m);
    }
  }

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
    final attachment = _pending;
    final replyTo = _replyTo;
    setState(() {
      _pending = null;
      _replyTo = null;
    });
    AppHaptics.fire(context, HapticMoment.commit);
    final sending = ref
        .read(datingProvider.notifier)
        .send(
          widget.personId,
          text,
          attachment: attachment,
          replyToId: replyTo?.id,
        );
    _toLatest();
    await sending;
  }

  Future<void> _attach() async {
    FocusScope.of(context).unfocus();
    final picked = await chooseAttachment(context, ref);
    if (!mounted || picked == null) return;
    setState(() => _pending = picked);
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
              style: NavButtonStyle.plain,
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
          // UI-031: ordinary messaging only; no Opening Move in the first release.
          if (ReleaseScope.openingMoves && person.openingMove != null) ...[
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
        Text(
          l10n.chatMatchedWith(person.name),
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ];
      DateTime? day;
      final byId = {for (final m in messages) m.id: m};
      String preview(DemoMessage m) => m.attachment == null
          ? m.text
          : [
              attachmentSummary(l10n, m.attachment!),
              if (m.text.isNotEmpty) m.text,
            ].join('. ');
      for (var i = 0; i < messages.length; i++) {
        final m = messages[i];
        final d = DateTime(m.at.year, m.at.month, m.at.day);
        // Day lines stay (UI-035): with exact times hidden, they are the thread's time context.
        if (day != d) {
          day = d;
          children.add(ChatSystemLine(dayLine(l10n, m.at, now)));
        }
        final prev = i > 0 ? messages[i - 1] : null;
        final grouped = prev != null && prev.mine == m.mine;
        final quoted = m.replyToId == null ? null : byId[m.replyToId];
        final dimmed =
            m.status == MessageStatus.sending ||
            m.status == MessageStatus.waiting;
        final spoken = m.attachment == null
            ? m.text
            : [
                attachmentSummary(l10n, m.attachment!),
                if (m.text.isNotEmpty) m.text,
              ].join('. ');
        final bubble = m.attachment != null
            ? MergeSemantics(
                child: Semantics(
                  label: m.mine
                      ? spoken
                      : l10n.chatTheirMessageLabel(person.name, spoken),
                  child: AttachmentMessage(
                    attachment: m.attachment!,
                    caption: m.text,
                    mine: m.mine,
                    grouped: grouped,
                    dimmed: dimmed,
                  ),
                ),
              )
            : Semantics(
                label: m.mine
                    ? m.text
                    : l10n.chatTheirMessageLabel(person.name, m.text),
                child: ExcludeSemantics(
                  child: MessageBubble(
                    text: m.text,
                    mine: m.mine,
                    grouped: grouped,
                    dimmed: dimmed,
                    replyAuthor: quoted == null
                        ? null
                        : (quoted.mine ? l10n.chatYou : person.name),
                    replyText: quoted == null ? null : preview(quoted),
                  ),
                ),
              );
        // UI-035/UI-036: no exact time at rest; drag left to see it, right to reply. Long press
        // and the screen-reader actions offer both without a gesture.
        final time = DateFormat('HH:mm').format(m.at);
        final swipeable = SwipeableMessage(
          key: ValueKey('message-${m.id}'),
          mine: m.mine,
          time: time,
          timeShown: _timeShown.contains(m.id),
          onReply: () => _startReply(m),
          onLongPress: () => _messageActions(m),
          semanticActions: {
            CustomSemanticsAction(label: l10n.chatReply): () => _startReply(m),
            CustomSemanticsAction(
              label: _timeShown.contains(m.id)
                  ? l10n.chatHideTime
                  : l10n.chatSentAt(time),
            ): () =>
                _toggleTime(m),
          },
          child: bubble,
        );
        children.add(
          known.contains(m.id)
              ? swipeable
              : _SettleIn(key: ValueKey(m.id), child: swipeable),
        );
      }
      children.addAll([
        const SizedBox(height: AppSpacing.s1),
        // UI-035: the resting thread shows no exact time; your own newest message keeps its
        // delivery state (sending, waiting, failed, not sent), which is status, not a timestamp.
        Align(
          alignment: Alignment.centerRight,
          child: !last.mine || last.sample
              ? const SizedBox.shrink()
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
        // The composer bar runs under the system navigation area (UI-038), so the bottom inset is
        // its own padding rather than the SafeArea's.
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, outer) => Column(
              children: [
                Expanded(
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
                              // A conversation sits at the bottom, by the composer; the intro reads
                              // from the top (V16 038 / 042).
                              child: LayoutBuilder(
                                builder: (context, box) => SingleChildScrollView(
                                  controller: _scroll,
                                  // Anchored to the newest message: the chat opens at the latest,
                                  // and stays there when the keyboard opens.
                                  reverse: messages.isNotEmpty,
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  padding: const EdgeInsets.fromLTRB(
                                    AppLayout.screenGutter,
                                    0,
                                    AppLayout.screenGutter,
                                    AppSpacing.s3,
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
                        ],
                      ),
                    ),
                  ),
                ),
                if (!expired)
                  // UI-038: Plus, the field and Send in one white bar, edge to edge. On a small
                  // phone with large text and the keyboard up, the bar takes at most a little over
                  // half the height and scrolls beyond that, so the conversation stays visible.
                  // The bottom padding is the system inset (zero while the keyboard is up, since
                  // the Scaffold already lifts the bar above it).
                  ColoredBox(
                    key: const ValueKey('chat-composer-bar'),
                    color: AppColors.surface,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: outer.maxHeight * 0.55,
                      ),
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.s3,
                            AppSpacing.s2,
                            AppSpacing.s3,
                            AppSpacing.s2 +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AppSpacing.contentMax,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_replyTo case final r?) ...[
                                    ReplyPreview(
                                      title: r.mine
                                          ? l10n.chatReplyingToYourself
                                          : l10n.chatReplyingTo(person.name),
                                      text: r.attachment == null
                                          ? r.text
                                          : [
                                              attachmentSummary(
                                                l10n,
                                                r.attachment!,
                                              ),
                                              if (r.text.isNotEmpty) r.text,
                                            ].join('. '),
                                      cancelLabel: l10n.chatCancelReply,
                                      onCancel: () =>
                                          setState(() => _replyTo = null),
                                    ),
                                    const SizedBox(height: AppSpacing.s2),
                                  ],
                                  if (_pending != null) ...[
                                    PendingAttachment(
                                      attachment: _pending!,
                                      onRemove: () =>
                                          setState(() => _pending = null),
                                    ),
                                    const SizedBox(height: AppSpacing.s2),
                                  ],
                                  // UI-041: no demo footer under the composer.
                                  Composer(
                                    controller: _text,
                                    focusNode: _focus,
                                    placeholder: _pending == null
                                        ? l10n.chatPlaceholder(person.name)
                                        : l10n.chatCaptionPlaceholder,
                                    sendLabel: l10n.chatSend,
                                    onSend: _send,
                                    hasAttachment: _pending != null,
                                    leading: NavIconButton(
                                      icon: NumayaIcons.plus,
                                      label: l10n.chatAttach,
                                      style: NavButtonStyle.plain,
                                      onPressed: _attach,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
