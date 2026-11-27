import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';

import 'generated/schema.dart';

void main() {
  test('a new database matches the saved schema of its version', () async {
    // Fails when a table changes without a new schema version saved by
    // `dart run drift_dev make-migrations`.
    final verifier = SchemaVerifier(GeneratedHelper());
    final database = AlambicDatabase(NativeDatabase.memory());
    await verifier.migrateAndValidate(database, database.schemaVersion);
    await database.close();
  });
}
