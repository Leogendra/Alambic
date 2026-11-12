import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/application/distillation/distillation_refused.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/distillation_repository.dart';
import 'package:remanence/domain/cards/card_direction.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/cards/direction_state.dart';
import 'package:remanence/domain/distillation/distillation_order.dart';
import 'package:remanence/domain/distillation/distillation_settings.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  late FixedClock clock;
  late SampleServices services;
  late CardRepository cards;
  late DistillationRepository distillations;
  late int capitals;
  late int spanish;

  const settings = DistillationSettings(avoidCollisions: false);

  setUp(() async {
    database = openTestDatabase();
    clock = FixedClock(DateTime(2026, 11, 10, 9));
    services = SampleServices(database, clock, random: Random(7));
    cards = CardRepository(database);
    distillations = DistillationRepository(database);
    capitals = await services.groups.create('Capitales');
    spanish = await services.groups.create('Espagnol');
    for (final country in ['Mongolie', 'Pérou', 'Laos']) {
      await services.card(
        country,
        'capitale',
        groupId: capitals,
        alsoReverse: true,
      );
    }
    for (final word in ['manger', 'boire']) {
      await services.card(word, 'espagnol', groupId: spanish);
    }
    await services.card('Mitochondrie', 'cellule', alsoReverse: true);
  });

  tearDown(() => database.close());

  Matcher refusedFor(DistillationRefusal reason) => throwsA(
    isA<DistillationRefused>().having(
      (refused) => refused.reason,
      'reason',
      reason,
    ),
  );

  Future<List<CardDirection>> allDirections() async => [
    for (final card in await cards.getAll()) ...card.directions,
  ];

  group('group distillations', () {
    test('one per direction: the second one of a sense is refused', () async {
      await services.distillations.launchForGroup(
        capitals,
        DirectionSense.frontToBack,
        settings,
      );
      await expectLater(
        services.distillations.launchForGroup(
          capitals,
          DirectionSense.frontToBack,
          settings,
        ),
        refusedFor(DistillationRefusal.senseTaken),
      );
      await services.distillations.launchForGroup(
        capitals,
        DirectionSense.backToFront,
        settings,
      );
      expect(await distillations.getAll(), hasLength(2));
    });

    test('a group with nothing new cannot be distilled', () async {
      await services.cards.startGroup(spanish);
      await expectLater(
        services.distillations.launchForGroup(
          spanish,
          DirectionSense.frontToBack,
          settings,
        ),
        refusedFor(DistillationRefusal.nothingToDistill),
      );
      expect(await distillations.getAll(), isEmpty);
    });
  });

  group('global distillation', () {
    test('it stops the other distillations and takes their queues', () async {
      await services.distillations.launchForGroup(
        capitals,
        DirectionSense.frontToBack,
        settings,
      );
      final globalId = await services.distillations.launchGlobal(settings);
      final all = await distillations.getAll();
      expect(all.map((distillation) => distillation.id), [globalId]);
      expect(all.single.introductionOrder, DistillationOrder.random);
      final pending = (await allDirections()).where(
        (direction) => direction.state == DirectionState.pending,
      );
      expect(
        pending.every((direction) => direction.distillationId == globalId),
        isTrue,
      );
      // 6 fronts and 4 reverses, less the first card of each distillation.
      expect(pending, hasLength(8));
    });

    test('it blocks group distillations while in progress', () async {
      await services.distillations.launchGlobal(settings);
      await expectLater(
        services.distillations.launchForGroup(
          spanish,
          DirectionSense.backToFront,
          settings,
        ),
        refusedFor(DistillationRefusal.globalInProgress),
      );
    });

    test('a reverse arrives after its front, never the same day', () async {
      await services.distillations.launchGlobal(
        const DistillationSettings(cardsPerBatch: 2, avoidCollisions: false),
      );
      final introducedOn = <int, DateTime>{};
      for (var day = 10; day <= 20; day++) {
        clock.now = DateTime(2026, 11, day, 9);
        await services.distillations.advance();
        for (final direction in await allDirections()) {
          if (direction.state == DirectionState.active) {
            introducedOn.putIfAbsent(
              direction.id,
              () => DateTime(2026, 11, day),
            );
          }
        }
      }
      final directions = await allDirections();
      expect(introducedOn, hasLength(10));
      for (final reverse in directions.where(
        (direction) =>
            direction.sense == DirectionSense.backToFront &&
            direction.state == DirectionState.active,
      )) {
        final front = directions.firstWhere(
          (direction) =>
              direction.cardId == reverse.cardId &&
              direction.sense == DirectionSense.frontToBack,
        );
        expect(
          introducedOn[reverse.id]!.isAfter(introducedOn[front.id]!),
          isTrue,
        );
      }
    });

    test('a card created meanwhile joins it, its reverse waiting for the '
        'front', () async {
      final globalId = await services.distillations.launchGlobal(settings);
      final cardId = await services.card(
        'Kenya',
        'Nairobi',
        groupId: spanish,
        alsoReverse: true,
      );
      final directions = await cards.getDirections(cardId);
      final front = directions.firstWhere(
        (direction) => direction.sense == DirectionSense.frontToBack,
      );
      final reverse = directions.firstWhere(
        (direction) => direction.sense == DirectionSense.backToFront,
      );
      expect(front.distillationId, globalId);
      expect(front.queuePosition, isNotNull);
      expect(reverse.distillationId, globalId);
      expect(reverse.queuePosition, isNull);
    });
  });
}
