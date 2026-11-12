import 'package:drift/drift.dart';

import '../../domain/groups/card_group.dart';
import '../database/alambic_database.dart';

class GroupRepository {
  const GroupRepository(this._database);

  final AlambicDatabase _database;

  Stream<List<CardGroup>> watchAll() => (_database.select(
    _database.cardGroups,
  )..orderBy([(group) => OrderingTerm.asc(group.name)])).watch();

  Stream<CardGroup?> watchById(int groupId) => (_database.select(
    _database.cardGroups,
  )..where((group) => group.id.equals(groupId))).watchSingleOrNull();

  Future<int> create(String name, DateTime createdAt) => _database
      .into(_database.cardGroups)
      .insert(CardGroupsCompanion.insert(name: name, createdAt: createdAt));

  Future<void> rename(int groupId, String name) =>
      (_database.update(_database.cardGroups)
            ..where((group) => group.id.equals(groupId)))
          .write(CardGroupsCompanion(name: Value(name)));

  /// A preset change keeps the step and the due date of every card.
  Future<void> setPreset(int groupId, int? presetId) =>
      (_database.update(_database.cardGroups)
            ..where((group) => group.id.equals(groupId)))
          .write(CardGroupsCompanion(presetId: Value(presetId)));

  /// Its cards, their directions and their history are deleted with it.
  Future<void> delete(int groupId) => (_database.delete(
    _database.cardGroups,
  )..where((group) => group.id.equals(groupId))).go();
}
