import '../cards/card_state.dart';
import 'fsrs/fsrs_memory.dart';

/// New scheduling values of a card after an answer or an introduction.
class CardSchedule {
  const CardSchedule({
    required this.state,
    required this.step,
    required this.dueAt,
    this.memory,
  });

  final CardState state;
  final int? step;
  final DateTime? dueAt;

  /// FSRS memory, for a card followed by the adaptive engine.
  final FsrsMemory? memory;
}
