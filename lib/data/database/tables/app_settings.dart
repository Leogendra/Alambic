import 'package:drift/drift.dart';

import '../converters/clock_time_converter.dart';
import 'presets.dart';

/// Single-row table of settings that belong to the data (and to the export),
/// unlike interface preferences kept in shared_preferences.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  /// Always 1: the table holds a single row.
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get globalPresetId => integer().references(Presets, #id)();

  /// Notification safeguards, see `NotificationGuards`.
  IntColumn get dailyNotificationCap =>
      integer().withDefault(const Constant(20))();
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

  /// Cards notified on [notifiedDay], counted against the daily cap.
  DateTimeColumn get notifiedDay => dateTime().nullable()();
  IntColumn get notifiedCount => integer().withDefault(const Constant(0))();

  /// Start of the global pause, `null` when it is off.
  DateTimeColumn get pausedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
