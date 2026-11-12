import 'package:drift/drift.dart';

import '../../domain/cards/direction_sense.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../domain/distillation/distillation_status.dart';
import '../database/alambic_database.dart';

/// Distillations in progress. A stopped or finished distillation is deleted;
/// its queued directions stay pending, released from it.
class DistillationRepository {
  const DistillationRepository(this._database);

  final AlambicDatabase _database;

  Future<int> insert({
    required int? groupId,
    required DirectionSense? sense,
    required DistillationSettings settings,
    required DateTime startedAt,
    required DateTime firstBatchDay,
  }) => _database
      .into(_database.distillations)
      .insert(
        DistillationsCompanion.insert(
          groupId: Value(groupId),
          sense: Value(sense),
          cardsPerBatch: settings.cardsPerBatch,
          everyDays: settings.everyDays,
          introductionOrder: settings.order,
          avoidCollisions: settings.avoidCollisions,
          status: DistillationStatus.running,
          startedAt: startedAt,
          nextBatchDay: firstBatchDay,
          introducedInBatch: 0,
        ),
      );

  Future<Distillation> get(int distillationId) => (_database.select(
    _database.distillations,
  )..where((row) => row.id.equals(distillationId))).getSingle();

  /// In launch order.
  Stream<List<Distillation>> watchAll() => _selectAll().watch();

  Future<List<Distillation>> getAll() => _selectAll().get();

  SimpleSelectStatement<$DistillationsTable, Distillation> _selectAll() =>
      _database.select(_database.distillations)
        ..orderBy([(row) => OrderingTerm.asc(row.id)]);

  Future<void> setStatus(int distillationId, DistillationStatus status) =>
      (_database.update(_database.distillations)
            ..where((row) => row.id.equals(distillationId)))
          .write(DistillationsCompanion(status: Value(status)));

  /// Records the day processed and where the batches stand.
  Future<void> saveProgress(
    int distillationId, {
    required DateTime advancedDay,
    required DateTime nextBatchDay,
    required int introducedInBatch,
  }) =>
      (_database.update(
        _database.distillations,
      )..where((row) => row.id.equals(distillationId))).write(
        DistillationsCompanion(
          lastAdvancedDay: Value(advancedDay),
          nextBatchDay: Value(nextBatchDay),
          introducedInBatch: Value(introducedInBatch),
        ),
      );

  /// Its pending directions stay pending, released from it.
  Future<void> delete(int distillationId) => (_database.delete(
    _database.distillations,
  )..where((row) => row.id.equals(distillationId))).go();
}
