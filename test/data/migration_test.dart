import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';

void main() {
  test('a version 1 database keeps its data, gains distillations, guards, pauses and FSRS', () async {
    final schemaV1 = File('test/data/fixtures/schema_v1.sql')
        .readAsStringSync();
    final database = AlambicDatabase(
      NativeDatabase.memory(setup: (raw) => raw.execute(schemaV1)),
    );
    addTearDown(database.close);

    final directions = await database.select(database.cardDirections).get();
    expect(directions, hasLength(2));
    expect(directions.first.state, DirectionState.active);
    expect(directions.first.step, 0);
    expect(directions.first.distillationId, isNull);
    expect(directions.first.queuePosition, isNull);
    expect(await database.select(database.distillations).get(), isEmpty);
    expect(await database.select(database.reviewRecords).get(), hasLength(1));
    final guards = await NotificationSettingsRepository(database).loadGuards();
    expect(guards.dailyCap, NotificationGuards.defaults.dailyCap);
    expect(guards.quietEnd, NotificationGuards.defaults.quietEnd);
    final pauses = await PauseRepository(database).loadPauses();
    expect(pauses.isGlobal, isFalse);
    expect(pauses.groupsSince, isEmpty);
    expect(directions.first.memory, isNull);
    final records = await database.select(database.reviewRecords).get();
    expect(records.single.dueAtAfter, isNull);
    final presets = await database.select(database.presets).get();
    expect(
      presets.map((preset) => preset.builtInKey),
      contains(BuiltInPresetKey.adaptive),
    );
  });
}
