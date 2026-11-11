import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../application/notifications/planned_alarm_store.dart';

/// Keeps the planned wake-ups in the preferences. The asynchronous API reads
/// the platform store each time, so the app and its background tasks, which
/// run in separate isolates, see each other's writes.
class SharedPreferencesAlarmStore implements PlannedAlarmStore {
  SharedPreferencesAlarmStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _key = 'plannedAlarms';

  final SharedPreferencesAsync _preferences;

  @override
  Future<Map<int, DateTime>> load() async {
    final stored = await _preferences.getString(_key);
    if (stored == null) {
      return {};
    }
    final decoded = (jsonDecode(stored) as Map<String, dynamic>);
    return decoded.map(
      (id, millis) => MapEntry(
        int.parse(id),
        DateTime.fromMillisecondsSinceEpoch(millis as int),
      ),
    );
  }

  @override
  Future<void> save(Map<int, DateTime> alarms) => _preferences.setString(
    _key,
    jsonEncode(
      alarms.map((id, at) => MapEntry('$id', at.millisecondsSinceEpoch)),
    ),
  );
}
