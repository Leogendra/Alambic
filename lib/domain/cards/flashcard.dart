import 'card_face.dart';
import 'card_side.dart';
import 'card_state.dart';

/// A front / back card of a group, with its single progression: whichever
/// face is asked, the card has one step, one due date and one history. It
/// has no preset of its own: it follows the preset of its group.
class Flashcard {
  const Flashcard({
    required this.id,
    required this.groupId,
    required this.frontText,
    required this.frontImagePath,
    required this.backText,
    required this.backImagePath,
    required this.suspended,
    required this.createdAt,
    required this.state,
    required this.step,
    required this.dueAt,
    required this.lastReviewedAt,
    required this.notifiedAt,
    required this.queuePosition,
  });

  final int id;
  final int groupId;
  final String? frontText;
  final String? frontImagePath;
  final String? backText;
  final String? backImagePath;

  /// A suspended card is never due.
  final bool suspended;
  final DateTime createdAt;
  final CardState state;

  /// Index, in the preset sequence, of the interval currently waited.
  /// `null` while the card has never been answered.
  final int? step;

  /// `null` unless the card is [CardState.active].
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;

  /// When a notification was last shown for the current due date.
  final DateTime? notifiedAt;

  /// Rank in the queue of its group while [CardState.pending]; `null` once
  /// introduced.
  final int? queuePosition;

  CardFace get front => CardFace(text: frontText, imagePath: frontImagePath);

  CardFace get back => CardFace(text: backText, imagePath: backImagePath);

  CardFace face(CardSide side) => switch (side) {
    CardSide.front => front,
    CardSide.back => back,
  };

  /// Face shown as the question when [asked] is drawn.
  CardFace promptFor(CardSide asked) => face(asked);

  /// Face expected as the answer when [asked] is drawn.
  CardFace answerFor(CardSide asked) => face(asked.opposite);

  bool get isPending => state == CardState.pending;

  bool get isScheduled => state == CardState.active && dueAt != null;
}
