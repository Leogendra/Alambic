import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../application/notifications/alarm_scheduler.dart';
import 'background_entry_points.dart';

/// Wake-ups through Android's AlarmManager. Each alarm runs
/// [onReviewAlarm] in a background isolate, app closed or not, and is
/// restored by the plugin after a restart of the phone.
class AndroidAlarmScheduler implements AlarmScheduler {
  AndroidAlarmScheduler(this._notifications);

  final AndroidFlutterLocalNotificationsPlugin _notifications;

  /// Exact alarms need a permission, refused by default since Android 14.
  /// Without it, the plugin would log an error and drop an exact alarm, so
  /// an inexact one is scheduled instead: Android may then deliver it a few
  /// minutes late.
  @override
  Future<bool> canScheduleExact() async =>
      await _notifications.canScheduleExactNotifications() ?? false;

  @override
  Future<void> requestExactPermission() =>
      _notifications.requestExactAlarmsPermission();

  @override
  Future<void> schedule(int id, DateTime at, {required bool exact}) =>
      AndroidAlarmManager.oneShotAt(
        at,
        id,
        onReviewAlarm,
        exact: exact,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );

  @override
  Future<void> cancel(int id) => AndroidAlarmManager.cancel(id);
}
