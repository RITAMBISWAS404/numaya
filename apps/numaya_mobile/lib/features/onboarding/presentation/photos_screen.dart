import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../application/device_permissions.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'edit_guard.dart';
import 'permission_prompt.dart';
import 'photo_options.dart';
import 'step_scaffold.dart';

/// OB-14 photos: at least 2, ideally 4, up to 6 (B-15; happn "Add your first 2 photos" [O]). No
/// camera, picker or upload is connected in this build: "+" offers both sources (OB-14a) and adds a
/// clearly labelled placeholder tile, never a stock photo of a person. [editing] is Edit profile's
/// version.
class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key, this.editing = false});

  final bool editing;

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

enum _PhotoSource { camera, library }

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  bool _saving = false;

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    await ref.read(onboardingProvider.notifier).saveEdits();
    if (!mounted) return;
    NumayaToast.show(context, l10n.editSaved);
    context.pop();
  }

  /// OB-14a: camera or library. The camera asks for permission first (simulated); a cancelled
  /// sheet changes nothing.
  Future<void> _add() async {
    final l10n = context.l10n;
    final source = await showNumayaSheet<_PhotoSource>(
      context: context,
      title: l10n.photoSourceTitle,
      closeLabel: l10n.cancel,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListGroup(
            children: [
              ListRow(
                leading: NumayaIcons.camera,
                label: l10n.photoSourceCamera,
                onTap: () => Navigator.of(context).pop(_PhotoSource.camera),
              ),
              ListRow(
                leading: NumayaIcons.image,
                label: l10n.photoSourceLibrary,
                onTap: () => Navigator.of(context).pop(_PhotoSource.library),
              ),
            ],
          ),
        ],
      ),
    );
    if (source == null || !mounted) return;
    if (source == _PhotoSource.camera) {
      final status = await requestPermission(
        context,
        ref,
        DevicePermission.camera,
      );
      if (!status.isGranted) return;
    }
    if (!mounted) return;
    final picked = await pickProfilePhoto(
      context,
      ref,
      camera: source == _PhotoSource.camera,
    );
    if (picked == null || !mounted) return;
    ref.read(onboardingProvider.notifier).addPhoto(source: picked.source);
  }

  Future<void> _tips() {
    final l10n = context.l10n;
    return showNumayaSheet<void>(
      context: context,
      title: l10n.photoTipsTitle,
      closeLabel: l10n.close,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // UI-053: the tips as rows in one white card on the grey sheet, each with an icon
          // that names its topic, divided by the shared inset divider.
          InfoList(
            items: [
              (NumayaIcons.user, l10n.photoTip1),
              (NumayaIcons.camera, l10n.photoTip2),
              (NumayaIcons.heart, l10n.photoTip3),
              (NumayaIcons.eyeOff, l10n.photoTip4),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(l10n.photoTipsNote, style: AppTypography.helper),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final photos = ref.watch(onboardingProvider.select((s) => s.draft.photos));
    final camera = ref.watch(
      devicePermissionsProvider.select((p) => p.of(DevicePermission.camera)),
    );
    final valid = photos.length >= ProfileRules.minPhotos;
    final missing = ProfileRules.recommendedPhotos - photos.length;

    final content = <Widget>[
      if (camera == PermissionStatus.denied ||
          camera == PermissionStatus.permanentlyDenied) ...[
        StatusBanner(
          tone: BannerTone.error,
          title: l10n.photoCameraDeniedTitle,
          body: camera == PermissionStatus.denied
              ? l10n.photoCameraDeniedBody
              : l10n.photoCameraBlockedBody,
        ),
        const SizedBox(height: AppSpacing.s4),
      ],
      PhotoGrid(
        photos: [
          for (final p in photos)
            GridPhoto(
              id: p.id,
              tone: p.tone,
              image: p.source == null
                  ? null
                  : localImage(p.source!, width: 360),
              alignment: p.source == null
                  ? Alignment.center
                  : localImageFocus(p.source!),
            ),
        ],
        slots: ProfileRules.maxPhotos,
        onAdd: _add,
        onRemove: controller.removePhoto,
        mainLabel: l10n.photosMain,
        addLabel: l10n.photosAdd,
        removeLabel: l10n.photosRemove,
        onOpen: (id) =>
            showPhotoOptions(context, ref, id, keepMinimum: widget.editing),
        openLabel: l10n.photoOptionsLabel,
      ),
      const SizedBox(height: AppSpacing.s3),
      Align(
        alignment: Alignment.centerLeft,
        child: TextLink(label: l10n.photoTipsLink, onPressed: _tips),
      ),
      const SizedBox(height: AppSpacing.s3),
      InfoCard(
        icon: NumayaIcons.camera,
        title: l10n.photosInfoTitle,
        body: l10n.photosInfoBody,
      ),
    ];

    if (!widget.editing) {
      return OnboardingStepScaffold(
        step: SetupStep.photos,
        title: l10n.photosTitle,
        lede: l10n.photosLede,
        caption: missing > 0
            ? l10n.photosAddMore(missing)
            : l10n.photosLookingGreat,
        canContinue: valid,
        onContinue: () => continueFrom(context, ref, SetupStep.photos),
        children: [...content, ..._moderationNote(l10n)],
      );
    }
    return EditGuard(
      enabled: true,
      child: NumayaScreen(
        top: NumayaTopBar(
          onBack: _saving ? null : () => context.pop(),
          backLabel: l10n.back,
          title: l10n.setupPhotosLabel,
        ),
        footer: NumayaButton(
          label: l10n.save,
          loading: _saving,
          onPressed: valid ? _save : null,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s6),
            ...content,
            ..._moderationNote(l10n),
          ],
        ),
      ),
    );
  }
}

/// S08: photo moderation. The demo approves photos instantly and says so; a live build shows each
/// photo's review status from the server and counts only approved photos toward discovery.
List<Widget> _moderationNote(AppLocalizations l10n) => [
  if (AppConfig.demoAuthAllowed) ...[
    const SizedBox(height: AppSpacing.s4),
    Text(l10n.obPhotosModeration, style: AppTypography.helper),
  ],
];
