import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/distillation/distillation_providers.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';

import '../support/fake_notifications.dart';
import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// A pause, of a distillation or global, holds back the new cards only: the
/// reminders go on, no due date moves, and a missed batch is not caught up.
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
    test('holds every distillation back, never the reminders', () async {
      await activate();
      await harness.read(distillationServiceProvider).pauseAll();
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(harness.presenter.prompts, hasLength(8));
      await moveTo(DateTime(2026, 11, 11, 9));
      await advance();
      expect(await introduced(), ['be']);
      expect(
        harness.alarms.scheduled.values.where((wakeUp) => wakeUp.hour == 4),
        isEmpty,
        reason: 'no wake-up for a distillation during the pause',
      );
      await moveTo(DateTime(2026, 11, 13, 9));
      await harness.read(distillationServiceProvider).resumeAll();
      expect(await introduced(), ['be', 'have']);
      expect((await dueDates())['Laos'], DateTime(2026, 11, 10, 12));
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
