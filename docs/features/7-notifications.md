# Feature 7 — Notifications

Status: in progress (2026-11-11)

## Goal

Make the notification the main way to review: a card arrives at the slot of its preset, is answered with "Correct" or "Again", or with a typed answer, without opening the app, and the next review is planned at once. Grouped reminders, time ranges and the daily safeguards come later.

## Implementation overview

### Layers

The application decides what to notify and when; a platform layer decides how. Three interfaces, owned by the application, stand between them, so that iOS can become a second implementation without touching the rules:

- `AlarmScheduler` wakes the app up at a moment, app closed or not, and says whether it can do so at the exact minute;
- `NotificationPresenter` shows a card, replaces it with its answer, withdraws it, and lists the cards currently shown;
- `PlannedAlarmStore` remembers the wake-ups scheduled last time.

`lib/notifications/android/` implements them with `android_alarm_manager_plus`, `flutter_local_notifications` and `shared_preferences`. The texts of a notification come from `ReviewTexts`, which is not tied to a platform.

### Planning the wake-ups

`NotificationPlanner` listens to every schedule change: an answer, a start, a reset, a suspension, a deletion, a reminder added or removed. Each time, it computes the next wake-ups from the [due dates](../lexicon.md#due-date) of the scheduled directions of non-suspended cards and from the upcoming [extra reminders](../lexicon.md#extra-reminder), plus the start of the next day each running [distillation](8-distillation.md) has to process:

- one wake-up per distinct minute, a due moment with seconds (after a sub-day interval) being rounded up to the next minute;
- at most 48 wake-ups ahead, since each wake-up plans the next ones;
- only the difference with the previous planning is cancelled and scheduled.

A wake-up only says "look at what is due now". The content of the notification is read from the database when it fires, never fixed at planning time, so a card edited or answered meanwhile is shown as it is.

The planner also withdraws the notifications of cards that are no longer [due](../lexicon.md#due). A card reviewed in the app at 8:00 loses both its 12:00 wake-up, since its due date moved, and any notification already on screen. It never gets a duplicate reminder.

### Showing a card

When the app wakes up, `NotificationDispatcher` first runs the daily pass of the distillations, which may introduce cards, then shows one notification per direction whose due moment has come and that was not notified yet for this due date, then marks it notified and plans again. A reminder found more than one hour late is not shown: the phone was off or the alarm was held back, and a notification hours late would be noise. The card stays due in the app.

The notification shows the asked face as its title, the [step](../lexicon.md#step) ("Cran 2 sur 6", "Nouvelle carte", with "verso → recto" for the reverse direction) as its text, the group as its sub-text, and two buttons, "Correct" and "Again". An extra reminder shows the same card with a "no effect on the schedule" mention.

### Answering from the notification

The buttons are handled in a background isolate, app open or not, by `NotificationActionHandler`. The answer goes through `ReviewService`, exactly like an in-app session ([Feature 5](5-session.md#answer)), with the notification as its source:

- "Correct" records the answer and closes the notification;
- "Again" records the failure and replaces the notification in place with the expected answer, what the failure did ("Compté raté · retour au cran 1, revue demain") and an "OK" button that closes it;
- answering an extra reminder is always a [bonus review](../lexicon.md#bonus-review);
- a card deleted meanwhile only closes the notification.

Touching the notification itself opens the app.

### Typed answer

A preset with the typed answer option replaces "Correct" with "Answer" (*Répondre*), which opens a text field in the notification; "Again" stays. A card whose answer face has no text keeps "Correct", having nothing to compare with.

The typed answer is compared with the answer face by `TypedAnswerMatch`, in the domain:

- case, accents, spaces, hyphens and apostrophes are ignored: "oulan bator" is "Oulan-Bator", "coeur" is "cœur";
- one typo is forgiven: a letter missing, added or replaced, or two neighbouring letters swapped;
- no typo is forgiven on an answer of fewer than 4 characters, nor on a digit, so that "Lia" is not "Lim" and "1788" is not "1789".

An accepted answer is recorded as "Correct", a refused one as "Again". In both cases the notification is replaced by the expected answer, how the typed answer compared and what the answer did ("« canbera » accepté, 1 faute · prochain rappel demain"), with "OK".

### Exact alarms, restarts and permissions

Exact alarms need a permission that Android 14 refuses by default. Without it, wake-ups are scheduled as inexact alarms, which Android may deliver a few minutes late, and Settings shows a "Reminders at the exact time" panel with an "Allow" button opening the system page. Back in the app, the permission is read again and, when it changed, every wake-up is scheduled again with the new precision.

Wake-ups survive a restart of the phone: the alarm plugin restores them at boot, and a wake-up whose moment passed while the phone was off fires right away, showing what is less than an hour late. Every launch of the app also schedules all wake-ups again, since a force-stop loses them.

The notification permission of Android 13 is asked at launch until the onboarding takes it over.

## Acceptance criteria

- [x] A started card is notified at its preset slot, without the app being open.
- [x] The notification shows the asked face, the step and the group, with "Correct" and "Again".
- [x] "Correct" records the answer from the notification and closes it; "Again" records the failure and shows the answer, the new step and the next review, with "OK".
- [x] A card reviewed in the app before its slot is not notified, and a notification already shown is withdrawn.
- [x] A suspended card is never notified; a reminder more than an hour late is not shown.
- [x] A "Review soon" reminder is notified at its moment, and its answer is a bonus review.
- [x] Without the exact alarm permission, reminders are still planned as inexact alarms, and Settings offers to allow exact alarms.
- [x] Wake-ups are planned again after a phone restart and at each launch.
- [x] With the typed answer option, the card is answered in a field of the notification; the comparison ignores case, accents and spaces and forgives one typo, then the expected answer is shown with "OK".

## Test strategy

- The timing rules (shown once, within an hour, wake-ups rounded and capped) and the typed answer comparison are tested as pure domain logic.
- The planner, the dispatcher and the action handler are tested together on an in-memory database, through the same providers as the app, with in-memory fakes of the three platform interfaces that behave like an alarm manager and a notification shade.
- The notification texts and the payload carried by a notification are tested without a device.
- The exact alarm panel is tested on screen, with a golden test of the refused state.
- The Android implementation itself (alarm plugin, notification plugin, background isolates) is not covered by automated tests: it is checked on a phone.

## File mapping

- `lib/domain/notifications/` — when to show a reminder and when to wake up.
- `lib/domain/reviews/typed_answer_match.dart` — comparison of a typed answer.
- `lib/application/notifications/` — the platform interfaces, the planner, the dispatcher, the action handler and their providers.
- `lib/notifications/` — notification texts and the store of planned wake-ups.
- `lib/notifications/android/` — Android implementations, wiring and background entry points.
- `lib/features/settings/exact_alarms_panel.dart` — the exact alarm panel of Settings.
- `lib/main.dart` — initialisation, permission request and planning at launch.

## Technical details

The alarm id of a wake-up is its minute since the epoch, so two plannings agree on the id of a moment without sharing state. The notification id of a card is its direction id; extra reminders use ids from 1,000,000,000 upwards so that they never replace the notification of a due card. A notification carries its key (direction, extra reminder, prompt or answer) in its payload, which is how the planner finds the cards shown and how a pressed button finds the direction it answers.

The "Again" and "Answer" buttons do not let the plugin close the notification, so that the answer replaces it in place; the replaced notification only alerts once. The text typed in the field reaches the background isolate in the `input` of the notification response.

`android_alarm_manager_plus` drops an exact alarm without the permission instead of falling back by itself: the scheduler asks for an exact alarm only when `canScheduleExactNotifications` says it is allowed.

The background isolates open the database with the same shared connection as the app, so the screens of an open app follow an answer given from a notification.

## Constraints

- The application layer never imports a notification or alarm plugin: only `lib/notifications/` does.
