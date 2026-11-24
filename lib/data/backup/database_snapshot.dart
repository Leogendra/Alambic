import 'package:drift/drift.dart';

import '../database/alambic_database.dart';
import 'invalid_backup_exception.dart';
import 'invalid_backup_kind.dart';

/// Reads every row of the database and replaces them all, table by table and
/// as stored by SQLite, without going through the domain classes: a backup
/// is a copy of the data, not an interpretation of it.
class DatabaseSnapshot {
  const DatabaseSnapshot(this._database);

  /// Tables in the order rows can be inserted: a table comes after the
  /// tables its foreign keys point at. Deleting goes the other way round.
  static const List<String> insertionOrder = [
    'presets',
    'app_settings',
    'card_groups',
    'distillations',
    'flashcards',
    'review_records',
  ];

  final AlambicDatabase _database;

  int get schemaVersion => _database.schemaVersion;

  Future<Map<String, List<Map<String, Object?>>>> read() =>
      _database.transaction(() async {
        return {
          for (final table in insertionOrder)
            table: [
              for (final row
                  in await _database
                      .customSelect('SELECT * FROM "$table"')
                      .get())
                row.data,
            ],
        };
      });

  /// Checks that [tables] can be inserted as they are: same schema version,
  /// every table present, no unknown column. Done before anything is deleted.
  void validate(
    int backupSchemaVersion,
    Map<String, List<Map<String, Object?>>> tables,
  ) {
    if (backupSchemaVersion != schemaVersion) {
      throw InvalidBackupException(
        InvalidBackupKind.incompatibleVersion,
        'backup schema $backupSchemaVersion, this app uses $schemaVersion',
      );
    }
    for (final table in _database.allTables) {
      final rows = tables[table.actualTableName];
      if (rows == null) {
        throw InvalidBackupException(
          InvalidBackupKind.corrupted,
          'table ${table.actualTableName} is missing',
        );
      }
      final columns = {for (final column in table.$columns) column.name};
      for (final row in rows) {
        final unknown = row.keys.where((name) => !columns.contains(name));
        if (unknown.isNotEmpty) {
          throw InvalidBackupException(
            InvalidBackupKind.corrupted,
            'unknown column ${unknown.first} in ${table.actualTableName}',
          );
        }
      }
    }
  }

  /// Deletes every row and inserts [tables] in one transaction: a failure
  /// leaves the current data as it was.
  Future<void> replaceAll(
    Map<String, List<Map<String, Object?>>> tables,
  ) async {
    await _database.transaction(() async {
      for (final table in insertionOrder.reversed) {
        await _database.customStatement('DELETE FROM "$table"');
      }
      for (final table in insertionOrder) {
        for (final row in tables[table]!) {
          await _insert(table, row);
        }
      }
    });
    _database.markTablesUpdated(_database.allTables);
  }

  Future<void> _insert(String table, Map<String, Object?> row) {
    final columns = row.keys.map((name) => '"$name"').join(', ');
    final placeholders = List.filled(row.length, '?').join(', ');
    return _database.customInsert(
      'INSERT INTO "$table" ($columns) VALUES ($placeholders)',
      variables: [for (final value in row.values) Variable<Object>(value)],
    );
  }
}
