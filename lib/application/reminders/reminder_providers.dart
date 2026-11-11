import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/reviews/extra_reminder.dart';
import '../clock.dart';
import '../scheduling/scheduling_providers.dart';
import 'reminder_service.dart';

final reminderServiceProvider = Provider(
  (ref) => ReminderService(
    reminders: ref.watch(reminderRepositoryProvider),
    calendar: ref.watch(schedulingCalendarProvider),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);

/// Reminders of a direction not shown yet, earliest first.
final upcomingRemindersProvider =
    StreamProvider.family<List<ExtraReminder>, int>(
      (ref, directionId) =>
          ref.watch(reminderRepositoryProvider).watchUpcoming(directionId),
    );
