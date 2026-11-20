# Feature 10 — Onboarding

Status: implemented (2026-11-20)

## Goal

On the first launch, explain the app in a sentence, get the permissions without which nothing is notified, and leave the user a group to distill, whose first card arrives the same day. After that, the app always opens on its tabs.

## Implementation overview

`AlambicApp` shows the welcome screens until they have been gone through once, then the tabs. Whether they were is an [interface preference](#interface-preferences), read before the first frame so that the app never flashes the wrong screen.

The three screens follow each other with a "Next" button at the bottom, under a row of dots that shows where the user is. At the top, "Back" returns to the previous screen (the system back does too), and "Skip" ends the onboarding from any screen, as on the last one. Each screen puts its illustration first, then its title and its text, centred in the height:

1. **The principle**: "Remember everything without thinking about it.", under "One card, multiple reminders": a line of dots for the start of a card and its reminders after 1 day, 2 days, 1 week and 1 month, not to scale, and "Each correct answer spaces out the next reminder."
2. **Reminders**: "You review straight from the notification.", under a card notification with its Correct and Again buttons, then the reminder time, 12:00 by default, "for all groups". The button of the screen, "Allow notifications", asks for the notification permission (the Android 13 dialog), then opens the system page of exact alarms when they are refused, and moves on to the next screen without waiting for the user to come back from it. Both can be refused: the app still works, with Settings offering exact alarms again ([Feature 7](7-notifications.md#exact-alarms-restarts-and-permissions)). A time picked becomes at once the fixed time of the app's [schedule](../lexicon.md#schedule), so that "Skip" keeps it.
3. **A group to start with**: the [sample group](#sample-group), with its number of cards and its first card ("A → Alpha").

"Next" on the last screen, or "Skip" on any screen, creates the sample group, marks the onboarding as done and opens the tabs. "Skip" leaves the user on Home, without asking the permissions when they were not reached. "Next" opens the page of the group above the tabs, with "Distill" pointed out by a line: "Its cards are waiting. Distill the group to receive them." Activating the distillation introduces its first card the same day, at the [daily slot](../lexicon.md#daily-slot) or right away when the slot has passed ([Feature 8](8-distillation.md)). The group to open is handed to the tabs by a notifier (`firstGroupProvider`), which forgets it once opened.

### Sample group

The sample group is the NATO alphabet: 26 cards, "A" → "Alpha" to "Z" → "Zulu", all [pending](../lexicon.md#pending) in that order. It is named "Alphabet NATO", or "NATO alphabet" when the app is in English at that moment; the name does not follow a later change of language. It inherits the global preset, its back is off and it does not distill.

It is created when the onboarding ends, and so once per installation: never again after it is deleted, nor after an import. It is then an ordinary group, which can be renamed or deleted.

Its cards are a text file in the app's assets, `assets/samples/nato_alphabet.txt`, in the format of the bulk add (`front;back`, one card per line), read by the bulk add's parser ([Feature 3](3-cards.md)). The file is read without the asset cache: it is only needed during the onboarding.

### Interface preferences

The preferences of the interface on this phone (whether the onboarding was done, the [language and the theme](0-foundation.md#language-and-theme)) live in shared_preferences, not in the database: they are not part of the review data and stay out of the export ([Feature 9](9-backup.md)). They are loaded once by the entry point, and by each background task for the language of the notifications, then held by a Riverpod notifier, which saves each change.

## Acceptance criteria

- [x] The first launch opens on the three welcome screens; later launches open on the tabs.
- [x] The second screen asks for notifications, then for exact alarms only while they are refused, with a single button, and sets the fixed time of the app's schedule.
- [x] The third screen shows the sample group; "Next" creates it, with its 26 cards pending in order, named in the language of the app, and opens the group page with "Distill" pointed out. "Skip", from any screen, creates it too and opens Home.
- [x] "Back" returns to the previous screen, from the second one on.
- [x] The sample group is created once: a later launch does not create it again, even after its deletion.
- [x] The notification permission is not asked at launch anymore.

## Test strategy

- The whole path is driven on the real app widget, over an in-memory database and in-memory replacements of the notification permissions and of the preferences: first launch versus later launch, both permission requests, the sample group created with the group page opened, skip from the first and the last screen, back, the French name, no new group at a later launch after its deletion, and the preference saved at the end.
- The sample group's cards and what its creation stores (order, pending, preset, back, no distillation) are tested on the service, over the asset file itself.
- The time given to the presets is tested on the preset service: fixed-time presets move, time-range presets do not.
- Each screen is covered by a golden test in English, the first one in dark theme too and the reminders screen in French too.

## File mapping

- `lib/features/onboarding/` — the three screens and their shared layout.
- `lib/application/onboarding/` — the creation of the sample group, and the group to open once the tabs show.
- `lib/data/samples/` and `assets/samples/` — the cards of the sample group.
- `lib/data/preferences/` — interface preferences and their shared_preferences store.
- `lib/application/preferences/` — the notifier holding the preferences, and its providers.
- `lib/app/alambic_app.dart` — chooses between the welcome screens and the tabs.
