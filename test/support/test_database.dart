import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:alambic/data/database/alambic_database.dart';

/// Real SQLite database held in memory. Streams close synchronously so that
/// widget tests do not end with pending timers.
AlambicDatabase openTestDatabase() => AlambicDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Closes [database], failing after 5 s instead of waiting for the timeout
/// of the test: a database closed under a screen still mounted never
/// finishes closing.
Future<void> closeTestDatabase(AlambicDatabase database) =>
    database.close().timeout(const Duration(seconds: 5));
