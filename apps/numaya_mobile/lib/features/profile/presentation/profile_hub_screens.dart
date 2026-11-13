import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/presentation/person_profile.dart';
import '../../lab/stat_templates.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../verification/application/verification_controller.dart';
import '../application/profile_details_controller.dart';
import '../domain/profile_details.dart';
import 'own_profile.dart';
import 'profile_editors.dart';

/// Profile completion hub (B-21, Mobbin "Completing a profile"): the percentage and one tile per
/// part, each opening its editor. Computed only from what the member entered.
class CompletionHubScreen extends ConsumerWidget {
  const CompletionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final details = ref.watch(profileDetailsProvider);
    final c = ProfileCompletion.of(draft, details);

    Future<void> editBio() async {
      final value = await showTextEditSheet(
        context,
        title: l10n.editBio,
        initial: details.bio,
        maxLength: DetailRules.bioLength,
        multiline: true,
        hint: l10n.editBioPlaceholder,
        tip: l10n.editBioTip,
      );
      if (value == null) return;
      ref.read(profileDetailsProvider.notifier).setBio(value);
      if (context.mounted) NumayaToast.show(context, l10n.editSaved);
    }

    final tiles = [
      (
        NumayaIcons.camera,
        l10n.completionPhotos,
        c.photos,
        () => context.push(Routes.editProfile),
      ),
      (
        NumayaIcons.message,
        l10n.completionPrompts,
        c.prompts,
        () => context.push(
          c.prompts.done == 0
              ? Routes.editPrompt
              : '${Routes.editPrompt}?slot=${(c.prompts.done).clamp(1, 2)}',
        ),
      ),
      (
        NumayaIcons.interests,
        l10n.completionInterests,
        c.interests,
        () => context.push(Routes.editInterests),
      ),
      (NumayaIcons.edit, l10n.completionBio, c.bio, editBio),
      (
        NumayaIcons.user,
        l10n.completionAbout,
        c.about,
        () => context.push(Routes.editProfile),
      ),
      (
        NumayaIcons.tag,
        l10n.completionMore,
        c.moreAbout,
        () => context.push(Routes.editProfile),
      ),
    ];

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.completionTitle,
      ),
      // UI-046: one summary card (a small muted label, the percentage as the large number, the
      // bar, one line of encouragement), then the six parts as one list card. Each row names the
      // part, gives its count in muted metadata (UI-045) and opens its editor; finished parts say
      // Done. One column keeps every label whole at 320pt and 200% text, which the two-column
      // grid could not. References: Bumble's and happn's completion pages on Mobbin, Ente Menu
      // Item rows.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          // UI-078 review: a chosen statistics template replaces the summary card.
          if (chosenStatTemplate(ref) != null)
            StatCard(
              key: const ValueKey('completion-stat'),
              data: statFamily(ref, l10n).completion,
              template: chosenStatTemplate(ref)!,
            )
          else
            Container(
              padding: const EdgeInsets.all(AppLayout.heroPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.all(AppRadii.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.completionYourProfile,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Semantics(
                    header: true,
                    label: l10n.completionPercent(c.percent),
                    excludeSemantics: true,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${c.percent}%',
                            style: AppTypography.metric,
                          ),
                          TextSpan(
                            text: '  ${l10n.completionUnit}',
                            style: AppTypography.metricUnit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  ClipRRect(
                    borderRadius: AppRadii.all(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: c.percent / 100,
                      minHeight: 8,
                      color: AppColors.accent,
                      backgroundColor: AppColors.fill,
                      semanticsLabel: l10n.completionPercent(c.percent),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    c.percent >= 100
                        ? l10n.completionDone
                        : l10n.completionLede,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            children: [
              for (final (icon, title, part, onTap) in tiles)
                ListRow(
                  key: ValueKey('completion-$title'),
                  leading: icon,
                  label: title,
                  detail: l10n.completionProgress(
                    part.done.clamp(0, part.total),
                    part.total,
                  ),
                  value: part.complete ? l10n.completionPartDone : null,
                  onTap: onTap,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
      ),
    );
  }
}

/// The member's profile as other people see it (V16 106 "Preview").
class ProfilePreviewScreen extends ConsumerWidget {
  const ProfilePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final details = ref.watch(profileDetailsProvider);
    final verified = ref.watch(photoVerificationProvider).verified;
    final me = memberAsPerson(
      draft: draft,
      details: details,
      today: ref.read(onboardingProvider.notifier).today,
      verified: verified,
    );
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.previewTitle,
      ),
      footer: NumayaButton(
        label: l10n.previewEdit,
        variant: NumayaButtonVariant.secondary,
        onPressed: () => context.pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s2),
          InfoCard(
            icon: NumayaIcons.public,
            title: l10n.previewInfoTitle,
            body: l10n.previewInfoBody,
          ),
          const SizedBox(height: AppSpacing.s3),
          // UI-058: the owner preview is the public profile: the same photo card with the
          // name and identity on the main photo over the shared gradient.
          PersonHeroCard(
            person: me,
            own: true,
            showAge: details.showAge,
            photoHeight: 0,
          ),
          const SizedBox(height: AppSpacing.s3),
          ...personSections(context, me, own: true, showDistance: false),
        ],
      ),
    );
  }
}

/// Your Opening Moves (B-27, Mobbin "Adding an opening move"): up to three questions new matches
/// can answer. Each opens an editor with a 160-character limit; suggestions help start.
class OpeningMovesScreen extends ConsumerWidget {
  const OpeningMovesScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    int index,
    String initial,
  ) async {
    final l10n = context.l10n;
    final value = await showNumayaSheet<String>(
      context: context,
      title: l10n.openingMoveEditTitle,
      closeLabel: l10n.cancel,
      builder: (context) => _MoveEditor(initial: initial),
    );
    if (value == null || !context.mounted) return;
    ref.read(profileDetailsProvider.notifier).setOpeningMove(index, value);
    NumayaToast.show(
      context,
      value.isEmpty ? l10n.openingMoveRemoved : l10n.editSaved,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final moves = ref.watch(profileDetailsProvider).openingMoves;
    final ordinals = [
      l10n.openingMoveFirst,
      l10n.openingMoveSecond,
      l10n.openingMoveThird,
    ];
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.openingMovesTitle,
      ),
      footer: NumayaButton(label: l10n.done, onPressed: () => context.pop()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          const IllustrationSlot(
            slot: 'opening_moves_header',
            label: 'Start a new conversation',
            aspectRatio: IllustrationSlot.header,
          ),
          // The header already says "Opening Moves"; the page heading repeating it is gone (ER
          // content pass). The lede stays: it says what an Opening Move is.
          Text(
            l10n.openingMovesLede,
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.s4),
          for (var i = 0; i < DetailRules.maxOpeningMoves; i++) ...[
            if (i < moves.length)
              PromptCard(
                question: ordinals[i],
                answer: moves[i],
                editLabel: l10n.promptEditLabel,
                onTap: () => _edit(context, ref, i, moves[i]),
              )
            else
              ListGroup(
                children: [
                  ListRow(
                    label: ordinals[i],
                    value: i == moves.length ? l10n.editAdd : null,
                    onTap: i == moves.length
                        ? () => _edit(context, ref, i, '')
                        : null,
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.s3),
          ],
        ],
      ),
    );
  }
}

class _MoveEditor extends StatefulWidget {
  const _MoveEditor({required this.initial});
  final String initial;

  @override
  State<_MoveEditor> createState() => _MoveEditorState();
}

class _MoveEditorState extends State<_MoveEditor> {
  late final _text = TextEditingController(text: widget.initial)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = _text.text.trim();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NumayaTextField(
            label: l10n.openingMoveLabel,
            controller: _text,
            multiline: true,
            maxLength: DetailRules.openingMoveLength,
            placeholder: kOpeningMoveSuggestions.first,
            textCapitalization: TextCapitalization.sentences,
            trailingNote: l10n.promptCharsLeft(
              DetailRules.openingMoveLength - _text.text.length,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          FieldLabel(l10n.openingMoveSuggestions),
          const SizedBox(height: AppSpacing.s2),
          for (final s in kOpeningMoveSuggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s2),
              child: Pressable(
                onTap: () => _text.value = TextEditingValue(
                  text: s,
                  selection: TextSelection.collapsed(offset: s.length),
                ),
                semanticLabel: s,
                excludeChildSemantics: true,
                pressedScale: 0.99,
                borderRadius: AppRadii.all(AppRadii.card),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s3),
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    borderRadius: AppRadii.all(AppRadii.card),
                  ),
                  child: Text(s, style: AppTypography.bodySm),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s4),
          NumayaButton(
            label: l10n.save,
            onPressed: text.isEmpty || text == widget.initial.trim()
                ? null
                : () => Navigator.of(context).pop(text),
          ),
          if (widget.initial.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              label: l10n.openingMoveRemove,
              variant: NumayaButtonVariant.destructive,
              onPressed: () => Navigator.of(context).pop(''),
            ),
          ],
        ],
      ),
    );
  }
}
