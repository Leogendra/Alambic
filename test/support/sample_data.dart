import 'package:flutter_riverpod/misc.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/card_service.dart';
import 'package:alambic/application/clock.dart';
import 'package:alambic/application/distillation/distillation_service.dart';
import 'package:alambic/application/groups/group_service.dart';
import 'package:alambic/application/reminders/reminder_service.dart';
import 'package:alambic/application/reviews/review_service.dart';
import 'package:alambic/application/scheduling/ignored_schedule_changes.dart';
import 'package:alambic/application/time/minute_ticker.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/images/image_store.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/data/repositories/pause_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/data/repositories/reminder_repository.dart';
import 'package:alambic/data/repositories/review_repository.dart';
import 'package:alambic/domain/scheduling/due_policy.dart';
import 'package:alambic/domain/scheduling/review_scheduler.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import 'fixed_clock.dart';
import 'test_images.dart';

/// Moment at which sample data is created and screens are rendered:
/// Tuesday 10 November 2026, 9am.
final DateTime sampleNow = DateTime(2026, 11, 10, 9);

/// Services over [database], driven by [clock].
class SampleServices {
  factory SampleServices(
    AlambicDatabase database,
    FixedClock clock, {
    ImageStore? images,
  }) => SampleServices._(
    database,
    clock,
    images ?? openTestImageStore(),
    DistillationService(
      distillations: DistillationRepository(database),
      cards: CardRepository(database),
      settings: NotificationSettingsRepository(database),
      pauses: PauseRepository(database),
      scheduler: const ReviewScheduler(SchedulingCalendar()),
      calendar: const SchedulingCalendar(),
      clock: clock.call,
      scheduleChangeListener: const IgnoredScheduleChanges(),
    ),
  );

  SampleServices._(this.database, this.clock, this.images, this.distillations)
    : cards = CardService(
        cards: CardRepository(database),
        images: images,
        clock: clock.call,
        scheduleChangeListener: const IgnoredScheduleChanges(),
      ),
      groups = GroupService(
        groups: GroupRepository(database),
        cards: CardRepository(database),
        presets: PresetRepository(database),
        settings: NotificationSettingsRepository(database),
        images: images,
        scheduler: const ReviewScheduler(SchedulingCalendar()),
        clock: clock.call,
        scheduleChangeListener: const IgnoredScheduleChanges(),
      ),
      reviews = ReviewService(
        cards: CardRepository(database),
        presets: PresetRepository(database),
        settings: NotificationSettingsRepository(database),
        reviews: ReviewRepository(database),
        scheduler: const ReviewScheduler(SchedulingCalendar()),
        duePolicy: const DuePolicy(SchedulingCalendar()),
        clock: clock.call,
        scheduleChangeListener: const IgnoredScheduleChanges(),
      ),
      reminders = ReminderService(
        reminders: ReminderRepository(database),
        calendar: const SchedulingCalendar(),
        clock: clock.call,
        scheduleChangeListener: const IgnoredScheduleChanges(),
      );

  final AlambicDatabase database;
  final FixedClock clock;
  final ImageStore images;
  final DistillationService distillations;
  final CardService cards;
  final GroupService groups;
  final ReviewService reviews;
  final ReminderService reminders;

  /// A new card of [groupId], pending in its queue.
  Future<int> card(String front, String back, {required int groupId}) => cards
      .create(CardDraft(frontText: front, backText: back, groupId: groupId));

  /// Introduces every pending card of [groupId] now, as a distillation would
  /// have done earlier: each becomes due today at the daily slot. Lets a
  /// test start from introduced cards without running distillations.
  Future<void> introduceAll(int groupId) async {
    final repository = CardRepository(database);
    final reminders = await NotificationSettingsRepository(database)
        .loadReminderSettings();
    for (final card in await repository.getCardsOfGroup(groupId)) {
      if (card.isPending) {
        await repository.applySchedule(
          card.id,
          const ReviewScheduler(SchedulingCalendar())
              .introduction(dailySlot: reminders.dailySlot, now: clock()),
        );
      }
    }
  }
}

/// A "Capitales" group of four cards, a "Espagnol" group of two and a
/// "Biologie" group of one, all introduced. Returns the id of "Capitales".
Future<int> seedSampleData(SampleServices services) async {
  final capitals = await services.groups.create('Capitales');
  final spanish = await services.groups.create('Espagnol');
  final biology = await services.groups.create('Biologie');
  await services.card('Mongolie', 'Oulan-Bator', groupId: capitals);
  await services.card('Pérou', 'Lima', groupId: capitals);
  await services.card('Laos', 'Vientiane', groupId: capitals);
  await services.card('Myanmar', 'Naypyidaw', groupId: capitals);
  await services.card('manger', 'comer', groupId: spanish);
  await services.card('boire', 'beber', groupId: spanish);
  await services.card(
    'Mitochondrie',
    'Centrale énergétique de la cellule',
    groupId: biology,
  );
  for (final groupId in [capitals, spanish, biology]) {
    await services.introduceAll(groupId);
  }
  return capitals;
}

/// Overrides rendering screens over [database] at the fixed moment [now].
List<Override> screenOverrides(
  AlambicDatabase database,
  DateTime now, {
  ImageStore? images,
}) => [
  databaseProvider.overrideWithValue(database),
  imageStoreProvider.overrideWithValue(images ?? openTestImageStore()),
  clockProvider.overrideWithValue(() => now),
  currentMomentProvider.overrideWith((ref) => Stream.value(now)),
];
