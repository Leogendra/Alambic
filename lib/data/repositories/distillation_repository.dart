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
  }) => _database
      .into(_database.distillations)
      .insert(
        DistillationsCompanion.insert(
          groupId: Value(groupId),
          cardsPerBatch: settings.cardsPerBatch,
          everyDays: settings.everyDays,
          prioritizeReviews: settings.prioritizeReviews,
          status: DistillationStatus.running,
          startedAt: startedAt,
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

  Future<void> saveSettings(int groupId, DistillationSettings settings) =>
      (_database.update(
        _database.distillations,
      )..where((row) => row.groupId.equals(groupId))).write(
        DistillationsCompanion(
          cardsPerBatch: Value(settings.cardsPerBatch),
          everyDays: Value(settings.everyDays),
          prioritizeReviews: Value(settings.prioritizeReviews),
        ),
      );

  /// Records the day processed and, when a batch came out that day, the
  /// day of the last batch.
  Future<void> saveProgress(
    int groupId, {
    required DateTime advancedDay,
    required bool batchCameOut,
  }) =>
      (_database.update(
        _database.distillations,
      )..where((row) => row.groupId.equals(groupId))).write(
        DistillationsCompanion(
          lastAdvancedDay: Value(advancedDay),
          lastBatchDay: batchCameOut
              ? Value(advancedDay)
              : const Value.absent(),
        ),
      );
}
