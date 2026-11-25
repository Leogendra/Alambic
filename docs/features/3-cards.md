# Feature 3 — Cards

Status: in progress (2026-11-24)

## Goal

Create and edit front / back [cards](../lexicon.md#card), put them in a group, then follow and manage each card from its sheet. A face holds a text, an image, or both.

## Implementation overview

"Add a card", from the "+" button of the navigation or of a group page, opens an empty card editor. The same screen edits an existing card. It shows the front, the back and the group (the group the user came from, or none chosen yet). It offers no preset: a card follows the preset of its group ([Feature 2](2-presets.md#cascading-resolution)).

Every card needs a group. The group row opens the list of groups; its "+" button asks for the name of a new group, creates it and chooses it. With no group yet, the row itself asks for a name. Saving without a group is refused with a message.

Each face needs a text, an image, or both. Text is stored without leading and trailing spaces; an empty text is stored as no text.

### Images

Each face takes one image at most. "Image", next to the face label, opens the phone gallery; the picture is scaled down to 1600 px on its longest side and compressed at quality 85, so that it stays light in storage, in notifications and in an export. The editor shows a thumbnail with a button to remove it. Nothing is stored before "Create" or "Save": the card service then copies the picked picture into the image store, a folder of the app next to the database, and the card keeps the file name only.

An image replaced or removed, the images of a deleted card, and those of the cards of a deleted group leave the store with them.

The image shows under the text of the face on the card sheet, above the text in a session, as a thumbnail before the front in the card lists, and in the expanded notification ([Feature 7](7-notifications.md#showing-a-cards-image)). A face without text reads "Image" in the lists. The typed answer is off for a card whose answer face has no text.

### New cards wait in their group's queue

A new card is never due by itself: it is [pending](../lexicon.md#pending) at the end of the [queue](../lexicon.md#queue) of its group, and only the group's [distillation](8-distillation.md) introduces it. A block of fifty pasted cards therefore never lands on the same day.

Moving a card to another group keeps the progression of an introduced card; a pending card joins the end of the new group's queue.

### Bulk add

"Add several cards", from the same "+" button, opens the bulk add: the user pastes one card per line, front and back split by a separator. The separator is a free field pre-filled with `;`, and may be several characters long. The group row, with the same "+" button as the editor, starts on the group the user came from, or on none chosen yet when the "+" of the navigation opened it; adding with no group is refused with a message, as in the editor.

Reading the lines is a domain rule (`BulkCardParser`), rerun at each keystroke:

- an empty line is skipped without error;
- the front stops at the first separator, so the back may itself contain the separator;
- a line without a separator, or whose front or back is empty, is reported by its number and skipped.

The screen announces the number of ready cards and lists the skipped lines before adding.

Under them, the order of the batch: "In order" (by default), the top line first, or "Shuffle". Shuffling draws an order when it is chosen, and choosing it again draws a new one; it only mixes the batch, never the cards already waiting. The draw mixes places in the batch, not texts: a line edited after the draw keeps its place and every other card keeps its own. A valid line added or removed, a line that becomes valid or invalid included, changes the size of the batch and mixes the whole batch again with the same draw, so the "First" box may change. A "First" box shows the card of the batch that will come out first ("Capital of Chile → Santiago"), with "after the 2 cards already waiting" when the queue of the group is not empty. It follows every keystroke, separator and order change, and is hidden while no line is valid.

Cards are created in a single transaction, in the order shown, at the end of the group's queue; they follow their group's preset.

### Where a card stands

No status and no step is shown. A list shows each card's front, its back below, and on the right where it stands:

- the time left before it is due, in days up to 29 ("1 d", "3 d"), then rounded to the month ("3 mo") and, from 365 days, to the year ("2 yr"), or "Due"; it is in the accent colour;
- "waiting" or "learned" for a card without a next date.

### Card sheet

Touching a card in a list opens its sheet. The top bar gives the name of the group, the edit button, which opens the card editor, and a menu whose only entry deletes the card after a confirmation. Below come three panels, and "Review now" stays at the bottom of the screen.

The first panel shows the front. The back is hidden behind "Show the answer", so that the sheet does not give the answer away before a review; touching it shows the back until the sheet is left. Nothing is recorded.

The second panel says where the card stands, in one line and a detail:

- a card due today: "Due now";
- a scheduled card, in its sequence or in [remanence](../lexicon.md#remanence): "Next review tomorrow", "in 3 d" or "in 6 mo", rounded as in the lists, then its date and time ("Fri, Nov 13, 12:00");
- a [learned](../lexicon.md#acquired) card: "Learned", "This card does not come back.";
- a [pending](../lexicon.md#pending) card: its rank in the [queue](../lexicon.md#queue) of its group ("Waiting · 3 of 44"), then when it should come out ("Comes out around November 26"), or why no date can be given: the distillation is paused, the group does not distill, or the card lies more than two years away. "To the head" and "To the end" move it there at once, each off when the card is already there.

Under it, the track of the steps: one segment per step of the preset, its interval below. The steps passed are filled, the current one is outlined with its interval in bold, the next ones are left empty. When the group ends in remanence, a dot follows the last segment with the remanence interval: grey, then filled once the card reaches it. From seven steps, the intervals are written smaller; beyond eight, only those of the first, the current and the last step are written, so that none is cut. A settings button, at the right of the line that says where the card stands, opens the step sheet; the track, which takes the whole width of the panel, opens it too.

The third panel gives the last answer "Correct" and the last answer "Again", [bonus reviews](../lexicon.md#bonus-review) included, as "3 d ago" (rounded as in the lists), "today", or "never". The full history stays in the database and in the backups.

"Review now" opens a one-card session, whatever the card: an answer to a card that is not due, pending cards included, is a bonus review, and a pending card keeps its place in the queue.

### Card management

The step sheet lists, in this order: "Waiting in the queue", each step of the preset by its interval, then the end of sequence of the group, "Remanence · 6 mo" or "Learned". Each step gives the date it would set, so the user sees what a choice does before making it. Where the card stands is selected; a pending card is not offered the queue.

A step chosen applies at once, and a message gives the new date ("Next review Tue, Nov 17, 12:00", or "Card learned"). It schedules the card as if an answer had brought it to that step at this moment ([Feature 1](1-scheduling.md)): an interval of a day or more lands on the [daily slot](../lexicon.md#daily-slot), a shorter one counts from now. A pending card chosen a step leaves its queue without waiting for its distillation. This is how a card already known is put far along, and how a card that comes back too rarely is brought closer.

"Waiting in the queue" asks for a confirmation first, since the card loses its progression: it goes back to the end of its group's queue. In both cases the history is kept and gets no entry: a step changed by hand is not an answer.

Every operation that touches due dates or the queue notifies the notification planning.

## Acceptance criteria

- [x] A card is created with a text front and back in a group; an empty face, or a missing group, is refused.
- [x] The "+" of the group row creates a group from its name and chooses it, in the editor and in the bulk add.
- [x] Each face takes an image from the gallery, alone or with a text; the image is copied into the app and leaves it with its card, its group, or when it is replaced or removed.
- [x] A new card is not due: it is pending at the end of its group's queue.
- [x] Editing a card changes its text, its group and its preset; a pending card moved to another group joins the end of its queue, an introduced one keeps its progression.
- [x] Bulk add creates one card per valid line and reports the skipped lines by number.
- [x] The batch joins the end of the queue in the order of the list, or in a shuffled order drawn when "Shuffle" is chosen and drawn again at each touch; a line edited after the draw keeps its place. The "First" box shows its first card and the cards already waiting.
- [x] The bulk-add separator is editable; changing it rereads every line.
- [x] The step sheet puts a card at any step of its preset, at the end of its sequence, or back at the end of its queue after a confirmation; a step counts from now, a pending card chosen a step is introduced, and no history entry is written.
- [x] Lists show the time left in days, months or years, in accent, or "waiting", "learned": no status and no step.
- [x] The card sheet hides the back until "Show the answer", says when the card comes back or why it does not, shows the track of its steps with the remanence as a dot, and its last "Correct" and "Again".
- [x] A pending card shows its rank in the queue and when it should come out, or why no date can be given, and moves to the head or the end of the queue.
- [x] "Review now" stays at the bottom and opens a one-card session, a bonus review when the card is not due; a pending card keeps its place.

## Test strategy

- The service is tested on an in-memory database with a fixed clock: state, queue position and due date after creation, group change and editing, read back from the database.
- The step change is tested the same way: a step higher and lower, a step of less than a day, a pending card introduced, the remanence, an acquired end, an acquired card brought back, the queue, and an empty history afterwards. The targets offered and where a card stands are tested as pure logic.
- Each test also checks that the notification planning was notified, through a listener that counts calls.
- Parsing the pasted lines is tested as pure logic: spaces, empty lines, missing separator, empty face, multi-character separator.
- The order of a batch is tested as pure logic: listed, shuffled within the batch, the same draw giving the same order, an edited line keeping every place.
- The bulk-add screen is tested end to end on an in-memory database with a seeded random generator: report and "First" box before adding, separator change, cards created pending at the end of the queue of the group, in the order listed or drawn.
- The group row is tested on the editor: a card without group is refused, "+" creates a group and puts the card in it, and with no group the row asks for a name.
- The editor, the bulk add and the card sheet are covered by screen tests with a capture. The card sheet is captured in light and dark theme, back hidden then shown, and in each state: due, scheduled, pending with its arrival, learned, in remanence, and with a preset too long to write every interval. The step sheet is driven to a step, to the remanence and back to the queue, and "Review now" to an answer on a pending card.
- Images are tested on a store in a temporary folder with a PNG fixture (`test/support/fixtures/flag.png`): copied on creation, kept, replaced and removed on update, deleted with the card and the group. The editor picks an image through a fake picker, shows it and stores it with the card; a capture shows it, another one shows it in a session.

## File mapping

- `lib/application/cards/` — card service, editor draft, providers.
- `lib/data/repositories/card_repository.dart` — storage of the cards, their progression and their queue position.
- `lib/domain/cards/bulk/` — parsing of bulk-add lines and the order of a batch.
- `lib/domain/scheduling/step_target.dart` — where a card can be put by hand.
- `lib/features/cards/` — card editor, the "+" button that adds cards (`add_cards_button.dart`), group row and picker, card sheet, its panels, track of steps and step sheet, bulk add, card row of the lists and the text of where a card stands, card image and gallery picker.
- `lib/data/images/image_store.dart` — the folder of the card images.

## Technical details

A widget test reads no file outside `runAsync`: an `Image.file` built before its file is decoded never loads, and precaching it afterwards waits forever on the first, stuck load. The tests decode the file into the image cache first (`precacheImageFile`), then build the screen.

The text input dialog (group name) owns its controller in a widget state: disposed when the dialog returns, the controller would still be read by the field during the closing animation.
