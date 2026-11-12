import '../cards/direction_state.dart';
import 'fsrs/fsrs_memory.dart';

/// New scheduling values of a direction after an answer or an activation.
class DirectionSchedule {
  const DirectionSchedule({
    required this.state,
    required this.step,
    required this.dueAt,
    this.memory,
  });

  /// A direction that is not studied: no step, no due date.
  static const DirectionSchedule inactive = DirectionSchedule(
    state: DirectionState.inactive,
    step: null,
    dueAt: null,
  );

  /// A direction waiting to be started: no step, no due date.
  static const DirectionSchedule unstarted = DirectionSchedule(
    state: DirectionState.unstarted,
    step: null,
    dueAt: null,
  );

  final DirectionState state;
  final int? step;
  final DateTime? dueAt;

  /// FSRS memory, for a direction followed by the adaptive engine.
  final FsrsMemory? memory;
}
