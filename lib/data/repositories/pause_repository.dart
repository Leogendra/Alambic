import 'package:drift/drift.dart';

import '../../domain/pauses/pauses.dart';
import '../database/alambic_database.dart';

/// The global pause and the pauses of groups.
class PauseRepository {
  const PauseRepository(this._database);

  final AlambicDatabase _database;

  /// Re-emitted whenever the global pause or a group changes.
  Stream<Pauses> watchPauses() => _database
      .customSelect(
        'SELECT 1',
        readsFrom: {_database.appSettings, _database.cardGroups},
      )
      .watch()
      .asyncMap((_) => _readPauses());

  Future<Pauses> loadPauses() => _readPauses();

  Future<void> setGlobalPausedAt(DateTime? pausedAt) => _database
      .update(_database.appSettings)
      .write(AppSettingsCompanion(pausedAt: Value(pausedAt)));

  Future<void> setGroupPausedAt(int groupId, DateTime? pausedAt) =>
      (_database.update(_database.cardGroups)
            ..where((group) => group.id.equals(groupId)))
          .write(CardGroupsCompanion(pausedAt: Value(pausedAt)));

  Future<Pauses> _readPauses() => _database.transaction(() async {
    final settings = await _database.select(_database.appSettings).getSingle();
    final groups = await (_database.select(
      _database.cardGroups,
    )..where((group) => group.pausedAt.isNotNull())).get();
    return Pauses(
      globalSince: settings.pausedAt,
      groupsSince: {for (final group in groups) group.id: group.pausedAt!},
    );
  });
}
