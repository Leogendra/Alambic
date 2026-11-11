import 'package:drift/drift.dart';

import '../../../domain/scheduling/clock_time.dart';

/// Stores a time of day as minutes since midnight.
class ClockTimeConverter extends TypeConverter<ClockTime, int> {
  const ClockTimeConverter();

  @override
  ClockTime fromSql(int fromDb) => ClockTime.fromMinutesSinceMidnight(fromDb);

  @override
  int toSql(ClockTime value) => value.minutesSinceMidnight;
}
