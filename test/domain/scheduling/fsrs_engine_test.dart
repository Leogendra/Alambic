import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/scheduling/fsrs/fsrs_engine.dart';
import 'package:alambic/domain/scheduling/fsrs/fsrs_memory.dart';
import 'package:alambic/domain/scheduling/fsrs/fsrs_rating.dart';

void main() {
  FsrsMemory first(FsrsRating rating) =>
      FsrsEngine.answer(memory: null, elapsedDays: 0, rating: rating);

  group('a first answer', () {
    test('takes the initial stability and difficulty of its rating', () {
      final good = first(FsrsRating.good);
      expect(good.stability, 3.173);
      expect(good.difficulty, closeTo(5.282, 0.001));
      final again = first(FsrsRating.again);
      expect(again.stability, 0.40255);
      expect(again.difficulty, closeTo(7.195, 0.001));
    });

    test('Correct comes back in 3 days, Again the next day', () {
      expect(FsrsEngine.intervalDays(first(FsrsRating.good).stability, 0.9), 3);
      expect(
        FsrsEngine.intervalDays(first(FsrsRating.again).stability, 0.9),
        1,
      );
    });
  });

  group('a later answer', () {
    final good = first(FsrsRating.good);

    test('recalled on time grows the stability', () {
      final next = FsrsEngine.answer(
        memory: good,
        elapsedDays: 3,
        rating: FsrsRating.good,
      );
      expect(next.stability, closeTo(10.739, 0.001));
      expect(next.difficulty, closeTo(5.273, 0.001));
      expect(FsrsEngine.intervalDays(next.stability, 0.9), 11);
    });

    test('recalled later than planned grows it more', () {
      final onTime = FsrsEngine.answer(
        memory: good,
        elapsedDays: 3,
        rating: FsrsRating.good,
      );
      final late = FsrsEngine.answer(
        memory: good,
        elapsedDays: 10,
        rating: FsrsRating.good,
      );
      expect(late.stability, greaterThan(onTime.stability));
    });

    test('forgotten drops the stability and raises the difficulty', () {
      final known = FsrsEngine.answer(
        memory: good,
        elapsedDays: 3,
        rating: FsrsRating.good,
      );
      final forgotten = FsrsEngine.answer(
        memory: known,
        elapsedDays: 11,
        rating: FsrsRating.again,
      );
      expect(forgotten.stability, closeTo(2.186, 0.001));
      expect(forgotten.difficulty, greaterThan(known.difficulty));
      expect(FsrsEngine.intervalDays(forgotten.stability, 0.9), 2);
    });

    test('the same day barely changes the stability', () {
      final sameDay = FsrsEngine.answer(
        memory: good,
        elapsedDays: 0,
        rating: FsrsRating.good,
      );
      expect(sameDay.stability, closeTo(good.stability * 1.408, 0.01));
    });
  });

  group('the interval', () {
    test('is the stability at a 90 % target retention', () {
      expect(FsrsEngine.retrievability(10, 10), closeTo(0.9, 1e-9));
      expect(FsrsEngine.intervalDays(10.739, 0.9), 11);
    });

    test('shortens when the target retention rises', () {
      expect(FsrsEngine.intervalDays(10.739, 0.8), 26);
      expect(FsrsEngine.intervalDays(10.739, 0.97), 3);
    });

    test('lasts between a day and a hundred years', () {
      expect(FsrsEngine.intervalDays(0.01, 0.97), 1);
      expect(FsrsEngine.intervalDays(1e9, 0.7), FsrsEngine.maximumIntervalDays);
    });
  });

  test('the difficulty stays between 1 and 10', () {
    var memory = first(FsrsRating.again);
    for (var answer = 0; answer < 30; answer++) {
      memory = FsrsEngine.answer(
        memory: memory,
        elapsedDays: 1,
        rating: FsrsRating.again,
      );
    }
    expect(memory.difficulty, lessThanOrEqualTo(10));
    for (var answer = 0; answer < 60; answer++) {
      memory = FsrsEngine.answer(
        memory: memory,
        elapsedDays: 1,
        rating: FsrsRating.easy,
      );
    }
    expect(memory.difficulty, greaterThanOrEqualTo(1));
  });
}
