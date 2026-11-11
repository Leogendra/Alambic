/// Cascade of preset choices: the card's own choice wins, then its group's,
/// then the global preset. A `null` level inherits from the next one.
abstract final class PresetResolver {
  static int resolve({
    required int? cardPresetId,
    required int? groupPresetId,
    required int globalPresetId,
  }) => cardPresetId ?? groupPresetId ?? globalPresetId;
}
