import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/alambic_database.dart';
import 'repositories/card_repository.dart';
import 'repositories/distillation_repository.dart';
import 'repositories/group_repository.dart';
import 'repositories/preset_repository.dart';
import 'repositories/reminder_repository.dart';

/// The open database. Always overridden: by the app entry point with the
/// database file, by tests with an in-memory database.
final databaseProvider = Provider<AlambicDatabase>(
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

final reminderRepositoryProvider = Provider(
  (ref) => ReminderRepository(ref.watch(databaseProvider)),
);

final distillationRepositoryProvider = Provider(
  (ref) => DistillationRepository(ref.watch(databaseProvider)),
);
