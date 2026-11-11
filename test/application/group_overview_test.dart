import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/application/groups/group_overview.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/group_repository.dart';
import 'package:remanence/data/repositories/preset_repository.dart';
import 'package:remanence/domain/scheduling/due_policy.dart';
import 'package:remanence/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  late SampleServices services;
  const overview = GroupOverview(DuePolicy(SchedulingCalendar()));

  setUp(() {
    database = openTestDatabase();
    services = SampleServices(database, FixedClock(sampleNow));
  });

  tearDown(() => database.close());

  Future<List<int>> dueCounts(DateTime now) async {
    final summaries = overview.summarize(
      groups: await GroupRepository(database).watchAll().first,
      cards: await CardRepository(database).getAll(),
      catalog: await PresetRepository(database).loadCatalog(),
      now: now,
    );
    return summaries.map((summary) => summary.dueCount).toList();
  }

  test('lists "Sans groupe" first, then the groups by name', () async {
    await seedSampleData(services);
    final summaries = overview.summarize(
      groups: await GroupRepository(database).watchAll().first,
      cards: await CardRepository(database).getAll(),
      catalog: await PresetRepository(database).loadCatalog(),
      now: sampleNow,
    );
    expect(summaries.map((summary) => summary.group?.name), [
      null,
      'Capitales',
      'Espagnol',
    ]);
    expect(summaries.map((summary) => summary.cardCount), [1, 4, 2]);
    expect(summaries.map((summary) => summary.activeCount), [1, 4, 2]);
  });

  test('counts the cards due today, suspended ones excluded', () async {
    final capitals = await seedSampleData(services);
    final cards = await CardRepository(database)
        .watchCardsOfGroup(capitals)
        .first;
    await services.cards.setSuspended(cards.first.card.id, suspended: true);
    expect(await dueCounts(sampleNow), [1, 3, 2]);
  });

  test('cards created after the slot are not due before tomorrow', () async {
    services.clock.now = DateTime(2026, 11, 10, 15);
    await seedSampleData(services);
    expect(await dueCounts(DateTime(2026, 11, 10, 16)), [0, 0, 0]);
    expect(await dueCounts(DateTime(2026, 11, 11, 8)), [1, 4, 2]);
  });
}
