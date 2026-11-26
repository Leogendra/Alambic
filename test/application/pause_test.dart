import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/distillation/distillation_providers.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/reviews/review_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../support/fake_notifications.dart';
import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// The pause of a distillation holds back its new cards only: the reminders
/// go on, no due date moves, and a missed batch is not caught up. The global
/// pause also stops the notifications and moves the due dates forward by
/// the days it lasts.
void main() {
  late AlambicDatabase database;
  late NotificationHarness harness;
  late int verbs;

  setUp(() async {
    database = openTestDatabase();
    harness = NotificationHarness(database, FixedClock(sampleNow));
    final services = SampleServices(database, harness.clock);
    await seedSampleData(services);
    verbs = await services.groups.create('Verbs');
    for (final verb in ['be', 'have', 'go', 'do']) {
      await services.card(verb, verb, groupId: verbs);
    }
    await NotificationSettingsRepository(
      database,
    ).saveGuards(NotificationGuards.defaults.copyWith(autoGroupEnabled: false));
  });

  tearDown(() async {
    harness.dispose();
    await database.close();
  });

  Future<void> moveTo(DateTime now) async => harness.clock.now = now;

  Future<void> dispatchAt(DateTime now) async {
    await moveTo(now);
    await harness.read(notificationDispatcherProvider).dispatchDue();
  }

  /// Distills Verbs, one card a day: "be" comes out today.
  Future<void> activate() => harness
      .read(distillationServiceProvider)
      .activate(verbs, const DistillationSettings(prioritizeReviews: false));

  Future<void> advance() => harness.read(distillationServiceProvider).advance();

  Future<List<String?>> introduced() async => [
    for (final card in await CardRepository(database).getCardsOfGroup(verbs))
      if (card.isScheduled) card.frontText,
  ];

  Future<Map<String?, DateTime?>> dueDates() async => {
    for (final card in await CardRepository(database).getAll())
      card.frontText: card.dueAt,
  };

  group('a paused distillation', () {
    test('keeps notifying its cards, and moves no due date', () async {
      await activate();
      await harness.read(distillationServiceProvider).pause(verbs);
      final before = await dueDates();
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(
        harness.presenter.prompts.values.map((prompt) => prompt.prompt),
        containsAll(['be', 'Mongolia']),
      );
      await moveTo(DateTime(2026, 11, 14, 9));
      await harness.read(distillationServiceProvider).resume(verbs);
      final after = await dueDates();
      expect(after['be'], before['be']);
      expect(after['Laos'], DateTime(2026, 11, 10, 12));
    });

    test('brings a single batch on resume, then one a day again', () async {
      await activate();
      await harness.read(distillationServiceProvider).pause(verbs);
      await moveTo(DateTime(2026, 11, 17, 9));
      await advance();
      expect(await introduced(), ['be']);
      await harness.read(distillationServiceProvider).resume(verbs);
      expect(await introduced(), ['be', 'have']);
      await moveTo(DateTime(2026, 11, 18, 9));
      await advance();
      expect(await introduced(), ['be', 'have', 'go']);
    });

    test('resumed on a day already processed waits for the next', () async {
      await activate();
      await harness.read(distillationServiceProvider).pause(verbs);
      await harness.read(distillationServiceProvider).resume(verbs);
      expect(await introduced(), ['be']);
    });
  });

  group('the global pause', () {
    Future<DateTime?> dueAt(String front) async => (await dueDates())[front];

    test('withdraws the notifications and shows none until it ends', () async {
      await activate();
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(harness.presenter.prompts, hasLength(8));
      await harness.read(distillationServiceProvider).pauseAll();
      expect(harness.presenter.prompts, isEmpty);
      expect(harness.alarms.scheduled.values, [
        DateTime(2026, 11, 11, 4),
      ], reason: 'a single wake-up, to move the due dates the next day');
      await dispatchAt(DateTime(2026, 11, 11, 4));
      await dispatchAt(DateTime(2026, 11, 11, 12));
      expect(harness.presenter.prompts, isEmpty);
      expect(harness.alarms.scheduled.values, [DateTime(2026, 11, 12, 4)]);
    });

    test('moves the due dates forward one day per day of pause', () async {
      await activate();
      await harness.read(distillationServiceProvider).pauseAll();
      await moveTo(DateTime(2026, 11, 13, 9));
      await advance();
      expect(await dueAt('Laos'), DateTime(2026, 11, 13, 12));
      expect(await dueAt('be'), DateTime(2026, 11, 13, 12));
      expect(await introduced(), ['be']);
      await moveTo(DateTime(2026, 11, 15, 9));
      await harness.read(distillationServiceProvider).resumeAll();
      expect(await dueAt('Laos'), DateTime(2026, 11, 15, 12));
      expect(await introduced(), ['be', 'have']);
      expect(await dueAt('go'), isNull);
      await dispatchAt(DateTime(2026, 11, 15, 12));
      expect(
        harness.presenter.prompts.values.map((prompt) => prompt.prompt),
        containsAll(['Laos', 'be', 'have']),
      );
    });

    test('moves no due date when it ends on the day it started', () async {
      await harness.read(distillationServiceProvider).pauseAll();
      await moveTo(DateTime(2026, 11, 11, 3));
      await advance();
      await harness.read(distillationServiceProvider).resumeAll();
      expect(await dueAt('Laos'), DateTime(2026, 11, 10, 12));
    });

    test('moves a card reviewed during the pause with the others', () async {
      await harness.read(distillationServiceProvider).pauseAll();
      await moveTo(DateTime(2026, 11, 12, 9));
      await advance();
      final laos = (await CardRepository(
        database,
      ).getAll()).firstWhere((card) => card.frontText == 'Laos');
      await harness
          .read(reviewServiceProvider)
          .answer(laos.id, ReviewOutcome.correct, source: ReviewSource.session);
      final reviewedDue = (await dueAt('Laos'))!;
      expect(reviewedDue.isAfter(DateTime(2026, 11, 12, 12)), isTrue);
      await moveTo(DateTime(2026, 11, 14, 9));
      await harness.read(distillationServiceProvider).resumeAll();
      expect(
        await dueAt('Laos'),
        const SchedulingCalendar().addDaysTo(reviewedDue, 2),
      );
    });

    test('leaves a distillation paused on its own paused', () async {
      await activate();
      await harness.read(distillationServiceProvider).pause(verbs);
      await harness.read(distillationServiceProvider).pauseAll();
      await moveTo(DateTime(2026, 11, 12, 9));
      await harness.read(distillationServiceProvider).resumeAll();
      expect(await introduced(), ['be']);
      expect(
        (await DistillationRepository(database).find(verbs))!.pausedAt,
        sampleNow,
      );
    });
  });
}
