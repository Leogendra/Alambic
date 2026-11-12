import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_direction.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/scheduling/due_policy.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

CardDirection direction({
  DirectionState state = DirectionState.active,
  DateTime? dueAt,
  DateTime? lastReviewedAt,
}) => CardDirection(
  id: 1,
  cardId: 1,
  sense: DirectionSense.frontToBack,
  state: state,
  step: 0,
  dueAt: dueAt,
  lastReviewedAt: lastReviewedAt,
  notifiedAt: null,
  distillationId: null,
  queuePosition: null,
);

void main() {
  const policy = DuePolicy(SchedulingCalendar());
  final now = DateTime(2026, 11, 10, 9);

  bool isDue(CardDirection value, {bool suspended = false}) =>
      policy.isDueToday(value, cardSuspended: suspended, now: now);

  test('a past due moment is due', () {
    expect(isDue(direction(dueAt: DateTime(2026, 11, 8, 12))), isTrue);
  });

  test('a due later today is due before its slot', () {
    expect(isDue(direction(dueAt: DateTime(2026, 11, 10, 12))), isTrue);
  });

  test('a due tomorrow is not due', () {
    expect(isDue(direction(dueAt: DateTime(2026, 11, 11, 12))), isFalse);
  });

  test('a sub-day interval answered today waits for its moment', () {
    final waiting = direction(
      dueAt: DateTime(2026, 11, 10, 9, 10),
      lastReviewedAt: DateTime(2026, 11, 10, 9),
    );
    expect(isDue(waiting), isFalse);
  });

  test('suspended, acquired or pending directions are never due', () {
    final past = DateTime(2026, 11, 8);
    expect(isDue(direction(dueAt: past), suspended: true), isFalse);
    expect(
      isDue(direction(dueAt: past, state: DirectionState.acquired)),
      isFalse,
    );
    expect(
      isDue(direction(dueAt: past, state: DirectionState.pending)),
      isFalse,
    );
  });
}
