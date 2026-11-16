import 'package:drift/drift.dart';

import '../../domain/notifications/notification_guards.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../database/alambic_database.dart';

/// The schedule and mode of the notifications, the safeguards, and the count
/// of cards notified today that the daily cap is checked against.
class NotificationSettingsRepository {
  const NotificationSettingsRepository(this._database);

  final AlambicDatabase _database;

  Stream<ReminderSettings> watchReminderSettings() =>
      _settings().watchSingle().map(_reminderSettings);

  /// A plain read rather than the first value of a stream: it may run inside
  /// a transaction while a screen watches the same query.
  Future<ReminderSettings> loadReminderSettings() =>
      _settings().getSingle().then(_reminderSettings);

  Future<void> saveReminderSettings(ReminderSettings reminders) => _database
      .update(_database.appSettings)
      .write(
        AppSettingsCompanion(
          scheduleKind: Value(reminders.scheduleKind),
          fixedTime: Value(reminders.fixedTime),
          rangeStart: Value(reminders.rangeStart),
          rangeEnd: Value(reminders.rangeEnd),
          notificationMode: Value(reminders.notificationMode),
          groupedAction: Value(reminders.groupedAction),
        ),
      );

  Stream<NotificationGuards> watchGuards() => _settings().watchSingle().map(
    (settings) => NotificationGuards(
      dailyCap: settings.dailyNotificationCap,
      quietHoursEnabled: settings.quietHoursEnabled,
      quietStart: settings.quietStart,
      quietEnd: settings.quietEnd,
      autoGroupEnabled: settings.autoGroupEnabled,
      autoGroupThreshold: settings.autoGroupThreshold,
    ),
  );

  Future<NotificationGuards> loadGuards() => watchGuards().first;

  Future<void> saveGuards(NotificationGuards guards) => _database
      .update(_database.appSettings)
      .write(
        AppSettingsCompanion(
          dailyNotificationCap: Value(guards.dailyCap),
          quietHoursEnabled: Value(guards.quietHoursEnabled),
          quietStart: Value(guards.quietStart),
          quietEnd: Value(guards.quietEnd),
          autoGroupEnabled: Value(guards.autoGroupEnabled),
          autoGroupThreshold: Value(guards.autoGroupThreshold),
        ),
      );

  /// Cards notified on the scheduling [day].
  Stream<int> watchNotifiedOn(DateTime day) => _settings().watchSingle().map(
    (settings) => settings.notifiedDay == day ? settings.notifiedCount : 0,
  );

  Future<int> notifiedOn(DateTime day) => watchNotifiedOn(day).first;

  /// Counts [count] more cards notified on the scheduling [day].
  Future<void> addNotified(DateTime day, int count) =>
      _database.transaction(() async {
        final already = await notifiedOn(day);
        await _database
            .update(_database.appSettings)
            .write(
              AppSettingsCompanion(
                notifiedDay: Value(day),
                notifiedCount: Value(already + count),
              ),
            );
      });

  static ReminderSettings _reminderSettings(AppSettingsRow settings) =>
      ReminderSettings(
        scheduleKind: settings.scheduleKind,
        fixedTime: settings.fixedTime,
        rangeStart: settings.rangeStart,
        rangeEnd: settings.rangeEnd,
        notificationMode: settings.notificationMode,
        groupedAction: settings.groupedAction,
      );

  SimpleSelectStatement<$AppSettingsTable, AppSettingsRow> _settings() =>
      _database.select(_database.appSettings);
}
