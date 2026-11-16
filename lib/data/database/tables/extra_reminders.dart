import 'package:drift/drift.dart';

import '../../../domain/reviews/extra_reminder.dart';
import 'flashcards.dart';

@UseRowClass(ExtraReminder)
class ExtraReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId =>
      integer().references(Flashcards, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get remindAt => dateTime()();
  DateTimeColumn get notifiedAt => dateTime().nullable()();
}
