import 'draft_image.dart';

/// Content of the card editor, validated before being stored.
class CardDraft {
  const CardDraft({
    required this.frontText,
    required this.backText,
    required this.groupId,
    this.frontImage,
    this.backImage,
  });

  final String frontText;
  final String backText;

  /// Image of each face, one at most; `null` for none.
  final DraftImage? frontImage;
  final DraftImage? backImage;

  /// Every card belongs to a group.
  final int groupId;

  /// Each face needs content: text, an image, or both.
  bool get isComplete =>
      (frontText.trim().isNotEmpty || frontImage != null) &&
      (backText.trim().isNotEmpty || backImage != null);
}
