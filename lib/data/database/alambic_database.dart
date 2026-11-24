import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/cards/card_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/notifications/grouped_reminder_action.dart';
import '../../domain/notifications/notification_mode.dart';
import '../../domain/notifications/schedule_kind.dart';
import '../../domain/groups/after_last_step.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/groups/remanence_interval.dart';
import '../../domain/presets/built_in_preset_key.dart';
import '../../domain/presets/built_in_presets.dart';
import '../../domain/presets/failure_behavior.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/preset_interval.dart';
import '../../domain/reviews/extra_reminder.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_record.dart';
import '../../domain/reviews/review_source.dart';
import '../../domain/scheduling/clock_time.dart';
import 'converters/clock_time_converter.dart';
import 'converters/preset_interval_list_converter.dart';
import 'preset_companions.dart';
import 'tables/app_settings.dart';
import 'tables/card_groups.dart';
import 'tables/distillations.dart';
import 'tables/extra_reminders.dart';
import 'tables/flashcards.dart';
import 'tables/presets.dart';
import 'tables/review_records.dart';

part 'alambic_database.g.dart';

/// Local SQLite database: the only store of cards, schedules and history.
@DriftDatabase(
  tables: [
    Presets,
    AppSettings,
    CardGroups,
    Distillations,
    Flashcards,
    ReviewRecords,
    ExtraReminders,
  ],
)
class AlambicDatabase extends _$AlambicDatabase {
  AlambicDatabase(super.executor);

  /// Opens the database file of the app. The connection is shared between
  /// isolates, so that answers given from a notification in the background
  /// refresh the screens of the running app.
  factory AlambicDatabase.open() => AlambicDatabase(
    driftDatabase(
      name: 'alambic',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    ),
  );

  /// Raised at every schema change.
  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: _create,
    onUpgrade: (migrator, from, to) async {
      await _dropAllTables();
      await _create(migrator);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _create(Migrator migrator) async {
    await migrator.createAll();
    await _seedBuiltInPresets();
  }

  /// Drops every table found in the file, including those of an older
  /// schema that this one no longer declares.
  Future<void> _dropAllTables() async {
    final tables = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
    ).get();
    await customStatement('PRAGMA foreign_keys = OFF');
    for (final table in tables) {
      await customStatement('DROP TABLE "${table.read<String>('name')}"');
    }
  }

  /// Creates the shipped presets and makes Standard the global preset.
  Future<void> _seedBuiltInPresets() async {
    int? standardId;
    for (final preset in BuiltInPresets.all) {
      final id = await into(presets).insert(PresetCompanions.forInsert(preset));
      if (preset.builtInKey == BuiltInPresetKey.standard) {
        standardId = id;
      }
    }
    await into(appSettings)
        .insert(AppSettingsCompanion.insert(globalPresetId: standardId!));
  }
}
