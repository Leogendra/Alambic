import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/domain/cards/card_direction.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/cards/direction_state.dart';
import 'package:remanence/domain/notifications/notification_timing.dart';

void main() {
  CardDirection direction({
    DirectionState state = DirectionState.active,
    DateTime? dueAt,
    DateTime? notifiedAt,
  }) => CardDirection(
    id: 1,
    cardId: 1,
    sense: DirectionSense.frontToBack,
    state: state,
    step: 0,
    dueAt: dueAt ?? DateTime(2026, 11, 10, 12),
    lastReviewedAt: null,
    notifiedAt: notifiedAt,
    distillationId: null,
    queuePosition: null,
  );

  bool shouldNotify(CardDirection direction, DateTime now) =>
      NotificationTiming.shouldNotify(
        direction,
        cardSuspended: false,
        now: now,
      );

  group('a reminder is shown', () {
    test('once its moment has come', () {
      expect(shouldNotify(direction(), DateTime(2026, 11, 10, 11, 59)), false);
      expect(shouldNotify(direction(), DateTime(2026, 11, 10, 12)), true);
      expect(shouldNotify(direction(), DateTime(2026, 11, 10, 12, 40)), true);
    });

    test('not when more than an hour late', () {
      expect(shouldNotify(direction(), DateTime(2026, 11, 10, 13, 1)), false);
    });

    test('only once per due date', () {
      final notified = direction(notifiedAt: DateTime(2026, 11, 10, 12));
      expect(shouldNotify(notified, DateTime(2026, 11, 10, 12, 1)), false);
    });

    test('never for a suspended card or a direction not scheduled', () {
      expect(
        NotificationTiming.shouldNotify(
          direction(),
          cardSuspended: true,
          now: DateTime(2026, 11, 10, 12),
        ),
        false,
      );
      final unstarted = CardDirection(
        id: 1,
        cardId: 1,
        sense: DirectionSense.frontToBack,
        state: DirectionState.unstarted,
        step: null,
        dueAt: null,
        lastReviewedAt: null,
        notifiedAt: null,
        distillationId: null,
        queuePosition: null,
      );
      expect(shouldNotify(unstarted, DateTime(2026, 11, 10, 12)), false);
    });
  });

  test('wake-ups are the next distinct minutes, in order, up to a limit', () {
    final wakeUps = NotificationTiming.wakeUps(
      [
        DateTime(2026, 11, 11, 12),
        DateTime(2026, 11, 10, 15, 17, 23),
        DateTime(2026, 11, 10, 12),
        DateTime(2026, 11, 11, 12),
        DateTime(2026, 11, 10, 8),
        DateTime(2026, 11, 12, 12),
      ],
      now: DateTime(2026, 11, 10, 9),
      limit: 3,
    );
    expect(wakeUps, [
      DateTime(2026, 11, 10, 12),
      DateTime(2026, 11, 10, 15, 18),
      DateTime(2026, 11, 11, 12),
    ]);
  });
}
