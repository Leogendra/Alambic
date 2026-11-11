import 'package:flutter_riverpod/misc.dart';
import 'package:remanence/application/cards/card_draft.dart';
import 'package:remanence/application/cards/card_service.dart';
import 'package:remanence/application/clock.dart';
import 'package:remanence/application/groups/group_service.dart';
import 'package:remanence/application/scheduling/ignored_schedule_changes.dart';
import 'package:remanence/application/time/minute_ticker.dart';
import 'package:remanence/data/data_providers.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/group_repository.dart';
import 'package:remanence/data/repositories/preset_repository.dart';
import 'package:remanence/domain/scheduling/review_scheduler.dart';
import 'package:remanence/domain/scheduling/scheduling_calendar.dart';

import 'fixed_clock.dart';

/// Moment at which sample data is created and screens are rendered:
/// Tuesday 10 November 2026, 9am.
final DateTime sampleNow = DateTime(2026, 11, 10, 9);

/// Services over [database], driven by [clock].
class SampleServices {
  SampleServices(this.database, this.clock)
    : cards = CardService(
        cards: CardRepository(database),
        presets: PresetRepository(database),
        scheduler: const ReviewScheduler(SchedulingCalendar()),
        clock: clock.call,
        scheduleChangeListener: const IgnoredScheduleChanges(),
      ),
      groups = GroupService(
        groups: GroupRepository(database),
        clock: clock.call,
      );

  final RemanenceDatabase database;
  final FixedClock clock;
  final CardService cards;
  final GroupService groups;

  Future<int> card(
    String front,
    String back, {
    int? groupId,
    bool alsoReverse = false,
  }) => cards.create(
    CardDraft(
      frontText: front,
      backText: back,
      groupId: groupId,
      presetId: null,
      alsoReverse: alsoReverse,
    ),
  );
}

/// A "Capitales" group of four cards, a "Espagnol" group of two, and one
/// card outside any group. Returns the id of "Capitales".
Future<int> seedSampleData(SampleServices services) async {
  final capitals = await services.groups.create('Capitales');
  final spanish = await services.groups.create('Espagnol');
  await services.card('Mongolie', 'Oulan-Bator', groupId: capitals);
  await services.card('Pérou', 'Lima', groupId: capitals, alsoReverse: true);
  await services.card('Laos', 'Vientiane', groupId: capitals);
  await services.card('Myanmar', 'Naypyidaw', groupId: capitals);
  await services.card('manger', 'comer', groupId: spanish);
  await services.card('boire', 'beber', groupId: spanish);
  await services.card('Mitochondrie', 'Centrale énergétique de la cellule');
  return capitals;
}

/// Overrides rendering screens over [database] at the fixed moment [now].
List<Override> screenOverrides(RemanenceDatabase database, DateTime now) => [
  databaseProvider.overrideWithValue(database),
  clockProvider.overrideWithValue(() => now),
  currentMomentProvider.overrideWith((ref) => Stream.value(now)),
];
