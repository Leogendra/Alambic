# Alambic

A notification-first spaced repetition app for Android: most reviews happen straight from the notification, without opening the app. Front / back cards are reviewed according to presets (sequences of intervals), and distillation introduces new cards a few at a time.

## Installation

Requirements: Flutter 3.47 (stable), an Android SDK with platform 37, and an Android phone with wireless debugging on (Developer options › Wireless debugging), on the same Wi-Fi as the computer.

1. First time only, pair the computer: on the phone, Wireless debugging › Pair device with pairing code, then enter the code it shows:

   ```sh
   adb pair <ip>:<pairing-port>
   ```

2. Connect, with the address shown at the top of the Wireless debugging screen (its port changes each time wireless debugging is turned on):

   ```sh
   adb connect <ip>:<port>
   ```

3. Build and install:

   ```sh
   flutter build apk --release
   flutter install --release
   ```

The release build is signed with the debug key, so it installs over a debug build and keeps the app's data.

## Usage

The app's interface is in French; UI labels are quoted below as they appear on screen.

On first launch, the app creates the Standard and Intensif presets. The "+" button creates a card; the Groupes (Groups) tab organizes cards and allows bulk adding. Due cards arrive as notifications at the preset's time, with "Correct" and "À revoir" (Again) buttons.

### Example: learning capitals

1. In the Groupes tab, tap "Nouveau" (New) and name the group "Capitals".
2. In the group, tap "Ajout en masse" (Bulk add) and paste one card per line, front and back separated by `;`:

   ```text
   Capital of Chile ; Santiago
   Capital of Kenya ; Nairobi
   ```

3. New cards wait until they are started: tap "Tout commencer" (Start all). They arrive at noon (Standard preset), right away if noon has passed, then after 2 days, 1 week, 1 month, 3 months and 6 months as long as they are answered correctly.

### Example: cramming for an exam within a day

1. Réglages (Settings), Presets: pick "Intensif" (10 min, 1 h, 1 d, 3 d, 1 wk).
2. In the group settings, select this preset. A card answered correctly comes back 10 minutes later, then an hour after that.

## Development

Commands, conventions and known pitfalls: [docs/stack.md](docs/stack.md). Architecture: [docs/architecture.md](docs/architecture.md).
