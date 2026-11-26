import 'package:drift/drift.dart';

import '../database/alambic_database.dart';

/// The global pause, which holds every distillation and notification back
/// and moves the due dates forward day after day.
class PauseRepository {
  const PauseRepository(this._database);

  final AlambicDatabase _database;

  /// Start of the global pause, `null` when it is off; re-emitted whenever
  /// it changes.
  Stream<DateTime?> watchGlobalPause() =>
      _settingsRow().watchSingle().map((settings) => settings.pausedAt);

  Future<DateTime?> loadGlobalPause() async =>
      (await _settingsRow().getSingle()).pausedAt;

  /// Starts the global pause at [pausedAt]; the due dates are up to date
  /// until [shiftedDay].
  Future<void> startGlobalPause(
    DateTime pausedAt, {
    required DateTime shiftedDay,
  }) => _write(
    AppSettingsCompanion(
      pausedAt: Value(pausedAt),
      pauseShiftedDay: Value(shiftedDay),
    ),
  );

  Future<void> endGlobalPause() => _write(
    const AppSettingsCompanion(
      pausedAt: Value(null),
      pauseShiftedDay: Value(null),
    ),
  );

  /// Last day whose due dates the global pause moved forward, `null` when
  /// the pause is off.
  Future<DateTime?> loadShiftedDay() async =>
      (await _settingsRow().getSingle()).pauseShiftedDay;

  Future<void> saveShiftedDay(DateTime day) =>
      _write(AppSettingsCompanion(pauseShiftedDay: Value(day)));

  Future<void> _write(AppSettingsCompanion settings) =>
      _database.update(_database.appSettings).write(settings);

  SimpleSelectStatement<$AppSettingsTable, AppSettingsRow> _settingsRow() =>
      _database.select(_database.appSettings);
}
