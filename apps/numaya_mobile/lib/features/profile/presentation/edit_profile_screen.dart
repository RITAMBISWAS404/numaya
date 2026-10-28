import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../../onboarding/presentation/photo_options.dart';
import '../../verification/application/verification_controller.dart';
import '../application/profile_details_controller.dart';
import '../domain/profile_details.dart';
import 'profile_editors.dart';

/// B-24 Edit profile in V16's layout (screenshot 102-edit-profile), extended with the reference's
/// long scroll (Mobbin "Editing my profile"): photos, verification, prompts (up to three), bio,
/// interests and basics, About you, More about you, languages and Opening Moves. Each change saves
/// at once (B-25); the header's Preview shows the profile as others see it (V16 106).
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final details = ref.watch(profileDetailsProvider);
    final detailsController = ref.read(profileDetailsProvider.notifier);
    final verification = ref.watch(photoVerificationProvider).status;
    final age = draft.ageOn(controller.today);

    Future<void> changePhotos(VoidCallback change) async {
      change();
      await controller.saveEdits();
    }

    void saved() => NumayaToast.show(context, l10n.editSaved);

    Future<void> editAbout(AboutKey key) async {
      final value = await showTextEditSheet(
        context,
        title: key.label,
        initial: details.about[key] ?? '',
        maxLength: AboutKey.maxLength,
        hint: key.hint,
      );
      if (value == null) return;
      detailsController.setAbout(key, value);
      saved();
    }

    Future<void> editDetail(DetailKey key) async {
      final value = await showChoiceSheet(
        context,
        title: key.label,
        legend: key.question,
        options: key.options,
        selected: details.details[key],
      );
      if (value == null) return;
      detailsController.setDetail(key, value.isEmpty ? null : value);
      saved();
    }

    final prompts = [draft.prompt, ...details.extraPrompts];
    final verificationValue = switch (verification) {
      PhotoVerificationStatus.verified => l10n.verifyStatusVerified,
      PhotoVerificationStatus.pending => l10n.verifyStatusPending,
      PhotoVerificationStatus.rejected => l10n.verifyStatusRejected,
      PhotoVerificationStatus.notStarted => l10n.verifyStatusNone,
    };
    final genderLabel = switch (draft.gender) {
      Gender.woman => l10n.genderWoman,
      Gender.man => l10n.genderMan,
      Gender.nonbinary => l10n.genderNonbinary,
      null => null,
    };

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.editTitle,
        actions: [
          NavIconButton(
            icon: NumayaIcons.public,
            label: l10n.editPreview,
            style: NavButtonStyle.plain,
            onPressed: () => context.push(Routes.preview),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          NumayaSection(
            title: l10n.editPhotosTitle,
            description: l10n.editPhotosHint,
            // V16 `.photo-grid-wrap`: the grid, then a muted note with an info icon.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PhotoGrid(
                  photos: [
                    for (final p in draft.photos)
                      GridPhoto(id: p.id, tone: p.tone),
                  ],
                  slots: ProfileRules.maxPhotos,
                  onAdd: () => changePhotos(controller.addPhoto),
                  onRemove: (id) {
                    // Keep the minimum: the last two photos can't be removed here.
                    if (draft.photos.length <= ProfileRules.minPhotos) {
                      NumayaToast.show(context, l10n.photoKeepTwo);
                      return;
                    }
                    changePhotos(() => controller.removePhoto(id));
                  },
                  onOpen: (id) async {
                    if (await showPhotoOptions(
                      context,
                      ref,
                      id,
                      keepMinimum: true,
                    )) {
                      await controller.saveEdits();
                    }
                  },
                  openLabel: l10n.photoOptionsLabel,
                  mainLabel: l10n.photosMain,
                  addLabel: l10n.photosAdd,
                  removeLabel: l10n.photosRemove,
                ),
                const SizedBox(height: AppSpacing.s3),
                Row(
                  children: [
                    const NumayaIcon(
                      NumayaIcons.info,
                      size: AppSizes.iconSm,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.editPhotosNote,
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            children: [
              ListRow(
                leading: NumayaIcons.verified,
                label: l10n.editVerify,
                value: verificationValue,
                onTap: () => context.push(Routes.verifyPhoto),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          NumayaSection(
            title: l10n.editPromptsSection,
            description: l10n.editPromptsHint(
              prompts.whereType<Object>().length,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PromptCard(
                  question: draft.prompt?.question ?? kPromptQuestions.first,
                  answer: draft.prompt?.answer,
                  emptyLabel: l10n.promptEmpty,
                  editLabel: l10n.promptEditLabel,
                  onTap: () => context.push(Routes.editPrompt),
                ),
                for (var i = 0; i < details.extraPrompts.length; i++) ...[
                  const SizedBox(height: AppSpacing.s3),
                  PromptCard(
                    question: details.extraPrompts[i].question,
                    answer: details.extraPrompts[i].answer,
                    editLabel: l10n.promptEditLabel,
                    onTap: () =>
                        context.push('${Routes.editPrompt}?slot=${i + 1}'),
                  ),
                ],
                if (details.extraPrompts.length <
                    DetailRules.maxPrompts - 1) ...[
                  const SizedBox(height: AppSpacing.s3),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: NumayaButton(
                      label: l10n.editAddPrompt,
                      small: true,
                      expand: false,
                      icon: NumayaIcons.plus,
                      variant: NumayaButtonVariant.secondary,
                      onPressed: () => context.push(
                        '${Routes.editPrompt}?slot=${details.extraPrompts.length + 1}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          NumayaSection(
            title: l10n.editBio,
            description: l10n.editBioHint,
            child: Pressable(
              onTap: () async {
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
                detailsController.setBio(value);
                saved();
              },
              semanticLabel: details.bio.isEmpty
                  ? l10n.editBioAdd
                  : '${l10n.editBio}: ${details.bio}',
              excludeChildSemantics: true,
              pressedScale: 0.99,
              borderRadius: AppRadii.all(AppRadii.card),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 88),
                padding: const EdgeInsets.all(AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.all(AppRadii.card),
                ),
                child: Text(
                  details.bio.isEmpty ? l10n.editBioAdd : details.bio,
                  style: AppTypography.body.copyWith(
                    color: details.bio.isEmpty
                        ? AppColors.textMuted
                        : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.editAboutSection,
            children: [
              ListRow(
                label: l10n.setupBasicsLabel,
                detail: age == null
                    ? draft.firstName
                    : '${draft.firstName}, $age',
                onTap: () => context.push(Routes.editBasics),
              ),
              ListRow(
                label: l10n.setupInterestsLabel,
                detail: draft.interests.join(', '),
                onTap: () => context.push(Routes.editInterests),
              ),
              for (final key in [AboutKey.work, AboutKey.school])
                ListRow(
                  label: key.label,
                  value: details.about[key] ?? l10n.editAdd,
                  onTap: () => editAbout(key),
                ),
              ListRow(
                label: l10n.editGender,
                value: details.genderDetail ?? genderLabel ?? l10n.editAdd,
                onTap: draft.gender == null
                    ? null
                    : () async {
                        final result = await showGenderDetailSheet(
                          context,
                          options: kGenderDetails[draft.gender!]!,
                          detail: details.genderDetail,
                          show: details.showGender,
                        );
                        if (result == null) return;
                        detailsController
                          ..setGenderDetail(result.detail)
                          ..setShowGender(result.show);
                        saved();
                      },
              ),
              for (final key in [AboutKey.location, AboutKey.hometown])
                ListRow(
                  label: key.label,
                  value: details.about[key] ?? l10n.editAdd,
                  onTap: () => editAbout(key),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.editMoreAbout,
            footnote: l10n.editMoreAboutNote,
            children: [
              ListRow(
                label: l10n.editHeight,
                value: details.heightCm == null
                    ? l10n.editAdd
                    : l10n.heightValue(details.heightCm!),
                onTap: () async {
                  final cm = await showHeightSheet(context, details.heightCm);
                  if (cm == null) return;
                  detailsController.setHeight(cm == 0 ? null : cm);
                  saved();
                },
              ),
              for (final key in DetailKey.values)
                ListRow(
                  label: key.label,
                  value: details.details[key] ?? l10n.editAdd,
                  onTap: () => editDetail(key),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.editMoreSection,
            children: [
              ListRow(
                label: l10n.editLanguages,
                value: details.languages.isEmpty
                    ? l10n.editAdd
                    : details.languages.join(', '),
                onTap: () async {
                  final picked = await showLanguagesSheet(
                    context,
                    details.languages,
                  );
                  if (picked == null) return;
                  for (final l in {...details.languages, ...picked}) {
                    if (details.languages.contains(l) != picked.contains(l)) {
                      detailsController.toggleLanguage(l);
                    }
                  }
                  saved();
                },
              ),
              ListRow(
                label: l10n.openingMovesTitle,
                value: l10n.openingMovesCount(details.openingMoves.length),
                onTap: () => context.push(Routes.openingMoves),
              ),
              ListRow(
                label: l10n.privacyTitle,
                onTap: () => context.push(Routes.privacy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
