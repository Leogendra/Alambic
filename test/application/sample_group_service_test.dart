import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/groups/sample_group_service.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/data/samples/sample_group.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  const SampleEdition englishCapitals = (
    sample: SampleGroup.capitals,
    languageCode: 'en',
  );
  const SampleEdition frenchCapitals = (
    sample: SampleGroup.capitals,
    languageCode: 'fr',
  );
  late AlambicDatabase database;
  late SampleGroupService samples;

  setUp(() {
    database = openTestDatabase();
    final services = SampleServices(database, FixedClock(sampleNow));
    samples = SampleGroupService(
      groups: services.groups,
      cards: services.cards,
      loadCards: (edition) =>
          File(edition.sample.assetFor(edition.languageCode)).readAsString(),
    );
  });

  tearDown(() => database.close());

  test('every edition of the catalog has its cards', () async {
    for (final edition in SampleGroup.editions) {
      expect(await samples.cards(edition), isNotEmpty, reason: '$edition');
    }
  });

  test('reads the capitals of the language, in order', () async {
    final english = await samples.cards(englishCapitals);
    expect(english, hasLength(197));
    expect((english.first.front, english.first.back), ('Afghanistan', 'Kabul'));
    expect((english.last.front, english.last.back), ('Zimbabwe', 'Harare'));

    final french = await samples.cards(frenchCapitals);
    expect(french, hasLength(197));
    expect((french.first.front, french.first.back), ('Afghanistan', 'Kaboul'));
    expect((french.last.front, french.last.back), ('Zimbabwé', 'Hararé'));
  });

  test('creates the group with its cards pending in order, on the global '
      'preset, without the back nor a distillation', () async {
    final groupId = await samples.createOrFind(
      englishCapitals,
      name: 'Capitals',
    );
    final group = await GroupRepository(database).watchById(groupId).first;
    expect(group!.name, 'Capitals');
    expect(
      group.presetId,
      (await PresetRepository(database).loadCatalog()).globalPresetId,
    );
    expect(group.reverseEnabled, isFalse);
    expect(await DistillationRepository(database).getAll(), isEmpty);
    final cards = await CardRepository(database).getCardsOfGroup(groupId)
      ..sort((a, b) => a.queuePosition!.compareTo(b.queuePosition!));
    expect(cards, hasLength(197));
    expect(cards.every((card) => card.isPending), isTrue);
    expect(cards.first.frontText, 'Afghanistan');
    expect(cards.last.frontText, 'Zimbabwe');
  });

  test('creates the cards in French for the French app', () async {
    final groupId = await samples.createOrFind(
      frenchCapitals,
      name: 'Capitales',
    );
    final cards = await CardRepository(database).getCardsOfGroup(groupId);
    final france = cards.singleWhere((card) => card.frontText == 'France');
    expect(france.backText, 'Paris');
    final germany = cards.singleWhere((card) => card.frontText == 'Allemagne');
    expect(germany.backText, 'Berlin');
  });

  test('returns the group already named so, without adding any card', () async {
    final first = await samples.createOrFind(englishCapitals, name: 'Capitals');
    final second = await samples.createOrFind(
      englishCapitals,
      name: 'Capitals',
    );
    expect(second, first);
    expect(await GroupRepository(database).watchAll().first, hasLength(1));
    expect(
      await CardRepository(database).getCardsOfGroup(first),
      hasLength(197),
    );
  });
}
