import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// Notification categories (B-74, Mobbin "New messages settings").
enum NotificationCategory { messages, likes, matches, expiring, tips }

enum NotificationChannel { push, inApp, email }

/// Snooze lengths (official Bumble help: 24 hours, 72 hours, a week or indefinitely [C]).
enum SnoozeLength { day, threeDays, week, indefinite }

/// Away statuses offered after snoozing (B-71).
const List<({String emoji, String label})> kAwayStatuses = [
  (emoji: '✈️', label: 'I’m travelling'),
  (emoji: '💼', label: 'I’m focused on work'),
  (emoji: '🔌', label: 'I’m on a digital detox'),
  (emoji: '❤️', label: 'I’m prioritising myself'),
];

@immutable
class AccountPrefs {
  const AccountPrefs({
    this.channels = const {},
    this.snoozeLength,
    this.snoozedAt,
    this.awayStatus,
    this.haptics = true,
    this.recoveryEmail,
  });

  /// Channels turned off per category; everything is on by default except email (no email on
  /// file in this build).
  final Map<NotificationCategory, Set<NotificationChannel>> channels;
  final SnoozeLength? snoozeLength;
  final DateTime? snoozedAt;
  final String? awayStatus;

  /// Whether the app vibrates on selections, decisions and successes (the one haptics gate).
  final bool haptics;

  /// An email for account recovery (B-09; U-11: a lost number needs a second way in). Kept on
  /// this device only: no email is sent or verified in this build.
  final String? recoveryEmail;

  static const Set<NotificationChannel> defaults = {
    NotificationChannel.push,
    NotificationChannel.inApp,
  };

  Set<NotificationChannel> channelsFor(NotificationCategory c) =>
      channels[c] ?? defaults;

  bool isOn(NotificationCategory c, NotificationChannel ch) =>
      channelsFor(c).contains(ch);

  /// When snooze ends, or null when indefinite / not snoozed.
  DateTime? get snoozeUntil {
    final at = snoozedAt;
    if (at == null) return null;
    return switch (snoozeLength) {
      SnoozeLength.day => at.add(const Duration(hours: 24)),
      SnoozeLength.threeDays => at.add(const Duration(hours: 72)),
      SnoozeLength.week => at.add(const Duration(days: 7)),
      _ => null,
    };
  }

  AccountPrefs copyWith({
    Map<NotificationCategory, Set<NotificationChannel>>? channels,
    SnoozeLength? snoozeLength,
    DateTime? snoozedAt,
    String? awayStatus,
    bool? haptics,
    String? recoveryEmail,
    bool clearSnooze = false,
    bool clearStatus = false,
    bool clearEmail = false,
  }) => AccountPrefs(
    channels: channels ?? this.channels,
    snoozeLength: clearSnooze ? null : (snoozeLength ?? this.snoozeLength),
    snoozedAt: clearSnooze ? null : (snoozedAt ?? this.snoozedAt),
    awayStatus: clearSnooze || clearStatus
        ? null
        : (awayStatus ?? this.awayStatus),
    haptics: haptics ?? this.haptics,
    recoveryEmail: clearEmail ? null : (recoveryEmail ?? this.recoveryEmail),
  );
}

/// A plausible email address: something@domain.tld, no spaces. The real check is the
/// confirmation email a service would send.
bool isValidEmail(String value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s.]{2,}$').hasMatch(value.trim());

/// Settings choices for this session. Push and email are not connected in this build, so the
/// switches only record a preference (the screens say so).
class AccountPrefsController extends Notifier<AccountPrefs> {
  @override
  AccountPrefs build() => const AccountPrefs();

  void setChannel(NotificationCategory c, NotificationChannel ch, bool on) {
    final next = {...state.channelsFor(c)};
    on ? next.add(ch) : next.remove(ch);
    state = state.copyWith(channels: {...state.channels, c: next});
  }

  /// Whether every channel is off for [c].
  bool muted(NotificationCategory c) => state.channelsFor(c).isEmpty;

  /// The V16 inline switch: turns push and in-app on or off together.
  void setCategory(NotificationCategory c, bool on) => state = state.copyWith(
    channels: {
      ...state.channels,
      c: on ? AccountPrefs.defaults : <NotificationChannel>{},
    },
  );

  void startSnooze(SnoozeLength length) => state = state.copyWith(
    snoozeLength: length,
    snoozedAt: ref.read(clockProvider)(),
    clearStatus: true,
  );

  void setAwayStatus(String? status) => state = status == null
      ? state.copyWith(clearStatus: true)
      : state.copyWith(awayStatus: status);

  void endSnooze() => state = state.copyWith(clearSnooze: true);

  void setHaptics(bool on) => state = state.copyWith(haptics: on);

  /// Saves [email] (trimmed), or removes it when null. Removing it also turns email
  /// notifications off, since there is nowhere to send them.
  void setRecoveryEmail(String? email) {
    if (email == null) {
      state = state.copyWith(
        clearEmail: true,
        channels: {
          for (final MapEntry(key: c, value: on) in state.channels.entries)
            c: {...on}..remove(NotificationChannel.email),
        },
      );
      return;
    }
    assert(isValidEmail(email));
    state = state.copyWith(recoveryEmail: email.trim());
  }
}

final accountPrefsProvider =
    NotifierProvider<AccountPrefsController, AccountPrefs>(
      AccountPrefsController.new,
    );
