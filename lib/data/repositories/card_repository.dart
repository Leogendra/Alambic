import 'package:drift/drift.dart';

import '../../domain/cards/card_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/scheduling/card_schedule.dart';
import '../database/alambic_database.dart';

/// Cards and their progression. Scheduling decisions are taken by the
/// application services; this repository only stores them.
class CardRepository {
  const CardRepository(this._database);

  final AlambicDatabase _database;

  Future<T> transaction<T>(Future<T> Function() action) =>
      _database.transaction(action);

  /// Stores a new card, pending at [queuePosition] in the queue of its group.
  Future<int> insertCard({
    required int groupId,
    required String? frontText,
    required String? frontImagePath,
    required String? backText,
    required String? backImagePath,
    required DateTime createdAt,
    required int queuePosition,
  }) => _database
      .into(_database.flashcards)
      .insert(
        FlashcardsCompanion.insert(
          groupId: groupId,
          frontText: Value(frontText),
          frontImagePath: Value(frontImagePath),
          backText: Value(backText),
          backImagePath: Value(backImagePath),
          createdAt: createdAt,
          state: CardState.pending,
          queuePosition: Value(queuePosition),
        ),
      );

  Future<void> updateCardContent({
    required int cardId,
    required int groupId,
    required String? frontText,
    required String? frontImagePath,
    required String? backText,
    required String? backImagePath,
  }) =>
      (_database.update(
        _database.flashcards,
      )..where((card) => card.id.equals(cardId))).write(
        FlashcardsCompanion(
          groupId: Value(groupId),
          frontText: Value(frontText),
          frontImagePath: Value(frontImagePath),
          backText: Value(backText),
          backImagePath: Value(backImagePath),
        ),
      );

  Future<void> setSuspended(int cardId, {required bool suspended}) =>
      (_database.update(_database.flashcards)
            ..where((card) => card.id.equals(cardId)))
          .write(FlashcardsCompanion(suspended: Value(suspended)));

  Future<void> deleteCard(int cardId) => (_database.delete(
    _database.flashcards,
  )..where((card) => card.id.equals(cardId))).go();

  Future<Flashcard> getCard(int cardId) => (_database.select(
    _database.flashcards,
  )..where((card) => card.id.equals(cardId))).getSingle();

  /// `null` once the card was deleted.
  Future<Flashcard?> findCard(int cardId) => (_database.select(
    _database.flashcards,
  )..where((card) => card.id.equals(cardId))).getSingleOrNull();

  /// Writes a new schedule. The card will be notified again for it.
  Future<void> applySchedule(
    int cardId,
    CardSchedule schedule, {
    DateTime? reviewedAt,
  }) =>
      (_database.update(
        _database.flashcards,
      )..where((card) => card.id.equals(cardId))).write(
        FlashcardsCompanion(
          state: Value(schedule.state),
          step: Value(schedule.step),
          dueAt: Value(schedule.dueAt),
          notifiedAt: const Value(null),
          queuePosition: const Value(null),
          lastReviewedAt: reviewedAt == null
              ? const Value.absent()
              : Value(reviewedAt),
        ),
      );

  /// Puts a card back in the queue of its group at [position], forgetting its
  /// progression. Its history is kept.
  Future<void> enqueue(int cardId, int position) =>
      (_database.update(
        _database.flashcards,
      )..where((card) => card.id.equals(cardId))).write(
        FlashcardsCompanion(
          state: const Value(CardState.pending),
          step: const Value(null),
          dueAt: const Value(null),
          notifiedAt: const Value(null),
          queuePosition: Value(position),
        ),
      );

  Future<void> setQueuePosition(int cardId, int position) =>
      (_database.update(_database.flashcards)
            ..where((card) => card.id.equals(cardId)))
          .write(FlashcardsCompanion(queuePosition: Value(position)));

  Future<void> markNotified(int cardId, DateTime notifiedAt) =>
      (_database.update(_database.flashcards)
            ..where((card) => card.id.equals(cardId)))
          .write(FlashcardsCompanion(notifiedAt: Value(notifiedAt)));

  Stream<Flashcard?> watchCard(int cardId) => (_database.select(
    _database.flashcards,
  )..where((card) => card.id.equals(cardId))).watchSingleOrNull();

  /// Cards of a group in creation order (the group order).
  Stream<List<Flashcard>> watchCardsOfGroup(int groupId) =>
      _selectGroup(groupId).watch();

  Future<List<Flashcard>> getCardsOfGroup(int groupId) =>
      _selectGroup(groupId).get();

  SimpleSelectStatement<$FlashcardsTable, Flashcard> _selectGroup(
    int groupId,
  ) => _database.select(_database.flashcards)
    ..where((card) => card.groupId.equals(groupId))
    ..orderBy([(card) => OrderingTerm.asc(card.id)]);

  /// Cards whose front or back contains [text], ignoring case.
  Stream<List<Flashcard>> watchSearch(String text) {
    final pattern = '%${text.trim()}%';
    return (_database.select(_database.flashcards)
          ..where(
            (card) =>
                card.frontText.like(pattern) | card.backText.like(pattern),
          )
          ..orderBy([(card) => OrderingTerm.asc(card.id)])
          ..limit(100))
        .watch();
  }

  /// Every card, in creation order.
  Stream<List<Flashcard>> watchAll() => _selectAll().watch();

  Future<List<Flashcard>> getAll() => _selectAll().get();

  SimpleSelectStatement<$FlashcardsTable, Flashcard> _selectAll() =>
      _database.select(_database.flashcards)
        ..orderBy([(card) => OrderingTerm.asc(card.id)]);
}
