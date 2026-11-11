import 'card_face.dart';
import 'direction_sense.dart';

/// A front / back card. Each of its two directions is scheduled separately.
class Flashcard {
  const Flashcard({
    required this.id,
    required this.groupId,
    required this.frontText,
    required this.frontImagePath,
    required this.backText,
    required this.backImagePath,
    required this.presetId,
    required this.suspended,
    required this.createdAt,
  });

  final int id;

  /// `null` for cards outside any group ("Sans groupe").
  final int? groupId;
  final String? frontText;
  final String? frontImagePath;
  final String? backText;
  final String? backImagePath;

  /// Preset chosen on the card itself; `null` inherits from the group.
  final int? presetId;

  /// A suspended card is never due, in both directions.
  final bool suspended;
  final DateTime createdAt;

  CardFace get front => CardFace(text: frontText, imagePath: frontImagePath);

  CardFace get back => CardFace(text: backText, imagePath: backImagePath);

  /// Face shown as the question for [sense].
  CardFace promptFor(DirectionSense sense) => switch (sense) {
    DirectionSense.frontToBack => front,
    DirectionSense.backToFront => back,
  };

  /// Face expected as the answer for [sense].
  CardFace answerFor(DirectionSense sense) => promptFor(sense.opposite);
}
