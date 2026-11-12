# Feature 2 — Presets

Status: in progress (2026-11-11)

## Goal

A [preset](../lexicon.md#preset) gathers all the repetition rules of a card: interval sequence, failure behaviour, end of sequence, schedule, notification mode. The user has nothing to set up to begin (Standard applies everywhere), then can pick another preset for a group or a card, or create their own.

## Implementation overview

### Shipped presets

The database is created with three presets, all at a fixed 12:00 time:

- **Standard**: 1 d, 2 d, 1 wk, 1 mo, 3 mo, 6 mo. It is the initial global preset.
- **Intensive** (*Intensif*): 10 min, 1 h, 1 d, 3 d, 1 wk.
- **Adaptive** (*Adaptatif*): the adaptive engine ([Feature 1](1-scheduling.md#the-adaptive-engine)) at a 90 % target retention, one grouped reminder per group opening the app.

Standard and Intensive send one notification per card, step back one step on failure and repeat the last interval at the end of the sequence. Adaptive keeps the Standard sequence, unused while its engine is adaptive.

Each shipped preset carries a key (`builtInKey`) that recognises it even after a rename, so that its name can be translated.

### Cascading resolution

A card's preset is read in three levels: the choice made on the card, otherwise its group's, otherwise the global preset. A level with no choice inherits from the next one; there is no field-by-field override. Cards without a group go straight from their own choice to the global preset.

This rule has a single implementation, `PresetResolver`. Screens and services go through `PresetCatalog`, a snapshot of all presets and of every group's choice, which resolves the preset of many cards without querying the database for each one. The preset repository publishes it as a stream and republishes it as soon as a preset, the global preset or a group's choice changes.

### Preset management

The preset list opens from Settings, which also lets the user choose the global preset. Each preset shows its sequence, its schedule and its notification mode; the global preset carries a badge.

The editor works on a draft and writes nothing before "Save". It first sets the engine: fixed sequence or adaptive. A sequence preset then sets the sequence (adding a step as a duration and a unit, removing a step as long as another one remains), the failure behaviour and the end of sequence; an adaptive preset sets instead its target retention, from 70 % to 97 % by steps of 1 %. Both then set the typed answer, the schedule (fixed time or time range) and the notification mode (one per card, or a grouped reminder that opens the app or chains the cards). These last three settings are stored already; the notifications that use them are described in their own feature.

"New" opens a draft with the Standard values. "Duplicate" immediately stores a copy named "<name> (copy)" and opens its editor. A copy is never a shipped preset, even when it copies Standard. Shipped presets remain editable.

In the list, an adaptive preset shows "Intervals computed from your answers. Target retention 90 %." instead of its sequence.

### Preset change

Changing the preset of a card, of a group or the global preset rewrites no card: the step and due date of each direction stay as they are. If the new sequence is shorter, the engine clamps the step to the last step at the next answer ([Feature 1](1-scheduling.md#the-step)).

## Acceptance criteria

- [x] A fresh database contains Standard and Intensive, with the intervals above and the fixed 12:00 time.
- [x] A card with no choice follows its group's preset, a group with no choice follows the global preset.
- [x] The choice made on a card wins over its group's.
- [x] Changing preset (same engine) keeps the step and the due date; a step that is too high is clamped to the last step.
- [x] A preset is created from the Standard values, any preset can be edited, a preset can be duplicated under a new name.
- [x] A preset without a name or without a step cannot be saved.
- [x] A fresh database contains Adaptive, an adaptive preset at a 90 % target retention.
- [x] The editor switches a preset between a sequence and the adaptive engine; an adaptive preset sets its target retention from 70 % to 97 %.
- [x] The global preset is chosen in Settings.

## Test strategy

- The cascade is proven twice: as pure logic on `PresetCatalog`, then end to end on an in-memory database, changing the choices through the repositories as the screens do.
- Keeping the step and the due date is checked on the stored data after the change, not on an in-memory object.
- Creation, editing, duplication and refusal of an invalid preset are tested through the service, on an in-memory database.
- The list and the editor are covered by golden tests on the shipped presets.

## File mapping

- `lib/domain/presets/` — preset model, shipped presets, resolution rule and `PresetCatalog`.
- `lib/data/repositories/preset_repository.dart` — reading and writing presets and the global preset, catalog stream.
- `lib/data/database/preset_companions.dart` — writing a domain `Preset` into its table.
- `lib/application/presets/` — creation, editing and duplication service; Riverpod providers of the presets and the catalog.
- `lib/features/presets/` — list, editor, step dialog and the preset picker reused by groups and cards.
- `lib/features/settings/settings_screen.dart` — access to presets and choice of the global preset.

## Technical details

The catalog stream observes three tables (presets, settings, groups) through a `SELECT 1` witness query declared on these tables, then rereads everything in a transaction. Drift cannot natively combine several queries into one stream; this keeps each emission a consistent snapshot.

Choosing a different engine (sequence to adaptive) resets the progression. It does not exist yet, for lack of an adaptive engine.
