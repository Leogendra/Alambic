import '../cards/card_state.dart';

/// New scheduling values of a card after an answer or an introduction.
class CardSchedule {
  const CardSchedule({
    required this.state,
    required this.step,
    required this.dueAt,
  });

  final CardState state;
  final int? step;
  final DateTime? dueAt;
}
