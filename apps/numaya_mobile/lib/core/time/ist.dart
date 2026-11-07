/// India Standard Time calendar helpers (PRD 02: "India daily reset midnight Asia/Kolkata; weekly
/// free extensions reset Monday IST"). IST has no daylight saving, so a fixed +05:30 offset is
/// exact. Every rule that counts days (like allowance, extensions, streak days) uses these, so the
/// boundaries are the same whatever time zone the phone is set to. Clocks are injected
/// (`clockProvider`); in a live build the authoritative timestamps come from the server.
library;

const Duration kIstOffset = Duration(hours: 5, minutes: 30);

/// A calendar day in IST, as a count of days since 1970-01-01 (IST). Comparable and hashable.
typedef IstDay = int;

/// The IST calendar day containing [moment].
IstDay istDay(DateTime moment) {
  final ist = moment.toUtc().add(kIstOffset);
  final date = DateTime.utc(ist.year, ist.month, ist.day);
  return date.difference(DateTime.utc(1970)).inDays;
}

/// The instant (UTC) at which IST day [day] starts (00:00 Asia/Kolkata).
DateTime istDayStart(IstDay day) =>
    DateTime.utc(1970).add(Duration(days: day)).subtract(kIstOffset);

/// The next IST midnight after [moment]: when the daily allowance resets.
DateTime nextIstMidnight(DateTime moment) => istDayStart(istDay(moment) + 1);

/// The Monday (IST) that starts the week containing [moment], as an [IstDay].
IstDay istWeekStart(DateTime moment) {
  final day = istDay(moment);
  // 1970-01-01 was a Thursday: day 0 has weekday index 3 (Monday = 0).
  final weekdayIndex = (day + 3) % 7;
  return day - weekdayIndex;
}

/// The next Monday 00:00 IST after [moment]: when the free weekly extension resets.
DateTime nextIstMonday(DateTime moment) =>
    istDayStart(istWeekStart(moment) + 7);
