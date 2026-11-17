import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/card_providers.dart';
import 'package:alambic/application/distillation/distillation_providers.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/reviews/review_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';

import '../support/fake_notifications.dart';
import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late NotificationHarness harness;

  setUp(() {
    database = openTestDatabase();
    harness = NotificationHarness(database, FixedClock(sampleNow));
  });

  tearDown(() async {
    harness.dispose();
    await database.close();
  });

  /// An introduced card, due today at 12:00.
  Future<int> startedCard() async {
    final services = SampleServices(database, harness.clock);
    final groupId = await services.groups.create('Capitales');
    final cardId = await services.card(
      'Mongolie',
      'Oulan-Bator',
      groupId: groupId,
    );
    await services.introduceAll(groupId);
    await harness.read(notificationPlannerProvider).replan();
    return cardId;
  }

  List<DateTime> scheduledMoments() =>
      harness.alarms.scheduled.values.toList()..sort();

  test('wakes the app up once per due moment', () async {
    await startedCard();
    await startedCard();
    expect(scheduledMoments(), [DateTime(2026, 11, 10, 12)]);
    expect(harness.alarms.exactById.values, everyElement(isTrue));
  });

  test(
    'a card reviewed before its slot drops the wake-up of the slot',
    () async {
      final cardId = await startedCard();
      harness.clock.now = DateTime(2026, 11, 10, 9, 30);
      await harness
          .read(reviewServiceProvider)
          .answer(cardId, ReviewOutcome.correct, source: ReviewSource.session);
      expect(scheduledMoments(), [DateTime(2026, 11, 11, 12)]);
    },
  );

  test('withdraws the notification of a card reviewed in the app', () async {
    final cardId = await startedCard();
    final key = ReviewNotificationKey(cardId: cardId);
    harness.clock.now = DateTime(2026, 11, 10, 12);
    await harness.read(notificationDispatcherProvider).dispatchDue();
    expect(harness.presenter.prompts.keys, [key]);
    await harness
        .read(reviewServiceProvider)
        .answer(
          key.cardId,
          ReviewOutcome.correct,
          source: ReviewSource.session,
        );
    expect(harness.presenter.prompts, isEmpty);
  });

  test('plans nothing for a suspended card', () async {
    final cardId = await startedCard();
    await harness
        .read(cardServiceProvider)
        .setSuspended(cardId, suspended: true);
    expect(harness.alarms.scheduled, isEmpty);
  });

  test('falls back to inexact alarms without the permission', () async {
    await startedCard();
    harness.alarms.exactAllowed = false;
    await harness.read(notificationPlannerProvider).replan(force: true);
    expect(harness.alarms.exactById.values, everyElement(isFalse));
  });

  test('schedules only what changed, unless forced', () async {
    await startedCard();
    final planner = harness.read(notificationPlannerProvider);
    final count = harness.alarms.scheduleCount;
    await planner.replan();
    expect(harness.alarms.scheduleCount, count);
    await planner.replan(force: true);
    expect(harness.alarms.scheduleCount, count + 1);
  });

  test('a distillation wakes the app up at the start of the next day, '
      'which introduces its next card', () async {
    final groupId = await SampleServices(
      database,
      harness.clock,
    ).groups.create('Capitales');
    final cards = harness.read(cardServiceProvider);
    final cardIds = [
      for (final country in ['Mongolie', 'Pérou'])
        await cards.create(
          CardDraft(frontText: country, backText: 'capitale', groupId: groupId),
        ),
    ];
    await harness
        .read(distillationServiceProvider)
        .activate(groupId, const DistillationSettings(prioritizeReviews: false));
    expect(scheduledMoments(), [
      DateTime(2026, 11, 10, 12),
      DateTime(2026, 11, 11, 4),
    ]);

    harness.clock.now = DateTime(2026, 11, 11, 4);
    await harness.read(notificationDispatcherProvider).dispatchDue();
    final second = await CardRepository(database).getCard(cardIds[1]);
    expect(second.state, CardState.active);
    expect(second.dueAt, DateTime(2026, 11, 11, 12));
    expect(harness.presenter.prompts, isEmpty);
    expect(scheduledMoments(), contains(DateTime(2026, 11, 11, 12)));
  });
}
