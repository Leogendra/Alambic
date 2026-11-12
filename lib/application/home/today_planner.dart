import '../../data/repositories/card_with_directions.dart';
import '../../domain/notifications/delivery_planner.dart';
import '../../domain/notifications/notification_guards.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/reviews/extra_reminder.dart';
import '../../domain/reviews/review_record.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import '../notifications/delivery_candidates.dart';
import 'timeline_entry.dart';
import 'today_overview.dart';

/// Builds the home screen view of today from the cards, the reminders and the
/// answers of the day.
class TodayPlanner {
  const TodayPlanner(this._calendar);

  final SchedulingCalendar _calendar;

  TodayOverview build({
    required List<CardWithDirections> cards,
    required List<ExtraReminder> reminders,
    required List<ReviewRecord> reviewsToday,
    required PresetCatalog catalog,
    required Set<int> distillationIds,
    required int dueCount,
    required DateTime now,
    NotificationGuards? guards,
    int notifiedToday = 0,
  }) => TodayOverview(
    dueCount: dueCount,
    doneCount: {
      for (final review in reviewsToday)
        if (!review.isBonus) review.directionId,
    }.length,
    timeline: [
      ..._groupEntries(
        cards,
        catalog,
        distillationIds,
        now,
        guards,
        notifiedToday,
      ),
      ..._reminderEntries(reminders, now),
    ]..sort((first, second) => first.at.compareTo(second.at)),
  );

  /// Directions of active cards notified today, grouped by group and moment
  /// of notification. The new cards of a distillation in progress get lines
  /// of their own.
  Iterable<TimelineEntry> _groupEntries(
    List<CardWithDirections> cards,
    PresetCatalog catalog,
    Set<int> distillationIds,
    DateTime now,
    NotificationGuards? guards,
    int notifiedToday,
  ) {
    final deliveries = DeliveryPlanner(_calendar).plan(
      deliveryCandidates(cards, catalog),
      now: now,
      guards: guards,
      notifiedToday: notifiedToday,
    );
    final counts = <(int?, DateTime, int?), int>{};
    for (final card in cards) {
      for (final direction in card.directions) {
        final deliverAt = deliveries[direction.id];
        if (deliverAt != null && _isToday(deliverAt, now)) {
          final distillationId = direction.distillationId;
          final isNewKnowledge =
              direction.step == null &&
              distillationIds.contains(distillationId);
          final key = (
            card.card.groupId,
            deliverAt,
            isNewKnowledge ? distillationId : null,
          );
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
    }
    return counts.entries.map(
      (count) => TimelineEntry(
        at: count.key.$2,
        groupId: count.key.$1,
        preset: catalog.presetForGroup(count.key.$1),
        count: count.value,
        isExtraReminder: false,
        distillationId: count.key.$3,
      ),
    );
  }

  Iterable<TimelineEntry> _reminderEntries(
    List<ExtraReminder> reminders,
    DateTime now,
  ) {
    final counts = <DateTime, int>{};
    for (final reminder in reminders) {
      if (_isToday(reminder.remindAt, now)) {
        counts[reminder.remindAt] = (counts[reminder.remindAt] ?? 0) + 1;
      }
    }
    return counts.entries.map(
      (count) => TimelineEntry(
        at: count.key,
        groupId: null,
        preset: null,
        count: count.value,
        isExtraReminder: true,
      ),
    );
  }

  bool _isToday(DateTime moment, DateTime now) =>
      _calendar.isSameDay(moment, now);
}
