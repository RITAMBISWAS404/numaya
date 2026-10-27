import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';

/// Photo options (V16 104): "Make main photo" (not for the main one) and "Remove photo". With
/// [keepMinimum], removing below the minimum is refused with a short explanation. Returns true when
/// something changed.
Future<bool> showPhotoOptions(
  BuildContext context,
  WidgetRef ref,
  int photoId, {
  required bool keepMinimum,
}) async {
  final l10n = context.l10n;
  final controller = ref.read(onboardingProvider.notifier);
  final photos = ref.read(onboardingProvider).draft.photos;
  final isMain = photos.isNotEmpty && photos.first.id == photoId;
  final actions = [
    if (!isMain)
      (icon: NumayaIcons.star, label: l10n.photoMakeMain, destructive: false),
    (icon: NumayaIcons.trash, label: l10n.photoRemove, destructive: true),
  ];
  final choice = await showNumayaActionSheet(
    context: context,
    actions: actions,
    cancelLabel: l10n.cancel,
  );
  if (choice == null || !context.mounted) return false;
  if (actions[choice].label == l10n.photoMakeMain) {
    controller.makeMain(photoId);
    NumayaToast.show(context, l10n.photoMadeMain);
    return true;
  }
  if (keepMinimum && photos.length <= ProfileRules.minPhotos) {
    NumayaToast.show(context, l10n.photoKeepTwo);
    return false;
  }
  controller.removePhoto(photoId);
  return true;
}
