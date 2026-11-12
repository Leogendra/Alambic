import '../../data/repositories/card_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/preset_repository.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/grouped_reminder_action.dart';
import '../../domain/presets/notification_mode.dart';
import '../../domain/presets/preset.dart';
import '../clock.dart';
import 'group_reminder.dart';
import 'group_reminder_key.dart';
import 'notification_presenter.dart';
import 'review_notification_key.dart';
import 'review_prompt.dart';

/// The grouped reminders: a single notification per group for the due cards
/// whose preset asks for one ("Capitales : 5 cartes à réviser"). It opens the
/// app on the group, or chains the cards inside the notification, each answer
/// replacing the card with the next one.
class GroupedReminders {
  const GroupedReminders({
    required this._cards,
    required this._groups,
    required this._presets,
    required this._presenter,
    required this._clock,
  });

  final CardRepository _cards;
  final GroupRepository _groups;
  final PresetRepository _presets;
  final NotificationPresenter _presenter;
  final Clock _clock;

  /// Shows the reminder of [key] with its current count, or closes it when
  /// no card is left. [alert] is `false` when only the count is refreshed.
  Future<void> show(GroupReminderKey key, {required bool alert}) async {
    final waiting = await _waiting(key);
    if (waiting.isEmpty) {
      await _presenter.dismissGroupReminder(key);
    } else {
      await _presenter.showGroupReminder(
        GroupReminder(
          key: key,
          groupName: await _groupName(key),
          count: waiting.length,
          chain:
              waiting.first.preset.groupedAction ==
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

  /// Asks the next card of [key] in the notification, or closes it when no
  /// card is left.
  Future<void> showNext(GroupReminderKey key) async {
    final waiting = await _waiting(key);
    if (waiting.isEmpty) {
      await _presenter.dismissGroupReminder(key);
    } else {
      final next = waiting.first;
      await _presenter.showPrompt(
        ReviewPrompt.of(
          key: ReviewNotificationKey(
            directionId: next.direction.id,
            chain: key,
          ),
          card: next.card,
          direction: next.direction,
          preset: next.preset,
          groupName: await _groupName(key),
          chainRemaining: waiting.length,
        ),
      );
    }
  }

  /// Due cards of the group whose preset asks for a grouped reminder, the
  /// earliest due first.
  Future<List<_Waiting>> _waiting(GroupReminderKey key) async {
    final now = _clock();
    final catalog = await _presets.loadCatalog();
    final waiting = [
      for (final card in await _cards.getCardsOfGroup(key.groupId))
        if (!card.card.suspended)
          for (final direction in card.directions)
            if (direction.isScheduled && !direction.dueAt!.isAfter(now))
              _Waiting(card.card, direction, catalog.presetForCard(card.card)),
    ].where((item) => item.preset.notificationMode == NotificationMode.grouped);
    return waiting.toList()..sort(_earliestDueFirst);
  }

  static int _earliestDueFirst(_Waiting first, _Waiting second) {
    final byDue = first.direction.dueAt!.compareTo(second.direction.dueAt!);
    return byDue != 0
        ? byDue
        : first.direction.id.compareTo(second.direction.id);
  }

  Future<String?> _groupName(GroupReminderKey key) async {
    final groupId = key.groupId;
    return groupId == null
        ? null
        : (await _groups.watchById(groupId).first)?.name;
  }
}

class _Waiting {
  const _Waiting(this.card, this.direction, this.preset);

  final Flashcard card;
  final CardDirection direction;
  final Preset preset;
}
