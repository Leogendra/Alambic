import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/reviews/review_soon_days.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

void main() {
  const calendar = SchedulingCalendar();

  ReviewSoonDays daysAt(DateTime now) =>
      ReviewSoonDays(calendar: calendar, now: now);

  test('offers tomorrow, the day after and the coming Saturday', () {
    final days = daysAt(DateTime(2026, 11, 10, 9));
    expect(days.tomorrow, DateTime(2026, 11, 11));
    expect(days.dayAfterTomorrow, DateTime(2026, 11, 12));
    expect(days.weekend, DateTime(2026, 11, 14));
  });

  test('on a Saturday, the weekend is the Sunday that follows', () {
    expect(daysAt(DateTime(2026, 11, 14, 9)).weekend, DateTime(2026, 11, 15));
  });

  test('on a Sunday, the weekend is the next Saturday', () {
    expect(daysAt(DateTime(2026, 11, 15, 9)).weekend, DateTime(2026, 11, 21));
  });

  test('counts from the scheduling day, which starts at 4am', () {
    final days = daysAt(DateTime(2026, 11, 11, 1));
    expect(days.tomorrow, DateTime(2026, 11, 11));
  });
}
