import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/reviews/session_item_factory.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/groups/asked_sides.dart';

import '../support/fixed_clock.dart';
import '../support/fixed_random.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late FixedRandom random;
  late SessionItemFactory factory;

  setUp(() {
    database = openTestDatabase();
    samples = SampleServices(database, FixedClock(sampleNow));
    random = FixedRandom();
    factory = SessionItemFactory(
      cards: CardRepository(database),
      groups: GroupRepository(database),
      random: random,
    );
  });

  tearDown(() => database.close());

  test('asks the front of the cards of a group by default', () async {
    final groupId = await samples.groups.create('Capitals');
    final cardId = await samples.card('Peru', 'Lima', groupId: groupId);
    final items = await factory.itemsFor([cardId]);
    expect(items.single.askedSide, CardSide.front);
  });

  test('asks the back of the cards of a group set to the back', () async {
    final groupId = await samples.groups.create('Capitals');
    await samples.groups.setAskedSides(groupId, AskedSides.back);
    final cardId = await samples.card('Peru', 'Lima', groupId: groupId);
    random.coin = false;
    expect((await factory.itemsFor([cardId])).single.askedSide, CardSide.back);
  });

  test('draws the asked face of a group set to random, each time', () async {
    final groupId = await samples.groups.create('Capitals');
    await samples.groups.setAskedSides(groupId, AskedSides.random);
    final cardId = await samples.card('Peru', 'Lima', groupId: groupId);
    expect((await factory.itemsFor([cardId])).single.askedSide, CardSide.back);
    random.coin = false;
    expect((await factory.itemsFor([cardId])).single.askedSide, CardSide.front);
  });

  test('keeps the order of the cards and leaves out deleted ones', () async {
    final groupId = await samples.groups.create('Capitals');
    final first = await samples.card('Peru', 'Lima', groupId: groupId);
    final second = await samples.card('Laos', 'Vientiane', groupId: groupId);
    final deleted = await samples.card('Chile', 'Santiago', groupId: groupId);
    await samples.cards.delete(deleted);
    final items = await factory.itemsFor([second, deleted, first]);
    expect(items.map((item) => item.cardId), [second, first]);
  });
}
