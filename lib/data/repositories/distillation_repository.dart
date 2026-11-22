import 'package:drift/drift.dart';

import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_settings.dart';
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
          prioritizeReviews: settings.prioritizeReviews,
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

  /// Pauses the distillation of a group since [pausedAt], or resumes it
  /// with `null`.
  Future<void> setPausedAt(int groupId, DateTime? pausedAt) =>
      (_database.update(_database.distillations)
            ..where((row) => row.groupId.equals(groupId)))
          .write(DistillationsCompanion(pausedAt: Value(pausedAt)));

  Future<void> saveSettings(int groupId, DistillationSettings settings) =>
      (_database.update(
        _database.distillations,
      )..where((row) => row.groupId.equals(groupId))).write(
        DistillationsCompanion(
          cardsPerBatch: Value(settings.cardsPerBatch),
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
