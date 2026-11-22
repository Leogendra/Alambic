import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';

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
    groupId = await GroupRepository(database).create('Capitals', now);
  });

  tearDown(() => database.close());

  Future<void> activate() => distillations.insert(
    groupId: groupId,
    settings: const DistillationSettings(
      cardsPerBatch: 3,
      prioritizeReviews: false,
    ),
    startedAt: now,
  );

  test('a group has no distillation until it is activated', () async {
    expect(await distillations.find(groupId), isNull);
  });

  test('a distillation keeps its settings and starts running', () async {
    await activate();
    final distillation = (await distillations.find(groupId))!;
    expect(distillation.groupId, groupId);
    expect(distillation.cardsPerBatch, 3);
    expect(distillation.prioritizeReviews, isFalse);
    expect(distillation.pausedAt, isNull);
    expect(distillation.lastBatchDay, isNull);
    expect(distillation.lastAdvancedDay, isNull);
  });

  test('one distillation per group', () async {
    await activate();
    expect(activate, throwsA(anything));
  });

  test('the day of the last batch moves only when a batch came out', () async {
    await activate();
    await distillations.saveProgress(
      groupId,
      advancedDay: today,
      batchCameOut: true,
    );
    final tomorrow = DateTime(2026, 11, 11);
    await distillations.saveProgress(
      groupId,
      advancedDay: tomorrow,
      batchCameOut: false,
    );
    final distillation = (await distillations.find(groupId))!;
    expect(distillation.lastBatchDay, today);
    expect(distillation.lastAdvancedDay, tomorrow);
  });

  test('new settings keep the day of the last batch', () async {
    await activate();
    await distillations.saveProgress(
      groupId,
      advancedDay: today,
      batchCameOut: true,
    );
    await distillations.saveSettings(
      groupId,
      const DistillationSettings(cardsPerBatch: 5),
    );
    final distillation = (await distillations.find(groupId))!;
    expect(distillation.cardsPerBatch, 5);
    expect(distillation.prioritizeReviews, isTrue);
    expect(distillation.lastBatchDay, today);
  });

  test('deleting a group deletes its distillation', () async {
    await activate();
    await GroupRepository(database).delete(groupId);
    expect(await distillations.getAll(), isEmpty);
  });
}
