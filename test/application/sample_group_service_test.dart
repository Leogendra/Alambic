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
      loadCards: () => File(BundledSampleCards.asset).readAsString(),
    );
  });

  tearDown(() => database.close());

  test('reads the 26 letters of the NATO alphabet, in order', () async {
    final cards = await samples.cards();
    expect(cards, hasLength(26));
    expect((cards.first.front, cards.first.back), ('A', 'Alpha'));
    expect((cards.last.front, cards.last.back), ('Z', 'Zulu'));
  });

  test('creates the group with its cards pending in order, on the global '
      'preset, without the back nor a distillation', () async {
    final groupId = await samples.create('NATO alphabet');
    final group = await GroupRepository(database).watchById(groupId).first;
    expect(group!.name, 'NATO alphabet');
    expect(group.presetId, isNull);
    expect(group.reverseEnabled, isFalse);
    expect(await DistillationRepository(database).getAll(), isEmpty);
    final cards = await CardRepository(database).getCardsOfGroup(groupId)
      ..sort((a, b) => a.queuePosition!.compareTo(b.queuePosition!));
    expect(cards, hasLength(26));
    expect(cards.every((card) => card.isPending), isTrue);
    expect(
      cards.map((card) => card.frontText).join(),
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    );
    expect(cards[9].backText, 'Juliett');
  });
}
