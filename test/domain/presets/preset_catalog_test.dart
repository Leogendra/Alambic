import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/presets/preset_catalog.dart';

import '../test_cards.dart';
import '../test_presets.dart';

Flashcard card({int groupId = 12, int? presetId}) =>
    testCard(groupId: groupId, presetId: presetId);

void main() {
  final catalog = PresetCatalog(
    presetsById: {
      standardPreset.id: standardPreset,
      intensivePreset.id: intensivePreset,
    },
    globalPresetId: standardPreset.id,
    groupPresetIds: {10: intensivePreset.id, 11: null},
  );

  test('resolves a card through its group, then the global preset', () {
    expect(catalog.presetForCard(card(groupId: 10)), intensivePreset);
    expect(catalog.presetForCard(card(groupId: 11)), standardPreset);
    expect(catalog.presetForCard(card()), standardPreset);
  });

  test('the card choice wins over its group', () {
    expect(
      catalog.presetForCard(card(groupId: 10, presetId: standardPreset.id)),
      standardPreset,
    );
  });

  test('gives the preset inherited by the cards of a group', () {
    expect(catalog.presetForGroup(10), intensivePreset);
    expect(catalog.presetForGroup(12), standardPreset);
  });
}
