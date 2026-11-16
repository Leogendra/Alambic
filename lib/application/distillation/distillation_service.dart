import 'dart:math';

import '../../data/repositories/card_repository.dart';
import '../../data/repositories/distillation_repository.dart';
import '../../data/repositories/pause_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/collision_budget.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../domain/distillation/distillation_status.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/scheduling/card_progress.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';

/// Activates and adjusts the distillation of a group, and introduces its
/// pending cards day after day.
///
/// The daily pass ([advance]) runs whenever the app or a wake-up starts, at
/// most once per scheduling day and distillation: a new day is processed by
/// the first pass that sees it.
class DistillationService {
  DistillationService({
    required this._distillations,
    required this._cards,
    required this._presets,
    required this._pauses,
    required this._scheduler,
    required this._calendar,
    required this._clock,
    required this._scheduleChangeListener,
    Random? random,
  }) : _random = random ?? Random();

  final DistillationRepository _distillations;
  final CardRepository _cards;
  final PresetRepository _presets;
  final PauseRepository _pauses;
  final ReviewScheduler _scheduler;
  final SchedulingCalendar _calendar;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;
  final Random _random;

  DistillationRhythm get _rhythm => DistillationRhythm(_calendar);

  /// Activates the distillation of a group: its queue is ordered by
  /// [DistillationSettings.order] and the first batch is introduced today.
  /// A group distills once: activating it again is an error.
  Future<void> activate(int groupId, DistillationSettings settings) async {
    await _cards.transaction(() async {
      if (await _distillations.find(groupId) != null) {
        throw StateError('The group $groupId already distills.');
      }
      final now = _clock();
      await _distillations.insert(
        groupId: groupId,
        settings: settings,
        startedAt: now,
        firstBatchDay: _calendar.dayOf(now),
      );
      await _rankQueue(groupId, settings);
    });
    await _advanceAndReplan();
  }

  /// Applies new settings to the distillation of a group. A new order ranks
  /// the queue again. A batch already complete under a smaller rhythm closes:
  /// the next one comes X days after the last day processed.
  Future<void> adjust(int groupId, DistillationSettings settings) async {
    await _cards.transaction(() async {
      final distillation = (await _distillations.find(groupId))!;
      final batchComplete =
          distillation.introducedInBatch >= settings.cardsPerBatch;
      await _distillations.saveSettings(
        groupId,
        settings,
        nextBatchDay: batchComplete
            ? _calendar.addDays(
                distillation.lastAdvancedDay ?? _calendar.dayOf(_clock()),
                settings.everyDays,
              )
            : distillation.nextBatchDay,
        introducedInBatch: batchComplete ? 0 : distillation.introducedInBatch,
      );
      if (settings.order != distillation.introductionOrder) {
        await _rankQueue(groupId, settings);
      }
    });
    await _advanceAndReplan();
  }

  /// No card leaves the queue until it resumes; the cards already introduced
  /// go on with their preset.
  Future<void> pause(int groupId) async {
    await _distillations.setStatus(groupId, DistillationStatus.paused);
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Resumes a paused distillation; a day not processed yet is processed now.
  Future<void> resume(int groupId) async {
    await _distillations.setStatus(groupId, DistillationStatus.running);
    await _advanceAndReplan();
  }

  /// Runs the pass of the current day for every running distillation that
  /// has not had it yet: spends its budget when it avoids collisions and
  /// introduces the cards the rhythm owes. A distillation whose group is
  /// paused, or any during the global pause, waits for the end of the pause.
  /// Returns whether a schedule moved.
  Future<bool> advance() async {
    var changed = false;
    final pauses = await _pauses.loadPauses();
    for (final distillation in await _distillations.getAll()) {
      if (distillation.isRunning && !pauses.covers(distillation.groupId)) {
        changed = await _advanceOne(distillation.groupId) || changed;
      }
    }
    return changed;
  }

  Future<void> _advanceAndReplan() async {
    await advance();
    await _scheduleChangeListener.onSchedulesChanged();
  }

  Future<bool> _advanceOne(int groupId) => _cards.transaction(() async {
    // Read again inside the transaction: the app and a wake-up may run
    // the pass at the same time, from two isolates.
    final distillation = (await _distillations.find(groupId))!;
    final now = _clock();
    final today = _calendar.dayOf(now);
    if (!distillation.isRunning || distillation.lastAdvancedDay == today) {
      return false;
    }
    final cards = await _cards.getCardsOfGroup(groupId);
    final catalog = await _presets.loadCatalog();
    var count = _rhythm.cardsDue(distillation, today);
    var postponed = 0;
    if (_spendsBudget(distillation, cards)) {
      final split = CollisionBudget.split(
        _dueReminders(cards, catalog, now),
        budget: distillation.cardsPerBatch,
      );
      postponed = await _postpone(split.postponed, cards, catalog, now);
      count = min(count, split.newCardRoom);
    }
    final introduced = await _introduce(cards, catalog, count, now);
    final progress = _rhythm.afterIntroducing(distillation, introduced, today);
    await _distillations.saveProgress(
      groupId,
      advancedDay: today,
      nextBatchDay: progress.nextBatchDay,
      introducedInBatch: progress.introducedInBatch,
    );
    return introduced > 0 || postponed > 0;
  });

  /// The budget protects the reminders from the new cards: it is spent only
  /// while cards wait in the queue. With an empty queue, every reminder goes
  /// through.
  bool _spendsBudget(Distillation distillation, List<Flashcard> cards) =>
      distillation.avoidCollisions &&
      DistillationQueue.next(cards, 1).isNotEmpty;

  /// Reminders of the group due today.
  List<BudgetedReminder> _dueReminders(
    List<Flashcard> cards,
    PresetCatalog catalog,
    DateTime now,
  ) {
    final duePolicy = DuePolicy(_calendar);
    return [
      for (final card in cards)
        if (duePolicy.isDueToday(card, now: now))
          BudgetedReminder(
            cardId: card.id,
            interval: CardProgress.of(
              card,
              catalog.presetForCard(card),
            ).waitedInterval,
            dueAt: card.dueAt!,
          ),
    ];
  }

  /// Moves the reminders over the budget to the next day, keeping their
  /// progression.
  Future<int> _postpone(
    List<int> cardIds,
    List<Flashcard> cards,
    PresetCatalog catalog,
    DateTime now,
  ) async {
    for (final cardId in cardIds) {
      final card = cards.firstWhere((card) => card.id == cardId);
      await _cards.applySchedule(
        cardId,
        _scheduler.postponed(
          card: card,
          preset: catalog.presetForCard(card),
          now: now,
        ),
      );
    }
    return cardIds.length;
  }

  /// Introduces the [count] next cards of the queue: each one becomes due
  /// today at its preset slot. Returns how many were introduced.
  Future<int> _introduce(
    List<Flashcard> cards,
    PresetCatalog catalog,
    int count,
    DateTime now,
  ) async {
    if (count <= 0) {
      return 0;
    }
    final picked = DistillationQueue.next(cards, count);
    for (final card in picked) {
      await _cards.applySchedule(
        card.id,
        _scheduler.introduction(preset: catalog.presetForCard(card), now: now),
      );
    }
    return picked.length;
  }

  /// Ranks the queue of the group again, in the order of [settings].
  Future<void> _rankQueue(int groupId, DistillationSettings settings) async {
    final ordered = DistillationQueue.ordered(
      await _cards.getCardsOfGroup(groupId),
      settings.order,
      _random,
    );
    for (final (position, card) in ordered.indexed) {
      await _cards.setQueuePosition(card.id, position);
    }
  }
}
