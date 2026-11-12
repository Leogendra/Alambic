import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/presets/preset_service.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset_interval.dart';
import 'package:alambic/domain/presets/scheduling_engine_kind.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';

import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late PresetRepository presets;
  late PresetService service;

  setUp(() {
    database = openTestDatabase();
    presets = PresetRepository(database);
    service = PresetService(presets);
  });

  tearDown(() => database.close());

  test('a new preset starts from Standard and is not a shipped one', () async {
    final id = await service.save(service.newDraft('Révision du soir'));
    final stored = await presets.getById(id);
    expect(stored.name, 'Révision du soir');
    expect(stored.builtInKey, isNull);
    expect(stored.intervals, hasLength(6));
  });

  test('saving a stored preset updates it in place', () async {
    final standard = (await presets.loadCatalog()).globalPreset;
    await service.save(
      standard.copyWith(
        fixedTime: const ClockTime(18, 0),
        intervals: const [PresetInterval(3, IntervalUnit.day)],
      ),
    );
    final stored = await presets.getById(standard.id);
    expect(stored.fixedTime, const ClockTime(18, 0));
    expect(stored.intervals, const [PresetInterval(3, IntervalUnit.day)]);
    expect(stored.builtInKey, BuiltInPresetKey.standard);
  });

  test('duplicating keeps every rule under a new name', () async {
    final standard = (await presets.loadCatalog()).globalPreset;
    final copyId = await service.duplicate(standard, 'Standard (copie)');
    final copy = await presets.getById(copyId);
    expect(copy.id, isNot(standard.id));
    expect(copy.name, 'Standard (copie)');
    expect(copy.builtInKey, isNull);
    expect(copy.intervals, standard.intervals);
    expect(copy.fixedTime, standard.fixedTime);
  });

  test('a preset needs a name and at least one step', () async {
    final draft = service.newDraft('Vide');
    expect(() => service.save(draft.copyWith(name: ' ')), throwsArgumentError);
    expect(
      () => service.save(draft.copyWith(intervals: const [])),
      throwsArgumentError,
    );
  });

  test('an adaptive preset aims at a retention from 70 % to 97 %', () async {
    final draft = service
        .newDraft('FSRS')
        .copyWith(engine: SchedulingEngineKind.adaptive);
    expect(
      () => service.save(draft.copyWith(targetRetention: 0.6)),
      throwsArgumentError,
    );
    expect(
      () => service.save(draft.copyWith(targetRetention: 0.99)),
      throwsArgumentError,
    );
    expect(
      await service.save(draft.copyWith(targetRetention: 0.85)),
      isPositive,
    );
  });
}
