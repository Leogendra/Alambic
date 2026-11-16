import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/distillation/distillation_order.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/distillation/distillation_status.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';

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
    services = SampleServices(database, clock, random: Random(3));
    cards = CardRepository(database);
    distillations = DistillationRepository(database);
    groupId = await services.groups.create('Capitales');
    cardIds = [
      for (final country in ['Mongolie', 'Pérou', 'Laos', 'Chili'])
        await services.card(country, 'capitale', groupId: groupId),
    ];
  });

  tearDown(() => database.close());

  Future<List<CardState>> states() async => [
    for (final cardId in cardIds) (await cards.getCard(cardId)).state,
  ];

  /// Without the budget unless told otherwise, so that the rhythm alone
  /// decides.
  Future<void> activate({
    DistillationSettings settings = const DistillationSettings(
      avoidCollisions: false,
    ),
  }) => services.distillations.activate(groupId, settings);

  void moveTo(DateTime moment) => clock.now = moment;

  const pending = CardState.pending;
  const active = CardState.active;

  test('cards wait in the queue until the distillation is activated', () async {
    await services.distillations.advance();
    expect(await states(), List.filled(4, pending));
  });

  test('activating introduces the first card today', () async {
    await activate();
    expect(await states(), [active, pending, pending, pending]);
    final first = await cards.getCard(cardIds[0]);
    expect(first.dueAt, DateTime(2026, 11, 10, 12));
    expect(first.step, isNull);
    expect(first.queuePosition, isNull);
    expect((await cards.getCard(cardIds[1])).queuePosition, 1);
  });

  test('a group distills once', () async {
    await activate();
    expect(activate, throwsStateError);
  });

  test('one card a day: the next one arrives the next day, once', () async {
    await activate();
    await services.distillations.advance();
    expect(await states(), [active, pending, pending, pending]);
    moveTo(DateTime(2026, 11, 11, 4, 30));
    expect(await services.distillations.advance(), isTrue);
    expect(await states(), [active, active, pending, pending]);
    expect((await cards.getCard(cardIds[1])).dueAt, DateTime(2026, 11, 11, 12));
    expect(await services.distillations.advance(), isFalse);
  });

  test('the day starts at 4am', () async {
    await activate();
    moveTo(DateTime(2026, 11, 11, 3, 59));
    await services.distillations.advance();
    expect(await states(), [active, pending, pending, pending]);
  });

  test('two cards every three days', () async {
    await activate(
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
    await activate();
    moveTo(DateTime(2026, 11, 14, 9));
    await services.distillations.advance();
    expect(await states(), [active, active, pending, pending]);
  });

  test('a random order shuffles the queue at activation', () async {
    await activate(
      settings: const DistillationSettings(
        order: DistillationOrder.random,
        avoidCollisions: false,
      ),
    );
    final positions = {
      for (final cardId in cardIds) (await cards.getCard(cardId)).queuePosition,
    };
    expect(positions.whereType<int>(), unorderedEquals([1, 2, 3]));
    expect((await states()).where((state) => state == active), hasLength(1));
  });

  group('the distillation never ends', () {
    test('it stays once its queue is empty', () async {
      await activate(
        settings: const DistillationSettings(
          cardsPerBatch: 4,
          avoidCollisions: false,
        ),
      );
      expect(await states(), List.filled(4, active));
      expect(await distillations.getAll(), hasLength(1));
    });

    test('a card added to an empty queue comes out with the rhythm', () async {
      await activate(
        settings: const DistillationSettings(
          cardsPerBatch: 4,
          avoidCollisions: false,
        ),
      );
      final added = await services.card('Kenya', 'Nairobi', groupId: groupId);
      expect((await cards.getCard(added)).isPending, isTrue);
      moveTo(DateTime(2026, 11, 11, 9));
      await services.distillations.advance();
      expect((await cards.getCard(added)).state, active);
    });
  });

  test('with an empty queue, the budget holds no reminder back', () async {
    await activate(settings: const DistillationSettings(cardsPerBatch: 4));
    for (final cardId in cardIds) {
      await services.reviews.answer(
        cardId,
        ReviewOutcome.correct,
        source: ReviewSource.session,
      );
    }
    await services.distillations.adjust(groupId, const DistillationSettings());
    moveTo(DateTime(2026, 11, 11, 9));
    expect(await services.distillations.advance(), isFalse);
    for (final cardId in cardIds) {
      expect((await cards.getCard(cardId)).dueAt, DateTime(2026, 11, 11, 12));
    }
  });

  test('a card added later joins the end of the queue', () async {
    await activate();
    final added = await services.card('Kenya', 'Nairobi', groupId: groupId);
    final queued = await cards.getCard(added);
    expect(queued.state, pending);
    expect(queued.queuePosition, 4);
  });

  test('a paused distillation waits, and resumes where it stopped', () async {
    await activate();
    await services.distillations.pause(groupId);
    expect(
      (await distillations.find(groupId))!.status,
      DistillationStatus.paused,
    );
    moveTo(DateTime(2026, 11, 12, 9));
    await services.distillations.advance();
    expect(await states(), [active, pending, pending, pending]);
    await services.distillations.resume(groupId);
    expect(await states(), [active, active, pending, pending]);
  });

  group('adjusting', () {
    test('a larger batch completes the current one', () async {
      await activate();
      await services.distillations.adjust(
        groupId,
        const DistillationSettings(cardsPerBatch: 3, avoidCollisions: false),
      );
      moveTo(DateTime(2026, 11, 11, 9));
      await services.distillations.advance();
      expect(await states(), [active, active, active, active]);
    });

    test('a smaller batch already reached waits X days', () async {
      await activate(
        settings: const DistillationSettings(
          cardsPerBatch: 2,
          avoidCollisions: false,
        ),
      );
      moveTo(DateTime(2026, 11, 11, 9));
      await services.distillations.advance();
      await services.distillations.adjust(
        groupId,
        const DistillationSettings(everyDays: 3, avoidCollisions: false),
      );
      moveTo(DateTime(2026, 11, 13, 9));
      await services.distillations.advance();
      expect(await states(), [active, active, active, active]);
    });

    test('a new order ranks the queue again', () async {
      await activate();
      await services.distillations.adjust(
        groupId,
        const DistillationSettings(
          order: DistillationOrder.random,
          avoidCollisions: false,
        ),
      );
      final ranks = [
        for (final cardId in cardIds.skip(1))
          (await cards.getCard(cardId)).queuePosition,
      ];
      expect(ranks, unorderedEquals([0, 1, 2]));
    });
  });

  test('a suspended card keeps its place without being introduced', () async {
    await services.cards.setSuspended(cardIds[1], suspended: true);
    await activate();
    moveTo(DateTime(2026, 11, 11, 9));
    await services.distillations.advance();
    expect(await states(), [active, pending, active, pending]);
    expect((await cards.getCard(cardIds[1])).queuePosition, 1);
  });

  test('a pending card moved to another group leaves the queue', () async {
    await activate();
    final otherGroup = await services.groups.create('Autres');
    await services.cards.update(
      cardIds[1],
      CardDraft(
        frontText: 'Pérou',
        backText: 'capitale',
        groupId: otherGroup,
        presetId: null,
      ),
    );
    moveTo(DateTime(2026, 11, 11, 9));
    await services.distillations.advance();
    expect(await states(), [active, pending, active, pending]);
  });
}
