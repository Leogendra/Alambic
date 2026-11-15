# Changelog

All visible changes to Alambic are listed here. Format: [Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

- Main navigation with four tabs and a card creation button, in light and dark theme.
- Standard (1 day to 6 months) and Intensive (10 min to 1 week) presets, created on first launch.
- Preset list and editor in Settings: create, edit and duplicate a preset, and choose the global preset.
- Creation and editing of text cards, in a group or not, with the "Also in the other direction" option and a card-specific preset. A new card is not scheduled until it is started: "Start all" on a group page makes its new cards due today.
- Groups tab: "No group", list of groups with their due cards, card search, group page and group settings (name, preset, deletion of the group with its cards).
- Bulk add: paste one card per line into a group, with an editable separator (`;` by default) and a report of the skipped lines.
- Home tab: number of due cards with an estimated duration and the progress of the day, today's reminders, groups to review and groups with new cards to start.
- Card sheet: both faces, step, next review and history of each direction, with Review soon (one-off reminder), Suspend / Resume, Reset and starting a direction.
- Notifications: a started card arrives at its preset slot with Correct / Again buttons, answered without opening the app; Again shows the expected answer and the next review. A card reviewed in the app before its slot is not notified twice. "Review soon" reminders are notified too.
- Reminders survive a phone restart. Without the exact alarm permission they may arrive a few minutes late, and Settings offers to allow exact alarms.
- Distillation: "Distill" on a group page introduces its new cards a few at a time ("N cards every X days", in group or random order), even with the app closed. "Avoid collisions" gives it a daily budget: reminders first, new cards in what is left. The group page follows each distillation with pause and stop; Home shows the day's "New knowledge". Cards added to the group join the end of the queue, and the cards left by a stopped distillation can be started by hand.
- Global distillation, from Settings: every new card of every group, in both directions and in random order, the reverse of a card always after its front. It replaces the group distillations in progress and blocks new ones until it is stopped.
- Typed answer in the notification, for presets with this option: the answer is accepted despite case, accents, spaces and one typo, then the expected answer is shown.
- Grouped reminder, for presets in this mode: one notification per group with its number of due cards, which opens the app on the group or chains the cards inside the notification.
- Time range schedule: the notifications of the day are spread evenly over the range, and Home's timeline shows them at their moment.
- A notification ignored or swiped is sent again the next day at the preset slot.
- Notification safeguards in Settings: a daily cap that holds back the longest intervals first, quiet hours (22:00 to 08:00 by default) and auto grouping of a busy moment into a single notification.
- Pause of a group, from its settings or its page, and global pause, from Settings or Home: nothing is notified and distillations wait; on resume, due dates move by the length of the pause.
- Adaptive preset (FSRS), shipped at a 90 % target retention: each interval is computed from the answers. The preset editor switches a preset between a fixed sequence and the adaptive engine, and sets its target retention. Moving cards to a preset with the other engine starts their progression over, keeping their due dates and history.
- Images on cards: each face takes a picture from the gallery, alone or with a text. It shows on the card sheet, in the lists, in a session and in the expanded notification.
- In-app review session: answer revealed on tap, Correct / Again buttons showing the next due date, end screen and bonus review of the missed cards.
- App icon on the home screen, following the phone's icon shape and its themed icons, and in the notifications' status bar.
