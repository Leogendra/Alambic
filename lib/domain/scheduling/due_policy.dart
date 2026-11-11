import '../cards/card_direction.dart';
import 'scheduling_calendar.dart';

/// Decides which directions are "due".
class DuePolicy {
  const DuePolicy(this.calendar);

  final SchedulingCalendar calendar;

  /// Due today: its due moment has passed, or its due day is today (or
  /// earlier) and it has not been answered yet today. The second half lets the
  /// user review in the app before the notification slot, while an interval of
  /// less than a day waits until its due moment.
  bool isDueToday(
    CardDirection direction, {
    required bool cardSuspended,
    required DateTime now,
  }) {
    final dueAt = direction.dueAt;
    if (cardSuspended || !direction.isScheduled || dueAt == null) {
      return false;
    } else if (!dueAt.isAfter(now)) {
      return true;
    } else {
      final today = calendar.dayOf(now);
      final lastReviewedAt = direction.lastReviewedAt;
      final dueDayReached = !calendar.dayOf(dueAt).isAfter(today);
      final answeredToday =
          lastReviewedAt != null && calendar.dayOf(lastReviewedAt) == today;
      return dueDayReached && !answeredToday;
    }
  }
}
