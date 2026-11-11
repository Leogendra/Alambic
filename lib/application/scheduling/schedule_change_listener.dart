/// Told whenever due dates may have changed, so that the notification planning
/// can follow. Owned by the application layer, implemented by the
/// notifications layer.
abstract interface class ScheduleChangeListener {
  Future<void> onSchedulesChanged();
}
