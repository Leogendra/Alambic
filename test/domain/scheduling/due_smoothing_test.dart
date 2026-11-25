import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/scheduling/due_smoothing.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';

void main() {
  const calendar = SchedulingCalendar();
  final dueDay = DateTime(2026, 11, 25);

  /// [counts] cards due on each day, by offset from [dueDay].
  DueSmoothing load(Map<int, int> counts) => DueSmoothing(calendar, {
    for (final MapEntry(key: offset, value: count) in counts.entries)
      calendar.addDays(dueDay, offset): count,
  });

  DateTime day(int offset) => calendar.addDays(dueDay, offset);

  test('the window widens with the interval', () {
    expect(DueSmoothing.reachFor(14), 0);
    expect(DueSmoothing.reachFor(15), 1);
    expect(DueSmoothing.reachFor(29), 1);
    expect(DueSmoothing.reachFor(30), 2);
    expect(DueSmoothing.reachFor(89), 2);
    expect(DueSmoothing.reachFor(90), 3);
  });

  test('an interval under 15 days keeps its busy due day', () {
    expect(load({0: 5}).dayFor(dueDay, intervalDays: 14), dueDay);
  });

  test('a due day with no card due is kept', () {
    expect(load({-1: 3, 1: 3}).dayFor(dueDay, intervalDays: 15), dueDay);
  });

  test('a busy due day moves to the least busy day of the window', () {
    expect(load({0: 3, -1: 2, 1: 1}).dayFor(dueDay, intervalDays: 15), day(1));
    // From 30 days, two days away are in reach.
    expect(
      load({0: 3, -1: 2, 1: 2, -2: 1}).dayFor(dueDay, intervalDays: 30),
      day(2),
    );
  });

  test('a tie keeps the due day, then the nearest, then the earliest', () {
    expect(load({0: 2, -1: 2, 1: 2}).dayFor(dueDay, intervalDays: 15), dueDay);
    expect(
      load({0: 3, -1: 1, 1: 1, -2: 1, 2: 1, -3: 1, 3: 1})
          .dayFor(dueDay, intervalDays: 90),
      day(-1),
    );
    expect(load({0: 3, -1: 2, 1: 2}).dayFor(dueDay, intervalDays: 90), day(-2));
  });

  test('counts the scheduled cards but the one rescheduled', () {
    final noon = DateTime(2026, 11, 25, 12);
    final smoothing = DueSmoothing.of(
      [
        testCard(id: 1, dueAt: noon),
        testCard(id: 2, dueAt: noon),
        testCard(id: 3, dueAt: DateTime(2026, 11, 26, 12)),
        testCard(
          id: 4,
          state: CardState.pending,
          dueAt: DateTime(2026, 11, 24, 12),
        ),
      ],
      calendar,
      excluded: 2,
    );
    // Card 1 stays on the 25th, card 3 on the 26th; the pending card 4 is
    // not due, so the 24th is free.
    expect(smoothing.dayFor(dueDay, intervalDays: 15), day(-1));
  });
}
