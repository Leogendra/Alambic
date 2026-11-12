# Feature 4 — Groups

Status: in progress (2026-11-11)

## Goal

Sort cards into flat [groups](../lexicon.md#group), find a card by search, see at a glance what is due in each group, and set a group's name and preset.

## Implementation overview

### Groups tab

The tab shows a search field, then "No group" first, then the groups in alphabetical order. Each row gives the number of cards and the preset followed ("global preset" for "No group"), and a badge with the number of [due](../lexicon.md#due) cards when there are any. "New" creates a group after asking for its name.

As soon as some text is typed, the group list gives way to the cards whose front or back contains that text, case-insensitively, across all groups (at most 100 results).

### Group page

The page of a group (or of "No group") recalls the number of cards, the preset, its notification mode and its schedule. Three counters follow: due cards, active cards (at least one active or acquired direction) and new cards (a direction unstarted or pending distillation). When cards wait to be started, a panel offers "Start all" ([Feature 3](3-cards.md#starting-new-cards)). A group (not "No group") then has a "Distillation" section: its distillations in progress and a "Distill" button ([Feature 8](8-distillation.md#screens)). The card list is in creation order, which is the group order. Each card shows its front, its back, the status of the front → back direction ("not started", "new", "step 2 of 6", "suspended", "pending distillation", "acquired") and its next due date ("Due", "at 15:17", "tomorrow", "in 3 d"). The "+" button creates a card directly in the group.

### Group settings

A group's settings are its name, its preset, its pause and its deletion. The preset is picked from the preset list, or inherits the global preset. The group always follows a whole preset: the screen reminds the user to duplicate a preset to adjust it.

The pause silences the group: none of its cards is notified and its distillations introduce nothing, until it is resumed; its due dates then move by the length of the pause ([Feature 7](7-notifications.md#pauses)). A paused group is greyed in the tab, with "En pause" and a pause icon instead of its due count, and its page starts with "En pause depuis le …" and a "Reprendre" button.

Deleting a group asks for confirmation, announcing how many cards go with it, then deletes the group with its cards and their history.

### Counts

Counters are computed by `GroupOverview` from all cards, the preset catalog and the current moment. A card counts as due as soon as one of its directions is. The current moment is republished every minute (`currentMomentProvider`), so a card planned for 12:00 joins the counters on time without any data change.

## Acceptance criteria

- [x] The tab lists "No group" first, then the groups, with number of cards, preset and number of due cards.
- [x] Search finds cards by their front or back, case-insensitively.
- [x] A group page shows the due / active / new counters and the card list with their status and due date.
- [x] A group is created, renamed, changes preset or inherits the global preset.
- [x] Deleting a group deletes its cards and their history.
- [x] A suspended card does not count as due.
- [x] A group is paused and resumed from its settings or its page; a paused group is shown as such in the tab.

## Test strategy

- Counts are tested on an in-memory database filled through the services, at chosen moments: before and after the preset slot, with a suspended card.
- The group service is tested for creation, renaming, refusal of an empty name and deletion with its cards.
- The tab (list and search), the group page and its settings are covered by golden tests on a sample data set, with a fixed clock.

## File mapping

- `lib/application/groups/` — group service, counts (`GroupOverview`) and providers.
- `lib/application/time/minute_ticker.dart` — current moment republished every minute.
- `lib/data/repositories/group_repository.dart` — group storage.
- `lib/features/groups/` — tab, group page and group settings.
- `lib/features/cards/card_list_tile.dart` — card row shared by the group page and the search; its texts come from `card_status_formatter.dart`.

## Technical details

"No group" is not a row of the group table: it is the `null` value of a card's group. Screens and counts treat it as a group whose identifier is `null`, with no settings and no distillation.

Search relies on SQLite `LIKE`, case-insensitive for ASCII letters only: "é" does not find "É".
