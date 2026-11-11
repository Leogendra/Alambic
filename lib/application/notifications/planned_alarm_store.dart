/// Remembers the wake-ups scheduled last time, so that a new planning only
/// cancels and adds the difference.
abstract interface class PlannedAlarmStore {
  /// Wake-up moments by alarm id.
  Future<Map<int, DateTime>> load();

  Future<void> save(Map<int, DateTime> alarms);
}
