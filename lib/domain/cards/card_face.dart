/// One face of a flashcard: plain text and/or an image, at least one of them.
class CardFace {
  const CardFace({this.text, this.imagePath});

  final String? text;
  final String? imagePath;

  bool get hasText => text != null && text!.trim().isNotEmpty;

  bool get hasImage => imagePath != null;

  bool get isEmpty => !hasText && !hasImage;
}
