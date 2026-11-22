# Feature 4 — Groups

Status: in progress (2026-11-20)

## Goal

Sort cards into flat [groups](../lexicon.md#group), find a card by search, see at a glance what is due in each group, distill a group, review it all, and set a group's name, preset, end of sequence, [typed answer](../lexicon.md#typed-answer) and [back option](../lexicon.md#back-option).

## Implementation overview

Every card is in a group: a group is created from the Groups tab, or on the fly from the card editor and the bulk add ([Feature 3](3-cards.md)).

### Groups tab

The tab shows a search field, then the groups in alphabetical order, one row each in a single panel. Each row gives the name and the number of cards, followed by "distillation" once the group's distillation is activated ("48 cards · distillation"), and a badge with the number of [due](../lexicon.md#due) cards when there are any. While its distillation is paused, the row is greyed and reads "Paused" instead ("64 cards · Paused"), with a pause icon when no card is due. "New" creates a group after asking for its name.

As soon as some text is typed, the group list gives way to the cards whose front or back contains that text, case-insensitively, across all groups (at most 100 results).

### Group page

The page of a group is titled with its name; from top to bottom:

- the large "Distill" button while the group does not distill, with a line explaining it, then, once activated, the tracking of its distillation in its place ([Feature 8](8-distillation.md#screens));
- the "Enable the back" / "Disable the back" button, with a line saying how cards are asked;
- the cards, under a "Cards" title with a small "Review all" button at its right, shown while the group has cards in progress or waiting. They come in three sections, each under a small title with its number of cards ("In progress · 4"), left out when empty. Each card shows where it stands ([Feature 3](3-cards.md#where-a-card-stands)):
  - "In progress · N": the introduced cards that have a due date, in their sequence or in [remanence](../lexicon.md#remanence), soonest due first; the suspended ones stay there, marked "suspended", at the end;
  - "Waiting · N": the [queue](../lexicon.md#queue), in its order, suspended cards in their place. The first card that is not suspended, the next one the distillation introduces, reads "next" in accent instead of "waiting";
  - "Learned · N": the [acquired](../lexicon.md#acquired) cards, folded by default; touching its title unfolds or folds it.

The "+" button creates a card directly in the group, and the toolbar opens the bulk add and the group settings.

The page opened at the end of the onboarding, on the sample group ([Feature 10](10-onboarding.md#sample-group)), points out "Distill" with a line above it: "Its cards are waiting. Distill the group to receive them."

### Review all

"Review all" opens a session on every card of the group, introduced or not. The cards due today come first, oldest due date first, and count normally; then the other introduced cards, soonest due first; then the pending cards in queue order. These last two kinds are [bonus reviews](../lexicon.md#bonus-review): their step and due date do not move, and a pending card stays pending. Suspended and [acquired](../lexicon.md#acquired) cards are left out.

The session is also a pre-test of the [queue](../lexicon.md#queue): a pending card answered "Again" goes to the head of the queue, and will be the next card the distillation introduces; "Correct" leaves it in place. Each missed card goes to the very top in turn, so the last one missed comes out first, ahead of the other missed ones and of the rest of the queue, unchanged. The move is made at each answer: leaving the session halfway keeps the cards already raised. The history records these answers as bonus reviews, without the move. "Review the missed cards now", at the end of the session, raises nothing.

### Back option

With the back enabled, each display of a card of the group (session, notification, typed answer) asks its front or its back, one chance in two, drawn again at every display. The progression of the card is the same whichever face is asked. The option is a button on the group page and a "Back" switch in the group settings.

### Sequence end and typed answer

A group carries two more options, set in its settings:

- After the last step: [remanence](../lexicon.md#remanence) (the default) at an interval of 3 months, 6 months (the default) or 1 year, or [acquired](../lexicon.md#acquired). They belong to the group rather than to the preset, so that two groups can share a rhythm and end it differently. Their effect on the cards, including switching from one to the other, is in [Feature 1](1-scheduling.md#after-the-last-step).
- The [typed answer](../lexicon.md#typed-answer), off by default: the cards of the group whose answer face has text are answered by typing it, in the notification ([Feature 7](7-notifications.md#typed-answer)) as in a session ([Feature 5](5-session.md#typed-answer)), with the same comparison.

### Group settings

A group's settings are, from top to bottom: its name; its preset, picked from the preset list or inherited from the global preset; what comes after the last step; the typed answer and the back option, as two switches; its deletion. A group has no pause of its own: only its distillation is paused ([Feature 8](8-distillation.md#pause)). The group always follows a whole preset: the screen reminds the user to duplicate a preset to adjust it.

"After the last step" is a segmented control, "Remanence" / "Learned". With remanence, a second one picks its interval (3 months, 6 months, 1 year). A line under them says what the choice does: the interval the cards will actually come back at, which is the last step of the preset when it is longer than the one chosen, or that an acquired card never comes back. Every change is saved at once, and switching applies at once to the cards past their last step ([Feature 1](1-scheduling.md#after-the-last-step)).

Deleting a group asks for confirmation, announcing how many cards go with it, then deletes the group with its cards, their history and its distillation.

### Counts and sections

The due count of the tab is computed by `GroupOverview` from all cards, the preset catalog and the current moment; it also marks the groups that have a distillation. The current moment is republished every minute (`currentMomentProvider`), so a card planned for 12:00 joins the count on time without any data change.

The sections of a group page are split by `GroupSections` from the cards of the group; the waiting one takes the queue order of the distillation (`DistillationQueue.inOrder`), so the page and the distillation cannot disagree on which card is next.

## Acceptance criteria

- [x] The tab lists the groups, one row each, with number of cards, "distillation" when it is activated, and number of due cards; no preset.
- [x] Search finds cards by their front or back, case-insensitively.
- [x] A group page shows its cards under "Cards", with "Review all" beside it, in three sections with their counts, "In progress", "Waiting" and "Learned", each card with where it stands; its header recalls neither the number of cards nor the preset.
- [x] "In progress" is sorted soonest due first, suspended cards last; "Waiting" follows the queue, and its first card that is not suspended reads "next".
- [x] The learned section is folded by default; an empty section is absent.
- [x] A group that does not distill shows a large "Distill" button; once activated, its tracking replaces it.
- [x] "Review all" asks the due cards first, then the other introduced cards, then the pending ones, all but the due ones as bonus reviews, and leaves suspended and acquired cards out.
- [x] In "Review all", a pending card answered "Again" goes to the head of the queue at once, the last one missed first.
- [x] The back option is switched from the group page or its settings.
- [x] A group is created, renamed, changes preset or inherits the global preset.
- [x] Deleting a group deletes its cards and their history.
- [x] A suspended card does not count as due.
- [x] A group whose distillation is paused is shown as such in the tab.
- [x] A new group comes back in remanence every 6 months after the last step, without typed answer.
- [x] The group settings set the end of sequence and the typed answer.

## Test strategy

- The split into sections is tested as pure logic: the order of each section, cards in remanence and suspended cards, the next card behind a suspended head.
- Counts are tested on an in-memory database filled through the services, at chosen moments: before and after the [daily slot](../lexicon.md#daily-slot), with a suspended card.
- The order of "Review all" is tested as pure logic (due, introduced, pending, suspended, acquired), then on the group page, down to the session it opens.
- Raising a missed pending card is tested on an in-memory database with the queue as the distillation reads it: one card, several, a correct answer, a forced bonus, a card added afterwards, the next introduction; and through a session left after one answer.
- The group service is tested for creation, renaming, refusal of an empty name, the back option, the end of sequence (the cards past their last step, switched in both directions) and deletion with its cards.
- The tab (list with a distilled group, with a paused distillation, and search), the group page and its settings are covered by screen tests with a capture on a sample data set, with a fixed clock; the group page (all three sections, a suspended card in progress and at the head of the queue) and its settings in light and dark theme. The section titles and the "next" mark are checked on the page, and the acquired section is unfolded and folded again by touch. The settings screen is driven to change the remanence interval, the typed answer and the end of sequence, read back from the database.

## File mapping

- `lib/application/groups/` — group service, counts (`GroupOverview`), sections of a group page (`GroupSections`) and providers.
- `lib/application/reviews/whole_group_review.dart` — the order of "Review all".
- `lib/application/time/minute_ticker.dart` — current moment republished every minute.
- `lib/data/repositories/group_repository.dart` — group storage.
- `lib/features/groups/` — tab, group page, back button and group settings.
- `lib/features/cards/card_list_tile.dart` — card row shared by the group page and the search; its texts come from `card_status_formatter.dart`.

## Technical details

Search relies on SQLite `LIKE`, case-insensitive for ASCII letters only: "é" does not find "É".

Cards due at the same moment keep their creation order in "Review all": Dart's sort is not stable, so the order breaks ties on the card id.
