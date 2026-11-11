import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/domain/scheduling/clock_time.dart';
import 'package:remanence/domain/scheduling/scheduling_calendar.dart';

void main() {
  const calendar = SchedulingCalendar();

  group('dayOf', () {
    test('a moment after 4am belongs to its calendar date', () {
      expect(calendar.dayOf(DateTime(2026, 11, 10, 4)), DateTime(2026, 11, 10));
    });

    test('a moment before 4am belongs to the previous day', () {
      expect(
        calendar.dayOf(DateTime(2026, 11, 10, 3, 59)),
        DateTime(2026, 11, 9),
      );
    });

    test('day boundaries cross months', () {
      expect(calendar.dayOf(DateTime(2026, 12, 1, 1)), DateTime(2026, 11, 30));
    });
  });

  group('momentAt', () {
    test('places a daytime slot on the same calendar date', () {
      expect(
        calendar.momentAt(DateTime(2026, 11, 10), const ClockTime(12, 0)),
        DateTime(2026, 11, 10, 12),
      );
    });

    test('places a slot before 4am at the end of the scheduling day', () {
      expect(
        calendar.momentAt(DateTime(2026, 11, 10), const ClockTime(2, 30)),
        DateTime(2026, 11, 11, 2, 30),
      );
    });
  });

  test('endOf is the next day start', () {
    expect(calendar.endOf(DateTime(2026, 11, 10)), DateTime(2026, 11, 11, 4));
  });
}
