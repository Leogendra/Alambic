# Feature 0 — Technical foundation

Status: in progress (2026-11-26)

## Goal

Infrastructure with no functional requirement of its own: the Flutter project `fr.gatienh.alambic`, the flat light and dark theme, the main navigation, the layout under the system bars, translatable texts and the local database. Every other feature builds on it.

## Implementation overview

The app starts on `AlambicApp`, which applies the theme and the language chosen in Settings (see [Language and theme](#language-and-theme)). The root screen is a shell with three tabs (Home, Groups, Settings) and a floating "+" button that adds cards: it opens two separate floating buttons above it, "Add a card" and "Add several cards", over a dimmed barrier, and turns into a close button meanwhile (`AddCardsButton`, also used by the group page). Its tab bar is drawn by the app (`AlambicTabBar`) rather than by Material's `NavigationBar`, whose theme cannot mark the active tab with a bar: the active tab is in accent under a 3 px bar across its top.

The DM Sans font is bundled as static weights (400, 500, 600, 700) rather than as a variable font. Flutter does not apply the weight axis of a variable font by itself, whereas it picks the right static file from `fontWeight`.

### Theme and contrast

The theme is flat: depth comes from steps of colour and 1 px borders, never from shadows, so every elevation of the Material components is set to zero. Its colours are tokens of the `AlambicColors` theme extension, read by screens with `AlambicColors.of(context)`, each with a light and a dark value. A Material 3 `ColorScheme` is derived from the same tokens so that stock components (dialogs, sheets, switches, text buttons) follow them. No screen writes a colour outside the tokens.

The tokens form a few steps of depth:

- `background` for the pages, `surface` for anything laid on them (cards, tiles, sheets, dialogs), always outlined with `border`.
- `well` for hollows darker than the surface: the track of a segmented control, input fields, progress tracks inside a surface.
- `surfaceRaised` for what stands out of a hollow: the selected segment, badges.
- `accent` for filled elements, with `onAccent` for the text laid on them, and `accentText`, a lighter shade in dark mode, for accent-coloured text and outlines. Text and outlined buttons use `accentText`, because the filled accent does not keep 4.5:1 as text on the dark background.

The tokens must keep WCAG contrast ratios: 7:1 for primary text on every background, 4.5:1 for secondary and accent text and for the text of a filled button, 3:1 for the filled accent on a surface, 1.15:1 between a surface and the page, 1.3:1 for a border on its surface and 1.4:1 for a selected segment on its track. The values of the tokens may move as long as these ratios hold. In the light theme, a white selected segment can only stand out from a grey track, so `well` is grey there, and input fields, which share it, are grey too. The neutrals of the dark theme are slightly blue, to move away from pure grey.

Input fields sit on `well` with a `border` outline, which turns `accentText` when they have the focus. The progress bar of a session lies on the page background, where `well` would vanish, so its track is `border`.

A selected state never rests on its fill alone. The two shared selection components show it twice:

- The segmented control, for every choice of 2 or 3 states: the selected segment is raised and outlined, with bold primary text, while the others are plain secondary text on the track.
- The choice tile, for a list where one option is active (preset, group, language, theme, day of a reminder): the active tile has a 2 px accent outline on an accent tint.

A settings row (`PanelRow`) can start with an icon, shows the current value in secondary text, and ends with a chevron when a tap opens something (a screen, a picker, a dialog), so that no tappable row reads as plain text. A row that already ends with its own control, such as a switch, a stepper or an action icon, has no chevron.

### System bars

The app draws edge to edge, under transparent status and navigation bars whose icons follow the theme; Android 15 imposes this anyway. Every screen keeps its texts and buttons clear of the bars, in both navigation modes:

- Screens without an app bar (the tabs, a session, the onboarding) and the bottom sheets sit in a `SafeArea`. The tab bar lifts itself above the navigation bar.
- A list under an app bar runs under the navigation bar, but ends with a margin of the bar's height (`scrollPadding`), so its last element can always be brought above it.
- The main button of a page with text input sits under its list rather than at its end (`BottomActionArea`): the page body shrinks above the keyboard, so the button stays visible while typing.

### Settings

The Settings tab is a short list with no subtitle and no value, so that it reads at a glance. Its first group holds one row per category, each with an icon and a chevron, and each opening a screen of its own that groups the settings of the category in a single group, one rounded block per setting with a thin gap between two blocks:

- **Notifications**: the schedule with the quiet hours, the notification mode with the auto grouping, the global pause, then, under "Permissions", the exact alarms and a test notification ([Feature 7](7-notifications.md)).
- **Presets**: opens the Presets screen directly ([Feature 2](2-presets.md)).
- **Display**: the language and the theme, see below.
- **Backup & restore**: the export and the import ([Feature 9](9-backup.md)).

Below, an "About" panel holds a link to the GitHub repository of the app, which opens in the browser, and the tab ends on the version of the installed app ("Alambic v1.0.0"). A debug build adds a "Development" panel, absent from a release build, whose "Replay the onboarding" row shows the welcome screens again ([Feature 10](10-onboarding.md#replay)).

A category screen is a page with an app bar, where the explanations and the current values that would crowd the tab belong.

### Language and theme

The Display category of Settings has two choices, applied at once:

- **Language**: the language of the phone (default), English or French. Following the phone means French on a French phone and English for any other language, including the ones the app does not have. The notifications speak the same language as the screens, background tasks included: both go through the same rule. English is the base language: every text is written in English first, and French translates all of them.
- **Theme**: the setting of the phone (default), light or dark.

These choices are [interface preferences](10-onboarding.md#interface-preferences): they stay on the phone and out of the export. They are read before the first frame, so that the app never opens in the wrong language or theme.

Flutter caches the locale it derives from the phone and only derives it again when the phone language changes. The chosen language is therefore given to the app as its forced locale, read at every build, while the resolution from the phone never depends on the choice; otherwise going back to "language of the phone" would keep the previous language.

### Database

All data lives in a local SQLite database managed by drift, `AlambicDatabase`. Tables use the domain classes directly as rows (`@UseRowClass`): a `Preset` or a `Flashcard` read from the database is the very object the business rules manipulate, with no conversion layer. Enums are stored by name, a preset sequence as JSON and times of day as minutes since midnight.

The tables follow the model of the [lexicon](../lexicon.md): `presets`, `app_settings` (a single row, which holds the global preset, the notification safeguards, the start of the global pause and the last day whose due dates it moved), `card_groups` (with the asked sides), `distillations` (one row per group whose distillation was activated, keyed by the group), `flashcards` (the faces, the group, and the single progression: state, step, due date, last answer, last notification and rank in the queue) and `review_records` (the history). Foreign keys are enabled at each opening, which gives these deletion rules:

- deleting a card deletes its history and its reminders;
- deleting a group deletes its cards, with their history, and its distillation.

The schema version is raised at every schema change, and each change ships a migration from the previous version that keeps the user's data. The schema of every version is saved in `drift_schemas/` by `dart run drift_dev make-migrations`, which also writes the skeleton of each step and its tests (`stack.md` §Commands). An older file is never erased: without a migration for its version, drift refuses to open it. A backup of another version is refused at import ([Feature 9](9-backup.md)).

The global preset lives in the database rather than in the preferences, because it is part of the review data: it must be readable from background tasks and travel with the export.

When the database is created, the Standard and Intensive presets are inserted and Standard becomes the global preset. The connection is shared between isolates (`shareAcrossIsolates`): an answer given from a notification, handled in a background isolate, refreshes the screens of the open app.

## Acceptance criteria

- [x] The Android identifier is `fr.gatienh.alambic` and the displayed name is "Alambic".
- [x] Dependency versions are pinned exactly in `pubspec.yaml` and `pubspec.lock`.
- [x] The app follows the light or dark theme of the phone, or the one chosen in Settings, in DM Sans.
- [x] Both themes keep the contrast ratios of [Theme and contrast](#theme-and-contrast); no component has a shadow.
- [x] No text or button shows under the status bar or the navigation bar; a list can always bring its last element above the navigation bar, and the main button of a page stays above the keyboard.
- [x] The app and its notifications speak English or French, from the phone language or the choice in Settings.
- [x] English is the base language: its texts are the template, and French translates every one of them.
- [x] The main navigation shows three tabs and a "+" button that opens "Add a card" and "Add several cards".
- [x] The Settings tab lists four categories (Notifications, Presets, Display, Backup & restore), each opening its own screen, then the link to the GitHub repository and the version of the app; a debug build also lists the development tools.
- [x] A fresh database contains the Standard and Intensive presets, Standard being the global preset.
- [x] Deleting a group deletes its cards and its distillation; deleting a card deletes its history and its reminders.

## Test strategy

- The language rule is tested on its own (phone language, unsupported language, choice in Settings), and switching the language and the theme from Settings is driven on the real app widget: from French to English, from English to French, and back to the phone language.
- Both ARB files are checked to hold the same texts and the same placeholders.
- Screen tests show the English interface, the base language. A test that depends on the French translation asks for French explicitly. A test that only goes through a screen reads the labels it taps from the English texts, so that rewording one does not break it.

- The contrast rules are computed with the WCAG formula on the tokens of both themes, so that a change of value that breaks one fails without looking at a screen.
- The system bars are simulated as a 32 px status bar and a 48 px navigation bar (the three-button one, the tallest) around every tab, page, sheet and onboarding screen. No text or tappable element may overlap them; a list is checked at its top and at the end of its scroll, since it may legitimately pass under the bars in between. A screen or sheet added or redone joins this check. Dialogs do not: Flutter centres them clear of the bars.
- A screen test pumps its screen at the size of the mockup screens (390 × 844) and checks its key texts. At each state worth seeing, `expectNoOverflow` lays the screen out again on a small phone (360 × 640) and with text twice as large, and fails on an overflow; `captureShot` writes an image of it to `build/shots/` when the run asks for it (`stack.md` §Commands). No test compares pixels: the images are for looking at the screens and comparing them with the mockup. A screen added or redone gets a screen test that calls both.
- The shell is covered by screen tests in light and dark theme. The Settings tab is covered in English and in French, in light and dark theme, and each category is opened from it; the version and the browser are replaced by an in-memory fake, so that the tests need no platform plugin.
- The schema is tested on a real, not mocked, in-memory SQLite database: initial content and cascading deletion rules.
- A new database is compared with the saved schema of its version, so that a table changed without a new version and its migration fails the tests. Each migration is tested from every older saved schema.
- Widget tests load the real fonts (DM Sans and the Material icons); otherwise text would render as blocks, the captures would not show the typography and the overflow checks would measure the wrong glyphs.

## File mapping

- `lib/app/` — app shell and its tab bar (`shell/`), theme, and the language rule (`app_locale.dart`).
- `lib/app/widgets/` — the shared components, among them the segmented control, the choice tile and the settings row.
- `lib/app/layout/` — the margins that keep content clear of the system bars.
- `lib/features/settings/` — the Settings tab, the page shared by the category screens, and the Display screen.
- `lib/data/about/` — the version and the repository link behind an interface, with the plugins that implement it.
- `lib/data/database/` — drift database: tables, converters and initial content. `alambic_database.g.dart` is generated by `build_runner`.
- `drift_schemas/` — the saved schema of every version; `test/drift/` holds the schema and migration tests, with helpers generated from these files.
- `lib/l10n/` — interface texts: `app_en.arb` is the template that declares the placeholders, `app_fr.arb` its French translation.
- `assets/fonts/` — DM Sans and its OFL licence.
- `android/app/build.gradle.kts` — `compileSdk` 37 and desugaring, required by the notifications (see `stack.md`).
- `test/support/` — shared test helpers, among them the screen harness (`screen_harness.dart`: `pumpScreen`, `expectNoOverflow`, `captureShot`).
- `test/flutter_test_config.dart` — loads the fonts before every test.
