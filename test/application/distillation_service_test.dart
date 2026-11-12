import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/domain/cards/card_direction.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late FixedClock clock;
  late SampleServices services;
  late CardRepository cards;
  late DistillationRepository distillations;
  late int groupId;
  late List<int> cardIds;

  setUp(() async {
    database = openTestDatabase();
    clock = FixedClock(DateTime(2026, 11, 10, 9));
    services = SampleServices(database, clock);
    cards = CardRepository(database);
    distillations = DistillationRepository(database);
    groupId = await services.groups.create('Capitales');
    cardIds = [
      for (final country in ['Mongolie', 'Pérou', 'Laos', 'Chili'])
        await services.card(country, 'capitale', groupId: groupId),
    ];
  });

  tearDown(() => database.close());

  Future<CardDirection> direction(
    int cardId, [
    DirectionSense sense = DirectionSense.frontToBack,
  ]) async =>
      (await cards.getDirections(cardId))
          .firstWhere((direction) => direction.sense == sense);

  Future<List<DirectionState>> states([
    DirectionSense sense = DirectionSense.frontToBack,
  ]) async => [
    for (final cardId in cardIds) (await direction(cardId, sense)).state,
  ];

  /// Without the budget unless told otherwise, so that the rhythm alone
  /// decides.
  Future<int> launch({
    DirectionSense sense = DirectionSense.frontToBack,
    DistillationSettings settings = const DistillationSettings(
      avoidCollisions: false,
    ),
  }) => services.distillations.launchForGroup(groupId, sense, settings);

  void moveTo(DateTime moment) => clock.now = moment;

  const pending = DirectionState.pending;
  const active = DirectionState.active;

  test(
    'launching queues the new cards and introduces the first one today',
    () async {
      final distillationId = await launch();
      expect(await states(), [active, pending, pending, pending]);
      final first = await direction(cardIds[0]);
      expect(first.dueAt, DateTime(2026, 11, 10, 12));
      expect(first.step, isNull);
      expect(first.distillationId, distillationId);
      expect(first.queuePosition, isNull);
      expect((await direction(cardIds[1])).queuePosition, 1);
    },
  );

  test('one card a day: the next one arrives the next day, once', () async {
    await launch();
    await services.distillations.advance();
    expect(await states(), [active, pending, pending, pending]);
    moveTo(DateTime(2026, 11, 11, 4, 30));
    expect(await services.distillations.advance(), isTrue);
    expect(await states(), [active, active, pending, pending]);
    expect((await direction(cardIds[1])).dueAt, DateTime(2026, 11, 11, 12));
    expect(await services.distillations.advance(), isFalse);
  });

  test('the day starts at 4am', () async {
    await launch();
    moveTo(DateTime(2026, 11, 11, 3, 59));
    await services.distillations.advance();
    expect(await states(), [active, pending, pending, pending]);
  });

  test('two cards every three days', () async {
    await launch(
      settings: const DistillationSettings(
        cardsPerBatch: 2,
        everyDays: 3,
        avoidCollisions: false,
      ),
    );
    expect(await states(), [active, active, pending, pending]);
    for (final day in [11, 12]) {
      moveTo(DateTime(2026, 11, day, 9));
      await services.distillations.advance();
      expect(await states(), [active, active, pending, pending]);
    }
    moveTo(DateTime(2026, 11, 13, 9));
    await services.distillations.advance();
    expect(await states(), [active, active, active, active]);
  });

  test('a missed day is not caught up', () async {
    await launch(settings: const DistillationSettings(avoidCollisions: false));
    moveTo(DateTime(2026, 11, 14, 9));
    await services.distillations.advance();
    expect(await states(), [active, active, pending, pending]);
  });

  test(
    'a card added during the distillation joins the end of the queue',
    () async {
      await launch();
      final added = await services.card('Kenya', 'Nairobi', groupId: groupId);
      final queued = await direction(added);
      expect(queued.state, pending);
      expect(queued.queuePosition, 4);
      final outside = await services.card('Japon', 'Tokyo');
      expect((await direction(outside)).state, DirectionState.unstarted);
    },
  );

  test('the distillation ends when its queue is empty', () async {
    await launch(
      settings: const DistillationSettings(
        cardsPerBatch: 3,
        avoidCollisions: false,
      ),
    );
    moveTo(DateTime(2026, 11, 11, 9));
    await services.distillations.advance();
    expect(await states(), [active, active, active, active]);
    expect(await distillations.getAll(), isEmpty);
    expect((await direction(cardIds[3])).distillationId, isNull);
  });

  test(
    'a reverse distillation activates the reverse of one-way cards',
    () async {
      await launch(sense: DirectionSense.backToFront);
      expect(await states(DirectionSense.backToFront), [
        active,
        pending,
        pending,
        pending,
      ]);
      expect(await states(), List.filled(4, DirectionState.unstarted));
    },
  );

  test('a paused distillation waits, and resumes where it stopped', () async {
    final distillationId = await launch();
    await services.distillations.pause(distillationId);
    moveTo(DateTime(2026, 11, 12, 9));
    await services.distillations.advance();
    expect(await states(), [active, pending, pending, pending]);
    await services.distillations.resume(distillationId);
    expect(await states(), [active, active, pending, pending]);
  });

  test('stopping leaves the rest pending, to start by hand', () async {
    final distillationId = await launch();
    await services.distillations.stop(distillationId);
    final left = await direction(cardIds[1]);
    expect(left.state, pending);
    expect(left.isStartable, isTrue);
    expect(await services.cards.startGroup(groupId), 3);
    expect(await states(), List.filled(4, active));
  });

  test('a suspended card keeps its place without being introduced', () async {
    await services.cards.setSuspended(cardIds[1], suspended: true);
    await launch();
    moveTo(DateTime(2026, 11, 11, 9));
    await services.distillations.advance();
    expect(await states(), [active, pending, active, pending]);
    expect((await direction(cardIds[1])).queuePosition, 1);
  });

  test('a card moved to another group leaves the queue', () async {
    await launch();
    final otherGroup = await services.groups.create('Autres');
    await services.cards.update(
      cardIds[2],
      CardDraft(
        frontText: 'Laos',
        backText: 'capitale',
        groupId: otherGroup,
        presetId: null,
        alsoReverse: false,
      ),
    );
    final moved = await direction(cardIds[2]);
    expect(moved.distillationId, isNull);
    expect(moved.isStartable, isTrue);
  });
}
