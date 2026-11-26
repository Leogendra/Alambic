import 'package:drift/drift.dart';

import '../../../domain/notifications/grouped_reminder_action.dart';
import '../../../domain/notifications/notification_mode.dart';
import '../../../domain/notifications/schedule_kind.dart';
import '../converters/clock_time_converter.dart';
import 'presets.dart';

/// Single-row table of settings that belong to the data (and to the export),
/// unlike interface preferences kept in shared_preferences.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  /// Always 1: the table holds a single row.
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get globalPresetId => integer().references(Presets, #id)();

  /// Schedule and notification mode of the whole app, see `ReminderSettings`.
  TextColumn get scheduleKind => textEnum<ScheduleKind>().withDefault(
    Constant(ScheduleKind.fixedTime.name),
  )();
  IntColumn get fixedTime => integer()
      .map(const ClockTimeConverter())
      .withDefault(const Constant(12 * 60))();
  IntColumn get rangeStart => integer()
      .map(const ClockTimeConverter())
      .withDefault(const Constant(9 * 60))();
  IntColumn get rangeEnd => integer()
      .map(const ClockTimeConverter())
      .withDefault(const Constant(18 * 60))();
  TextColumn get notificationMode => textEnum<NotificationMode>().withDefault(
    Constant(NotificationMode.perCard.name),
  )();
  TextColumn get groupedAction => textEnum<GroupedReminderAction>().withDefault(
    Constant(GroupedReminderAction.openApp.name),
  )();

  /// Notification safeguards, see `NotificationGuards`.
  BoolColumn get smoothDueDates =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get quietHoursEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get quietStart => integer()
      .map(const ClockTimeConverter())
      .withDefault(const Constant(22 * 60))();
  IntColumn get quietEnd => integer()
      .map(const ClockTimeConverter())
      .withDefault(const Constant(8 * 60))();
  BoolColumn get autoGroupEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get autoGroupThreshold =>
      integer().withDefault(const Constant(5))();

  /// Start of the global pause, `null` when it is off. It holds every
  /// distillation and every notification back.
  DateTimeColumn get pausedAt => dateTime().nullable()();

  /// Last scheduling day whose due dates the global pause moved forward,
  /// `null` when it is off.
  DateTimeColumn get pauseShiftedDay => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
