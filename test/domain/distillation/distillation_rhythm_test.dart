import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/distillation/distillation.dart';
import 'package:alambic/domain/distillation/distillation_order.dart';
import 'package:alambic/domain/distillation/distillation_rhythm.dart';
import 'package:alambic/domain/distillation/distillation_status.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

void main() {
  const rhythm = DistillationRhythm(SchedulingCalendar());

  Distillation distillation({
    int cardsPerBatch = 3,
    int everyDays = 2,
    DateTime? nextBatchDay,
    int introducedInBatch = 0,
    DateTime? lastAdvancedDay,
  }) => Distillation(
    groupId: 1,
    cardsPerBatch: cardsPerBatch,
    everyDays: everyDays,
    introductionOrder: DistillationOrder.groupOrder,
    avoidCollisions: true,
    status: DistillationStatus.running,
    startedAt: DateTime(2026, 11, 10, 9),
    nextBatchDay: nextBatchDay ?? DateTime(2026, 11, 10),
    introducedInBatch: introducedInBatch,
    lastAdvancedDay: lastAdvancedDay,
  );

  test('a batch is owed from its day on', () {
    final waiting = distillation(nextBatchDay: DateTime(2026, 11, 12));
    expect(rhythm.cardsDue(waiting, DateTime(2026, 11, 11)), 0);
    expect(rhythm.cardsDue(waiting, DateTime(2026, 11, 12)), 3);
    expect(rhythm.cardsDue(waiting, DateTime(2026, 11, 15)), 3);
  });

  test('the rest of a batch held back is owed the next days', () {
    final started = distillation(introducedInBatch: 2);
    expect(rhythm.cardsDue(started, DateTime(2026, 11, 11)), 1);
    final progress = rhythm.afterIntroducing(
      distillation(),
      1,
      DateTime(2026, 11, 10),
    );
    expect(progress.nextBatchDay, DateTime(2026, 11, 10));
    expect(progress.introducedInBatch, 1);
  });

  test('the next batch comes X days after the batch is completed', () {
    final progress = rhythm.afterIntroducing(
      distillation(introducedInBatch: 1),
      2,
      DateTime(2026, 11, 13),
    );
    expect(progress.nextBatchDay, DateTime(2026, 11, 15));
    expect(progress.introducedInBatch, 0);
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

  test('the next introduction is tomorrow once today was processed', () {
    final today = DateTime(2026, 11, 10);
    expect(rhythm.nextIntroductionDay(distillation(), today), today);
    expect(
      rhythm.nextIntroductionDay(distillation(lastAdvancedDay: today), today),
      DateTime(2026, 11, 11),
    );
    expect(
      rhythm.nextIntroductionDay(
        distillation(nextBatchDay: DateTime(2026, 11, 13)),
        today,
      ),
      DateTime(2026, 11, 13),
    );
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

  test('arrivals skip today once its pass ran, and finish a batch first', () {
    final today = DateTime(2026, 11, 10);
    expect(
      rhythm.arrivals(
        distillation(introducedInBatch: 2, lastAdvancedDay: today),
        remaining: 5,
        today: today,
        dayCount: 4,
      ),
      {DateTime(2026, 11, 11): 1, DateTime(2026, 11, 13): 3},
    );
  });
}
