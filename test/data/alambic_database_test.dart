import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/presets/built_in_preset_key.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';

void main() {
  late AlambicDatabase database;

  setUp(() {
    database = AlambicDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test(
    'a new database ships Standard and Intensif, Standard as global',
    () async {
      final presets = await database.select(database.presets).get();
      expect(presets.map((preset) => preset.builtInKey), [
        BuiltInPresetKey.standard,
        BuiltInPresetKey.intensive,
      ]);
      expect(presets.first.intervals, BuiltInPresets.standard.intervals);
      final settings = await database.select(database.appSettings).getSingle();
      expect(settings.globalPresetId, presets.first.id);
    },
  );

  Future<int> insertGroup() => database
      .into(database.cardGroups)
      .insert(
        CardGroupsCompanion.insert(
          name: 'Capitales',
          createdAt: DateTime(2026, 11, 10),
        ),
      );

  Future<int> insertCard(int groupId) => database
      .into(database.flashcards)
      .insert(
        FlashcardsCompanion.insert(
          groupId: groupId,
          frontText: const Value('Mongolie'),
          backText: const Value('Oulan-Bator'),
          createdAt: DateTime(2026, 11, 10),
          state: CardState.pending,
        ),
      );

  test('deleting a group deletes its cards', () async {
    final groupId = await insertGroup();
    final cardId = await insertCard(groupId);
    await (database.delete(
      database.cardGroups,
    )..where((group) => group.id.equals(groupId))).go();
    final cards = await (database.select(
      database.flashcards,
    )..where((card) => card.id.equals(cardId))).get();
    expect(cards, isEmpty);
  });

  test('deleting a card deletes its history', () async {
    final cardId = await insertCard(await insertGroup());
    await database
        .into(database.reviewRecords)
        .insert(
          ReviewRecordsCompanion.insert(
            cardId: cardId,
            reviewedAt: DateTime(2026, 11, 10),
            outcome: ReviewOutcome.correct,
            isBonus: false,
            source: ReviewSource.session,
          ),
        );
    await (database.delete(
      database.flashcards,
    )..where((card) => card.id.equals(cardId))).go();
    expect(await database.select(database.reviewRecords).get(), isEmpty);
  });
}
