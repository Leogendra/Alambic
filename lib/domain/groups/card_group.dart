/// A flat list of cards sharing a preset. Every card belongs to one.
class CardGroup {
  const CardGroup({
    required this.id,
    required this.name,
    required this.presetId,
    required this.createdAt,
    required this.reverseEnabled,
    this.pausedAt,
  });

  final int id;
  final String name;

  /// `null` inherits the global preset.
  final int? presetId;
  final DateTime createdAt;

  /// With the back enabled, each display of a card draws the asked face:
  /// the front or the back, one chance in two. The draw is visual only.
  final bool reverseEnabled;

  /// Start of the pause of the group, `null` when it is not paused.
  final DateTime? pausedAt;

  bool get isPaused => pausedAt != null;
}
