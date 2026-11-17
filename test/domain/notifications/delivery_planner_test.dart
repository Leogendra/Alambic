import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/groups/sequence_end.dart';
import 'package:alambic/domain/notifications/delivery_candidate.dart';
import 'package:alambic/domain/notifications/delivery_planner.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';
import 'package:alambic/domain/notifications/notification_mode.dart';
import 'package:alambic/domain/notifications/reminder_settings.dart';
import 'package:alambic/domain/notifications/schedule_kind.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/scheduling/card_progress.dart';
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

  DeliveryCandidate candidate(
    int id,
    DateTime dueAt, {
    Preset? preset,
    int groupId = 1,
    int? step = 1,
    DateTime? notifiedAt,
  }) {
    final card = testCard(
      id: id,
      groupId: groupId,
      state: CardState.active,
      step: step,
      dueAt: dueAt,
      notifiedAt: notifiedAt,
    );
    return DeliveryCandidate(
      card: card,
      progress: CardProgress.of(
        card,
        preset ?? BuiltInPresets.standard,
        SequenceEnd.standard,
      ),
    );
  }

  Map<int, DateTime> plan(
    List<DeliveryCandidate> candidates, {
    DateTime? now,
    ReminderSettings? reminders,
  }) => planner.plan(
    candidates,
    now: now ?? DateTime(2026, 11, 10, 8),
    reminders: reminders ?? range,
  );

  group('a time range', () {
    test('spreads the cards of a day evenly, in the order of their ids', () {
      final rangeStart = DateTime(2026, 11, 10, 9);
      final moments = plan([
        for (final id in [4, 2, 3, 1]) candidate(id, rangeStart),
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
        for (final id in [1, 2, 3, 4, 5, 6, 7]) candidate(id, rangeStart),
      ]);
      // 8 hours / 7 = 1 h 08 min 34 s.
      expect(moments[2], DateTime(2026, 11, 10, 10, 8));
      expect(moments[7], DateTime(2026, 11, 10, 15, 51));
    });

    test('spreads each day on its own, whatever the preset', () {
      final moments = plan([
        candidate(1, DateTime(2026, 11, 10, 9)),
        candidate(
          2,
          DateTime(2026, 11, 10, 9),
          preset: BuiltInPresets.intensive,
        ),
        candidate(3, DateTime(2026, 11, 11, 9)),
      ]);
      expect(moments[2], DateTime(2026, 11, 10, 13));
      expect(moments[3], DateTime(2026, 11, 11, 9));
    });

    test('leaves a sub-day due moment alone', () {
      final moments = plan([
        candidate(1, DateTime(2026, 11, 10, 15, 17)),
        candidate(2, DateTime(2026, 11, 10, 9)),
      ]);
      expect(moments, {
        1: DateTime(2026, 11, 10, 15, 17),
        2: DateTime(2026, 11, 10, 9),
      });
    });

    test('keeps the grouped reminders at its start', () {
      final moments = plan([
        candidate(1, DateTime(2026, 11, 10, 9)),
        candidate(2, DateTime(2026, 11, 10, 9)),
      ], reminders: range.copyWith(notificationMode: NotificationMode.grouped));
      expect(moments, {
        1: DateTime(2026, 11, 10, 9),
        2: DateTime(2026, 11, 10, 9),
      });
    });
  });

  test('a fixed time notifies at the due date', () {
    final noon = DateTime(2026, 11, 10, 12);
    final moments = plan([
      candidate(1, noon),
      candidate(2, noon),
    ], reminders: fixed);
    expect(moments, {1: noon, 2: noon});
  });

  group('a direction still due from an earlier day', () {
    test('is notified again today, at the daily slot', () {
      final moments = plan(
        [
          candidate(
            1,
            DateTime(2026, 11, 9, 12),
            preset: BuiltInPresets.standard,
          ),
          candidate(
            2,
            DateTime(2026, 11, 2, 12),
            preset: BuiltInPresets.standard,
          ),
          candidate(
            3,
            DateTime(2026, 11, 9, 15, 17),
            preset: BuiltInPresets.intensive,
          ),
          candidate(
            4,
            DateTime(2026, 11, 10, 18),
            preset: BuiltInPresets.standard,
          ),
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
        candidate(1, DateTime(2026, 11, 9, 9)),
        candidate(2, DateTime(2026, 11, 10, 9)),
      ], now: DateTime(2026, 11, 10, 8));
      expect(moments, {
        1: DateTime(2026, 11, 10, 9),
        2: DateTime(2026, 11, 10, 13),
      });
    });
  });

  group('quiet hours', () {
    const guards = NotificationGuards.defaults;
    final intensive = BuiltInPresets.intensive;

    Map<int, DateTime> guarded(
      List<DeliveryCandidate> candidates,
      DateTime now,
    ) => planner.plan(candidates, now: now, reminders: fixed, guards: guards);

    test('move a notification falling inside to their end', () {
      final moments = guarded([
        candidate(1, DateTime(2026, 11, 10, 23, 10), preset: intensive),
        candidate(2, DateTime(2026, 11, 11, 2, 30), preset: intensive),
        candidate(3, DateTime(2026, 11, 11, 7, 59), preset: intensive),
        candidate(4, DateTime(2026, 11, 10, 21, 59), preset: intensive),
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
        candidate(1, DateTime(2026, 11, 10, 23, 10), preset: intensive),
      ], DateTime(2026, 11, 11, 7));
      expect(moments[1], DateTime(2026, 11, 11, 8));
    });

    test('hold a late notification until their end', () {
      final noon = DateTime(2026, 11, 10, 12);
      final moments = guarded([
        candidate(1, noon),
        candidate(2, noon, notifiedAt: noon),
      ], DateTime(2026, 11, 10, 23));
      expect(moments, {1: DateTime(2026, 11, 11, 8), 2: noon});
      // Outside them, a late notification is shown at once.
      expect(guarded([candidate(1, noon)], DateTime(2026, 11, 10, 18)), {
        1: DateTime(2026, 11, 10, 18),
      });
    });

    test('are ignored when turned off', () {
      final moments = planner.plan(
        [candidate(1, DateTime(2026, 11, 10, 23, 10), preset: intensive)],
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

  group('the daily cap', () {
    final noon = DateTime(2026, 11, 10, 12);
    final standard = BuiltInPresets.standard;
    final guards = NotificationGuards.defaults.copyWith(dailyCap: 2);

    test('moves the longest intervals to the slot of the next day', () {
      final moments = planner.plan(
        [
          candidate(1, noon, preset: standard, step: 5),
          candidate(2, noon, preset: standard, step: 0),
          candidate(3, noon, preset: standard, step: null),
          candidate(4, noon, preset: standard, step: 3),
        ],
        now: DateTime(2026, 11, 10, 8),
        reminders: fixed,
        guards: guards,
      );
      expect(moments, {
        1: DateTime(2026, 11, 11, 12),
        2: noon,
        3: noon,
        4: DateTime(2026, 11, 11, 12),
      });
    });

    test('counts the cards already notified today', () {
      final moments = planner.plan(
        [
          candidate(1, noon, preset: standard, step: 0),
          candidate(2, noon, preset: standard, step: 1),
          candidate(
            3,
            DateTime(2026, 11, 10, 9),
            preset: standard,
            notifiedAt: DateTime(2026, 11, 10, 9),
          ),
        ],
        now: DateTime(2026, 11, 10, 10),
        reminders: fixed,
        guards: guards,
        notifiedToday: 1,
      );
      expect(moments[1], noon);
      expect(moments[2], DateTime(2026, 11, 11, 12));
      expect(moments[3], DateTime(2026, 11, 10, 9));
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
