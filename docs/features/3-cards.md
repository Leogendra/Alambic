# Feature 3 — Cards

Status: in progress (2026-11-20)

## Goal

Create and edit front / back [cards](../lexicon.md#card), put them in a group, then follow and manage each card from its sheet. A face holds a text, an image, or both.

## Implementation overview

The "+" button of the navigation opens an empty card editor. The same screen edits an existing card. It shows the front, the back and the group (the group the user came from, or none chosen yet). It offers no preset: a card follows the preset of its group ([Feature 2](2-presets.md#cascading-resolution)).

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

The page of a group opens the bulk add: the user pastes one card per line, front and back split by a separator. The separator is a free field pre-filled with `;`, and may be several characters long. The group row, with the same "+" button as the editor, starts on the group the user came from.

Reading the lines is a domain rule (`BulkCardParser`), rerun at each keystroke:

- an empty line is skipped without error;
- the front stops at the first separator, so the back may itself contain the separator;
- a line without a separator, or whose front or back is empty, is reported by its number and skipped.

The screen announces the number of ready cards and lists the skipped lines before adding.

Under them, the order of the batch: "In order" (by default), the top line first, or "Shuffle". Shuffling draws an order when it is chosen, and choosing it again draws a new one; it only mixes the batch, never the cards already waiting. The draw mixes places in the batch, not texts: a line edited after the draw keeps its place and every other card keeps its own. A valid line added or removed, a line that becomes valid or invalid included, changes the size of the batch and mixes the whole batch again with the same draw, so the "First" box may change. A "First" box shows the card of the batch that will come out first ("Capital of Chile → Santiago"), with "after the 2 cards already waiting" when the queue of the group is not empty. It follows every keystroke, separator and order change, and is hidden while no line is valid.

Cards are created in a single transaction, in the order shown, at the end of the group's queue; they follow their group's preset.

### Where a card stands

No status and no step is shown. A list shows each card's front, its back below, and on the right where it stands:

- its next date, "in 3 d", or "Due" in the accent colour when it is due;
- "waiting", "suspended" or "learned" for a card without a next date.

### Card sheet

Touching a card in a list opens its sheet. It shows both faces, then:

- its progress: a bar of the preset sequence, without title, one segment per step with its interval below, then one more for the [remanence](../lexicon.md#remanence) when the group has one, with the remanence interval. The segments are filled up to where the card stands, and its interval is in bold. Then its next review ("Next review Fri 13 Nov, 12:00", or "Due now");
- or, when it is not scheduled, why: waiting in its group's queue, or learned;
- its upcoming "Review soon" reminders, each removable;
- its history, most recent first: date, answer, a "bonus" tag for a [bonus review](../lexicon.md#bonus-review), and the effect ("→ 1 mo", "back to 2 d", "→ 6 mo" for the [remanence](../lexicon.md#remanence), "acquired", "no effect"). The effect is read against the current preset and end of sequence of the group, so it may differ from what the user saw if they changed since.

Touching the faces opens a one-card session; when the card is not due, the answer is a bonus review. The edit button opens the card editor, and the menu deletes the card after confirmation.

### Card management

Three actions sit under the progress panel:

- "Review soon" adds an [extra reminder](../lexicon.md#extra-reminder) on a chosen day (tomorrow, the day after, the coming weekend, or any date) at a chosen time, the [daily slot](../lexicon.md#daily-slot) by default. A moment already past is refused. It is offered only for an introduced card.
- "Suspend" / "Resume": a suspended card is never due.
- "Reset", after confirmation: the card goes back to the end of its group's queue, history kept.

Every operation that touches due dates or reminders notifies the notification planning.

## Acceptance criteria

- [x] A card is created with a text front and back in a group; an empty face, or a missing group, is refused.
- [x] The "+" of the group row creates a group from its name and chooses it, in the editor and in the bulk add.
- [x] Each face takes an image from the gallery, alone or with a text; the image is copied into the app and leaves it with its card, its group, or when it is replaced or removed.
- [x] A new card is not due: it is pending at the end of its group's queue.
- [x] Editing a card changes its text, its group and its preset; a pending card moved to another group joins the end of its queue, an introduced one keeps its progression.
- [x] Bulk add creates one card per valid line and reports the skipped lines by number.
- [x] The batch joins the end of the queue in the order of the list, or in a shuffled order drawn when "Shuffle" is chosen and drawn again at each touch; a line edited after the draw keeps its place. The "First" box shows its first card and the cards already waiting.
- [x] The bulk-add separator is editable; changing it rereads every line.
- [x] Resetting sends the card back to the end of its group's queue, keeping the history.
- [x] Lists show the next date only, or "waiting", "suspended", "learned": no status and no step.
- [x] The card sheet shows the step bar without title, the remanence as its last segment, the next review or why there is none, the reminders and the history with each answer's effect.
- [x] "Review soon" adds a reminder at a chosen day and time; a past moment is refused; a reminder can be removed.
- [x] Touching the faces reviews the card, as a bonus review when it is not due.

## Test strategy

- The service is tested on an in-memory database with a fixed clock: state, queue position and due date after creation, group change, editing and reset, read back from the database.
- Each test also checks that the notification planning was notified, through a listener that counts calls.
- Parsing the pasted lines is tested as pure logic: spaces, empty lines, missing separator, empty face, multi-character separator.
- The order of a batch is tested as pure logic: listed, shuffled within the batch, the same draw giving the same order, an edited line keeping every place.
- The bulk-add screen is tested end to end on an in-memory database with a seeded random generator: report and "First" box before adding, separator change, cards created pending at the end of the queue of the group, in the order listed or drawn.
- The group row is tested on the editor: a card without group is refused, "+" creates a group and puts the card in it, and with no group the row asks for a name.
- The days offered by "Review soon" are tested as pure logic, Saturday and Sunday included; the reminder service is tested on an in-memory database (added, refused in the past, removed).
- The editor, the bulk add and the card sheet (with history, bonus reviews and a reminder) are covered by screen tests with a capture, the card sheet in light and dark theme.
- Images are tested on a store in a temporary folder with a PNG fixture (`test/support/fixtures/flag.png`): copied on creation, kept, replaced and removed on update, deleted with the card and the group. The editor picks an image through a fake picker, shows it and stores it with the card; a capture shows it, another one shows it in a session.

## File mapping

- `lib/application/cards/` — card service, editor draft, providers.
- `lib/application/reminders/` and `lib/data/repositories/reminder_repository.dart` — "Review soon" reminders.
- `lib/domain/reviews/review_soon_days.dart` — the days offered by "Review soon".
- `lib/data/repositories/card_repository.dart` — storage of the cards, their progression and their queue position.
- `lib/domain/cards/bulk/` — parsing of bulk-add lines and the order of a batch.
- `lib/features/cards/` — card editor, group row and picker, card sheet and its panels, "Review soon" sheet, bulk add, card row of the lists and the text of where a card stands, card image and gallery picker.
- `lib/data/images/image_store.dart` — the folder of the card images.

## Technical details

A widget test reads no file outside `runAsync`: an `Image.file` built before its file is decoded never loads, and precaching it afterwards waits forever on the first, stuck load. The tests decode the file into the image cache first (`precacheImageFile`), then build the screen.

The text input dialog (group name) owns its controller in a widget state: disposed when the dialog returns, the controller would still be read by the field during the closing animation.
