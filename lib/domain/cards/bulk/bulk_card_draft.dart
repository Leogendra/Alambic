/// A card read from one line of a bulk paste.
class BulkCardDraft {
  const BulkCardDraft({
    required this.lineNumber,
    required this.front,
    required this.back,
  });

  final int lineNumber;
  final String front;
  final String back;
}
