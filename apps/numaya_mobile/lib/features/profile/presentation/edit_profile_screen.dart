import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/domain/profile_draft.dart';

/// B-24 Edit profile in V16's layout (screenshot 102-edit-profile): an "EDIT PROFILE" header, the
/// photo grid in place (changes save straight away), the prompt card, then rows for the basics and
/// interests, which open the same editors used during setup. V16's Edit / Preview switch is left out
/// until a preview exists, so there is no control that does nothing.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final age = draft.ageIn(controller.currentYear);

    Future<void> changePhotos(VoidCallback change) async {
      change();
      await controller.saveEdits();
    }

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.editTitle,
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
                    if (draft.photos.length <= ProfileRules.minPhotos) return;
                    changePhotos(() => controller.removePhoto(id));
                  },
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
          const SizedBox(height: AppSpacing.sectionGap),
          NumayaSection(
            title: l10n.editPromptSection,
            description: l10n.profilePromptCaption,
            child: PromptCard(
              question: draft.prompt?.question ?? kPromptQuestions.first,
              answer: draft.prompt?.answer,
              emptyLabel: l10n.promptEmpty,
              editLabel: l10n.promptEditLabel,
              onTap: () => context.push(Routes.editPrompt),
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
            ],
          ),
        ],
      ),
    );
  }
}
