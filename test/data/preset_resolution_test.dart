import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';

void main() {
  late AlambicDatabase database;
  late PresetRepository presets;
  late GroupRepository groups;
  late CardRepository cards;
  late int standardId;
  late int intensiveId;
  late int groupId;

  setUp(() async {
    database = AlambicDatabase(NativeDatabase.memory());
    presets = PresetRepository(database);
    groups = GroupRepository(database);
    cards = CardRepository(database);
    final catalog = await presets.loadCatalog();
    standardId = catalog.presetsById.values
        .firstWhere((preset) => preset.builtInKey == BuiltInPresetKey.standard)
        .id;
    intensiveId = catalog.presetsById.values
        .firstWhere((preset) => preset.builtInKey == BuiltInPresetKey.intensive)
        .id;
    groupId = await groups.create('Capitales', DateTime(2026, 11, 10));
  });

  tearDown(() => database.close());

  Future<int> createCard({int? presetId}) => cards.insertCard(
    groupId: groupId,
    frontText: 'Mongolie',
    frontImagePath: null,
    backText: 'Oulan-Bator',
    backImagePath: null,
    presetId: presetId,
    createdAt: DateTime(2026, 11, 10),
    queuePosition: 0,
  );

  Future<int> presetIdOfCard(int cardId) async {
    final catalog = await presets.loadCatalog();
    return catalog.presetForCard(await cards.getCard(cardId)).id;
  }

  test('a group without preset follows the global one', () async {
    final cardId = await createCard();
    expect(await presetIdOfCard(cardId), standardId);
    await presets.setGlobalPresetId(intensiveId);
    expect(await presetIdOfCard(cardId), intensiveId);
  });

  test('a group preset replaces the global one for its cards', () async {
    final cardId = await createCard();
    await groups.setPreset(groupId, intensiveId);
    expect(await presetIdOfCard(cardId), intensiveId);
  });

  test('a card preset replaces the group one', () async {
    await groups.setPreset(groupId, intensiveId);
    final cardId = await createCard(presetId: standardId);
    expect(await presetIdOfCard(cardId), standardId);
  });

  test('changing the preset of a card keeps its step and due date', () async {
    final cardId = await createCard();
    final dueAt = DateTime(2026, 11, 20, 12);
    await cards.applySchedule(
      cardId,
      CardSchedule(state: CardState.active, step: 4, dueAt: dueAt),
    );
    await cards.setCardPreset(cardId, intensiveId);
    final card = await cards.getCard(cardId);
    expect(card.step, 4);
    expect(card.dueAt, dueAt);
  });
}
