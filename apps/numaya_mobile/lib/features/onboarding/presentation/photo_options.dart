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
  final isLast = photos.isNotEmpty && photos.last.id == photoId;
  final actions = [
    if (!isMain)
      (icon: NumayaIcons.star, label: l10n.photoMakeMain, destructive: false),
    if (!isMain)
      (
        icon: NumayaIcons.chevronLeft,
        label: l10n.photoMoveEarlier,
        destructive: false,
      ),
    if (!isLast)
      (
        icon: NumayaIcons.chevronRight,
        label: l10n.photoMoveLater,
        destructive: false,
      ),
    (icon: NumayaIcons.refresh, label: l10n.photoReplace, destructive: false),
    (icon: NumayaIcons.trash, label: l10n.photoRemove, destructive: true),
  ];
  final choice = await showNumayaActionSheet(
    context: context,
    actions: actions,
    cancelLabel: l10n.cancel,
  );
  if (choice == null || !context.mounted) return false;
  final label = actions[choice].label;
  if (label == l10n.photoMakeMain) {
    controller.makeMain(photoId);
    NumayaToast.show(context, l10n.photoMadeMain);
    return true;
  }
  if (label == l10n.photoMoveEarlier || label == l10n.photoMoveLater) {
    controller.movePhoto(photoId, label == l10n.photoMoveEarlier ? -1 : 1);
    NumayaToast.show(context, l10n.photoMoved);
    return true;
  }
  if (label == l10n.photoReplace) {
    controller.replacePhoto(photoId);
    NumayaToast.show(context, l10n.photoReplaced);
    return true;
  }
  if (keepMinimum && photos.length <= ProfileRules.minPhotos) {
    NumayaToast.show(context, l10n.photoKeepTwo);
    return false;
  }
  controller.removePhoto(photoId);
  return true;
}
