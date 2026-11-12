import '../cards/card_direction.dart';
import '../scheduling/scheduling_calendar.dart';

/// How the due dates move when a pause ends.
///
/// Rules owned here:
/// - a due date is shifted by as many days as the pause lasted, counted in
///   scheduling days, and keeps its time of day;
/// - a direction answered during the pause already has a due date chosen
///   after the pause started: it is not shifted.
class PauseShift {
  const PauseShift(this.calendar);

  final SchedulingCalendar calendar;

  /// Days a pause from [pausedAt] to [resumedAt] lasted.
  int days(DateTime pausedAt, DateTime resumedAt) =>
      (calendar.dayOf(resumedAt).difference(calendar.dayOf(pausedAt)).inHours /
              24)
          .round();

  /// The due date of [direction] once the pause ends, `null` when it does not
  /// move.
  DateTime? shiftedDueAt(
    CardDirection direction, {
    required DateTime pausedAt,
    required DateTime resumedAt,
  }) {
    final dueAt = direction.dueAt;
    final lastReviewedAt = direction.lastReviewedAt;
    final shift = days(pausedAt, resumedAt);
    if (!direction.isScheduled ||
        dueAt == null ||
        shift <= 0 ||
        (lastReviewedAt != null && !lastReviewedAt.isBefore(pausedAt))) {
      return null;
    }
    return DateTime(
      dueAt.year,
      dueAt.month,
      dueAt.day + shift,
      dueAt.hour,
      dueAt.minute,
      dueAt.second,
    );
  }
}
