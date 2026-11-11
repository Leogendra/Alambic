import '../../domain/scheduling/direction_schedule.dart';

/// Schedules each answer would give, shown under the answer buttons.
/// Both are `null` when answering is a bonus review.
class AnswerPreview {
  const AnswerPreview({required this.correct, required this.again});

  const AnswerPreview.noEffect() : correct = null, again = null;

  final DirectionSchedule? correct;
  final DirectionSchedule? again;

  bool get isBonus => correct == null;
}
