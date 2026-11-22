# Feature 10 — Onboarding

Status: implemented (2026-11-20)

## Goal

On the first launch, explain the app in a sentence, get the permissions without which nothing is notified, and leave the user a group to distill, whose first card arrives the same day. After that, the app always opens on its tabs.

## Implementation overview

`AlambicApp` shows the welcome screens until they have been gone through once, then the tabs. Whether they were is an [interface preference](#interface-preferences), read before the first frame so that the app never flashes the wrong screen.

The four screens follow each other with a button at the bottom, under a row of dots that shows where the user is. At the top, "Back" returns to the previous screen (the system back does too), and "Skip" ends the onboarding from any screen, as on the last one. Each screen puts its illustration first, then its title and its text, centred in the height:

1. **The principle**: "Learn it once, keep it for good.", under "One card, multiple reminders": a line of dots for the start of a card and its reminders after 1 day, 2 days, 1 week and 1 month, not to scale, and "Each correct answer spaces out the next reminder."
2. **The distillation**: "Distill what you learn, one drop at a time.", under "197 cards, one a day": the cards of the [sample group](#sample-group) as a pile, then a dot for each day of a week from Monday, and "You choose the pace". The number is the sample group's, so the illustration waits for its cards to be read. The screen explains what [distilling](../lexicon.md#distillation) does before the user meets the word on the group page.
3. **Reminders**: "You review straight from the notification.", under a card notification with its three buttons spread along its bottom, "Again", "Reveal" and "Correct", then two rows:
   - the reminder time, 12:00 by default. A time picked becomes at once the fixed time of the app's [schedule](../lexicon.md#schedule), so that "Skip" keeps it.
   - "Test notification", which shows at once the card notification of the illustration, "What is the capital of Peru?" in the group "Capitals". It asks for the notification permission first, since without it nothing would show. The notification is tied to no card but has the buttons of a real card notification ([Feature 7](7-notifications.md#exact-alarms-restarts-and-permissions)): "Reveal" shows "Lima" and "Hide" asks again, "Correct" and "Again" show what they would do, with demonstration delays, and record nothing. Touching it opens the app on Home.

   The button of the screen, "Allow notifications", asks for the notification permission (the Android 13 dialog), then opens the system page of exact alarms when they are refused, and moves on to the next screen without waiting for the user to come back from it. Both can be refused: the app still works, with Settings offering exact alarms again ([Feature 7](7-notifications.md#exact-alarms-restarts-and-permissions)).
4. **A group to get started**: the sample group, with its number of cards and its first card ("Afghanistan → Kabul"), and "197 capitals are waiting".

"Get started" on the last screen, or "Skip" on any screen, creates the sample group, marks the onboarding as done and opens the tabs. "Skip" leaves the user on Home, without asking the permissions when they were not reached. "Get started" opens the page of the group above the tabs, with "Distill" pointed out by a line: "Its cards are waiting. Distill the group to receive them." Activating the distillation introduces its first card the same day, at the [daily slot](../lexicon.md#daily-slot) or right away when the slot has passed ([Feature 8](8-distillation.md)). The group to open is handed to the tabs by a notifier (`firstGroupProvider`), which forgets it once opened.

### Sample group

The sample group is the capitals of the world: 197 cards, the country on the front and its capital on the back ("Afghanistan" → "Kabul"), all [pending](../lexicon.md#pending) in alphabetical order of the country. Its name and its cards are in the language of the app at that moment: "Capitals" with English country names, "Capitales" with French ones. They do not follow a later change of language. It inherits the global preset, its back is off and it does not distill.

It is created when the onboarding ends, and so once per installation: never again after it is deleted, nor after an import. It is then an ordinary group, which can be renamed or deleted.

Its cards are a text file in the app's assets, `assets/samples/capitals_en.txt` and `assets/samples/capitals_fr.txt`, one per language of the app, in the format of the bulk add (`front;back`, one card per line), read by the bulk add's parser ([Feature 3](3-cards.md)). The file of the language is read without the asset cache: it is only needed during the onboarding.

### Interface preferences

The preferences of the interface on this phone (whether the onboarding was done, the [language and the theme](0-foundation.md#language-and-theme)) live in shared_preferences, not in the database: they are not part of the review data and stay out of the export ([Feature 9](9-backup.md)). They are loaded once by the entry point, and by each background task for the language of the notifications, then held by a Riverpod notifier, which saves each change.

### Replay

A debug build shows a "Development" panel at the end of Settings, whose "Replay the onboarding" row shows the four screens again, in place of the tabs. It only clears the preference above: finishing opens the group already named like the sample group, if there is one, instead of creating it again, and creates it otherwise, as the first launch does. A release build has no such row.

## Acceptance criteria

- [x] The first launch opens on the four welcome screens; later launches open on the tabs.
- [x] The second screen shows the number of cards of the sample group.
- [x] The third screen asks for notifications, then for exact alarms only while they are refused, with a single button, and sets the fixed time of the app's schedule.
- [x] "Test notification" shows at once a card notification tied to no card, after asking for notifications; refused, it shows nothing.
- [x] The last screen shows the sample group; "Get started" creates it, with its 197 cards pending in order, named and written in the language of the app, and opens the group page with "Distill" pointed out. "Skip", from any screen, creates it too and opens Home.
- [x] "Back" returns to the previous screen, from the second one on.
- [x] The sample group is created once: a later launch does not create it again, even after its deletion.
- [x] When the onboarding is replayed, finishing it opens the group already named like the sample group, with its cards untouched, instead of creating a second one.
- [x] The notification permission is not asked at launch anymore.

## Test strategy

- The whole path is driven on the real app widget, over an in-memory database and in-memory replacements of the notification permissions and of the preferences: first launch versus later launch, both permission requests, the test notification allowed and refused, the sample group created with the group page opened, skip from the first and the last screen, back, the French name, no new group at a later launch after its deletion, and the preference saved at the end.
- The sample group's cards and what its creation stores (order, pending, preset, back, no distillation) are tested on the service, over the asset file itself.
- The time given to the presets is tested on the preset service: fixed-time presets move, time-range presets do not.
- Each screen is covered by a screen test with a capture in English, the first one in dark theme too and the reminders screen in French too.
- The Android notification itself is not covered by a test: it is checked on a device.

## File mapping

- `lib/features/onboarding/` — the four screens and their shared layout.
- `lib/application/onboarding/` — the creation of the sample group, and the group to open once the tabs show.
- `lib/data/samples/` and `assets/samples/` — the cards of the sample group.
- `lib/data/preferences/` — interface preferences and their shared_preferences store.
- `lib/application/preferences/` — the notifier holding the preferences, and its providers.
- `lib/app/alambic_app.dart` — chooses between the welcome screens and the tabs.
