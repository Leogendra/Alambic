# Feature 5 — In-app review session

Status: in progress (2026-11-16)

## Goal

Review [due](../lexicon.md#due) cards in the app, one by one, with the same two answers as in the notifications, then review the missed cards again right away without distorting the schedule.

## Implementation overview

### Flow

A session starts from a list of cards. A group page starts it on the group's due cards, sorted by [due date](../lexicon.md#due-date) (oldest first, "Review the N due"), or on all its cards ("Review all", [Feature 4](4-groups.md#review-all)); the card sheet starts it on a single card. Each card's [asked side](../lexicon.md#asked-side) is drawn when the session opens: the front, or one chance in two the back when its group has the [back option](../lexicon.md#back-option).

For each card, the screen shows the asked face (its image above its text, the image shrinking to leave room for the text), with the group and the preset on top, and the mention "back → front" when the back is asked. Tapping the card or "Show answer" reveals the other face, then the "Again" and "Correct" buttons. Under each button stands the effect of the answer: "tomorrow", "in 6 d", "at 15:17", "acquired", or "no effect" for a bonus review. A progress bar and a "3 / 12" counter follow the progress; the cross leaves the session, the answers already given staying recorded.

### Answer

Every answer goes through `ReviewService`, the same service as the notifications. It rereads the card from the database at answer time and decides:

- if the card is due, it computes the new due date ([Feature 1](1-scheduling.md)), stores it with the answer moment, writes the answer to the history and notifies the notification planning;
- otherwise, or if the session is a bonus session, it only writes a [bonus review](../lexicon.md#bonus-review) to the history, without touching the step or the due date.

Rereading the card at each answer keeps the session right if the same card was reviewed meanwhile from a notification: the session answer then becomes a bonus.

The preview shown under the buttons is computed by the same service, with the same rules, without writing anything.

### End of session

The end screen gives the number of cards, the duration, and the number of correct and Again answers. If cards were missed, "Review the N missed now" opens a bonus session on them, their asked side drawn again: their answers are written to the history but their due dates do not move. "Back to home" closes the session.

## Acceptance criteria

- [x] The answer appears only after a tap on the card or on "Show answer".
- [x] Each button announces when the card will come back if chosen.
- [x] Answering a due card reschedules it and writes the answer to the history.
- [x] Answering a card that is not due is a bonus review: history only.
- [x] The end screen counts the answers and offers to review the missed cards as a bonus review.
- [x] A group page starts a session on its due cards, or on all its cards with "Review all".
- [x] With the back option, each card of the session asks its front or its back, drawn at the opening.

## Test strategy

- The answer service is tested on an in-memory database with a fixed clock: answer on a due card, on a card due later in the day, on a card already reviewed (bonus), forced bonus, and agreement between the preview and the recorded answer.
- Session tracking (order, counts, missed) is tested as pure logic; the draw of the asked side per group is tested with a fixed random generator.
- The full flow is tested on screen: reveal, answer, end screen, bonus session of the missed cards, then the history read from the database. The front, the back and the end screen are also golden tests, the front and the back in light and dark theme.

## File mapping

- `lib/application/reviews/` — answer service, preview, due queue, the items of a session with their drawn side, and session tracking.
- `lib/data/repositories/review_repository.dart` — answer history.
- `lib/features/session/` — session screen, card, answer buttons, end screen and launcher.

## Technical details

The due queue (`dueItemsProvider`) is computed from all cards and the current moment republished every minute. The session receives a copy of it when it opens and keeps it: a card that becomes due during the session does not join it.

A bonus review does not update the card's last review date. That date drives the "due" rule; changing it would make a card due today disappear after a mere bonus review.
