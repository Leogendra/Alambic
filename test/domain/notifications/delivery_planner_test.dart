import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/notifications/delivery_planner.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';
import 'package:alambic/domain/notifications/notification_mode.dart';
import 'package:alambic/domain/notifications/reminder_settings.dart';
import 'package:alambic/domain/notifications/schedule_kind.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';

void main() {
  const planner = DeliveryPlanner(SchedulingCalendar());
  const fixed = ReminderSettings.defaults;
  final range = fixed.copyWith(
    scheduleKind: ScheduleKind.timeRange,
    rangeStart: const ClockTime(9, 0),
    rangeEnd: const ClockTime(17, 0),
  );

  Flashcard card(
    int id,
    DateTime dueAt, {
    int groupId = 1,
    DateTime? notifiedAt,
  }) => testCard(
    id: id,
    groupId: groupId,
    state: CardState.active,
    step: 1,
    dueAt: dueAt,
    notifiedAt: notifiedAt,
  );

  Map<int, DateTime> plan(
    List<Flashcard> cards, {
    DateTime? now,
    ReminderSettings? reminders,
  }) => planner.plan(
    cards,
    now: now ?? DateTime(2026, 11, 10, 8),
    reminders: reminders ?? range,
  );

  group('a time range', () {
    test('spreads the cards of a day evenly, in the order of their ids', () {
      final rangeStart = DateTime(2026, 11, 10, 9);
      final moments = plan([
        for (final id in [4, 2, 3, 1]) card(id, rangeStart),
      ]);
      expect(moments, {
        1: DateTime(2026, 11, 10, 9),
        2: DateTime(2026, 11, 10, 11),
        3: DateTime(2026, 11, 10, 13),
        4: DateTime(2026, 11, 10, 15),
      });
    });

    test('rounds the moments down to the minute', () {
      final rangeStart = DateTime(2026, 11, 10, 9);
      final moments = plan([
        for (final id in [1, 2, 3, 4, 5, 6, 7]) card(id, rangeStart),
      ]);
      // 8 hours / 7 = 1 h 08 min 34 s.
      expect(moments[2], DateTime(2026, 11, 10, 10, 8));
      expect(moments[7], DateTime(2026, 11, 10, 15, 51));
    });

    test('spreads each day on its own', () {
      final moments = plan([
        card(1, DateTime(2026, 11, 10, 9)),
        card(2, DateTime(2026, 11, 10, 9)),
        card(3, DateTime(2026, 11, 11, 9)),
      ]);
      expect(moments[2], DateTime(2026, 11, 10, 13));
      expect(moments[3], DateTime(2026, 11, 11, 9));
    });

    test('leaves a sub-day due moment alone', () {
      final moments = plan([
        card(1, DateTime(2026, 11, 10, 15, 17)),
        card(2, DateTime(2026, 11, 10, 9)),
      ]);
      expect(moments, {
        1: DateTime(2026, 11, 10, 15, 17),
        2: DateTime(2026, 11, 10, 9),
      });
    });

    test('keeps the grouped reminders at its start', () {
      final moments = plan([
        card(1, DateTime(2026, 11, 10, 9)),
        card(2, DateTime(2026, 11, 10, 9)),
      ], reminders: range.copyWith(notificationMode: NotificationMode.grouped));
      expect(moments, {
        1: DateTime(2026, 11, 10, 9),
        2: DateTime(2026, 11, 10, 9),
      });
    });
  });

  test('a fixed time notifies at the due date', () {
    final noon = DateTime(2026, 11, 10, 12);
    final moments = plan([card(1, noon), card(2, noon)], reminders: fixed);
    expect(moments, {1: noon, 2: noon});
  });

  group('a direction still due from an earlier day', () {
    test('is notified again today, at the daily slot', () {
      final moments = plan(
        [
          card(1, DateTime(2026, 11, 9, 12)),
          card(2, DateTime(2026, 11, 2, 12)),
          card(3, DateTime(2026, 11, 9, 15, 17)),
          card(4, DateTime(2026, 11, 10, 18)),
        ],
        now: DateTime(2026, 11, 10, 8),
        reminders: fixed,
      );
      expect(moments, {
        1: DateTime(2026, 11, 10, 12),
        2: DateTime(2026, 11, 10, 12),
        3: DateTime(2026, 11, 10, 12),
        4: DateTime(2026, 11, 10, 18),
      });
    });

    test('shares the time range of the day with the cards due today', () {
      final moments = plan([
        card(1, DateTime(2026, 11, 9, 9)),
        card(2, DateTime(2026, 11, 10, 9)),
      ], now: DateTime(2026, 11, 10, 8));
      expect(moments, {
        1: DateTime(2026, 11, 10, 9),
        2: DateTime(2026, 11, 10, 13),
      });
    });
  });

  group('quiet hours', () {
    const guards = NotificationGuards.defaults;

    Map<int, DateTime> guarded(List<Flashcard> cards, DateTime now) =>
        planner.plan(cards, now: now, reminders: fixed, guards: guards);

    test('move a notification falling inside to their end', () {
      final moments = guarded([
        card(1, DateTime(2026, 11, 10, 23, 10)),
        card(2, DateTime(2026, 11, 11, 2, 30)),
        card(3, DateTime(2026, 11, 11, 7, 59)),
        card(4, DateTime(2026, 11, 10, 21, 59)),
      ], DateTime(2026, 11, 10, 21));
      expect(moments, {
        1: DateTime(2026, 11, 11, 8),
        2: DateTime(2026, 11, 11, 8),
        3: DateTime(2026, 11, 11, 8),
        4: DateTime(2026, 11, 10, 21, 59),
      });
    });

    test('keep the moved notification on the next morning', () {
      final moments = guarded([
        card(1, DateTime(2026, 11, 10, 23, 10)),
      ], DateTime(2026, 11, 11, 7));
      expect(moments[1], DateTime(2026, 11, 11, 8));
    });

    test('hold a late notification until their end', () {
      final noon = DateTime(2026, 11, 10, 12);
      final moments = guarded([
        card(1, noon),
        card(2, noon, notifiedAt: noon),
      ], DateTime(2026, 11, 10, 23));
      expect(moments, {1: DateTime(2026, 11, 11, 8), 2: noon});
      // Outside them, a late notification is shown at once.
      expect(guarded([card(1, noon)], DateTime(2026, 11, 10, 18)), {
        1: DateTime(2026, 11, 10, 18),
      });
    });

    test('are ignored when turned off', () {
      final moments = planner.plan(
        [card(1, DateTime(2026, 11, 10, 23, 10))],
        now: DateTime(2026, 11, 10, 21),
        reminders: fixed,
        guards: guards.copyWith(quietHoursEnabled: false),
      );
      expect(moments[1], DateTime(2026, 11, 10, 23, 10));
    });

    test('may stay within a day', () {
      final nap = guards.copyWith(
        quietStart: const ClockTime(13, 0),
        quietEnd: const ClockTime(14, 30),
      );
      expect(nap.isQuiet(const ClockTime(13, 45)), isTrue);
      expect(nap.isQuiet(const ClockTime(14, 30)), isFalse);
      expect(nap.isQuiet(const ClockTime(23, 0)), isFalse);
    });
  });

  test('a card still due after its moment comes back the next day', () {
    final retry = planner.nextDayRetry(
      now: DateTime(2026, 11, 10, 18),
      reminders: fixed,
      guards: NotificationGuards.defaults.copyWith(
        quietStart: const ClockTime(22, 0),
        quietEnd: const ClockTime(13, 0),
      ),
    );
    expect(retry, DateTime(2026, 11, 11, 13));
  });
}
