# Feature 10 — Onboarding

Status: implemented (2026-11-16)

## Goal

On the first launch, explain the app in a sentence, get the permissions without which nothing is notified, and lead the user to a first card that arrives the same day. After that, the app always opens on its tabs.

## Implementation overview

`AlambicApp` shows the welcome screens until they have been gone through once, then the tabs. Whether they were is an [interface preference](#interface-preferences), read before the first frame so that the app never flashes the wrong screen.

The three screens follow each other with a "Continue" button; a row of dots shows where the user is:

1. **The principle**: "One piece of knowledge a day", and how the app works in a sentence.
2. **Reminders**: one row to allow notifications (the Android 13 permission), one row to allow exact alarms (a system settings page, read again when the app comes back to the front), and the reminder time, 12:00 by default. A row shows "Allowed" once its permission is given. Both can be refused: the app still works, with Settings offering exact alarms again ([Feature 7](7-notifications.md#exact-alarms-restarts-and-permissions)). A time other than 12:00 is given to every preset notified at a fixed time, which on a first launch means the shipped presets; presets on a time range keep their range.
3. **First card**: a front and a back. "Create and start" creates the card outside any group and [starts](../lexicon.md#unstarted) it at once, so that it is due today and its notification comes at the preset slot, or right away when the slot has passed. "Skip" opens the app without a card.

Either button of the last screen marks the onboarding as done and opens the tabs.

### Interface preferences

The preferences of the interface on this phone (whether the onboarding was done) live in shared_preferences, not in the database: they are not part of the review data and stay out of the export ([Feature 9](9-backup.md)). They are loaded once by the entry point and then held by a Riverpod notifier, which saves each change.

## Acceptance criteria

- [x] The first launch opens on the three welcome screens; later launches open on the tabs.
- [x] The second screen asks for notifications and exact alarms, and sets the reminder time of the presets notified at a fixed time.
- [x] The third screen creates a first card outside any group, started at once, or is skipped.
- [x] The notification permission is not asked at launch anymore.

## Test strategy

- The whole path is driven on the real app widget, over an in-memory database and in-memory replacements of the notification permissions and of the preferences: first launch versus later launch, both permission requests, creation of a started card, skip, and the preference saved at the end.
- The time given to the presets is tested on the preset service: fixed-time presets move, time-range presets do not.
- Each screen is covered by a golden test, and the first one in dark theme.

## File mapping

- `lib/features/onboarding/` — the three screens and their shared layout.
- `lib/data/preferences/` — interface preferences and their shared_preferences store.
- `lib/application/preferences/` — the notifier holding the preferences, and its providers.
- `lib/app/alambic_app.dart` — chooses between the welcome screens and the tabs.
