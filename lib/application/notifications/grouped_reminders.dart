import 'dart:math';

import '../../data/repositories/card_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/repositories/pause_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/cards/asked_side_draw.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/notifications/delivery_planner.dart';
import '../../domain/notifications/grouped_reminder_action.dart';
import '../../domain/notifications/notification_mode.dart';
import '../../domain/presets/preset.dart';
import '../clock.dart';
import 'delivery_candidates.dart';
import 'group_reminder.dart';
import 'group_reminder_key.dart';
import 'notification_presenter.dart';
import 'review_notification_key.dart';
import 'review_prompt.dart';

/// The grouped reminders: in this notification mode, a single notification
/// per group for its due cards ("Capitales : 5 cartes à réviser"). It opens the
/// app on the group, or chains the cards inside the notification, each answer
/// replacing the card with the next one.
class GroupedReminders {
  const GroupedReminders({
    required this._cards,
    required this._groups,
    required this._presets,
    required this._settings,
    required this._pauses,
    required this._presenter,
    required this._deliveryPlanner,
    required this._clock,
    required this._random,
  });

  final CardRepository _cards;
  final GroupRepository _groups;
  final PresetRepository _presets;
  final NotificationSettingsRepository _settings;
  final PauseRepository _pauses;
  final NotificationPresenter _presenter;
  final DeliveryPlanner _deliveryPlanner;
  final Clock _clock;
  final Random _random;

  /// Shows the reminder of [key] with its current count, or closes it when
  /// no card is left. [alert] is `false` when only the count is refreshed.
  Future<void> show(GroupReminderKey key, {required bool alert}) async {
    final waiting = await _waiting(key);
    if (waiting.isEmpty) {
      await _presenter.dismissGroupReminder(key);
    } else {
      final reminderSettings = await _settings.loadReminderSettings();
      await _presenter.showGroupReminder(
        GroupReminder(
          key: key,
          groupName: await _groupName(key),
          count: waiting.length,
          chain:
              reminderSettings.groupedAction ==
              GroupedReminderAction.chainInNotification,
          alert: alert,
        ),
      );
    }
  }

  /// Updates, without alerting, the reminder of [key] showing [shownCount]
  /// cards when the count changed, or closes it when no card is left.
  Future<void> refresh(GroupReminderKey key, int shownCount) async {
    final count = (await _waiting(key)).length;
    if (count != shownCount) {
      await show(key, alert: false);
    }
  }

  /// Asks the next card of [key] in the notification, drawing its asked
  /// face, or closes it when no card is left.
  Future<void> showNext(GroupReminderKey key) async {
    final waiting = await _waiting(key);
    final group = await _groups.find(key.groupId);
    if (waiting.isEmpty || group == null) {
      await _presenter.dismissGroupReminder(key);
    } else {
      final next = waiting.first;
      await _presenter.showPrompt(
        ReviewPrompt.of(
          key: ReviewNotificationKey(cardId: next.card.id, chain: key),
          card: next.card,
          askedSide: AskedSideDraw.draw(group, _random),
          preset: next.preset,
          groupName: group.name,
          chainRemaining: waiting.length,
        ),
      );
    }
  }

  /// Cards of the group whose notification moment has come, the earliest due
  /// first; none outside the grouped reminder mode. Cards held back by the
  /// daily cap are left out.
  Future<List<_Waiting>> _waiting(GroupReminderKey key) async {
    final reminderSettings = await _settings.loadReminderSettings();
    if (reminderSettings.notificationMode != NotificationMode.grouped) {
      return const [];
    }
    final now = _clock();
    final cards = await _cards.getCardsOfGroup(key.groupId);
    final catalog = await _presets.loadCatalog();
    final deliveries = _deliveryPlanner.plan(
      deliveryCandidates(cards, catalog, await _pauses.loadPauses()),
      now: now,
      reminders: reminderSettings,
      guards: await _settings.loadGuards(),
      notifiedToday: await _settings.notifiedOn(
        _deliveryPlanner.calendar.dayOf(now),
      ),
    );
    final waiting = [
      for (final card in cards)
        if (deliveries[card.id] case final deliverAt?
            when !deliverAt.isAfter(now))
          _Waiting(card, catalog.presetForGroup(card.groupId)),
    ];
    return waiting..sort(_earliestDueFirst);
  }

  static int _earliestDueFirst(_Waiting first, _Waiting second) {
    final byDue = first.card.dueAt!.compareTo(second.card.dueAt!);
    return byDue != 0 ? byDue : first.card.id.compareTo(second.card.id);
  }

  Future<String> _groupName(GroupReminderKey key) async =>
      (await _groups.find(key.groupId))?.name ?? '';
}

class _Waiting {
  const _Waiting(this.card, this.preset);

  final Flashcard card;
  final Preset preset;
}
