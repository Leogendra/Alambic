import 'package:drift/drift.dart';

import '../../domain/reviews/extra_reminder.dart';
import '../database/remanence_database.dart';

/// One-off reminders added with "Review soon".
class ReminderRepository {
  const ReminderRepository(this._database);

  final RemanenceDatabase _database;

  Future<int> insert(int directionId, DateTime remindAt) => _database
      .into(_database.extraReminders)
      .insert(
        ExtraRemindersCompanion.insert(
          directionId: directionId,
          remindAt: remindAt,
        ),
      );

  Future<void> delete(int reminderId) => (_database.delete(
    _database.extraReminders,
  )..where((reminder) => reminder.id.equals(reminderId))).go();

  Future<ExtraReminder?> getById(int reminderId) => (_database.select(
    _database.extraReminders,
  )..where((reminder) => reminder.id.equals(reminderId))).getSingleOrNull();

  /// Reminders of a direction not shown yet, earliest first.
  Stream<List<ExtraReminder>> watchUpcoming(int directionId) =>
      (_database.select(_database.extraReminders)
            ..where(
              (reminder) =>
                  reminder.directionId.equals(directionId) &
                  reminder.notifiedAt.isNull(),
            )
            ..orderBy([(reminder) => OrderingTerm.asc(reminder.remindAt)]))
          .watch();

  /// Every reminder not shown yet, earliest first.
  Stream<List<ExtraReminder>> watchAllUpcoming() =>
      (_database.select(_database.extraReminders)
            ..where((reminder) => reminder.notifiedAt.isNull())
            ..orderBy([(reminder) => OrderingTerm.asc(reminder.remindAt)]))
          .watch();

  Future<List<ExtraReminder>> getAllUpcoming() => watchAllUpcoming().first;

  Future<void> markNotified(int reminderId, DateTime notifiedAt) =>
      (_database.update(_database.extraReminders)
            ..where((reminder) => reminder.id.equals(reminderId)))
          .write(ExtraRemindersCompanion(notifiedAt: Value(notifiedAt)));
}
