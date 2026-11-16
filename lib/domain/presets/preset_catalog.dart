import '../cards/flashcard.dart';
import 'preset.dart';
import 'preset_resolver.dart';

/// Snapshot of every preset and of the choices made at each level, to resolve
/// the preset of many cards at once (lists, sessions) without querying.
class PresetCatalog {
  const PresetCatalog({
    required this.presetsById,
    required this.globalPresetId,
    required this.groupPresetIds,
  });

  final Map<int, Preset> presetsById;
  final int globalPresetId;

  /// Preset chosen by each group; a missing or `null` entry inherits.
  final Map<int, int?> groupPresetIds;

  Preset get globalPreset => presetsById[globalPresetId]!;

  /// Preset applied to the cards of [groupId] that have no choice of their own.
  Preset presetForGroup(int groupId) =>
      presetsById[PresetResolver.resolve(
        cardPresetId: null,
        groupPresetId: groupPresetIds[groupId],
        globalPresetId: globalPresetId,
      )]!;

  Preset presetForCard(Flashcard card) =>
      presetsById[PresetResolver.resolve(
        cardPresetId: card.presetId,
        groupPresetId: groupPresetIds[card.groupId],
        globalPresetId: globalPresetId,
      )]!;
}
