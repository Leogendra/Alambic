import '../cards/card_side.dart';
import '../cards/flashcard.dart';
import 'after_last_step.dart';
import 'remanence_interval.dart';
import 'sequence_end.dart';

/// A flat list of cards sharing a preset. Every card belongs to one.
class CardGroup {
  const CardGroup({
    required this.id,
    required this.name,
    required this.presetId,
    required this.createdAt,
    required this.reverseEnabled,
    required this.afterLastStep,
    required this.remanenceInterval,
    required this.typedAnswer,
  });

  final int id;
  final String name;

  /// The preset its cards follow.
  final int presetId;
  final DateTime createdAt;

  /// With the back enabled, each display of a card draws the asked face:
  /// the front or the back, one chance in two. The draw is visual only.
  final bool reverseEnabled;

  /// Read at each answer: changing it moves no due date.
  final AfterLastStep afterLastStep;

  /// Read at each answer: changing it moves no due date.
  final RemanenceInterval remanenceInterval;

  /// The cards whose answer face has text are answered by typing it, in a
  /// notification as in a session.
  final bool typedAnswer;

  /// Whether [card], asking [askedSide], is answered by typing: with the
  /// typed answer option, unless its answer face has no text to compare
  /// with.
  bool asksTypedAnswer(Flashcard card, CardSide askedSide) =>
      typedAnswer && card.answerFor(askedSide).hasText;

  SequenceEnd get sequenceEnd => SequenceEnd(
    afterLastStep: afterLastStep,
    remanenceInterval: remanenceInterval,
  );
}
