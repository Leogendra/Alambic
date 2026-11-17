# Feature 7 — Notifications

Status: in progress (2026-11-16)

## Goal

Make the notification the main way to review: a card arrives at the [daily slot](../lexicon.md#daily-slot), is answered with "Correct" or "Again", or with a typed answer, without opening the app, and the next review is planned at once. The app can instead gather the due cards of a group in a single grouped reminder, or spread its notifications over a time range. Safeguards set in Settings keep the whole within a daily cap, outside quiet hours, and gather the notifications of a busy moment into one. A group, or everything, can be paused.

## Implementation overview

### Layers

The application decides what to notify and when; a platform layer decides how. Three interfaces, owned by the application, stand between them, so that iOS can become a second implementation without touching the rules:

- `AlarmScheduler` wakes the app up at a moment, app closed or not, and says whether it can do so at the exact minute;
- `NotificationPresenter` shows a card, replaces it with its answer, withdraws it, and lists the cards currently shown;
- `PlannedAlarmStore` remembers the wake-ups scheduled last time.

`lib/notifications/android/` implements them with `android_alarm_manager_plus`, `flutter_local_notifications` and `shared_preferences`. The texts of a notification come from `ReviewTexts`, which is not tied to a platform.

### Schedule and mode

The [schedule](../lexicon.md#schedule) and the notification mode are set once for the whole app, in the Notifications section of Settings: "Horaire" (a fixed time, 12:00 by default, or a time range, 9:00 to 18:00 when first chosen) and "Mode de notification" (one notification per card by default, or a grouped reminder per group that opens the app or chains the cards). No group nor preset has its own. They are stored in `app_settings`, where the background tasks read them, and each change is saved at once and plans the wake-ups again.

A due date is a moment, written when a card is answered, so changing the daily slot would leave the dates already set at the old time. The settings service therefore moves every due date still to come that falls on the old slot to the new slot of the same day (`DailySlotMove`). A due date at another time of day comes from an interval of less than a day and keeps its moment; a due date already passed is left alone, the card being due anyway.

### Planning the wake-ups

`NotificationPlanner` listens to every schedule change: an answer, an introduction, a reset, a suspension, a deletion, a reminder added or removed. Each time, it computes the next wake-ups from the [notification moments](../lexicon.md#notification-moment) of the scheduled, non-suspended cards and from the upcoming [extra reminders](../lexicon.md#extra-reminder), plus the start of the next day each running [distillation](8-distillation.md) has to process, and the slot of the next day for every card still due whose moment has passed, so that an ignored card is sent again even when nothing else wakes the app:

- one wake-up per distinct minute, a due moment with seconds (after a sub-day interval) being rounded up to the next minute;
- at most 48 wake-ups ahead, since each wake-up plans the next ones;
- only the difference with the previous planning is cancelled and scheduled.

A wake-up only says "look at what is due now". The content of the notification is read from the database when it fires, never fixed at planning time, so a card edited or answered meanwhile is shown as it is.

The planner also withdraws the notifications of cards that are no longer [due](../lexicon.md#due). A card reviewed in the app at 8:00 loses both its 12:00 wake-up, since its due date moved, and any notification already on screen. It never gets a duplicate reminder.

### Notification moment

`DeliveryPlanner`, in the domain, decides when each scheduled card is notified. The moment is its due date, with two exceptions.

A card still due from an earlier day is notified again today, at the daily slot: its notification was ignored or swiped, or was not shown because it was found too late. It never counts as an answer, neither a success nor a failure. "Notified" is therefore kept per day: a card notified yesterday and still due is notified again today, once.

Then, with a time range in one-notification-per-card mode: the cards due at the start of the range on a day are spread evenly over the range, in the order of their ids. With 4 cards and a 9:00 – 17:00 range, they arrive at 9:00, 11:00, 13:00 and 15:00; the moments are rounded down to the minute. A grouped reminder stays at the start of the range, and so does a due date after an interval of less than a day, which keeps its own moment.

The spreading depends on the cards due that day: when a card is answered in the app before its notification, the others of the range move. A notification that moves to a moment already passed is shown at once, through a wake-up planned for the next minute.

Home's timeline lists the same moments, so a range shows one line per notification.

### Safeguards

Three safeguards, set in Settings › Notifications › Garde-fous and stored in the database (`NotificationGuards`), apply to every group. `DeliveryPlanner` applies the first two to the notification moments, the dispatcher the third:

- **Quiet hours** (*ne pas déranger*, on by default, 22:00 to 08:00): a notification falling inside is moved to their end, 23:10 to 08:00 the next morning. The hours may span midnight or stay within a day. A notification moved to the next morning keeps that moment even though its due day is over.
- **Daily cap** (20 cards by default): each day, the cards beyond the cap are not notified; the ones waiting the longest interval of their sequence go last, a new card counting as the shortest. They are moved to the slot of the next day, where they compete again. The cards already notified that day count against the cap, through a counter of the day kept in `app_settings`, since a card answered loses the trace of its notification. A card in a grouped reminder counts as one card; "Review soon" reminders are not counted.
- **Auto grouping** (on by default, beyond 5): when a wake-up has more notifications to show than the threshold, card notifications and grouped reminders together, a single notification replaces them, "12 cartes à réviser", naming the groups and the estimated time. Touching it opens Home. Its count follows the answers given in the app: it counts the cards notified that day that are still due, and closes when none is left.

The Garde-fous screen saves each change at once and plans the wake-ups again. Under the cap, it shows tomorrow's load: the cards due tomorrow, how many fit under the cap and how many would be moved to the day after.

### Pauses

A group is paused from its settings or its page, everything from Settings › Notifications or the pause button of Home. `PauseService` stores the start of the pause (`card_groups.paused_at`, `app_settings.paused_at`) and plans the wake-ups again.

During a pause, the paused cards are no longer candidates for a notification, so no wake-up is planned for them, no grouped reminder counts them, Home's timeline announces no new card for their group and their "Review soon" reminders are dropped. The distillation of a paused group, and every distillation during the global pause, introduce nothing; on resume, the next daily pass introduces the batch due, without catching up the days missed. The cards stay reviewable in the app.

On resume, `PauseShift`, in the domain, moves the due date of every scheduled card by the number of scheduling days the pause lasted, keeping its time: a card due on the 12th, in a pause from the 10th to the 14th, comes back on the 16th. A card answered during the pause keeps the due date chosen then, and a pause shorter than a day moves nothing. Resuming the global pause leaves alone the groups still paused on their own: their resume shifts them by their whole pause.

### Showing a card

When the app wakes up, `NotificationDispatcher` first runs the daily pass of the distillations, which may introduce cards, then shows one notification per card whose notification moment has come and that was not notified yet for this due date, then marks it notified and plans again. A reminder found more than one hour late is not shown: the phone was off or the alarm was held back, and a notification hours late would be noise. The card stays due in the app, and is notified again the next day at its slot.

The notification shows the asked face as its title ("Que montre cette image ?" for a face that is an image alone), the [reminder label](../lexicon.md#reminder-label) ("J2" or "Nouvelle carte", with "verso → recto" when the back is asked) as its text, the group as its sub-text, and two buttons, "Correct" and "Again". An extra reminder shows the same card with a "no effect on the schedule" mention. The texts are in the language of the app ([Feature 0](0-foundation.md#language-and-theme)), read from the interface preferences by each background task.

With the [back option](../lexicon.md#back-option) of the group, the asked face is drawn when the notification is shown, one chance in two, and each chained card of a grouped reminder draws its own. The face drawn travels in the payload, so that the answer revealed after "Again" and the typed answer are read against the other face.

### Showing a card's image

When the asked face has an image, the expanded notification shows it in the Android *BigPicture* style, with the face and its step above; the collapsed notification shows the text only. After "Again" or a typed answer, an answer face with an image shows it the same way, under the answer and the verdict ("Réponse en image" when it has no text). The presenter reads the file from the image store; a file gone shows the text alone.

### Answering from the notification

The buttons are handled in a background isolate, app open or not, by `NotificationActionHandler`. The answer goes through `ReviewService`, exactly like an in-app session ([Feature 5](5-session.md#answer)), with the notification as its source:

- "Correct" records the answer and closes the notification;
- "Again" records the failure and replaces the notification in place with the expected answer, what the failure did ("Compté raté · retour à J1, revue demain") and an "OK" button that closes it;
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

### Grouped reminder

In grouped reminder mode, every group announces its due cards with a single notification, "Capitales : 5 cartes à réviser", with the estimated time ("Environ 3 min"). `GroupedReminders` builds it: the dispatcher marks each due card as notified, as usual, then shows the reminder of its group instead of a notification of its own.

The count is the number of cards of the group whose due moment has passed. When it changes because a card was answered in the app, the planner refreshes it without ringing again, and closes the reminder once no card is left.

What the reminder offers is set with the mode:

- open the app (default): touching the notification or "Ouvrir l'app" opens the app on the group page;
- chain the cards: "Commencer ici" replaces the reminder with the first card, the earliest due. Each answer replaces it with the next card, with "Capitales · 3 à réviser" as sub-text and an "Ouvrir" button to switch to the app; "Again" first shows the expected answer, and its "OK" moves on. The notification closes after the last card. A chained card answered in the app gives way to the next one.

### Exact alarms, restarts and permissions

Exact alarms need a permission that Android 14 refuses by default. Without it, wake-ups are scheduled as inexact alarms, which Android may deliver a few minutes late, and Settings shows a "Reminders at the exact time" panel with an "Allow" button opening the system page. Back in the app, the permission is read again and, when it changed, every wake-up is scheduled again with the new precision.

Wake-ups survive a restart of the phone: the alarm plugin restores them at boot, and a wake-up whose moment passed while the phone was off fires right away, showing what is less than an hour late. Every launch of the app also schedules all wake-ups again, since a force-stop loses them.

The notification permission of Android 13 and exact alarms are both asked on the second welcome screen ([Feature 10](10-onboarding.md)). A user who refused can still allow exact alarms from Settings, and notifications from the system settings of the app.

## Acceptance criteria

- [x] An introduced card is notified at the [daily slot](../lexicon.md#daily-slot), without the app being open.
- [x] The notification shows the asked face, the reminder label and the group, with "Correct" and "Again".
- [x] A face with an image shows it in the expanded notification, text only when collapsed; so does an answer face with an image after "Again".
- [x] "Correct" records the answer from the notification and closes it; "Again" records the failure and shows the answer, the new step and the next review, with "OK".
- [x] A card reviewed in the app before its slot is not notified, and a notification already shown is withdrawn.
- [x] A suspended card is never notified; a reminder more than an hour late is not shown.
- [x] A notification ignored or swiped, or not shown for being late, is sent again the next day at the [daily slot](../lexicon.md#daily-slot), without any effect on the step.
- [x] A "Review soon" reminder is notified at its moment, and its answer is a bonus review.
- [x] Without the exact alarm permission, reminders are still planned as inexact alarms, and Settings offers to allow exact alarms.
- [x] Wake-ups are planned again after a phone restart and at each launch.
- [x] With the typed answer option, the card is answered in a field of the notification; the comparison ignores case, accents and spaces and forgives one typo, then the expected answer is shown with "OK".
- [x] In grouped reminder mode, the due cards of a group are announced by one notification with their count, which opens the app on the group.
- [x] With chaining, the cards of the reminder are answered one after the other inside the notification, with "Open" to switch to the app.
- [x] A grouped reminder follows the answers given in the app, and closes when no card is left.
- [x] With a time range, the cards of the day are notified one by one, spread evenly over the range; a grouped reminder arrives at the start of the range.
- [x] Beyond the daily cap, the cards waiting the longest intervals are not notified that day and come back the next day.
- [x] A notification falling in the quiet hours arrives at their end.
- [x] Beyond the auto grouping threshold, the notifications of a moment are replaced by a single one that opens Home.
- [x] The safeguards are set in Settings, with tomorrow's load shown against the cap.
- [x] The schedule and the notification mode are set once in Settings and apply to every group; a new daily slot moves the due dates set at the old one.
- [x] A paused group, or every card during the global pause, is not notified and its distillations wait; on resume, its due dates move by the length of the pause, except those of cards answered meanwhile.

## Test strategy

- The timing rules (shown once, within an hour, wake-ups rounded and capped), the notification moments and the typed answer comparison are tested as pure domain logic.
- The planner, the dispatcher and the action handler are tested together on an in-memory database, through the same providers as the app, with in-memory fakes of the three platform interfaces that behave like an alarm manager and a notification shade.
- The notification texts and the payload carried by a notification are tested without a device.
- The exact alarm panel is tested on screen, with a golden test of the refused state; the safeguards, schedule and notification mode screens have golden tests too, and their changes are checked in the database.
- Moving the due dates to a new slot is tested as pure domain logic, then through the settings service on an in-memory database.
- The Android implementation itself (alarm plugin, notification plugin, background isolates) is not covered by automated tests: it is checked on a phone.

## File mapping

- `lib/domain/notifications/` — when each card is notified, when to show a reminder and when to wake up.
- `lib/domain/reviews/typed_answer_match.dart` — comparison of a typed answer.
- `lib/application/notifications/` — the platform interfaces, the planner, the dispatcher, the grouped reminders, the action handler and their providers.
- `lib/notifications/` — notification texts and the store of planned wake-ups.
- `lib/notifications/android/` — Android implementations, wiring and background entry points.
- `lib/features/settings/` — the exact alarm panel, the schedule, notification mode and safeguards screens.
- `lib/data/repositories/notification_settings_repository.dart` — the schedule, the mode, the safeguards and the count of cards notified today.
- `lib/domain/pauses/`, `lib/application/pauses/`, `lib/data/repositories/pause_repository.dart` — the pauses, their shift on resume, their service and storage.
- `lib/features/pauses/paused_banner.dart` — "En pause depuis le …" with "Reprendre", on Home and on a group page.
- `lib/app/shell/main_shell.dart` — opens the group of a grouped reminder touched in the notifications.
- `lib/main.dart` — initialisation and planning at launch.

## Technical details

The alarm id of a wake-up is its minute since the epoch, so two plannings agree on the id of a moment without sharing state. The notification id of a card is its card id; extra reminders use ids from 1,000,000,000 upwards so that they never replace the notification of a due card; the digest of a moment uses 2,000,000,000; the grouped reminder of a group uses the negative id `-1 - groupId`, and the cards chained in it take the same id, so that each one replaces the previous. A notification carries its key (card, extra reminder, chained group, prompt or answer, the [asked side](../lexicon.md#asked-side), or the group and count of a grouped reminder) in its payload, which is how the planner finds the notifications shown and how a pressed button finds what it answers.

"Open" and touching a grouped reminder launch the app instead of a background isolate: the plugin hands the response to the running app, or to the launch details when the notification started it. `notificationTargetsProvider` turns both into a stream of groups to open, which the main shell follows.

The "Again" and "Answer" buttons do not let the plugin close the notification, so that the answer replaces it in place; the replaced notification only alerts once. The text typed in the field reaches the background isolate in the `input` of the notification response.

`android_alarm_manager_plus` drops an exact alarm without the permission instead of falling back by itself: the scheduler asks for an exact alarm only when `canScheduleExactNotifications` says it is allowed.

The background isolates open the database with the same shared connection as the app, so the screens of an open app follow an answer given from a notification.

## Constraints

- The application layer never imports a notification or alarm plugin: only `lib/notifications/` does.
