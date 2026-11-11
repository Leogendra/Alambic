import '../../domain/scheduling/clock_time.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../l10n/generated/app_localizations.dart';

/// When a direction comes back, relative to [now]: "Due", "at 15:17",
/// "tomorrow" or "in 3 d". Shared by the screens and the notifications.
extension DueLabels on AppLocalizations {
  String dueDateLabel(
    DateTime dueAt, {
    required DateTime now,
    required SchedulingCalendar calendar,
  }) {
    final days = _daysBetween(calendar.dayOf(now), calendar.dayOf(dueAt));
    if (!dueAt.isAfter(now)) {
      return dueNow;
    } else if (days <= 0) {
      return dueAtTime(ClockTime(dueAt.hour, dueAt.minute).toString());
    } else if (days == 1) {
      return dueTomorrow;
    } else {
      return dueInDays(days);
    }
  }

  /// Whole days between two scheduling days, robust to daylight saving.
  static int _daysBetween(DateTime from, DateTime to) =>
      (to.difference(from).inHours / 24).round();
}
