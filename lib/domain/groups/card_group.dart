/// A flat list of cards sharing a preset.
class CardGroup {
  const CardGroup({
    required this.id,
    required this.name,
    required this.presetId,
    required this.createdAt,
  });

  final int id;
  final String name;

  /// `null` inherits the global preset.
  final int? presetId;
  final DateTime createdAt;
}
