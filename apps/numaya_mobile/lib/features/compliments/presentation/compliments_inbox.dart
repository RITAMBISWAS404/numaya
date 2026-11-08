import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/domain/sample_people.dart';
import '../../dating/presentation/person_profile.dart';
import '../../dating/presentation/time_format.dart';
import '../../lab/lab_empty_state.dart';
import '../../lab/lab_registry.dart';
import '../application/compliments_controller.dart';
import '../domain/compliment.dart';
import 'compliment_screens.dart';

/// R03: the Compliments part of the Heart tab. Pending Compliments are readable and answerable
/// for free, each on its own card (moved out of Chats). Reply opens the request page, whose reply
/// creates the one normal conversation (never a duplicate); Not now dismisses after confirming.
class ComplimentsInbox extends ConsumerWidget {
  const ComplimentsInbox({super.key, required this.requests, this.cardVariant});

  final List<Compliment> requests;

  /// A screen direction's fixed card variant; null follows the Lab's component choice.
  final String? cardVariant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (requests.isEmpty) {
      return LabEmptyState(
        key: const ValueKey('compliments-empty'),
        slot: 'compliments_empty',
        slotLabel: 'purple cat holding a small note',
        icon: NumayaMobileIcons.compliment,
        title: l10n.complimentsEmptyTitle,
        body: l10n.complimentsEmptyBody,
        actionLabel: l10n.goToHome,
        onAction: () => context.go(Routes.home),
      );
    }
    final now = ref.read(clockProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.complimentsInboxNote,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s4),
        for (final c in requests)
          if (personById(c.personId) case final p?)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s3),
              child: ComplimentCard(
                key: ValueKey('compliment-${c.id}'),
                compliment: c,
                person: p,
                now: now,
                onOpen: () => context.push('${Routes.request}/${c.id}'),
                onDismiss: () => confirmComplimentDismiss(context, ref, c, p),
                variant: cardVariant,
              ),
            ),
      ],
    );
  }
}

/// Asks before dismissing (no credit comes back to the sender; they can't send another).
Future<bool> confirmComplimentDismiss(
  BuildContext context,
  WidgetRef ref,
  Compliment c,
  SamplePerson person,
) async {
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
  if (ok != true || !context.mounted) return false;
  ref.read(complimentsProvider.notifier).dismiss(c.id);
  NumayaToast.show(context, l10n.requestDismissed);
  return true;
}

/// One incoming Compliment. Card family `compliment-card` (Visual Lab V2): O sender, quote,
/// actions; A quote-led editorial; B with what they noticed; C compact row; D photo-led. Every
/// variant names the sender, shows the words in full (150 characters at most), says what it was
/// about, and offers Reply and Not now (C opens the page that has both).
class ComplimentCard extends ConsumerWidget {
  const ComplimentCard({
    super.key,
    required this.compliment,
    required this.person,
    required this.now,
    required this.onOpen,
    required this.onDismiss,
    this.variant,
  });

  final Compliment compliment;
  final SamplePerson person;
  final DateTime now;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('compliment-card'));
    final l10n = context.l10n;
    final c = compliment;
    final onPhoto = c.target.kind == ComplimentTargetKind.photo;
    final about = onPhoto ? l10n.requestOnYourPhoto : l10n.requestOnYourPrompt;
    final time = shortTime(l10n, c.sentAt, now);
    final own = ref.watch(ownProfilePersonProvider);
    final prompt = onPhoto ? null : promptAt(own, c.target.index);

    Widget name(TextStyle style) => NameWithBadge(
      name: l10n.profileNameAge(person.name, person.age),
      verified: person.verified,
      verifiedLabel: l10n.photoVerifiedLabel,
      style: style,
    );
    final nameStyle = AppTypography.weight(
      AppTypography.row,
      AppTypography.semibold,
    );
    Widget avatar(double size) => InitialsAvatar(
      initial: person.initial,
      size: size,
      image: personAvatarImage(person),
      imageAlignment: personAvatarFocus(person),
    );
    Widget meta() => MetaText(
      [about, time].join(MetaText.joiner),
      style: AppTypography.caption,
    );
    Widget words({TextStyle? style}) =>
        Text(c.text, style: style ?? AppTypography.answer);
    Widget actions() => NumayaButtonGroup(
      children: [
        NumayaButton(
          expand: true,
          key: ValueKey('compliment-dismiss-${c.id}'),
          label: l10n.complimentNotNow,
          small: true,
          variant: NumayaButtonVariant.secondary,
          onPressed: onDismiss,
        ),
        NumayaButton(
          expand: true,
          key: ValueKey('compliment-reply-${c.id}'),
          label: l10n.complimentReply,
          small: true,
          onPressed: onOpen,
        ),
      ],
    );
    // What they noticed: a thumbnail of your photo, or your prompt's question.
    Widget noticed({double width = 64}) => onPhoto
        ? ClipRRect(
            borderRadius: AppRadii.all(AppRadii.tile),
            child: SizedBox(
              width: width,
              child: PhotoPlaceholder(
                label: about,
                aspectRatio: AppMedia.personPhoto,
                child: personPhotoImage(own, c.target.index + 1),
              ),
            ),
          )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s3),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: AppRadii.all(AppRadii.tile),
            ),
            child: Text(
              prompt?.question ?? about,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
    BoxDecoration card() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.card),
    );
    const pad = EdgeInsets.all(AppLayout.cardPadding);

    switch (v) {
      case 'A':
        return Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Text(
                  '“',
                  style: AppTypography.hero.copyWith(
                    color: AppColors.accent,
                    height: 0.8,
                  ),
                ),
              ),
              words(
                style: AppTypography.weight(
                  AppTypography.answer,
                  AppTypography.semibold,
                ).copyWith(fontSize: 20, height: 28 / 20),
              ),
              const SizedBox(height: AppSpacing.s4),
              Row(
                children: [
                  avatar(32),
                  const SizedBox(width: AppSpacing.s2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [name(nameStyle), meta()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
              actions(),
            ],
          ),
        );
      case 'B':
        return Container(
          padding: pad,
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  avatar(40),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(child: name(nameStyle)),
                  Text(time, style: AppTypography.micro),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              Text(about, style: AppTypography.labelCaps),
              const SizedBox(height: AppSpacing.s2),
              if (onPhoto)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    noticed(width: 72),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(child: words()),
                  ],
                )
              else ...[
                noticed(),
                const SizedBox(height: AppSpacing.s3),
                words(),
              ],
              const SizedBox(height: AppSpacing.s4),
              actions(),
            ],
          ),
        );
      case 'C':
        return Pressable(
          onTap: onOpen,
          semanticLabel: [
            l10n.requestRowCompliment(person.name),
            c.text,
            about,
            time,
          ].join('. '),
          excludeChildSemantics: true,
          pressedScale: 1,
          borderRadius: AppRadii.all(AppRadii.card),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.cardPadding,
              vertical: AppSpacing.s3,
            ),
            decoration: card(),
            child: Row(
              children: [
                avatar(48),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      name(nameStyle),
                      const SizedBox(height: 2),
                      Text(
                        c.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      meta(),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                const NumayaIcon(
                  NumayaIcons.chevronRight,
                  size: 18,
                  color: AppColors.iconSupporting,
                ),
              ],
            ),
          ),
        );
      case 'D':
        return ClipRRect(
          borderRadius: AppRadii.all(AppRadii.card),
          child: ColoredBox(
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: PhotoPlaceholder(
                    label: l10n.discoverPhotoLabel(person.name, 1),
                    aspectRatio: 16 / 10,
                    child: personPhotoImage(person, 1),
                  ),
                ),
                Padding(
                  padding: pad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      name(AppTypography.card),
                      meta(),
                      const SizedBox(height: AppSpacing.s3),
                      words(),
                      const SizedBox(height: AppSpacing.s4),
                      actions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        // Owner selection O with notes: no Reply / Not now buttons here; the whole card opens the
        // request page (what they noticed, reply, dismiss, report, block). Opening it accepts
        // nothing and sends nothing.
        return Pressable(
          onTap: onOpen,
          semanticLabel: [
            l10n.requestRowCompliment(person.name),
            c.text,
            about,
            time,
          ].join('. '),
          excludeChildSemantics: true,
          pressedScale: 1,
          borderRadius: AppRadii.all(AppRadii.card),
          child: Container(
            padding: pad,
            decoration: card(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          avatar(48),
                          const SizedBox(width: AppSpacing.s3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [name(nameStyle), meta()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      words(),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                const NumayaIcon(
                  NumayaIcons.chevronRight,
                  size: 18,
                  color: AppColors.iconSupporting,
                ),
              ],
            ),
          ),
        );
    }
  }
}
