# Feature 2 — Presets

Status: in progress (2026-11-17)

## Goal

A [preset](../lexicon.md#preset) gathers the rhythm of the reviews of a card: interval sequence, failure behaviour, end of sequence. When in the day and how the cards are notified is the [schedule](../lexicon.md#schedule) of the app, set in Settings. The user has nothing to set up to begin (Standard applies everywhere), then can pick another preset for a group, or create their own. A card has no preset of its own: it follows its group.

## Implementation overview

### Shipped presets

The database is created with two presets:

- **Standard**: 1 d, 2 d, 1 wk, 1 mo, 3 mo, 6 mo. It is the initial global preset.
- **Intensive** (*Intensif*): 10 min, 1 h, 1 d, 3 d, 1 wk.

Both step back one step on failure and repeat the last interval at the end of the sequence.

Each shipped preset carries a key (`builtInKey`) that recognises it even after a rename. As long as it keeps the name it was created with, it is shown under its name in the language of the interface ("Intensif" in French, "Intensive" in English); once renamed, it shows the name the user gave it. The editor shows the translated name, and the stored name only changes when the field is edited.

### Cascading resolution

A card follows the preset of its group, read in two levels: the group's choice, otherwise the global preset. A group with no choice inherits the global preset; there is no field-by-field override.

This rule has a single implementation, `PresetResolver`. Screens and services go through `PresetCatalog`, a snapshot of all presets and of every group's choice, which resolves the preset of many groups without querying the database for each card. The preset repository publishes it as a stream and republishes it as soon as a preset, the global preset or a group's choice changes.

### Preset management

The preset list opens from Settings, which also lets the user choose the global preset. Each preset shows its sequence; the global preset carries a badge.

The editor works on a draft and writes nothing before "Save". It sets the name, the sequence (adding a step as a duration and a unit, removing a step as long as another one remains), the failure behaviour, the end of sequence and the typed answer.

"New" opens a draft with the Standard values. "Duplicate" immediately stores a copy named "<name> (copy)" and opens its editor. A copy is never a shipped preset, even when it copies Standard. Shipped presets remain editable.

### Preset change

Changing the preset of a group or the global preset rewrites no card: the step and due date of each card stay as they are. If the new sequence is shorter, the engine clamps the step to the last step at the next answer ([Feature 1](1-scheduling.md#the-step)).

## Acceptance criteria

- [x] A fresh database contains Standard and Intensive, with the intervals above.
- [x] A card follows its group's preset; a group with no choice follows the global preset.
- [x] A card has no preset of its own: neither the card editor nor the card sheet offers one.
- [x] Changing preset keeps the step and the due date; a step that is too high is clamped to the last step.
- [x] A preset is created from the Standard values, any preset can be edited, a preset can be duplicated under a new name.
- [x] A preset without a name or without a step cannot be saved.
- [x] The global preset is chosen in Settings.

## Test strategy

- The cascade is proven twice: as pure logic on `PresetCatalog`, then end to end on an in-memory database, changing the choices through the repositories as the screens do.
- Keeping the step and the due date is checked on the stored data after the change, not on an in-memory object.
- Creation, editing, duplication and refusal of an invalid preset are tested through the service, on an in-memory database.
- The list and the editor are covered by golden tests on the shipped presets, the editor in light and dark theme.

## File mapping

- `lib/domain/presets/` — preset model, shipped presets, resolution rule and `PresetCatalog`.
- `lib/data/repositories/preset_repository.dart` — reading and writing presets and the global preset, catalog stream.
- `lib/data/database/preset_companions.dart` — writing a domain `Preset` into its table.
- `lib/application/presets/` — creation, editing and duplication service; Riverpod providers of the presets and the catalog.
- `lib/features/presets/` — list, editor, step dialog and the preset picker of the group settings.
- `lib/features/settings/settings_screen.dart` — access to presets and choice of the global preset.

## Technical details

The catalog stream observes three tables (presets, settings, groups) through a `SELECT 1` witness query declared on these tables, then rereads everything in a transaction. Drift cannot natively combine several queries into one stream; this keeps each emission a consistent snapshot.
