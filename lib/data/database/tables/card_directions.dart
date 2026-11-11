import 'package:drift/drift.dart';

import '../../../domain/cards/card_direction.dart';
import '../../../domain/cards/direction_sense.dart';
import '../../../domain/cards/direction_state.dart';
import 'flashcards.dart';

@UseRowClass(CardDirection)
@TableIndex(name: 'card_directions_due_at', columns: {#dueAt})
class CardDirections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId =>
      integer().references(Flashcards, #id, onDelete: KeyAction.cascade)();
  TextColumn get sense => textEnum<DirectionSense>()();
  TextColumn get state => textEnum<DirectionState>()();
  IntColumn get step => integer().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get notifiedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {cardId, sense},
  ];
}
