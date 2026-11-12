import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:alambic/application/clock.dart';
import 'package:alambic/application/notifications/alarm_scheduler.dart';
import 'package:alambic/application/notifications/answer_reveal.dart';
import 'package:alambic/application/notifications/notification_presenter.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/notifications/planned_alarm_store.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/notifications/review_prompt.dart';
import 'package:alambic/application/scheduling/scheduling_providers.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';

import 'fixed_clock.dart';

/// Alarms kept in memory: what is scheduled, and whether exactly.
class FakeAlarmScheduler implements AlarmScheduler {
  bool exactAllowed = true;
  final Map<int, DateTime> scheduled = {};
  final Map<int, bool> exactById = {};
  int scheduleCount = 0;
  int permissionRequests = 0;

  @override
  Future<bool> canScheduleExact() async => exactAllowed;

  @override
  Future<void> requestExactPermission() async => permissionRequests++;

  @override
  Future<void> schedule(int id, DateTime at, {required bool exact}) async {
    scheduled[id] = at;
    exactById[id] = exact;
    scheduleCount++;
  }

  @override
  Future<void> cancel(int id) async {
    scheduled.remove(id);
    exactById.remove(id);
  }
}

/// Notifications kept in memory, as a notification shade would hold them.
class FakePresenter implements NotificationPresenter {
  final Map<ReviewNotificationKey, ReviewPrompt> prompts = {};
  final Map<ReviewNotificationKey, AnswerReveal> reveals = {};

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> showPrompt(ReviewPrompt prompt) async {
    reveals.remove(prompt.key);
    prompts[prompt.key] = prompt;
  }

  @override
  Future<void> showReveal(AnswerReveal reveal) async {
    prompts.remove(reveal.key);
    reveals[reveal.key] = reveal;
  }

  @override
  Future<void> dismiss(ReviewNotificationKey key) async {
    prompts.remove(key);
    reveals.remove(key);
  }

  @override
  Future<List<ReviewNotificationKey>> shownPrompts() async =>
      prompts.keys.toList();
}

class InMemoryAlarmStore implements PlannedAlarmStore {
  Map<int, DateTime> alarms = {};

  @override
  Future<Map<int, DateTime>> load() async => Map.of(alarms);

  @override
  Future<void> save(Map<int, DateTime> alarms) async =>
      this.alarms = Map.of(alarms);
}

/// The services of the app over [database], with fake notifications and the
/// planner listening to schedule changes, as in the app.
class NotificationHarness {
  factory NotificationHarness(AlambicDatabase database, FixedClock clock) {
    final alarms = FakeAlarmScheduler();
    final presenter = FakePresenter();
    final store = InMemoryAlarmStore();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(clock.call),
        alarmSchedulerProvider.overrideWithValue(alarms),
        notificationPresenterProvider.overrideWithValue(presenter),
        plannedAlarmStoreProvider.overrideWithValue(store),
        scheduleChangeListenerProvider.overrideWith(
          (ref) => ref.watch(notificationPlannerProvider),
        ),
      ],
    );
    return NotificationHarness._(clock, alarms, presenter, store, container);
  }

  NotificationHarness._(
    this.clock,
    this.alarms,
    this.presenter,
    this.store,
    this.container,
  );

  final FixedClock clock;
  final FakeAlarmScheduler alarms;
  final FakePresenter presenter;
  final InMemoryAlarmStore store;
  final ProviderContainer container;

  T read<T>(ProviderListenable<T> provider) => container.read(provider);

  void dispose() => container.dispose();
}
