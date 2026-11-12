# Feature 8 — Distillation

Status: implemented (2026-11-12)

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

### Screens

On a group page, the "Distillation" section lists the distillations of the group: direction, "In progress" or "Paused", rhythm and order ("1 card per day · group order"), a progress bar ("22 of 35 introduced") and the estimated day of the last arrival. Each one has a pause / resume button and a stop button, which asks for confirmation and says what becomes of the remaining cards. Its "Distill" button opens the launch screen.

The launch screen ("Distill") shows the preset slot and the preset the cards will follow, then the settings: direction (one already distilled is greyed out, "already in progress"; the other shows how many cards it would take), "N cards every X days" (1 / 1 by default), order (group order by default) and "Avoid collisions" (on, explaining the daily budget). An estimate follows ("44 cards · last arrival on 23 December"), computed as if every batch went through, then "Launch the distillation", disabled when nothing waits.

On Home, the new cards of a distillation have their own line in the timeline ([Feature 6](6-home.md)).

Settings has a "Global distillation" row, which says whether it is in progress and how far ("In progress · 23 of 212 introduced"). Its screen recalls what the global distillation covers, warns that launching it stops the distillations in progress (named) and blocks group distillations, then offers the rhythm and "Avoid collisions" (no direction nor order: it covers both, at random). The estimate is a duration ("212 to introduce · about 7 months at this rhythm"); it counts the directions queued by the distillations it would stop. Once launched, the screen shows its tile, with pause and stop.

While it exists, a group page says that the global distillation also introduces the cards of the group, and the launch screen of a group distillation shows why it is blocked, with the tile of the global distillation to stop it.

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
- [x] The launch screen sets direction, rhythm, order and collision avoidance, with an estimate of the last arrival.
- [x] The group page follows each distillation (state, rhythm, progress, last arrival) with pause / resume and stop.
- [x] Home shows the new cards of a distillation as "New knowledge".
- [x] Settings launches and follows the global distillation; a group launch is blocked meanwhile, with a way to stop it.

## Test strategy

- The rhythm (`DistillationRhythm`) and the budget (`CollisionBudget`) are tested as pure functions: batch owed, rest of a batch held back, next batch day, estimate of the last arrival; ranking of the reminders and room left for new cards.
- The launch rules and the global distillation are tested on an in-memory database: refusals, queues taken over, cards created meanwhile, and the reverse arriving after its front over ten simulated days with a seeded random order.
- The example of 3 cards a day on the Standard preset is replayed day by day on an in-memory database, answering every card when it comes.
- The service is tested on an in-memory database filled through the services, moving a fixed clock across days: first batch, next days, 4am boundary, missed days, additions, reverse, pause, stop, suspension, end.
- The launch screen, the group page, Home, the global distillation screen (before and after launch) and the blocked group launch are covered by golden tests; widget tests launch a group and a global distillation from their screens.
- The wake-up at the start of the day is tested with the fake alarm scheduler: the planned moment, and the introduction done by the wake-up.

## File mapping

- `lib/domain/distillation/` — the distillation, its settings, the rhythm and the queue rules.
- `lib/application/distillation/` — `DistillationService`, the progress of a distillation (`DistillationProgress`) and their providers.
- `lib/features/distillation/` — the launch screens (group and global), the tile and the section of a group page.
- `lib/data/repositories/distillation_repository.dart` — storage of the distillations; the queue itself is stored on the directions (`CardRepository`).

## Technical details

The queue is not a table: a direction belongs to the queue of a distillation when it is pending and points to it (`distillationId`), at its `queuePosition`. An introduced direction keeps pointing to its distillation while it runs, which is how the distillation finds its cards. Deleting a distillation sets these links to `null` (foreign key `ON DELETE SET NULL`).

The daily pass runs in a transaction and reads the distillation again inside it, because the app and a wake-up may run it at the same moment from two isolates; the day already processed (`lastAdvancedDay`) makes the second pass a no-op.
