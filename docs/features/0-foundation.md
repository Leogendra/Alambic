# Feature 0 — Technical foundation

Status: in progress (2026-11-11)

## Goal

Infrastructure with no functional requirement of its own: the Flutter project `fr.gatienh.alambic`, the "hybrid" light and dark theme, the main navigation, translatable texts and the local database. Every other feature builds on it.

## Implementation overview

The app starts on `AlambicApp`, which applies the theme and the language chosen in Settings (see [Language and theme](#language-and-theme)). The root screen is a shell with four tabs (Home, Groups, Statistics, Settings) and a floating "+" button that creates a card.

The theme starts from a Material 3 `ColorScheme` built on the `#1052d5` accent, then overrides it with the mockup colours. Colours with no Material equivalent (segment background, colours of the "Again" button, secondary and tertiary text) are carried by the `AlambicColors` theme extension, read by screens with `AlambicColors.of(context)`. Each token has a light and a dark value, taken from the mockup.

The DM Sans font is bundled as static weights (400, 500, 600, 700) rather than as a variable font. Flutter does not apply the weight axis of a variable font by itself, whereas it picks the right static file from `fontWeight`.

### Language and theme

Settings has a "Display" section with two choices, applied at once:

- **Language**: the language of the phone (default), French or English. Following the phone means French on a French phone and English for any other language, including the ones the app does not have. The notifications speak the same language as the screens, background tasks included: both go through the same rule.
- **Theme**: the setting of the phone (default), light or dark.

These choices are [interface preferences](10-onboarding.md#interface-preferences): they stay on the phone and out of the export. They are read before the first frame, so that the app never opens in the wrong language or theme.

Flutter caches the locale it derives from the phone and only derives it again when the phone language changes. The chosen language is therefore given to the app as its forced locale, read at every build, while the resolution from the phone never depends on the choice; otherwise going back to "language of the phone" would keep the previous language.

### Database

All data lives in a local SQLite database managed by drift, `AlambicDatabase`. Tables use the domain classes directly as rows (`@UseRowClass`): a `Preset` or a `CardDirection` read from the database is the very object the business rules manipulate, with no conversion layer. Enums are stored by name, a preset sequence as JSON and times of day as minutes since midnight.

The tables follow the model of the [lexicon](../lexicon.md): `presets`, `app_settings` (a single row, which holds the global preset, the notification safeguards, the count of cards notified today and the start of the global pause), `card_groups`, `distillations` (the distillations in progress), `flashcards`, `card_directions` (one direction per card and orientation, with the distillation that queued it and its rank in the queue), `review_records` (the history) and `extra_reminders` (the "Review soon" reminders). Foreign keys are enabled at each opening, which gives these deletion rules:

- deleting a card deletes its directions, their history and their reminders;
- deleting a group deletes its cards, and with them their directions and history, and its distillations;
- deleting a distillation releases its directions: a pending one stays pending, outside any queue.

The schema is at version 1 and has no upgrade step: until the app has users, a schema change is installed over cleared app data (`adb shell pm clear fr.gatienh.alambic`) rather than migrated. Once real data must survive an update, each version bump comes with an upgrade step in `AlambicDatabase.migration`.

The global preset lives in the database rather than in the preferences, because it is part of the review data: it must be readable from background tasks and travel with the export.

When the database is created, the Standard, Intensive and Adaptive presets are inserted and Standard becomes the global preset. The connection is shared between isolates (`shareAcrossIsolates`): an answer given from a notification, handled in a background isolate, refreshes the screens of the open app.

## Acceptance criteria

- [x] The Android identifier is `fr.gatienh.alambic` and the displayed name is "Alambic".
- [x] Dependency versions are pinned exactly in `pubspec.yaml` and `pubspec.lock`.
- [x] The app follows the light or dark theme of the phone, or the one chosen in Settings, in DM Sans with the `#1052d5` accent.
- [x] The app and its notifications speak French or English, from the phone language or the choice in Settings.
- [x] The main navigation shows four tabs and a "+" button.
- [x] A fresh database contains the Standard, Intensive and Adaptive presets, Standard being the global preset.
- [x] Deleting a group deletes its cards; deleting a card deletes its directions and their history.

## Test strategy

- The language rule is tested on its own (phone language, unsupported language, choice in Settings), and switching the language and the theme from Settings is driven on the real app widget, including going back to the phone language.
- Both ARB files are checked to hold the same texts and the same placeholders.

- The shell is covered by golden tests, in light and dark theme, at the size of the mockup screens (390 × 844).
- The schema is tested on a real, not mocked, in-memory SQLite database: initial content and cascading deletion rules.
- Golden tests load the real fonts (DM Sans and the Material icons); otherwise text would render as blocks and the images would not show the typography.

## File mapping

- `lib/app/` — app shell, theme, and the language rule (`app_locale.dart`).
- `lib/features/settings/display_panel.dart` — the Display section of Settings.
- `lib/data/database/` — drift database: tables, converters and initial content. `alambic_database.g.dart` is generated by `build_runner`.
- `lib/l10n/` — interface texts: `app_fr.arb` is the template that declares the placeholders, `app_en.arb` its English translation.
- `assets/fonts/` — DM Sans and its OFL licence.
- `android/app/build.gradle.kts` — `compileSdk` 37 and desugaring, required by the notifications (see `stack.md`).
- `test/support/` — shared golden test harness.
- `test/flutter_test_config.dart` — loads the fonts before every test.
