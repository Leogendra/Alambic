import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/application/notifications/notification_action.dart';
import 'package:remanence/application/notifications/notification_providers.dart';
import 'package:remanence/application/notifications/review_notification_key.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/review_repository.dart';
import 'package:remanence/domain/cards/direction_sense.dart';
import 'package:remanence/domain/reviews/review_source.dart';
import 'package:remanence/domain/scheduling/clock_time.dart';

import '../support/fake_notifications.dart';
import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  late NotificationHarness harness;
  late int capitals;

  setUp(() async {
    database = openTestDatabase();
    harness = NotificationHarness(database, FixedClock(sampleNow));
    capitals = await seedSampleData(SampleServices(database, harness.clock));
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
      expect(mongolia.step, isNull);
      expect(mongolia.sequenceLength, 6);
      harness.presenter.prompts.clear();
      await dispatchAt(DateTime(2026, 11, 10, 12, 1));
      expect(harness.presenter.prompts, isEmpty);
    });

    test('drops reminders found more than an hour late', () async {
      await dispatchAt(DateTime(2026, 11, 10, 13, 30));
      expect(harness.presenter.prompts, isEmpty);
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
}
