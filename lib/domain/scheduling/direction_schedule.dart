import '../cards/direction_state.dart';

/// New scheduling values of a direction after an answer or an activation.
class DirectionSchedule {
  const DirectionSchedule({
    required this.state,
    required this.step,
    required this.dueAt,
  });

  /// A direction that is not studied: no step, no due date.
  static const DirectionSchedule inactive = DirectionSchedule(
    state: DirectionState.inactive,
    step: null,
    dueAt: null,
  );

  final DirectionState state;
  final int? step;
  final DateTime? dueAt;
}
