import 'dart:math';

import '../../data/repositories/card_repository.dart';
import '../../data/repositories/card_with_directions.dart';
import '../../data/repositories/distillation_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/distillation/collision_budget.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_order.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../domain/distillation/distillation_status.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../../domain/scheduling/sequence_engine.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';
import 'distillation_refused.dart';

/// Launches distillations, feeds their queues and introduces their cards day
/// after day.
///
/// The daily pass ([advance]) runs whenever the app or a wake-up starts, at
/// most once per scheduling day and distillation: a new day is processed by
/// the first pass that sees it.
class DistillationService {
  DistillationService({
    required this._distillations,
    required this._cards,
    required this._presets,
    required this._scheduler,
    required this._calendar,
    required this._clock,
    required this._scheduleChangeListener,
    Random? random,
  }) : _random = random ?? Random();

  final DistillationRepository _distillations;
  final CardRepository _cards;
  final PresetRepository _presets;
  final ReviewScheduler _scheduler;
  final SchedulingCalendar _calendar;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;
  final Random _random;

  DistillationRhythm get _rhythm => DistillationRhythm(_calendar);

  /// Launches the distillation of the [sense] directions of a group: every
  /// direction of the group never started joins the queue, and the first
  /// batch is introduced today. Refused while the global distillation is in
  /// progress, when the group already distills this direction, or when no
  /// direction waits. Returns the id of the distillation.
  Future<int> launchForGroup(
    int groupId,
    DirectionSense sense,
    DistillationSettings settings,
  ) async {
    final distillationId = await _cards.transaction(() async {
      final existing = await _distillations.getAll();
      if (existing.any((distillation) => distillation.isGlobal)) {
        throw const DistillationRefused(DistillationRefusal.globalInProgress);
      } else if (existing.any(
        (distillation) =>
            distillation.groupId == groupId && distillation.sense == sense,
      )) {
        throw const DistillationRefused(DistillationRefusal.senseTaken);
      }
      final queue = [
        for (final card in await _cards.getCardsOfGroup(groupId))
          if (card.direction(sense) case final direction?
              when canJoinGroupQueue(direction))
            direction,
      ];
      return _create(
        groupId: groupId,
        sense: sense,
        settings: settings,
        ranked: _ordered(queue, settings.order),
        held: const [],
      );
    });
    await advance();
    await _scheduleChangeListener.onSchedulesChanged();
    return distillationId;
  }

  /// Launches the global distillation: every direction never started, of
  /// every card and in both directions, in random order. It stops the other
  /// distillations, whose remaining directions join its queue. The reverse
  /// of a card whose front is queued too only gets a rank once its front is
  /// introduced, so it never arrives first nor the same day.
  Future<int> launchGlobal(DistillationSettings settings) async {
    final distillationId = await _cards.transaction(() async {
      for (final other in await _distillations.getAll()) {
        await _distillations.delete(other.id);
      }
      final ranked = <CardDirection>[];
      final held = <CardDirection>[];
      for (final card in await _cards.getAll()) {
        final front = card.direction(DirectionSense.frontToBack);
        final reverse = card.direction(DirectionSense.backToFront);
        final frontQueued = front != null && front.isStartable;
        if (frontQueued) {
          ranked.add(front);
        }
        if (reverse != null && reverse.isStartable) {
          (frontQueued ? held : ranked).add(reverse);
        }
      }
      return _create(
        groupId: null,
        sense: null,
        settings: settings.copyWith(order: DistillationOrder.random),
        ranked: _ordered(ranked, DistillationOrder.random),
        held: held,
      );
    });
    await advance();
    await _scheduleChangeListener.onSchedulesChanged();
    return distillationId;
  }

  /// Whether a group distillation of its sense would take [direction]: never
  /// started, or never studied for the reverse, which the distillation then
  /// activates.
  static bool canJoinGroupQueue(CardDirection direction) =>
      direction.isStartable ||
      (direction.sense == DirectionSense.backToFront &&
          direction.state == DirectionState.inactive &&
          direction.lastReviewedAt == null);

  /// Directions of [cards] a group distillation of [sense] would take.
  static int queueableInGroup(
    Iterable<CardWithDirections> cards,
    DirectionSense sense,
  ) => cards
      .where(
        (card) => switch (card.direction(sense)) {
          final direction? => canJoinGroupQueue(direction),
          null => false,
        },
      )
      .length;

  /// Directions of [cards] the global distillation would take: the ones
  /// never started, including those queued by the distillations it stops.
  static int queueableGlobally(Iterable<CardWithDirections> cards) => cards
      .expand((card) => card.directions)
      .where(
        (direction) =>
            direction.isStartable || direction.state == DirectionState.pending,
      )
      .length;

  /// Puts the directions of a new or edited card in the queue of the
  /// distillation that covers them, at its end: the global distillation when
  /// it is in progress, otherwise the distillation of its group and sense. A
  /// direction queued by the distillation of a group the card has left is
  /// released first.
  Future<void> joinQueues(int cardId) => _cards.transaction(() async {
    final card = await _cards.getCard(cardId);
    final distillations = await _distillations.getAll();
    final global = distillations
        .where((distillation) => distillation.isGlobal)
        .firstOrNull;
    for (final sense in DirectionSense.values) {
      var direction = await _directionOf(cardId, sense);
      final owner = distillations
          .where((distillation) => distillation.id == direction.distillationId)
          .firstOrNull;
      if (owner != null &&
          !owner.isGlobal &&
          owner.groupId != card.groupId &&
          direction.state == DirectionState.pending) {
        await _cards.releaseFromDistillation(direction.id);
        direction = await _cards.getDirection(direction.id);
      }
      final target =
          global ??
          distillations
              .where(
                (distillation) =>
                    distillation.groupId == card.groupId &&
                    distillation.sense == sense,
              )
              .firstOrNull;
      if (target == null || direction.distillationId != null) {
        continue;
      }
      final eligible = target.isGlobal
          ? direction.isStartable
          : canJoinGroupQueue(direction);
      if (eligible) {
        await _cards.enqueue(
          direction.id,
          distillationId: target.id,
          position: await _joiningPosition(target, direction),
        );
      }
    }
  });

  /// Runs the pass of the current day for every running distillation that
  /// has not had it yet: spends its budget when it avoids collisions,
  /// introduces the cards the rhythm owes, and deletes a distillation whose
  /// queue is empty. Returns whether a schedule moved.
  Future<bool> advance() async {
    var changed = false;
    for (final distillation in await _distillations.getAll()) {
      if (distillation.isRunning) {
        changed = await _advanceOne(distillation.id) || changed;
      }
    }
    return changed;
  }

  Future<void> pause(int distillationId) =>
      _distillations.setStatus(distillationId, DistillationStatus.paused);

  /// Resumes a paused distillation; a day not processed yet is processed now.
  Future<void> resume(int distillationId) async {
    await _distillations.setStatus(distillationId, DistillationStatus.running);
    if (await advance()) {
      await _scheduleChangeListener.onSchedulesChanged();
    }
  }

  /// Stops a distillation. Its remaining directions stay pending, outside
  /// any queue, until another distillation takes them or they are started by
  /// hand. The cards it already introduced go on with their preset.
  Future<void> stop(int distillationId) =>
      _distillations.delete(distillationId);

  Future<bool> _advanceOne(int distillationId) => _cards.transaction(() async {
    // Read again inside the transaction: the app and a wake-up may run
    // the pass at the same time, from two isolates.
    final distillation = await _distillations.get(distillationId);
    final now = _clock();
    final today = _calendar.dayOf(now);
    if (!distillation.isRunning || distillation.lastAdvancedDay == today) {
      return false;
    }
    final cards = await _cards.getAll();
    final catalog = await _presets.loadCatalog();
    var count = _rhythm.cardsDue(distillation, today);
    var postponed = 0;
    if (distillation.avoidCollisions) {
      final split = CollisionBudget.split(
        _dueReminders(distillation, cards, catalog, now),
        budget: distillation.cardsPerBatch,
      );
      postponed = await _postpone(split.postponed, cards, catalog, now);
      count = min(count, split.newCardRoom);
    }
    final introduced = await _introduce(
      distillation,
      cards,
      catalog,
      count,
      now,
    );
    final progress = _rhythm.afterIntroducing(distillation, introduced, today);
    await _distillations.saveProgress(
      distillation.id,
      advancedDay: today,
      nextBatchDay: progress.nextBatchDay,
      introducedInBatch: progress.introducedInBatch,
    );
    final distilled = await _cards.getDistilled(distillation.id);
    if (DistillationQueue.remaining(distilled) == 0) {
      await _distillations.delete(distillation.id);
    }
    return introduced > 0 || postponed > 0;
  });

  /// Reminders of the cards [distillation] introduced that are due today.
  List<BudgetedReminder> _dueReminders(
    Distillation distillation,
    List<CardWithDirections> cards,
    PresetCatalog catalog,
    DateTime now,
  ) {
    final duePolicy = DuePolicy(_calendar);
    return [
      for (final card in cards)
        for (final direction in card.directions)
          if (direction.distillationId == distillation.id &&
              duePolicy.isDueToday(
                direction,
                cardSuspended: card.card.suspended,
                now: now,
              ))
            BudgetedReminder(
              directionId: direction.id,
              interval: _waitedInterval(
                direction,
                catalog.presetForCard(card.card),
              ),
              dueAt: direction.dueAt!,
            ),
    ];
  }

  /// Interval that led to the current due date of [direction].
  Duration _waitedInterval(CardDirection direction, Preset preset) {
    final step = SequenceEngine.clampToSequence(direction.step, preset);
    return step == null ? Duration.zero : preset.intervals[step].length;
  }

  /// Moves the reminders over the budget to the next day, keeping their step.
  Future<int> _postpone(
    List<int> directionIds,
    List<CardWithDirections> cards,
    PresetCatalog catalog,
    DateTime now,
  ) async {
    for (final directionId in directionIds) {
      final card = cards.firstWhere(
        (card) => card.directions.any((other) => other.id == directionId),
      );
      final direction = card.directions.firstWhere(
        (other) => other.id == directionId,
      );
      final opposite = (await _cards.getDirections(card.card.id))
          .where((other) => other.id != directionId && other.isScheduled)
          .firstOrNull;
      await _cards.applySchedule(
        directionId,
        _scheduler.postponed(
          step: direction.step,
          preset: catalog.presetForCard(card.card),
          now: now,
          oppositeDueAt: opposite?.dueAt,
        ),
      );
    }
    return directionIds.length;
  }

  /// Introduces the [count] next directions of the queue: each one becomes
  /// due today at its preset slot. Returns how many were introduced.
  Future<int> _introduce(
    Distillation distillation,
    List<CardWithDirections> cards,
    PresetCatalog catalog,
    int count,
    DateTime now,
  ) async {
    if (count <= 0) {
      return 0;
    }
    final cardsById = {for (final card in cards) card.card.id: card};
    final picked = DistillationQueue.next(
      [
        for (final card in cards)
          for (final direction in card.directions)
            if (direction.distillationId == distillation.id) direction,
      ],
      suspendedCardIds: {
        for (final card in cards)
          if (card.card.suspended) card.card.id,
      },
      count: count,
    );
    for (final direction in picked) {
      await _start(cardsById[direction.cardId]!, direction, catalog, now);
    }
    if (distillation.isGlobal) {
      await _rankReverses(distillation, picked);
    }
    return picked.length;
  }

  Future<void> _start(
    CardWithDirections card,
    CardDirection direction,
    PresetCatalog catalog,
    DateTime now,
  ) async {
    final opposite = (await _cards.getDirections(card.card.id))
        .where((other) => other.id != direction.id && other.isScheduled)
        .firstOrNull;
    final schedule = _scheduler.startSchedule(
      preset: catalog.presetForCard(card.card),
      now: now,
      oppositeDueAt: opposite?.dueAt,
    );
    await _cards.applySchedule(direction.id, schedule);
    await _cards.setQueuePosition(direction.id, null);
  }

  /// Creates a distillation whose queue holds [ranked] in that order, and
  /// [held] without a rank yet.
  Future<int> _create({
    required int? groupId,
    required DirectionSense? sense,
    required DistillationSettings settings,
    required List<CardDirection> ranked,
    required List<CardDirection> held,
  }) async {
    if (ranked.isEmpty) {
      throw const DistillationRefused(DistillationRefusal.nothingToDistill);
    }
    final now = _clock();
    final distillationId = await _distillations.insert(
      groupId: groupId,
      sense: sense,
      settings: settings,
      startedAt: now,
      firstBatchDay: _calendar.dayOf(now),
    );
    for (final (position, direction) in ranked.indexed) {
      await _cards.enqueue(
        direction.id,
        distillationId: distillationId,
        position: position,
      );
    }
    for (final direction in held) {
      await _cards.enqueue(
        direction.id,
        distillationId: distillationId,
        position: null,
      );
    }
    return distillationId;
  }

  /// Rank of a direction joining [distillation]: the end of the queue, or
  /// none for a reverse of the global distillation whose front still waits.
  Future<int?> _joiningPosition(
    Distillation distillation,
    CardDirection direction,
  ) async {
    if (distillation.isGlobal &&
        direction.sense == DirectionSense.backToFront) {
      final front = await _directionOf(
        direction.cardId,
        DirectionSense.frontToBack,
      );
      if (front.state == DirectionState.pending &&
          front.distillationId == distillation.id) {
        return null;
      }
    }
    return DistillationQueue.endPosition(
      await _cards.getDistilled(distillation.id),
    );
  }

  /// In the global distillation, the reverse of a front just introduced gets
  /// its rank at the end of the queue. The pass of the day is over by then,
  /// so it never arrives the same day as its front.
  Future<void> _rankReverses(
    Distillation distillation,
    List<CardDirection> introduced,
  ) async {
    for (final front in introduced) {
      if (front.sense != DirectionSense.frontToBack) {
        continue;
      }
      final reverse = await _directionOf(
        front.cardId,
        DirectionSense.backToFront,
      );
      if (reverse.state == DirectionState.pending &&
          reverse.distillationId == distillation.id &&
          reverse.queuePosition == null) {
        await _cards.setQueuePosition(
          reverse.id,
          DistillationQueue.endPosition(
            await _cards.getDistilled(distillation.id),
          ),
        );
      }
    }
  }

  Future<CardDirection> _directionOf(int cardId, DirectionSense sense) async =>
      (await _cards.getDirections(cardId))
          .firstWhere((direction) => direction.sense == sense);

  List<CardDirection> _ordered(
    List<CardDirection> directions,
    DistillationOrder order,
  ) => switch (order) {
    DistillationOrder.groupOrder => directions,
    DistillationOrder.random => [...directions]..shuffle(_random),
  };
}
