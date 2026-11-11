/// Content of the card editor, validated before being stored.
class CardDraft {
  const CardDraft({
    required this.frontText,
    required this.backText,
    required this.groupId,
    required this.presetId,
    required this.alsoReverse,
  });

  final String frontText;
  final String backText;
  final int? groupId;

  /// Preset chosen on the card; `null` inherits from the group.
  final int? presetId;

  /// Studies the back → front direction too.
  final bool alsoReverse;

  /// Each face needs content; until images exist, that means text.
  bool get isComplete =>
      frontText.trim().isNotEmpty && backText.trim().isNotEmpty;
}
