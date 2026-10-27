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

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsDeleteTitle),
        content: Text(l10n.settingsDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: AppTypography.button),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.settingsDelete,
              style: AppTypography.button.copyWith(color: AppColors.danger),
            ),
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
          NumayaButton(
            label: l10n.settingsSignOut,
            variant: NumayaButtonVariant.secondary,
            onPressed: () async {
              NumayaToast.show(
                context,
                l10n.settingsSignedOut,
                aboveFooter: false,
              );
              await ref.read(sessionProvider.notifier).signOut();
            },
          ),
          const SizedBox(height: AppSpacing.s2),
          NumayaButton(
            label: l10n.settingsDelete,
            variant: NumayaButtonVariant.destructive,
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
    );
  }
}
