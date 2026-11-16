import 'package:drift/drift.dart';

import '../../../domain/distillation/distillation.dart';
import '../../../domain/distillation/distillation_order.dart';
import '../../../domain/distillation/distillation_status.dart';
import 'card_groups.dart';

/// One row per group whose distillation was activated.
@UseRowClass(Distillation)
class Distillations extends Table {
  /// Deleting a group deletes its distillation.
  IntColumn get groupId =>
      integer().references(CardGroups, #id, onDelete: KeyAction.cascade)();
  IntColumn get cardsPerBatch => integer()();
  IntColumn get everyDays => integer()();
  TextColumn get introductionOrder => textEnum<DistillationOrder>()();
  BoolColumn get avoidCollisions => boolean()();
  TextColumn get status => textEnum<DistillationStatus>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get nextBatchDay => dateTime()();
  IntColumn get introducedInBatch => integer()();
  DateTimeColumn get lastAdvancedDay => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {groupId};
}
