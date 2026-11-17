import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/draft_image.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
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

  test('deleting a group deletes its cards', () async {
    final capitals = await seedSampleData(services);
    await services.groups.delete(capitals);
    final cards = await CardRepository(database).getAll();
    expect(cards, hasLength(3));
    expect(cards.where((card) => card.groupId == capitals), isEmpty);
  });

  test('deleting a group deletes the images of its cards', () async {
    final flags = await services.groups.create('Drapeaux');
    final other = await services.groups.create('Autres');
    final cardId = await services.cards.create(
      CardDraft(
        frontText: '',
        backText: 'Pérou',
        frontImage: const PickedImage('test/support/fixtures/flag.png'),
        groupId: other,
      ),
    );
    final card = await CardRepository(database).getCard(cardId);
    await services.cards.update(
      cardId,
      CardDraft(
        frontText: '',
        backText: 'Pérou',
        frontImage: StoredImage(card.frontImagePath!),
        groupId: flags,
      ),
    );
    final file = File(services.images.pathOf(card.frontImagePath!));
    expect(file.existsSync(), isTrue);
    await services.groups.delete(flags);
    expect(file.existsSync(), isFalse);
  });
}
