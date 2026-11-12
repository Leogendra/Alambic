/// A flat list of cards sharing a preset.
class CardGroup {
  const CardGroup({
    required this.id,
    required this.name,
    required this.presetId,
    required this.createdAt,
    this.pausedAt,
  });

  final int id;
  final String name;

  /// `null` inherits the global preset.
  final int? presetId;
  final DateTime createdAt;

  /// Start of the pause of the group, `null` when it is not paused.
  final DateTime? pausedAt;

  bool get isPaused => pausedAt != null;
}
