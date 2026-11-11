import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../domain/presets/preset_interval.dart';

/// Stores a preset sequence as a JSON array of `{amount, unit}` objects.
class PresetIntervalListConverter
    extends TypeConverter<List<PresetInterval>, String> {
  const PresetIntervalListConverter();

  @override
  List<PresetInterval> fromSql(String fromDb) => (jsonDecode(fromDb) as List)
      .cast<Map<String, Object?>>()
      .map(PresetInterval.fromJson)
      .toList(growable: false);

  @override
  String toSql(List<PresetInterval> value) =>
      jsonEncode(value.map((interval) => interval.toJson()).toList());
}
