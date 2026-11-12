import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_order.dart';
import '../../domain/distillation/distillation_status.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/presets/built_in_preset_key.dart';
import '../../domain/presets/built_in_presets.dart';
import '../../domain/presets/failure_behavior.dart';
import '../../domain/presets/grouped_reminder_action.dart';
import '../../domain/presets/notification_mode.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/preset_interval.dart';
import '../../domain/presets/schedule_kind.dart';
import '../../domain/presets/scheduling_engine_kind.dart';
import '../../domain/presets/sequence_end_behavior.dart';
import '../../domain/reviews/extra_reminder.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_record.dart';
import '../../domain/reviews/review_source.dart';
import '../../domain/scheduling/clock_time.dart';
import 'converters/clock_time_converter.dart';
import 'converters/preset_interval_list_converter.dart';
import 'preset_companions.dart';
import 'tables/app_settings.dart';
import 'tables/card_directions.dart';
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
    CardDirections,
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

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedBuiltInPresets();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(distillations);
        await migrator.addColumn(cardDirections, cardDirections.distillationId);
        await migrator.addColumn(cardDirections, cardDirections.queuePosition);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Creates the shipped presets and makes Standard the global preset.
  Future<void> _seedBuiltInPresets() async {
    int? standardId;
    for (final preset in BuiltInPresets.shippedInFirstRelease) {
      final id = await into(presets).insert(PresetCompanions.forInsert(preset));
      if (preset.builtInKey == BuiltInPresetKey.standard) {
        standardId = id;
      }
    }
    await into(appSettings)
        .insert(AppSettingsCompanion.insert(globalPresetId: standardId!));
  }
}
