import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/distillation/distillation_order.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/distillation/distillation_status.dart';
import 'package:alambic/domain/scheduling/direction_schedule.dart';

import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late DistillationRepository distillations;
  late CardRepository cards;
  late int groupId;
  late int directionId;

  final now = DateTime(2026, 11, 10, 9);
  final today = DateTime(2026, 11, 10);

  setUp(() async {
    database = openTestDatabase();
    distillations = DistillationRepository(database);
    cards = CardRepository(database);
    groupId = await GroupRepository(database).create('Capitales', now);
    final cardId = await cards.insertCard(
      groupId: groupId,
      frontText: 'Mongolie',
      backText: 'Oulan-Bator',
      presetId: null,
      createdAt: now,
    );
    await cards.insertDirection(
      cardId: cardId,
      sense: DirectionSense.frontToBack,
      schedule: DirectionSchedule.unstarted,
    );
    directionId = (await cards.getDirections(cardId)).single.id;
  });

  tearDown(() => database.close());

  Future<int> launch() => distillations.insert(
    groupId: groupId,
    sense: DirectionSense.frontToBack,
    settings: const DistillationSettings(
      cardsPerBatch: 3,
      everyDays: 2,
      order: DistillationOrder.random,
      avoidCollisions: false,
    ),
    startedAt: now,
    firstBatchDay: today,
  );

  test('a distillation keeps its settings and starts running', () async {
    final distillation = await distillations.get(await launch());
    expect(distillation.groupId, groupId);
    expect(distillation.sense, DirectionSense.frontToBack);
    expect(distillation.cardsPerBatch, 3);
    expect(distillation.everyDays, 2);
    expect(distillation.introductionOrder, DistillationOrder.random);
    expect(distillation.avoidCollisions, isFalse);
    expect(distillation.status, DistillationStatus.running);
    expect(distillation.nextBatchDay, today);
    expect(distillation.introducedInBatch, 0);
    expect(distillation.lastAdvancedDay, isNull);
  });

  test('a queued direction is pending, with its rank', () async {
    final distillationId = await launch();
    await cards.enqueue(
      directionId,
      distillationId: distillationId,
      position: 4,
    );
    final direction = await cards.getDirection(directionId);
    expect(direction.state, DirectionState.pending);
    expect(direction.distillationId, distillationId);
    expect(direction.queuePosition, 4);
    expect(direction.isStartable, isFalse);
  });

  test('deleting a distillation leaves its queue pending, startable', () async {
    final distillationId = await launch();
    await cards.enqueue(
      directionId,
      distillationId: distillationId,
      position: 0,
    );
    await distillations.delete(distillationId);
    final direction = await cards.getDirection(directionId);
    expect(direction.state, DirectionState.pending);
    expect(direction.distillationId, isNull);
    expect(direction.isStartable, isTrue);
  });

  test('deleting a group deletes its distillations', () async {
    await launch();
    await GroupRepository(database).delete(groupId);
    expect(await distillations.getAll(), isEmpty);
  });
}
