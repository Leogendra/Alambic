# Alambic

A notification-first spaced repetition app for Android: distilate your knowledge by introducing new cards a few at the time. Most reviews happen straight from the notification.

> **Alpha:** under active development. Features may change or break, and data may be reset between versions.

## Installation

Requirements: 
- Flutter 3.50
- Android SDK with platform 37

1. Pair & connect device:

   ```bash
   adb pair <ip>:<pairing-port>
   adb connect <ip>:<port>
   ```

2. Build and install:

   ```bash
   flutter build apk --release
   flutter install --release
   ```

The release build is signed with the debug key, so it installs over a debug build and keeps the app's data.

## Usage example: learning capitals

1. In the Groupes tab, tap "Nouveau" (New) and name the group "Capitals".
2. In the group, tap "Ajout en masse" (Bulk add) and paste one card per line, front and back separated by `;`:

   ```text
   Capital of Chile ; Santiago
   Capital of Kenya ; Nairobi
   ```

3. New cards wait until they are started: tap "Tout commencer" (Start all). They arrive at noon (Standard preset), right away if noon has passed, then after 2 days, 1 week, 1 month, 3 months and 6 months as long as they are answered correctly.

## Development

### Hot reload

Start the app once in debug mode on the connected device:

```bash
flutter run
```

Then, while it runs:

- `r`: hot reload, applies code changes in about a second and keeps the current screen and state. VS Code does it on every save.
- `R`: hot restart, restarts the app without rebuilding. Needed for changes to `static final` values, `main()` or app initialization.
- `q`: quit.

After a drift schema change, run `dart run build_runner build`, then hot restart.

### More

Commands, conventions and known pitfalls: [docs/stack.md](docs/stack.md). Architecture: [docs/architecture.md](docs/architecture.md).
