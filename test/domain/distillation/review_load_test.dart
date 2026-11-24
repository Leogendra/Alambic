import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/distillation/review_load.dart';
import 'package:alambic/domain/groups/remanence_interval.dart';
import 'package:alambic/domain/groups/sequence_end.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';
import '../test_groups.dart';
import '../test_presets.dart';

void main() {
  final now = DateTime(2026, 11, 10, 9);
  final today = DateTime(2026, 11, 10);
  final lastWeek = DateTime(2026, 11, 3, 12);

  DateTime day(int offset) => DateTime(2026, 11, 10 + offset);

  ReviewLoad load({Preset? preset, SequenceEnd? end, DateTime? until}) =>
      ReviewLoad(
        calendar: const SchedulingCalendar(),
        preset: preset ?? shortSequence(),
        end: end ?? remanence(RemanenceInterval.threeMonths),
        until: until ?? day(365),
      );

  List<DateTime> reviewDays(ReviewLoad load) => [
    for (var offset = 0; offset < 365; offset++)
      for (var review = 0; review < load.on(day(offset)); review++) day(offset),
  ];

  group('a card already introduced', () {
    test('follows its sequence, then its remanence', () {
      final reviews = load()
        ..addIntroducedCard(
          testCard(dueAt: DateTime(2026, 11, 13, 12), lastReviewedAt: lastWeek),
          now: now,
        );
      // 1 d, 2 d, 4 d, then every 3 months (90 days).
      expect(reviewDays(reviews), [
        day(3),
        day(4),
        day(6),
        day(10),
        day(100),
        day(190),
        day(280),
      ]);
    });

    test('stops after its last step when the group acquires it', () {
      final reviews = load(end: acquiredEnd)
        ..addIntroducedCard(
          testCard(dueAt: DateTime(2026, 11, 13, 12), lastReviewedAt: lastWeek),
          now: now,
        );
      expect(reviewDays(reviews), [day(3), day(4), day(6), day(10)]);
    });

    test('resumes from its step; a card in remanence keeps coming back', () {
      final reviews = load()
        ..addIntroducedCard(
          testCard(
            step: 1,
            dueAt: DateTime(2026, 11, 13, 12),
            lastReviewedAt: lastWeek,
          ),
          now: now,
        )
        ..addIntroducedCard(
          testCard(
            id: 2,
            state: CardState.completed,
            dueAt: DateTime(2026, 11, 20, 12),
            lastReviewedAt: lastWeek,
          ),
          now: now,
        );
      expect(reviewDays(reviews), [
        day(3),
        day(7),
        day(10),
        day(97),
        day(100),
        day(187),
        day(190),
        day(277),
        day(280),
      ]);
    });

    test('a late card is counted today', () {
      final reviews = load()
        ..addIntroducedCard(
          testCard(dueAt: DateTime(2026, 11, 7, 12), lastReviewedAt: lastWeek),
          now: now,
        );
      expect(reviews.on(today), 1);
      expect(reviews.on(day(1)), 1);
    });

    test('a card due later today, already answered today, is not counted '
        'today but follows its sequence', () {
      final reviews = load()
        ..addIntroducedCard(
          testCard(
            dueAt: DateTime(2026, 11, 10, 15),
            lastReviewedAt: DateTime(2026, 11, 10, 8),
          ),
          now: now,
        );
      expect(reviews.on(today), 0);
      expect(reviews.on(day(1)), 1);
    });

    test('an acquired or pending card has no review', () {
      final reviews = load()
        ..addIntroducedCard(
          testCard(id: 2, state: CardState.completed),
          now: now,
        )
        ..addIntroducedCard(
          testCard(id: 3, state: CardState.pending, queuePosition: 1),
          now: now,
        );
      expect(reviewDays(reviews), isEmpty);
    });
  });

  group('new cards', () {
    test('are answered the day they arrive, their introduction is not a '
        'review', () {
      final reviews = load(end: acquiredEnd)..addNewCards(day(2), 1);
      expect(reviewDays(reviews), [day(3), day(5), day(9)]);
    });

    test('count once per card', () {
      final reviews = load(end: acquiredEnd)..addNewCards(day(0), 3);
      expect(reviews.on(day(1)), 3);
    });

    test('an interval of less than a day brings the next review back the '
        'same day, where it is not counted', () {
      final reviews = load(preset: intensivePreset, end: acquiredEnd)
        ..addNewCards(today, 1);
      // 1 h, 3 h, 1 d, 3 d, 1 wk.
      expect(reviewDays(reviews), [day(1), day(4), day(11)]);
    });
  });

  test('nothing is counted from the day given on', () {
    final reviews = load(until: day(5))..addNewCards(today, 1);
    expect(reviewDays(reviews), [day(1), day(3)]);
  });
}
