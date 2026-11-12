import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_direction.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/scheduling/direction_progress.dart';

import '../test_presets.dart';

void main() {
  final adaptive = BuiltInPresets.adaptive.copyWith(id: 4);

  CardDirection direction({int? step, double? stability, double? difficulty}) =>
      CardDirection(
        id: 1,
        cardId: 1,
        sense: DirectionSense.frontToBack,
        state: DirectionState.active,
        step: step,
        stability: stability,
        difficulty: difficulty,
        dueAt: DateTime(2026, 11, 20, 12),
        lastReviewedAt: DateTime(2026, 11, 10, 12),
        notifiedAt: null,
        distillationId: null,
        queuePosition: null,
      );

  final sequenced = direction(step: 3);
  final adapted = direction(stability: 10.739, difficulty: 5.273);

  test('the sequence engine reads the step, clamped to its sequence', () {
    final progress = DirectionProgress.of(sequenced, standardPreset);
    expect(progress, isA<SequenceProgress>());
    progress as SequenceProgress;
    expect(progress.step, 3);
    expect(progress.sequenceLength, 6);
    expect(progress.waitedInterval, const Duration(days: 30));
    final clamped = DirectionProgress.of(sequenced, shortSequence());
    expect((clamped as SequenceProgress).step, 2);
  });

  test('the adaptive engine reads the memory and its interval', () {
    final progress = DirectionProgress.of(adapted, adaptive);
    expect(progress, isA<AdaptiveProgress>());
    expect((progress as AdaptiveProgress).intervalDays, 11);
    expect(progress.waitedInterval, const Duration(days: 11));
    final closer = DirectionProgress.of(
      adapted,
      adaptive.copyWith(targetRetention: 0.97),
    );
    expect((closer as AdaptiveProgress).intervalDays, 3);
  });

  group('a progression left by the other engine', () {
    test('does not count for FSRS', () {
      expect(DirectionProgress.of(sequenced, adaptive), isA<NewProgress>());
    });

    test('does not count for a sequence', () {
      expect(DirectionProgress.of(adapted, standardPreset), isA<NewProgress>());
    });
  });

  test('a direction never answered is new for both engines', () {
    expect(
      DirectionProgress.of(direction(), standardPreset),
      isA<NewProgress>(),
    );
    expect(DirectionProgress.of(direction(), adaptive), isA<NewProgress>());
    expect(
      DirectionProgress.of(direction(), adaptive).waitedInterval,
      Duration.zero,
    );
  });
}
