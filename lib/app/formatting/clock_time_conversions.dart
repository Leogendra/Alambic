import 'package:material_ui/material_ui.dart';

import '../../domain/scheduling/clock_time.dart';

/// Conversions between the domain [ClockTime] and Flutter's [TimeOfDay].
extension ClockTimeConversions on ClockTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}

extension TimeOfDayConversions on TimeOfDay {
  ClockTime toClockTime() => ClockTime(hour, minute);
}
