# Feature 10 — Onboarding

Status: implemented (2026-11-17)

## Goal

On the first launch, explain the app in a sentence, get the permissions without which nothing is notified, and leave the user a group to distill, whose first card arrives the same day. After that, the app always opens on its tabs.

## Implementation overview

`AlambicApp` shows the welcome screens until they have been gone through once, then the tabs. Whether they were is an [interface preference](#interface-preferences), read before the first frame so that the app never flashes the wrong screen.

The three screens follow each other with a "Continue" button; a row of dots shows where the user is:

1. **The principle**: "One piece of knowledge a day", and how the app works in a sentence.
2. **Reminders**: one row to allow notifications (the Android 13 permission), one row to allow exact alarms (a system settings page, read again when the app comes back to the front), and the reminder time, 12:00 by default. A row shows "Allowed" once its permission is given. Both can be refused: the app still works, with Settings offering exact alarms again ([Feature 7](7-notifications.md#exact-alarms-restarts-and-permissions)). A time other than 12:00 becomes the fixed time of the app's [schedule](../lexicon.md#schedule).
3. **A group to start with** (*Un groupe pour commencer*): the [sample group](#sample-group), with its number of cards and its first card ("A → Alpha"), then "Start" and "Skip".

Either button of the last screen creates the sample group, marks the onboarding as done and opens the tabs. "Skip" leaves the user on Home. "Start" opens the page of the group above the tabs, with "Distill" pointed out by a line: "Its cards are waiting. Distill the group to receive them." Activating the distillation introduces its first card the same day, at the [daily slot](../lexicon.md#daily-slot) or right away when the slot has passed ([Feature 8](8-distillation.md)). The group to open is handed to the tabs by a notifier (`firstGroupProvider`), which forgets it once opened.

### Sample group

The sample group is the NATO alphabet: 26 cards, "A" → "Alpha" to "Z" → "Zulu", all [pending](../lexicon.md#pending) in that order. It is named "Alphabet OTAN", or "NATO alphabet" when the app is in English at that moment; the name does not follow a later change of language. It inherits the global preset, its back is off and it does not distill.

It is created when the onboarding ends, and so once per installation: never again after it is deleted, nor after an import. It is then an ordinary group, which can be renamed or deleted.

Its cards are a text file in the app's assets, `assets/samples/nato_alphabet.txt`, in the format of the bulk add (`front;back`, one card per line), read by the bulk add's parser ([Feature 3](3-cards.md)). The file is read without the asset cache: it is only needed during the onboarding.

### Interface preferences

The preferences of the interface on this phone (whether the onboarding was done, the [language and the theme](0-foundation.md#language-and-theme)) live in shared_preferences, not in the database: they are not part of the review data and stay out of the export ([Feature 9](9-backup.md)). They are loaded once by the entry point, and by each background task for the language of the notifications, then held by a Riverpod notifier, which saves each change.

## Acceptance criteria

- [x] The first launch opens on the three welcome screens; later launches open on the tabs.
- [x] The second screen asks for notifications and exact alarms, and sets the fixed time of the app's schedule.
- [x] The third screen shows the sample group; either of its buttons creates it, with its 26 cards pending in order, named in the language of the app. "Start" opens the group page with "Distill" pointed out; "Skip" opens Home.
- [x] The sample group is created once: a later launch does not create it again, even after its deletion.
- [x] The notification permission is not asked at launch anymore.

## Test strategy

- The whole path is driven on the real app widget, over an in-memory database and in-memory replacements of the notification permissions and of the preferences: first launch versus later launch, both permission requests, the sample group created with the group page opened, skip, the English name, no new group at a later launch after its deletion, and the preference saved at the end.
- The sample group's cards and what its creation stores (order, pending, preset, back, no distillation) are tested on the service, over the asset file itself.
- The time given to the presets is tested on the preset service: fixed-time presets move, time-range presets do not.
- Each screen is covered by a golden test, and the first one in dark theme.

## File mapping

- `lib/features/onboarding/` — the three screens and their shared layout.
- `lib/application/onboarding/` — the creation of the sample group, and the group to open once the tabs show.
- `lib/data/samples/` and `assets/samples/` — the cards of the sample group.
- `lib/data/preferences/` — interface preferences and their shared_preferences store.
- `lib/application/preferences/` — the notifier holding the preferences, and its providers.
- `lib/app/alambic_app.dart` — chooses between the welcome screens and the tabs.
