import '../../domain/cards/card_side.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/card_progress.dart';
import 'review_notification_key.dart';

/// Content of a notification asking a card: the asked face and where the
/// card stands. Formatted into text by the platform implementation.
class ReviewPrompt {
  const ReviewPrompt({
    required this.key,
    required this.askedSide,
    required this.prompt,
    required this.image,
    required this.groupName,
    required this.progress,
    required this.typedAnswer,
    this.chainRemaining,
  });

  /// The notification of [card] asking its [askedSide] face, following
  /// [preset].
  factory ReviewPrompt.of({
    required ReviewNotificationKey key,
    required Flashcard card,
    required CardSide askedSide,
    required Preset preset,
    required String groupName,
    int? chainRemaining,
  }) => ReviewPrompt(
    key: key,
    askedSide: askedSide,
    prompt: card.promptFor(askedSide).text ?? '',
    image: card.promptFor(askedSide).imagePath,
    groupName: groupName,
    progress: CardProgress.of(card, preset),
    // Without text on the answer face, there is nothing to compare with.
    typedAnswer: preset.typedAnswer && card.answerFor(askedSide).hasText,
    chainRemaining: chainRemaining,
  );

  final ReviewNotificationKey key;

  /// Face drawn for this display; the answer is the other one.
  final CardSide askedSide;

  /// Text of the asked face; empty for a face that is an image alone.
  final String prompt;

  /// Image of the asked face, by its name in the image store.
  final String? image;
  final String groupName;

  /// Where the card stands in the engine of its preset.
  final CardProgress progress;

  /// Asks for a typed answer ("Answer" and "Again") instead of "Correct" and
  /// "Again".
  final bool typedAnswer;

  /// Cards left in the grouped reminder, this one included, when the cards
  /// are chained in the notification.
  final int? chainRemaining;
}
