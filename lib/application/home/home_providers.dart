import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/reviews/extra_reminder.dart';
import '../../domain/reviews/review_record.dart';
import '../cards/card_providers.dart';
import '../clock.dart';
import '../presets/preset_providers.dart';
import '../reviews/review_providers.dart';
import '../time/minute_ticker.dart';
import 'today_overview.dart';
import 'today_planner.dart';

/// First moment of the current scheduling day; changes once a day, so the
/// streams built on it are not rebuilt every minute.
final todayStartProvider = Provider<DateTime?>((ref) {
  final now = ref.watch(currentMomentProvider).value;
  final calendar = ref.watch(schedulingCalendarProvider);
  return now == null ? null : calendar.startOf(calendar.dayOf(now));
});

/// Answers given today, bonus reviews included.
final todayReviewsProvider = StreamProvider<List<ReviewRecord>>((ref) {
  final start = ref.watch(todayStartProvider);
  return start == null
      ? const Stream.empty()
      : ref.watch(reviewRepositoryProvider).watchSince(start);
});

/// "Review soon" reminders not shown yet.
final upcomingExtraRemindersProvider = StreamProvider<List<ExtraReminder>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchAllUpcoming(),
);

/// Today as shown on the home screen; `null` while loading.
final todayOverviewProvider = Provider<TodayOverview?>((ref) {
  final cards = ref.watch(allCardsProvider).value;
  final reminders = ref.watch(upcomingExtraRemindersProvider).value;
  final reviews = ref.watch(todayReviewsProvider).value;
  final catalog = ref.watch(presetCatalogProvider).value;
  final now = ref.watch(currentMomentProvider).value;
  if (cards == null ||
      reminders == null ||
      reviews == null ||
      catalog == null ||
      now == null) {
    return null;
  } else {
    return TodayPlanner(ref.watch(schedulingCalendarProvider)).build(
      cards: cards,
      reminders: reminders,
      reviewsToday: reviews,
      catalog: catalog,
      dueCount: ref.watch(dueItemsProvider).length,
      now: now,
    );
  }
});
