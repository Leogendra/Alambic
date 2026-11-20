import 'dart:math' as math;

import '../../domain/scheduling/card_schedule.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../l10n/generated/app_localizations.dart';

/// When a card comes back, relative to [now]: "Due", "at 15:17",
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

  /// What an answer did, from the delay it gave: "Next in 3 d", "Next at
  /// 15:17", or "Card learned" for a card left without due date.
  String nextReviewLabel(
    CardSchedule schedule, {
    required DateTime answeredAt,
    required SchedulingCalendar calendar,
  }) => switch (schedule.dueAt) {
    null => nextReviewLearned,
    final dueAt => nextReview(
      dueDateLabel(dueAt, now: answeredAt, calendar: calendar),
    ),
  };

  /// How long until [dueAt], from [now]: "10 min" or "2 h" within the
  /// day, else the days, "3 d".
  String delayLabel(
    DateTime dueAt, {
    required DateTime now,
    required SchedulingCalendar calendar,
  }) {
    final days = calendar.daysBetween(now, dueAt);
    final minutes = math.max(1, (dueAt.difference(now).inSeconds / 60).ceil());
    if (days > 0) {
      return intervalDays(days);
    } else if (minutes < 60) {
      return intervalMinutes(minutes);
    } else {
      return intervalHours((minutes / 60).round());
    }
  }

  /// Whole days between two scheduling days, robust to daylight saving.
  static int _daysBetween(DateTime from, DateTime to) =>
      (to.difference(from).inHours / 24).round();
}
