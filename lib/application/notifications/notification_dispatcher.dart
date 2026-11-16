import '../../data/repositories/card_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/pause_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../domain/cards/card_side.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/notifications/delivery_planner.dart';
import '../../domain/notifications/notification_timing.dart';
import '../../domain/pauses/pauses.dart';
import '../../domain/presets/notification_mode.dart';
import '../../domain/presets/preset_catalog.dart';
import '../clock.dart';
import '../distillation/distillation_service.dart';
import 'delivery_candidates.dart';
import 'group_reminder_key.dart';
import 'grouped_reminders.dart';
import 'notification_digest.dart';
import 'notification_planner.dart';
import 'notification_presenter.dart';
import 'review_notification_key.dart';
import 'review_prompt.dart';

/// Runs when the app wakes up: runs the daily pass of the distillations,
/// shows a notification for every card and every "Review soon" reminder
/// whose moment has come, then plans the next wake-ups. A card whose
/// preset asks for a grouped reminder is announced by the reminder of its
/// group instead. Beyond the auto grouping threshold, a single notification
/// replaces all of them. The cards notified count against the daily cap. The
/// content is read from the database at that moment, never fixed when the
/// wake-up was planned.
class NotificationDispatcher {
  const NotificationDispatcher({
    required this._cards,
    required this._groups,
    required this._presets,
    required this._reminders,
    required this._settings,
    required this._pauses,
    required this._distillations,
    required this._groupedReminders,
    required this._presenter,
    required this._planner,
    required this._deliveryPlanner,
    required this._clock,
  });

  final CardRepository _cards;
  final GroupRepository _groups;
  final PresetRepository _presets;
  final ReminderRepository _reminders;
  final NotificationSettingsRepository _settings;
  final PauseRepository _pauses;
  final DistillationService _distillations;
  final GroupedReminders _groupedReminders;
  final NotificationPresenter _presenter;
  final NotificationPlanner _planner;
  final DeliveryPlanner _deliveryPlanner;
  final Clock _clock;

  Future<void> dispatchDue() async {
    await _distillations.advance();
    final now = _clock();
    final catalog = await _presets.loadCatalog();
    final groupNames = {
      for (final group in await _groups.watchAll().first) group.id: group.name,
    };
    final cards = await _cards.getAll();
    final guards = await _settings.loadGuards();
    final pauses = await _pauses.loadPauses();
    final today = _deliveryPlanner.calendar.dayOf(now);
    final deliveries = _deliveryPlanner.plan(
      deliveryCandidates(cards, catalog, pauses),
      now: now,
      guards: guards,
      notifiedToday: await _settings.notifiedOn(today),
    );
    final prompts = <ReviewPrompt>[];
    final groupedReminders = <GroupReminderKey>{};
    final notifiedGroups = <int>[];
    for (final card in cards) {
      final deliverAt = deliveries[card.id];
      if (deliverAt != null &&
          NotificationTiming.shouldNotify(
            card,
            deliverAt: deliverAt,
            now: now,
            calendar: _deliveryPlanner.calendar,
          )) {
        if (catalog.presetForCard(card).notificationMode ==
            NotificationMode.grouped) {
          groupedReminders.add(GroupReminderKey(card.groupId));
        } else {
          prompts.add(_prompt(card, catalog, groupNames, null));
        }
        notifiedGroups.add(card.groupId);
        await _cards.markNotified(card.id, now);
      }
    }
    if (guards.groupsAutomatically(prompts.length + groupedReminders.length)) {
      await _presenter.showDigest(
        NotificationDigest.of(notifiedGroups, groupNames, alert: true),
      );
    } else {
      for (final prompt in prompts) {
        await _presenter.showPrompt(prompt);
      }
      for (final key in groupedReminders) {
        await _groupedReminders.show(key, alert: true);
      }
    }
    if (notifiedGroups.isNotEmpty) {
      await _settings.addNotified(today, notifiedGroups.length);
    }
    await _dispatchExtraReminders(cards, catalog, groupNames, pauses, now);
    await _planner.replan();
  }

  /// Shows the extra reminders whose moment has come. One found too late,
  /// or falling during a pause of its card, is dropped, like a late reminder
  /// of a due card.
  Future<void> _dispatchExtraReminders(
    List<Flashcard> cards,
    PresetCatalog catalog,
    Map<int, String> groupNames,
    Pauses pauses,
    DateTime now,
  ) async {
    for (final reminder in await _reminders.getAllUpcoming()) {
      if (reminder.remindAt.isAfter(now)) {
        continue;
      }
      final card = cards
          .where((card) => card.id == reminder.cardId)
          .firstOrNull;
      if (card != null &&
          !pauses.covers(card.groupId) &&
          NotificationTiming.isOnTime(reminder.remindAt, now)) {
        await _presenter.showPrompt(
          _prompt(card, catalog, groupNames, reminder.id),
        );
      }
      await _reminders.markNotified(reminder.id, now);
    }
  }

  ReviewPrompt _prompt(
    Flashcard card,
    PresetCatalog catalog,
    Map<int, String> groupNames,
    int? extraReminderId,
  ) => ReviewPrompt.of(
    key: ReviewNotificationKey(
      cardId: card.id,
      extraReminderId: extraReminderId,
    ),
    card: card,
    askedSide: CardSide.front,
    preset: catalog.presetForCard(card),
    groupName: groupNames[card.groupId] ?? '',
  );
}
