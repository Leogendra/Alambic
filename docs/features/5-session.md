# Feature 5 — In-app review session

Status: in progress (2026-11-20)

## Goal

Review [due](../lexicon.md#due) cards in the app, one by one, with the same two answers as in the notifications, then review the missed cards again right away without distorting the schedule.

## Implementation overview

### Flow

A session starts from a list of cards. A group page starts it on all its cards ("Review all", [Feature 4](4-groups.md#review-all)); the card sheet starts it on a single card; a touched notification starts it on its card or the due cards of its group, then every due card ([Feature 7](7-notifications.md#touching-a-notification)), the touched card asking the face of its notification. Each card's [asked side](../lexicon.md#asked-side) is drawn when the session opens: the front, or one chance in two the back when its group has the [back option](../lexicon.md#back-option).

For each card, the screen shows a card in two halves of fixed height, split by a line shown from the question on. The top half holds a context line (the group and the preset, the mention "back → front" when the back is asked) and the asked face, its image above its text, the image shrinking to leave room for the text. The bottom half is empty until the reveal, then shows the other face. The top half does not change at the reveal: same position, same text size, same colour.

The text of a face is 28 at most, a single word included, so that a word does not fill the card; a text longer than 60 characters is 22. It runs 400 wide at most, centered, so that its lines stay readable on a wide screen. The system text size applies on top of these sizes, 1.5 times at most since they are already large; without an image, a text that still does not fit its half shrinks to fit it. The labels of the answer buttons shrink the same way to the height of the buttons.

The one announced way to reveal is the "Show answer" button at the bottom of the screen; tapping the card reveals too, without anything saying so. The button sits in a zone of fixed height where "Again" / "Correct" replace it, so the card does not move. Under each answer button stands the effect of the answer: "tomorrow", "in 6 d", "at 15:17" or "acquired"; a bonus review shows the labels alone. A progress bar and a "3 / 12" counter follow the progress; the cross leaves the session, the answers already given staying recorded.

### Reveal

The reveal takes 250 ms, eased out: the answer fades in while rising by 12 px, and "Show answer" cross-fades into the two answer buttons. A light haptic tap goes with it. When the system asks for reduced motion, the answer shows at once. Moving to the next card plays nothing backwards: the new card shows unrevealed.

### Answer

Every answer goes through `ReviewService`, the same service as the notifications. It rereads the card from the database at answer time and decides:

- if the card is due, it computes the new due date ([Feature 1](1-scheduling.md)), stores it with the answer moment, writes the answer to the history and notifies the notification planning;
- otherwise, or if the session is a bonus session, it only writes a [bonus review](../lexicon.md#bonus-review) to the history, without touching the step or the due date.

Rereading the card at each answer keeps the session right if the same card was reviewed meanwhile from a notification: the session answer then becomes a bonus.

The preview shown under the buttons is computed by the same service, with the same rules, without writing anything.

### Typed answer

In a group with the [typed answer](../lexicon.md#typed-answer) option, a card whose answer face has text is answered by typing it. A field ("Your answer") takes the place of "Show answer", with a send button and a "Reveal" link beside it; it takes the focus, so the keyboard opens on each card. A blank answer is not submitted.

Once submitted, the answer is compared and recorded at once, Correct when accepted and Again when refused, with the rules of the notifications ([Feature 7](7-notifications.md#typed-answer)). The keyboard closes, the answer shows with the usual reveal, and under it the verdict, in blue when accepted and in orange when refused (`"ulanbaatar" accepted, 1 typo`), then what the answer did, accepted or not ("Next tomorrow"). "Next" takes the place of the field and moves to the next card.

"Reveal", or a tap on the card, reveals the answer as for any card, with "Again" and "Correct": nothing is typed nor recorded until one of them is pressed.

### End of session

The end screen gives the number of cards, the duration, and the number of correct and Again answers. If cards were missed, "Review the N missed now" opens a bonus session on them, their asked side drawn again: their answers are written to the history but their due dates do not move. "Back to home" closes the session.

## Acceptance criteria

- [x] The answer appears only after a tap on the card or on "Show answer", the only button before the reveal.
- [x] The top half of the card keeps its position, text size and colour at the reveal; the answer buttons take the place of "Show answer" without moving the card.
- [x] The line between the halves shows before the reveal.
- [x] The text of a face never exceeds its maximum size nor its maximum width, a single word included; a long text is smaller.
- [x] The reveal is animated in 250 ms with a light haptic tap, at once under reduced motion, and the next card shows unrevealed.
- [x] Each button announces when the card will come back if chosen; a bonus review shows no effect under the buttons.
- [x] Answering a due card reschedules it and writes the answer to the history.
- [x] Answering a card that is not due is a bonus review: history only.
- [x] The end screen counts the answers and offers to review the missed cards as a bonus review.
- [x] A group page starts a session on all its cards with "Review all".
- [x] Touching a notification starts a session on its card or group, then every due card.
- [x] With the back option, each card of the session asks its front or its back, drawn at the opening.
- [x] With the typed answer option, a field replaces "Show answer", with "Reveal"; the typed answer is compared like in the notifications, recorded at once, shown with its verdict and the answer, then "Next" moves on.

## Test strategy

- The answer service is tested on an in-memory database with a fixed clock: answer on a due card, on a card due later in the day, on a card already reviewed (bonus), forced bonus, and agreement between the preview and the recorded answer.
- Session tracking (order, counts, missed) is tested as pure logic; the draw of the asked side per group is tested with a fixed random generator.
- The full flow is tested on screen: reveal, answer, end screen, bonus session of the missed cards, then the history read from the database. The front, the back and the end screen are also golden tests, the front and the back in light and dark theme; between the two, the asked face is checked at the same place with the same style.
- The size of a face text is a golden test for a single word, a sentence and a long text, each checked against the maximum size; the maximum width is checked on a wide screen, where the uncapped text would run wider.
- The typed answer is tested on screen: an accepted answer with one typo and a refused one, their verdict and the answer recorded in the database, "Next", "Reveal" recording nothing, a blank answer not submitted; the field and the verdict are golden tests.
- The reveal is tested on screen frame by frame: the answer half-faded midway, "Show answer" gone and the card unmoved at the end, the haptic call read on the platform channel; under reduced motion (a test accessibility setting), the answer is fully shown on the first frame; the next card starts unrevealed.

## File mapping

- `lib/application/reviews/` — answer service, preview, due queue, the items of a session with their drawn side, and session tracking.
- `lib/data/repositories/review_repository.dart` — answer history.
- `lib/features/session/` — session screen, card, answer buttons, typed answer field, end screen and launcher.
- `lib/app/formatting/typed_answer_labels.dart` — the verdict of a typed answer and what it did, shared with the notifications.

## Technical details

The session receives its list of cards when it opens and keeps it: a card that becomes due during the session does not join it.

The reveal is one `AnimationController` of the session screen, eased once and handed to the card and to the button zone. Going to the next card sets it back to 0 instead of reversing it.

A typed answer goes through `ReviewService.answerTyped`, which compares it with `TypedAnswerMatch` and records it like any answer: the notifications use the same method, so the two cannot drift apart. `CardGroup.asksTypedAnswer` decides, for both, which card is answered by typing.

A bonus review does not update the card's last review date. That date drives the "due" rule; changing it would make a card due today disappear after a mere bonus review.
