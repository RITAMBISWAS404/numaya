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
import '../../compliments/application/compliments_controller.dart';
import '../../compliments/domain/compliment.dart';
import '../../compliments/presentation/compliment_thread.dart';
import '../../experiments/experiments.dart';
import '../../home/presentation/home_shell.dart';
import '../../home/presentation/tab_screens.dart';
import '../../lab/lab_banners.dart';
import '../../lab/lab_registry.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../application/dating_controller.dart';
import '../data/media_picker.dart';
import '../domain/sample_people.dart';
import 'chat_attachments.dart';
import 'chat_header.dart';
import 'chat_voice.dart';
import 'conversation_row.dart';
import 'empty_conversations.dart';
import 'match_avatar.dart';
import 'person_profile.dart';
import 'safety_sheets.dart';
import 'time_format.dart';

enum _ConvFilter { all, unread, yourMove }

/// Messages (B-42 / B-43, V16 034 / 037 / 052): search, the match queue (countdown rings, the
/// likes tile, expired matches), an Opening Moves prompt and conversations with view tabs.
/// One row of the conversation list: a chat, or a Compliment nobody has answered yet.
class _Entry {
  const _Entry({
    required this.person,
    required this.last,
    required this.unread,
    required this.yourMove,
    this.compliment = false,
  });

  final SamplePerson person;
  final DemoMessage last;
  final int unread;
  final bool yourMove;
  final bool compliment;
}

/// A received Compliment counts as unread until its conversation is opened.
bool _unseen(DatingState state, Compliment c) {
  final read = state.lastRead[c.personId];
  return read == null || read.isBefore(c.sentAt);
}

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
    // Screen group `screen-chats`: directions fix the row and avatar variants in this screen.
    final direction = ref.watch(labVariantProvider('screen-chats'));
    final (String? avatarV, String? rowV) = switch (direction) {
      'A' => ('B', 'D'),
      'B' => (null, 'B'),
      'C' => ('D', 'C'),
      _ => (null, null),
    };
    final expired = controller.expiredMatches();
    final archived = controller.archivedConversations();
    final convs = controller.conversations();
    final likes = controller.unansweredLikes();
    ref.watch(complimentsProvider);
    final compliments = ref.read(complimentsProvider.notifier);
    // Pending Compliments both ways, as conversations that have not started yet.
    // One row per person (docs/v8-replacement/CONVERSATION_CONTRACT.md): a person who already
    // has a thread shows only that thread, never a second Compliment row.
    final threaded = {for (final p in convs) p.id};
    final pending = <Compliment>[
      for (final c in compliments.requests())
        if (!threaded.contains(c.personId)) c,
      for (final c in ref.read(complimentsProvider))
        if (c.fromMe &&
            c.status == ComplimentStatus.pending &&
            state.isActive(c.personId) &&
            !state.matches.contains(c.personId) &&
            !threaded.contains(c.personId))
          c,
    ];
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

    // R03: Compliment requests live on the Heart tab, not here. R01: quiet chats are in Archive.
    if (queued.isEmpty &&
        expired.isEmpty &&
        archived.isEmpty &&
        convs.isEmpty &&
        pending.isEmpty) {
      // EXP-003 (Experiment Lab only; release builds show the refined candidate).
      final variant = ref.watch(
        experimentVariantProvider(Experiment.emptyChats),
      );
      if (variant != ExpVariant.current) {
        return TabPage(
          header: header,
          child: EmptyConversations(
            variant: variant,
            likes: likes,
            onDiscover: () => context.go(Routes.home),
            onLikes: () => context.go(Routes.likes),
            onEvents: () => context.go(Routes.events),
            events: ref.watch(eventsAvailableProvider),
          ),
        );
      }
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
    final laterCount = archived.length + expired.length;
    final now = ref.read(clockProvider)();
    // One list: chats and not-yet-answered Compliments, newest activity first.
    final entries = <_Entry>[
      for (final p in convs.where(matches))
        _Entry(
          person: p,
          last: controller.lastMessage(p.id)!,
          unread: controller.unread(p.id),
          yourMove: controller.yourMove(p.id),
        ),
      for (final c in pending)
        if (personById(c.personId) case final p? when matches(p))
          _Entry(
            person: p,
            last: DemoMessage(
              id: -1,
              text: c.text,
              status: MessageStatus.onDevice,
              at: c.sentAt,
              mine: c.fromMe,
              sample: !c.fromMe,
            ),
            // Unread until opened; it is your move until you reply.
            unread: !c.fromMe && _unseen(state, c) ? 1 : 0,
            yourMove: !c.fromMe,
            compliment: true,
          ),
    ]..sort((a, b) => b.last.at.compareTo(a.last.at));
    final all = entries;
    final unread = all.where((e) => e.unread > 0).toList();
    final yourMove = all.where((e) => e.yourMove).toList();
    final rows = switch (_filter) {
      _ConvFilter.all => all,
      _ConvFilter.unread => unread,
      _ConvFilter.yourMove => yourMove,
    };

    final dividers = ref.watch(labVariantProvider('r8-chat-dividers'));
    final Widget list;
    if (rows.isNotEmpty) {
      list = Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            // Replacement V8 (lab r8-chat-dividers): A near-full hairline (recommended), B inset to
            // the text, O spacing only (V7).
            if (i > 0 && dividers != 'O')
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: dividers == 'B'
                      ? ConversationRow.textInset
                      : AppLayout.screenGutter,
                  end: AppLayout.screenGutter,
                ),
                child: const ExcludeSemantics(
                  child: SizedBox(
                    height: AppBorders.hairline,
                    width: double.infinity,
                    child: ColoredBox(color: AppColors.divider),
                  ),
                ),
              ),
            ConversationRow(
              key: ValueKey('conversation-${rows[i].person.id}'),
              person: rows[i].person,
              last: rows[i].last,
              unread: rows[i].unread,
              yourMove: rows[i].yourMove,
              compliment: rows[i].compliment,
              now: now,
              onTap: () => _open(rows[i].person),
              variant: rowV,
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

    final queueCount = queueShown.length;
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
                  // Owner selection (Visual Lab): only real new matches here; likes live in
                  // the Heart tab, so the likes tile is gone from this row.
                  // R02: the photo carries a ring showing the fraction of the (possibly
                  // extended) window left; no number under it. The exact time and the
                  // extension are inside the chat; the spoken label includes the time left.
                  for (final m in queueShown)
                    MatchAvatarTile(
                      key: ValueKey('match-tile-${m.person.id}'),
                      person: m.person,
                      fraction: m.fraction,
                      variant: avatarV,
                      semanticLabel: l10n.queueMatchLabel(
                        m.person.name,
                        timeLeft(l10n, m.remaining),
                      ),
                      onTap: () => _open(m.person),
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
          if (laterCount > 0 && q.isEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            ListGroup(
              children: [
                ListRow(
                  key: const ValueKey('chats-archive'),
                  leadingMobile: NumayaMobileIcons.archive,
                  label: l10n.chatsArchiveRow,
                  detail: archived.isEmpty
                      ? l10n.chatsArchiveExpiredOnly(expired.length)
                      : l10n.chatsArchiveDetail(archived.length),
                  onTap: () => context.push(Routes.archive),
                ),
              ],
            ),
          ],
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
  bool _recording = false;
  final _messageKeys = <int, GlobalKey>{};

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
      if (!mounted) return;
      final dating = ref.read(datingProvider.notifier);
      dating.openChat(widget.personId);
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

  /// Sends a finished voice note, answering the message being replied to.
  Future<void> _sendVoice(MessageAttachment note) async {
    final replyTo = _replyTo;
    setState(() {
      _recording = false;
      _replyTo = null;
    });
    AppHaptics.fire(context, HapticMoment.commit);
    final sending = ref
        .read(datingProvider.notifier)
        .send(widget.personId, '', attachment: note, replyToId: replyTo?.id);
    _toLatest();
    await sending;
  }

  void _goToMessage(int id) {
    final target = _messageKeys[id]?.currentContext;
    if (target != null) {
      unawaited(
        Scrollable.ensureVisible(
          target,
          alignment: 0.3,
          duration: AppMotion.duration(context, AppMotion.state),
        ),
      );
    }
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
        icon: NumayaIcons.bell,
        label: ref.read(datingProvider).muted.contains(person.id)
            ? l10n.chatUnmute
            : l10n.chatMute,
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
    } else if (label == l10n.chatMute || label == l10n.chatUnmute) {
      final mute = label == l10n.chatMute;
      ref.read(datingProvider.notifier).setMuted(person.id, mute);
      NumayaToast.show(
        context,
        mute ? l10n.chatMuted(person.name) : l10n.chatUnmuted(person.name),
      );
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
    switch (controller.extend(person.id)) {
      case ExtendResult.extended:
        AppHaptics.fire(context, HapticMoment.success);
        NumayaToast.show(context, l10n.extendDone(person.name));
      case ExtendResult.needsPremium:
        await context.push(
          '${Routes.paywall}?feature=${PremiumFeature.extension.name}',
        );
      case ExtendResult.usedToday:
        NumayaToast.show(context, l10n.extendUsedToday);
      case ExtendResult.alreadyExtended:
        NumayaToast.show(context, l10n.extendAlready);
      case ExtendResult.notNeeded:
        break;
    }
  }

  /// R02: an initial match that ran out before anyone wrote. A simple expired state: no
  /// reconnection, no countdown, one way back.
  Widget _expiredPanel(SamplePerson person) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.chatExpiredFirstTitle,
            textAlign: TextAlign.center,
            style: AppTypography.sheetTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          l10n.chatExpiredSimpleBody,
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          key: const ValueKey('chat-expired-discover'),
          label: l10n.backToDiscover,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => context.go(Routes.home),
        ),
      ],
    );
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
    // V8: before a reply, a Compliment is this conversation. Received: reply privately here;
    // sent: wait here. Once answered the same route becomes the chat, Compliment first.
    ref.watch(complimentsProvider);
    if (messages.isEmpty && !state.matches.contains(person.id)) {
      final compliments = ref.read(complimentsProvider.notifier);
      final incoming = compliments.pendingFrom(person.id);
      final outgoing = compliments.sentTo(person.id);
      final c =
          incoming ??
          (outgoing?.status == ComplimentStatus.pending ? outgoing : null);
      if (c != null && state.isActive(person.id)) {
        return ComplimentThread(person: person, compliment: c, onBack: _back);
      }
      // Not a match and no Compliment to answer: there is no conversation to write in.
      return NumayaScreen(
        top: NumayaTopBar(onBack: _back, backLabel: l10n.backToMessages),
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s10),
          child: EmptyState(
            art: const IllustrationView(NumayaIllustration.noChats, width: 140),
            title: l10n.requestGone,
            body: '',
          ),
        ),
      );
    }
    final known = _known ??= {for (final m in messages) m.id};
    final expired = controller.isExpired(person.id);
    final archived = controller.isArchived(person.id);
    final now = ref.read(clockProvider)();

    // UC-05: the same height and centre line as `NumayaTopBar` (the V16 8pt drop is retired), so
    // Back sits where it does on every other pushed page.
    final header = ChatHeader(
      person: person,
      onBack: _back,
      onMenu: () => _menu(person, talked: messages.isNotEmpty),
    );

    final Widget body;
    if (expired && messages.isEmpty) {
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
                image: personAvatarImage(person),
                imageAlignment: personAvatarFocus(person),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            _expiredPanel(person),
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
              image: personAvatarImage(person),
              imageAlignment: personAvatarFocus(person),
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
            style: AppTypography.helper,
          ),
          const SizedBox(height: AppSpacing.s4),
          StatusBanner(
            tone: left.inHours < 2 ? BannerTone.pending : BannerTone.info,
            title: l10n.chatExpiresIn(timeLeft(l10n, left)),
            // R02: the exact end, then the extension rule (one per match).
            body:
                '${l10n.chatEndsAt(deadlineWhen(l10n, controller.expiresAt(person.id), now))} '
                '${premium.active ? l10n.chatExtendPremiumNote : l10n.chatExtendFreeNote}',
            action: NumayaButton(
              label: l10n.chatExtend,
              small: true,
              expand: false,
              variant: NumayaButtonVariant.secondary,
              onPressed: state.extendedUntil.containsKey(person.id)
                  ? null
                  : () => _extend(person),
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
        final quoteGone = m.replyToId != null && quoted == null;
        final quotedPhoto =
            quoted?.attachment?.kind == AttachmentKind.photo &&
                quoted?.attachment?.source != null
            ? quoted!.attachment
            : null;
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
                    time: DateFormat('HH:mm').format(m.at),
                    replyAuthor: quoted == null
                        ? (m.context == null
                              ? null
                              : (m.mine
                                    ? l10n.v8ComplimentYours
                                    : l10n.v8ComplimentTheirs(person.name)))
                        : (quoted.mine ? l10n.chatYou : person.name),
                    replyText: quoteGone
                        ? l10n.chatQuoteUnavailable
                        : quoted != null
                        ? preview(quoted)
                        : m.context == null
                        ? null
                        : (m.context == kComplimentPhotoContext
                              ? l10n.v8ComplimentOnAPhoto
                              : m.context!),
                    quoteStyle: switch (ref.watch(
                      labVariantProvider('v6-quote-style'),
                    )) {
                      'A' => QuoteStyle.stripe,
                      'B' => QuoteStyle.plain,
                      _ => QuoteStyle.block,
                    },
                    replyThumbnail: quotedPhoto == null
                        ? null
                        : ClipRRect(
                            borderRadius: AppRadii.all(AppRadii.tag),
                            child: SizedBox.square(
                              dimension: 36,
                              child: AttachmentImage(
                                attachment: quotedPhoto,
                                width: 36,
                              ),
                            ),
                          ),
                    onQuoteTap: quoted == null
                        ? null
                        : () => _goToMessage(quoted.id),
                  ),
                ),
              );
        // UI-035/UI-036: no exact time at rest; drag left to see it, right to reply. Long press
        // and the screen-reader actions offer both without a gesture.
        final time = DateFormat('HH:mm').format(m.at);
        final swipeable = SwipeableMessage(
          key: _messageKeys.putIfAbsent(
            m.id,
            () => GlobalKey(debugLabel: 'message-${m.id}'),
          ),
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
                // R01: an archived chat stays fully usable; the note says why it moved and that
                // sending brings it back. No timer, request or fee.
                if (archived)
                  Padding(
                    key: const ValueKey('chat-archived-note'),
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.screenGutter,
                      AppSpacing.s2,
                      AppLayout.screenGutter,
                      AppSpacing.s2,
                    ),
                    child: LabStatusBanner(
                      tone: BannerTone.info,
                      icon: NumayaMobileIcons.archive,
                      title: l10n.chatArchivedTitle,
                      body: l10n.chatArchivedBody,
                    ),
                  ),
                // An expired initial match with no messages shows its state in the body; the bar
                // is only for one that has history.
                if (expired && messages.isEmpty)
                  // The ended state is in the body; no composer and no empty bar.
                  SizedBox(height: MediaQuery.paddingOf(context).bottom)
                else if (expired)
                  ColoredBox(
                    key: const ValueKey('chat-expired-bar'),
                    color: AppColors.surface,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppLayout.screenGutter,
                        AppSpacing.s4,
                        AppLayout.screenGutter,
                        AppSpacing.s4 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: _expiredPanel(person),
                    ),
                  )
                else
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
                                      thumbnail:
                                          r.attachment?.kind ==
                                                  AttachmentKind.photo &&
                                              r.attachment?.source != null
                                          ? ClipRRect(
                                              borderRadius: AppRadii.all(
                                                AppRadii.tag,
                                              ),
                                              child: SizedBox.square(
                                                dimension: 36,
                                                child: AttachmentImage(
                                                  attachment: r.attachment!,
                                                  width: 36,
                                                ),
                                              ),
                                            )
                                          : null,
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
                                  // PRD 02: one-sided spam guard.
                                  if (!controller.canSendMore(person.id)) ...[
                                    Text(
                                      l10n.chatSpamLimit(person.name),
                                      style: AppTypography.helper,
                                    ),
                                    const SizedBox(height: AppSpacing.s2),
                                  ],
                                  // UI-041: no demo footer under the composer.
                                  if (_recording)
                                    VoiceRecorderBar(
                                      onClose: () =>
                                          setState(() => _recording = false),
                                      onSend: _sendVoice,
                                    )
                                  else
                                    Composer(
                                      controller: _text,
                                      focusNode: _focus,
                                      placeholder: _pending == null
                                          ? l10n.chatPlaceholder(person.name)
                                          : l10n.chatCaptionPlaceholder,
                                      sendLabel: l10n.chatSend,
                                      onSend: _send,
                                      hasAttachment: _pending != null,
                                      idleAction:
                                          ref.watch(chatAttachmentsProvider) &&
                                              controller.canSendMore(
                                                person.id,
                                              ) &&
                                              ref.watch(
                                                    labVariantProvider(
                                                      'v6-composer',
                                                    ),
                                                  ) !=
                                                  'A'
                                          ? NavIconButton(
                                              key: const ValueKey('chat-voice'),
                                              icon: NumayaIcons.mic,
                                              label: l10n.chatRecordVoice,
                                              style: NavButtonStyle.plain,
                                              onPressed: () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                setState(
                                                  () => _recording = true,
                                                );
                                              },
                                            )
                                          : null,
                                      enabled: controller.canSendMore(
                                        person.id,
                                      ),
                                      // PRD 01: chat is text and emoji only in the MVP; attachments
                                      // stay dormant behind ReleaseScope.chatAttachments.
                                      leading:
                                          ref.watch(chatAttachmentsProvider)
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                NavIconButton(
                                                  icon: NumayaIcons.plus,
                                                  label: l10n.chatAttach,
                                                  style: NavButtonStyle.plain,
                                                  onPressed: _attach,
                                                ),
                                                if (ref.watch(
                                                      labVariantProvider(
                                                        'v6-composer',
                                                      ),
                                                    ) ==
                                                    'A')
                                                  NavIconButton(
                                                    key: const ValueKey(
                                                      'chat-voice',
                                                    ),
                                                    icon: NumayaIcons.mic,
                                                    label: l10n.chatRecordVoice,
                                                    style: NavButtonStyle.plain,
                                                    onPressed: () => setState(
                                                      () => _recording = true,
                                                    ),
                                                  ),
                                              ],
                                            )
                                          : null,
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
