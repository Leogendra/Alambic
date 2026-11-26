import '../../data/repositories/card_repository.dart';
import '../../data/repositories/distillation_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/pause_repository.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';

/// Activates, adjusts and pauses the distillation of a group, and introduces
/// its pending cards day after day. Also holds the global pause, which holds
/// back every distillation and moves every due date forward by the days it
/// lasts, as if they had not passed.
///
/// The daily pass ([advance]) runs whenever the app or a wake-up starts, at
/// most once per scheduling day and distillation: a new day is processed by
/// the first pass that sees it. The pause of a distillation never touches
/// the reminders: the cards already introduced keep their due dates and
/// their notifications.
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

  /// Applies new settings to the distillation of a group, from today's pass;
  /// when that pass already ran, the next one applies them.
  Future<void> adjust(int groupId, DistillationSettings settings) async {
    await _distillations.saveSettings(groupId, settings);
    await _advanceAndReplan();
  }

  /// No card leaves the queue until it resumes; the cards already introduced
  /// go on with their preset.
  Future<void> pause(int groupId) async {
    await _distillations.setPausedAt(groupId, _clock());
    await _scheduleChangeListener.onSchedulesChanged();
  }

  /// Resumes a paused distillation: a day not processed yet is processed
  /// now, with a single batch if the rhythm owes one.
  Future<void> resume(int groupId) async {
    await _distillations.setPausedAt(groupId, null);
    await _advanceAndReplan();
  }

  /// Holds back every distillation, leaving their own pause untouched, and
  /// every notification. From the next day on, the due dates move forward
  /// one day for each day of pause.
  Future<void> pauseAll() async {
    if (await _pauses.loadGlobalPause() == null) {
      final now = _clock();
      await _pauses.startGlobalPause(now, shiftedDay: _calendar.dayOf(now));
      await _scheduleChangeListener.onSchedulesChanged();
    }
  }

  /// Ends the global pause, after moving the due dates past the days not
  /// moved yet; a distillation paused on its own stays paused.
  Future<void> resumeAll() async {
    await _cards.transaction(() async {
      await _skipPausedDays();
      await _pauses.endGlobalPause();
    });
    await _advanceAndReplan();
  }

  /// Runs the pass of the current day for every running distillation that
  /// has not had it yet: at most one batch comes out, when the rhythm owes
  /// one. During the global pause, no distillation runs: the pass moves the
  /// due dates forward instead.
  /// Returns whether a schedule moved.
  Future<bool> advance() async {
    if (await _pauses.loadGlobalPause() != null) {
      return _cards.transaction(_skipPausedDays);
    }
    var changed = false;
    for (final distillation in await _distillations.getAll()) {
      if (!distillation.isPaused) {
        changed = await _advanceOne(distillation.groupId) || changed;
      }
    }
    return changed;
  }

  /// Moves every due date forward by the days of global pause not skipped
  /// yet, keeping its clock time: a card late by two days when the pause
  /// started is still late by two days when it ends. Runs inside a
  /// transaction: the app and a wake-up may skip the same days at the same
  /// time, from two isolates. Returns whether a due date moved.
  Future<bool> _skipPausedDays() async {
    final shiftedDay = await _pauses.loadShiftedDay();
    if (shiftedDay == null) {
      return false;
    }
    final today = _calendar.dayOf(_clock());
    final days = _calendar.daysBetween(shiftedDay, today);
    if (days <= 0) {
      return false;
    }
    final dueDates = {
      for (final card in await _cards.getAll())
        if (card.dueAt case final dueAt? when card.isScheduled)
          card.id: _calendar.addDaysTo(dueAt, days),
    };
    await _cards.moveDueDates(dueDates);
    await _pauses.saveShiftedDay(today);
    return dueDates.isNotEmpty;
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
    if (distillation.isPaused || distillation.lastAdvancedDay == today) {
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
        distillation.settings,
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
