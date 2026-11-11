/// Wakes the app up at a given moment, even when it is closed. Implemented
/// per platform; the wake-up shows whatever is due at that moment.
abstract interface class AlarmScheduler {
  /// Whether alarms fire at the exact minute. Without this permission they
  /// still fire, a few minutes late at most.
  Future<bool> canScheduleExact();

  /// Asks the user for exact alarms; the answer is read back with
  /// [canScheduleExact] once the app is resumed.
  Future<void> requestExactPermission();

  /// Schedules the wake-up [id] at [at], replacing any wake-up with that id.
  /// It survives a restart of the phone.
  Future<void> schedule(int id, DateTime at, {required bool exact});

  Future<void> cancel(int id);
}
