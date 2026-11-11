import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/data/repositories/card_repository.dart';
import 'package:remanence/data/repositories/group_repository.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late RemanenceDatabase database;
  late SampleServices services;

  setUp(() {
    database = openTestDatabase();
    services = SampleServices(database, FixedClock(sampleNow));
  });

  tearDown(() => database.close());

  test('creates and renames a group, trimming its name', () async {
    final id = await services.groups.create('  Capitales ');
    await services.groups.rename(id, 'Capitales du monde');
    final group = await GroupRepository(database).watchById(id).first;
    expect(group!.name, 'Capitales du monde');
  });

  test('refuses an empty name', () {
    expect(() => services.groups.create('  '), throwsArgumentError);
  });

  test('deleting a group keeps its cards in "Sans groupe"', () async {
    final capitals = await seedSampleData(services);
    await services.groups.delete(capitals);
    final withoutGroup = await CardRepository(database)
        .watchCardsOfGroup(null)
        .first;
    expect(withoutGroup, hasLength(5));
  });
}
