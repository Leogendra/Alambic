import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/notifications/notification_guards.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../../domain/scheduling/daily_slot_move.dart';
import '../clock.dart';
import '../scheduling/scheduling_providers.dart';
import 'notification_settings_service.dart';

/// The schedule and mode of the notifications set in Settings.
final reminderSettingsProvider = StreamProvider<ReminderSettings>(
  (ref) =>
      ref.watch(notificationSettingsRepositoryProvider).watchReminderSettings(),
);

/// The notification safeguards set in Settings.
final notificationGuardsProvider = StreamProvider<NotificationGuards>(
  (ref) => ref.watch(notificationSettingsRepositoryProvider).watchGuards(),
);

final notificationSettingsServiceProvider = Provider(
  (ref) => NotificationSettingsService(
    settings: ref.watch(notificationSettingsRepositoryProvider),
    cards: ref.watch(cardRepositoryProvider),
    slotMove: DailySlotMove(ref.watch(schedulingCalendarProvider)),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);
