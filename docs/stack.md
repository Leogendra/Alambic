# Stack — Alambic

## Languages and environments

- Dart 3.14 and Flutter 3.50 (stable channel). The V1 target is Android only: the project contains only the `android/` folder.
- Android: AGP 9.3, Gradle 9.5, Kotlin 2.4, `compileSdk` 37, Java 17 target with core library desugaring (`coreLibraryDesugaring`). The release workflow builds with JDK 21: the lint bundled with AGP 9.3 crashes on JDK 17 (`NoSuchMethodError` on `List.removeLast()`).

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
- `package_info_plus`: the version of the installed app, shown in Settings.
- `url_launcher`: opens the GitHub repository in the browser.
- `intl` and `flutter_localizations`: translations generated from the ARB files of `lib/l10n/`.
- DM Sans font (OFL), bundled as four static weights in `assets/fonts/`.

## Commands

- Dependencies: `flutter pub get`. Translations are regenerated at the same time into `lib/l10n/generated/`, which is not versioned.
- drift generated code: `dart run build_runner build`. The `*.g.dart` files are versioned so that a fresh clone compiles without this step.
- Schema change: raise `schemaVersion`, run `dart run build_runner build`, then `dart run drift_dev make-migrations`. It saves the new schema in `drift_schemas/`, writes the steps file next to the database and the generated tests in `test/drift/`. Write the step in `onUpgrade` with `stepByStep`, then run the tests. The paths are set in `build.yaml`.
- Analysis: `flutter analyze`. Formatting: `dart format lib test`.
- Tests: `flutter test`; for a local pass, `flutter test --fail-fast` stops at the first failure.
- Screen captures: `flutter test --dart-define=shots=true test/app test/features` writes one PNG per screen state to `build/shots/` (not versioned, about 15 s). Without the flag, `captureShot` (`test/support/screen_harness.dart`) does nothing. The three images of the README, in `docs/images/`, are copies of captures of the same name, refreshed by hand: copy them from `build/shots/` after a visible change to their screens.
- Debug APK: `flutter build apk --debug`. Install on a connected phone: `flutter install` or `flutter run`.
- Release: run the `Release` workflow by hand from GitHub Actions, on `main`. It reads the version of `pubspec.yaml` without its build number (`1.0.0+1` gives the tag `v1.0.0`) and stops if that tag exists or if `CHANGELOG.md` has no `## [1.0.0]` section. Then it analyzes, tests, builds a universal release APK and publishes it as `alambic-v1.0.0.apk` in a GitHub release marked Latest, with that changelog section as its text. The APK is signed with the keystore of the secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD`, written to `android/key.properties` by the workflow. Without that file, a local release build is signed with the debug keys.
- Notifications are tested with in-memory fakes of the platform interfaces (`test/support/fake_notifications.dart`); the Android side is checked on a phone.
- Tests that touch the database open a real in-memory SQLite database, with `closeStreamsSynchronously` so that widget tests do not end on pending timers. A widget test that opens one is declared with `testScreen` (`test/support/test_screen.dart`) instead of `testWidgets`, and its `tearDown` closes the database with `closeTestDatabase`: see Pitfalls.
- A widget test fails after 30 s instead of the 10 minutes of flutter_test, set in `test/flutter_test_config.dart`. `--timeout` and `dart_test.yaml` have no effect on it: `testWidgets` passes its own timeout to package:test.

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
- flutter_test unmounts the widgets of a test only when it passes. A failed test leaves its screen mounted with its drift streams open, and a database closed under them never finishes closing. `testScreen` unmounts the screen even on failure, before the `tearDown`. `closeTestDatabase` bounds the close to 5 s, so a test that misses the rule fails with a `TimeoutException` in `closeTestDatabase` instead of hanging the run.
- No test compares pixels. Rendered images depend on the machine, the Flutter version and the pinned `material_ui` (Material is no longer part of the SDK, so its fixes arrive through a bump of `pubspec.yaml`): exact image comparisons (goldens) failed on the antialiasing of the glyphs alone between machines, and were dropped for the captures written on demand. The `environment` of `pubspec.yaml` still sets the minimum Flutter version, so that an older SDK refuses `pub get` instead of rewriting `pubspec.lock`.
- In widget tests, a Future created in the fake time of one test never completes in the next one. `rootBundle.loadString` caches the Future of each asset, so a second test reading the same asset waits forever: an asset read from a screen under test is loaded with `cache: false`. Work done on the database from a button (drift runs on real time) is awaited by alternating `tester.runAsync` with a short delay and `tester.pump()` until its effect shows, instead of a single fixed delay.
