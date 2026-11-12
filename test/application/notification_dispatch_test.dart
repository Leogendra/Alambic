import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/notification_action.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/reviews/review_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';
import 'package:alambic/domain/presets/schedule_kind.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';
import 'package:alambic/domain/reviews/typed_answer_match.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/direction_progress.dart';

import '../support/fake_notifications.dart';
import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late NotificationHarness harness;
  late int capitals;

  setUp(() async {
    database = openTestDatabase();
    harness = NotificationHarness(database, FixedClock(sampleNow));
    capitals = await seedSampleData(SampleServices(database, harness.clock));
    // The seven cards due at noon are notified one by one.
    await NotificationSettingsRepository(
      database,
    ).saveGuards(NotificationGuards.defaults.copyWith(autoGroupEnabled: false));
  });

  tearDown(() async {
    harness.dispose();
    await database.close();
  });

  Future<int> mongoliaFront() async {
    final cards = await CardRepository(database).getCardsOfGroup(capitals);
    return cards.first.direction(DirectionSense.frontToBack)!.id;
  }

  Future<void> dispatchAt(DateTime now) async {
    harness.clock.now = now;
    await harness.read(notificationDispatcherProvider).dispatchDue();
  }

  group('at the slot', () {
    test('shows each due card once, with its group and step', () async {
      await dispatchAt(DateTime(2026, 11, 10, 12));
      final prompts = harness.presenter.prompts.values;
      expect(prompts, hasLength(7));
      final mongolia = harness
          .presenter
          .prompts[ReviewNotificationKey(directionId: await mongoliaFront())]!;
      expect(mongolia.prompt, 'Mongolie');
      expect(mongolia.groupName, 'Capitales');
      expect(mongolia.progress, isA<NewProgress>());
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 10, 12, 1));
      expect(harness.presenter.prompts, isEmpty);
    });

    test('drops reminders found more than an hour late', () async {
      await dispatchAt(DateTime(2026, 11, 10, 13, 30));
      expect(harness.presenter.prompts, isEmpty);
    });

    test('notifies an ignored card again the next day, at the slot', () async {
      await dispatchAt(DateTime(2026, 11, 10, 12));
      final mongolia = ReviewNotificationKey(
        directionId: await mongoliaFront(),
      );
      expect(harness.presenter.prompts.keys, contains(mongolia));
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 10, 18));
      expect(harness.presenter.prompts, isEmpty);
      expect(
        harness.alarms.scheduled.values,
        contains(DateTime(2026, 11, 11, 12)),
      );
      await dispatchAt(DateTime(2026, 11, 11, 12));
      expect(harness.presenter.prompts.keys, contains(mongolia));
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 11, 12, 30));
      expect(harness.presenter.prompts.keys, isNot(contains(mongolia)));
    });

    test('notifies the next day a card not shown for being late', () async {
      await dispatchAt(DateTime(2026, 11, 10, 13, 30));
      await dispatchAt(DateTime(2026, 11, 11, 12));
      expect(
        harness.presenter.prompts.keys,
        contains(ReviewNotificationKey(directionId: await mongoliaFront())),
      );
    });

    test('shows a Review soon reminder as a bonus', () async {
      final direction = await mongoliaFront();
      final reminderId = await SampleServices(database, harness.clock).reminders
          .add(direction, DateTime(2026, 11, 10), const ClockTime(18, 0));
      await dispatchAt(DateTime(2026, 11, 10, 18));
      final key = ReviewNotificationKey(
        directionId: direction,
        extraReminderId: reminderId,
      );
      expect(harness.presenter.prompts.keys, [key]);
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.correct);
      final history = await ReviewRepository(database)
          .watchHistory(direction)
          .first;
      expect(history.single.isBonus, isTrue);
    });
  });

  group('answering from the notification', () {
    late ReviewNotificationKey key;

    setUp(() async {
      key = ReviewNotificationKey(directionId: await mongoliaFront());
      await dispatchAt(DateTime(2026, 11, 10, 12));
    });

    test('"Correct" records the answer and closes the notification', () async {
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.correct);
      final history = await ReviewRepository(database)
          .watchHistory(key.directionId)
          .first;
      expect(history.single.source, ReviewSource.notification);
      expect(history.single.isBonus, isFalse);
      expect(harness.presenter.prompts.containsKey(key), isFalse);
      expect(harness.presenter.reveals, isEmpty);
    });

    test('"Again" reveals the answer and the next review', () async {
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.again);
      final reveal = harness.presenter.reveals[key]!;
      expect(reveal.answer, 'Oulan-Bator');
      expect(reveal.result.isBonus, isFalse);
      expect(reveal.result.schedule!.dueAt, DateTime(2026, 11, 11, 12));
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.acknowledge);
      expect(harness.presenter.reveals, isEmpty);
    });

    test('a card deleted meanwhile only closes the notification', () async {
      final cardId = (await CardRepository(
        database,
      ).findDirection(key.directionId))!.cardId;
      await CardRepository(database).deleteCard(cardId);
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.correct);
      expect(harness.presenter.prompts.containsKey(key), isFalse);
    });
  });

  group('typed answer', () {
    late ReviewNotificationKey key;

    setUp(() async {
      final presets = PresetRepository(database);
      final catalog = await presets.loadCatalog();
      await presets.update(catalog.globalPreset.copyWith(typedAnswer: true));
      key = ReviewNotificationKey(directionId: await mongoliaFront());
      await dispatchAt(DateTime(2026, 11, 10, 12));
    });

    test('asks for an answer when the answer face has text', () {
      expect(harness.presenter.prompts[key]!.typedAnswer, isTrue);
    });

    test('an answer with one typo counts as correct', () async {
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.answer, input: 'oulan bater');
      final reveal = harness.presenter.reveals[key]!;
      expect(reveal.match, TypedAnswerMatch.oneTypo);
      expect(reveal.answer, 'Oulan-Bator');
      final history = await ReviewRepository(database)
          .watchHistory(key.directionId)
          .first;
      expect(history.single.outcome, ReviewOutcome.correct);
      expect(reveal.result.schedule!.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('a wrong answer counts as a failure', () async {
      await harness
          .read(notificationActionHandlerProvider)
          .handle(key, NotificationAction.answer, input: 'Pékin');
      expect(harness.presenter.reveals[key]!.match, TypedAnswerMatch.wrong);
      final history = await ReviewRepository(database)
          .watchHistory(key.directionId)
          .first;
      expect(history.single.outcome, ReviewOutcome.again);
    });
  });

  test('spreads the cards of a time range over the range', () async {
    final services = SampleServices(database, harness.clock);
    final presets = PresetRepository(database);
    final standard = (await presets.loadCatalog()).globalPreset;
    final rangeId = await presets.insert(
      standard.copyWith(
        name: 'Journée',
        builtInKey: () => null,
        scheduleKind: ScheduleKind.timeRange,
        rangeStart: const ClockTime(9, 0),
        rangeEnd: const ClockTime(17, 0),
      ),
    );
    final verbs = await services.groups.create('Verbes');
    await GroupRepository(database).setPreset(verbs, rangeId);
    for (final verb in ['être', 'avoir', 'aller', 'faire']) {
      await services.card(verb, verb, groupId: verbs);
    }
    harness.clock.now = DateTime(2026, 11, 10, 8);
    await services.cards.startGroup(verbs);
    await harness.read(notificationPlannerProvider).replan();
    expect(
      harness.alarms.scheduled.values.where(
        (wakeUp) => wakeUp.day == 10 && wakeUp.hour < 17,
      ),
      containsAll([
        DateTime(2026, 11, 10, 9),
        DateTime(2026, 11, 10, 11),
        DateTime(2026, 11, 10, 13),
        DateTime(2026, 11, 10, 15),
      ]),
    );
    await dispatchAt(DateTime(2026, 11, 10, 9));
    await dispatchAt(DateTime(2026, 11, 10, 11));
    expect(
      harness.presenter.prompts.values
          .where((prompt) => prompt.groupName == 'Verbes')
          .map((prompt) => prompt.prompt),
      ['être', 'avoir'],
    );
  });

  group('safeguards', () {
    Future<void> setGuards(NotificationGuards guards) =>
        NotificationSettingsRepository(database).saveGuards(guards);

    test(
      'gathers the notifications of a moment beyond the threshold',
      () async {
        await setGuards(NotificationGuards.defaults);
        await dispatchAt(DateTime(2026, 11, 10, 12));
        expect(harness.presenter.prompts, isEmpty);
        final digest = harness.presenter.digest!;
        expect(digest.count, 7);
        expect(digest.groupNames, ['Capitales', 'Espagnol', null]);
        // Answered in the app, the cards leave the digest.
        final direction = await mongoliaFront();
        await harness
            .read(reviewServiceProvider)
            .answer(
              direction,
              ReviewOutcome.correct,
              source: ReviewSource.session,
            );
        expect(harness.presenter.digest!.count, 6);
        expect(harness.presenter.digest!.alert, isFalse);
      },
    );

    test('holds the cards beyond the daily cap until the next day', () async {
      await setGuards(
        NotificationGuards.defaults.copyWith(
          dailyCap: 4,
          autoGroupEnabled: false,
        ),
      );
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(harness.presenter.prompts, hasLength(4));
      expect(
        await NotificationSettingsRepository(database)
            .notifiedOn(DateTime(2026, 11, 10)),
        4,
      );
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 11, 12));
      // The three held back, then the reverse of Pérou due that day; the
      // four ignored the day before compete with them.
      expect(harness.presenter.prompts, hasLength(4));
    });

    test('moves a notification out of the quiet hours', () async {
      await setGuards(
        NotificationGuards.defaults.copyWith(
          quietStart: const ClockTime(11, 0),
          quietEnd: const ClockTime(13, 0),
          autoGroupEnabled: false,
        ),
      );
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(harness.presenter.prompts, isEmpty);
      await dispatchAt(DateTime(2026, 11, 10, 13));
      expect(harness.presenter.prompts, hasLength(7));
    });
  });
}
