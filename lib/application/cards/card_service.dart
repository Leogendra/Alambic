import '../../data/repositories/card_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/direction_schedule.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';
import 'card_draft.dart';

/// Creates, edits and manages cards, and schedules the directions they start.
class CardService {
  const CardService({
    required this._cards,
    required this._presets,
    required this._scheduler,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final CardRepository _cards;
  final PresetRepository _presets;
  final ReviewScheduler _scheduler;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Stores a new card. Its front → back direction is due at the next preset
  /// slot; the reverse one is active only with [CardDraft.alsoReverse].
  Future<int> create(CardDraft draft) async {
    _checkComplete(draft);
    final cardId = await _cards.transaction(() async {
      final now = _clock();
      final cardId = await _cards.insertCard(
        groupId: draft.groupId,
        frontText: draft.frontText.trim(),
        backText: draft.backText.trim(),
        presetId: draft.presetId,
        createdAt: now,
      );
      await _insertDirections(cardId, draft.alsoReverse, now);
      return cardId;
    });
    await _scheduleChangeListener.onSchedulesChanged();
    return cardId;
  }

  /// Several cards at once, for the bulk add; returns how many were stored.
  Future<int> createAll(List<CardDraft> drafts) async {
    drafts.forEach(_checkComplete);
    await _cards.transaction(() async {
      for (final draft in drafts) {
        final now = _clock();
        final cardId = await _cards.insertCard(
          groupId: draft.groupId,
          frontText: draft.frontText.trim(),
          backText: draft.backText.trim(),
          presetId: draft.presetId,
          createdAt: now,
        );
        await _insertDirections(cardId, draft.alsoReverse, now);
      }
    });
    await _scheduleChangeListener.onSchedulesChanged();
    return drafts.length;
  }

  /// Updates the content of a card. Checking "also reverse" starts the reverse
  /// direction; unchecking it stops it, keeping its history.
  Future<void> update(int cardId, CardDraft draft) async {
    _checkComplete(draft);
    await _cards.transaction(() async {
      await _cards.updateCardContent(
        cardId: cardId,
        groupId: draft.groupId,
        frontText: draft.frontText.trim(),
        backText: draft.backText.trim(),
        presetId: draft.presetId,
      );
      await _applyReverseChoice(cardId, draft.alsoReverse);
    });
    await _scheduleChangeListener.onSchedulesChanged();
  }

  Future<void> setSuspended(int cardId, {required bool suspended}) async {
    await _cards.setSuspended(cardId, suspended: suspended);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Forgets the progression of both directions: every active direction starts
  /// again as a new one. The history is kept.
  Future<void> resetProgress(int cardId) async {
    await _cards.transaction(() async {
      final preset = await _presetOfCard(cardId);
      DateTime? previousDue;
      for (final direction in await _sortedDirections(cardId)) {
        if (direction.state == DirectionState.active ||
            direction.state == DirectionState.acquired) {
          final schedule = _scheduler.firstSchedule(
            preset: preset,
            now: _clock(),
            oppositeDueAt: previousDue,
          );
          await _cards.applySchedule(direction.id, schedule);
          previousDue = schedule.dueAt;
        }
      }
    });
    await _scheduleChangeListener.onSchedulesChanged();
  }

  Future<void> delete(int cardId) async {
    await _cards.deleteCard(cardId);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  Future<void> _insertDirections(
    int cardId,
    bool alsoReverse,
    DateTime now,
  ) async {
    final preset = await _presetOfCard(cardId);
    final front = _scheduler.firstSchedule(
      preset: preset,
      now: now,
      oppositeDueAt: null,
    );
    await _cards.insertDirection(
      cardId: cardId,
      sense: DirectionSense.frontToBack,
      schedule: front,
    );
    await _cards.insertDirection(
      cardId: cardId,
      sense: DirectionSense.backToFront,
      schedule: alsoReverse
          ? _scheduler.firstSchedule(
              preset: preset,
              now: now,
              oppositeDueAt: front.dueAt,
            )
          : DirectionSchedule.inactive,
    );
  }

  Future<void> _applyReverseChoice(int cardId, bool alsoReverse) async {
    final directions = await _cards.getDirections(cardId);
    final reverse = directions.firstWhere(
      (direction) => direction.sense == DirectionSense.backToFront,
    );
    final isStudied = reverse.state != DirectionState.inactive;
    if (alsoReverse && !isStudied) {
      final front = directions.firstWhere(
        (direction) => direction.sense == DirectionSense.frontToBack,
      );
      final schedule = _scheduler.firstSchedule(
        preset: await _presetOfCard(cardId),
        now: _clock(),
        oppositeDueAt: front.dueAt,
      );
      await _cards.applySchedule(reverse.id, schedule);
    } else if (!alsoReverse && reverse.state == DirectionState.active) {
      await _cards.deactivateDirection(reverse.id);
    }
  }

  Future<List<CardDirection>> _sortedDirections(int cardId) async =>
      (await _cards.getDirections(cardId))
        ..sort((first, second) => first.sense.index - second.sense.index);

  Future<Preset> _presetOfCard(int cardId) async {
    final catalog = await _presets.loadCatalog();
    return catalog.presetForCard(await _cards.getCard(cardId));
  }

  void _checkComplete(CardDraft draft) {
    if (!draft.isComplete) {
      throw ArgumentError('A card needs a front and a back.');
    }
  }
}
