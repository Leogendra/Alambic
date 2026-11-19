# Changelog

All visible changes to Alambic are listed here. Format: [Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

- Main navigation with three tabs and a card creation button, in light and dark theme. The active tab is marked by a bar across its top.
- Standard (1 day to 6 months) and Intensive (10 min to 1 week) presets, created on first launch.
- Presets screen, from a single row of Settings: one tile per preset with its steps and failure behaviour, "Edit", "Make default" and "Duplicate" or "Delete" from its menu, and "New preset" at the end of the list. Deleting a preset moves the groups that use it to the default preset, keeping their progress.
- Creation and editing of text cards, each in a group. The group row creates a new group from its name with "+". A new card waits in its group's queue until the group's distillation brings it in.
- Groups tab: list of groups, one row each with its number of cards, "distillation" when it distills and its due cards, card search, group page and group settings (name, preset, back, deletion of the group with its cards). A group page lists its cards under a "Cards" title, with "Review all" beside it, in three sections: in progress, soonest first; waiting, in queue order, the next card marked "next"; and learned, folded.
- "Review all" on a group page: a session on every card of the group but the learned ones, where only the cards due today count; the others are bonus reviews. A waiting card answered "Again" goes to the head of the queue and comes out next.
- Back of a group: once enabled, each display of a card (session, notification, typed answer) asks its front or its back at random, with a single progression per card.
- Bulk add: paste one card per line into a group, chosen or created on the spot, with an editable separator (`;` by default) and a report of the skipped lines. The batch joins the end of the group's queue "In order" or shuffled, and a "First" box shows the card that will come out first.
- Home tab: a timeline of the coming cards, today first with the late ones, then the next six days, card by card with their group and the time left before it ("3H", "1D"), and one line per group for its new cards ("Capitales: 2 new cards"). Two blocks close it with the number of cards of the coming month and of the coming year.
- Card sheet: both faces, a bar of the preset steps ending with the remanence, next review and history, with Review soon (one-off reminder), Suspend / Resume and Reset, which sends the card back to its group's queue. Lists show the next date of each card ("in 3 d"), or "waiting"; no step is named anywhere, notifications included.
- Notifications: an introduced card arrives at the reminder time with Correct / Again / Reveal buttons, answered without opening the app. Reveal shows the answer in the notification, without a sound, before answering Correct or Again. A card reviewed in the app before its slot is not notified twice. "Review soon" reminders are notified too.
- Reminders survive a phone restart. Without the exact alarm permission they may arrive a few minutes late, and Settings offers to allow exact alarms.
- Distillation: "Distill" on a group page introduces its waiting cards a few at a time, from the head of its queue ("N cards every X days"), even with the app closed. It is a permanent setting of the group, adjusted, paused and resumed from its "Distill" screen, opened by the settings button of the group page; cards added later join the end of its queue. "Prioritize reviews" (on by default): on a batch day, each card of the group due for review takes the place of a new card, and reminders are never moved. A missed batch is not caught up: after days with the phone off, a single batch comes out, as soon as the phone is turned back on. The "Distill" screen and the group page estimate the day of the last arrival, which leaves room for the reviews already planned.
- Typed answer in the notification, for groups with this option, with Again / Reveal / Answer buttons: the answer is accepted despite case, accents, spaces and one typo, then the verdict and the expected answer are shown.
- Grouped reminder, as the notification mode of the app: one notification per group with its number of due cards, which opens a session on the group or chains the cards inside the notification, each with the buttons of a card notification.
- Time range schedule: the notifications of the day are spread evenly over the range, and Home's timeline shows them at their moment.
- A notification ignored or swiped is sent again the next day at the reminder time.
- Schedule and notification mode in Settings, for every group at once: a fixed time (12:00 by default) or a time range, one notification per card or a grouped reminder. A new reminder time also moves the reminders already set at the old one.
- Notification safeguards in Settings: a daily cap that holds back the longest intervals first, quiet hours (22:00 to 08:00 by default) and auto grouping of a busy moment into a single notification.
- Pause of a distillation, from its "Distill" screen, and global pause of every distillation, from Settings or Home, after a confirmation: no new card comes out until the resume, which brings a single batch at most. Reminders and their notifications go on, and no due date moves.
- Images on cards: each face takes a picture from the gallery, alone or with a text. It shows on the card sheet, in the lists, in a session and in the expanded notification.
- In-app review session: answer revealed on tap, Correct / Again buttons showing the next due date, end screen and bonus review of the missed cards.
- Typed answer in a session, for groups with this option: a field takes the place of "Show answer", with Reveal beside it. The answer is checked like in the notifications, recorded at once and shown with its verdict, then Next moves on.
- Export and import from Settings: all the cards, their history, the presets, the settings and the images in a single zip file saved where you choose. Importing a file replaces all the current data after a confirmation; a file that is not a valid backup is refused without changing anything.
- Welcome screens on the first launch, with "Back" and "Skip" at the top: the principle of the app (one card, multiple reminders), a card notification with the reminder time and a single "Allow notifications" button that asks for the notification and exact alarm permissions, and a sample group to start with, the NATO alphabet (26 cards, waiting), created once whichever way the onboarding ends; "Next" on its screen opens its page with "Distill" pointed out. The notification permission is no longer asked at every launch.
- English translation of the whole app, notifications included.
- Language and theme in Settings: the app follows the phone by default, or stays in French or English, light or dark. A phone in another language gets English. The shipped presets are named in the language of the interface until they are renamed.
- App icon on the home screen, following the phone's icon shape and its themed icons, and in the notifications' status bar.

### Changed

- Backups made before the queue became the only order of the distillation are refused at import, as from another version.
- After the last step of its preset, a card now comes back every 6 months, or at its last step when that is longer, instead of repeating its last interval. A failure then follows the failure behaviour of the preset.
- The end of sequence and the typed answer belong to the group instead of the preset, and are set in the group settings: after the last step, the cards come back every 3 months, 6 months (by default) or year, or are learned for good; the typed answer is off by default.
- The distillation always takes the head of its group's queue: the "Distill" screen no longer offers an order (group order or random).
- In a session, the top half of the card no longer shrinks or greys at the reveal: the answer fades in below it with a short animation and a light vibration, shown at once when the phone reduces animations. "Show answer" is the only button before the reveal, in the place of the answer buttons, and a bonus review no longer shows "no effect" under them.
- Touching a notification opens a review session on its card, or on the due cards of its group, then on every due card, instead of opening Home or the group page.
- A notification that could not arrive on time, the phone being off, arrives when it is turned back on, however late, instead of being dropped after an hour; during the quiet hours it waits for their end.
- Again in a notification closes it like Correct, instead of showing the expected answer and the next review: Reveal shows the answer beforehand.
- Preset steps can be set in years.
- The schedule refuses a time range whose end comes before its start.
- The preset editor says what a missed card does under the failure choice, now named "On failure": one step back, back to start or stay.
- Sharper dark theme: a darker background, lighter cards and a brighter blue, so cards stand out and the selected option of a choice is clearly visible. Both themes are flat, with outlines instead of shadows.
- Settings rows show their value in grey with an arrow when they open something, and lists where one option is chosen (preset, group, language, theme) highlight it with a blue outline.

### Removed

- The preset of a card: a card always follows the preset of its group, and the card editor no longer offers one.
- The end of sequence (including "Loop") and the typed answer in the preset editor.
- The counters at the top of a group page (due, active, waiting) and its "Review the N due" button: "Review all" starts the reviews of a group.
- The Open button of a card chained in a grouped reminder, replaced by Reveal.
- The Adaptive preset and the choice of an adaptive engine in the preset editor: every preset follows its fixed sequence of steps. The card sheet no longer shows a stability and a difficulty.

### Fixed

- The Android navigation bar no longer hides the end of a screen: every list can be scrolled above it, and the bulk add button stays visible above the keyboard.
