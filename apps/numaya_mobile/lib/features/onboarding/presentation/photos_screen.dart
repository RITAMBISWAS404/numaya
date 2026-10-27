import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/auth_copy.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'edit_guard.dart';
import 'photo_options.dart';

/// B-15 photos: at least 2, ideally 4, up to 6. Image upload is not connected yet, so "+" adds a
/// clearly labelled placeholder tile (never a stock photo of a person).
class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key, this.editing = false});

  final bool editing;

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  bool _saving = false;

  Future<void> _finish() async {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    setState(() => _saving = true);
    if (widget.editing) {
      await controller.saveEdits();
      if (!mounted) return;
      NumayaToast.show(context, l10n.editSaved);
      context.pop();
      return;
    }
    controller.completeStep(SetupStep.photos);
    await controller.finish();
    if (!mounted) return;
    context.go(Routes.home);
    NumayaToast.show(context, l10n.profileReady, aboveFooter: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final photos = ref.watch(onboardingProvider.select((s) => s.draft.photos));
    final valid = photos.length >= ProfileRules.minPhotos;
    final missing = ProfileRules.recommendedPhotos - photos.length;

    return EditGuard(
      enabled: widget.editing,
      child: NumayaScreen(
        top: NumayaTopBar(
          onBack: _saving ? null : () => context.pop(),
          backLabel: l10n.back,
          step: widget.editing ? null : SignUpProgress.photos,
          steps: widget.editing ? null : SignUpProgress.total,
          title: widget.editing ? l10n.setupPhotosLabel : null,
        ),
        footer: widget.editing
            ? NumayaButton(
                label: l10n.save,
                loading: _saving,
                onPressed: valid ? _finish : null,
              )
            : StepFooter(
                caption: missing > 0
                    ? l10n.photosAddMore(missing)
                    : l10n.photosLookingGreat,
                action: NumayaFab(
                  semanticLabel: l10n.photosFinish,
                  loading: _saving,
                  onPressed: valid ? _finish : null,
                ),
              ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.editing)
              ScreenHeader(title: l10n.photosTitle, lede: l10n.photosLede),
            const SizedBox(height: AppSpacing.s6),
            PhotoGrid(
              photos: [
                for (final p in photos) GridPhoto(id: p.id, tone: p.tone),
              ],
              slots: ProfileRules.maxPhotos,
              onAdd: controller.addPhoto,
              onRemove: controller.removePhoto,
              mainLabel: l10n.photosMain,
              addLabel: l10n.photosAdd,
              removeLabel: l10n.photosRemove,
              onOpen: (id) =>
                  showPhotoOptions(context, ref, id, keepMinimum: false),
              openLabel: l10n.photoOptionsLabel,
            ),
            const SizedBox(height: AppSpacing.s5),
            InfoCard(
              icon: NumayaIcons.camera,
              title: l10n.photosInfoTitle,
              body: l10n.photosInfoBody,
            ),
          ],
        ),
      ),
    );
  }
}
