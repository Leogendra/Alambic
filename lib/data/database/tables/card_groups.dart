import 'package:drift/drift.dart';

import '../../../domain/groups/card_group.dart';
import 'presets.dart';

@UseRowClass(CardGroup)
class CardGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get presetId => integer().nullable().references(Presets, #id)();
  DateTimeColumn get createdAt => dateTime()();

  /// Start of the pause of the group, `null` when it is not paused.
  DateTimeColumn get pausedAt => dateTime().nullable()();
}
