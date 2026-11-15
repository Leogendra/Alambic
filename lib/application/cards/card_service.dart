import '../../data/images/image_store.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/direction_schedule.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../clock.dart';
import '../distillation/distillation_service.dart';
import '../scheduling/schedule_change_listener.dart';
import 'card_draft.dart';
import 'draft_image.dart';

/// Creates, edits and manages cards, and starts their directions.
class CardService {
  const CardService({
    required this._cards,
    required this._presets,
    required this._images,
    required this._scheduler,
    required this._distillations,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final CardRepository _cards;
  final PresetRepository _presets;
  final ImageStore _images;
  final ReviewScheduler _scheduler;
  final DistillationService _distillations;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Stores a new card. It is never due by itself: its front → back direction,
  /// and the reverse one with [CardDraft.alsoReverse], wait to be started, or
  /// join the end of the queue of the distillation covering them.
  Future<int> create(CardDraft draft) async {
    _checkComplete(draft);
    final frontImage = await _store(draft.frontImage);
    final backImage = await _store(draft.backImage);
    final cardId = await _cards.transaction(() async {
      final now = _clock();
      final cardId = await _cards.insertCard(
        groupId: draft.groupId,
        frontText: _textOf(draft.frontText),
        frontImagePath: frontImage,
        backText: _textOf(draft.backText),
        backImagePath: backImage,
        presetId: draft.presetId,
        createdAt: now,
      );
      await _insertDirections(cardId, draft.alsoReverse);
      return cardId;
    });
    await _distillations.joinQueues(cardId);
    await _scheduleChangeListener.onSchedulesChanged();
    return cardId;
  }

  /// Several cards at once, for the bulk add; returns how many were stored.
  Future<int> createAll(List<CardDraft> drafts) async {
    drafts.forEach(_checkComplete);
    final cardIds = await _cards.transaction(() async {
      final cardIds = <int>[];
      for (final draft in drafts) {
        final now = _clock();
        final cardId = await _cards.insertCard(
          groupId: draft.groupId,
          frontText: _textOf(draft.frontText),
          frontImagePath: null,
          backText: _textOf(draft.backText),
          backImagePath: null,
          presetId: draft.presetId,
          createdAt: now,
        );
        await _insertDirections(cardId, draft.alsoReverse);
        cardIds.add(cardId);
      }
      return cardIds;
    });
    for (final cardId in cardIds) {
      await _distillations.joinQueues(cardId);
    }
    await _scheduleChangeListener.onSchedulesChanged();
    return drafts.length;
  }

  /// Updates the content of a card. Checking "also reverse" adds the reverse
  /// direction, waiting to be started; unchecking it stops it, keeping its
  /// history. A card moved to another group follows the distillations of its
  /// new group. An image replaced or removed leaves the image store.
  Future<void> update(int cardId, CardDraft draft) async {
    _checkComplete(draft);
    final previous = await _cards.getCard(cardId);
    final frontImage = await _store(draft.frontImage);
    final backImage = await _store(draft.backImage);
    await _cards.transaction(() async {
      await _cards.updateCardContent(
        cardId: cardId,
        groupId: draft.groupId,
        frontText: _textOf(draft.frontText),
        frontImagePath: frontImage,
        backText: _textOf(draft.backText),
        backImagePath: backImage,
        presetId: draft.presetId,
      );
      await _applyReverseChoice(cardId, draft.alsoReverse);
    });
    for (final image in [previous.frontImagePath, previous.backImagePath]) {
      if (image != null && image != frontImage && image != backImage) {
        await _images.delete(image);
      }
    }
    await _distillations.joinQueues(cardId);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  Future<void> setSuspended(int cardId, {required bool suspended}) async {
    await _cards.setSuspended(cardId, suspended: suspended);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Starts every startable direction of the cards of [groupId], or of "No
  /// group" for `null`: they all become due today. Directions in the queue of
  /// a distillation wait for it. Returns how many cards started.
  Future<int> startGroup(int? groupId) async {
    final startedCards = await _cards.transaction(() async {
      var count = 0;
      for (final card in await _cards.getCardsOfGroup(groupId)) {
        if (await _startStartable(card.card.id)) {
          count++;
        }
      }
      return count;
    });
    if (startedCards > 0) {
      await _scheduleChangeListener.onSchedulesChanged();
    }
    return startedCards;
  }

  /// Starts the startable directions of one card: they become due today.
  Future<void> startCard(int cardId) async {
    await _cards.transaction(() => _startStartable(cardId));
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Starts one startable direction: it becomes due today.
  Future<void> startDirection(int directionId) async {
    await _cards.transaction(() async {
      final direction = await _cards.getDirection(directionId);
      await _startStartable(direction.cardId, onlyDirectionId: directionId);
    });
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Forgets the progression of both directions: every active or acquired
  /// direction starts again from scratch, due today. The history is kept.
  Future<void> resetProgress(int cardId) async {
    await _cards.transaction(() async {
      final preset = await _presetOfCard(cardId);
      DateTime? previousDue;
      for (final direction in await _sortedDirections(cardId)) {
        if (direction.state == DirectionState.active ||
            direction.state == DirectionState.acquired) {
          final schedule = _scheduler.startSchedule(
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

  /// Deletes a card with its history and its images.
  Future<void> delete(int cardId) async {
    final card = await _cards.getCard(cardId);
    await _cards.deleteCard(cardId);
    for (final image in [card.frontImagePath, card.backImagePath]) {
      if (image != null) {
        await _images.delete(image);
      }
    }
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Name in the image store of a draft image, copying a picked one into it.
  Future<String?> _store(DraftImage? image) async => switch (image) {
    null => null,
    StoredImage(:final name) => name,
    PickedImage(:final path) => await _images.add(path),
  };

  /// An empty text is no text: the face is an image alone.
  static String? _textOf(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _insertDirections(int cardId, bool alsoReverse) async {
    await _cards.insertDirection(
      cardId: cardId,
      sense: DirectionSense.frontToBack,
      schedule: DirectionSchedule.unstarted,
    );
    await _cards.insertDirection(
      cardId: cardId,
      sense: DirectionSense.backToFront,
      schedule: alsoReverse
          ? DirectionSchedule.unstarted
          : DirectionSchedule.inactive,
    );
  }

  /// Starts the startable directions of a card, front → back first, keeping
  /// the two directions on different days. Returns whether one started.
  Future<bool> _startStartable(int cardId, {int? onlyDirectionId}) async {
    final preset = await _presetOfCard(cardId);
    var started = false;
    for (final direction in await _sortedDirections(cardId)) {
      final isTarget =
          onlyDirectionId == null || direction.id == onlyDirectionId;
      if (isTarget && direction.isStartable) {
        final opposite = (await _cards.getDirections(cardId))
            .where((other) => other.id != direction.id && other.isScheduled)
            .firstOrNull;
        final schedule = _scheduler.startSchedule(
          preset: preset,
          now: _clock(),
          oppositeDueAt: opposite?.dueAt,
        );
        await _cards.applySchedule(direction.id, schedule);
        started = true;
      }
    }
    return started;
  }

  Future<void> _applyReverseChoice(int cardId, bool alsoReverse) async {
    final directions = await _cards.getDirections(cardId);
    final reverse = directions.firstWhere(
      (direction) => direction.sense == DirectionSense.backToFront,
    );
    final isStudied = reverse.state != DirectionState.inactive;
    if (alsoReverse && !isStudied) {
      await _cards.applySchedule(reverse.id, DirectionSchedule.unstarted);
    } else if (!alsoReverse && isStudied) {
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
