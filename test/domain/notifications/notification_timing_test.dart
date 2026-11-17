import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/notifications/notification_timing.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';

void main() {
  Flashcard card({
    CardState state = CardState.active,
    DateTime? dueAt,
    DateTime? notifiedAt,
    bool suspended = false,
  }) => testCard(
    state: state,
    step: 0,
    dueAt: state == CardState.active
        ? dueAt ?? DateTime(2026, 11, 10, 12)
        : null,
    notifiedAt: notifiedAt,
    suspended: suspended,
  );

  bool shouldNotify(Flashcard card, DateTime now, {DateTime? deliverAt}) =>
      NotificationTiming.shouldNotify(
        card,
        deliverAt: deliverAt ?? card.dueAt ?? DateTime(2026, 11, 10, 12),
        now: now,
        calendar: const SchedulingCalendar(),
      );

  group('a reminder is shown', () {
    test('once its moment has come', () {
      expect(shouldNotify(card(), DateTime(2026, 11, 10, 11, 59)), false);
      expect(shouldNotify(card(), DateTime(2026, 11, 10, 12)), true);
      expect(shouldNotify(card(), DateTime(2026, 11, 10, 12, 40)), true);
    });

    test('however late', () {
      expect(shouldNotify(card(), DateTime(2026, 11, 10, 23, 30)), true);
    });

    test('only once per due date', () {
      final notified = card(notifiedAt: DateTime(2026, 11, 10, 12));
      expect(shouldNotify(notified, DateTime(2026, 11, 10, 12, 1)), false);
    });

    test('again the next day when it was ignored', () {
      final ignored = card(
        dueAt: DateTime(2026, 11, 9, 12),
        notifiedAt: DateTime(2026, 11, 9, 12),
      );
      expect(
        shouldNotify(
          ignored,
          DateTime(2026, 11, 10, 12),
          deliverAt: DateTime(2026, 11, 10, 12),
        ),
        true,
      );
    });

    test('never for a suspended card or a card not scheduled', () {
      final now = DateTime(2026, 11, 10, 12);
      expect(shouldNotify(card(suspended: true), now), false);
      expect(shouldNotify(card(state: CardState.pending), now), false);
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
