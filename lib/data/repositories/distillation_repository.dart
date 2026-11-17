import 'package:drift/drift.dart';

import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../domain/distillation/distillation_status.dart';
import '../database/alambic_database.dart';

/// The distillations of the groups, one per group once activated.
class DistillationRepository {
  const DistillationRepository(this._database);

  final AlambicDatabase _database;

  Future<void> insert({
    required int groupId,
    required DistillationSettings settings,
    required DateTime startedAt,
    required DateTime firstBatchDay,
  }) => _database
      .into(_database.distillations)
      .insert(
        DistillationsCompanion.insert(
          groupId: Value(groupId),
          cardsPerBatch: settings.cardsPerBatch,
          everyDays: settings.everyDays,
          avoidCollisions: settings.avoidCollisions,
          status: DistillationStatus.running,
          startedAt: startedAt,
          nextBatchDay: firstBatchDay,
          introducedInBatch: 0,
        ),
      );

  /// `null` while the distillation of the group was never activated.
  Future<Distillation?> find(int groupId) => (_database.select(
    _database.distillations,
  )..where((row) => row.groupId.equals(groupId))).getSingleOrNull();

  Stream<List<Distillation>> watchAll() => _selectAll().watch();

  Future<List<Distillation>> getAll() => _selectAll().get();

  SimpleSelectStatement<$DistillationsTable, Distillation> _selectAll() =>
      _database.select(_database.distillations)
        ..orderBy([(row) => OrderingTerm.asc(row.groupId)]);

  Future<void> setStatus(int groupId, DistillationStatus status) =>
      (_database.update(_database.distillations)
            ..where((row) => row.groupId.equals(groupId)))
          .write(DistillationsCompanion(status: Value(status)));

  /// Writes new settings and where the current batch stands under them.
  Future<void> saveSettings(
    int groupId,
    DistillationSettings settings, {
    required DateTime nextBatchDay,
    required int introducedInBatch,
  }) =>
      (_database.update(
        _database.distillations,
      )..where((row) => row.groupId.equals(groupId))).write(
        DistillationsCompanion(
          cardsPerBatch: Value(settings.cardsPerBatch),
          everyDays: Value(settings.everyDays),
          avoidCollisions: Value(settings.avoidCollisions),
          nextBatchDay: Value(nextBatchDay),
          introducedInBatch: Value(introducedInBatch),
        ),
      );

  /// Records the day processed and where the batches stand.
  Future<void> saveProgress(
    int groupId, {
    required DateTime advancedDay,
    required DateTime nextBatchDay,
    required int introducedInBatch,
  }) =>
      (_database.update(
        _database.distillations,
      )..where((row) => row.groupId.equals(groupId))).write(
        DistillationsCompanion(
          lastAdvancedDay: Value(advancedDay),
          nextBatchDay: Value(nextBatchDay),
          introducedInBatch: Value(introducedInBatch),
        ),
      );
}
