import 'package:drift/drift.dart';

import '../../../domain/cards/flashcard.dart';
import 'card_groups.dart';
import 'presets.dart';

@UseRowClass(Flashcard)
class Flashcards extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Deleting a group moves its cards to "Sans groupe".
  IntColumn get groupId => integer().nullable().references(
    CardGroups,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get frontText => text().nullable()();
  TextColumn get frontImagePath => text().nullable()();
  TextColumn get backText => text().nullable()();
  TextColumn get backImagePath => text().nullable()();
  IntColumn get presetId => integer().nullable().references(Presets, #id)();
  BoolColumn get suspended => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
