import '../cards/card_direction.dart';

/// When reminders are shown, and when the app must wake up to show them.
abstract final class NotificationTiming {
  /// A reminder found later than this after its moment is not shown: the
  /// phone was off or the alarm was held back too long, and a notification
  /// hours late would be noise.
  static const Duration lateness = Duration(hours: 1);

  /// Whether [direction] must be notified now: it is scheduled, the moment
  /// [deliverAt] planned for its notification has come within [lateness],
  /// and it was not notified yet.
  static bool shouldNotify(
    CardDirection direction, {
    required bool cardSuspended,
    required DateTime deliverAt,
    required DateTime now,
  }) =>
      !cardSuspended &&
      direction.isScheduled &&
      direction.notifiedAt == null &&
      isOnTime(deliverAt, now);

  /// Whether a reminder planned at [moment] is due now and not too late.
  static bool isOnTime(DateTime moment, DateTime now) =>
      !moment.isAfter(now) && now.difference(moment) <= lateness;

  /// The [limit] next distinct wake-up moments after [now], each [moment]
  /// rounded up to the minute so that one wake-up shows everything due
  /// within that minute.
  static List<DateTime> wakeUps(
    Iterable<DateTime> moments, {
    required DateTime now,
    required int limit,
  }) {
    final wakeUps = {
      for (final moment in moments)
        if (moment.isAfter(now)) _ceilToMinute(moment),
    }.toList()..sort();
    return wakeUps.take(limit).toList();
  }

  static DateTime _ceilToMinute(DateTime moment) {
    final minute = DateTime(
      moment.year,
      moment.month,
      moment.day,
      moment.hour,
      moment.minute,
    );
    return minute == moment ? minute : minute.add(const Duration(minutes: 1));
  }
}
