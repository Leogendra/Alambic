import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/distillation/distillation_providers.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/pauses/pause_providers.dart';
import 'package:alambic/application/reviews/review_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';

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
    await NotificationSettingsRepository(
      database,
    ).saveGuards(NotificationGuards.defaults.copyWith(autoGroupEnabled: false));
  });

  tearDown(() async {
    harness.dispose();
    await database.close();
  });

  Future<void> dispatchAt(DateTime now) async {
    harness.clock.now = now;
    await harness.read(notificationDispatcherProvider).dispatchDue();
  }

  /// Due date of each direction of a group, keyed "front sense".
  Future<Map<String, DateTime?>> dueDates(int? groupId) async => {
    for (final card in await CardRepository(database).getCardsOfGroup(groupId))
      for (final direction in card.directions)
        '${card.card.frontText} ${direction.sense.name}': direction.dueAt,
  };

  group('a paused group', () {
    test('is not notified, the other groups are', () async {
      await harness.read(pauseServiceProvider).pauseGroup(capitals);
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(
        harness.presenter.prompts.values.map((prompt) => prompt.groupName),
        isNot(contains('Capitales')),
      );
      expect(harness.presenter.prompts, hasLength(3));
    });

    test('shifts its due dates by the pause on resume', () async {
      final before = await dueDates(capitals);
      await harness.read(pauseServiceProvider).pauseGroup(capitals);
      // A card answered during the pause keeps the date chosen then.
      harness.clock.now = DateTime(2026, 11, 11, 9);
      final mongolia = (await CardRepository(
        database,
      ).getCardsOfGroup(capitals)).first.direction(DirectionSense.frontToBack)!;
      await harness
          .read(reviewServiceProvider)
          .answer(
            mongolia.id,
            ReviewOutcome.correct,
            source: ReviewSource.session,
          );
      final answered = (await dueDates(capitals))['Mongolie frontToBack'];
      harness.clock.now = DateTime(2026, 11, 14, 9);
      await harness.read(pauseServiceProvider).resumeGroup(capitals);
      final after = await dueDates(capitals);
      expect(after['Mongolie frontToBack'], answered);
      expect(after['Laos frontToBack'], DateTime(2026, 11, 14, 12));
      expect(
        after['Pérou backToFront'],
        DateTime(2026, 11, 15, 12),
        reason: 'due on the 11th, shifted by 4 days',
      );
      expect(before['Pérou backToFront'], DateTime(2026, 11, 11, 12));
      expect((await PauseRepository(database).loadPauses()).groupsSince, {});
    });

    test('holds its distillation until the end of the pause', () async {
      final services = SampleServices(database, harness.clock);
      final verbs = await services.groups.create('Verbes');
      for (final verb in ['être', 'avoir', 'aller']) {
        await services.card(verb, verb, groupId: verbs);
      }
      await harness
          .read(distillationServiceProvider)
          .launchForGroup(
            verbs,
            DirectionSense.frontToBack,
            const DistillationSettings(avoidCollisions: false),
          );
      await harness.read(pauseServiceProvider).pauseGroup(verbs);
      harness.clock.now = DateTime(2026, 11, 11, 9);
      await harness.read(distillationServiceProvider).advance();
      Future<List<String?>> introduced() async => [
        for (final card in await CardRepository(
          database,
        ).getCardsOfGroup(verbs))
          if (card.direction(DirectionSense.frontToBack)!.isScheduled)
            card.card.frontText,
      ];
      expect(await introduced(), ['être']);
      await harness.read(pauseServiceProvider).resumeGroup(verbs);
      await harness.read(distillationServiceProvider).advance();
      expect(await introduced(), ['être', 'avoir']);
    });
  });

  group('the global pause', () {
    test('silences everything until it ends', () async {
      await harness.read(pauseServiceProvider).pauseAll();
      await dispatchAt(DateTime(2026, 11, 10, 12));
      expect(harness.presenter.prompts, isEmpty);
      harness.clock.now = DateTime(2026, 11, 12, 9);
      await harness.read(pauseServiceProvider).resumeAll();
      expect(
        (await dueDates(null))['Mitochondrie frontToBack'],
        DateTime(2026, 11, 12, 12),
      );
      await dispatchAt(DateTime(2026, 11, 12, 12));
      expect(harness.presenter.prompts, hasLength(7));
    });

    test(
      'leaves the groups still paused on their own to their resume',
      () async {
        final before = await dueDates(capitals);
        await harness.read(pauseServiceProvider).pauseGroup(capitals);
        await harness.read(pauseServiceProvider).pauseAll();
        harness.clock.now = DateTime(2026, 11, 12, 9);
        await harness.read(pauseServiceProvider).resumeAll();
        expect(await dueDates(capitals), before);
        harness.clock.now = DateTime(2026, 11, 13, 9);
        await harness.read(pauseServiceProvider).resumeGroup(capitals);
        expect(
          (await dueDates(capitals))['Laos frontToBack'],
          DateTime(2026, 11, 13, 12),
        );
      },
    );
  });
}
