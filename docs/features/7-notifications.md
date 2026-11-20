# Feature 7 — Notifications

Status: in progress (2026-11-20)

## Goal

Make the notification the main way to review: a card arrives at the [daily slot](../lexicon.md#daily-slot), is answered with "Correct" or "Again", after revealing its answer or not, or with a typed answer, without opening the app, and the next review is planned at once. The app can instead gather the due cards of a group in a single grouped reminder, or spread its notifications over a time range. Safeguards set in Settings keep the whole within a daily cap, outside quiet hours, and gather the notifications of a busy moment into one. A group, or everything, can be paused.

## Implementation overview

### Layers

The application decides what to notify and when; a platform layer decides how. Three interfaces, owned by the application, stand between them, so that iOS can become a second implementation without touching the rules:

- `AlarmScheduler` wakes the app up at a moment, app closed or not, and says whether it can do so at the exact minute;
- `NotificationPresenter` shows a card, replaces it with its answer, withdraws it, and lists the cards currently shown;
- `PlannedAlarmStore` remembers the wake-ups scheduled last time.

`lib/notifications/android/` implements them with `android_alarm_manager_plus`, `flutter_local_notifications` and `shared_preferences`. The texts of a notification come from `ReviewTexts`, which is not tied to a platform.

### Schedule and mode

The [schedule](../lexicon.md#schedule) and the notification mode are set once for the whole app, in the Notifications section of Settings: "Schedule" (a fixed time, 12:00 by default, or a time range, 9:00 to 18:00 when first chosen) and "Notification mode" (one notification per card by default, or a grouped reminder per group that opens the app or chains the cards). No group nor preset has its own. The end of a range never precedes its start, so a range does not run past midnight: a time that would break this order is refused with a message and nothing is saved, and the settings service refuses such a range whatever its caller. They are stored in `app_settings`, where the background tasks read them, and each change is saved at once and plans the wake-ups again.

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

A card still due from an earlier day is notified again today, at the daily slot: its notification was ignored or swiped, or could not be shown that day. It never counts as an answer, neither a success nor a failure. "Notified" is therefore kept per day: a card notified yesterday and still due is notified again today, once.

Then, with a time range in one-notification-per-card mode: the cards due at the start of the range on a day are spread evenly over the range, in the order of their ids. With 4 cards and a 9:00 – 17:00 range, they arrive at 9:00, 11:00, 13:00 and 15:00; the moments are rounded down to the minute. A grouped reminder stays at the start of the range, and so does a due date after an interval of less than a day, which keeps its own moment.

The spreading depends on the cards due that day: when a card is answered in the app before its notification, the others of the range move. A notification that moves to a moment already passed is shown at once, through a wake-up planned for the next minute.

Home's timeline lists the same moments, so a range shows one line per notification.

### Safeguards

Three safeguards, set in Settings › Notifications › Garde-fous and stored in the database (`NotificationGuards`), apply to every group. `DeliveryPlanner` applies the first two to the notification moments, the dispatcher the third:

- **Quiet hours** ("Do not disturb", on by default, 22:00 to 08:00): a notification falling inside is moved to their end, 23:10 to 08:00 the next morning. The hours may span midnight or stay within a day. A notification moved to the next morning keeps that moment even though its due day is over.
- **Daily cap** (20 cards by default): each day, the cards beyond the cap are not notified; the ones waiting the longest interval of their sequence go last, a new card counting as the shortest. They are moved to the slot of the next day, where they compete again. The cards already notified that day count against the cap, through a counter of the day kept in `app_settings`, since a card answered loses the trace of its notification. A card in a grouped reminder counts as one card; "Review soon" reminders are not counted.
- **Auto grouping** (on by default, beyond 5): when a wake-up has more notifications to show than the threshold, card notifications and grouped reminders together, a single notification replaces them, "12 cards to review", naming the groups and the estimated time. Touching it opens a session on every due card. Its count follows the answers given in the app: it counts the cards notified that day that are still due, and closes when none is left.

The Garde-fous screen saves each change at once and plans the wake-ups again. Under the cap, it shows tomorrow's load: the cards due tomorrow, how many fit under the cap and how many would be moved to the day after.

### Pauses

A pause, of a distillation or global, only holds back new cards ([Feature 8](8-distillation.md#pause)): every introduced card keeps being notified, "Review soon" reminders included, and no due date moves. The global pause only removes the wake-ups planned for the distillations.

### Showing a card

When the app wakes up, `NotificationDispatcher` first runs the daily pass of the distillations, which may introduce cards, then shows one notification per card whose notification moment has come and that was not notified yet for this due date, then marks it notified and plans again. A notification that could not be shown at its moment, the phone being off or the alarm held back, is shown as soon as the app wakes up, whatever the delay. During the quiet hours it waits for their end; when that end falls on the next day, the card comes back at the slot of that day, like an ignored one.

The notification shows the name of the group in its header, beside the name of the app, the asked face as its title ("What does this image show?" for a face that is an image alone), and three buttons, "Correct", "Again" and "Reveal". It shows nothing else: neither the step, nor the asked side, nor whether it is an extra reminder. The texts are in the language of the app ([Feature 0](0-foundation.md#language-and-theme)), read from the interface preferences by each background task.

With the [back option](../lexicon.md#back-option) of the group, the asked face is drawn when the notification is shown, one chance in two, and each chained card of a grouped reminder draws its own. The face drawn travels in the payload, so that the answer revealed and the typed answer are read against the other face.

### Showing a card's image

When the asked face has an image, the expanded notification shows it in the Android *BigPicture* style, with the face above; the collapsed notification shows the text only. Once revealed, or after a typed answer, an answer face with an image shows it the same way, under the answer ("Answer in the image" when it has no text). The presenter reads the file from the image store; a file gone shows the text alone.

### Answering from the notification

The buttons are handled in a background isolate, app open or not, by `NotificationActionHandler`. The answer goes through `ReviewService`, exactly like an in-app session ([Feature 5](5-session.md#answer)), with the notification as its source:

- "Correct" and "Again" record the answer and replace the notification in place, silently, with what the answer did, written from the delay it gave: "Next in 3 d", "Next at 15:17", or "Card learned". This line is the whole notification, and it closes by itself after 4 seconds. A chained card gives way to the next one instead;
- "Reveal" replaces the notification in place, without sound or vibration, with the answer face (its text alone, "Lima", and its image) under the asked face, and two buttons, "Correct" and "Again", which then behave as above. Nothing is recorded until one of them is pressed: a revealed notification swiped away is an ignored one, and the card stays due;
- answering an extra reminder is always a [bonus review](../lexicon.md#bonus-review), which only closes the notification;
- a card deleted meanwhile only closes the notification.

### Touching a notification

Touching the body of a notification opens a session in the app ([Feature 5](5-session.md)): notifications save time, they do not keep the user out of the app, and whoever touches one can review at once everything waiting for them.

- A card notification: that card, asking the same face as the notification, then every due card of the app.
- A card chained in a grouped reminder: that card, then the due cards of its group, then the others.
- A grouped reminder, or its "Open the app": the due cards of the group, then the others.
- The digest, or its "Open the app", the verdict of a typed answer and the line left by an answer, whose card is already answered: every due card.

The due cards are the ones a session counts as [due](../lexicon.md#due) today, earliest due first, each asked face drawn at the opening; the touched card is not asked twice. A card that is not due, such as the card of a "Review soon" reminder, is answered as a bonus review. The session opens above the root screen, closing the screens opened on it; when nothing is left to review, the app opens where it was, without a session.

### Typed answer

In a group with the [typed answer](../lexicon.md#typed-answer) option, the buttons are "Again", "Reveal" and "Answer", which opens a text field in the notification. "Again" and "Reveal" behave as on any card. A card whose answer face has no text gets the usual buttons, having nothing to compare with.

The typed answer is compared with the answer face by `TypedAnswerMatch`, in the domain, through `ReviewService.answerTyped`, which a session uses too ([Feature 5](5-session.md#typed-answer)):

- case, accents, spaces, hyphens and apostrophes are ignored: "port au prince" is "Port-au-Prince", "coeur" is "cœur";
- one typo is forgiven: a letter missing, added or replaced, or two neighbouring letters swapped;
- no typo is forgiven on an answer of fewer than 4 characters, nor on a digit, so that "Lia" is not "Lim" and "1788" is not "1789".

An accepted answer is recorded as "Correct", a refused one as "Again". In both cases the notification is replaced by the expected answer, how the typed answer compared and what the answer did (`"canbera" accepted, 1 typo · Next tomorrow`, `"Quito" refused · Next tomorrow`), with "OK" to close it; a bonus review shows the comparison alone. Unlike the line left by "Correct" and "Again", it stays until "OK": the user has to know whether the typed answer was accepted.

### Grouped reminder

In grouped reminder mode, every group announces its due cards with a single notification, "Capitals: 5 cards to review", with the estimated time ("About 3 min"). `GroupedReminders` builds it: the dispatcher marks each due card as notified, as usual, then shows the reminder of its group instead of a notification of its own.

The count is the number of cards of the group whose due moment has passed. When it changes because a card was answered in the app, the planner refreshes it without ringing again, and closes the reminder once no card is left.

What the reminder offers is set with the mode:

- open the app (default): touching the notification or "Open the app" opens a session on the due cards of the group, then the others;
- chain the cards: "Start here" replaces the reminder with the first card, the earliest due. Each answer replaces it with the next card, with "Capitals · 3 to review" as its header and the same buttons as a card notification, "Reveal" included; there is no room left for a button opening the app. The "OK" of a typed answer's verdict moves on. The notification closes after the last card. A chained card answered in the app gives way to the next one.

### Exact alarms, restarts and permissions

Exact alarms need a permission that Android 14 refuses by default. Without it, wake-ups are scheduled as inexact alarms, which Android may deliver a few minutes late, and Settings shows a "Reminders at the exact time" panel with an "Allow" button opening the system page. Back in the app, the permission is read again and, when it changed, every wake-up is scheduled again with the new precision.

Wake-ups survive a restart of the phone: the alarm plugin restores them at boot, and a wake-up whose moment passed while the phone was off fires right away, showing everything late. A missed 4am wake-up of a distillation fires the same way, so the day's batch comes out at restart ([Feature 8](8-distillation.md#rhythm)). Every launch of the app also schedules all wake-ups again, since a force-stop loses them.

The notification permission of Android 13 and exact alarms are both asked on the second welcome screen ([Feature 10](10-onboarding.md)). A user who refused can still allow exact alarms from Settings, and notifications from the system settings of the app.

## Acceptance criteria

- [x] An introduced card is notified at the [daily slot](../lexicon.md#daily-slot), without the app being open.
- [x] The notification shows the name of the group in its header and the asked face, nothing else, with "Correct", "Again" and "Reveal".
- [x] A face with an image shows it in the expanded notification, text only when collapsed; so does an answer face with an image once revealed.
- [x] "Correct" and "Again" record the answer from the notification, revealed or not, and replace it with the next review ("Next in 3 d"), which closes by itself; a bonus review only closes it.
- [x] "Reveal" shows the answer alone in place, silently, with "Correct" and "Again", and records nothing.
- [x] A card reviewed in the app before its slot is not notified, and a notification already shown is withdrawn.
- [x] A suspended card is never notified.
- [x] A notification that could not be shown at its moment is shown when the phone is back on, whatever the delay, outside the quiet hours.
- [x] A notification ignored or swiped is sent again the next day at the [daily slot](../lexicon.md#daily-slot), without any effect on the step.
- [x] A "Review soon" reminder is notified at its moment, and its answer is a bonus review.
- [x] Without the exact alarm permission, reminders are still planned as inexact alarms, and Settings offers to allow exact alarms.
- [x] Wake-ups are planned again after a phone restart and at each launch.
- [x] With the typed answer option, the card is answered in a field of the notification; the buttons are "Again", "Reveal" and "Answer"; the comparison ignores case, accents and spaces and forgives one typo, then the verdict and the expected answer are shown with "OK".
- [x] In grouped reminder mode, the due cards of a group are announced by one notification with their count, which opens a session starting with them.
- [x] With chaining, the cards of the reminder are answered one after the other inside the notification, with the buttons of a card notification.
- [x] A grouped reminder follows the answers given in the app, and closes when no card is left.
- [x] With a time range, the cards of the day are notified one by one, spread evenly over the range; a grouped reminder arrives at the start of the range.
- [x] A time range whose end would precede its start cannot be entered.
- [x] Beyond the daily cap, the cards waiting the longest intervals are not notified that day and come back the next day.
- [x] A notification falling in the quiet hours arrives at their end.
- [x] Beyond the auto grouping threshold, the notifications of a moment are replaced by a single one.
- [x] Touching a notification opens a session: its card, or the due cards of its group, first, then every due card.
- [x] The safeguards are set in Settings, with tomorrow's load shown against the cap.
- [x] The schedule and the notification mode are set once in Settings and apply to every group; a new daily slot moves the due dates set at the old one.
- [x] A pause, of a distillation or global, changes no notification and moves no due date.

## Test strategy

- The timing rules (shown once, however late, wake-ups rounded and capped), the notification moments and the typed answer comparison are tested as pure domain logic.
- The planner, the dispatcher and the action handler are tested together on an in-memory database, through the same providers as the app, with in-memory fakes of the three platform interfaces that behave like an alarm manager and a notification shade.
- Each button is tested through the action handler: "Correct" and "Again" record and leave the next review, a bonus review closes; "Reveal" shows the answer and records nothing, then its "Correct" or "Again"; the typed answer with its verdict, "Again" and "Reveal"; "Reveal" and "Again" on a chained card.
- The notification texts and the payload carried by a notification, including what a touched notification opens, are tested without a device.
- The content of the session opened by each kind of notification is tested on an in-memory database with a fixed clock: its card or group first, then every due card, earliest first, without repeating the touched card.
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
- `lib/app/shell/main_shell.dart` — opens the session of a touched notification.
- `lib/main.dart` — initialisation and planning at launch.

## Technical details

The alarm id of a wake-up is its minute since the epoch, so two plannings agree on the id of a moment without sharing state. The notification id of a card is its card id; extra reminders use ids from 1,000,000,000 upwards so that they never replace the notification of a due card; the digest of a moment uses 2,000,000,000; the grouped reminder of a group uses the negative id `-1 - groupId`, and the cards chained in it take the same id, so that each one replaces the previous. A notification carries its key (card, extra reminder, chained group, prompt or answer, the [asked side](../lexicon.md#asked-side), or the group and count of a grouped reminder) in its payload, which is how the planner finds the notifications shown and how a pressed button finds what it answers.

"Open the app" and touching a grouped reminder launch the app instead of a background isolate: the plugin hands the response to the running app, or to the launch details when the notification started it. `notificationTargetsProvider` turns both into a stream of `NotificationTarget`, read from the payload, which the main shell follows; `NotificationSession` turns a target into the items of the session. The due cards are read from the database, not from the screens' providers, which are still loading when a notification launches the app.

No answer button lets the plugin close the notification, so that the answer, the verdict, the next review or the next card replaces it in place. The next review carries a payload that is not a prompt, so the planner never withdraws it; Android removes it after its timeout (`timeoutAfter`). The revealed notification is silent and alerts only once; it stays a prompt in its payload, so that the planner withdraws it like any other once its card is answered in the app. The text typed in the field reaches the background isolate in the `input` of the notification response.

`android_alarm_manager_plus` drops an exact alarm without the permission instead of falling back by itself: the scheduler asks for an exact alarm only when `canScheduleExactNotifications` says it is allowed.

The background isolates open the database with the same shared connection as the app, so the screens of an open app follow an answer given from a notification.

## Constraints

- The application layer never imports a notification or alarm plugin: only `lib/notifications/` does.
