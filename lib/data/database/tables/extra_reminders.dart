import 'package:drift/drift.dart';

import '../../../domain/reviews/extra_reminder.dart';
import 'card_directions.dart';

@UseRowClass(ExtraReminder)
class ExtraReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directionId =>
      integer().references(CardDirections, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get remindAt => dateTime()();
  DateTimeColumn get notifiedAt => dateTime().nullable()();
}
