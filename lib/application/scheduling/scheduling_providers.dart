import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/review_scheduler.dart';
import '../clock.dart';
import 'ignored_schedule_changes.dart';
import 'schedule_change_listener.dart';

final reviewSchedulerProvider = Provider(
  (ref) => ReviewScheduler(ref.watch(schedulingCalendarProvider)),
);

final duePolicyProvider = Provider(
  (ref) => DuePolicy(ref.watch(schedulingCalendarProvider)),
);

/// Overridden by the app entry point with the notification planning.
final scheduleChangeListenerProvider = Provider<ScheduleChangeListener>(
  (ref) => const IgnoredScheduleChanges(),
);
