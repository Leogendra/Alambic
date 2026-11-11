import 'schedule_change_listener.dart';

/// Listener used where no notification is planned (tests, previews).
class IgnoredScheduleChanges implements ScheduleChangeListener {
  const IgnoredScheduleChanges();

  @override
  Future<void> onSchedulesChanged() async {}
}
