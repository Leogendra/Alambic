import 'package:drift/drift.dart';

import '../../domain/notifications/notification_guards.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../database/alambic_database.dart';

/// The schedule and mode of the notifications, and the safeguards.
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

  Stream<NotificationGuards> watchGuards() =>
      _settings().watchSingle().map(_guards);

  /// A plain read, like [loadReminderSettings]: an answer reads it inside a
  /// transaction.
  Future<NotificationGuards> loadGuards() =>
      _settings().getSingle().then(_guards);

  Future<void> saveGuards(NotificationGuards guards) => _database
      .update(_database.appSettings)
      .write(
        AppSettingsCompanion(
          smoothDueDates: Value(guards.smoothDueDates),
          quietHoursEnabled: Value(guards.quietHoursEnabled),
          quietStart: Value(guards.quietStart),
          quietEnd: Value(guards.quietEnd),
          autoGroupEnabled: Value(guards.autoGroupEnabled),
          autoGroupThreshold: Value(guards.autoGroupThreshold),
        ),
      );

  static NotificationGuards _guards(AppSettingsRow settings) =>
      NotificationGuards(
        smoothDueDates: settings.smoothDueDates,
        quietHoursEnabled: settings.quietHoursEnabled,
        quietStart: settings.quietStart,
        quietEnd: settings.quietEnd,
        autoGroupEnabled: settings.autoGroupEnabled,
        autoGroupThreshold: settings.autoGroupThreshold,
      );

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
