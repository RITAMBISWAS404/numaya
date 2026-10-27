import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/session_controller.dart';
import '../../dating/application/dating_controller.dart';

/// Notification choices for this session (push is not connected yet).
class NotificationPrefs {
  const NotificationPrefs({this.messages = true, this.likes = true});
  final bool messages;
  final bool likes;
}

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() => const NotificationPrefs();

  void setMessages(bool v) =>
      state = NotificationPrefs(messages: v, likes: state.likes);
  void setLikes(bool v) =>
      state = NotificationPrefs(messages: state.messages, likes: v);
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
    final dating = ref.watch(datingProvider);
    final datingController = ref.read(datingProvider.notifier);

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
            title: l10n.settingsVisibility,
            footnote: l10n.settingsSnoozeNote,
            children: [
              ListRow(
                label: l10n.settingsSnooze,
                detail: dating.snoozed
                    ? l10n.settingsSnoozeOn
                    : l10n.settingsSnoozeOff,
                switchValue: dating.snoozed,
                onSwitch: (v) {
                  datingController.setSnoozed(v);
                  NumayaToast.show(
                    context,
                    v ? l10n.snoozedToast : l10n.resumedToast,
                    aboveFooter: false,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsNotifications,
            footnote: l10n.settingsNotificationsNote,
            children: [
              // V16 113: New messages, New likes, each with its state underneath.
              ListRow(
                label: l10n.settingsMessages,
                detail: prefs.messages
                    ? l10n.settingsSwitchOn
                    : l10n.settingsSwitchOff,
                switchValue: prefs.messages,
                onSwitch: ref
                    .read(notificationPrefsProvider.notifier)
                    .setMessages,
              ),
              ListRow(
                label: l10n.settingsNewLikes,
                detail: prefs.likes
                    ? l10n.settingsSwitchOn
                    : l10n.settingsSwitchOff,
                switchValue: prefs.likes,
                onSwitch: ref.read(notificationPrefsProvider.notifier).setLikes,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsPrivacy,
            children: [
              ListRow(
                leading: NumayaIcons.shield,
                label: l10n.settingsBlocked,
                value: '${datingController.blocked().length}',
                onTap: () => context.push(Routes.blocked),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (demo) ...[
            ListGroup(
              title: l10n.settingsPrototype,
              footnote: l10n.settingsPrototypeNote,
              children: [
                ListRow(
                  label: l10n.settingsSimulate,
                  detail: dating.simulateErrors
                      ? l10n.settingsSimulateOn
                      : l10n.settingsSimulateOff,
                  switchValue: dating.simulateErrors,
                  onSwitch: datingController.setSimulateErrors,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
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
