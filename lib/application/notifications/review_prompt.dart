import '../../domain/cards/card_side.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/groups/card_group.dart';
import 'review_notification_key.dart';

/// Content of a notification asking a card: the asked face and its group,
/// and the answer face once revealed. Formatted into text by the platform
/// implementation.
class ReviewPrompt {
  const ReviewPrompt({
    required this.key,
    required this.askedSide,
    required this.prompt,
    required this.image,
    required this.answer,
    required this.answerImage,
    required this.groupName,
    required this.typedAnswer,
    this.chainRemaining,
    this.isRevealed = false,
    this.alert = true,
  });

  /// The notification of [card] asking its [askedSide] face, following
  /// the options of its [group].
  factory ReviewPrompt.of({
    required ReviewNotificationKey key,
    required Flashcard card,
    required CardSide askedSide,
    required CardGroup group,
    int? chainRemaining,
    bool isRevealed = false,
    bool alert = true,
  }) => ReviewPrompt(
    key: key,
    askedSide: askedSide,
    prompt: card.promptFor(askedSide).text ?? '',
    image: card.promptFor(askedSide).imagePath,
    answer: card.answerFor(askedSide).text ?? '',
    answerImage: card.answerFor(askedSide).imagePath,
    groupName: group.name,
    typedAnswer: group.asksTypedAnswer(card, askedSide),
    chainRemaining: chainRemaining,
    isRevealed: isRevealed,
    alert: alert,
  );

  final ReviewNotificationKey key;

  /// Face drawn for this display; the answer is the other one.
  final CardSide askedSide;

  /// Text of the asked face; empty for a face that is an image alone.
  final String prompt;

  /// Image of the asked face, by its name in the image store.
  final String? image;

  /// Text of the answer face, shown once revealed; empty for an image alone.
  final String answer;

  /// Image of the answer face, by its name in the image store.
  final String? answerImage;
  final String groupName;

  /// Asks for a typed answer ("Again", "Answer" and "Reveal") instead of
  /// "Again", "Correct" and "Reveal".
  final bool typedAnswer;

  /// Cards left in the grouped reminder, this one included, when the cards
  /// are chained in the notification.
  final int? chainRemaining;

  /// Shows the answer face, with "Again", "Correct" and "Hide"; nothing is
  /// recorded until "Again" or "Correct" is pressed.
  final bool isRevealed;

  /// Rings; `false` when the notification only changes in place, its answer
  /// shown or hidden.
  final bool alert;
}
