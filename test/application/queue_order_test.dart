import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// The queue of a group as the distillation reads it, from every way in.
void main() {
  late AlambicDatabase database;
  late FixedClock clock;
  late SampleServices services;
  late CardRepository cards;
  late int groupId;
  late Map<String, int> ids;

  setUp(() async {
    database = openTestDatabase();
    clock = FixedClock(sampleNow);
    services = SampleServices(database, clock);
    cards = CardRepository(database);
    groupId = await services.groups.create('Capitales');
    ids = {
      for (final country in ['Mongolie', 'Pérou', 'Laos', 'Chili'])
        country: await services.card(country, 'capitale', groupId: groupId),
    };
  });

  tearDown(() => database.close());

  /// Fronts of the pending cards of the group, head first.
  Future<List<String?>> queue([int? group]) async {
    final pending = [
      for (final card in await cards.getCardsOfGroup(group ?? groupId))
        if (card.isPending) card,
    ]..sort(_byQueue);
    return [for (final card in pending) card.frontText];
  }

  Future<void> answer(
    String country,
    ReviewOutcome outcome, {
    bool raises = true,
    bool forceBonus = false,
  }) => services.reviews.answer(
    ids[country]!,
    outcome,
    source: ReviewSource.session,
    forceBonus: forceBonus,
    raisesMissedPending: raises,
  );

  group('ways in', () {
    test('created cards join the end, in creation order', () async {
      expect(await queue(), ['Mongolie', 'Pérou', 'Laos', 'Chili']);
    });

    test('a bulk add joins the end as a batch, in its order', () async {
      await services.cards.createAll([
        for (final country in ['Kenya', 'Maroc'])
          CardDraft(frontText: country, backText: 'capitale', groupId: groupId),
      ]);
      expect(await queue(), [
        'Mongolie',
        'Pérou',
        'Laos',
        'Chili',
        'Kenya',
        'Maroc',
      ]);
    });

    test('a reset card joins the end', () async {
      await services.introduceAll(groupId);
      await services.card('Kenya', 'capitale', groupId: groupId);
      await services.cards.resetProgress(ids['Pérou']!);
      expect(await queue(), ['Kenya', 'Pérou']);
    });

    test('a pending card moved in joins the end', () async {
      final other = await services.groups.create('Autres');
      final kenya = await services.card('Kenya', 'capitale', groupId: other);
      await services.cards.update(
        kenya,
        CardDraft(frontText: 'Kenya', backText: 'capitale', groupId: groupId),
      );
      expect(await queue(), ['Mongolie', 'Pérou', 'Laos', 'Chili', 'Kenya']);
    });
  });

  group('"Review all" raises a missed pending card', () {
    test('to the head of the queue, still pending, as a bonus', () async {
      await answer('Laos', ReviewOutcome.again);
      expect(await queue(), ['Laos', 'Mongolie', 'Pérou', 'Chili']);
      final laos = await cards.getCard(ids['Laos']!);
      expect(laos.isPending, isTrue);
      final history = await ReviewRepository(database)
          .watchHistory(laos.id)
          .first;
      expect(history.single.isBonus, isTrue);
    });

    test('the last one missed comes out first', () async {
      await answer('Mongolie', ReviewOutcome.correct);
      await answer('Pérou', ReviewOutcome.again);
      await answer('Laos', ReviewOutcome.correct);
      await answer('Chili', ReviewOutcome.again);
      expect(await queue(), ['Chili', 'Pérou', 'Mongolie', 'Laos']);
    });

    test('a later card joins the end, behind the raised ones', () async {
      await answer('Chili', ReviewOutcome.again);
      await services.card('Kenya', 'capitale', groupId: groupId);
      expect(await queue(), ['Chili', 'Mongolie', 'Pérou', 'Laos', 'Kenya']);
    });

    test('nowhere else: a forced bonus or another session', () async {
      await answer('Laos', ReviewOutcome.again, forceBonus: true);
      await answer('Chili', ReviewOutcome.again, raises: false);
      expect(await queue(), ['Mongolie', 'Pérou', 'Laos', 'Chili']);
    });

    test('the distillation introduces it next', () async {
      await answer('Laos', ReviewOutcome.again);
      await services.distillations.activate(
        groupId,
        const DistillationSettings(avoidCollisions: false),
      );
      expect(await queue(), ['Mongolie', 'Pérou', 'Chili']);
    });
  });

  test(
    'the distillation skips a suspended head, which keeps its place',
    () async {
      await services.cards.setSuspended(ids['Mongolie']!, suspended: true);
      await services.distillations.activate(
        groupId,
        const DistillationSettings(avoidCollisions: false),
      );
      expect(await queue(), ['Mongolie', 'Laos', 'Chili']);
    },
  );
}

int _byQueue(Flashcard first, Flashcard second) {
  final byPosition = first.queuePosition!.compareTo(second.queuePosition!);
  return byPosition != 0 ? byPosition : first.id.compareTo(second.id);
}
