import 'package:drift/drift.dart';

import '../../domain/presets/preset.dart';
import 'alambic_database.dart';

/// Writes a domain [Preset] into the presets table.
abstract final class PresetCompanions {
  /// Companion for an insert: the stored id is assigned by the database.
  static PresetsCompanion forInsert(Preset preset) =>
      _fields(preset).copyWith(id: const Value.absent());

  static PresetsCompanion forUpdate(Preset preset) => _fields(preset);

  static PresetsCompanion _fields(Preset preset) => PresetsCompanion(
    id: Value(preset.id),
    name: Value(preset.name),
    builtInKey: Value(preset.builtInKey),
    engine: Value(preset.engine),
    intervals: Value(preset.intervals),
    failureBehavior: Value(preset.failureBehavior),
    endBehavior: Value(preset.endBehavior),
    typedAnswer: Value(preset.typedAnswer),
    scheduleKind: Value(preset.scheduleKind),
    fixedTime: Value(preset.fixedTime),
    rangeStart: Value(preset.rangeStart),
    rangeEnd: Value(preset.rangeEnd),
    notificationMode: Value(preset.notificationMode),
    groupedAction: Value(preset.groupedAction),
    targetRetention: Value(preset.targetRetention),
  );
}
