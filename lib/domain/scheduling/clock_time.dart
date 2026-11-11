/// A time of day, independent of any date (for example the 12:00 slot of a preset).
class ClockTime implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  factory ClockTime.fromMinutesSinceMidnight(int minutes) =>
      ClockTime(minutes ~/ 60, minutes % 60);

  final int hour;
  final int minute;

  int get minutesSinceMidnight => hour * 60 + minute;

  @override
  int compareTo(ClockTime other) =>
      minutesSinceMidnight.compareTo(other.minutesSinceMidnight);

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.minutesSinceMidnight == minutesSinceMidnight;

  @override
  int get hashCode => minutesSinceMidnight.hashCode;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
