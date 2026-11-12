import '../../data/repositories/notification_settings_repository.dart';
import '../../domain/notifications/notification_guards.dart';
import '../scheduling/schedule_change_listener.dart';

/// Changes to the notification safeguards, which move the next
/// notifications.
class NotificationSettingsService {
  const NotificationSettingsService({
    required this._settings,
    required this._scheduleChangeListener,
  });

  final NotificationSettingsRepository _settings;
  final ScheduleChangeListener _scheduleChangeListener;

  Future<void> saveGuards(NotificationGuards guards) async {
    if (guards.dailyCap < 1 || guards.autoGroupThreshold < 1) {
      throw ArgumentError('A cap and a threshold count at least one card');
    }
    await _settings.saveGuards(guards);
    await _scheduleChangeListener.onSchedulesChanged();
  }
}
