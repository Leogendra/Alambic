import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/home/home_timeline.dart';
import 'package:alambic/application/home/timeline_card.dart';
import 'package:alambic/application/home/timeline_planner.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/distillation/distillation.dart';
import 'package:alambic/domain/distillation/distillation_rhythm.dart';
import 'package:alambic/domain/presets/preset_catalog.dart';
import 'package:alambic/domain/scheduling/due_policy.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../domain/test_cards.dart';
import '../domain/test_presets.dart';

void main() {
  const planner = TimelinePlanner(
    calendar: SchedulingCalendar(),
    duePolicy: DuePolicy(SchedulingCalendar()),
    rhythm: DistillationRhythm(SchedulingCalendar()),
  );
  final catalog = PresetCatalog(
    presetsById: {standardPreset.id: standardPreset},
    globalPresetId: standardPreset.id,
    groupPresetIds: const {},
    groupSequenceEnds: const {},
  );
  final now = DateTime(2026, 11, 10, 9);
  final lastWeek = DateTime(2026, 11, 3, 12);

  Distillation distillation({
    bool prioritizeReviews = false,
    DateTime? pausedAt,
    DateTime? lastBatchDay,
    DateTime? lastAdvancedDay,
  }) => Distillation(
    groupId: 1,
    cardsPerBatch: 1,
    prioritizeReviews: prioritizeReviews,
    pausedAt: pausedAt,
    startedAt: DateTime(2026, 11, 1),
    lastBatchDay: lastBatchDay,
    lastAdvancedDay: lastAdvancedDay,
  );

  Flashcard answered(int id, DateTime dueAt) =>
      testCard(id: id, dueAt: dueAt, lastReviewedAt: lastWeek);

  Flashcard pending(int id) =>
      testCard(id: id, state: CardState.pending, queuePosition: id);

  HomeTimeline build(
    List<Flashcard> cards, {
    List<Distillation> distillations = const [],
    bool globallyPaused = false,
  }) => planner.build(
    cards: cards,
    distillations: distillations,
    catalog: catalog,
    globallyPaused: globallyPaused,
    now: now,
  );

  test('today shows the late cards first, then the cards of the day', () {
    final timeline = build([
      answered(1, DateTime(2026, 11, 10, 12)),
      answered(2, DateTime(2026, 11, 8, 12)),
      answered(3, DateTime(2026, 11, 12, 12)),
    ]);
    final today = timeline.today;
    expect(today.isToday, isTrue);
    expect(today.cards.map((entry) => entry.card.id), [2, 1]);
    expect(today.cards.map((entry) => entry.isLate), [true, false]);
    expect(timeline.days[1].day, DateTime(2026, 11, 12));
    expect(timeline.days[1].cards.single.card.id, 3);
  });

  test('today is kept when empty, other empty days and later ones are '
      'left out', () {
    final timeline = build([
      answered(1, DateTime(2026, 11, 13, 12)),
      answered(2, DateTime(2026, 11, 30, 12)),
    ]);
    expect(timeline.days.map((day) => day.day), [
      DateTime(2026, 11, 10),
      DateTime(2026, 11, 13),
    ]);
    expect(timeline.today.isEmpty, isTrue);
  });

  test('pending cards are not reminders', () {
    final timeline = build([pending(2)]);
    expect(timeline.days.single.isEmpty, isTrue);
  });

  test('new cards are counted per group, never named', () {
    final timeline = build(
      [
        testCard(id: 1, dueAt: DateTime(2026, 11, 10, 12)),
        testCard(id: 2, dueAt: DateTime(2026, 11, 9, 12)),
        pending(3),
        pending(4),
      ],
      distillations: [
        distillation(
          lastBatchDay: DateTime(2026, 11, 10),
          lastAdvancedDay: DateTime(2026, 11, 10),
        ),
      ],
    );
    expect(timeline.today.cards, isEmpty);
    expect(timeline.today.arrivals.single.groupId, 1);
    expect(timeline.today.arrivals.single.count, 2);
    expect(
      timeline.days.skip(1).map((day) => (day.day, day.arrivals.single.count)),
      [(DateTime(2026, 11, 11), 1), (DateTime(2026, 11, 12), 1)],
    );
  });

  test('today owes its batch until the daily pass ran', () {
    final timeline = build([pending(1)], distillations: [distillation()]);
    expect(timeline.today.arrivals.single.count, 1);
  });

  test('a paused distillation, or the global pause, announces nothing', () {
    expect(
      build(
        [pending(1)],
        distillations: [distillation(pausedAt: DateTime(2026, 11, 9))],
      ).days.single.isEmpty,
      isTrue,
    );
    expect(
      build(
        [pending(1)],
        distillations: [distillation()],
        globallyPaused: true,
      ).days.single.isEmpty,
      isTrue,
    );
  });

  test('the reviews of the group take the places of new cards, those of the '
      'cards to come included', () {
    final timeline = build(
      [answered(1, DateTime(2026, 11, 12, 12)), pending(2), pending(3)],
      distillations: [
        distillation(
          prioritizeReviews: true,
          lastBatchDay: DateTime(2026, 11, 10),
          lastAdvancedDay: DateTime(2026, 11, 10),
        ),
      ],
    );
    expect(
      timeline.days.map(
        (day) => (day.day, day.cards.length, day.arrivals.firstOrNull?.count),
      ),
      [
        (DateTime(2026, 11, 10), 0, null),
        (DateTime(2026, 11, 11), 0, 1),
        (DateTime(2026, 11, 12), 1, null),
        (DateTime(2026, 11, 16), 0, 1),
      ],
    );
  });

  test('each reminder gives the time left: hours today, rounded up, days '
      'afterwards, nothing once its moment has passed', () {
    final timeline = build([
      answered(1, DateTime(2026, 11, 10, 12)),
      answered(2, DateTime(2026, 11, 10, 9, 20)),
      answered(3, DateTime(2026, 11, 10, 8)),
      answered(4, DateTime(2026, 11, 8, 12)),
      answered(5, DateTime(2026, 11, 12, 12)),
    ]);
    expect(
      {for (final entry in timeline.today.cards) entry.card.id: entry.delay},
      {
        4: null,
        3: null,
        2: const TimelineDelay.hours(1),
        1: const TimelineDelay.hours(3),
      },
    );
    expect(timeline.days[1].cards.single.delay, const TimelineDelay.days(2));
  });

  test('the coming month and year count the reminders and the new cards '
      'expected', () {
    final timeline = build(
      [
        answered(1, DateTime(2026, 11, 16, 12)),
        answered(2, DateTime(2026, 11, 17, 12)),
        answered(3, DateTime(2026, 12, 9, 12)),
        answered(4, DateTime(2026, 12, 10, 12)),
        answered(5, DateTime(2027, 11, 10, 12)),
        for (var id = 11; id <= 30; id++) pending(id),
      ],
      distillations: [
        distillation(
          lastBatchDay: DateTime(2026, 11, 10),
          lastAdvancedDay: DateTime(2026, 11, 10),
        ),
      ],
    );
    expect(timeline.days.last.day, DateTime(2026, 11, 16));
    expect(timeline.comingMonth, 2 + 14);
    expect(timeline.comingYear, 1);
  });

  test('a card is learned once notified: answered, or introduced with its '
      'first moment passed', () {
    final timeline = build([
      answered(1, DateTime(2026, 11, 20, 12)),
      testCard(id: 2, dueAt: DateTime(2026, 11, 10, 8)),
      testCard(id: 3, dueAt: DateTime(2026, 11, 11, 12)),
      pending(4),
    ]);
    expect(timeline.learnedCount, 2);
  });
}
