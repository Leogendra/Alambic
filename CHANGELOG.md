# Changelog

All visible changes to Alambic are listed here. Format: [Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

- Main navigation with three tabs and a card creation button, in a flat light and dark theme, with outlines instead of shadows. The active tab is marked by a bar across its top.
- Standard (1 day to 6 months) and Intensive (10 min to 1 week) presets, created on first launch.
- Presets screen, from a single row of Settings: one tile per preset with its steps and failure behaviour, "Edit", "Make default" and "Duplicate" or "Delete" from its menu, and "New preset" at the end of the list. The editor lists the steps as a timeline, from the nearest to the furthest, in hours to years, and the failure behaviour is chosen among three tiles, "Back to start", "One step back" and "Same step", each saying what a missed card does. Every group follows one preset, the default one when it is created; making another preset the default moves no existing group. Deleting a preset moves the groups that use it to the default preset, keeping their progress.
- Creation and editing of text cards, each in a group. The group row creates a new group from its name with "+". A new card waits in its group's queue until the group's distillation brings it in.
- Groups tab: list of groups, one row each with its number of cards, "distillation" when it distills and its due cards, card search, group page and group settings (name, preset, back, typed answer, end of sequence, deletion of the group with its cards). After the last step of its preset, the cards come back every 3 months, 6 months (by default) or year, or are learned for good. A group page lists its cards in three sections, with "Review all" beside the first title: in progress, soonest first; waiting, in queue order, the next card marked "next" while the group distills; and learned, folded.
- "Review all" on a group page: a session on every card of the group but the learned ones, where only the cards due today count; the others are bonus reviews. A waiting card answered "Again" goes to the head of the queue and comes out next.
- Back of a group: once enabled, each display of a card (session, notification, typed answer) asks its front or its back at random, with a single progression per card.
- Bulk add: paste one card per line into a group, chosen or created on the spot, with an editable separator (`;` by default) and a report of the skipped lines. The batch joins the end of the group's queue "In order" or shuffled, and a "First" box shows the card that will come out first.
- Home tab: a timeline of the coming cards, today first with the late ones, then the next six days, card by card with their group and the time left before it ("3H", "1D"), and one line per group for its new cards ("Capitals: 2 new cards"). Two blocks close it with the number of cards of the coming month and of the coming year.
- Card sheet: both faces, a bar of the preset steps ending with the remanence, next review and history, with Review soon (one-off reminder), Suspend / Resume and Reset, which sends the card back to its group's queue. Lists show the next date of each card ("in 3 d"), or "waiting"; no step is named anywhere, notifications included.
- Notifications: an introduced card arrives at the reminder time with Again / Reveal / Correct buttons, answered without opening the app. Reveal shows the answer in the notification, without a sound, before answering Again or Correct, and Hide asks the card again. The answer then leaves a short line, "Correct, next in 3 d" or "To review, next in 1 d". A card reviewed in the app before its slot is not notified twice. Touching a notification opens a review session on its card, or on the due cards of its group. "Review soon" reminders are notified too.
- Reminders survive a phone restart. A reminder missed because the phone was off arrives when it is turned back on, or at the end of the quiet hours. Without the exact alarm permission they may arrive a few minutes late, and Settings offers to allow exact alarms.
- Distillation: "Distill" on a group page introduces its waiting cards a few at a time, from the head of its queue ("N cards a day"), even with the app closed. It is a permanent setting of the group, adjusted, paused and resumed from its "Distill" screen, opened by the settings button of the group page; cards added later join the end of its queue. "Prioritize reviews" (on by default): each day, each card of the group due for review takes the place of a new card, and reminders are never moved. A missed day is not caught up: after days with the phone off, a single batch comes out, as soon as the phone is turned back on. The "Distill" screen estimates the day of the last arrival, which leaves room for the reviews already planned. The "Distill" screen also shows the preset the group follows, with its reminders (1 d, 2 d, 1 wk…): it can be edited there, swapped for another preset or replaced by a new one.
- Typed answer in the notification, for groups with this option, with Again / Reveal / Answer buttons: the answer is accepted despite case, accents, spaces and one typo, then a short line tells the verdict, "Correct, next in 1 d", or "To review (Lima), next in 1 d" with the expected answer.
- Grouped reminder, as the notification mode of the app: one notification per group with its number of due cards, which opens a session on the group or chains the cards inside the notification, each with the buttons of a card notification.
- Time range schedule: the notifications of the day are spread evenly over the range, and Home's timeline shows them at their moment.
- A notification ignored or swiped is sent again the next day at the reminder time.
- Schedule and notification mode in Settings, for every group at once: a fixed time (12:00 by default) or a time range (its end cannot come before its start), one notification per card or a grouped reminder. A new reminder time also moves the reminders already set at the old one.
- Notification safeguards in Settings: a daily cap that holds back the longest intervals first, quiet hours (22:00 to 08:00 by default) and auto grouping of a busy moment into a single notification.
- Pause of a distillation, from its "Distill" screen, and global pause of every distillation, from Settings, after a confirmation: no new card comes out until the resume, which brings a single batch at most. Reminders and their notifications go on, and no due date moves.
- Images on cards: each face takes a picture from the gallery, alone or with a text. It shows on the card sheet, in the lists, in a session and in the expanded notification.
- In-app review session: answer revealed on tap, Correct / Again buttons showing the next due date, end screen and bonus review of the missed cards.
- Typed answer in a session, for groups with this option: a field takes the place of "Show answer", with Reveal beside it. The answer is checked like in the notifications, recorded at once and shown with its verdict, then Next moves on.
- Export and import from Settings: all the cards, their history, the presets, the settings and the images in a single zip file saved where you choose. Importing a file replaces all the current data after a confirmation; a file that is not a valid backup is refused without changing anything.
- Welcome screens on the first launch, with "Back" and "Skip" at the top: the principle of the app (one card, multiple reminders), the distillation (waiting cards let in one a day), a card notification with the reminder time, a "Test notification" button that shows one at once, with the buttons of a real card and a single "Allow notifications" button that asks for the notification and exact alarm permissions, and a sample group to get started, the capitals of the world (197 cards, waiting, in the language of the app), created once whichever way the onboarding ends; "Get started" on its screen opens its page with "Distill" pointed out. The notification permission is no longer asked at every launch.
- The whole app in English and in French, notifications included.
- Settings as a short list of categories (Notifications, Presets, Display, Backup & restore), each opening a screen that groups its settings.
- Language and theme in Settings: the app follows the phone by default, or stays in French or English, light or dark. A phone in another language gets English. The shipped presets are named in the language of the interface until they are renamed.
- App icon on the home screen, following the phone's icon shape and its themed icons, and in the notifications' status bar.
- "About" in Settings: a link to the GitHub repository and the version of the app, at the foot of the tab. A debug build also offers to replay the onboarding.

### Removed

- The preset of a card: a card always follows the preset of its group, and the card editor no longer offers one.
- The end of sequence (including "Loop") and the typed answer in the preset editor.
- The counters at the top of a group page (due, active, waiting) and its "Review the N due" button: "Review all" starts the reviews of a group.
- The Open button of a card chained in a grouped reminder, replaced by Reveal.
- The Adaptive preset and the choice of an adaptive engine in the preset editor: every preset follows its fixed sequence of steps. The card sheet no longer shows a stability and a difficulty.

### Fixed

- The Android navigation bar no longer hides the end of a screen: every list can be scrolled above it, and the bulk add button stays visible above the keyboard.
