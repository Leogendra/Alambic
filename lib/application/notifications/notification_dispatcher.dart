import '../../data/repositories/card_repository.dart';
import '../../data/repositories/card_with_directions.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/notifications/notification_timing.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/reviews/extra_reminder.dart';
import '../clock.dart';
import '../distillation/distillation_service.dart';
import 'notification_planner.dart';
import 'notification_presenter.dart';
import 'review_notification_key.dart';
import 'review_prompt.dart';

/// Runs when the app wakes up: runs the daily pass of the distillations,
/// shows a notification for every direction and every "Review soon" reminder
/// whose moment has come, then plans the next wake-ups. The content is read from the database at that moment, never
/// fixed when the wake-up was planned.
class NotificationDispatcher {
  const NotificationDispatcher({
    required this._cards,
    required this._groups,
    required this._presets,
    required this._reminders,
    required this._distillations,
    required this._presenter,
    required this._planner,
    required this._clock,
  });

  final CardRepository _cards;
  final GroupRepository _groups;
  final PresetRepository _presets;
  final ReminderRepository _reminders;
  final DistillationService _distillations;
  final NotificationPresenter _presenter;
  final NotificationPlanner _planner;
  final Clock _clock;

  Future<void> dispatchDue() async {
    await _distillations.advance();
    final now = _clock();
    final catalog = await _presets.loadCatalog();
    final groupNames = {
      for (final group in await _groups.watchAll().first) group.id: group.name,
    };
    final cards = await _cards.getAll();
    for (final card in cards) {
      for (final direction in card.directions) {
        if (NotificationTiming.shouldNotify(
          direction,
          cardSuspended: card.card.suspended,
          now: now,
        )) {
          await _presenter.showPrompt(
            _prompt(card, direction, catalog, groupNames, null),
          );
          await _cards.markNotified(direction.id, now);
        }
      }
    }
    await _dispatchExtraReminders(cards, catalog, groupNames, now);
    await _planner.replan();
  }

  /// Shows the extra reminders whose moment has come. One found too late is
  /// dropped, like a late reminder of a due card.
  Future<void> _dispatchExtraReminders(
    List<CardWithDirections> cards,
    PresetCatalog catalog,
    Map<int, String> groupNames,
    DateTime now,
  ) async {
    for (final reminder in await _reminders.getAllUpcoming()) {
      if (reminder.remindAt.isAfter(now)) {
        continue;
      }
      final card = _cardOf(cards, reminder);
      if (card != null && NotificationTiming.isOnTime(reminder.remindAt, now)) {
        final direction = card.directions.firstWhere(
          (direction) => direction.id == reminder.directionId,
        );
        await _presenter.showPrompt(
          _prompt(card, direction, catalog, groupNames, reminder.id),
        );
      }
      await _reminders.markNotified(reminder.id, now);
    }
  }

  CardWithDirections? _cardOf(
    List<CardWithDirections> cards,
    ExtraReminder reminder,
  ) => cards
      .where(
        (card) => card.directions.any(
          (direction) => direction.id == reminder.directionId,
        ),
      )
      .firstOrNull;

  ReviewPrompt _prompt(
    CardWithDirections card,
    CardDirection direction,
    PresetCatalog catalog,
    Map<int, String> groupNames,
    int? extraReminderId,
  ) => ReviewPrompt(
    key: ReviewNotificationKey(
      directionId: direction.id,
      extraReminderId: extraReminderId,
    ),
    prompt: card.card.promptFor(direction.sense).text ?? '',
    groupName: groupNames[card.card.groupId],
    step: direction.step,
    sequenceLength: catalog.presetForCard(card.card).sequenceLength,
    isReverse: direction.sense == DirectionSense.backToFront,
  );
}
