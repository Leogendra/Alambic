import '../../data/repositories/card_repository.dart';
import '../../data/repositories/distillation_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/pause_repository.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/notifications/delivery_planner.dart';
import '../../domain/notifications/notification_timing.dart';
import '../../domain/scheduling/due_policy.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';
import 'alarm_scheduler.dart';
import 'grouped_reminders.dart';
import 'notification_digest.dart';
import 'notification_presenter.dart';
import 'planned_alarm_store.dart';

/// Keeps the wake-ups of the app in line with the due dates. Told after every
/// schedule change, it schedules the next wake-ups, cancels the ones no longer
/// needed, and withdraws the notifications of cards that are no longer due,
/// for example a card reviewed in the app before its notification was
/// answered. The grouped reminders are refreshed the same way: a chained card
/// answered in the app gives way to the next one, and a reminder with no card
/// left is closed.
///
/// A running distillation also wakes the app up at the start of the next day
/// it has to process, so that its cards are introduced with the app closed.
///
/// During the global pause, no notification is planned and those on screen
/// are withdrawn; the app only wakes up at the start of each day, to move
/// the due dates forward.
class NotificationPlanner implements ScheduleChangeListener {
  const NotificationPlanner({
    required this._cards,
    required this._groups,
    required this._settings,
    required this._pauses,
    required this._distillations,
    required this._rhythm,
    required this._alarms,
    required this._store,
    required this._presenter,
    required this._groupedReminders,
    required this._deliveryPlanner,
    required this._duePolicy,
    required this._clock,
  });

  /// Wake-ups scheduled ahead. Each wake-up plans the next ones, so this only
  /// bounds the number of alarms held by the system at once.
  static const int wakeUpLimit = 48;

  final CardRepository _cards;
  final GroupRepository _groups;
  final NotificationSettingsRepository _settings;
  final PauseRepository _pauses;
  final DistillationRepository _distillations;
  final DistillationRhythm _rhythm;
  final AlarmScheduler _alarms;
  final PlannedAlarmStore _store;
  final NotificationPresenter _presenter;
  final GroupedReminders _groupedReminders;
  final DeliveryPlanner _deliveryPlanner;
  final DuePolicy _duePolicy;
  final Clock _clock;

  /// Alarm id of a wake-up: its minute since the epoch, unique per moment.
  static int alarmId(DateTime wakeUp) =>
      wakeUp.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute;

  @override
  Future<void> onSchedulesChanged() => replan();

  /// Plans the next wake-ups. [force] schedules them all again, after the
  /// exact alarm permission changed or the phone restarted.
  Future<void> replan({bool force = false}) async {
    final now = _clock();
    final cards = await _cards.getAll();
    final paused = await _pauses.loadGlobalPause() != null;
    final moments = paused
        ? [_rhythm.calendar.endOf(_rhythm.calendar.dayOf(now))]
        : await _reminderMoments(cards, now);
    final wanted = {
      for (final wakeUp in NotificationTiming.wakeUps(
        moments,
        now: now,
        limit: wakeUpLimit,
      ))
        alarmId(wakeUp): wakeUp,
    };
    final planned = await _store.load();
    for (final id in planned.keys) {
      if (!wanted.containsKey(id)) {
        await _alarms.cancel(id);
      }
    }
    final exact = await _alarms.canScheduleExact();
    for (final MapEntry(key: id, value: wakeUp) in wanted.entries) {
      if (force || planned[id] != wakeUp) {
        await _alarms.schedule(id, wakeUp, exact: exact);
      }
    }
    await _store.save(wanted);
    if (paused) {
      await _withdrawAll();
    } else {
      await _withdrawAnswered(cards, now);
      await _refreshDigest(cards, now);
    }
  }

  /// The moments at which the reminders are due, and the distillations
  /// owe their next pass.
  Future<List<DateTime>> _reminderMoments(
    List<Flashcard> cards,
    DateTime now,
  ) async {
    final guards = await _settings.loadGuards();
    final reminderSettings = await _settings.loadReminderSettings();
    final deliveries = _deliveryPlanner.plan(
      cards,
      now: now,
      reminders: reminderSettings,
      guards: guards,
    );
    return [
      ...deliveries.values,
      for (final deliverAt in deliveries.values)
        if (!deliverAt.isAfter(now))
          _deliveryPlanner.nextDayRetry(
            now: now,
            reminders: reminderSettings,
            guards: guards,
          ),
      ...await _distillationPasses(now),
      // A notification moved earlier than now, when a card sharing its time
      // range left it, is shown at once.
      if (cards.any(
        (card) => switch (deliveries[card.id]) {
          final deliverAt? => NotificationTiming.shouldNotify(
            card,
            deliverAt: deliverAt,
            now: now,
            calendar: _deliveryPlanner.calendar,
          ),
          null => false,
        },
      ))
        now.add(const Duration(seconds: 1)),
    ];
  }

  /// Start of the day on which each running distillation owes its next
  /// batch.
  Future<List<DateTime>> _distillationPasses(DateTime now) async {
    final calendar = _rhythm.calendar;
    final today = calendar.dayOf(now);
    return [
      for (final distillation in await _distillations.getAll())
        if (!distillation.isPaused)
          calendar.startOf(_rhythm.nextIntroductionDay(distillation, today)),
    ];
  }

  /// Counts again the cards announced today that are still due, when the
  /// notification gathering them is on screen, and closes it once none is
  /// left.
  Future<void> _refreshDigest(List<Flashcard> cards, DateTime now) async {
    final shownCount = await _presenter.shownDigestCount();
    if (shownCount == null) {
      return;
    }
    final today = _deliveryPlanner.calendar.dayOf(now);
    final groupIds = [
      for (final card in cards)
        if (card.notifiedAt case final notifiedAt?
            when _deliveryPlanner.calendar.dayOf(notifiedAt) == today &&
                _duePolicy.isDueToday(card, now: now))
          card.groupId,
    ];
    if (groupIds.isEmpty) {
      await _presenter.dismissDigest();
    } else if (groupIds.length != shownCount) {
      await _presenter.showDigest(
        NotificationDigest.of(groupIds, {
          for (final group in await _groups.watchAll().first)
            group.id: group.name,
        }, alert: false),
      );
    }
  }

  /// Withdraws every review notification on screen, at the start of the
  /// global pause.
  Future<void> _withdrawAll() async {
    for (final key in await _presenter.shownPrompts()) {
      await _presenter.dismiss(key);
    }
    for (final key in (await _presenter.shownGroupReminders()).keys) {
      await _presenter.dismissGroupReminder(key);
    }
    if (await _presenter.shownDigestCount() != null) {
      await _presenter.dismissDigest();
    }
  }

  Future<void> _withdrawAnswered(List<Flashcard> cards, DateTime now) async {
    final cardsById = {for (final card in cards) card.id: card};
    for (final key in await _presenter.shownPrompts()) {
      final card = cardsById[key.cardId];
      final stillDue = card != null && _duePolicy.isDueToday(card, now: now);
      if (stillDue) {
        continue;
      }
      final chain = key.chain;
      if (chain == null) {
        await _presenter.dismiss(key);
      } else {
        await _groupedReminders.showNext(chain);
      }
    }
    for (final MapEntry(:key, value: shownCount)
        in (await _presenter.shownGroupReminders()).entries) {
      await _groupedReminders.refresh(key, shownCount);
    }
  }
}
