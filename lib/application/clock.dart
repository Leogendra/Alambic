import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/scheduling/scheduling_calendar.dart';

/// Source of the current moment, replaced in tests by a fixed date.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);

final schedulingCalendarProvider = Provider(
  (ref) => const SchedulingCalendar(),
);
