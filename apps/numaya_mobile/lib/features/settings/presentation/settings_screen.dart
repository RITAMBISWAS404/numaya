import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/session_controller.dart';

/// Notification choices for this session (push is not connected yet).
class NotificationPrefs {
  const NotificationPrefs({this.matches = true, this.messages = true});
  final bool matches;
  final bool messages;
}

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() => const NotificationPrefs();

  void setMatches(bool v) =>
      state = NotificationPrefs(matches: v, messages: state.messages);
  void setMessages(bool v) =>
      state = NotificationPrefs(matches: state.matches, messages: v);
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
      NotificationPrefsController.new,
    );

/// B-70 Settings (the parts this build can honour): account, notifications, sign out, delete.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const version = '0.1.0';

  /// V16 delete confirmation (screenshot 130): a sheet with the consequence, a solid red
  /// "Delete account" and an outlined Cancel.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showNumayaSheet<bool>(
      context: context,
      title: l10n.settingsDeleteTitle,
      closeLabel: l10n.close,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsDeleteBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s6),
          NumayaButton(
            label: l10n.settingsDelete,
            variant: NumayaButtonVariant.destructiveSolid,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.cancel,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    NumayaToast.show(context, l10n.settingsDeleted, aboveFooter: false);
    // Ending the session sends the router back to Welcome.
    await ref.read(sessionProvider.notifier).deleteAccount();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);
    final prefs = ref.watch(notificationPrefsProvider);
    final demo = ref.watch(demoAuthProvider) != null;

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.settingsTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            title: l10n.settingsAccount,
            children: [
              ListRow(
                label: l10n.settingsPhone,
                value: session?.phone.display ?? '',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsNotifications,
            footnote: l10n.settingsNotificationsNote,
            children: [
              ListRow(
                label: l10n.settingsNewMatches,
                switchValue: prefs.matches,
                onSwitch: ref
                    .read(notificationPrefsProvider.notifier)
                    .setMatches,
              ),
              ListRow(
                label: l10n.settingsMessages,
                switchValue: prefs.messages,
                onSwitch: ref
                    .read(notificationPrefsProvider.notifier)
                    .setMessages,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsAbout,
            footnote: demo ? l10n.settingsDemoNote : null,
            children: [ListRow(label: l10n.settingsVersion(version))],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          // V16 (screenshot 112): Log out and Delete account are white blocks on the page.
          _ActionBlock(
            label: l10n.settingsSignOut,
            onTap: () async {
              NumayaToast.show(
                context,
                l10n.settingsSignedOut,
                aboveFooter: false,
              );
              await ref.read(sessionProvider.notifier).signOut();
            },
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _ActionBlock(
            label: l10n.settingsDelete,
            danger: true,
            onTap: () => _delete(context, ref),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s1,
              AppSpacing.s3,
              0,
              0,
            ),
            child: Text(
              l10n.settingsDeleteNote,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      excludeChildSemantics: true,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Container(
        width: double.infinity,
        height: AppSizes.row,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.row.copyWith(
            color: danger ? AppColors.negative : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
