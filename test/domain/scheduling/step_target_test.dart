import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/groups/sequence_end.dart';
import 'package:alambic/domain/scheduling/sequence_step.dart';
import 'package:alambic/domain/scheduling/step_target.dart';

import '../test_cards.dart';
import '../test_groups.dart';
import '../test_presets.dart';

void main() {
  test('the queue first, then each step, then the end of the sequence', () {
    expect(StepTarget.allOf(standardPreset), [
      const PendingTarget(),
      for (var step = 0; step < standardPreset.sequenceLength; step++)
        StepIndexTarget(step),
      const SequenceEndTarget(),
    ]);
  });

  test('a card stands at its target; a new introduced card at none', () {
    StepTarget? of(CardState state, {int? step}) =>
        StepTarget.of(testCard(state: state, step: step), standardPreset);
    expect(of(CardState.pending), const PendingTarget());
    expect(of(CardState.active, step: 2), const StepIndexTarget(2));
    expect(
      of(CardState.active, step: 40),
      StepIndexTarget(standardPreset.lastStep),
      reason: 'a step kept from a longer sequence counts as the last one',
    );
    expect(of(CardState.completed), const SequenceEndTarget());
    expect(of(CardState.active), isNull);
  });

  test('the end of the sequence follows the group', () {
    expect(
      const SequenceEndTarget().reached(standardPreset, SequenceEnd.standard),
      isA<RemanenceReached>(),
    );
    expect(
      const SequenceEndTarget().reached(standardPreset, acquiredEnd),
      isA<AcquiredReached>(),
    );
  });
}
