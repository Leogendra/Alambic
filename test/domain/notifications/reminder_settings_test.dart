import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/notifications/reminder_settings.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';

void main() {
  const range = ReminderSettings.defaults;

  test('the end of a range may follow or equal its start', () {
    expect(range.hasOrderedRange, isTrue);
    expect(
      range
          .copyWith(
            rangeStart: const ClockTime(9, 0),
            rangeEnd: const ClockTime(9, 0),
          )
          .hasOrderedRange,
      isTrue,
    );
  });

  test('the end of a range never precedes its start', () {
    expect(
      range.copyWith(rangeEnd: const ClockTime(8, 59)).hasOrderedRange,
      isFalse,
    );
    expect(
      range
          .copyWith(
            rangeStart: const ClockTime(22, 0),
            rangeEnd: const ClockTime(1, 0),
          )
          .hasOrderedRange,
      isFalse,
      reason: 'a range does not run past midnight',
    );
  });
}
