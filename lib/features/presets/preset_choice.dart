/// Result of the preset picker: a preset, or inheriting from the next level.
class PresetChoice {
  const PresetChoice.preset(int this.presetId);

  const PresetChoice.inherit() : presetId = null;

  /// `null` when the level inherits.
  final int? presetId;
}
