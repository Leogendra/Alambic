import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/groups/group_overview.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/scheduling/due_policy.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
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

  test('lists the groups by name', () async {
    await seedSampleData(services);
    final summaries = overview.summarize(
      groups: await GroupRepository(database).watchAll().first,
      cards: await CardRepository(database).getAll(),
      catalog: await PresetRepository(database).loadCatalog(),
      now: sampleNow,
    );
    expect(summaries.map((summary) => summary.group.name), [
      'Biologie',
      'Capitales',
      'Espagnol',
    ]);
    expect(summaries.map((summary) => summary.cardCount), [1, 4, 2]);
  });

  test('counts a pending card, never due', () async {
    final groupId = await services.groups.create('Capitales');
    await services.card('Laos', 'Vientiane', groupId: groupId);
    final summary = overview.summarizeOne(
      (await GroupRepository(database).find(groupId))!,
      await CardRepository(database).getAll(),
      await PresetRepository(database).loadCatalog(),
      sampleNow,
    );
    expect(summary.cardCount, 1);
    expect(summary.dueCount, 0);
  });

  test('counts the cards due today, suspended ones excluded', () async {
    final capitals = await seedSampleData(services);
    final cards = await CardRepository(database)
        .watchCardsOfGroup(capitals)
        .first;
    await services.cards.setSuspended(cards.first.id, suspended: true);
    expect(await dueCounts(sampleNow), [1, 3, 2]);
  });

  test('cards introduced after the slot are due at once', () async {
    services.clock.now = DateTime(2026, 11, 10, 15);
    await seedSampleData(services);
    expect(await dueCounts(DateTime(2026, 11, 10, 16)), [1, 4, 2]);
  });
}
