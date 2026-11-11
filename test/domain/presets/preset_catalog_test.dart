import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/domain/cards/flashcard.dart';
import 'package:remanence/domain/presets/preset_catalog.dart';

import '../test_presets.dart';

Flashcard card({int? groupId, int? presetId}) => Flashcard(
  id: 1,
  groupId: groupId,
  frontText: 'Mongolie',
  frontImagePath: null,
  backText: 'Oulan-Bator',
  backImagePath: null,
  presetId: presetId,
  suspended: false,
  createdAt: DateTime(2026, 11, 10),
);

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
    expect(catalog.presetForGroup(null), standardPreset);
  });
}
