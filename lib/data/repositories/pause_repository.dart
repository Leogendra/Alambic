import 'package:drift/drift.dart';

import '../database/alambic_database.dart';

/// The global pause, which holds every distillation back.
class PauseRepository {
  const PauseRepository(this._database);

  final AlambicDatabase _database;

  /// Start of the global pause, `null` when it is off; re-emitted whenever
  /// it changes.
  Stream<DateTime?> watchGlobalPause() =>
      _settingsRow().watchSingle().map((settings) => settings.pausedAt);

  Future<DateTime?> loadGlobalPause() async =>
      (await _settingsRow().getSingle()).pausedAt;

  Future<void> setGlobalPausedAt(DateTime? pausedAt) => _database
      .update(_database.appSettings)
      .write(AppSettingsCompanion(pausedAt: Value(pausedAt)));

  SimpleSelectStatement<$AppSettingsTable, AppSettingsRow> _settingsRow() =>
      _database.select(_database.appSettings);
}
