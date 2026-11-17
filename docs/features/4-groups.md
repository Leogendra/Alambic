# Feature 4 — Groups

Status: in progress (2026-11-17)

## Goal

Sort cards into flat [groups](../lexicon.md#group), find a card by search, see at a glance what is due in each group, distill a group, review it all, and set a group's name, preset, end of sequence, [typed answer](../lexicon.md#typed-answer) and [back option](../lexicon.md#back-option).

## Implementation overview

Every card is in a group: a group is created from the Groups tab, or on the fly from the card editor and the bulk add ([Feature 3](3-cards.md)).

### Groups tab

The tab shows a search field, then the groups in alphabetical order. Each row gives the number of cards and the preset followed, and a badge with the number of [due](../lexicon.md#due) cards when there are any. "New" creates a group after asking for its name.

As soon as some text is typed, the group list gives way to the cards whose front or back contains that text, case-insensitively, across all groups (at most 100 results).

### Group page

The page of a group recalls the number of cards and the preset. Three counters follow: due cards, active cards (introduced) and waiting cards ([pending](../lexicon.md#pending) in the queue). Then, from top to bottom:

- "Review the N due" when cards are due, which opens a session on them;
- the large "Distill" button while the group does not distill, with a line explaining it, then, once activated, the tracking of its distillation in its place ([Feature 8](8-distillation.md#screens));
- the "Enable the back" / "Disable the back" button, with a line saying how cards are asked;
- the card list, in creation order, under a "Cards" title that carries a small "Review all" button. Each card shows where it stands ([Feature 3](3-cards.md#where-a-card-stands));
- the [acquired](../lexicon.md#acquired) cards, out of that list, in an "Acquired · N" section (*Acquises*) folded by default: touching its title unfolds or folds it. It is absent when the group has no acquired card.

The "+" button creates a card directly in the group, and the toolbar opens the bulk add and the group settings.

The page opened at the end of the onboarding points out "Distill" with a line above it: "Your first card is waiting. Distill the group to receive it."

### Review all

"Review all" opens a session on every card of the group, introduced or not. The cards due today come first, oldest due date first, and count normally; then the other introduced cards, soonest due first; then the pending cards in queue order. These last two kinds are [bonus reviews](../lexicon.md#bonus-review): their step and due date do not move, and a pending card stays pending. Suspended and [acquired](../lexicon.md#acquired) cards are left out.

The session is also a pre-test of the [queue](../lexicon.md#queue): a pending card answered "Again" goes to the head of the queue, and will be the next card the distillation introduces; "Correct" leaves it in place. Each missed card goes to the very top in turn, so the last one missed comes out first, ahead of the other missed ones and of the rest of the queue, unchanged. The move is made at each answer: leaving the session halfway keeps the cards already raised. The history records these answers as bonus reviews, without the move. "Review the missed cards now", at the end of the session, raises nothing.

### Back option

With the back enabled, each display of a card of the group (session, notification, typed answer) asks its front or its back, one chance in two, drawn again at every display. The progression of the card is the same whichever face is asked. The option is a button on the group page and a "Back" switch in the group settings.

### Sequence end and typed answer

A group carries two more options, set in its settings:

- After the last step: [remanence](../lexicon.md#remanence) (the default) at an interval of 3 months, 6 months (the default) or 1 year, or [acquired](../lexicon.md#acquired). They belong to the group rather than to the preset, so that two groups can share a rhythm and end it differently. Their effect on the cards, including switching from one to the other, is in [Feature 1](1-scheduling.md#after-the-last-step).
- The [typed answer](../lexicon.md#typed-answer), off by default: the cards of the group whose answer face has text are answered by typing it in the notification ([Feature 7](7-notifications.md#typed-answer)).

### Group settings

A group's settings are, from top to bottom: its name; its preset, picked from the preset list or inherited from the global preset; what comes after the last step; the typed answer and the back option, as two switches; its pause and its deletion. The group always follows a whole preset: the screen reminds the user to duplicate a preset to adjust it.

"After the last step" is a segmented control, "Remanence" / "Learned" (*Rémanence* / *Acquise*). With remanence, a second one picks its interval (3 months, 6 months, 1 year). A line under them says what the choice does: the interval the cards will actually come back at, which is the last step of the preset when it is longer than the one chosen, or that an acquired card never comes back. Every change is saved at once; switching to remanence sends the acquired cards of the group back into it.

The pause silences the group: none of its cards is notified and its distillation introduces nothing, until it is resumed; its due dates then move by the length of the pause ([Feature 7](7-notifications.md#pauses)). A paused group is greyed in the tab, with "En pause" and a pause icon instead of its due count, and its page starts with "En pause depuis le …" and a "Reprendre" button.

Deleting a group asks for confirmation, announcing how many cards go with it, then deletes the group with its cards, their history and its distillation.

### Counts

Counters are computed by `GroupOverview` from all cards, the preset catalog and the current moment. The current moment is republished every minute (`currentMomentProvider`), so a card planned for 12:00 joins the counters on time without any data change.

## Acceptance criteria

- [x] The tab lists the groups, with number of cards, preset and number of due cards.
- [x] Search finds cards by their front or back, case-insensitively.
- [x] A group page shows the due / active / waiting counters and the card list with where each card stands.
- [x] The acquired cards are in their own section, folded by default and absent when there are none.
- [x] A group that does not distill shows a large "Distill" button; once activated, its tracking replaces it.
- [x] "Review all" asks the due cards first, then the other introduced cards, then the pending ones, all but the due ones as bonus reviews, and leaves suspended and acquired cards out.
- [x] In "Review all", a pending card answered "Again" goes to the head of the queue at once, the last one missed first.
- [x] The back option is switched from the group page or its settings.
- [x] A group is created, renamed, changes preset or inherits the global preset.
- [x] Deleting a group deletes its cards and their history.
- [x] A suspended card does not count as due.
- [x] A group is paused and resumed from its settings or its page; a paused group is shown as such in the tab.
- [x] A new group comes back in remanence every 6 months after the last step, without typed answer.
- [x] The group settings set the end of sequence and the typed answer.

## Test strategy

- Counts are tested on an in-memory database filled through the services, at chosen moments: before and after the [daily slot](../lexicon.md#daily-slot), with a suspended card.
- The order of "Review all" is tested as pure logic (due, introduced, pending, suspended, acquired), then on the group page, down to the session it opens.
- Raising a missed pending card is tested on an in-memory database with the queue as the distillation reads it: one card, several, a correct answer, a forced bonus, a card added afterwards, the next introduction; and through a session left after one answer.
- The group service is tested for creation, renaming, refusal of an empty name, the back option, the end of sequence (the acquired cards sent back into remanence) and deletion with its cards.
- The tab (list and search), the group page and its settings are covered by golden tests on a sample data set, with a fixed clock; the group page (with a folded acquired section) and its settings in light and dark theme. The acquired section is unfolded and folded again by touch. The settings screen is driven to change the remanence interval, the typed answer and the end of sequence, read back from the database.

## File mapping

- `lib/application/groups/` — group service, counts (`GroupOverview`) and providers.
- `lib/application/reviews/whole_group_review.dart` — the order of "Review all".
- `lib/application/time/minute_ticker.dart` — current moment republished every minute.
- `lib/data/repositories/group_repository.dart` — group storage.
- `lib/features/groups/` — tab, group page, back button and group settings.
- `lib/features/cards/card_list_tile.dart` — card row shared by the group page and the search; its texts come from `card_status_formatter.dart`.

## Technical details

Search relies on SQLite `LIKE`, case-insensitive for ASCII letters only: "é" does not find "É".

Cards due at the same moment keep their creation order in "Review all": Dart's sort is not stable, so the order breaks ties on the card id.
