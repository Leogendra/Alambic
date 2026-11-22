import 'package:drift/drift.dart';

import '../../../domain/distillation/distillation.dart';
import 'card_groups.dart';

/// One row per group whose distillation was activated.
@UseRowClass(Distillation)
class Distillations extends Table {
  /// Deleting a group deletes its distillation.
  IntColumn get groupId =>
      integer().references(CardGroups, #id, onDelete: KeyAction.cascade)();
  IntColumn get cardsPerBatch => integer()();
  BoolColumn get prioritizeReviews => boolean()();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastBatchDay => dateTime().nullable()();
  DateTimeColumn get lastAdvancedDay => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {groupId};
}
