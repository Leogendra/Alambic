# Changelog

All visible changes to Alambic are listed here. Format: [Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/). Alambic follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-11-27

### Added

- Three tabs, Home, Groups and Settings, and a card creation button, in a flat light and dark theme.
- Text cards, each in a group, with an optional image from the gallery on each face. The card editor creates a group from its name. A new card waits in its group's queue until distillation brings it in.
- Bulk add from the "+" button: one card per line into a chosen or new group, with an editable separator (`;` by default) and a report of the skipped lines. The batch joins the end of the queue in order or shuffled.
- Presets: a sequence of reminder steps, from hours to years, and a failure behaviour: "Back to start", "One step back" or "Same step". Standard (1 day to 6 months) and Intensive (1 hour to 1 week) are shipped, and presets are created, duplicated, edited, deleted and made default from Settings. Every group follows one preset, and deleting a preset moves its groups to the default one with their progress.
- Groups tab: every group with its card count, due cards and distillation state, and a card search. "New" creates an empty group or a sample group, the capitals of the world in English or French.
- Group page: cards in progress (soonest first), waiting (in queue order, the next one marked) and learned (folded). Waiting cards are dragged to a new place, sent to the head or the end of the queue, or shuffled. "Hide the back" shows the fronts alone.
- Group settings: name, asked side (front, back or random, with a single progression per card), typed answer, and deletion of the group with its cards.
- Distillation: a group lets in its waiting cards a few a day from the head of its queue, even with the app closed. With "Prioritize reviews" (on by default), each card due for review that day takes the place of a new card. A missed day is not caught up.
- "Distill" screen of a group: sets the pace, pauses and resumes it, and estimates the day of the last arrival. It also edits, swaps or replaces the group's preset, and sets what follows the last step: a review every 3 months, 6 months (default) or year, or learned for good.
- Review sessions: the answer is revealed on tap, Correct and Again show the next due date, and the end screen offers a bonus round on the missed cards. "Review all" on a group page reviews every card but the learned ones; only today's due cards count.
- Card sheet: front, back, next date, last answers and "Review now". The step track puts the card at any step, with the date each one gives, or back in the queue. Lists show each card's next date, or "waiting".
- Typed answer, per group, in sessions and notifications: the answer is accepted despite case, accents, spaces and one typo, and the verdict comes with the expected answer.
- Card notifications at the reminder time, answered with Again, Reveal or Correct without opening the app. The answer leaves a short summary such as "Correct, next in 3 d". Touching a notification opens a session on its card or its group.
- Grouped reminder, as an alternative notification mode: one notification per group with its count of due cards, opening a session or chaining the cards inside the notification. A busy moment can also be merged into a single notification.
- Schedule: a fixed time (12:00 by default) or a time range over which the day's notifications are spread, and quiet hours (22:00 to 08:00 by default).
- A card reviewed in the app is not notified twice, and an ignored or swiped notification comes back the next day.
- Reminders survive a phone restart, and one missed while the phone was off arrives when it is back on. Settings shows refused notification and exact alarm permissions, with a way to allow them.
- "Smooth due dates" (off by default): a review due in 15 days or more moves by up to 3 days to the least busy day around it.
- Global pause from Settings: no notification and no new card until the resume, and due dates move forward one day per day of pause. Cards can still be reviewed in the app.
- Home tab: the agenda of today, late cards included, and the next six days, with the number of cards due within a month and within a year. Pulling the page down shows the number of cards notified so far.
- Export and import of all the data, images included, in a single zip file. Importing replaces the current data after a confirmation, and an invalid file changes nothing.
- Welcome screens on first launch: the principle of the app, distillation, a test notification, the permission requests and a sample group of the 197 capitals of the world. "Test notification" stays available in Settings.
- English and French throughout, notifications included. Language and theme follow the phone or are set in Settings.
- App icon following the phone's icon shape and themed icons, and shown in the status bar.
- "About" in Settings: a link to the GitHub repository and the version of the app.