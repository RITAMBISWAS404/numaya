import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/session_controller.dart';
import '../../dating/application/dating_controller.dart';
import '../../help/domain/help_articles.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/application/profile_details_controller.dart';
import '../application/account_prefs.dart';
import 'settings_screen.dart';

String _categoryLabel(AppLocalizations l10n, NotificationCategory c) =>
    switch (c) {
      NotificationCategory.messages => l10n.settingsMessages,
      NotificationCategory.likes => l10n.settingsNewLikes,
      NotificationCategory.matches => l10n.notifMatches,
      NotificationCategory.expiring => l10n.notifExpiring,
      NotificationCategory.tips => l10n.notifTips,
    };

/// Notification settings (B-74, Mobbin "New messages settings"): each category with Push, In-app
/// and Email switches and the warning line. Push and email aren't connected in this build, so these
/// are preferences only; there's no email on file, so Email is unavailable and says why.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationCategory? _open;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prefs = ref.watch(accountPrefsProvider);
    final controller = ref.read(accountPrefsProvider.notifier);
    final open = _open;

    String summary(NotificationCategory c) {
      final on = prefs.channelsFor(c);
      if (on.isEmpty) return l10n.settingsSwitchOff;
      return [
        if (on.contains(NotificationChannel.push)) l10n.notifPush,
        if (on.contains(NotificationChannel.inApp)) l10n.notifInApp,
        if (on.contains(NotificationChannel.email)) l10n.notifEmail,
      ].join(', ');
    }

    if (open != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _open = null);
        },
        child: NumayaScreen(
          top: NumayaTopBar(
            onBack: () => setState(() => _open = null),
            backLabel: l10n.back,
            title: _categoryLabel(l10n, open),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s4),
              Text(
                l10n.notifWarning,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              ListGroup(
                footnote: l10n.notifEmailNote,
                children: [
                  ListRow(
                    label: l10n.notifPush,
                    switchValue: prefs.isOn(open, NotificationChannel.push),
                    onSwitch: (v) => controller.setChannel(
                      open,
                      NotificationChannel.push,
                      v,
                    ),
                  ),
                  ListRow(
                    label: l10n.notifInApp,
                    switchValue: prefs.isOn(open, NotificationChannel.inApp),
                    onSwitch: (v) => controller.setChannel(
                      open,
                      NotificationChannel.inApp,
                      v,
                    ),
                  ),
                  ListRow(
                    label: l10n.notifEmail,
                    detail: l10n.notifNoEmail,
                    switchValue: false,
                    onSwitch: null,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.settingsNotifications,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            footnote: l10n.settingsNotificationsNote,
            children: [
              for (final c in NotificationCategory.values)
                ListRow(
                  label: _categoryLabel(l10n, c),
                  value: summary(c),
                  onTap: () => setState(() => _open = c),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Profile visibility (B-70 security and privacy, B-13 gender visibility): what the profile shows,
/// and Incognito (Premium).
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final details = ref.watch(profileDetailsProvider);
    final controller = ref.read(profileDetailsProvider.notifier);
    final premium = ref.watch(premiumProvider);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.privacyTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            title: l10n.privacyShowTitle,
            footnote: l10n.privacyShowNote,
            children: [
              ListRow(
                label: l10n.privacyShowAge,
                switchValue: details.showAge,
                onSwitch: controller.setShowAge,
              ),
              ListRow(
                label: l10n.privacyShowDistance,
                switchValue: details.showDistance,
                onSwitch: controller.setShowDistance,
              ),
              ListRow(
                label: l10n.editGenderShow,
                switchValue: details.showGender,
                onSwitch: controller.setShowGender,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.privacyWhoSees,
            footnote: l10n.incognitoNote,
            children: [
              ListRow(
                label: l10n.incognito,
                detail: premium.active ? null : l10n.premiumOnly,
                switchValue: premium.active && premium.incognito,
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
            children: [
              ListRow(
                leading: NumayaIcons.block,
                label: l10n.settingsBlocked,
                onTap: () => context.push(Routes.blocked),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Delete account (B-75, official help [C]): a reason, the alternatives (snooze), what's removed,
/// the 28-day restore window and the subscription warning, then V16's confirmation sheet (130).
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  String? _reason;

  static const _reasons = [
    'I met someone',
    'I’m taking a break',
    'I’m not getting the matches I want',
    'Something isn’t working',
    'Something else',
  ];

  /// V16 delete confirmation (screenshot 130): a sheet with the consequence, a solid red
  /// "Delete account" and an outlined Cancel.
  Future<void> _confirm() async {
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
          const SizedBox(height: AppSpacing.s3),
          Text(
            l10n.deleteRestoreNote,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
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
    if (confirmed != true || !mounted) return;
    NumayaToast.show(context, l10n.settingsDeleted, aboveFooter: false);
    // Ending the session sends the router back to Welcome.
    await ref.read(sessionProvider.notifier).deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final premium = ref.watch(premiumProvider).active;
    final snoozed = ref.watch(datingProvider.select((s) => s.snoozed));
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.settingsDelete,
      ),
      footer: NumayaButton(
        label: l10n.deleteContinue,
        variant: NumayaButtonVariant.destructiveSolid,
        onPressed: _reason == null ? null : _confirm,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ScreenHeader(title: l10n.deleteHeading, lede: l10n.deleteLede),
          const SizedBox(height: AppSpacing.s5),
          OptionGroup(
            legend: l10n.deleteWhy,
            children: [
              for (final r in _reasons)
                OptionCard(
                  label: r,
                  selected: _reason == r,
                  onTap: () => setState(() => _reason = r),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          if (!snoozed) ...[
            InfoCard(
              icon: NumayaIcons.clock,
              title: l10n.deleteSnoozeTitle,
              body: l10n.deleteSnoozeBody,
            ),
            const SizedBox(height: AppSpacing.s2),
            Align(
              alignment: Alignment.centerLeft,
              child: TextLink(
                label: l10n.deleteSnoozeAction,
                onPressed: () => SettingsScreen.startSnooze(context, ref),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          ConsequenceList(
            items: [
              (NumayaIcons.eyeOff, l10n.deleteC1),
              (NumayaIcons.message, l10n.deleteC2),
              (NumayaIcons.refresh, l10n.deleteC3),
            ],
          ),
          if (premium) ...[
            const SizedBox(height: AppSpacing.s4),
            StatusBanner(
              tone: BannerTone.pending,
              title: l10n.deleteSubscriptionTitle,
              body: l10n.deleteSubscriptionBody,
            ),
          ],
          const SizedBox(height: AppSpacing.s3),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLink(
              label: l10n.deleteHelp,
              onPressed: () =>
                  context.push('${Routes.help}/${HelpArticleId.deleting.name}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Account restore (F27, official help [C]): signing in with the number of an account deleted in
/// the last 28 days offers to bring it back or start over.
class RestoreAccountScreen extends ConsumerStatefulWidget {
  const RestoreAccountScreen({super.key});

  @override
  ConsumerState<RestoreAccountScreen> createState() =>
      _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends ConsumerState<RestoreAccountScreen> {
  bool _busy = false;

  Future<void> _restore() async {
    setState(() => _busy = true);
    await ref.read(sessionProvider.notifier).restoreAccount();
    if (!mounted) return;
    context.go(Routes.home);
    NumayaToast.show(context, context.l10n.restoreDone, aboveFooter: false);
  }

  Future<void> _startOver() async {
    await ref.read(sessionProvider.notifier).startOver();
    if (mounted) context.go(Routes.setup);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final until = ref.watch(sessionProvider)?.restorableUntil;
    final date = until == null
        ? ''
        : MaterialLocalizations.of(context).formatMediumDate(until);
    return NumayaScreen(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            label: l10n.restoreAction,
            loading: _busy,
            onPressed: _busy ? null : _restore,
          ),
          const SizedBox(height: AppSpacing.s2),
          NumayaButton(
            label: l10n.restoreStartOver,
            variant: NumayaButtonVariant.quiet,
            onPressed: _busy ? null : _startOver,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s10),
        child: ResultPanel(
          illustration: NumayaIllustration.hello,
          title: l10n.restoreTitle,
          body: l10n.restoreBody(date),
        ),
      ),
    );
  }
}

/// Moderation block (B-59, official help [C]): a neutral notice with an appeal form. The server
/// decides this; the demo previews it from the Demo Hub. The appeal is not sent anywhere.
class AccountBlockedScreen extends StatefulWidget {
  const AccountBlockedScreen({super.key});

  @override
  State<AccountBlockedScreen> createState() => _AccountBlockedScreenState();
}

class _AccountBlockedScreenState extends State<AccountBlockedScreen> {
  final _text = TextEditingController();
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.blockedAccountTitle,
      ),
      footer: _sent
          ? null
          : NumayaButton(
              label: l10n.appealSend,
              onPressed: _text.text.trim().length < 10
                  ? null
                  : () => setState(() => _sent = true),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          StatusBanner(
            tone: BannerTone.error,
            title: l10n.blockedAccountHeading,
            body: l10n.blockedAccountBody,
          ),
          const SizedBox(height: AppSpacing.s5),
          if (_sent)
            ResultPanel(
              illustration: NumayaIllustration.hello,
              compact: true,
              title: l10n.appealSentTitle,
              body: l10n.appealSentBody,
            )
          else
            NumayaTextField(
              label: l10n.appealLabel,
              controller: _text,
              multiline: true,
              maxLength: 500,
              placeholder: l10n.appealPlaceholder,
              hint: l10n.appealHint,
              trailingNote: l10n.promptCharsLeft(500 - _text.text.length),
            ),
        ],
      ),
    );
  }
}
