import '../../data/repositories/card_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../domain/notifications/notification_guards.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../../domain/notifications/schedule_kind.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../domain/scheduling/daily_slot_move.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';

/// Changes to the schedule, the mode and the safeguards of the notifications,
/// which move the next notifications.
class NotificationSettingsService {
  const NotificationSettingsService({
    required this._settings,
    required this._cards,
    required this._slotMove,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final NotificationSettingsRepository _settings;
  final CardRepository _cards;
  final DailySlotMove _slotMove;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Saves the schedule and the mode. When the daily slot changes, the due
  /// dates set at the old slot move to the new one. A range whose end
  /// precedes its start is refused.
  Future<void> saveReminderSettings(ReminderSettings reminders) async {
    if (!reminders.hasOrderedRange) {
      throw ArgumentError('The end of a time range cannot precede its start');
    }
    await _cards.transaction(() async {
      final previous = await _settings.loadReminderSettings();
      await _settings.saveReminderSettings(reminders);
      if (previous.dailySlot != reminders.dailySlot) {
        await _moveDueDates(previous.dailySlot, reminders.dailySlot);
      }
    });
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// The reminder time chosen at onboarding: the schedule becomes this fixed
  /// time.
  Future<void> setFixedTime(ClockTime time) async {
    final reminders = await _settings.loadReminderSettings();
    await saveReminderSettings(
      reminders.copyWith(scheduleKind: ScheduleKind.fixedTime, fixedTime: time),
    );
  }

  Future<void> saveGuards(NotificationGuards guards) async {
    if (guards.autoGroupThreshold < 1) {
      throw ArgumentError('A threshold counts at least one card');
    }
    await _settings.saveGuards(guards);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  Future<void> _moveDueDates(ClockTime from, ClockTime to) async {
    final now = _clock();
    for (final card in await _cards.getAll()) {
      final moved = _slotMove.movedDueAt(card, from: from, to: to, now: now);
      if (moved != null) {
        await _cards.applySchedule(
          card.id,
          CardSchedule(state: card.state, step: card.step, dueAt: moved),
        );
      }
    }
  }
}
