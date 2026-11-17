import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../clock.dart';
import '../randomness.dart';
import '../distillation/distillation_providers.dart';
import '../reviews/review_providers.dart';
import '../scheduling/scheduling_providers.dart';
import 'alarm_scheduler.dart';
import 'grouped_reminders.dart';
import 'notification_action_handler.dart';
import 'notification_dispatcher.dart';
import 'notification_planner.dart';
import 'notification_presenter.dart';
import 'notification_target.dart';
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
    groups: ref.watch(groupRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    settings: ref.watch(notificationSettingsRepositoryProvider),
    pauses: ref.watch(pauseRepositoryProvider),
    reminders: ref.watch(reminderRepositoryProvider),
    distillations: ref.watch(distillationRepositoryProvider),
    rhythm: ref.watch(distillationRhythmProvider),
    alarms: ref.watch(alarmSchedulerProvider),
    store: ref.watch(plannedAlarmStoreProvider),
    presenter: ref.watch(notificationPresenterProvider),
    groupedReminders: ref.watch(groupedRemindersProvider),
    deliveryPlanner: ref.watch(deliveryPlannerProvider),
    duePolicy: ref.watch(duePolicyProvider),
    clock: ref.watch(clockProvider),
  ),
);

final groupedRemindersProvider = Provider(
  (ref) => GroupedReminders(
    cards: ref.watch(cardRepositoryProvider),
    groups: ref.watch(groupRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    settings: ref.watch(notificationSettingsRepositoryProvider),
    pauses: ref.watch(pauseRepositoryProvider),
    presenter: ref.watch(notificationPresenterProvider),
    deliveryPlanner: ref.watch(deliveryPlannerProvider),
    clock: ref.watch(clockProvider),
    random: ref.watch(randomProvider),
  ),
);

final notificationDispatcherProvider = Provider(
  (ref) => NotificationDispatcher(
    cards: ref.watch(cardRepositoryProvider),
    groups: ref.watch(groupRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    reminders: ref.watch(reminderRepositoryProvider),
    settings: ref.watch(notificationSettingsRepositoryProvider),
    pauses: ref.watch(pauseRepositoryProvider),
    distillations: ref.watch(distillationServiceProvider),
    groupedReminders: ref.watch(groupedRemindersProvider),
    presenter: ref.watch(notificationPresenterProvider),
    planner: ref.watch(notificationPlannerProvider),
    deliveryPlanner: ref.watch(deliveryPlannerProvider),
    clock: ref.watch(clockProvider),
    random: ref.watch(randomProvider),
  ),
);

final notificationActionHandlerProvider = Provider(
  (ref) => NotificationActionHandler(
    cards: ref.watch(cardRepositoryProvider),
    groups: ref.watch(groupRepositoryProvider),
    reviews: ref.watch(reviewServiceProvider),
    groupedReminders: ref.watch(groupedRemindersProvider),
    presenter: ref.watch(notificationPresenterProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Groups opened from a notification, the one that launched the app first.
/// Empty unless the platform layer overrides it.
final notificationTargetsProvider = Provider<Stream<NotificationTarget>>(
  (ref) => const Stream.empty(),
);

/// Whether alarms fire at the exact minute; refreshed when the app resumes.
final exactAlarmsAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(alarmSchedulerProvider).canScheduleExact(),
);
