import 'package:drift/drift.dart';

import '../../../domain/cards/card_state.dart';
import '../../../domain/cards/flashcard.dart';
import 'card_groups.dart';

@UseRowClass(Flashcard)
@TableIndex(name: 'flashcards_due_at', columns: {#dueAt})
class Flashcards extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Deleting a group deletes its cards.
  IntColumn get groupId =>
      integer().references(CardGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get frontText => text().nullable()();
  TextColumn get frontImagePath => text().nullable()();
  TextColumn get backText => text().nullable()();
  TextColumn get backImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get state => textEnum<CardState>()();
  IntColumn get step => integer().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get notifiedAt => dateTime().nullable()();
  IntColumn get queuePosition => integer().nullable()();
}
