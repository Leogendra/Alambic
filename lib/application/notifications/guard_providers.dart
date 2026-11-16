import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/notifications/notification_guards.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../../domain/scheduling/daily_slot_move.dart';
import '../cards/card_providers.dart';
import '../clock.dart';
import '../home/home_providers.dart';
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

/// Cards notified today, counted against the daily cap.
final notifiedTodayProvider = StreamProvider<int>((ref) {
  final start = ref.watch(todayStartProvider);
  final calendar = ref.watch(schedulingCalendarProvider);
  return start == null
      ? const Stream.empty()
      : ref
            .watch(notificationSettingsRepositoryProvider)
            .watchNotifiedOn(calendar.dayOf(start));
});

/// Cards due tomorrow, shown against the daily cap in Settings; `null` while
/// loading.
final tomorrowDueCountProvider = Provider<int?>((ref) {
  final cards = ref.watch(allCardsProvider).value;
  final start = ref.watch(todayStartProvider);
  final calendar = ref.watch(schedulingCalendarProvider);
  if (cards == null || start == null) {
    return null;
  }
  final tomorrow = calendar.addDays(calendar.dayOf(start), 1);
  return cards
      .where(
        (card) =>
            !card.suspended &&
            card.isScheduled &&
            calendar.dayOf(card.dueAt!) == tomorrow,
      )
      .length;
});

final notificationSettingsServiceProvider = Provider(
  (ref) => NotificationSettingsService(
    settings: ref.watch(notificationSettingsRepositoryProvider),
    cards: ref.watch(cardRepositoryProvider),
    slotMove: DailySlotMove(ref.watch(schedulingCalendarProvider)),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);
