import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/presets/preset_service.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late PresetRepository presets;
  late GroupRepository groups;
  late CardRepository cards;
  late RecordingScheduleListener listener;
  late PresetService service;
  late int standardId;
  late int intensiveId;

  setUp(() async {
    database = openTestDatabase();
    samples = SampleServices(database, FixedClock(sampleNow));
    presets = PresetRepository(database);
    groups = GroupRepository(database);
    cards = CardRepository(database);
    listener = RecordingScheduleListener();
    service = PresetService(presets, groups, listener);
    final catalog = await presets.loadCatalog();
    standardId = catalog.globalPresetId;
    intensiveId = catalog.presetsById.values
        .firstWhere((preset) => preset.builtInKey == BuiltInPresetKey.intensive)
        .id;
  });

  tearDown(() => database.close());

  test('the groups that follow a deleted preset move to the default one, '
      'their cards keeping their steps and due dates', () async {
    final capitals = await samples.groups.create('Capitals');
    final spanish = await samples.groups.create('Spanish');
    await samples.groups.setPreset(capitals, intensiveId);
    await samples.groups.setPreset(spanish, intensiveId);
    final cardId = await samples.card('Peru', 'Lima', groupId: capitals);
    final dueAt = DateTime(2026, 11, 20, 12);
    await cards.applySchedule(
      cardId,
      CardSchedule(state: CardState.active, step: 4, dueAt: dueAt),
    );
    expect((await presets.loadCatalog()).groupCountFollowing(intensiveId), 2);

    await service.delete(intensiveId);

    final catalog = await presets.loadCatalog();
    expect(catalog.presetsById.keys, [standardId]);
    expect(catalog.presetForGroup(capitals).id, standardId);
    expect((await groups.find(capitals))!.presetId, standardId);
    expect((await groups.find(spanish))!.presetId, standardId);
    final card = await cards.getCard(cardId);
    expect(card.step, 4);
    expect(card.dueAt, dueAt);
    expect(listener.changeCount, 1);
  });

  test('the groups of other presets keep theirs', () async {
    final copyId = await service.duplicate(
      (await presets.loadCatalog()).presetsById[intensiveId]!,
      'Examen',
    );
    final capitals = await samples.groups.create('Capitals');
    final biology = await samples.groups.create('Biology');
    await samples.groups.setPreset(capitals, copyId);

    await service.delete(intensiveId);

    expect((await groups.find(capitals))!.presetId, copyId);
    expect((await groups.find(biology))!.presetId, standardId);
  });

  test('the default preset cannot be deleted', () async {
    final capitals = await samples.groups.create('Capitals');
    await samples.groups.setPreset(capitals, standardId);

    await expectLater(service.delete(standardId), throwsStateError);

    expect((await presets.loadCatalog()).presetsById, hasLength(2));
    expect((await groups.find(capitals))!.presetId, standardId);
    expect(listener.changeCount, 0);
  });
}
