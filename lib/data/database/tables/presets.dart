import 'package:drift/drift.dart';

import '../../../domain/presets/built_in_preset_key.dart';
import '../../../domain/presets/failure_behavior.dart';
import '../../../domain/presets/preset.dart';
import '../../../domain/presets/scheduling_engine_kind.dart';
import '../../../domain/presets/sequence_end_behavior.dart';
import '../converters/preset_interval_list_converter.dart';

@UseRowClass(Preset)
class Presets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get builtInKey => textEnum<BuiltInPresetKey>().nullable()();
  TextColumn get engine => textEnum<SchedulingEngineKind>()();
  TextColumn get intervals => text().map(const PresetIntervalListConverter())();
  TextColumn get failureBehavior => textEnum<FailureBehavior>()();
  TextColumn get endBehavior => textEnum<SequenceEndBehavior>()();
  BoolColumn get typedAnswer => boolean()();
  RealColumn get targetRetention => real()();
}
