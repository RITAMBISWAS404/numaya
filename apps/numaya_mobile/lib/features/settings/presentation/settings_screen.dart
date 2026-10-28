import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/session_controller.dart';
import '../../dating/application/dating_controller.dart';
import '../../onboarding/presentation/permission_prompt.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../application/account_prefs.dart';
import 'recovery_email_sheet.dart';

/// B-70 Settings in V16's layout (screenshots 111–113): grouped white rows on the stone page,
/// switch rows with their state underneath, and Log out / Delete account as white blocks. Extended
/// with the reference's structure (Mobbin "Settings"): location and Travel, Incognito, Snooze with
/// a length and an away status, notification categories, privacy, help and legal, and restore
/// purchases. Push, email, location and the store aren't connected in this build; rows say so.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const version = '0.2.0';

  /// Snooze (B-71): choose how long, then an optional away status for existing matches.
  static Future<void> startSnooze(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final lengths = [
      (SnoozeLength.day, l10n.snooze24h),
      (SnoozeLength.threeDays, l10n.snooze72h),
      (SnoozeLength.week, l10n.snoozeWeek),
      (SnoozeLength.indefinite, l10n.snoozeIndefinite),
    ];
    final length = await showNumayaSheet<SnoozeLength>(
      context: context,
      title: l10n.snoozeTitle,
      closeLabel: l10n.close,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.snoozeBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s4),
          OptionGroup(
            legend: l10n.snoozeHowLong,
            children: [
              for (final (value, label) in lengths)
                OptionCard(
                  label: label,
                  selected: false,
                  onTap: () => Navigator.of(context).pop(value),
                ),
            ],
          ),
        ],
      ),
    );
    if (length == null || !context.mounted) return;
    ref.read(accountPrefsProvider.notifier).startSnooze(length);
    ref.read(datingProvider.notifier).setSnoozed(true);
    final status = await showNumayaActionSheet(
      context: context,
      cancelLabel: l10n.snoozeNoStatus,
      actions: [
        for (final s in kAwayStatuses)
          (icon: NumayaIcons.clock, label: s.label, destructive: false),
      ],
    );
    if (!context.mounted) return;
    if (status != null) {
      ref
          .read(accountPrefsProvider.notifier)
          .setAwayStatus(kAwayStatuses[status].label);
    }
    NumayaToast.show(context, l10n.snoozedToast, aboveFooter: false);
  }

  static void endSnooze(BuildContext context, WidgetRef ref) {
    ref.read(accountPrefsProvider.notifier).endSnooze();
    ref.read(datingProvider.notifier).setSnoozed(false);
    NumayaToast.show(context, context.l10n.resumedToast, aboveFooter: false);
  }

  Future<void> _logOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showNumayaSheet<bool>(
      context: context,
      title: l10n.logoutTitle,
      closeLabel: l10n.close,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.logoutBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s6),
          NumayaButton(
            label: l10n.settingsSignOut,
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
    if (ok != true || !context.mounted) return;
    NumayaToast.show(context, l10n.settingsSignedOut, aboveFooter: false);
    await ref.read(sessionProvider.notifier).signOut();
  }

  Future<void> _travel(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final premium = ref.read(premiumProvider);
    if (!premium.active) {
      await context.push(
        '${Routes.paywall}?feature=${PremiumFeature.travel.name}',
      );
      return;
    }
    final city = await showNumayaSheet<String>(
      context: context,
      title: l10n.travelTitle,
      closeLabel: l10n.close,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.travelBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s4),
          OptionGroup(
            legend: l10n.travelPick,
            children: [
              for (final c in kTravelCities)
                OptionCard(
                  label: c,
                  selected: premium.travelCity == c,
                  onTap: () => Navigator.of(context).pop(c),
                ),
            ],
          ),
          if (premium.travelCity != null) ...[
            const SizedBox(height: AppSpacing.s4),
            NumayaButton(
              label: l10n.travelOff,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(''),
            ),
          ],
        ],
      ),
    );
    if (city == null || !context.mounted) return;
    ref.read(premiumProvider.notifier).setTravel(city.isEmpty ? null : city);
    NumayaToast.show(
      context,
      city.isEmpty ? l10n.travelEnded : l10n.travelSet(city),
      aboveFooter: false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);
    final prefs = ref.watch(accountPrefsProvider);
    final prefsController = ref.read(accountPrefsProvider.notifier);
    final premium = ref.watch(premiumProvider);
    final demo = ref.watch(demoAuthProvider) != null;
    final dating = ref.watch(datingProvider);
    final datingController = ref.read(datingProvider.notifier);
    final until = prefs.snoozeUntil;
    final snoozeDetail = !dating.snoozed
        ? l10n.settingsSnoozeOff
        : [
            if (until != null)
              l10n.snoozeUntil(
                MaterialLocalizations.of(context).formatMediumDate(until),
              )
            else
              l10n.settingsSnoozeOn,
            ?prefs.awayStatus,
          ].join(' · ');

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
              ListRow(
                label: l10n.recoveryEmailLabel,
                value:
                    ref.watch(accountPrefsProvider).recoveryEmail ??
                    l10n.recoveryEmailAdd,
                detail: ref.watch(accountPrefsProvider).recoveryEmail == null
                    ? null
                    : l10n.recoveryEmailUnverified,
                onTap: () => showRecoveryEmailSheet(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsVisibility,
            footnote: l10n.settingsSnoozeNote,
            children: [
              ListRow(
                label: l10n.visTitle,
                detail: l10n.visSettingsDetail,
                onTap: () => context.push(Routes.visibility),
              ),
              ListRow(
                label: l10n.settingsSnooze,
                detail: snoozeDetail,
                switchValue: dating.snoozed,
                onSwitch: (v) =>
                    v ? startSnooze(context, ref) : endSnooze(context, ref),
              ),
              ListRow(
                label: l10n.incognito,
                detail: premium.active
                    ? (premium.incognito ? l10n.incognitoOn : l10n.incognitoOff)
                    : l10n.premiumOnly,
                switchValue: premium.active ? premium.incognito : false,
                onSwitch: (v) => premium.active
                    ? ref.read(premiumProvider.notifier).setIncognito(v)
                    : context.push(
                        '${Routes.paywall}?feature=${PremiumFeature.incognito.name}',
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsLocation,
            footnote: l10n.settingsLocationNote,
            children: [
              ListRow(
                leading: NumayaIcons.location,
                label: l10n.settingsCurrentLocation,
                // The member's own choice; nothing stands in for an area never set (the
                // same value Profile & visibility shows).
                value:
                    premium.travelCity ??
                    ref.watch(profileDetailsProvider.select((d) => d.area)) ??
                    l10n.visNotSet,
                onTap: premium.travelCity != null
                    ? null
                    : () async {
                        final area = await showAreaSheet(
                          context,
                          selected: ref.read(profileDetailsProvider).area,
                        );
                        if (area != null) {
                          ref
                              .read(profileDetailsProvider.notifier)
                              .setArea(area);
                        }
                      },
              ),
              ListRow(
                leading: premium.active ? NumayaIcons.public : NumayaIcons.lock,
                label: l10n.travelTitle,
                value: premium.travelCity == null
                    ? (premium.active ? l10n.travelOffValue : l10n.premiumOnly)
                    : l10n.travelOnValue,
                onTap: () => _travel(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsNotifications,
            footnote: l10n.settingsNotificationsNote,
            children: [
              // V16 113: New messages, New likes, each with its state underneath.
              for (final (c, label) in [
                (NotificationCategory.messages, l10n.settingsMessages),
                (NotificationCategory.likes, l10n.settingsNewLikes),
              ])
                ListRow(
                  label: label,
                  detail: prefsController.muted(c)
                      ? l10n.settingsSwitchOff
                      : l10n.settingsSwitchOn,
                  switchValue: !prefsController.muted(c),
                  onSwitch: (v) => prefsController.setCategory(c, v),
                ),
              ListRow(
                label: l10n.notificationsMore,
                onTap: () => context.push(Routes.notifications),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsApp,
            footnote: l10n.settingsVibrationNote,
            children: [
              ListRow(
                label: l10n.settingsVibration,
                detail: prefs.haptics
                    ? l10n.settingsSwitchOn
                    : l10n.settingsSwitchOff,
                switchValue: prefs.haptics,
                onSwitch: prefsController.setHaptics,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsPrivacy,
            children: [
              ListRow(
                leading: NumayaIcons.eyeOff,
                label: l10n.privacyTitle,
                onTap: () => context.push(Routes.privacy),
              ),
              ListRow(
                leading: NumayaIcons.block,
                label: l10n.settingsBlocked,
                value: '${datingController.blocked().length}',
                onTap: () => context.push(Routes.blocked),
              ),
              ListRow(
                leading: NumayaIcons.shield,
                label: l10n.safetyTitle,
                onTap: () => context.push(Routes.safety),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.settingsHelpLegal,
            children: [
              ListRow(
                leading: NumayaIcons.help,
                label: l10n.helpTitle,
                onTap: () => context.push(Routes.help),
              ),
              ListRow(
                leading: NumayaIcons.draft,
                label: l10n.legalTermsTitle,
                onTap: () => showLegalSheet(context, l10n.legalTermsTitle),
              ),
              ListRow(
                leading: NumayaIcons.draft,
                label: l10n.legalPrivacyTitle,
                onTap: () => showLegalSheet(context, l10n.legalPrivacyTitle),
              ),
              ListRow(
                leading: NumayaIcons.refresh,
                label: l10n.paywallRestore,
                onTap: () => NumayaToast.show(
                  context,
                  l10n.paywallRestoreNone,
                  aboveFooter: false,
                ),
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
                  leading: NumayaIcons.explore,
                  label: l10n.demoHubTitle,
                  onTap: () => context.push(Routes.demo),
                ),
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
            onTap: () => _logOut(context, ref),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _ActionBlock(
            label: l10n.settingsDelete,
            danger: true,
            onTap: () => context.push(Routes.deleteAccount),
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

/// Terms and Privacy aren't published yet; the sheet says so instead of linking nowhere.
Future<void> showLegalSheet(BuildContext context, String title) {
  final l10n = context.l10n;
  return showNumayaSheet<void>(
    context: context,
    title: title,
    closeLabel: l10n.close,
    builder: (context) => Text(
      l10n.legalPending,
      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
    ),
  );
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
