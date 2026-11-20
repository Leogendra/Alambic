import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/onboarding/sample_group_service.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/distillation_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/samples/bundled_sample_cards.dart';

import '../support/fixed_clock.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late SampleGroupService samples;

  setUp(() {
    database = openTestDatabase();
    final services = SampleServices(database, FixedClock(sampleNow));
    samples = SampleGroupService(
      groups: services.groups,
      cards: services.cards,
      loadCards: (language) =>
          File(BundledSampleCards.assetFor(language)).readAsString(),
    );
  });

  tearDown(() => database.close());

  test('reads the capitals of the language, in order', () async {
    final english = await samples.cards('en');
    expect(english, hasLength(197));
    expect((english.first.front, english.first.back), ('Afghanistan', 'Kabul'));
    expect((english.last.front, english.last.back), ('Zimbabwe', 'Harare'));

    final french = await samples.cards('fr');
    expect(french, hasLength(197));
    expect((french.first.front, french.first.back), ('Afghanistan', 'Kaboul'));
    expect((french.last.front, french.last.back), ('Zimbabwé', 'Hararé'));
  });

  test('creates the group with its cards pending in order, on the global '
      'preset, without the back nor a distillation', () async {
    final groupId = await samples.create('Capitals', 'en');
    final group = await GroupRepository(database).watchById(groupId).first;
    expect(group!.name, 'Capitals');
    expect(group.presetId, isNull);
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
    final groupId = await samples.create('Capitales', 'fr');
    final cards = await CardRepository(database).getCardsOfGroup(groupId);
    final france = cards.singleWhere((card) => card.frontText == 'France');
    expect(france.backText, 'Paris');
    final germany = cards.singleWhere((card) => card.frontText == 'Allemagne');
    expect(germany.backText, 'Berlin');
  });
}
