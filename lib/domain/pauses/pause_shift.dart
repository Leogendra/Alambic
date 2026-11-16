import '../cards/flashcard.dart';
import '../scheduling/scheduling_calendar.dart';

/// How the due dates move when a pause ends.
///
/// Rules owned here:
/// - a due date is shifted by as many days as the pause lasted, counted in
///   scheduling days, and keeps its time of day;
/// - a card answered during the pause already has a due date chosen
///   after the pause started: it is not shifted.
class PauseShift {
  const PauseShift(this.calendar);

  final SchedulingCalendar calendar;

  /// Days a pause from [pausedAt] to [resumedAt] lasted.
  int days(DateTime pausedAt, DateTime resumedAt) =>
      calendar.daysBetween(pausedAt, resumedAt);

  /// The due date of [card] once the pause ends, `null` when it does not
  /// move.
  DateTime? shiftedDueAt(
    Flashcard card, {
    required DateTime pausedAt,
    required DateTime resumedAt,
  }) {
    final dueAt = card.dueAt;
    final lastReviewedAt = card.lastReviewedAt;
    final shift = days(pausedAt, resumedAt);
    if (!card.isScheduled ||
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
