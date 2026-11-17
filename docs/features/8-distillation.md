# Feature 8 — Distillation

Status: implemented (2026-11-17)

## Goal

Introduce the cards of a group a few at a time ("one piece of knowledge a day") instead of making them all due at once. The [distillation](../lexicon.md#distillation) of a group takes its [pending](../lexicon.md#pending) cards and hands them to review at the rhythm "N cards every X days"; each card then follows its preset like any other. It is the only way a card enters review.

## Implementation overview

### Activating

A distillation is a permanent setting of a group, at most one per group. The group does not distill until the user activates it from its page: until then its cards stay pending. Activating introduces the first batch the same day. A group with an empty queue can be activated too: the cards added later arrive at its rhythm.

### Queue

The [queue](../lexicon.md#queue) of a group is its pending cards in a fixed order, and the distillation takes its cards from the head of it. That order is the only one: the distillation has no order setting, and the user never reorders the queue by hand.

A card created in the group, moved into it while pending, or reset joins the end of the queue. A card moved out of the group leaves it, keeping its progression if it was introduced. A suspended card keeps its place and is skipped.

### Rhythm

A batch of N cards is owed from its batch day on; the next batch comes X days after the day the previous one was completed. Introducing a card makes it due today at the [daily slot](../lexicon.md#daily-slot), due right away when the slot has passed. It then follows its preset.

Each scheduling day is processed once per distillation, by the first pass that sees it: at app launch, or at any wake-up of the app. A running distillation plans a wake-up at the start of the next day it has to process (4am), so cards are introduced with the app closed. A missed day is not caught up: at most one batch is introduced per day. When the queue is empty, the distillation simply waits for new cards.

### Adjusting

The settings stay editable: "N cards every X days" and "Avoid collisions". If the current batch already gave as many cards as the new N, it is closed and the next one comes X days after the last day processed; otherwise it is completed up to the new N. When today was already processed, the new settings apply from the next pass.

### Avoiding collisions

With "Avoid collisions" (on by default), a distillation has a budget of N notifications a day, N being its cards per batch. When the day is processed, the reminders due today of the cards of the group come first, the shortest interval first (a D+1 reminder before a D+2 one; a card introduced and not answered yet counts as the shortest). Those over the budget move to the next day at the daily slot, keeping their step: no penalty. New cards only get what is left of the budget; the part of the batch they cannot take waits for the next days.

With 3 cards a day on the Standard preset, every card answered correctly: day 1 brings three new cards, day 2 their three D+1 reminders and no new card, day 3 three new cards, day 4 the three D+1 reminders while the three D+2 reminders move to day 5.

The budget is spent once, when the day is processed; reminders that come later the same day (intervals shorter than a day) do not count. It only applies while the distillation runs and its queue holds a card ready to come out (pending and not suspended): a distillation never ends, and a budget kept once the queue is empty would hold the group to N reminders a day for good. Without the option, the N cards of a batch arrive whatever is due.

### Pause

A paused distillation introduces nothing and spends no budget; its introduced cards follow their preset. Resuming it processes the current day if it was not processed yet. There is no stop and no end.

### Screens

While the group does not distill, its page shows a large "Distill" button ([Feature 4](4-groups.md#group-page)). Once activated, a "Distillation" section takes its place: "In progress" or "Paused", "Adjust", a pause / resume button, the rhythm ("1 card per day"), the waiting cards ("5 cards waiting") and the estimated day of the last arrival.

The "Distill" screen shows the [schedule](../lexicon.md#schedule) of the app and the preset the cards will follow, then the settings: "N cards every X days" (1 / 1 by default) and "Avoid collisions" (on, explaining the daily budget). An estimate follows ("44 cards · last arrival on 23 December"), computed as if every batch went through, or a line saying no card waits. It ends on "Start distilling"; opened from "Adjust", it is titled "Adjust the distillation", starts from the current settings and ends on "Save".

On Home, the new cards of a group have one line per day ([Feature 6](6-home.md#new-cards)).

## Acceptance criteria

- [x] A group does not distill until activated; activating introduces the first batch the same day.
- [x] The distillation takes the head of the queue, skipping the suspended cards; it has no order setting.
- [x] Batches follow "N cards every X days", one batch at most per day, the day starting at 4am, with the app closed.
- [x] A card added to the group joins the end of the queue, even when the queue was empty; a card moved out of the group leaves it.
- [x] One distillation per group; it is adjusted, paused and resumed, never stopped.
- [x] Adjusting changes the rhythm and collision avoidance, keeping the progress of the batches.
- [x] Avoiding collisions: a daily budget of N notifications while cards wait, reminders first and shortest intervals first, the rest moved to the next day without penalty, new cards in what is left.
- [x] The "Distill" screen activates or adjusts, with an estimate of the last arrival.
- [x] The group page follows the distillation (state, rhythm, waiting cards, last arrival) with "Adjust" and pause / resume.

## Test strategy

- The rhythm (`DistillationRhythm`) and the budget (`CollisionBudget`) are tested as pure functions: batch owed, rest of a batch held back, next batch day, estimate of the last arrival, arrivals day by day; ranking of the reminders and room left for new cards.
- The example of 3 cards a day on the Standard preset is replayed day by day on an in-memory database, answering every card when it comes.
- The service is tested on an in-memory database filled through the services, moving a fixed clock across days: activation, first batch, next days, 4am boundary, missed days, additions to an empty queue, adjustment, pause, suspension, budget only while cards wait.
- The "Distill" screen, the group page and Home are covered by golden tests; widget tests activate a distillation and adjust it from their screens.
- The wake-up at the start of the day is tested with the fake alarm scheduler: the planned moment, and the introduction done by the wake-up.

## File mapping

- `lib/domain/distillation/` — the distillation, its settings, the rhythm and the queue rules.
- `lib/application/distillation/` — `DistillationService`, the progress of a distillation (`DistillationProgress`) and their providers.
- `lib/features/distillation/` — the "Distill" screen, the tile and the section of a group page.
- `lib/data/repositories/distillation_repository.dart` — storage of the distillations; the queue itself is stored on the cards (`CardRepository`).

## Technical details

The queue is not a table: a card is in the queue of its group when it is pending, at its `queuePosition`, ties broken by creation. A card joining the end takes the position after the last pending one. Introducing a card clears its position. A distillation row is keyed by its group, and deleted with it.

The daily pass runs in a transaction and reads the distillation again inside it, because the app and a wake-up may run it at the same moment from two isolates; the day already processed (`lastAdvancedDay`) makes the second pass a no-op.
