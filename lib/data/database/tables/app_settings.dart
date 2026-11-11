import 'package:drift/drift.dart';

import 'presets.dart';

/// Single-row table of settings that belong to the data (and to the export),
/// unlike interface preferences kept in shared_preferences.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  /// Always 1: the table holds a single row.
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get globalPresetId => integer().references(Presets, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
