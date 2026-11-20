import '../cards/card_state.dart';

/// New scheduling values of a card after an answer or an introduction.
class CardSchedule {
  const CardSchedule({
    required this.state,
    required this.step,
    required this.dueAt,
  });

  /// Past the last step, in a group whose cards are then acquired.
  static const CardSchedule acquired = CardSchedule(
    state: CardState.completed,
    step: null,
    dueAt: null,
  );

  final CardState state;
  final int? step;
  final DateTime? dueAt;
}
