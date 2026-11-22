import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';

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
    groupId = await groups.create('Capitals', DateTime(2026, 11, 10));
  });

  tearDown(() => database.close());

  Future<int> createCard() => cards.insertCard(
    groupId: groupId,
    frontText: 'Mongolia',
    frontImagePath: null,
    backText: 'Ulaanbaatar',
    backImagePath: null,
    createdAt: DateTime(2026, 11, 10),
    queuePosition: 0,
  );

  Future<int> presetIdOfCard(int cardId) async {
    final catalog = await presets.loadCatalog();
    final card = await cards.getCard(cardId);
    return catalog.presetForGroup(card.groupId).id;
  }

  test('a new group follows the global preset of the moment', () async {
    final cardId = await createCard();
    expect((await groups.find(groupId))!.presetId, standardId);
    expect(await presetIdOfCard(cardId), standardId);

    await presets.setGlobalPresetId(intensiveId);
    final later = await groups.create('Later', DateTime(2026, 11, 11));

    expect((await groups.find(later))!.presetId, intensiveId);
  });

  test('changing the global preset leaves the existing groups alone', () async {
    final cardId = await createCard();
    await presets.setGlobalPresetId(intensiveId);
    expect(await presetIdOfCard(cardId), standardId);
  });

  test('the preset of a group is the one it was given', () async {
    final cardId = await createCard();
    await groups.setPreset(groupId, intensiveId);
    expect(await presetIdOfCard(cardId), intensiveId);
    await groups.setPreset(groupId, standardId);
    expect(await presetIdOfCard(cardId), standardId);
  });
}
