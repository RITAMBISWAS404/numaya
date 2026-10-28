import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../profile/domain/profile_details.dart';
import '../application/device_permissions.dart';

/// Asks for [permission] the way the app would: only when the prompt can still appear. Shows a
/// labelled stand-in for Android's prompt (this build has no permission plugin) and records the
/// answer. Returns the status afterwards, unchanged when the sheet is dismissed or Android would
/// no longer ask.
Future<PermissionStatus> requestPermission(
  BuildContext context,
  WidgetRef ref,
  DevicePermission permission,
) async {
  final controller = ref.read(devicePermissionsProvider.notifier);
  final before = ref.read(devicePermissionsProvider).of(permission);
  if (!before.canAsk) return before;
  final answer = await _showPrompt(context, permission);
  if (answer == null) return before;
  return controller.answer(permission, answer);
}

Future<PermissionAnswer?> _showPrompt(
  BuildContext context,
  DevicePermission permission,
) {
  final l10n = context.l10n;
  final (title, options) = switch (permission) {
    DevicePermission.location => (
      l10n.permLocationTitle,
      [
        (PermissionAnswer.allowApproximate, l10n.permAllowApproximate),
        (PermissionAnswer.allowPrecise, l10n.permAllowPrecise),
        (PermissionAnswer.deny, l10n.permDeny),
      ],
    ),
    DevicePermission.camera => (
      l10n.permCameraTitle,
      [
        (PermissionAnswer.allow, l10n.permAllow),
        (PermissionAnswer.deny, l10n.permDeny),
      ],
    ),
    DevicePermission.notifications => (
      l10n.permNotificationsTitle,
      [
        (PermissionAnswer.allow, l10n.permAllow),
        (PermissionAnswer.deny, l10n.permDeny),
      ],
    ),
  };
  return showNumayaSheet<PermissionAnswer>(
    context: context,
    title: title,
    closeLabel: l10n.close,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(label: l10n.permDemoTag),
        ),
        const SizedBox(height: AppSpacing.s4),
        for (final (answer, label) in options) ...[
          NumayaButton(
            label: label,
            variant: answer == PermissionAnswer.deny
                ? NumayaButtonVariant.secondary
                : NumayaButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(answer),
          ),
          const SizedBox(height: AppSpacing.s3),
        ],
      ],
    ),
  );
}

/// OB-13: the area list with search (a sample list in this build). Returns the area or null.
Future<String?> showAreaSheet(BuildContext context, {String? selected}) {
  final l10n = context.l10n;
  var query = '';
  return showNumayaSheet<String>(
    context: context,
    title: l10n.obAreaSheetTitle,
    closeLabel: l10n.close,
    tall: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheet) {
        final q = query.trim().toLowerCase();
        final areas = kSampleAreas
            .where((a) => q.isEmpty || a.toLowerCase().contains(q))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumayaSearchField(
              placeholder: l10n.obAreaSearch,
              clearLabel: l10n.interestsClearSearch,
              onChanged: (v) => setSheet(() => query = v),
            ),
            const SizedBox(height: AppSpacing.s4),
            Expanded(
              child: areas.isEmpty
                  ? Center(
                      child: Text(
                        l10n.obAreaNone(query.trim()),
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: OptionGroup(
                        legend: l10n.obLocationAreaLabel,
                        children: [
                          for (final a in areas)
                            OptionCard(
                              label: a,
                              selected: a == selected,
                              onTap: () => Navigator.of(context).pop(a),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    ),
  );
}
