# Changelog

All visible changes to Alambic are listed here. Format: [Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

- Main navigation with four tabs and a card creation button, in light and dark theme.
- Standard (1 day to 6 months) and Intensive (10 min to 1 week) presets, created on first launch.
- Preset list and editor in Settings: create, edit and duplicate a preset, and choose the global preset.
- Creation and editing of text cards, each in a group. The group row creates a new group from its name with "+". A new card waits in its group's queue until the group's distillation brings it in.
- Groups tab: list of groups with their due cards, card search, group page and group settings (name, preset, back, deletion of the group with its cards).
- "Review all" on a group page: a session on every card of the group, where only the cards due today count; the others are bonus reviews.
- Back of a group: once enabled, each display of a card (session, notification, typed answer) asks its front or its back at random, with a single progression per card.
- Bulk add: paste one card per line into a group, chosen or created on the spot, with an editable separator (`;` by default) and a report of the skipped lines.
- Home tab: a timeline of the coming cards, today first with the late ones, then the next six days, card by card with their reminder label ("J2", "S1"), and one line per group for its new cards ("Capitales: 2 new cards").
- Card sheet: both faces, reminder label on the step bar, next review and history, with Review soon (one-off reminder), Suspend / Resume and Reset, which sends the card back to its group's queue. Lists show the reminder label and next date of each card ("J2 · in 3 d"), or "waiting".
- Notifications: an introduced card arrives at the reminder time with Correct / Again buttons, answered without opening the app; Again shows the expected answer and the next review. A card reviewed in the app before its slot is not notified twice. "Review soon" reminders are notified too.
- Reminders survive a phone restart. Without the exact alarm permission they may arrive a few minutes late, and Settings offers to allow exact alarms.
- Distillation: "Distill" on a group page introduces its waiting cards a few at a time ("N cards every X days", in group or random order), even with the app closed. It is a permanent setting of the group, adjusted, paused and resumed from the group page; cards added later join the end of its queue. "Avoid collisions" gives it a daily budget while cards wait: reminders first, new cards in what is left.
- Typed answer in the notification, for presets with this option: the answer is accepted despite case, accents, spaces and one typo, then the expected answer is shown.
- Grouped reminder, as the notification mode of the app: one notification per group with its number of due cards, which opens the app on the group or chains the cards inside the notification.
- Time range schedule: the notifications of the day are spread evenly over the range, and Home's timeline shows them at their moment.
- A notification ignored or swiped is sent again the next day at the reminder time.
- Schedule and notification mode in Settings, for every group at once: a fixed time (12:00 by default) or a time range, one notification per card or a grouped reminder. A new reminder time also moves the reminders already set at the old one.
- Notification safeguards in Settings: a daily cap that holds back the longest intervals first, quiet hours (22:00 to 08:00 by default) and auto grouping of a busy moment into a single notification.
- Pause of a group, from its settings or its page, and global pause, from Settings or Home: nothing is notified and distillations wait; on resume, due dates move by the length of the pause.
- Images on cards: each face takes a picture from the gallery, alone or with a text. It shows on the card sheet, in the lists, in a session and in the expanded notification.
- In-app review session: answer revealed on tap, Correct / Again buttons showing the next due date, end screen and bonus review of the missed cards.
- Export and import from Settings: all the cards, their history, the presets, the settings and the images in a single zip file saved where you choose. Importing a file replaces all the current data after a confirmation; a file that is not a valid backup is refused without changing anything.
- Welcome screens on the first launch: the principle of the app, the notification and exact alarm permissions with the reminder time, and a first group with its first card, then the page of that group with "Distill" pointed out. The notification permission is no longer asked at every launch.
- English translation of the whole app, notifications included.
- Language and theme in Settings: the app follows the phone by default, or stays in French or English, light or dark. A phone in another language gets English. The shipped presets are named in the language of the interface until they are renamed.
- App icon on the home screen, following the phone's icon shape and its themed icons, and in the notifications' status bar.

### Changed

- Sharper dark theme: a darker background, lighter cards and a brighter blue, so cards stand out and the selected option of a choice is clearly visible. Both themes are flat, with outlines instead of shadows.
- Settings rows show their value in grey with an arrow when they open something, and lists where one option is chosen (preset, group, language, theme) highlight it with a blue outline.

### Removed

- The preset of a card: a card always follows the preset of its group, and the card editor no longer offers one.
- The Adaptive preset and the choice of an adaptive engine in the preset editor: every preset follows its fixed sequence of steps. The card sheet no longer shows a stability and a difficulty.

### Fixed

- The Android navigation bar no longer hides the end of a screen: every list can be scrolled above it, and the bulk add button stays visible above the keyboard.
