import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/domain/sample_people.dart';
import '../../dating/presentation/chat_header.dart';
import '../../dating/presentation/person_profile.dart';
import '../../dating/presentation/safety_sheets.dart';
import '../../dating/presentation/time_format.dart';
import '../application/compliments_controller.dart';
import '../domain/compliment.dart';
import 'compliment_screens.dart' show ownProfilePersonProvider, promptAt;
import 'compliments_inbox.dart' show confirmComplimentDismiss;

/// V8: a Compliment is the first event of a conversation, not a separate inbox. Before anyone
/// replies the chat route shows this thread: the Compliment as a message that quotes the photo or
/// prompt it was about, then either a private reply composer (received) or a waiting note (sent).
/// Replying is free and opens the real conversation in place, with the Compliment kept first.
/// The rules are unchanged: one per pair, and the sender cannot write until the recipient replies.
class ComplimentThread extends ConsumerStatefulWidget {
  const ComplimentThread({
    super.key,
    required this.person,
    required this.compliment,
    required this.onBack,
  });

  final SamplePerson person;
  final Compliment compliment;
  final VoidCallback onBack;

  @override
  ConsumerState<ComplimentThread> createState() => _ComplimentThreadState();
}

class _ComplimentThreadState extends ConsumerState<ComplimentThread> {
  final _reply = TextEditingController();

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  void _send() {
    final ok = ref
        .read(complimentsProvider.notifier)
        .reply(widget.compliment.id, _reply.text);
    if (!ok) return;
    AppHaptics.fire(context, HapticMoment.success);
    // The chat route now has a thread: ChatScreen rebuilds into the conversation in place.
  }

  Future<void> _menu() async {
    final l10n = context.l10n;
    final person = widget.person;
    final received = !widget.compliment.fromMe;
    final choice = await showNumayaActionSheet(
      context: context,
      cancelLabel: l10n.cancel,
      actions: [
        (
          icon: NumayaIcons.user,
          label: l10n.requestViewProfile,
          destructive: false,
        ),
        if (received)
          (
            icon: NumayaIcons.close,
            label: l10n.complimentNotNow,
            destructive: false,
          ),
        (icon: NumayaIcons.flag, label: l10n.optionReport, destructive: true),
        (
          icon: NumayaIcons.block,
          label: l10n.optionBlock(person.name),
          destructive: true,
        ),
      ],
    );
    if (!mounted || choice == null) return;
    final action = received ? choice : (choice == 0 ? 0 : choice + 1);
    switch (action) {
      case 0:
        await context.push('${Routes.person}/${person.id}');
      case 1:
        final done = await confirmComplimentDismiss(
          context,
          ref,
          widget.compliment,
          person,
        );
        if (done && mounted) widget.onBack();
      case 2:
        final done = await showReportSheet(context, ref, person);
        if (done == true && mounted) widget.onBack();
      default:
        final done = await showBlockSheet(context, ref, person);
        if (done == true && mounted) widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.compliment;
    final person = widget.person;
    final now = ref.read(clockProvider)();
    final received = !c.fromMe;
    // The quoted thing: your photo or prompt when it was sent to you, theirs when you sent it.
    final owner = received ? ref.watch(ownProfilePersonProvider) : person;
    final onPhoto = c.target.kind == ComplimentTargetKind.photo;
    final prompt = onPhoto ? null : promptAt(owner, c.target.index);
    final quoteAuthor = switch ((received, onPhoto)) {
      (true, true) => l10n.v8ComplimentOnYourPhoto,
      (true, false) => l10n.v8ComplimentOnYourPrompt,
      (false, true) => l10n.v8ComplimentOnTheirPhoto,
      (false, false) => l10n.v8ComplimentOnTheirPrompt,
    };
    final quoteText = !c.referenceAvailable
        ? l10n.chatQuoteUnavailable
        : onPhoto
        ? l10n.v8ComplimentPhotoNumber(c.target.index + 1)
        : (prompt?.question ?? '');
    final thumbnail = onPhoto && c.referenceAvailable
        ? ClipRRect(
            borderRadius: AppRadii.all(AppRadii.tag),
            child: SizedBox(
              width: 36,
              height: 48,
              child: personPhotoImage(owner, c.target.index + 1),
            ),
          )
        : null;

    final thread = ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenGutter,
        AppSpacing.s4,
        AppLayout.screenGutter,
        AppSpacing.s4,
      ),
      children: [
        ChatSystemLine(
          received
              ? l10n.v8ComplimentFrom(person.name)
              : l10n.v8ComplimentYouSent(person.name),
        ),
        ChatSystemLine(dayLine(l10n, c.sentAt, now)),
        Semantics(
          label: received
              ? l10n.chatTheirMessageLabel(person.name, c.text)
              : c.text,
          child: ExcludeSemantics(
            child: MessageBubble(
              key: const ValueKey('compliment-bubble'),
              text: c.text,
              mine: !received,
              replyAuthor: quoteAuthor,
              replyText: quoteText,
              replyThumbnail: thumbnail,
              time: DateFormat('HH:mm').format(c.sentAt),
            ),
          ),
        ),
        if (!received) ...[
          const SizedBox(height: AppSpacing.s6),
          const Center(child: SceneArt(ArtScene.waiting, width: 140)),
          const SizedBox(height: AppSpacing.s3),
          Text(
            l10n.v8ComplimentWaiting(person.name),
            textAlign: TextAlign.center,
            style: AppTypography.emptyTitle,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            l10n.complimentSentBody(person.name),
            textAlign: TextAlign.center,
            style: AppTypography.helper,
          ),
        ],
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            ChatHeader(person: person, onBack: widget.onBack, onMenu: _menu),
            // The header's bottom edge: full bleed, like the chat's.
            const NumayaDivider(margin: 0),
            Expanded(child: thread),
            if (received)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenGutter,
                  AppSpacing.s2,
                  AppLayout.screenGutter,
                  AppSpacing.s3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Composer(
                      key: const ValueKey('compliment-reply-composer'),
                      controller: _reply,
                      placeholder: l10n.v8ReplyPrivately,
                      sendLabel: l10n.chatSend,
                      onSend: (_) => _send(),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      l10n.requestReplyHint,
                      textAlign: TextAlign.center,
                      style: AppTypography.micro,
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
