import '../../data/repositories/card_repository.dart';
import '../../data/repositories/distillation_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/pause_repository.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../domain/distillation/distillation_status.dart';
import '../../domain/scheduling/clock_time.dart';
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
    required this._settings,
    required this._pauses,
    required this._scheduler,
    required this._calendar,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final DistillationRepository _distillations;
  final CardRepository _cards;
  final NotificationSettingsRepository _settings;
  final PauseRepository _pauses;
  final ReviewScheduler _scheduler;
  final SchedulingCalendar _calendar;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  DistillationRhythm get _rhythm => DistillationRhythm(_calendar);

  /// Activates the distillation of a group: the first batch, from the head
  /// of its queue, comes out today.
  /// A group distills once: activating it again is an error.
  Future<void> activate(int groupId, DistillationSettings settings) async {
    await _cards.transaction(() async {
      if (await _distillations.find(groupId) != null) {
        throw StateError('The group $groupId already distills.');
      }
      await _distillations.insert(
        groupId: groupId,
        settings: settings,
        startedAt: _clock(),
      );
    });
    await _advanceAndReplan();
  }

  /// Applies new settings to the distillation of a group. The next batch
  /// comes X days (the new X) after the last one, and not before today's
  /// pass; when that pass already ran, the next one applies them.
  Future<void> adjust(int groupId, DistillationSettings settings) async {
    await _distillations.saveSettings(groupId, settings);
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
  /// has not had it yet: at most one batch comes out, when the rhythm owes
  /// one. A distillation whose group is paused, or any during the global
  /// pause, waits for the end of the pause.
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
    // A batch comes out only when a card is ready to leave the queue: an
    // empty queue keeps the batch owed until cards join it.
    final batchCameOut =
        _rhythm.batchDue(distillation, today) &&
        DistillationQueue.next(cards, 1).isNotEmpty;
    var introduced = 0;
    if (batchCameOut) {
      final duePolicy = DuePolicy(_calendar);
      final count = _rhythm.newCards(
        distillation,
        dueCards: cards
            .where((card) => duePolicy.isDueToday(card, now: now))
            .length,
      );
      final dailySlot = (await _settings.loadReminderSettings()).dailySlot;
      introduced = await _introduce(cards, dailySlot, count, now);
    }
    await _distillations.saveProgress(
      groupId,
      advancedDay: today,
      batchCameOut: batchCameOut,
    );
    return introduced > 0;
  });

  /// Introduces the [count] next cards of the queue: each one becomes due
  /// today at the daily slot. Returns how many were introduced.
  Future<int> _introduce(
    List<Flashcard> cards,
    ClockTime dailySlot,
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
        _scheduler.introduction(dailySlot: dailySlot, now: now),
      );
    }
    return picked.length;
  }
}
