import '../../data/repositories/card_repository.dart';
import '../../data/repositories/card_with_directions.dart';
import '../../data/repositories/distillation_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/notifications/delivery_planner.dart';
import '../../domain/notifications/notification_timing.dart';
import '../../domain/scheduling/due_policy.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';
import 'alarm_scheduler.dart';
import 'delivery_candidates.dart';
import 'grouped_reminders.dart';
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
class NotificationPlanner implements ScheduleChangeListener {
  const NotificationPlanner({
    required this._cards,
    required this._presets,
    required this._reminders,
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
  final PresetRepository _presets;
  final ReminderRepository _reminders;
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
    final reminders = await _reminders.getAllUpcoming();
    final candidates = deliveryCandidates(cards, await _presets.loadCatalog());
    final deliveries = _deliveryPlanner.plan(candidates, now: now);
    final moments = [
      ...deliveries.values,
      for (final reminder in reminders) reminder.remindAt,
      ...await _distillationPasses(now),
      // A notification moved earlier than now, when a card sharing its time
      // range left it, is shown at once.
      if (candidates.any(
        (candidate) => NotificationTiming.shouldNotify(
          candidate.direction,
          cardSuspended: false,
          deliverAt: deliveries[candidate.direction.id]!,
          now: now,
          calendar: _deliveryPlanner.calendar,
        ),
      ))
        now.add(const Duration(seconds: 1)),
    ];
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
    await _withdrawAnswered(cards, now);
  }

  /// Start of the next day each running distillation has to process: every
  /// day when it spends a budget on its reminders, otherwise the day of its
  /// next batch.
  Future<List<DateTime>> _distillationPasses(DateTime now) async {
    final calendar = _rhythm.calendar;
    final today = calendar.dayOf(now);
    return [
      for (final distillation in await _distillations.getAll())
        if (distillation.isRunning)
          calendar.startOf(
            distillation.avoidCollisions
                ? calendar.addDays(distillation.lastAdvancedDay ?? today, 1)
                : _rhythm.nextIntroductionDay(distillation, today),
          ),
    ];
  }

  Future<void> _withdrawAnswered(
    List<CardWithDirections> cards,
    DateTime now,
  ) async {
    final directions = {
      for (final card in cards)
        for (final direction in card.directions) direction.id: card,
    };
    for (final key in await _presenter.shownPrompts()) {
      final card = directions[key.directionId];
      final direction = card?.directions
          .where((direction) => direction.id == key.directionId)
          .single;
      final stillDue =
          direction != null &&
          _duePolicy.isDueToday(
            direction,
            cardSuspended: card!.card.suspended,
            now: now,
          );
      if (key.isExtraReminder || stillDue) {
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
