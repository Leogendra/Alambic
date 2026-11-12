# Feature 8 — Distillation

Status: in progress (2026-11-12)

## Goal

Introduce the cards of a subject a few at a time ("one piece of knowledge a day") instead of making them all due at once. A [distillation](../lexicon.md#distillation) takes the [directions](../lexicon.md#direction) never started and hands them to review at the rhythm "N cards every X days"; each card then follows its preset like any other.

Out of scope: the global notification cap, which comes with the notification safeguards.

## Implementation overview

### Launching

A group distillation covers one direction (front → back or back → front) of one group. Launching it puts in its queue every direction of that sense in the group that was never started: unstarted directions, directions left pending by a stopped distillation, and, for back → front, the reverse of one-way cards, which the distillation activates as it introduces them. Directions already in review go on normally.

The queue follows the group order (creation order) or a random order chosen at launch. A card created in the group, or moved into it, while the distillation exists joins the end of the queue; a card moved out of the group leaves it and waits to be started by hand.

A group has at most two distillations, one per direction, each with its own rhythm. "No group" cannot be distilled, and launching is refused when no direction waits.

### Global distillation

The global distillation covers every card, of every group and of "No group", in both directions: it takes every direction never started (the reverse of a one-way card stays inactive). Its order is always random. Launching it stops every other distillation, and their remaining directions join its queue; while it exists, running or paused, no group distillation can be launched. A card created anywhere joins it.

The reverse of a card only enters the queue once its front was introduced: until then it is held without a rank, and it gets the last rank at the end of the pass that introduced its front. It therefore always arrives after its front, and never the same day. A reverse whose front is already in review enters the queue directly.

### Rhythm

The first batch is introduced on the launch day. A batch of N cards is owed from its batch day on; the next batch comes X days after the day the previous one was completed. Introducing a direction makes it due today at its preset slot, exactly like starting it by hand: due right away when the slot has passed, and moved to the next day if the other direction of the card is due today. It arrives as a new card ("New card") and then follows its preset.

Each scheduling day is processed once per distillation, by the first pass that sees it: at app launch, or at any wake-up of the app. A running distillation plans a wake-up at the start of the next day it has to process (4am), so cards are introduced with the app closed. A missed day is not caught up: at most one batch is introduced per day. A suspended card keeps its place in the queue and is skipped.

### Avoiding collisions

With "Avoid collisions" (on by default), a distillation has a budget of N notifications a day, N being its cards per batch. When the day is processed, the reminders due today of the cards it introduced come first, the shortest interval first (a D+1 reminder before a D+2 one; a card introduced and not answered yet counts as the shortest). Those over the budget move to the next day at their preset slot, keeping their step: no penalty. New cards only get what is left of the budget; the part of the batch they cannot take waits for the next days.

With 3 cards a day on the Standard preset, every card answered correctly: day 1 brings three new cards, day 2 their three D+1 reminders and no new card, day 3 three new cards, day 4 the three D+1 reminders while the three D+2 reminders move to day 5.

The budget is spent once, when the day is processed; reminders that come later the same day (intervals shorter than a day) do not count. It only applies while the distillation runs: paused, stopped or finished, its cards follow their preset without it. Without the option, the N cards of a batch arrive whatever is due.

### Pause, stop and end

A paused distillation introduces nothing; resuming it processes the current day if it was not processed yet. Stopping a distillation deletes it: its remaining directions stay pending, outside any queue, and can be started by hand (card sheet, "Start all") or taken by a new distillation. A distillation whose queue is empty ends and is deleted the same way.

## Acceptance criteria

- [x] Launching a group distillation queues the never started directions of its sense, in group or random order, and introduces the first batch the same day.
- [x] Batches follow "N cards every X days", one batch at most per day, the day starting at 4am, with the app closed.
- [x] A card added to the group during the distillation joins the end of the queue; a card moved out of the group leaves it.
- [x] A back → front distillation activates the reverse of one-way cards.
- [x] At most one distillation per group and direction; launching with nothing to introduce is refused.
- [x] The global distillation stops the others and takes their queues, blocks group distillations while it exists, and introduces the reverse of a card after its front, never the same day.
- [x] Avoiding collisions: a daily budget of N notifications, reminders first and shortest intervals first, the rest moved to the next day without penalty, new cards in what is left.
- [x] Pause, resume and stop; the directions left by a stopped distillation can be started by hand.
- [x] A distillation ends when its queue is empty.

## Test strategy

- The rhythm (`DistillationRhythm`) and the budget (`CollisionBudget`) are tested as pure functions: batch owed, rest of a batch held back, next batch day, estimate of the last arrival; ranking of the reminders and room left for new cards.
- The launch rules and the global distillation are tested on an in-memory database: refusals, queues taken over, cards created meanwhile, and the reverse arriving after its front over ten simulated days with a seeded random order.
- The example of 3 cards a day on the Standard preset is replayed day by day on an in-memory database, answering every card when it comes.
- The service is tested on an in-memory database filled through the services, moving a fixed clock across days: first batch, next days, 4am boundary, missed days, additions, reverse, pause, stop, suspension, end.
- The wake-up at the start of the day is tested with the fake alarm scheduler: the planned moment, and the introduction done by the wake-up.

## File mapping

- `lib/domain/distillation/` — the distillation, its settings, the rhythm and the queue rules.
- `lib/application/distillation/` — `DistillationService` and its providers.
- `lib/data/repositories/distillation_repository.dart` — storage of the distillations; the queue itself is stored on the directions (`CardRepository`).

## Technical details

The queue is not a table: a direction belongs to the queue of a distillation when it is pending and points to it (`distillationId`), at its `queuePosition`. An introduced direction keeps pointing to its distillation while it runs, which is how the distillation finds its cards. Deleting a distillation sets these links to `null` (foreign key `ON DELETE SET NULL`).

The daily pass runs in a transaction and reads the distillation again inside it, because the app and a wake-up may run it at the same moment from two isolates; the day already processed (`lastAdvancedDay`) makes the second pass a no-op.
