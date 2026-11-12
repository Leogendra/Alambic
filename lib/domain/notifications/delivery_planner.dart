import '../presets/notification_mode.dart';
import '../presets/schedule_kind.dart';
import '../scheduling/scheduling_calendar.dart';
import 'delivery_candidate.dart';

/// Decides when each due direction is notified, which is not always its due
/// date.
///
/// Rules owned here:
/// - with a time range and one notification per card, the directions due at
///   the start of the range on a day are spread evenly over the range, in
///   the order of their ids; a grouped reminder stays at the start.
class DeliveryPlanner {
  const DeliveryPlanner(this.calendar);

  final SchedulingCalendar calendar;

  /// Moment at which each candidate is notified, by direction id.
  Map<int, DateTime> plan(Iterable<DeliveryCandidate> candidates) {
    final moments = <int, DateTime>{};
    final ranges = <(int, DateTime), List<DeliveryCandidate>>{};
    for (final candidate in candidates) {
      final dueAt = candidate.direction.dueAt!;
      final day = calendar.dayOf(dueAt);
      if (_spreadsOverRange(candidate) &&
          dueAt == calendar.momentAt(day, candidate.preset.rangeStart)) {
        ranges.putIfAbsent((candidate.preset.id, day), () => []).add(candidate);
      } else {
        moments[candidate.direction.id] = dueAt;
      }
    }
    for (final MapEntry(key: (_, day), value: sharing) in ranges.entries) {
      moments.addAll(_spread(sharing, day));
    }
    return moments;
  }

  static bool _spreadsOverRange(DeliveryCandidate candidate) =>
      candidate.preset.scheduleKind == ScheduleKind.timeRange &&
      candidate.preset.notificationMode == NotificationMode.perCard;

  /// [sharing] spread over the range of their preset on [day]: the first at
  /// its start, then one every range length divided by their number.
  Map<int, DateTime> _spread(List<DeliveryCandidate> sharing, DateTime day) {
    final preset = sharing.first.preset;
    final start = calendar.momentAt(day, preset.rangeStart);
    final end = calendar.momentAt(day, preset.rangeEnd);
    final range = end.isAfter(start) ? end.difference(start) : Duration.zero;
    final ordered = sharing.toList()
      ..sort(
        (first, second) => first.direction.id.compareTo(second.direction.id),
      );
    return {
      for (final (index, candidate) in ordered.indexed)
        candidate.direction.id: _toMinute(
          start.add(range * index ~/ ordered.length),
        ),
    };
  }

  static DateTime _toMinute(DateTime moment) => DateTime(
    moment.year,
    moment.month,
    moment.day,
    moment.hour,
    moment.minute,
  );
}
