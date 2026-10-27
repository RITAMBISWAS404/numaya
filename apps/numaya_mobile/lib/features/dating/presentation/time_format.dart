import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';

/// "14:02" today, "Yesterday", the weekday this week, else "12 Oct" (B-42 rows, B-44 lines).
String shortTime(AppLocalizations l10n, DateTime at, DateTime now) {
  final day = DateTime(at.year, at.month, at.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return DateFormat('HH:mm').format(at);
  if (days == 1) return l10n.timeYesterday;
  if (days < 7) return DateFormat('EEE').format(at);
  return DateFormat('d MMM').format(at);
}

/// The day line above a group of messages.
String dayLine(AppLocalizations l10n, DateTime at, DateTime now) {
  final day = DateTime(at.year, at.month, at.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return l10n.timeToday;
  if (days == 1) return l10n.timeYesterday;
  return DateFormat('EEEE d MMMM').format(at);
}

/// "21h left", "45m left".
String timeLeft(AppLocalizations l10n, Duration d) => d.inHours >= 1
    ? l10n.hoursLeft(d.inHours)
    : l10n.minutesLeft(d.inMinutes.clamp(1, 59));
