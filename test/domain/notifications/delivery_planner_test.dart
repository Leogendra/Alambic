import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_direction.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/notifications/delivery_candidate.dart';
import 'package:alambic/domain/notifications/delivery_planner.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/presets/notification_mode.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/presets/schedule_kind.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

void main() {
  const planner = DeliveryPlanner(SchedulingCalendar());
  final range = BuiltInPresets.standard.copyWith(
    id: 3,
    scheduleKind: ScheduleKind.timeRange,
    rangeStart: const ClockTime(9, 0),
    rangeEnd: const ClockTime(17, 0),
  );

  DeliveryCandidate candidate(
    int id,
    DateTime dueAt, {
    Preset? preset,
    int? groupId,
  }) => DeliveryCandidate(
    direction: CardDirection(
      id: id,
      cardId: id,
      sense: DirectionSense.frontToBack,
      state: DirectionState.active,
      step: 1,
      dueAt: dueAt,
      lastReviewedAt: null,
      notifiedAt: null,
      distillationId: null,
      queuePosition: null,
    ),
    preset: preset ?? range,
    groupId: groupId,
  );

  group('a time range', () {
    test('spreads the cards of a day evenly, in the order of their ids', () {
      final rangeStart = DateTime(2026, 11, 10, 9);
      final plan = planner.plan([
        for (final id in [4, 2, 3, 1]) candidate(id, rangeStart),
      ]);
      expect(plan, {
        1: DateTime(2026, 11, 10, 9),
        2: DateTime(2026, 11, 10, 11),
        3: DateTime(2026, 11, 10, 13),
        4: DateTime(2026, 11, 10, 15),
      });
    });

    test('rounds the moments down to the minute', () {
      final rangeStart = DateTime(2026, 11, 10, 9);
      final plan = planner.plan([
        for (final id in [1, 2, 3, 4, 5, 6, 7]) candidate(id, rangeStart),
      ]);
      // 8 hours / 7 = 1 h 08 min 34 s.
      expect(plan[2], DateTime(2026, 11, 10, 10, 8));
      expect(plan[7], DateTime(2026, 11, 10, 15, 51));
    });

    test('spreads each day and each preset on its own', () {
      final other = range.copyWith(id: 4);
      final plan = planner.plan([
        candidate(1, DateTime(2026, 11, 10, 9)),
        candidate(2, DateTime(2026, 11, 10, 9)),
        candidate(3, DateTime(2026, 11, 11, 9)),
        candidate(4, DateTime(2026, 11, 10, 9), preset: other),
      ]);
      expect(plan[2], DateTime(2026, 11, 10, 13));
      expect(plan[3], DateTime(2026, 11, 11, 9));
      expect(plan[4], DateTime(2026, 11, 10, 9));
    });

    test('leaves a sub-day due moment and a grouped reminder alone', () {
      final grouped = range.copyWith(
        notificationMode: NotificationMode.grouped,
      );
      final plan = planner.plan([
        candidate(1, DateTime(2026, 11, 10, 15, 17)),
        candidate(2, DateTime(2026, 11, 10, 9)),
        candidate(3, DateTime(2026, 11, 10, 9), preset: grouped),
        candidate(4, DateTime(2026, 11, 10, 9), preset: grouped),
      ]);
      expect(plan, {
        1: DateTime(2026, 11, 10, 15, 17),
        2: DateTime(2026, 11, 10, 9),
        3: DateTime(2026, 11, 10, 9),
        4: DateTime(2026, 11, 10, 9),
      });
    });
  });

  test('a fixed time notifies at the due date', () {
    final noon = DateTime(2026, 11, 10, 12);
    final plan = planner.plan([
      candidate(1, noon, preset: BuiltInPresets.standard),
      candidate(2, noon, preset: BuiltInPresets.standard),
    ]);
    expect(plan, {1: noon, 2: noon});
  });
}
