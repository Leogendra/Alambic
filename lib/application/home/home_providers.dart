import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/reviews/extra_reminder.dart';
import '../cards/card_providers.dart';
import '../clock.dart';
import '../distillation/distillation_providers.dart';
import '../scheduling/scheduling_providers.dart';
import '../time/minute_ticker.dart';
import 'home_timeline.dart';
import 'timeline_planner.dart';

/// First moment of the current scheduling day; changes once a day, so the
/// streams built on it are not rebuilt every minute.
final todayStartProvider = Provider<DateTime?>((ref) {
  final now = ref.watch(currentMomentProvider).value;
  final calendar = ref.watch(schedulingCalendarProvider);
  return now == null ? null : calendar.startOf(calendar.dayOf(now));
});

/// "Review soon" reminders not shown yet.
final upcomingExtraRemindersProvider = StreamProvider<List<ExtraReminder>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchAllUpcoming(),
);

/// Home's timeline; `null` while loading.
final homeTimelineProvider = Provider<HomeTimeline?>((ref) {
  final cards = ref.watch(allCardsProvider).value;
  final reminders = ref.watch(upcomingExtraRemindersProvider).value;
  final distillations = ref.watch(distillationsProvider).value;
  final globalPause = ref.watch(globalPauseProvider);
  final now = ref.watch(currentMomentProvider).value;
  if (cards == null ||
      reminders == null ||
      distillations == null ||
      !globalPause.hasValue ||
      now == null) {
    return null;
  } else {
    return TimelinePlanner(
      calendar: ref.watch(schedulingCalendarProvider),
      duePolicy: ref.watch(duePolicyProvider),
      rhythm: ref.watch(distillationRhythmProvider),
    ).build(
      cards: cards,
      reminders: reminders,
      distillations: distillations,
      globallyPaused: globalPause.value != null,
      now: now,
    );
  }
});
