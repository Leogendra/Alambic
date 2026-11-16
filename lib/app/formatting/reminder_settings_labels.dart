import '../../domain/notifications/grouped_reminder_action.dart';
import '../../domain/notifications/notification_mode.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../../domain/notifications/schedule_kind.dart';
import '../../l10n/generated/app_localizations.dart';

/// Short descriptions of the schedule and the mode of the notifications, as
/// in "12:00" or "Grouped reminder · Chain".
extension ReminderSettingsLabels on AppLocalizations {
  String scheduleLabel(ReminderSettings reminders) =>
      switch (reminders.scheduleKind) {
        ScheduleKind.fixedTime => reminders.fixedTime.toString(),
        ScheduleKind.timeRange => scheduleRangeValue(
          reminders.rangeStart.toString(),
          reminders.rangeEnd.toString(),
        ),
      };

  String notificationModeLabel(ReminderSettings reminders) =>
      switch (reminders.notificationMode) {
        NotificationMode.perCard => notificationModePerCard,
        NotificationMode.grouped =>
          '$notificationModeGrouped · ${switch (reminders.groupedAction) {
            GroupedReminderAction.openApp => notificationModeOpenApp,
            GroupedReminderAction.chainInNotification => notificationModeChain,
          }}',
      };
}
