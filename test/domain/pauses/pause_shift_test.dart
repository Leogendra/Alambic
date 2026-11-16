import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/pauses/pause_shift.dart';
import 'package:alambic/domain/pauses/pauses.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';

void main() {
  const shift = PauseShift(SchedulingCalendar());
  final pausedAt = DateTime(2026, 11, 10, 20);

  Flashcard direction({DateTime? dueAt, DateTime? lastReviewedAt}) => testCard(
    state: CardState.active,
    step: 2,
    stability: null,
    difficulty: null,
    dueAt: dueAt,
    lastReviewedAt: lastReviewedAt,
    notifiedAt: null,
    queuePosition: null,
  );

  test('counts the pause in scheduling days', () {
    expect(shift.days(pausedAt, DateTime(2026, 11, 13, 9)), 3);
    // Resumed at 2am: still the 12th for the 4am calendar.
    expect(shift.days(pausedAt, DateTime(2026, 11, 13, 2)), 2);
    expect(shift.days(pausedAt, DateTime(2026, 11, 10, 23)), 0);
  });

  test('shifts a due date by the pause, keeping its time', () {
    expect(
      shift.shiftedDueAt(
        direction(dueAt: DateTime(2026, 11, 12, 12)),
        pausedAt: pausedAt,
        resumedAt: DateTime(2026, 11, 17, 9),
      ),
      DateTime(2026, 11, 19, 12),
    );
  });

  test('leaves a direction answered during the pause alone', () {
    expect(
      shift.shiftedDueAt(
        direction(
          dueAt: DateTime(2026, 11, 20, 12),
          lastReviewedAt: DateTime(2026, 11, 12, 9),
        ),
        pausedAt: pausedAt,
        resumedAt: DateTime(2026, 11, 17, 9),
      ),
      isNull,
    );
  });

  test('moves nothing after a pause shorter than a day', () {
    expect(
      shift.shiftedDueAt(
        direction(dueAt: DateTime(2026, 11, 11, 12)),
        pausedAt: pausedAt,
        resumedAt: DateTime(2026, 11, 10, 23),
      ),
      isNull,
    );
  });

  test('the global pause covers every group, a group pause its own', () {
    final groupPause = Pauses(groupsSince: {3: pausedAt});
    expect(groupPause.covers(3), isTrue);
    expect(groupPause.covers(4), isFalse);
    expect(Pauses(globalSince: pausedAt).covers(4), isTrue);
  });
}
