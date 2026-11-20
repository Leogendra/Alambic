# Stack — Alambic

## Languages and environments

- Dart 3.14 and Flutter 3.50 (stable channel). The V1 target is Android only: the project contains only the `android/` folder.
- Android: AGP 9.3, Gradle 9.5, Kotlin 2.4, `compileSdk` 37, Java 17 with core library desugaring (`coreLibraryDesugaring`).

## Key libraries

Versions are pinned exactly in `pubspec.yaml` (no `^`) and in `pubspec.lock`, so that a build on another machine produces the same app. A version bump is an explicit change of both files.

- `material_ui`: the Material widgets and their localizations, which replace `package:flutter/material.dart`, deprecated since Flutter 3.47.
- `flutter_riverpod`: state and dependency injection.
- `drift` and `drift_flutter`: local SQLite database (groups, cards, distillations, reviews, presets). `drift_dev` and `build_runner` generate code during development.
- `shared_preferences`: interface preferences.
- `flutter_local_notifications`: notifications with action buttons handled in the background.
- `android_alarm_manager_plus`: wakes the app up at a due moment, including after a phone restart.
- `image_picker`: picks a card image from the phone gallery, scaled down on the way.
- `path_provider`: locates the folder of the app, where the database and the image store live.
- `archive`: reads and writes the zip file of a backup.
- `file_picker`: the system dialogs that save a backup file and pick one to import.
- `intl` and `flutter_localizations`: translations generated from the ARB files of `lib/l10n/`.
- DM Sans font (OFL), bundled as four static weights in `assets/fonts/`.

## Commands

- Dependencies: `flutter pub get`. Translations are regenerated at the same time into `lib/l10n/generated/`, which is not versioned.
- drift generated code: `dart run build_runner build`. The `*.g.dart` files are versioned so that a fresh clone compiles without this step.
- Analysis: `flutter analyze`. Formatting: `dart format lib test`.
- Tests: `flutter test`. Regenerate golden images after an intended visual change: `flutter test --update-goldens`.
- Debug APK: `flutter build apk --debug`. Install on a connected phone: `flutter install` or `flutter run`.
- Notifications are tested with in-memory fakes of the platform interfaces (`test/support/fake_notifications.dart`); the Android side is checked on a phone.
- Tests that touch the database open a real in-memory SQLite database, with `closeStreamsSynchronously` so that widget tests do not end on pending timers.

## Conventions

- Code, comments and documentation in English. Interface texts are written in English first, in `app_en.arb`, then translated in `app_fr.arb`; a test fails when a text is missing from one of them. `app_en.arb` is the template: it alone carries the placeholder declarations. An amount and its unit ("3 mo", "6 mois") are joined by a non-breaking space (`\u00a0`), so that a line never breaks between them.
- Official Dart style (`dart format`, two-space indentation) and the `flutter_lints` lints, extended in `analysis_options.yaml`. The `.editorconfig` carries these rules to other editors.
- One class, enum or type per file, named after it.
- The domain (`lib/domain/`) is pure Dart: it imports neither Flutter, nor drift, nor any plugin. The current time is always passed in as a parameter.

## Pitfalls

- `flutter_local_notifications` 23 requires `compileSdk` 37. With AGP 9, SDK 37 installs under the name `android-37.0`: `compileSdk = 37` fails with "Failed to find target with hash string 'android-37'". The `compileSdk { version = release(37) { minorApiLevel = 0 } }` syntax of `android/app/build.gradle.kts` is needed.
- On Windows, the pub cache must be on the same drive as the project. Otherwise the Kotlin incremental caches of the plugins fail with "Could not close incremental caches", since the plugin sources live in the pub cache. The default cache is on C:; with the project on D:, set the `PUB_CACHE` environment variable to a folder on D: and run `flutter pub get` again.
- `android_alarm_manager_plus` does not fall back to an inexact alarm without the exact alarm permission: it logs an error and drops the alarm. Ask for an exact alarm only when `canScheduleExactNotifications` allows it.
- Notification buttons without user interface are always delivered to the background handler of `flutter_local_notifications`, even when the app is open.
- When a golden comparison fails, the next tests of the same file that use the database can hang until the 10-minute timeout instead of failing. A run that suddenly takes minutes is a golden mismatch: rerun the file alone to see the first failure.
- Golden images depend on the rendering of the platform that generated them (Windows here). Regenerating them on another platform produces differences of a few pixels. They also depend on the Flutter version: the `environment` of `pubspec.yaml` sets the minimum one, so that an older SDK refuses `pub get` instead of rewriting `pubspec.lock` and failing every golden on the glyphs. The pinned version of `material_ui` matters too: Material is no longer part of the SDK, so its bug fixes arrive through a bump of `pubspec.yaml` and can change a golden.
- In widget tests, a Future created in the fake time of one test never completes in the next one. `rootBundle.loadString` caches the Future of each asset, so a second test reading the same asset waits forever: an asset read from a screen under test is loaded with `cache: false`. Work done on the database from a button (drift runs on real time) is awaited by alternating `tester.runAsync` with a short delay and `tester.pump()` until its effect shows, instead of a single fixed delay.
