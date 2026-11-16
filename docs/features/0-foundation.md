# Feature 0 — Technical foundation

Status: in progress (2026-11-16)

## Goal

Infrastructure with no functional requirement of its own: the Flutter project `fr.gatienh.alambic`, the flat light and dark theme, the main navigation, the layout under the system bars, translatable texts and the local database. Every other feature builds on it.

## Implementation overview

The app starts on `AlambicApp`, which applies the theme and the language chosen in Settings (see [Language and theme](#language-and-theme)). The root screen is a shell with four tabs (Home, Groups, Statistics, Settings) and a floating "+" button that creates a card.

The DM Sans font is bundled as static weights (400, 500, 600, 700) rather than as a variable font. Flutter does not apply the weight axis of a variable font by itself, whereas it picks the right static file from `fontWeight`.

### Theme and contrast

The theme is flat: depth comes from steps of colour and 1 px borders, never from shadows, so every elevation of the Material components is set to zero. Its colours are tokens of the `AlambicColors` theme extension, read by screens with `AlambicColors.of(context)`, each with a light and a dark value. A Material 3 `ColorScheme` is derived from the same tokens so that stock components (dialogs, sheets, switches, text buttons) follow them. No screen writes a colour outside the tokens.

The tokens form a few steps of depth:

- `background` for the pages, `surface` for anything laid on them (cards, tiles, sheets, dialogs), always outlined with `border`.
- `well` for hollows darker than the surface: the track of a segmented control, input fields, progress tracks inside a surface.
- `surfaceRaised` for what stands out of a hollow: the selected segment, badges.
- `accent` for filled elements, with `onAccent` for the text laid on them, and `accentText`, a lighter shade in dark mode, for accent-coloured text and outlines. Text and outlined buttons use `accentText`, because the filled accent does not keep 4.5:1 as text on the dark background.

The tokens must keep WCAG contrast ratios: 7:1 for primary text on every background, 4.5:1 for secondary and accent text and for the text of a filled button, 3:1 for the filled accent on a surface, 1.15:1 between a surface and the page, 1.3:1 for a border on its surface and 1.4:1 for a selected segment on its track. The values of the tokens may move as long as these ratios hold.

A selected state never rests on its fill alone. The two shared selection components show it twice:

- The segmented control, for every choice of 2 or 3 states: the selected segment is raised and outlined, with bold primary text, while the others are plain secondary text on the track.
- The choice tile, for a list where one option is active (preset, group, language, theme, day of a reminder): the active tile has a 2 px accent outline on an accent tint.

A settings row (`PanelRow`) shows the current value in secondary text, and ends with a chevron when a tap opens something (a screen, a picker, a dialog), so that no tappable row reads as plain text. A row that already ends with its own control, such as a switch, a stepper or an action icon, has no chevron.

### System bars

The app draws edge to edge, under transparent status and navigation bars whose icons follow the theme; Android 15 imposes this anyway. Every screen keeps its texts and buttons clear of the bars, in both navigation modes:

- Screens without an app bar (the tabs, a session, the onboarding) and the bottom sheets sit in a `SafeArea`. The tab bar lifts itself above the navigation bar.
- A list under an app bar runs under the navigation bar, but ends with a margin of the bar's height (`scrollPadding`), so its last element can always be brought above it.
- The main button of a page with text input sits under its list rather than at its end (`BottomActionArea`): the page body shrinks above the keyboard, so the button stays visible while typing.

### Language and theme

Settings has a "Display" section with two choices, applied at once:

- **Language**: the language of the phone (default), French or English. Following the phone means French on a French phone and English for any other language, including the ones the app does not have. The notifications speak the same language as the screens, background tasks included: both go through the same rule.
- **Theme**: the setting of the phone (default), light or dark.

These choices are [interface preferences](10-onboarding.md#interface-preferences): they stay on the phone and out of the export. They are read before the first frame, so that the app never opens in the wrong language or theme.

Flutter caches the locale it derives from the phone and only derives it again when the phone language changes. The chosen language is therefore given to the app as its forced locale, read at every build, while the resolution from the phone never depends on the choice; otherwise going back to "language of the phone" would keep the previous language.

### Database

All data lives in a local SQLite database managed by drift, `AlambicDatabase`. Tables use the domain classes directly as rows (`@UseRowClass`): a `Preset` or a `Flashcard` read from the database is the very object the business rules manipulate, with no conversion layer. Enums are stored by name, a preset sequence as JSON and times of day as minutes since midnight.

The tables follow the model of the [lexicon](../lexicon.md): `presets`, `app_settings` (a single row, which holds the global preset, the notification safeguards, the count of cards notified today and the start of the global pause), `card_groups` (with the back option), `distillations` (one row per group whose distillation was activated, keyed by the group), `flashcards` (the faces, the group, and the single progression: state, step or FSRS memory, due date, last answer, last notification and rank in the queue), `review_records` (the history) and `extra_reminders` (the "Review soon" reminders). Foreign keys are enabled at each opening, which gives these deletion rules:

- deleting a card deletes its history and its reminders;
- deleting a group deletes its cards, with their history, and its distillation.

The schema is at version 1 and has no upgrade step: until the app has users, a schema change is installed over cleared app data (`adb shell pm clear fr.gatienh.alambic`) rather than migrated. Once real data must survive an update, each version bump comes with an upgrade step in `AlambicDatabase.migration`.

The global preset lives in the database rather than in the preferences, because it is part of the review data: it must be readable from background tasks and travel with the export.

When the database is created, the Standard, Intensive and Adaptive presets are inserted and Standard becomes the global preset. The connection is shared between isolates (`shareAcrossIsolates`): an answer given from a notification, handled in a background isolate, refreshes the screens of the open app.

## Acceptance criteria

- [x] The Android identifier is `fr.gatienh.alambic` and the displayed name is "Alambic".
- [x] Dependency versions are pinned exactly in `pubspec.yaml` and `pubspec.lock`.
- [x] The app follows the light or dark theme of the phone, or the one chosen in Settings, in DM Sans.
- [x] Both themes keep the contrast ratios of [Theme and contrast](#theme-and-contrast); no component has a shadow.
- [x] No text or button shows under the status bar or the navigation bar; a list can always bring its last element above the navigation bar, and the main button of a page stays above the keyboard.
- [x] The app and its notifications speak French or English, from the phone language or the choice in Settings.
- [x] The main navigation shows four tabs and a "+" button.
- [x] A fresh database contains the Standard, Intensive and Adaptive presets, Standard being the global preset.
- [x] Deleting a group deletes its cards and its distillation; deleting a card deletes its history and its reminders.

## Test strategy

- The language rule is tested on its own (phone language, unsupported language, choice in Settings), and switching the language and the theme from Settings is driven on the real app widget, including going back to the phone language.
- Both ARB files are checked to hold the same texts and the same placeholders.

- The contrast rules are computed with the WCAG formula on the tokens of both themes, so that a change of value that breaks one fails without looking at a screen.
- The system bars are simulated as a 32 px status bar and a 48 px navigation bar (the three-button one, the tallest) around every tab, page, sheet and onboarding screen. No text or tappable element may overlap them; a list is checked at its top and at the end of its scroll, since it may legitimately pass under the bars in between.
- The shell and the Settings tab (in English) are covered by golden tests, in light and dark theme, at the size of the mockup screens (390 × 844).
- The schema is tested on a real, not mocked, in-memory SQLite database: initial content and cascading deletion rules.
- Golden tests load the real fonts (DM Sans and the Material icons); otherwise text would render as blocks and the images would not show the typography.

## File mapping

- `lib/app/` — app shell, theme, and the language rule (`app_locale.dart`).
- `lib/app/widgets/` — the shared components, among them the segmented control, the choice tile and the settings row.
- `lib/app/layout/` — the margins that keep content clear of the system bars.
- `lib/features/settings/display_panel.dart` — the Display section of Settings.
- `lib/data/database/` — drift database: tables, converters and initial content. `alambic_database.g.dart` is generated by `build_runner`.
- `lib/l10n/` — interface texts: `app_fr.arb` is the template that declares the placeholders, `app_en.arb` its English translation.
- `assets/fonts/` — DM Sans and its OFL licence.
- `android/app/build.gradle.kts` — `compileSdk` 37 and desugaring, required by the notifications (see `stack.md`).
- `test/support/` — shared golden test harness.
- `test/flutter_test_config.dart` — loads the fonts before every test.
