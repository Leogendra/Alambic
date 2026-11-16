import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/domain/distillation/distillation_order.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/distillation/distillation_status.dart';

import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late DistillationRepository distillations;
  late int groupId;

  final now = DateTime(2026, 11, 10, 9);
  final today = DateTime(2026, 11, 10);

  setUp(() async {
    database = openTestDatabase();
    distillations = DistillationRepository(database);
    groupId = await GroupRepository(database).create('Capitales', now);
  });

  tearDown(() => database.close());

  Future<void> activate() => distillations.insert(
    groupId: groupId,
    settings: const DistillationSettings(
      cardsPerBatch: 3,
      everyDays: 2,
      order: DistillationOrder.random,
      avoidCollisions: false,
    ),
    startedAt: now,
    firstBatchDay: today,
  );

  test('a group has no distillation until it is activated', () async {
    expect(await distillations.find(groupId), isNull);
  });

  test('a distillation keeps its settings and starts running', () async {
    await activate();
    final distillation = (await distillations.find(groupId))!;
    expect(distillation.groupId, groupId);
    expect(distillation.cardsPerBatch, 3);
    expect(distillation.everyDays, 2);
    expect(distillation.introductionOrder, DistillationOrder.random);
    expect(distillation.avoidCollisions, isFalse);
    expect(distillation.status, DistillationStatus.running);
    expect(distillation.nextBatchDay, today);
    expect(distillation.introducedInBatch, 0);
    expect(distillation.lastAdvancedDay, isNull);
  });

  test('one distillation per group', () async {
    await activate();
    expect(activate, throwsA(anything));
  });

  test('new settings keep the progress of the batches', () async {
    await activate();
    await distillations.saveProgress(
      groupId,
      advancedDay: today,
      nextBatchDay: today,
      introducedInBatch: 1,
    );
    await distillations.saveSettings(
      groupId,
      const DistillationSettings(cardsPerBatch: 5),
      nextBatchDay: today,
      introducedInBatch: 1,
    );
    final distillation = (await distillations.find(groupId))!;
    expect(distillation.cardsPerBatch, 5);
    expect(distillation.introductionOrder, DistillationOrder.groupOrder);
    expect(distillation.introducedInBatch, 1);
    expect(distillation.lastAdvancedDay, today);
  });

  test('deleting a group deletes its distillation', () async {
    await activate();
    await GroupRepository(database).delete(groupId);
    expect(await distillations.getAll(), isEmpty);
  });
}
