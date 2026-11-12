import 'package:drift/drift.dart';

import '../../../domain/cards/direction_sense.dart';
import '../../../domain/distillation/distillation.dart';
import '../../../domain/distillation/distillation_order.dart';
import '../../../domain/distillation/distillation_status.dart';
import 'card_groups.dart';

@UseRowClass(Distillation)
class Distillations extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Deleting a group deletes its distillations.
  IntColumn get groupId => integer().nullable().references(
    CardGroups,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get sense => textEnum<DirectionSense>().nullable()();
  IntColumn get cardsPerBatch => integer()();
  IntColumn get everyDays => integer()();
  TextColumn get introductionOrder => textEnum<DistillationOrder>()();
  BoolColumn get avoidCollisions => boolean()();
  TextColumn get status => textEnum<DistillationStatus>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get nextBatchDay => dateTime()();
  IntColumn get introducedInBatch => integer()();
  DateTimeColumn get lastAdvancedDay => dateTime().nullable()();
}
