import '../../domain/cards/flashcard.dart';
import '../../domain/notifications/delivery_planner.dart';
import '../../domain/notifications/notification_guards.dart';
import '../../domain/pauses/pauses.dart';
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
    required List<Flashcard> cards,
    required List<ExtraReminder> reminders,
    required List<ReviewRecord> reviewsToday,
    required PresetCatalog catalog,
    required Set<int> distillingGroupIds,
    required int dueCount,
    required DateTime now,
    NotificationGuards? guards,
    int notifiedToday = 0,
    Pauses pauses = Pauses.none,
  }) => TodayOverview(
    dueCount: dueCount,
    doneCount: {
      for (final review in reviewsToday)
        if (!review.isBonus) review.cardId,
    }.length,
    timeline: [
      ..._groupEntries(
        cards,
        catalog,
        distillingGroupIds,
        now,
        guards,
        notifiedToday,
        pauses,
      ),
      ..._reminderEntries(reminders, cards, pauses, now),
    ]..sort((first, second) => first.at.compareTo(second.at)),
  );

  /// Active cards notified today, grouped by group and moment of
  /// notification. The new cards of a distillation in progress get lines
  /// of their own.
  Iterable<TimelineEntry> _groupEntries(
    List<Flashcard> cards,
    PresetCatalog catalog,
    Set<int> distillingGroupIds,
    DateTime now,
    NotificationGuards? guards,
    int notifiedToday,
    Pauses pauses,
  ) {
    final deliveries = DeliveryPlanner(_calendar).plan(
      deliveryCandidates(cards, catalog, pauses),
      now: now,
      guards: guards,
      notifiedToday: notifiedToday,
    );
    final counts = <(int, DateTime, bool), int>{};
    for (final card in cards) {
      final deliverAt = deliveries[card.id];
      if (deliverAt != null && _isToday(deliverAt, now)) {
        final isNewKnowledge =
            card.lastReviewedAt == null &&
            distillingGroupIds.contains(card.groupId);
        final key = (card.groupId, deliverAt, isNewKnowledge);
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return counts.entries.map(
      (count) => TimelineEntry(
        at: count.key.$2,
        groupId: count.key.$1,
        preset: catalog.presetForGroup(count.key.$1),
        count: count.value,
        isExtraReminder: false,
        distillingGroupId: count.key.$3 ? count.key.$1 : null,
      ),
    );
  }

  /// "Review soon" reminders of today, except those of paused cards, which
  /// are not notified.
  Iterable<TimelineEntry> _reminderEntries(
    List<ExtraReminder> reminders,
    List<Flashcard> cards,
    Pauses pauses,
    DateTime now,
  ) {
    final groupOfCard = {for (final card in cards) card.id: card.groupId};
    final counts = <DateTime, int>{};
    for (final reminder in reminders) {
      final groupId = groupOfCard[reminder.cardId];
      if (_isToday(reminder.remindAt, now) &&
          groupId != null &&
          !pauses.covers(groupId)) {
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
