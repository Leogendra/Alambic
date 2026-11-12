import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/direction_progress.dart';
import 'review_notification_key.dart';

/// Content of a notification asking a card: the asked face and where the
/// direction stands. Formatted into text by the platform implementation.
class ReviewPrompt {
  const ReviewPrompt({
    required this.key,
    required this.prompt,
    required this.image,
    required this.groupName,
    required this.progress,
    required this.isReverse,
    required this.typedAnswer,
    this.chainRemaining,
  });

  /// The notification of [direction] of [card], following [preset].
  factory ReviewPrompt.of({
    required ReviewNotificationKey key,
    required Flashcard card,
    required CardDirection direction,
    required Preset preset,
    required String? groupName,
    int? chainRemaining,
  }) => ReviewPrompt(
    key: key,
    prompt: card.promptFor(direction.sense).text ?? '',
    image: card.promptFor(direction.sense).imagePath,
    groupName: groupName,
    progress: DirectionProgress.of(direction, preset),
    isReverse: direction.sense == DirectionSense.backToFront,
    // Without text on the answer face, there is nothing to compare with.
    typedAnswer: preset.typedAnswer && card.answerFor(direction.sense).hasText,
    chainRemaining: chainRemaining,
  );

  final ReviewNotificationKey key;

  /// Text of the asked face; empty for a face that is an image alone.
  final String prompt;

  /// Image of the asked face, by its name in the image store.
  final String? image;

  /// `null` for a card outside any group.
  final String? groupName;

  /// Where the direction stands in the engine of its preset.
  final DirectionProgress progress;

  /// Back → front direction.
  final bool isReverse;

  /// Asks for a typed answer ("Answer" and "Again") instead of "Correct" and
  /// "Again".
  final bool typedAnswer;

  /// Cards left in the grouped reminder, this one included, when the cards
  /// are chained in the notification.
  final int? chainRemaining;
}
