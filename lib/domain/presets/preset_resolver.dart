/// Cascade of preset choices: the group's choice wins, then the global
/// preset. A group with no choice (`null`) inherits the global preset.
abstract final class PresetResolver {
  static int resolve({
    required int? groupPresetId,
    required int globalPresetId,
  }) => groupPresetId ?? globalPresetId;
}
