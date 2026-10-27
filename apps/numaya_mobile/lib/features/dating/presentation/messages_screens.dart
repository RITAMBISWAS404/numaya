import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/home_shell.dart';
import '../../home/presentation/tab_screens.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';
import 'safety_sheets.dart';

enum _ConvFilter { all, unread, yourMove }

/// Messages (B-42 / B-43, V16 034 / 037 / 052): search, new matches as round portraits, and
/// conversations with view tabs. In this demo nobody writes back, so Unread and Your move stay empty
/// and say so.
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
    final controller = ref.read(datingProvider.notifier);
    final fresh = controller.newMatches();
    final convs = controller.conversations();
    final header = TabHeader(title: l10n.tabChats);

    if (fresh.isEmpty && convs.isEmpty) {
      return TabPage(
        header: header,
        child: EmptyState(
          art: const IllustrationView(NumayaIllustration.noChats, width: 160),
          title: l10n.chatsEmptyTitle,
          body: l10n.chatsEmptyBody,
          action: NumayaButton(
            label: l10n.findYourPeople,
            small: true,
            onPressed: () => context.go(Routes.home),
          ),
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
    final freshShown = fresh
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
        .toList();
    final all = convs.where(matches).toList();
    // Nobody replies in the demo: nothing is unread and nothing waits on you.
    final rows = _filter == _ConvFilter.all ? all : <SamplePerson>[];

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
              last: state.threads[rows[i].id]!.last,
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
          if (freshShown.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            Semantics(
              header: true,
              child: Text(
                l10n.newMatchesTitle(freshShown.length),
                style: AppTypography.section,
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (final p in freshShown)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s4),
                      child: Pressable(
                        onTap: () => _open(p),
                        semanticLabel: l10n.chatPlaceholder(p.name),
                        excludeChildSemantics: true,
                        child: Column(
                          children: [
                            InitialsAvatar(
                              initial: p.initial,
                              size: 72,
                              ring: !state.openedMatches.contains(p.id),
                            ),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              p.name,
                              style: AppTypography.weight(
                                AppTypography.bodySm,
                                AppTypography.medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          Semantics(
            header: true,
            child: Text(l10n.conversationsTitle, style: AppTypography.section),
          ),
          const SizedBox(height: AppSpacing.s3),
          ViewTabs(
            label: l10n.conversationsTitle,
            selected: _filter.index,
            onSelect: (i) => setState(() => _filter = _ConvFilter.values[i]),
            options: [
              (label: l10n.convFilterAll, count: all.length),
              (label: l10n.convFilterUnread, count: 0),
              (label: l10n.convFilterMove, count: 0),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          list,
        ],
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    required this.person,
    required this.last,
    required this.onTap,
  });

  final SamplePerson person;
  final DemoMessage last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = l10n.youPrefix(last.text);
    return Pressable(
      onTap: onTap,
      semanticLabel: '${person.name}. $preview',
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
                  Text(
                    person.name,
                    style: AppTypography.weight(
                      AppTypography.row,
                      AppTypography.semibold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
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

/// Conversation (B-44, V16 038 / 039 / 042). Before the first message: the person centred with
/// openers to edit. Messages are the member's own, kept on this device and labelled; a failed send
/// offers Retry or Delete. The ⋯ menu offers Unmatch, Block and Report.
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

  Future<void> _send(String text) async {
    _text.clear();
    await ref.read(datingProvider.notifier).send(widget.personId, text);
    if (_scroll.hasClients) {
      unawaited(
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: AppMotion.base,
          curve: AppMotion.easeOut,
        ),
      );
    }
  }

  Future<void> _menu(SamplePerson person) async {
    final l10n = context.l10n;
    final choice = await showNumayaActionSheet(
      context: context,
      cancelLabel: l10n.cancel,
      actions: [
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
      ],
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 0:
        final next = await showUnmatchSheet(context, person);
        if (!mounted) return;
        if (next == UnmatchChoice.unmatch) {
          ref.read(datingProvider.notifier).end(person.id, EndReason.unmatched);
        } else if (next == UnmatchChoice.report) {
          await showReportSheet(context, ref, person);
        }
      case 1:
        await showBlockSheet(context, ref, person);
      case 2:
        await showReportSheet(context, ref, person);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(datingProvider);
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

    final messages = state.threads[person.id] ?? const <DemoMessage>[];
    final controller = ref.read(datingProvider.notifier);

    // V16 sets the chat header 8pt lower than the flow top bar (centre at 36pt).
    final header = SizedBox(
      height: AppSizes.topBar + AppSpacing.s2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s2,
          AppSpacing.gutter,
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
              onPressed: () => _menu(person),
            ),
          ],
        ),
      ),
    );

    final Widget body;
    if (messages.isEmpty) {
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
          const SizedBox(height: AppSpacing.s8),
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
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.chatMatchedWith(person.name),
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          for (var i = 0; i < messages.length; i++)
            Semantics(
              label: messages[i].text,
              child: ExcludeSemantics(
                child: MessageBubble(
                  text: messages[i].text,
                  grouped: i > 0,
                  dimmed: messages[i].status == MessageStatus.sending,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s1),
          Align(
            alignment: Alignment.centerRight,
            child: switch (last.status) {
              MessageStatus.sending => Text(
                l10n.chatStatusSending,
                style: AppTypography.micro,
              ),
              MessageStatus.onDevice => Text(
                l10n.chatStatusOnDevice,
                style: AppTypography.micro,
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
        ],
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
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.gutter,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.s2,
                      AppSpacing.gutter,
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
                          l10n.chatSampleNote(person.name),
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
