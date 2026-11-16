import '../cards/flashcard.dart';
import 'clock_time.dart';
import 'scheduling_calendar.dart';

/// How the due dates move when the daily slot of the app changes.
///
/// Rules owned here:
/// - a due date still to come that falls on the old slot moves to the new
///   slot of the same scheduling day;
/// - a due date at another time of day, set by an interval of less than a
///   day, keeps its moment;
/// - a due date already passed is left alone: the card is due, and is
///   notified again at the new slot.
class DailySlotMove {
  const DailySlotMove(this.calendar);

  final SchedulingCalendar calendar;

  /// The due date of [card] at the [to] slot, `null` when it does not move.
  DateTime? movedDueAt(
    Flashcard card, {
    required ClockTime from,
    required ClockTime to,
    required DateTime now,
  }) {
    final dueAt = card.dueAt;
    if (from == to ||
        !card.isScheduled ||
        dueAt == null ||
        !dueAt.isAfter(now) ||
        ClockTime(dueAt.hour, dueAt.minute) != from) {
      return null;
    }
    return calendar.momentAt(calendar.dayOf(dueAt), to);
  }
}
