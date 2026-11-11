import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/group_repository.dart';
import 'package:remanence/data/repositories/preset_repository.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/cards/direction_state.dart';
import 'package:remanence/domain/presets/built_in_preset_key.dart';
import 'package:remanence/domain/scheduling/direction_schedule.dart';

void main() {
  late RemanenceDatabase database;
  late PresetRepository presets;
  late GroupRepository groups;
  late CardRepository cards;
  late int standardId;
  late int intensiveId;

  setUp(() async {
    database = RemanenceDatabase(NativeDatabase.memory());
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
  });

  tearDown(() => database.close());

  Future<int> createCard({int? groupId, int? presetId}) => cards.insertCard(
    groupId: groupId,
    frontText: 'Mongolie',
    backText: 'Oulan-Bator',
    presetId: presetId,
    createdAt: DateTime(2026, 11, 10),
  );

  Future<int> presetIdOfCard(int cardId) async {
    final catalog = await presets.loadCatalog();
    return catalog.presetForCard(await cards.getCard(cardId)).id;
  }

  test('a card outside any group follows the global preset', () async {
    final cardId = await createCard();
    expect(await presetIdOfCard(cardId), standardId);
    await presets.setGlobalPresetId(intensiveId);
    expect(await presetIdOfCard(cardId), intensiveId);
  });

  test('a group preset replaces the global one for its cards', () async {
    final groupId = await groups.create('Capitales', DateTime(2026, 11, 10));
    final cardId = await createCard(groupId: groupId);
    await groups.setPreset(groupId, intensiveId);
    expect(await presetIdOfCard(cardId), intensiveId);
  });

  test('a card preset replaces the group one', () async {
    final groupId = await groups.create('Capitales', DateTime(2026, 11, 10));
    await groups.setPreset(groupId, intensiveId);
    final cardId = await createCard(groupId: groupId, presetId: standardId);
    expect(await presetIdOfCard(cardId), standardId);
  });

  test('changing the preset of a card keeps its step and due date', () async {
    final cardId = await createCard();
    final dueAt = DateTime(2026, 11, 20, 12);
    await cards.insertDirection(
      cardId: cardId,
      sense: DirectionSense.frontToBack,
      schedule: DirectionSchedule(
        state: DirectionState.active,
        step: 4,
        dueAt: dueAt,
      ),
    );
    await cards.setCardPreset(cardId, intensiveId);
    final direction = (await cards.getDirections(cardId)).single;
    expect(direction.step, 4);
    expect(direction.dueAt, dueAt);
  });
}
