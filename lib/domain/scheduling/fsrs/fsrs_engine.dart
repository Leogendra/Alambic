import 'dart:math';

import 'fsrs_memory.dart';
import 'fsrs_rating.dart';

/// Port of FSRS-5 (Free Spaced Repetition Scheduler), with its default
/// parameters.
///
/// FSRS models the memory of a card with a stability (days until the recall
/// probability falls to 90 %) and a difficulty. Each answer updates both,
/// depending on how likely the card was to be recalled when it was answered;
/// the next interval is the time the recall probability takes to fall to the
/// target retention.
abstract final class FsrsEngine {
  /// Default parameters of FSRS-5, fitted on a large set of reviews.
  static const List<double> defaultWeights = [
    0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046, //
    1.54575, 0.1192, 1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315, //
    2.9898, 0.51655, 0.6621,
  ];

  /// Longest interval, in days (100 years).
  static const int maximumIntervalDays = 36500;

  static const double _decay = -0.5;

  /// Makes the retrievability 90 % when the elapsed time equals the stability.
  static const double _factor = 19 / 81;

  static const double _minimumStability = 0.01;

  /// Memory after an answer rated [rating], given [elapsedDays] since the
  /// previous answer. A direction without [memory] is answered for the first
  /// time.
  static FsrsMemory answer({
    required FsrsMemory? memory,
    required int elapsedDays,
    required FsrsRating rating,
    List<double> weights = defaultWeights,
  }) {
    if (memory == null) {
      return FsrsMemory(
        stability: max(weights[rating.grade - 1], 0.1),
        difficulty: _clampDifficulty(_initialDifficulty(rating, weights)),
      );
    }
    final difficulty = _nextDifficulty(memory.difficulty, rating, weights);
    final double stability;
    if (elapsedDays <= 0) {
      stability = _shortTermStability(memory.stability, rating, weights);
    } else {
      final recall = retrievability(elapsedDays.toDouble(), memory.stability);
      stability = rating == FsrsRating.again
          ? _forgetStability(memory, recall, weights)
          : _recallStability(memory, recall, rating, weights);
    }
    return FsrsMemory(
      stability: max(stability, _minimumStability),
      difficulty: difficulty,
    );
  }

  /// Probability of recalling a card of [stability] after [elapsedDays].
  static double retrievability(double elapsedDays, double stability) =>
      pow(1 + _factor * elapsedDays / stability, _decay).toDouble();

  /// Days until the recall probability of a card of [stability] falls to
  /// [targetRetention]; at least one day.
  static int intervalDays(double stability, double targetRetention) {
    final days = stability / _factor * (pow(targetRetention, 1 / _decay) - 1);
    return days.round().clamp(1, maximumIntervalDays);
  }

  static double _initialDifficulty(FsrsRating rating, List<double> weights) =>
      weights[4] - exp(weights[5] * (rating.grade - 1)) + 1;

  /// Moves the difficulty by the rating, less and less near 10, then pulls
  /// it slightly back towards the difficulty of an "easy" first answer.
  static double _nextDifficulty(
    double difficulty,
    FsrsRating rating,
    List<double> weights,
  ) {
    final delta = -weights[6] * (rating.grade - 3);
    final damped = difficulty + delta * (10 - difficulty) / 9;
    final reverted =
        weights[7] * _initialDifficulty(FsrsRating.easy, weights) +
        (1 - weights[7]) * damped;
    return _clampDifficulty(reverted);
  }

  static double _recallStability(
    FsrsMemory memory,
    double recall,
    FsrsRating rating,
    List<double> weights,
  ) {
    final hardPenalty = rating == FsrsRating.hard ? weights[15] : 1.0;
    final easyBonus = rating == FsrsRating.easy ? weights[16] : 1.0;
    return memory.stability *
        (1 +
            exp(weights[8]) *
                (11 - memory.difficulty) *
                pow(memory.stability, -weights[9]) *
                (exp((1 - recall) * weights[10]) - 1) *
                hardPenalty *
                easyBonus);
  }

  static double _forgetStability(
    FsrsMemory memory,
    double recall,
    List<double> weights,
  ) {
    final longTerm =
        weights[11] *
        pow(memory.difficulty, -weights[12]) *
        (pow(memory.stability + 1, weights[13]) - 1) *
        exp((1 - recall) * weights[14]);
    final shortTerm = memory.stability / exp(weights[17] * weights[18]);
    return min(longTerm, shortTerm);
  }

  /// Stability after a second answer the same day.
  static double _shortTermStability(
    double stability,
    FsrsRating rating,
    List<double> weights,
  ) => stability * exp(weights[17] * (rating.grade - 3 + weights[18]));

  static double _clampDifficulty(double difficulty) =>
      difficulty.clamp(1, 10).toDouble();
}
