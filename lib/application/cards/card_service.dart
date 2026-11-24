import '../../data/images/image_store.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../../domain/scheduling/step_target.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';
import 'card_draft.dart';
import 'draft_image.dart';

/// Creates, edits and manages cards. A card never enters review by itself:
/// it waits in the queue of its group until the distillation of the group
/// introduces it.
class CardService {
  const CardService({
    required this._cards,
    required this._presets,
    required this._settings,
    required this._images,
    required this._scheduler,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final CardRepository _cards;
  final PresetRepository _presets;
  final NotificationSettingsRepository _settings;
  final ImageStore _images;
  final ReviewScheduler _scheduler;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Stores a new card at the end of the queue of its group.
  Future<int> create(CardDraft draft) async {
    _checkComplete(draft);
    final frontImage = await _store(draft.frontImage);
    final backImage = await _store(draft.backImage);
    final cardId = await _cards.transaction(
      () => _insert(draft, frontImage: frontImage, backImage: backImage),
    );
    await _scheduleChangeListener.onSchedulesChanged();
    return cardId;
  }

  /// Several cards at once, for the bulk add, joining the queue in their
  /// order; returns how many were stored.
  Future<int> createAll(List<CardDraft> drafts) async {
    drafts.forEach(_checkComplete);
    await _cards.transaction(() async {
      for (final draft in drafts) {
        await _insert(draft, frontImage: null, backImage: null);
      }
    });
    await _scheduleChangeListener.onSchedulesChanged();
    return drafts.length;
  }

  /// Updates the content of a card. A pending card moved to another group
  /// joins the end of the queue of its new group; an introduced one keeps its
  /// progression and its due date. An image replaced or removed leaves the
  /// image store.
  Future<void> update(int cardId, CardDraft draft) async {
    _checkComplete(draft);
    final previous = await _cards.getCard(cardId);
    final frontImage = await _store(draft.frontImage);
    final backImage = await _store(draft.backImage);
    await _cards.transaction(() async {
      final joiningPosition =
          previous.isPending && previous.groupId != draft.groupId
          ? await _queueEnd(draft.groupId)
          : null;
      await _cards.updateCardContent(
        cardId: cardId,
        groupId: draft.groupId,
        frontText: _textOf(draft.frontText),
        frontImagePath: frontImage,
        backText: _textOf(draft.backText),
        backImagePath: backImage,
      );
      if (joiningPosition != null) {
        await _cards.setQueuePosition(cardId, joiningPosition);
      }
    });
    for (final image in [previous.frontImagePath, previous.backImagePath]) {
      if (image != null && image != frontImage && image != backImage) {
        await _images.delete(image);
      }
    }
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Puts a card at [target] by hand, whatever its answers, and returns its
  /// new due date. [PendingTarget] forgets its progression: it goes back to
  /// the end of the queue of its group, waiting for the distillation. Any
  /// other target schedules it as if an answer had brought it there now, a
  /// pending card leaving its queue. Nothing enters the history, which is
  /// kept.
  Future<DateTime?> setStep(int cardId, StepTarget target) async {
    final dueAt = await _cards.transaction(() async {
      final card = await _cards.getCard(cardId);
      final catalog = await _presets.loadCatalog();
      final reached = target.reachedIn(
        catalog.presetForGroup(card.groupId),
        catalog.sequenceEndForGroup(card.groupId),
      );
      if (reached == null) {
        await _cards.enqueue(cardId, await _queueEnd(card.groupId));
        return null;
      } else {
        final schedule = _scheduler.atStep(
          reached,
          from: _clock(),
          dailySlot: (await _settings.loadReminderSettings()).dailySlot,
        );
        await _cards.applySchedule(cardId, schedule);
        return schedule.dueAt;
      }
    });
    await _scheduleChangeListener.onSchedulesChanged();
    return dueAt;
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

  Future<int> _insert(
    CardDraft draft, {
    required String? frontImage,
    required String? backImage,
  }) async => _cards.insertCard(
    groupId: draft.groupId,
    frontText: _textOf(draft.frontText),
    frontImagePath: frontImage,
    backText: _textOf(draft.backText),
    backImagePath: backImage,
    createdAt: _clock(),
    queuePosition: await _queueEnd(draft.groupId),
  );

  Future<int> _queueEnd(int groupId) async =>
      DistillationQueue.endPosition(await _cards.getCardsOfGroup(groupId));

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

  void _checkComplete(CardDraft draft) {
    if (!draft.isComplete) {
      throw ArgumentError('A card needs a front and a back.');
    }
  }
}
