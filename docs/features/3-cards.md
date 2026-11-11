# Feature 3 — Cards

Status: in progress (2026-11-11)

## Goal

Create and edit front / back [cards](../lexicon.md#card), choose to review them in one direction or both, put them in a group and give them a preset. For now a face only holds text; images will come later.

## Implementation overview

The "+" button of the navigation opens an empty card editor. The same screen edits an existing card. It shows the front, the back, the "Also in the other direction" option, the group ("No group" by default, or the group the user came from) and the preset, inherited until one is chosen. The preset row says where it comes from: "Inherited from the group: Standard" or "Global preset: Standard".

The front and the back are required. Text is stored without leading and trailing spaces.

### Created directions

Every card has two [directions](../lexicon.md#direction) in the database from its creation, whatever the choice made:

- front → back is active and due at the next slot of its preset ([Feature 1](1-scheduling.md#due-date-of-a-new-direction));
- back → front is active only when "Also in the other direction" is checked, and is then due the day after the front; otherwise it is inactive.

Creating the reverse direction upfront, even inactive, avoids having to build it later: checking the option while editing, or a back-side distillation, only has to change its state.

While editing, checking the option schedules the reverse direction as a new direction; unchecking it makes it inactive, without erasing its history.

### Bulk add

The page of a group (and that of "No group") opens the bulk add: the user pastes one card per line, front and back split by a separator. The separator is a free field pre-filled with `;`, and may be several characters long.

Reading the lines is a domain rule (`BulkCardParser`), rerun at each keystroke:

- an empty line is skipped without error;
- the front stops at the first separator, so the back may itself contain the separator;
- a line without a separator, or whose front or back is empty, is reported by its number and skipped.

The screen announces the number of ready cards and lists the skipped lines before adding. Cards are created in a single transaction, in line order, with the "Also in the other direction" option chosen once for all; they follow their group's preset.

### Card management

The card service also handles suspension (a suspended card is never due, in either direction), progress reset (each active or acquired direction starts again as a new one, history kept) and deletion. Every operation that touches due dates notifies the notification planning.

## Acceptance criteria

- [x] A card is created with a text front and back; an empty face is refused.
- [x] Without the option, only the front → back direction is active, due at the next preset slot.
- [x] With the option, the back → front direction is active too, due the next day.
- [x] Editing a card changes its text, its group, its preset, and starts or stops the reverse direction.
- [x] Bulk add creates one card per valid line, in order, and reports the skipped lines by number.
- [x] The bulk-add separator is editable; changing it rereads every line.
- [x] Resetting reschedules the active directions as new ones, keeping the history.

## Test strategy

- The service is tested on an in-memory database with a fixed clock: state and due date of each direction after creation, editing and reset, read back from the database.
- Each test also checks that the notification planning was notified, through a listener that counts calls.
- Parsing the pasted lines is tested as pure logic: spaces, empty lines, missing separator, empty face, multi-character separator.
- The bulk-add screen is tested end to end on an in-memory database: report before adding, separator change, cards created in the group with both directions.
- The editor and the bulk add are covered by golden tests.

## File mapping

- `lib/application/cards/` — card service, editor draft, providers.
- `lib/data/repositories/card_repository.dart` — storage of cards and their directions, streams of cards with their directions.
- `lib/domain/cards/bulk/` — parsing of bulk-add lines.
- `lib/features/cards/` — card editor, bulk add, group picker, card row of the lists.

## Technical details

The card streams (`watchCard`, `watchCardsOfGroup`, `watchSearch`) observe both the card table and the direction table, and reread both at each change. An answer changes a direction without touching its card: a stream observing only the cards would show stale steps and due dates.
