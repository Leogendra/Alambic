import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/daily_slot_move.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';

void main() {
  const move = DailySlotMove(SchedulingCalendar());
  const noon = ClockTime(12, 0);
  final now = DateTime(2026, 11, 10, 9);

  DateTime? moved(DateTime dueAt, {ClockTime to = const ClockTime(8, 30)}) =>
      move.movedDueAt(
        testCard(dueAt: dueAt, step: 1),
        from: noon,
        to: to,
        now: now,
      );

  test('a due date at the old slot moves to the new one, same day', () {
    expect(moved(DateTime(2026, 11, 14, 12)), DateTime(2026, 11, 14, 8, 30));
    expect(moved(DateTime(2026, 11, 10, 12)), DateTime(2026, 11, 10, 8, 30));
  });

  test('a slot before 4am belongs to the end of the scheduling day', () {
    expect(
      moved(DateTime(2026, 11, 14, 12), to: const ClockTime(1, 0)),
      DateTime(2026, 11, 15, 1),
    );
  });

  test('a due date set by a sub-day interval keeps its moment', () {
    expect(moved(DateTime(2026, 11, 10, 15, 17)), isNull);
  });

  test('a due date already passed stays', () {
    expect(moved(DateTime(2026, 11, 9, 12)), isNull);
  });

  test('a pending card has no due date to move', () {
    expect(
      move.movedDueAt(
        testCard(state: CardState.pending, queuePosition: 0),
        from: noon,
        to: const ClockTime(8, 30),
        now: now,
      ),
      isNull,
    );
  });
}
