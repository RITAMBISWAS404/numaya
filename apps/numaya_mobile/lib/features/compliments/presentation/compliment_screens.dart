import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';
import '../../dating/domain/sample_people.dart';
import '../../dating/presentation/person_profile.dart';
import '../../dating/presentation/safety_sheets.dart';
import '../../dating/presentation/time_format.dart';
import '../../lab/lab_registry.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../profile/presentation/own_profile.dart';
import '../application/compliments_controller.dart';
import '../domain/compliment.dart';

/// The member's own profile as others see it (the recipient's side of a request quotes it).
final ownProfilePersonProvider = Provider<SamplePerson>(
  (ref) => memberAsPerson(
    draft: ref.watch(onboardingProvider.select((s) => s.draft)),
    details: ref.watch(profileDetailsProvider),
    today: ref.read(clockProvider)(),
    verified: false,
  ),
);

/// The route to compose a Compliment on [personId]'s photo or prompt at [index] (0-based).
String complimentRoute(String personId, ComplimentTarget target) =>
    '${Routes.compliment}/$personId?kind=${target.kind.name}&index=${target.index}';

ComplimentTarget parseComplimentTarget(Map<String, String> q) {
  final index = int.tryParse(q['index'] ?? '') ?? 0;
  return q['kind'] == ComplimentTargetKind.prompt.name
      ? ComplimentTarget.prompt(index)
      : ComplimentTarget.photo(index);
}

/// Opens the composer for a target: a page, or a sheet over the profile in the sheet direction.
Future<void> openCompliment(
  BuildContext context,
  WidgetRef ref,
  String personId,
  ComplimentTarget target,
) async {
  final person = personById(personId);
  if (ref.read(labVariantProvider('v7-compliment')) == 'B' && person != null) {
    await showNumayaSheet<void>(
      context: context,
      title: context.l10n.complimentTitle(person.name),
      closeLabel: context.l10n.close,
      builder: (_) => ComplimentComposerScreen(
        personId: personId,
        target: target,
        embedded: true,
      ),
    );
    return;
  }
  await context.push(complimentRoute(personId, target));
}

/// The prompt at [index] on [person] (0: the main prompt, then the extra prompts).
({String question, String answer})? promptAt(SamplePerson person, int index) {
  final all = [?person.prompt, ...person.morePrompts];
  return index < all.length ? all[index] : null;
}

/// The referenced photo or prompt, as quoted above a Compliment.
class ComplimentReference extends StatelessWidget {
  const ComplimentReference({
    super.key,
    required this.person,
    required this.target,
    this.available = true,
    this.yours = false,
  });

  final SamplePerson person;
  final ComplimentTarget target;
  final bool available;

  /// The recipient's view: "On your photo".
  final bool yours;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prompt = target.kind == ComplimentTargetKind.prompt
        ? promptAt(person, target.index)
        : null;
    final photoExists =
        target.kind == ComplimentTargetKind.photo &&
        target.index < person.photoCount;
    if (!available || (prompt == null && !photoExists)) {
      return StatusBanner(title: l10n.complimentReferenceGone);
    }
    final caption = target.kind == ComplimentTargetKind.photo
        ? (yours ? l10n.requestOnYourPhoto : l10n.complimentOnPhoto)
        : (yours ? l10n.requestOnYourPrompt : l10n.complimentOnPrompt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(caption, style: AppTypography.labelCaps),
        const SizedBox(height: AppSpacing.s2),
        if (prompt != null)
          PromptCard(question: prompt.question, answer: prompt.answer)
        else
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 120,
              child: PhotoPlaceholder(
                label: l10n.discoverPhotoLabel(person.name, target.index + 1),
                aspectRatio: AppMedia.personPhoto,
                child: personPhotoImage(person, target.index + 1),
              ),
            ),
          ),
      ],
    );
  }
}

/// Direction A: the photo or prompt fills the width, so the member writes looking at it.
class ComplimentContextHero extends StatelessWidget {
  const ComplimentContextHero({
    super.key,
    required this.person,
    required this.target,
  });

  final SamplePerson person;
  final ComplimentTarget target;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prompt = target.kind == ComplimentTargetKind.prompt
        ? promptAt(person, target.index)
        : null;
    if (prompt != null) {
      return PromptCard(question: prompt.question, answer: prompt.answer);
    }
    return PhotoPlaceholder(
      label: l10n.discoverPhotoLabel(person.name, target.index + 1),
      aspectRatio: 1,
      child: personPhotoImage(person, target.index + 1),
    );
  }
}

/// The exact photo or prompt a Compliment is about, as one compact row: words first, then the
/// picture at the end of the line, so the field or message below keeps the emphasis.
class ComplimentContextRow extends StatelessWidget {
  const ComplimentContextRow({
    super.key,
    required this.person,
    required this.target,
    this.available = true,
    this.yours = false,
  });

  final SamplePerson person;
  final ComplimentTarget target;
  final bool available;
  final bool yours;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPrompt = target.kind == ComplimentTargetKind.prompt;
    final prompt = isPrompt ? promptAt(person, target.index) : null;
    final exists = isPrompt ? prompt != null : target.index < person.photoCount;
    if (!available || !exists) {
      return Text(
        l10n.complimentReferenceGone,
        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
      );
    }
    final caption = isPrompt
        ? (yours ? l10n.requestOnYourPrompt : l10n.complimentOnPrompt)
        : (yours ? l10n.requestOnYourPhoto : l10n.complimentOnPhoto);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prompt == null ? caption : '$caption · ${prompt.question}',
                style: AppTypography.helper,
              ),
              if (prompt != null) ...[
                const SizedBox(height: AppLayout.metaGap),
                Text(
                  prompt.answer,
                  style: AppTypography.weight(
                    AppTypography.body,
                    AppTypography.semibold,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isPrompt) ...[
          const SizedBox(width: AppSpacing.s3),
          ClipRRect(
            borderRadius: AppRadii.all(AppRadii.tile),
            child: SizedBox(
              width: 56,
              child: PhotoPlaceholder(
                label: l10n.discoverPhotoLabel(person.name, target.index + 1),
                aspectRatio: AppMedia.personPhoto,
                child: personPhotoImage(person, target.index + 1),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// S14: write a Compliment of up to 150 characters on one photo or prompt. Shows the credit
/// balance; with none, the button opens the Compliment pack. Sends once (the button locks while
/// sending); closing the page spends nothing.
class ComplimentComposerScreen extends ConsumerStatefulWidget {
  const ComplimentComposerScreen({
    super.key,
    required this.personId,
    required this.target,
    this.embedded = false,
  });

  final String personId;
  final ComplimentTarget target;

  /// Drawn inside a sheet rather than as a page.
  final bool embedded;

  @override
  ConsumerState<ComplimentComposerScreen> createState() =>
      _ComplimentComposerScreenState();
}

class _ComplimentComposerScreenState
    extends ConsumerState<ComplimentComposerScreen> {
  final _text = TextEditingController();
  bool _sending = false;
  bool _failed = false;
  bool _sent = false;

  bool get _dirty => !_sent && _text.text.trim().isNotEmpty;

  void _leave() {
    if (widget.embedded) {
      Navigator.of(context).pop();
    } else {
      context.pop();
    }
  }

  void _useOpener(String text) {
    _text.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// A page, or plain content inside the sheet (which has its own title and close).
  Widget _frame({
    required Widget top,
    required Widget footer,
    required Widget body,
  }) {
    if (!widget.embedded) {
      return NumayaScreen(top: top, footer: footer, body: body);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: SingleChildScrollView(child: body)),
        const SizedBox(height: AppSpacing.s4),
        footer,
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// Leaving with words written asks first; nothing has been spent either way.
  Future<void> _close() async {
    if (!_dirty) {
      _leave();
      return;
    }
    final l10n = context.l10n;
    final discard = await showNumayaSheet<bool>(
      context: context,
      title: l10n.complimentDiscardTitle,
      closeLabel: l10n.close,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.complimentDiscardBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            label: l10n.complimentKeepWriting,
            onPressed: () => Navigator.of(sheet).pop(false),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            key: const ValueKey('compliment-discard'),
            label: l10n.complimentDiscard,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => Navigator.of(sheet).pop(true),
          ),
        ],
      ),
    );
    if (discard == true && mounted) _leave();
  }

  Future<void> _send(SamplePerson person) async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _failed = false;
    });
    final prompt = widget.target.kind == ComplimentTargetKind.prompt
        ? promptAt(person, widget.target.index)
        : null;
    final result = await ref
        .read(complimentsProvider.notifier)
        .send(
          personId: person.id,
          target: widget.target,
          text: _text.text,
          referenceText: prompt == null
              ? null
              : '${prompt.question}: ${prompt.answer}',
        );
    if (!mounted) return;
    setState(() => _sending = false);
    switch (result) {
      case ComplimentSendResult.sent:
        AppHaptics.fire(context, HapticMoment.success);
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() => _sent = true);
      case ComplimentSendResult.insufficientCredits:
        await context.push(Routes.storeCompliments);
      case ComplimentSendResult.failed:
        setState(() => _failed = true);
      case ComplimentSendResult.invalid || ComplimentSendResult.notAllowed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final person = personById(widget.personId);
    final balance = ref.watch(creditBalanceProvider);
    ref.watch(complimentsProvider);
    final controller = ref.read(complimentsProvider.notifier);
    final top = NumayaTopBar(
      onBack: _close,
      backLabel: l10n.close,
      closeIcon: true,
    );
    if (person == null) {
      return NumayaScreen(
        top: top,
        body: EmptyState(
          title: l10n.complimentUnavailable,
          body: l10n.requestGone,
        ),
      );
    }
    final v7 = ref.watch(labVariantProvider('v7-compliment'));
    final max = controller.maxLength;
    final block = controller.blockFor(person.id);
    final problem = complimentProblem(_text.text, max);
    final used = complimentLength(_text.text);
    final blockText = switch (block) {
      ComplimentBlock.alreadySent => l10n.complimentAlreadySent(person.name),
      ComplimentBlock.alreadyReceived => l10n.complimentAlreadyReceived(
        person.name,
      ),
      ComplimentBlock.connected => l10n.complimentConnected(person.name),
      ComplimentBlock.unavailable => l10n.complimentUnavailable,
      null => null,
    };
    if (_sent) {
      return _frame(
        top: NumayaTopBar(
          onBack: _leave,
          backLabel: l10n.close,
          closeIcon: true,
        ),
        footer: NumayaButton(
          key: const ValueKey('compliment-done'),
          label: l10n.done,
          onPressed: _leave,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s4),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const NumayaIcon(
                  NumayaIcons.check,
                  size: AppSizes.iconMd,
                  color: AppColors.accentForeground,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            ScreenHeader(
              title: l10n.complimentSentTitle,
              lede: l10n.complimentSentBody(person.name),
            ),
            const SizedBox(height: AppSpacing.s5),
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ComplimentContextRow(person: person, target: widget.target),
                  const SizedBox(height: AppSpacing.s3),
                  Text(_text.text.trim(), style: AppTypography.cardPrimary),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final Widget footer;
    if (blockText != null) {
      footer = NumayaButton(label: l10n.done, onPressed: () => context.pop());
    } else if (balance <= 0) {
      footer = NumayaButton(
        label: l10n.complimentGetMore,
        onPressed: () => context.push(Routes.storeCompliments),
      );
    } else {
      footer = NumayaButton(
        key: const ValueKey('compliment-send'),
        label: l10n.complimentSend,
        loading: _sending,
        onPressed: problem == null && !_sending ? () => _send(person) : null,
      );
    }
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: _frame(
        top: top,
        footer: footer,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.embedded) ...[
              const SizedBox(height: AppSpacing.s4),
              ScreenHeader(
                title: v7 == 'C'
                    ? l10n.v7ComplimentWarmTitle(person.name)
                    : l10n.complimentTitle(person.name),
              ),
              const SizedBox(height: AppSpacing.s4),
            ],
            if (v7 == 'A')
              ComplimentContextHero(person: person, target: widget.target)
            else
              WhiteCard(
                child: ComplimentContextRow(
                  person: person,
                  target: widget.target,
                ),
              ),
            const SizedBox(height: AppSpacing.s4),
            if (blockText != null)
              StatusBanner(title: blockText)
            else ...[
              if (_failed) ...[
                StatusBanner(
                  tone: BannerTone.error,
                  title: l10n.complimentFailedTitle,
                  body: l10n.complimentFailedBody,
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
              NumayaTextField(
                key: const ValueKey('compliment-field'),
                label: l10n.complimentFieldLabel,
                placeholder: l10n.complimentPlaceholder,
                controller: _text,
                maxLength: max,
                multiline: true,
                autofocus: balance > 0,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_sending,
                error: problem == ComplimentProblem.tooLong
                    ? l10n.complimentTooLong(max)
                    : null,
                trailingNote: l10n.complimentCounter(used, max),
              ),
              if (v7 == 'C' && _text.text.isEmpty) ...[
                const SizedBox(height: AppSpacing.s3),
                Wrap(
                  spacing: AppSpacing.s2,
                  runSpacing: AppSpacing.s2,
                  children: [
                    for (final opener in [
                      if (widget.target.kind == ComplimentTargetKind.photo) ...[
                        l10n.v7OpenerStory,
                        l10n.v7OpenerWhere,
                      ] else ...[
                        l10n.v7OpenerPromptStory,
                        l10n.v7OpenerPromptSame,
                      ],
                      l10n.v7OpenerMore,
                    ])
                      NumayaChip(
                        label: opener,
                        selected: false,
                        onTap: () => _useOpener(opener),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.s2),
              Text(
                '${l10n.complimentBalance(balance)} ${l10n.complimentRule(person.name)}',
                style: AppTypography.helper,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// S21: one Compliment request. Reply (free) opens the conversation; dismiss, view profile,
/// report or block. Never says who else saw it.
class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key, required this.complimentId});

  final String complimentId;

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final _reply = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reply.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _dismiss(SamplePerson person) async {
    final l10n = context.l10n;
    final ok = await showNumayaSheet<bool>(
      context: context,
      title: l10n.requestDismissTitle,
      closeLabel: l10n.close,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.requestDismissBody(person.name),
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            key: const ValueKey('dismiss-confirm'),
            label: l10n.requestDismiss,
            variant: NumayaButtonVariant.destructiveSolid,
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
    if (ok != true || !mounted) return;
    ref.read(complimentsProvider.notifier).dismiss(widget.complimentId);
    context.pop();
    NumayaToast.show(context, l10n.requestDismissed);
  }

  Future<void> _options(SamplePerson person) async {
    final l10n = context.l10n;
    final choice = await showNumayaActionSheet(
      context: context,
      cancelLabel: l10n.cancel,
      actions: [
        (icon: NumayaIcons.flag, label: l10n.optionReport, destructive: true),
        (
          icon: NumayaIcons.block,
          label: l10n.optionBlock(person.name),
          destructive: true,
        ),
      ],
    );
    if (!mounted || choice == null) return;
    final done = choice == 0
        ? await showReportSheet(context, ref, person)
        : await showBlockSheet(context, ref, person);
    if (done == true && mounted && context.canPop()) context.pop();
  }

  void _send(SamplePerson person) {
    final ok = ref
        .read(complimentsProvider.notifier)
        .reply(widget.complimentId, _reply.text);
    if (!ok) return;
    AppHaptics.fire(context, HapticMoment.success);
    context.pushReplacement('${Routes.chat}/${person.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(complimentsProvider);
    final c = ref.read(complimentsProvider.notifier).byId(widget.complimentId);
    final person = c == null ? null : personById(c.personId);
    final top = NumayaTopBar(
      onBack: () => context.pop(),
      backLabel: l10n.back,
      title: l10n.requestTitle,
      actions: [
        if (person != null && c?.status == ComplimentStatus.pending)
          NavIconButton(
            icon: NumayaIcons.more,
            label: l10n.discoverOptions,
            onPressed: () => _options(person),
          ),
      ],
    );
    if (c == null ||
        person == null ||
        c.status != ComplimentStatus.pending ||
        !ref.read(datingProvider).isActive(person.id)) {
      return NumayaScreen(
        top: top,
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s10),
          child: EmptyState(title: l10n.requestGone, body: ''),
        ),
      );
    }
    final now = ref.read(clockProvider)();
    final requestV = ref.watch(labVariantProvider('v7-request'));
    return NumayaScreen(
      top: top,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Composer(
            controller: _reply,
            placeholder: l10n.requestReplyLabel,
            sendLabel: l10n.chatSend,
            onSend: (_) => _send(person),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            l10n.requestReplyHint,
            textAlign: TextAlign.center,
            style: AppTypography.micro,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Row(
            children: [
              InitialsAvatar(
                initial: person.initial,
                size: 48,
                image: personAvatarImage(person),
                imageAlignment: personAvatarFocus(person),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${person.name}, ${person.age}',
                      style: AppTypography.card,
                    ),
                    if (person.lookingFor != null)
                      Text(person.lookingFor!, style: AppTypography.helper),
                  ],
                ),
              ),
              Text(shortTime(l10n, c.sentAt, now), style: AppTypography.helper),
            ],
          ),
          const SizedBox(height: AppSpacing.s5),
          if (requestV == 'B') ...[
            PhotoPlaceholder(
              label: l10n.discoverPhotoLabel(person.name, 1),
              aspectRatio: 4 / 3,
              child: personPhotoImage(person, 1),
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          if (requestV == 'A')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
              child: Text(c.text, style: AppTypography.headline),
            ),
          if (requestV == 'A')
            WhiteCard(
              child: ComplimentContextRow(
                person: ref.watch(ownProfilePersonProvider),
                target: c.target,
                available: c.referenceAvailable,
                yours: true,
              ),
            )
          else
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(c.text, style: AppTypography.cardPrimary),
                  const SizedBox(height: AppSpacing.s3),
                  ComplimentContextRow(
                    person: ref.watch(ownProfilePersonProvider),
                    target: c.target,
                    available: c.referenceAvailable,
                    yours: true,
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.s4),
          NumayaButtonGroup(
            children: [
              NumayaButton(
                expand: true,
                label: l10n.requestViewProfile,
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => context.push('${Routes.person}/${person.id}'),
              ),
              NumayaButton(
                expand: true,
                key: const ValueKey('request-dismiss'),
                label: l10n.requestDismiss,
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => _dismiss(person),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
