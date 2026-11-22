# Feature 2 — Presets

Status: implemented (2026-11-20)

## Goal

A [preset](../lexicon.md#preset) gathers the rhythm of the reviews of a card: interval sequence and failure behaviour. When in the day and how the cards are notified is the [schedule](../lexicon.md#schedule) of the app, set in Settings; what happens after the last step and whether answers are typed are options of the [group](4-groups.md#sequence-end-and-typed-answer). The user has nothing to set up to begin (Standard applies everywhere), then can pick another preset for a group, or create their own. A card has no preset of its own: it follows its group.

## Implementation overview

### Shipped presets

The database is created with two presets:

- **Standard**: 1 d, 2 d, 1 wk, 1 mo, 3 mo, 6 mo. It is the initial global preset.
- **Intensive**: 10 min, 1 h, 1 d, 3 d, 1 wk.

Both step back one step on failure.

Each shipped preset carries a key (`builtInKey`) that recognises it even after a rename. As long as it keeps the name it was created with, it is shown under its name in the language of the interface ("Intensif" in French, "Intensive" in English); once renamed, it shows the name the user gave it. The editor shows the translated name, and the stored name only changes when the field is edited.

### Cascading resolution

A card follows the preset of its group. Every group has exactly one, from its creation: a new group takes the global preset of the moment, and keeps its own afterwards, even when another preset is made the default. There is no inheritance and no field-by-field override.

Screens and services go through `PresetCatalog`, a snapshot of all presets and of the preset of every group, which resolves the preset of many groups without querying the database for each card. The preset repository publishes it as a stream and republishes it as soon as a preset, the global preset or the preset of a group changes.

### Preset management

A single "Presets" row of Settings opens the Presets screen, one tile per preset. A tile shows the name, the steps ("1 d · 2 d · 1 wk · 1 mo · 3 mo · 6 mo") and the failure behaviour ("On failure: one step back"). Two buttons act on it: "Edit" opens the editor, "Make default" makes it the global preset. The global preset shows a "Default" badge in place of that button. "New preset", at the end of the list, opens the editor on a draft with the Standard values. The tile's menu holds "Duplicate", which stores a copy named "<name> (copy)" right away, and "Delete", except on the global preset: another preset must be made the default first.

Deleting a preset first says how many groups follow it ("2 groups use it: they will move to the default preset, Standard, keeping their steps and due dates."). Once confirmed, those groups move to the global preset and the preset is deleted. Making another preset the default moves no group: the global preset only serves new groups and the groups of a deleted preset. Their cards keep their steps and due dates, as for any preset change; a step beyond the shorter sequence counts as its last step.

The editor works on a draft and writes nothing before "Save". It sets the name, the sequence (adding a step as a duration and a unit, from minutes to years, removing a step as long as another one remains) and the failure behaviour, nothing else. The failure behaviour is a three-way choice, "One step back", "Back to start" or "Stay" ([Feature 1](1-scheduling.md#on-failure)), with a line under it that says what a missed card then does ("A missed card goes back to the previous step.").

A copy is never a shipped preset, even when it copies Standard. Shipped presets remain editable.

### Preset change

Changing the preset of a group or the steps of a preset rewrites no card: the step and due date of each card stay as they are, a card in remanence stays in remanence, and an acquired card stays acquired. If the new sequence is shorter, a card beyond it counts as being at the last step: its sheet shows the last step, and its next answer starts from there ([Feature 1](1-scheduling.md#the-step)).

## Acceptance criteria

- [x] A fresh database contains Standard and Intensive, with the intervals above.
- [x] A card follows its group's preset; every group has one, a new group taking the global preset of the moment.
- [x] A card has no preset of its own: neither the card editor nor the card sheet offers one.
- [x] Changing the preset of a group or the steps of a preset keeps the step and the due date; a step beyond a shorter sequence counts as the last step, and the next answer starts from it; a card in remanence stays in remanence.
- [x] The editor sets the name, the steps and the failure behaviour only.
- [x] A preset is created from the Standard values, any preset can be edited, a preset can be duplicated under a new name.
- [x] A preset without a name or without a step cannot be saved.
- [x] The editor says, under the failure choice, the effect of the chosen behaviour.
- [x] The global preset is chosen with "Make default" on its tile of the Presets screen, which is reached from a single "Presets" row of Settings; it moves no existing group and only serves the groups created afterwards.
- [x] A tile shows the steps and the failure behaviour of its preset; its menu duplicates it.
- [x] Any preset but the global one can be deleted, after a confirmation that gives the number of groups that follow it; these groups move to the global preset, their cards keeping their steps and due dates.

## Test strategy

- The cascade is proven twice: as pure logic on `PresetCatalog`, then end to end on an in-memory database, changing the choices through the repositories as the screens do.
- Keeping the step and the due date is checked on the stored data after each kind of change (group, edited steps), not on an in-memory object, then followed by an answer from the last step.
- Creation, editing, duplication and refusal of an invalid preset are tested through the service, on an in-memory database.
- Deletion is tested through the service on groups and cards read back from the database: the groups that follow the preset move to the global one, the others keep theirs, the cards keep their steps and due dates, and the global preset is refused. The screen test checks that the global preset offers no "Delete" and that the confirmation counts the groups.
- The Presets screen and the editor are covered by screen tests with a capture on the shipped presets, in light and dark theme; "Make default" and "Duplicate" are exercised on the screen and checked in the database.

## File mapping

- `lib/domain/presets/` — preset model, shipped presets, resolution rule and `PresetCatalog`.
- `lib/data/repositories/preset_repository.dart` — reading and writing presets and the global preset, catalog stream.
- `lib/data/database/preset_companions.dart` — writing a domain `Preset` into its table.
- `lib/application/presets/` — creation, editing, duplication and deletion service; Riverpod providers of the presets and the catalog.
- `lib/features/presets/` — list, editor, step dialog and the preset picker of the group settings.
- `lib/features/settings/settings_screen.dart` — the "Presets" row.

## Technical details

The catalog stream observes three tables (presets, settings, groups) through a `SELECT 1` witness query declared on these tables, then rereads everything in a transaction. Drift cannot natively combine several queries into one stream; this keeps each emission a consistent snapshot.
