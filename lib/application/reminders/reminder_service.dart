import '../../data/repositories/reminder_repository.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';

/// Adds and removes "Review soon" reminders. Answering one is a bonus review:
/// a reminder never changes the step or the due date of its card.
class ReminderService {
  const ReminderService({
    required this._reminders,
    required this._calendar,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final ReminderRepository _reminders;
  final SchedulingCalendar _calendar;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Adds a reminder on [day] at [time]; a moment already past is refused.
  Future<int> add(int cardId, DateTime day, ClockTime time) async {
    final remindAt = _calendar.momentAt(day, time);
    if (!remindAt.isAfter(_clock())) {
      throw ArgumentError.value(remindAt, 'remindAt', 'must be in the future');
    }
    final id = await _reminders.insert(cardId, remindAt);
    await _scheduleChangeListener.onSchedulesChanged();
    return id;
  }

  Future<void> remove(int reminderId) async {
    await _reminders.delete(reminderId);
    await _scheduleChangeListener.onSchedulesChanged();
  }
}
