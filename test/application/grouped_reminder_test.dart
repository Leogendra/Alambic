import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/notifications/group_reminder_key.dart';
import 'package:alambic/application/notifications/notification_action.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/notifications/review_notification_key.dart';
import 'package:alambic/application/notifications/review_prompt.dart';
import 'package:alambic/application/reviews/review_providers.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/presets/grouped_reminder_action.dart';
import 'package:alambic/domain/presets/notification_mode.dart';
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

  /// Gives "Capitales" a copy of Standard with a grouped reminder.
  Future<void> groupCapitals(GroupedReminderAction action) async {
    final presets = PresetRepository(database);
    final standard = (await presets.loadCatalog()).globalPreset;
    final presetId = await presets.insert(
      standard.copyWith(
        name: 'Groupé',
        builtInKey: () => null,
        notificationMode: NotificationMode.grouped,
        groupedAction: action,
      ),
    );
    await GroupRepository(database).setPreset(capitals.groupId!, presetId);
  }

  Future<void> dispatchAt(DateTime now) async {
    harness.clock.now = now;
    await harness.read(notificationDispatcherProvider).dispatchDue();
  }

  NotificationActionHandlerTester handler() =>
      NotificationActionHandlerTester(harness);

  test('announces the due cards of a group in a single reminder', () async {
    await groupCapitals(GroupedReminderAction.openApp);
    await dispatchAt(DateTime(2026, 11, 10, 12));
    final reminder = harness.presenter.groupReminders[capitals]!;
    expect(reminder.groupName, 'Capitales');
    expect(reminder.count, 4);
    expect(reminder.chain, isFalse);
    expect(reminder.alert, isTrue);
    // The two Spanish cards and the card outside any group stay per card.
    expect(harness.presenter.prompts, hasLength(3));
  });

  test('refreshes the count after an answer in the app, then closes', () async {
    await groupCapitals(GroupedReminderAction.openApp);
    await dispatchAt(DateTime(2026, 11, 10, 12));
    final due = [
      for (final card in await CardRepository(
        database,
      ).getCardsOfGroup(capitals.groupId))
        for (final direction in card.directions)
          if (direction.dueAt == DateTime(2026, 11, 10, 12)) direction,
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
    expect(harness.presenter.groupReminders, isEmpty);
  });

  group('chained in the notification', () {
    setUp(() async {
      await groupCapitals(GroupedReminderAction.chainInNotification);
      await dispatchAt(DateTime(2026, 11, 10, 12));
    });

    test('offers to start, then asks each card in turn', () async {
      expect(harness.presenter.groupReminders[capitals]!.chain, isTrue);
      await handler().start(capitals);
      expect(harness.presenter.groupReminders, isEmpty);
      final first = handler().chained(capitals);
      expect(first.prompt, 'Mongolie');
      expect(first.chainRemaining, 4);
      await handler().answer(first.key, NotificationAction.correct);
      final second = handler().chained(capitals);
      expect(second.prompt, 'Pérou');
      expect(second.chainRemaining, 3);
      await handler().answer(second.key, NotificationAction.again);
      expect(harness.presenter.reveals.keys.single.chain, capitals);
      await handler().answer(second.key, NotificationAction.acknowledge);
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
        harness.presenter.prompts.keys.where((key) => key.chain != null),
        isEmpty,
      );
      expect(harness.presenter.groupReminders, isEmpty);
    });

    test('a chained card answered in the app gives way to the next', () async {
      await handler().start(capitals);
      final first = handler().chained(capitals);
      await harness
          .read(reviewServiceProvider)
          .answer(
            first.key.directionId,
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
