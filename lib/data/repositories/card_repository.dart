import 'package:drift/drift.dart';

import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/scheduling/direction_schedule.dart';
import '../database/alambic_database.dart';
import 'card_with_directions.dart';

/// Cards and their directions. Scheduling decisions are taken by the
/// application services; this repository only stores them.
class CardRepository {
  const CardRepository(this._database);

  final AlambicDatabase _database;

  Future<T> transaction<T>(Future<T> Function() action) =>
      _database.transaction(action);

  Future<int> insertCard({
    required int? groupId,
    required String? frontText,
    required String? frontImagePath,
    required String? backText,
    required String? backImagePath,
    required int? presetId,
    required DateTime createdAt,
  }) => _database
      .into(_database.flashcards)
      .insert(
        FlashcardsCompanion.insert(
          groupId: Value(groupId),
          frontText: Value(frontText),
          frontImagePath: Value(frontImagePath),
          backText: Value(backText),
          backImagePath: Value(backImagePath),
          presetId: Value(presetId),
          createdAt: createdAt,
        ),
      );

  Future<void> updateCardContent({
    required int cardId,
    required int? groupId,
    required String? frontText,
    required String? frontImagePath,
    required String? backText,
    required String? backImagePath,
    required int? presetId,
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
          presetId: Value(presetId),
        ),
      );

  /// A preset change keeps the step and the due date of both directions.
  Future<void> setCardPreset(int cardId, int? presetId) =>
      (_database.update(_database.flashcards)
            ..where((card) => card.id.equals(cardId)))
          .write(FlashcardsCompanion(presetId: Value(presetId)));

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

  Future<CardDirection> getDirection(int directionId) => (_database.select(
    _database.cardDirections,
  )..where((direction) => direction.id.equals(directionId))).getSingle();

  /// `null` once the card was deleted.
  Future<CardDirection?> findDirection(int directionId) => (_database.select(
    _database.cardDirections,
  )..where((direction) => direction.id.equals(directionId))).getSingleOrNull();

  Future<List<CardDirection>> getDirections(int cardId) => (_database.select(
    _database.cardDirections,
  )..where((direction) => direction.cardId.equals(cardId))).get();

  Future<void> insertDirection({
    required int cardId,
    required DirectionSense sense,
    required DirectionSchedule schedule,
  }) => _database
      .into(_database.cardDirections)
      .insert(
        CardDirectionsCompanion.insert(
          cardId: cardId,
          sense: sense,
          state: schedule.state,
          step: Value(schedule.step),
          stability: Value(schedule.memory?.stability),
          difficulty: Value(schedule.memory?.difficulty),
          dueAt: Value(schedule.dueAt),
        ),
      );

  /// Writes a new schedule. The direction will be notified again for it.
  Future<void> applySchedule(
    int directionId,
    DirectionSchedule schedule, {
    DateTime? reviewedAt,
  }) =>
      (_database.update(
        _database.cardDirections,
      )..where((direction) => direction.id.equals(directionId))).write(
        CardDirectionsCompanion(
          state: Value(schedule.state),
          step: Value(schedule.step),
          stability: Value(schedule.memory?.stability),
          difficulty: Value(schedule.memory?.difficulty),
          dueAt: Value(schedule.dueAt),
          notifiedAt: const Value(null),
          lastReviewedAt: reviewedAt == null
              ? const Value.absent()
              : Value(reviewedAt),
        ),
      );

  /// Stops studying a direction; it leaves any distillation.
  Future<void> deactivateDirection(int directionId) async {
    await applySchedule(directionId, DirectionSchedule.inactive);
    await releaseFromDistillation(directionId);
  }

  /// Puts a direction in the queue of a distillation, at [position] (`null`
  /// to hold it until it gets one).
  Future<void> enqueue(
    int directionId, {
    required int distillationId,
    required int? position,
  }) =>
      (_database.update(
        _database.cardDirections,
      )..where((direction) => direction.id.equals(directionId))).write(
        CardDirectionsCompanion(
          state: const Value(DirectionState.pending),
          step: const Value(null),
          stability: const Value(null),
          difficulty: const Value(null),
          dueAt: const Value(null),
          notifiedAt: const Value(null),
          distillationId: Value(distillationId),
          queuePosition: Value(position),
        ),
      );

  Future<void> setQueuePosition(int directionId, int? position) =>
      (_database.update(_database.cardDirections)
            ..where((direction) => direction.id.equals(directionId)))
          .write(CardDirectionsCompanion(queuePosition: Value(position)));

  /// Takes a direction out of its distillation; a pending one stays pending,
  /// waiting to be started by hand or by another distillation.
  Future<void> releaseFromDistillation(int directionId) =>
      (_database.update(
        _database.cardDirections,
      )..where((direction) => direction.id.equals(directionId))).write(
        const CardDirectionsCompanion(
          distillationId: Value(null),
          queuePosition: Value(null),
        ),
      );

  /// Directions queued or introduced by a distillation.
  Future<List<CardDirection>> getDistilled(int distillationId) =>
      (_database.select(_database.cardDirections)..where(
            (direction) => direction.distillationId.equals(distillationId),
          ))
          .get();

  /// Directions queued or introduced by any distillation.
  Stream<List<CardDirection>> watchAllDistilled() => (_database.select(
    _database.cardDirections,
  )..where((direction) => direction.distillationId.isNotNull())).watch();

  Future<void> markNotified(int directionId, DateTime notifiedAt) =>
      (_database.update(_database.cardDirections)
            ..where((direction) => direction.id.equals(directionId)))
          .write(CardDirectionsCompanion(notifiedAt: Value(notifiedAt)));

  Stream<CardWithDirections?> watchCard(int cardId) => _watchWithDirections(
    () => (_database.select(
      _database.flashcards,
    )..where((card) => card.id.equals(cardId))).get(),
  ).map((cards) => cards.isEmpty ? null : cards.single);

  /// Cards of a group, or of "No group" when [groupId] is `null`, in
  /// creation order (the group order).
  Stream<List<CardWithDirections>> watchCardsOfGroup(int? groupId) =>
      _watchWithDirections(
        () =>
            (_database.select(_database.flashcards)
                  ..where(
                    (card) => groupId == null
                        ? card.groupId.isNull()
                        : card.groupId.equals(groupId),
                  )
                  ..orderBy([(card) => OrderingTerm.asc(card.id)]))
                .get(),
      );

  Future<List<CardWithDirections>> getCardsOfGroup(int? groupId) =>
      watchCardsOfGroup(groupId).first;

  /// Cards whose front or back contains [text], ignoring case.
  Stream<List<CardWithDirections>> watchSearch(String text) {
    final pattern = '%${text.trim()}%';
    return _watchWithDirections(
      () =>
          (_database.select(_database.flashcards)
                ..where(
                  (card) =>
                      card.frontText.like(pattern) |
                      card.backText.like(pattern),
                )
                ..orderBy([(card) => OrderingTerm.asc(card.id)])
                ..limit(100))
              .get(),
    );
  }

  /// Every card with its directions.
  Stream<List<CardWithDirections>> watchAll() =>
      _watchWithDirections(() => _database.select(_database.flashcards).get());

  Future<List<CardWithDirections>> getAll() => watchAll().first;

  /// Re-reads [readCards] and joins their directions whenever a card or a
  /// direction changes, so that every list stays consistent with both tables.
  Stream<List<CardWithDirections>> _watchWithDirections(
    Future<List<Flashcard>> Function() readCards,
  ) => _database
      .customSelect(
        'SELECT 1',
        readsFrom: {_database.flashcards, _database.cardDirections},
      )
      .watch()
      .asyncMap(
        (_) => _database.transaction(() async {
          final cards = await readCards();
          final directions = await _database
              .select(_database.cardDirections)
              .get();
          return _join(cards, directions);
        }),
      );

  List<CardWithDirections> _join(
    List<Flashcard> cards,
    List<CardDirection> directions,
  ) {
    final directionsByCard = <int, List<CardDirection>>{};
    for (final direction in directions) {
      directionsByCard.putIfAbsent(direction.cardId, () => []).add(direction);
    }
    return [
      for (final card in cards)
        CardWithDirections(
          card: card,
          directions: directionsByCard[card.id] ?? const [],
        ),
    ];
  }
}
