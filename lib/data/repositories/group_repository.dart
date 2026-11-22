import 'package:drift/drift.dart';

import '../../domain/groups/after_last_step.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/groups/remanence_interval.dart';
import '../database/alambic_database.dart';

class GroupRepository {
  const GroupRepository(this._database);

  final AlambicDatabase _database;

  Stream<List<CardGroup>> watchAll() => (_database.select(
    _database.cardGroups,
  )..orderBy([(group) => OrderingTerm.asc(group.name)])).watch();

  Future<CardGroup?> find(int groupId) => (_database.select(
    _database.cardGroups,
  )..where((group) => group.id.equals(groupId))).getSingleOrNull();

  /// The first group named exactly [name], if any.
  Future<CardGroup?> findByName(String name) =>
      (_database.select(_database.cardGroups)
            ..where((group) => group.name.equals(name))
            ..orderBy([(group) => OrderingTerm.asc(group.id)])
            ..limit(1))
          .getSingleOrNull();

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

  /// The groups that chose [presetId] inherit the global preset again. The
  /// steps and due dates of their cards stay as they are.
  Future<void> releasePreset(int presetId) =>
      (_database.update(_database.cardGroups)
            ..where((group) => group.presetId.equals(presetId)))
          .write(const CardGroupsCompanion(presetId: Value(null)));

  /// Draws the asked face of each display of its cards, or always asks the
  /// front. Changes nothing to their progression.
  Future<void> setReverseEnabled(int groupId, {required bool enabled}) =>
      (_database.update(_database.cardGroups)
            ..where((group) => group.id.equals(groupId)))
          .write(CardGroupsCompanion(reverseEnabled: Value(enabled)));

  Future<void> setAfterLastStep(int groupId, AfterLastStep afterLastStep) =>
      (_database.update(_database.cardGroups)
            ..where((group) => group.id.equals(groupId)))
          .write(CardGroupsCompanion(afterLastStep: Value(afterLastStep)));

  /// Moves no due date: the new interval applies from the next answer.
  Future<void> setRemanenceInterval(int groupId, RemanenceInterval interval) =>
      (_database.update(_database.cardGroups)
            ..where((group) => group.id.equals(groupId)))
          .write(CardGroupsCompanion(remanenceInterval: Value(interval)));

  Future<void> setTypedAnswer(int groupId, {required bool enabled}) =>
      (_database.update(_database.cardGroups)
            ..where((group) => group.id.equals(groupId)))
          .write(CardGroupsCompanion(typedAnswer: Value(enabled)));

  /// Its cards, their history and its distillation are deleted with it.
  Future<void> delete(int groupId) => (_database.delete(
    _database.cardGroups,
  )..where((group) => group.id.equals(groupId))).go();
}
