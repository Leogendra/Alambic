import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/remanence_database.dart';
import 'repositories/card_repository.dart';
import 'repositories/group_repository.dart';
import 'repositories/preset_repository.dart';

/// The open database. Always overridden: by the app entry point with the
/// database file, by tests with an in-memory database.
final databaseProvider = Provider<RemanenceDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final presetRepositoryProvider = Provider(
  (ref) => PresetRepository(ref.watch(databaseProvider)),
);

final groupRepositoryProvider = Provider(
  (ref) => GroupRepository(ref.watch(databaseProvider)),
);

final cardRepositoryProvider = Provider(
  (ref) => CardRepository(ref.watch(databaseProvider)),
);
