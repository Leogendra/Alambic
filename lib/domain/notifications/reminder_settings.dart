import '../scheduling/clock_time.dart';
import 'grouped_reminder_action.dart';
import 'notification_mode.dart';
import 'schedule_kind.dart';

/// When and how the reviews are notified, set once for the whole app in
/// Settings: no group or preset has its own schedule or mode.
class ReminderSettings {
  const ReminderSettings({
    required this.scheduleKind,
    required this.fixedTime,
    required this.rangeStart,
    required this.rangeEnd,
    required this.notificationMode,
    required this.groupedAction,
  });

  static const ReminderSettings defaults = ReminderSettings(
    scheduleKind: ScheduleKind.fixedTime,
    fixedTime: ClockTime(12, 0),
    rangeStart: ClockTime(9, 0),
    rangeEnd: ClockTime(18, 0),
    notificationMode: NotificationMode.perCard,
    groupedAction: GroupedReminderAction.openApp,
  );

  final ScheduleKind scheduleKind;
  final ClockTime fixedTime;
  final ClockTime rangeStart;
  final ClockTime rangeEnd;
  final NotificationMode notificationMode;
  final GroupedReminderAction groupedAction;

  /// Time at which day-based reviews become due.
  ///
  /// With a range, dues are anchored at its start; spreading the notifications
  /// over the range is the job of the notification planning.
  ClockTime get dailySlot => switch (scheduleKind) {
    ScheduleKind.fixedTime => fixedTime,
    ScheduleKind.timeRange => rangeStart,
  };

  /// One notification per card spread over a time range; a grouped reminder
  /// stays at the start of the range.
  bool get spreadsOverRange =>
      scheduleKind == ScheduleKind.timeRange &&
      notificationMode == NotificationMode.perCard;

  ReminderSettings copyWith({
    ScheduleKind? scheduleKind,
    ClockTime? fixedTime,
    ClockTime? rangeStart,
    ClockTime? rangeEnd,
    NotificationMode? notificationMode,
    GroupedReminderAction? groupedAction,
  }) => ReminderSettings(
    scheduleKind: scheduleKind ?? this.scheduleKind,
    fixedTime: fixedTime ?? this.fixedTime,
    rangeStart: rangeStart ?? this.rangeStart,
    rangeEnd: rangeEnd ?? this.rangeEnd,
    notificationMode: notificationMode ?? this.notificationMode,
    groupedAction: groupedAction ?? this.groupedAction,
  );

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.scheduleKind == scheduleKind &&
      other.fixedTime == fixedTime &&
      other.rangeStart == rangeStart &&
      other.rangeEnd == rangeEnd &&
      other.notificationMode == notificationMode &&
      other.groupedAction == groupedAction;

  @override
  int get hashCode => Object.hash(
    scheduleKind,
    fixedTime,
    rangeStart,
    rangeEnd,
    notificationMode,
    groupedAction,
  );
}
