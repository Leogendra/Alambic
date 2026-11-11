import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../clock.dart';
import '../reviews/review_providers.dart';
import '../scheduling/scheduling_providers.dart';
import 'alarm_scheduler.dart';
import 'notification_action_handler.dart';
import 'notification_dispatcher.dart';
import 'notification_planner.dart';
import 'notification_presenter.dart';
import 'planned_alarm_store.dart';

/// Platform implementations, always overridden: by the platform layer in the
/// app and in background tasks, by fakes in tests.
final alarmSchedulerProvider = Provider<AlarmScheduler>(
  (ref) =>
      throw UnimplementedError('alarmSchedulerProvider must be overridden'),
);

final notificationPresenterProvider = Provider<NotificationPresenter>(
  (ref) => throw UnimplementedError(
    'notificationPresenterProvider must be overridden',
  ),
);

final plannedAlarmStoreProvider = Provider<PlannedAlarmStore>(
  (ref) =>
      throw UnimplementedError('plannedAlarmStoreProvider must be overridden'),
);

final notificationPlannerProvider = Provider(
  (ref) => NotificationPlanner(
    cards: ref.watch(cardRepositoryProvider),
    reminders: ref.watch(reminderRepositoryProvider),
    alarms: ref.watch(alarmSchedulerProvider),
    store: ref.watch(plannedAlarmStoreProvider),
    presenter: ref.watch(notificationPresenterProvider),
    duePolicy: ref.watch(duePolicyProvider),
    clock: ref.watch(clockProvider),
  ),
);

final notificationDispatcherProvider = Provider(
  (ref) => NotificationDispatcher(
    cards: ref.watch(cardRepositoryProvider),
    groups: ref.watch(groupRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    reminders: ref.watch(reminderRepositoryProvider),
    presenter: ref.watch(notificationPresenterProvider),
    planner: ref.watch(notificationPlannerProvider),
    clock: ref.watch(clockProvider),
  ),
);

final notificationActionHandlerProvider = Provider(
  (ref) => NotificationActionHandler(
    cards: ref.watch(cardRepositoryProvider),
    reviews: ref.watch(reviewServiceProvider),
    presenter: ref.watch(notificationPresenterProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Whether alarms fire at the exact minute; refreshed when the app resumes.
final exactAlarmsAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(alarmSchedulerProvider).canScheduleExact(),
);
