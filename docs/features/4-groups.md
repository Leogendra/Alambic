# Feature 4 — Groups

Status: in progress (2026-11-24)

## Goal

Sort cards into flat [groups](../lexicon.md#group), find a card by search, see at a glance what is due in each group, distill a group, review it all, and set a group's name, preset, end of sequence, [typed answer](../lexicon.md#typed-answer) and [back option](../lexicon.md#back-option).

## Implementation overview

Every card is in a group: a group is created from the Groups tab, or on the fly from the card editor and the bulk add ([Feature 3](3-cards.md)).

### Groups tab

The tab shows a search field, then the groups in alphabetical order, one row each in a single panel. Each row gives the name and the number of cards, followed by "distillation" once the group's distillation is activated ("48 cards · distillation"), and a badge with the number of [due](../lexicon.md#due) cards when there are any. While its distillation is paused, the row is greyed and reads "Paused" instead ("64 cards · Paused"), with a pause icon when no card is due. "New", under the last group, creates a group after asking for its name; it gives way to the search results like the list.

As soon as some text is typed, the group list gives way to the cards whose front or back contains that text, case-insensitively, across all groups (at most 100 results).

### Group page

The page of a group is titled with its name; from top to bottom:

- the large "Distill" button while the group does not distill, with a line explaining it and a band of light gliding once across the button when the page opens (nothing when the system asks for no animation), then, once activated, the tracking of its distillation in its place ([Feature 8](8-distillation.md#screens));
- the "Enable the back" / "Disable the back" button, with a line saying how cards are asked;
- the cards, in three sections, each under a small title with its number of cards ("In progress · 4"), left out when empty. A small "Review all" button sits at the right of the first title, shown while the group has cards in progress or waiting; on the waiting title, it sits before "Reorder". Each card shows where it stands ([Feature 3](3-cards.md#where-a-card-stands)):
  - "In progress · N": the introduced cards that have a due date, in their sequence or in [remanence](../lexicon.md#remanence), soonest due first;
  - "Waiting · N": the [queue](../lexicon.md#queue), in its order, which the user can change ([Reordering the queue](#reordering-the-queue)). The cards do not say "waiting", their section does; while the group distills, the head of the queue, the next card the distillation introduces, reads "next", in grey;
  - "Learned · N": the [acquired](../lexicon.md#acquired) cards, folded by default; touching its title unfolds or folds it.

The "+" button opens the two floating buttons of the app, "Add a card" and "Add several cards", both starting in the group ([Feature 0](0-foundation.md#implementation-overview)). The toolbar opens the group settings.

The page opened at the end of the onboarding, on the sample group ([Feature 10](10-onboarding.md#sample-group)), points out "Distill" with a line above it: "Its cards are waiting. Distill the group to receive them."

### Reordering the queue

The order of the "Waiting" section is the order in which the distillation introduces the cards ([Feature 8](8-distillation.md#queue)), and the user changes it in two ways:

- a long press on a waiting card lifts it, and dragging it drops it at another place; the page scrolls when the card nears its top or bottom edge. A plain touch still opens the card sheet, and a swipe still scrolls;
- "Reorder", a round button with the icon of two arrows at the right of the "Waiting · N" title, shown from two waiting cards, opens the reordering mode. The rows become compact, the front alone, each with two buttons, "To the head" and "To the end", off where the card already is, and a handle that drags the card at once. A touch on a row opens nothing. The title then offers "Shuffle the queue", which draws a new order at random after a confirmation, and "Done", which leaves the mode; "Review all" is not shown there, and nor is the "+" button, which would cover the last rows.

Each move is written at once; the list shows the new order before the database confirms it, and the "next" mark follows the new head. The card sheet moves a single card to the head or the end too ([Feature 3](3-cards.md#card-sheet)).

### Review all

"Review all" opens a session on every card of the group, introduced or not. The cards due today come first, oldest due date first, and count normally; then the other introduced cards, soonest due first; then the pending cards in queue order. These last two kinds are [bonus reviews](../lexicon.md#bonus-review): their step and due date do not move, and a pending card stays pending. [Acquired](../lexicon.md#acquired) cards are left out.

The session is also a pre-test of the [queue](../lexicon.md#queue): a pending card answered "Again" goes to the head of the queue, and will be the next card the distillation introduces; "Correct" leaves it in place. Each missed card goes to the very top in turn, so the last one missed comes out first, ahead of the other missed ones and of the rest of the queue, unchanged. The move is made at each answer: leaving the session halfway keeps the cards already raised. The history records these answers as bonus reviews, without the move. "Review the missed cards now", at the end of the session, raises nothing.

### Back option

With the back enabled, each display of a card of the group (session, notification, typed answer) asks its front or its back, one chance in two, drawn again at every display. The progression of the card is the same whichever face is asked. The option is a "Back" switch in the group settings.

### Hiding the backs

The group page has a "Hide the back" button, which becomes "Show the back" once pressed (`CardGroup.backHidden`, stored with the group). While the backs are hidden, the card lists of the group page show the front of each card alone. Nothing else changes: the card sheet, the search results, sessions and notifications still show the backs, the stored cards are untouched, and the [back option](#back-option) is independent.

### Sequence end and typed answer

A group carries two more options, set in its settings:

- After the last step: [remanence](../lexicon.md#remanence) (the default) at an interval of 3 months, 6 months (the default) or 1 year, or [acquired](../lexicon.md#acquired). They belong to the group rather than to the preset, so that two groups can share a rhythm and end it differently. Their effect on the cards, including switching from one to the other, is in [Feature 1](1-scheduling.md#after-the-last-step).
- The [typed answer](../lexicon.md#typed-answer), off by default: the cards of the group whose answer face has text are answered by typing it, in the notification ([Feature 7](7-notifications.md#typed-answer)) as in a session ([Feature 5](5-session.md#typed-answer)), with the same comparison.

### Group settings

A group's settings are, from top to bottom: its name; its preset, picked from the preset list; what comes after the last step; the typed answer and the back option, as two switches; its deletion. A group has no pause of its own: only its distillation is paused ([Feature 8](8-distillation.md#pause)). The group always follows a whole preset: the screen reminds the user to duplicate a preset to adjust it.

"After the last step" is a segmented control, "Remanence" / "Learned". With remanence, a second one picks its interval (3 months, 6 months, 1 year). A line under them says what the choice does: the interval the cards will actually come back at, which is the last step of the preset when it is longer than the one chosen, or that an acquired card never comes back. Every change is saved at once, and switching applies at once to the cards past their last step ([Feature 1](1-scheduling.md#after-the-last-step)).

Deleting a group asks for confirmation, announcing how many cards go with it, then deletes the group with its cards, their history and its distillation.

### Counts and sections

The due count of the tab is computed by `GroupOverview` from all cards, the preset catalog and the current moment; it also marks the groups that have a distillation. The current moment is republished every minute (`currentMomentProvider`), so a card planned for 12:00 joins the count on time without any data change.

The sections of a group page are split by `GroupSections` from the cards of the group; the waiting one takes the queue order of the distillation (`DistillationQueue.inOrder`), so the page and the distillation cannot disagree on which card is next.

## Acceptance criteria

- [x] The tab lists the groups, one row each, with number of cards, "distillation" when it is activated, and number of due cards; no preset.
- [x] Search finds cards by their front or back, case-insensitively.
- [x] A group page shows its cards in three sections with their counts, "In progress", "Waiting" and "Learned", each card with where it stands; its header recalls neither the number of cards nor the preset.
- [x] "In progress" is sorted soonest due first; "Waiting" follows the queue, and, while the group distills, its head reads "next"; no waiting card reads "waiting".
- [x] The learned section is folded by default; an empty section is absent.
- [x] A long press on a waiting card drags it to another place in the queue, written at once; a touch still opens the card sheet, and "next" follows the new head.
- [x] "Reorder" turns the waiting rows compact, with a handle and "To the head" and "To the end", each off where the card already is, and takes the "+" button away; "Shuffle the queue" draws a new order once confirmed; "Done" leaves the mode. A queue of one card offers no "Reorder".
- [x] On the waiting title, "Review all" and "Reorder" sit side by side without overlapping, down to a small phone.
- [x] A group that does not distill shows a large "Distill" button; once activated, its tracking replaces it. A band of light glides once across the button on arrival.
- [x] "Review all" asks the due cards first, then the other introduced cards, then the pending ones, all but the due ones as bonus reviews, and leaves acquired cards out.
- [x] In "Review all", a pending card answered "Again" goes to the head of the queue at once, the last one missed first.
- [x] The back option is switched from the group settings.
- [x] "Hide the back" on a group page hides the back line of every card of its lists, and "Show the back" brings it back; the card sheet, the search and the sessions are unchanged.
- [x] A group is created, renamed, changes preset; a new group follows the global preset of the moment.
- [x] Deleting a group deletes its cards and their history.
- [x] A group whose distillation is paused is shown as such in the tab.
- [x] A new group comes back in remanence every 6 months after the last step, without typed answer.
- [x] The group settings set the end of sequence and the typed answer.

## Test strategy

- The split into sections is tested as pure logic: the order of each section, cards in remanence, the head of the queue as next card.
- Counts are tested on an in-memory database filled through the services, at chosen moments: before and after the [daily slot](../lexicon.md#daily-slot).
- The order of "Review all" is tested as pure logic (due, introduced, pending, acquired), then on the group page, down to the session it opens.
- Raising a missed pending card is tested on an in-memory database with the queue as the distillation reads it: one card, several, a correct answer, a forced bonus, a card added afterwards, the next introduction; and through a session left after one answer.
- The group service is tested for creation, renaming, refusal of an empty name, the back option, the hiding of the backs, the end of sequence (the cards past their last step, switched in both directions) and deletion with its cards.
- The tab (list with a distilled group, with a paused distillation, and search), the group page and its settings are covered by screen tests with a capture on a sample data set, with a fixed clock; the group page (all three sections) and its settings in light and dark theme. The section titles and the "next" mark are checked on the page, and the acquired section is unfolded and folded again by touch. The queue is driven by touch, read back from the database each time: a long press dragged to the head, the head and end buttons of the reordering mode (captured in light and dark theme), a shuffle cancelled then confirmed with a seeded random generator, the "next" mark after each move, and the place of the title buttons on a group without card in progress. The settings screen is driven to change the remanence interval, the typed answer and the end of sequence, read back from the database.

## File mapping

- `lib/application/groups/` — group service, counts (`GroupOverview`), sections of a group page (`GroupSections`) and providers.
- `lib/application/reviews/whole_group_review.dart` — the order of "Review all".
- `lib/application/time/minute_ticker.dart` — current moment republished every minute.
- `lib/data/repositories/group_repository.dart` — group storage.
- `lib/features/groups/` — tab, group page, back button and group settings.
- `lib/features/groups/queue_section.dart` — the reorderable "Waiting" section and its reordering mode.
- `lib/features/cards/card_list_tile.dart` — card row shared by the group page and the search; its texts come from `card_status_formatter.dart`.

## Technical details

Search relies on SQLite `LIKE`, case-insensitive for ASCII letters only: "é" does not find "É".

The group page is a single `CustomScrollView`: the waiting section is a `SliverReorderableList` inside it, so a dragged card scrolls the whole page. A list nested in a non-scrolling `ListView` would not scroll at all while dragging. Until the database answers, the section keeps the order of the last move by card id, and drops it as soon as the order it receives changes.

Cards due at the same moment keep their creation order in "Review all": Dart's sort is not stable, so the order breaks ties on the card id.
