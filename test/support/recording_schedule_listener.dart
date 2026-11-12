import 'package:alambic/application/scheduling/schedule_change_listener.dart';

/// Counts the notifications of schedule changes.
class RecordingScheduleListener implements ScheduleChangeListener {
  int changeCount = 0;

  @override
  Future<void> onSchedulesChanged() async => changeCount++;
}
