import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:remanence/data/database/remanence_database.dart';

/// Real SQLite database held in memory. Streams close synchronously so that
/// widget tests do not end with pending timers.
RemanenceDatabase openTestDatabase() => RemanenceDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);
