import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/distillation/distillation.dart';
import 'package:alambic/domain/distillation/distillation_rhythm.dart';
import 'package:alambic/domain/distillation/distillation_status.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

void main() {
  const rhythm = DistillationRhythm(SchedulingCalendar());

  Distillation distillation({
    int cardsPerBatch = 3,
    int everyDays = 2,
    bool prioritizeReviews = true,
    DateTime? lastBatchDay,
    DateTime? lastAdvancedDay,
  }) => Distillation(
    groupId: 1,
    cardsPerBatch: cardsPerBatch,
    everyDays: everyDays,
    prioritizeReviews: prioritizeReviews,
    status: DistillationStatus.running,
    startedAt: DateTime(2026, 11, 10, 9),
    lastBatchDay: lastBatchDay,
    lastAdvancedDay: lastAdvancedDay,
  );

  test('the first batch is owed right away', () {
    expect(rhythm.batchDue(distillation(), DateTime(2026, 11, 10)), isTrue);
  });

  test('a batch is owed X days after the last one, and later on', () {
    final batched = distillation(lastBatchDay: DateTime(2026, 11, 10));
    expect(rhythm.batchDue(batched, DateTime(2026, 11, 11)), isFalse);
    expect(rhythm.batchDue(batched, DateTime(2026, 11, 12)), isTrue);
    expect(rhythm.batchDue(batched, DateTime(2026, 11, 17)), isTrue);
  });

  group('new cards of a batch', () {
    test('with "Prioritize reviews", each due card takes a place', () {
      expect(rhythm.newCards(distillation(), dueCards: 0), 3);
      expect(rhythm.newCards(distillation(), dueCards: 1), 2);
      expect(rhythm.newCards(distillation(), dueCards: 5), 0);
    });

    test('without it, the N cards whatever is due', () {
      final always = distillation(prioritizeReviews: false);
      expect(rhythm.newCards(always, dueCards: 5), 3);
    });
  });

  test('the last arrival counts whole batches', () {
    expect(
      rhythm.lastArrival(
        remaining: 7,
        cardsPerBatch: 3,
        everyDays: 2,
        firstDay: DateTime(2026, 11, 10),
      ),
      DateTime(2026, 11, 14),
    );
    expect(
      rhythm.lastArrival(
        remaining: 0,
        cardsPerBatch: 3,
        everyDays: 2,
        firstDay: DateTime(2026, 11, 10),
      ),
      isNull,
    );
  });

  group('next introduction', () {
    final today = DateTime(2026, 11, 10);

    test('today until its pass ran, tomorrow afterwards', () {
      expect(rhythm.nextIntroductionDay(distillation(), today), today);
      expect(
        rhythm.nextIntroductionDay(distillation(lastAdvancedDay: today), today),
        DateTime(2026, 11, 11),
      );
    });

    test('X days after the last batch', () {
      expect(
        rhythm.nextIntroductionDay(
          distillation(lastBatchDay: DateTime(2026, 11, 9)),
          today,
        ),
        DateTime(2026, 11, 11),
      );
    });

    test('never before today after a long gap', () {
      expect(
        rhythm.nextIntroductionDay(
          distillation(lastBatchDay: DateTime(2026, 11, 1)),
          today,
        ),
        today,
      );
    });
  });

  test('arrivals follow the batches until the queue is empty', () {
    expect(
      rhythm.arrivals(
        distillation(),
        remaining: 7,
        today: DateTime(2026, 11, 10),
        dayCount: 7,
      ),
      {
        DateTime(2026, 11, 10): 3,
        DateTime(2026, 11, 12): 3,
        DateTime(2026, 11, 14): 1,
      },
    );
  });

  test('arrivals skip today once its pass ran', () {
    final today = DateTime(2026, 11, 10);
    expect(
      rhythm.arrivals(
        distillation(lastBatchDay: today, lastAdvancedDay: today),
        remaining: 5,
        today: today,
        dayCount: 5,
      ),
      {DateTime(2026, 11, 12): 3, DateTime(2026, 11, 14): 2},
    );
  });
}
