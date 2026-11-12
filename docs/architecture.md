# Architecture — Remanence

## Role

Remanence is an Android spaced-repetition app where the notification is the main interface. Each card has two [directions](lexicon.md#direction) tracked separately; a [preset](lexicon.md#preset) decides when each direction comes back. The reference product rules live in `SPECS.md` (not versioned); `docs/features/` describes what is implemented.

## Major pieces

The code is split into layers, from the most stable to the most platform-dependent. A layer only imports the layers listed above it.

- `lib/domain/` holds the business rules in pure Dart: the 4am calendar, the sequence engine, due-date computation, preset resolution, the distillation rhythm, bulk-add parsing. It imports no Flutter, drift or plugin code, so these rules are tested without a database or an emulator. See [Feature 1](features/1-scheduling.md) and [Feature 2](features/2-presets.md).
- `lib/data/` is persistence. The drift database (`lib/data/database/`) stores domain objects as they are; the repositories (`lib/data/repositories/`) expose reads, writes and streams per concept (cards, groups, presets, reviews). They store decisions, they never take any. See [Feature 0](features/0-foundation.md#database).
- `lib/application/` holds the services that apply domain rules to the data (create a card, answer, duplicate a preset) and the Riverpod providers that expose them. The clock (`clockProvider`) is injected here.
- `lib/notifications/` is the platform side of the notifications: the Android implementation of the alarm and notification interfaces owned by `lib/application/notifications/`, the texts of a notification, and the entry points of the background isolates. It is the only place that imports the alarm and notification plugins, so iOS can be added as a second implementation. See [Feature 7](features/7-notifications.md).
- `lib/features/` holds the screens, one folder per screen or family of screens (home, groups, cards, session, presets, settings). They read state through providers and act only through services.
- `lib/app/` is the app shell (`RemanenceApp`, tabs, "+" button), the theme, the shared widgets that reproduce the mockup components, and text formatting (intervals, presets). See [Feature 0](features/0-foundation.md).
- `lib/l10n/` holds the interface texts, as ARB files.

## How the pieces fit

The entry point initialises the notification plugins, opens the database and injects it into Riverpod (`databaseProvider`), together with the Android notification implementations. Repositories publish drift streams; screens observe them through `StreamProvider`s and refresh by themselves after every write, including writes made in another isolate. A user action calls a service, which reads the data it needs, asks the domain for a decision and writes it through the repositories. A service that moves a due date then tells the `ScheduleChangeListener`, implemented by the notification planner, which plans the next wake-ups of the app.

Some decisions depend on the day rather than on a user action: the [distillations](features/8-distillation.md) introduce their cards day after day. Their daily pass runs at app launch and at every wake-up, once per scheduling day.

Notifications run without the app: an alarm or a pressed notification button starts a background isolate, which opens the same database and builds the same services through a `ProviderContainer`, then releases them.

## Design decisions

### The domain does not know the time

Domain functions receive the current moment as a parameter instead of reading the clock. This is what makes the 4am day boundary, sub-day intervals and the two-directions rule testable without waiting or faking time.

### A sequence step is clamped to the current sequence

A direction keeps its [step](lexicon.md#step) when its preset changes or when the sequence gets shorter. Rather than rewriting the affected cards at change time, the engine clamps the step to the last existing step at each computation. A preset change with the same engine therefore needs no data migration.
