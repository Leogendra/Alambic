import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:alambic/application/clock.dart';
import 'package:alambic/application/notifications/alarm_scheduler.dart';
import 'package:alambic/application/notifications/group_reminder.dart';
import 'package:alambic/application/notifications/group_reminder_key.dart';
import 'package:alambic/application/notifications/notification_digest.dart';
import 'package:alambic/application/notifications/notification_presenter.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/notifications/planned_alarm_store.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/notifications/review_prompt.dart';
import 'package:alambic/application/notifications/typed_answer_verdict.dart';
import 'package:alambic/application/randomness.dart';
import 'package:alambic/application/scheduling/scheduling_providers.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';

import 'fixed_clock.dart';
import 'fixed_random.dart';
import 'test_images.dart';

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
  /// Cards asked, revealed or not.
  final Map<ReviewNotificationKey, ReviewPrompt> prompts = {};
  final Map<ReviewNotificationKey, TypedAnswerVerdict> verdicts = {};
  final Map<GroupReminderKey, GroupReminder> groupReminders = {};
  NotificationDigest? digest;

  /// What the user answers when asked for notifications.
  bool notificationsAllowed = true;
  int notificationPermissionRequests = 0;

  @override
  Future<bool> requestPermission() async {
    notificationPermissionRequests++;
    return notificationsAllowed;
  }

  @override
  Future<void> showPrompt(ReviewPrompt prompt) async {
    _clearSlotOf(prompt.key);
    prompts[prompt.key] = prompt;
  }

  @override
  Future<void> showVerdict(TypedAnswerVerdict verdict) async {
    _clearSlotOf(verdict.key);
    verdicts[verdict.key] = verdict;
  }

  @override
  Future<void> dismiss(ReviewNotificationKey key) async => _clearSlotOf(key);

  @override
  Future<List<ReviewNotificationKey>> shownPrompts() async =>
      prompts.keys.toList();

  @override
  Future<void> showGroupReminder(GroupReminder reminder) async {
    dismissGroupReminder(reminder.key);
    groupReminders[reminder.key] = reminder;
  }

  @override
  Future<void> dismissGroupReminder(GroupReminderKey key) async {
    groupReminders.remove(key);
    prompts.removeWhere((prompt, _) => prompt.chain == key);
    verdicts.removeWhere((verdict, _) => verdict.chain == key);
  }

  @override
  Future<Map<GroupReminderKey, int>> shownGroupReminders() async => {
    for (final reminder in groupReminders.values) reminder.key: reminder.count,
  };

  @override
  Future<void> showDigest(NotificationDigest digest) async =>
      this.digest = digest;

  @override
  Future<void> dismissDigest() async => digest = null;

  @override
  Future<int?> shownDigestCount() async => digest?.count;

  /// A notification replaces the one with the same id: the same card, or
  /// anything shown by the grouped reminder it is chained in.
  void _clearSlotOf(ReviewNotificationKey key) {
    final chain = key.chain;
    if (chain != null) {
      dismissGroupReminder(chain);
    } else {
      prompts.remove(key);
      verdicts.remove(key);
    }
  }
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
  /// [random] decides the asked faces; the front is always asked without
  /// it.
  factory NotificationHarness(
    AlambicDatabase database,
    FixedClock clock, {
    Random? random,
  }) {
    final alarms = FakeAlarmScheduler();
    final presenter = FakePresenter();
    final store = InMemoryAlarmStore();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        imageStoreProvider.overrideWithValue(openTestImageStore()),
        clockProvider.overrideWithValue(clock.call),
        randomProvider.overrideWithValue(random ?? FixedRandom(coin: false)),
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
