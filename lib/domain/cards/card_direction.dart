import '../scheduling/fsrs/fsrs_memory.dart';
import 'direction_sense.dart';
import 'direction_state.dart';

/// Scheduling state of one direction of a card.
class CardDirection {
  const CardDirection({
    required this.id,
    required this.cardId,
    required this.sense,
    required this.state,
    required this.step,
    required this.stability,
    required this.difficulty,
    required this.dueAt,
    required this.lastReviewedAt,
    required this.notifiedAt,
    required this.distillationId,
    required this.queuePosition,
  });

  final int id;
  final int cardId;
  final DirectionSense sense;
  final DirectionState state;

  /// Index, in the preset sequence, of the interval currently waited.
  /// `null` while the direction has never been answered.
  final int? step;

  /// FSRS memory of a direction followed by the adaptive engine; `null`
  /// otherwise, and while it has never been answered.
  final double? stability;
  final double? difficulty;

  /// `null` unless the direction is [DirectionState.active].
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;

  /// When a notification was last shown for the current due date.
  final DateTime? notifiedAt;

  /// Distillation whose queue holds the direction, or which introduced it
  /// while it runs; `null` otherwise.
  final int? distillationId;

  /// Rank in the queue of [distillationId] while pending. `null` for a
  /// reverse direction of the global distillation still waiting for its
  /// front to be introduced, and once introduced.
  final int? queuePosition;

  FsrsMemory? get memory => switch ((stability, difficulty)) {
    (final double stability, final double difficulty) => FsrsMemory(
      stability: stability,
      difficulty: difficulty,
    ),
    _ => null,
  };

  bool get isScheduled => state == DirectionState.active && dueAt != null;

  /// Waits to be started by hand: never started, or left pending by a
  /// distillation that was stopped.
  bool get isStartable =>
      state == DirectionState.unstarted ||
      (state == DirectionState.pending && distillationId == null);
}
