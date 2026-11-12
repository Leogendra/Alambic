# Feature 3 — Cards

Status: in progress (2026-11-11)

## Goal

Create and edit front / back [cards](../lexicon.md#card), choose to review them in one direction or both, put them in a group and give them a preset, then follow and manage each card from its sheet. For now a face only holds text; images will come later.

## Implementation overview

The "+" button of the navigation opens an empty card editor. The same screen edits an existing card. It shows the front, the back, the "Also in the other direction" option, the group ("No group" by default, or the group the user came from) and the preset, inherited until one is chosen. The preset row says where it comes from: "Inherited from the group: Standard" or "Global preset: Standard".

The front and the back are required. Text is stored without leading and trailing spaces.

### Created directions

Every card has two [directions](../lexicon.md#direction) in the database from its creation, whatever the choice made:

- front → back is [unstarted](../lexicon.md#unstarted);
- back → front is unstarted too when "Also in the other direction" is checked, inactive otherwise.

Creating the reverse direction upfront, even inactive, avoids having to build it later: checking the option while editing, or a back-side distillation, only has to change its state.

While editing, checking the option makes the reverse direction unstarted; unchecking it makes it inactive, without erasing its history.

### Starting new cards

A new card is never due by itself. The user decides how its directions enter review, so that a block of fifty pasted cards does not land on the same day by accident. Two ways exist:

- the classic start: "Start all" on the page of a group (or of "No group") starts every unstarted direction of the block at once (and the directions left pending by a stopped [distillation](8-distillation.md)), and they are all due today ([Feature 1](1-scheduling.md#starting-a-direction));
- the distillation, which introduces the directions a few at a time, is described in its own feature.

A single direction can also be started on its own from the card sheet.

### Bulk add

The page of a group (and that of "No group") opens the bulk add: the user pastes one card per line, front and back split by a separator. The separator is a free field pre-filled with `;`, and may be several characters long.

Reading the lines is a domain rule (`BulkCardParser`), rerun at each keystroke:

- an empty line is skipped without error;
- the front stops at the first separator, so the back may itself contain the separator;
- a line without a separator, or whose front or back is empty, is reported by its number and skipped.

The screen announces the number of ready cards and lists the skipped lines before adding. Cards are created in a single transaction, in line order, with the "Also in the other direction" option chosen once for all; they follow their group's preset.

### Card sheet

Touching a card in a list opens its sheet. It shows both faces, then one direction at a time, chosen with a two-segment switch whose segments already summarise each direction ("step 1 of 6 · tomorrow"). For the shown direction, the sheet gives:

- its [step](../lexicon.md#step) on a bar of the preset sequence, with the interval of each step, or for an [adaptive](../lexicon.md#adaptive-engine) preset its current interval with its stability and difficulty ("Interval 11 d", "Stability 10.7 d · difficulty 5.3 of 10"); then its next review ("Next review Fri 13 Nov, 12:00", or "Due now");
- or, when it is not scheduled, why: not studied, waiting in a distillation, or [unstarted](../lexicon.md#unstarted) (or left by a stopped distillation), with a "Start this direction" button;
- its upcoming "Review soon" reminders, each removable;
- its history, most recent first: date, answer, a "bonus" tag for a [bonus review](../lexicon.md#bonus-review), and the effect ("→ 1 mo", "back to 2 d", "acquired", "no effect"); an FSRS answer gives the interval to the due date it chose ("→ 11 d"). The effect is read against the current preset, so it may differ from what the user saw if the preset changed since.

Touching the faces opens a one-card session on the shown direction; when that direction is not due, the answer is a bonus review. The edit button opens the card editor, and the menu deletes the card after confirmation.

### Card management

Three actions sit under the direction panel:

- "Review soon" adds an [extra reminder](../lexicon.md#extra-reminder) on a chosen day (tomorrow, the day after, the coming weekend, or any date) at a chosen time, the preset slot by default. A moment already past is refused. It is offered only for a started direction.
- "Suspend" / "Resume": a suspended card is never due, in either direction.
- "Reset", after confirmation: each active or acquired direction starts again from scratch, due today, history kept.

Every operation that touches due dates or reminders notifies the notification planning.

## Acceptance criteria

- [x] A card is created with a text front and back; an empty face is refused.
- [x] A new card is not due: its front → back direction is unstarted, and so is the back → front one with the option; without it, the reverse is inactive.
- [x] "Start all" on a group page makes every unstarted direction of the group due today, the reverse of a card the next day.
- [x] Editing a card changes its text, its group, its preset, and adds or stops the reverse direction.
- [x] Bulk add creates one card per valid line, in order, and reports the skipped lines by number.
- [x] The bulk-add separator is editable; changing it rereads every line.
- [x] Resetting makes the active and acquired directions due today from scratch, keeping the history.
- [x] The card sheet shows, per direction, the step, the next review or why there is none, the reminders and the history with each answer's effect.
- [x] An unstarted direction can be started from the card sheet.
- [x] "Review soon" adds a reminder at a chosen day and time; a past moment is refused; a reminder can be removed.
- [x] Touching the faces reviews the shown direction, as a bonus review when it is not due.

## Test strategy

- The service is tested on an in-memory database with a fixed clock: state and due date of each direction after creation, start, editing and reset, read back from the database.
- Each test also checks that the notification planning was notified, through a listener that counts calls.
- Parsing the pasted lines is tested as pure logic: spaces, empty lines, missing separator, empty face, multi-character separator.
- The bulk-add screen is tested end to end on an in-memory database: report before adding, separator change, cards created in the group with both directions.
- The days offered by "Review soon" are tested as pure logic, Saturday and Sunday included; the reminder service is tested on an in-memory database (added, refused in the past, removed).
- The editor, the bulk add and the card sheet (with history, bonus reviews and a reminder) are covered by golden tests; starting a direction from the sheet is tested on screen.

## File mapping

- `lib/application/cards/` — card service, editor draft, providers.
- `lib/application/reminders/` and `lib/data/repositories/reminder_repository.dart` — "Review soon" reminders.
- `lib/domain/reviews/review_soon_days.dart` — the days offered by "Review soon".
- `lib/data/repositories/card_repository.dart` — storage of cards and their directions, streams of cards with their directions.
- `lib/domain/cards/bulk/` — parsing of bulk-add lines.
- `lib/features/cards/` — card editor, card sheet and its panels, "Review soon" sheet, bulk add, group picker, card row of the lists.

## Technical details

The card streams (`watchCard`, `watchCardsOfGroup`, `watchSearch`) observe both the card table and the direction table, and reread both at each change. An answer changes a direction without touching its card: a stream observing only the cards would show stale steps and due dates.
