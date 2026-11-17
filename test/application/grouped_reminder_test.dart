import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/group_reminder_key.dart';
import 'package:alambic/application/notifications/notification_action.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/notifications/review_prompt.dart';
import 'package:alambic/application/reviews/review_providers.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/domain/notifications/grouped_reminder_action.dart';
import 'package:alambic/domain/notifications/notification_mode.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';

import '../support/fake_notifications.dart';
import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late NotificationHarness harness;
  late GroupReminderKey capitals;

  setUp(() async {
    database = openTestDatabase();
    harness = NotificationHarness(database, FixedClock(sampleNow));
    capitals = GroupReminderKey(
      await seedSampleData(SampleServices(database, harness.clock)),
    );
  });

  tearDown(() async {
    harness.dispose();
    await database.close();
  });

  /// Switches the app to grouped reminders.
  Future<void> groupReminders(GroupedReminderAction action) async {
    final settings = NotificationSettingsRepository(database);
    await settings.saveReminderSettings(
      (await settings.loadReminderSettings()).copyWith(
        notificationMode: NotificationMode.grouped,
        groupedAction: action,
      ),
    );
  }

  Future<void> dispatchAt(DateTime now) async {
    harness.clock.now = now;
    await harness.read(notificationDispatcherProvider).dispatchDue();
  }

  NotificationActionHandlerTester handler() =>
      NotificationActionHandlerTester(harness);

  test('announces the due cards of a group in a single reminder', () async {
    await groupReminders(GroupedReminderAction.openApp);
    await dispatchAt(DateTime(2026, 11, 10, 12));
    final reminder = harness.presenter.groupReminders[capitals]!;
    expect(reminder.groupName, 'Capitales');
    expect(reminder.count, 4);
    expect(reminder.chain, isFalse);
    expect(reminder.alert, isTrue);
    // Every group has its reminder, no card is notified on its own.
    expect(harness.presenter.groupReminders, hasLength(3));
    expect(harness.presenter.prompts, isEmpty);
  });

  test('refreshes the count after an answer in the app, then closes', () async {
    await groupReminders(GroupedReminderAction.openApp);
    await dispatchAt(DateTime(2026, 11, 10, 12));
    final due = [
      for (final card in await CardRepository(
        database,
      ).getCardsOfGroup(capitals.groupId))
        if (card.dueAt == DateTime(2026, 11, 10, 12)) card,
    ];
    expect(due, hasLength(4));
    for (final (index, item) in due.indexed) {
      await harness
          .read(reviewServiceProvider)
          .answer(item.id, ReviewOutcome.correct, source: ReviewSource.session);
      if (index < 3) {
        expect(harness.presenter.groupReminders[capitals]!.count, 3 - index);
        expect(harness.presenter.groupReminders[capitals]!.alert, isFalse);
      }
    }
    expect(harness.presenter.groupReminders, isNot(contains(capitals)));
  });

  group('chained in the notification', () {
    setUp(() async {
      await groupReminders(GroupedReminderAction.chainInNotification);
      await dispatchAt(DateTime(2026, 11, 10, 12));
    });

    test('offers to start, then asks each card in turn', () async {
      expect(harness.presenter.groupReminders[capitals]!.chain, isTrue);
      await handler().start(capitals);
      expect(harness.presenter.groupReminders, isNot(contains(capitals)));
      final first = handler().chained(capitals);
      expect(first.prompt, 'Mongolie');
      expect(first.chainRemaining, 4);
      await handler().answer(first.key, NotificationAction.correct);
      final second = handler().chained(capitals);
      expect(second.prompt, 'Pérou');
      expect(second.chainRemaining, 3);
      // "Reveal" keeps the card and its count, then its answer moves on.
      await handler().answer(second.key, NotificationAction.reveal);
      final revealed = handler().chained(capitals);
      expect(revealed.isRevealed, isTrue);
      expect(revealed.answer, 'Lima');
      expect(revealed.chainRemaining, 3);
      await handler().answer(second.key, NotificationAction.again);
      expect(handler().chained(capitals).isRevealed, isFalse);
      expect(handler().chained(capitals).chainRemaining, 2);
      await handler().answer(
        handler().chained(capitals).key,
        NotificationAction.correct,
      );
      await handler().answer(
        handler().chained(capitals).key,
        NotificationAction.correct,
      );
      expect(
        harness.presenter.prompts.keys.where((key) => key.chain == capitals),
        isEmpty,
      );
      expect(harness.presenter.groupReminders, isNot(contains(capitals)));
    });

    test('a chained card answered in the app gives way to the next', () async {
      await handler().start(capitals);
      final first = handler().chained(capitals);
      await harness
          .read(reviewServiceProvider)
          .answer(
            first.key.cardId,
            ReviewOutcome.correct,
            source: ReviewSource.session,
          );
      expect(handler().chained(capitals).prompt, 'Pérou');
    });
  });
}

/// Presses the buttons of the fake notifications.
class NotificationActionHandlerTester {
  NotificationActionHandlerTester(this.harness);

  final NotificationHarness harness;

  Future<void> start(GroupReminderKey key) => harness
      .read(notificationActionHandlerProvider)
      .handleGroup(key, NotificationAction.start);

  Future<void> answer(ReviewNotificationKey key, NotificationAction action) =>
      harness.read(notificationActionHandlerProvider).handle(key, action);

  /// The card currently chained in the reminder of [key].
  ReviewPrompt chained(GroupReminderKey key) => harness
      .presenter
      .prompts
      .entries
      .singleWhere((entry) => entry.key.chain == key)
      .value;
}
