import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/distillation/queue_service.dart';
import 'package:alambic/application/groups/group_sections.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/step_target.dart';

import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
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
    groupId = await services.groups.create('Capitals');
    ids = {
      for (final country in ['Mongolia', 'Peru', 'Laos', 'Chile'])
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
      expect(await queue(), ['Mongolia', 'Peru', 'Laos', 'Chile']);
    });

    test('a bulk add joins the end as a batch, in its order', () async {
      await services.cards.createAll([
        for (final country in ['Kenya', 'Morocco'])
          CardDraft(frontText: country, backText: 'capitale', groupId: groupId),
      ]);
      expect(await queue(), [
        'Mongolia',
        'Peru',
        'Laos',
        'Chile',
        'Kenya',
        'Morocco',
      ]);
    });

    test('a reset card joins the end', () async {
      await services.introduceAll(groupId);
      await services.card('Kenya', 'capitale', groupId: groupId);
      await services.cards.setStep(ids['Peru']!, const PendingTarget());
      expect(await queue(), ['Kenya', 'Peru']);
    });

    test('a pending card moved in joins the end', () async {
      final other = await services.groups.create('Autres');
      final kenya = await services.card('Kenya', 'capitale', groupId: other);
      await services.cards.update(
        kenya,
        CardDraft(frontText: 'Kenya', backText: 'capitale', groupId: groupId),
      );
      expect(await queue(), ['Mongolia', 'Peru', 'Laos', 'Chile', 'Kenya']);
    });
  });

  group('"Review all" raises a missed pending card', () {
    test('to the head of the queue, still pending, as a bonus', () async {
      await answer('Laos', ReviewOutcome.again);
      expect(await queue(), ['Laos', 'Mongolia', 'Peru', 'Chile']);
      final laos = await cards.getCard(ids['Laos']!);
      expect(laos.isPending, isTrue);
      final history = await ReviewRepository(database)
          .watchHistory(laos.id)
          .first;
      expect(history.single.isBonus, isTrue);
    });

    test('the last one missed comes out first', () async {
      await answer('Mongolia', ReviewOutcome.correct);
      await answer('Peru', ReviewOutcome.again);
      await answer('Laos', ReviewOutcome.correct);
      await answer('Chile', ReviewOutcome.again);
      expect(await queue(), ['Chile', 'Peru', 'Mongolia', 'Laos']);
    });

    test('a later card joins the end, behind the raised ones', () async {
      await answer('Chile', ReviewOutcome.again);
      await services.card('Kenya', 'capitale', groupId: groupId);
      expect(await queue(), ['Chile', 'Mongolia', 'Peru', 'Laos', 'Kenya']);
    });

    test('nowhere else: a forced bonus or another session', () async {
      await answer('Laos', ReviewOutcome.again, forceBonus: true);
      await answer('Chile', ReviewOutcome.again, raises: false);
      expect(await queue(), ['Mongolia', 'Peru', 'Laos', 'Chile']);
    });

    test('the distillation introduces it next', () async {
      await answer('Laos', ReviewOutcome.again);
      await services.distillations.activate(
        groupId,
        const DistillationSettings(prioritizeReviews: false),
      );
      expect(await queue(), ['Mongolia', 'Peru', 'Chile']);
    });
  });

  group('moved by hand', () {
    late RecordingScheduleListener listener;
    late QueueService queueService;

    setUp(() {
      listener = RecordingScheduleListener();
      queueService = QueueService(
        cards: cards,
        scheduleChangeListener: listener,
      );
    });

    /// The ranks stored, which always run from 0 without a gap.
    Future<List<int?>> ranks() async {
      final pending = [
        for (final card in await cards.getCardsOfGroup(groupId))
          if (card.isPending) card,
      ]..sort(_byQueue);
      return [for (final card in pending) card.queuePosition];
    }

    test('to the head, and it is next', () async {
      await queueService.moveToHead(ids['Laos']!);
      expect(await queue(), ['Laos', 'Mongolia', 'Peru', 'Chile']);
      expect(await ranks(), [0, 1, 2, 3]);
      final sections = GroupSections.of(await cards.getCardsOfGroup(groupId));
      expect(sections.nextId, ids['Laos']);
      expect(listener.changeCount, 1);
    });

    test('to the end', () async {
      await queueService.moveToEnd(ids['Mongolia']!);
      expect(await queue(), ['Peru', 'Laos', 'Chile', 'Mongolia']);
      expect(await ranks(), [0, 1, 2, 3]);
    });

    test('to a place in the middle, the others keeping their order', () async {
      await queueService.moveTo(ids['Chile']!, 1);
      expect(await queue(), ['Mongolia', 'Chile', 'Peru', 'Laos']);
      await queueService.moveTo(ids['Mongolia']!, 2);
      expect(await queue(), ['Chile', 'Peru', 'Mongolia', 'Laos']);
      expect(await ranks(), [0, 1, 2, 3]);
    });

    test('shuffled with the draw given', () async {
      await queueService.shuffleQueue(groupId, Random(7));
      expect(await queue(), ['Peru', 'Chile', 'Laos', 'Mongolia']);
      expect(await ranks(), [0, 1, 2, 3]);
    });

    test('an introduced card is not in the queue', () async {
      await services.introduceAll(groupId);
      expect(() => queueService.moveToHead(ids['Peru']!), throwsArgumentError);
    });
  });
}

int _byQueue(Flashcard first, Flashcard second) {
  final byPosition = first.queuePosition!.compareTo(second.queuePosition!);
  return byPosition != 0 ? byPosition : first.id.compareTo(second.id);
}
