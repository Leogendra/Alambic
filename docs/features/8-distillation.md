# Feature 8 — Distillation

Status: implemented (2026-11-20)

## Goal

Introduce the cards of a group a few at a time ("one piece of knowledge a day") instead of making them all due at once. The [distillation](../lexicon.md#distillation) of a group takes its [pending](../lexicon.md#pending) cards and hands them to review at the rhythm "N cards every X days"; each card then follows its preset like any other. It is the only way a card enters review.

## Implementation overview

### Activating

A distillation is a permanent setting of a group, at most one per group. The group does not distill until the user activates it from its page: until then its cards stay pending. Activating introduces the first batch the same day, or at the end of the global pause when it is on. A group with an empty queue can be activated too: the cards added later arrive at its rhythm.

### Queue

The [queue](../lexicon.md#queue) of a group is its pending cards in a fixed order, and the distillation takes its cards from the head of it. That order is the only one: the distillation has no order setting, and the user never reorders the queue by hand.

A card created in the group, moved into it while pending, or reset joins the end of the queue, and a pending card missed in "Review all" goes to its head ([Feature 4](4-groups.md#review-all)); a bulk add joins it as a whole batch, in the order chosen on its screen ([Feature 3](3-cards.md#bulk-add)). A card moved out of the group leaves it, keeping its progression if it was introduced. A suspended card keeps its place and is skipped.

### Rhythm

The distillation makes one pass per scheduling day, by the first pass that sees it: at app launch, or at any wake-up of the app. A running distillation plans a wake-up at the start (4am) of the day it owes its next batch, so cards are introduced with the app closed. When that wake-up is missed, the phone being off at 4am, it fires at restart, and the pass runs then; opening the app runs it too. Introducing a card makes it due today at the [daily slot](../lexicon.md#daily-slot), due right away when the slot has passed. It then follows its preset.

A batch comes out every X days, counted from the last day a batch came out; the first one comes out on activation. A batch comes out only when a card is ready to leave the queue (pending and not suspended): while the queue is empty, the batch stays owed and comes out at the first pass after a card joins. A batch short of cards gives what the queue holds and is never completed the next days.

At most one batch comes out per pass, and missed batches are never caught up: after a week with the phone off, a single batch comes out and the rhythm starts again from that day. The reminders due meanwhile stay due.

### Adjusting

The settings stay editable: "N cards every X days" and "Prioritize reviews". Changing the rhythm misses nothing: the next batch comes out at the earliest today, and at the earliest X days (the new X) after the last batch. When today's pass already ran, the new settings apply from the next pass.

### Prioritizing reviews

With "Prioritize reviews" (on by default), a batch day brings max(0, N − the cards of the group due at the pass) new cards. Every card due at that moment counts: due today, late, introduced and not answered yet. A reminder of less than a day that falls later the same day does not count. The cards that do not come out stay at the head of the queue, and the next batch comes X days later, with the same computation.

Reminders always arrive on their due date: the distillation never moves them. With 3 cards a day, day 1 brings three new cards; one is missed (due the next day) and two are answered (due in three days), so day 2 brings the missed card and two new ones. With 1 card a day, a card planned a week ago and a card missed yesterday both fall today: both arrive, without a new card.

Without the option, the N new cards of a batch arrive at the rhythm whatever is due. The global daily cap of notifications ([Feature 7](7-notifications.md)) applies on top.

### Pause

A distillation is paused and resumed from its "Distill" screen, opened from its group page; the button applies at once, without "Save". A paused distillation introduces nothing. Its introduced cards follow their preset and keep being notified: no due date moves, during the pause or at its end. There is no stop and no end.

The global pause, started from the Notifications category of Settings after a confirmation and ended from Home's banner or from Settings, holds back every distillation the same way, and only them: the reminders go on. It leaves each distillation's own pause alone: a distillation paused before it is still paused after it.

Resuming, from either pause, processes the current day if it was not processed yet: a single batch comes out if the rhythm owes one, as after days with the phone off, and the rhythm starts again from that day. A distillation resumed on a day already processed waits for the next one.

### Screens

While the group does not distill, its page shows a large "Distill" button ([Feature 4](4-groups.md#group-page)). Once activated, a "Distillation" section takes its place: a "Distillation" tag, or "Paused since Nov 3" with a pause icon, a settings button that opens the "Distill" screen, the rhythm ("1 card a day"), the waiting cards ("5 cards waiting") and the estimated day of the last arrival ("last around Nov 15"), or "no arrival planned" while cards wait and no arrival is planned (paused, or during the global pause).

The "Distill" screen shows the [schedule](../lexicon.md#schedule) of the app and the preset the cards will follow, then the settings: "N cards every X days" (1 / 1 by default) and "Prioritize reviews" (on, explaining that each card due takes the place of a new card). An estimate of the last arrival follows, with the settings being chosen ("44 cards · last one arrives around December 23", see [Estimates](#estimates)), or a line saying no card waits. It ends on "Start distilling"; opened from the group page, it is titled "Adjust the distillation", starts from the current settings and ends on "Save". There, a "Pause" or "Resume" button follows the settings, with a line saying that no new card comes out while the reminders go on ("Paused since November 3: …" while paused); a paused distillation shows "13 cards waiting · paused" instead of its estimate, and so does any distillation during the global pause.

On Home, the new cards of a group have one line per day ([Feature 6](6-home.md#new-cards)), and count in the totals of the coming month and year.

### Estimates

The "Distill" screen, the group page and Home announce the arrivals to come from the rhythm, batch after batch from the next batch day until the queue is empty: today until today's pass ran, otherwise X days after the last batch, never before tomorrow. With "Prioritize reviews", each batch day gives up a place for every card of the group already due that day: on today, the cards due right now, late ones included; on a later day, the cards whose due day it is. The reviews of the cards not introduced yet, and those of the cards answered meanwhile, are unknown: an announced arrival can slip, which is why the screens say "around". A paused distillation, or any during the global pause, announces nothing.

## Acceptance criteria

- [x] A group does not distill until activated; activating introduces the first batch the same day.
- [x] The distillation takes the head of the queue, skipping the suspended cards; it has no order setting.
- [x] A batch comes out every X days from the last one, one at most per pass, the day starting at 4am, with the app closed; missed batches are not caught up and a batch is never completed the next days.
- [x] A card added to the group joins the end of the queue, even when the queue was empty; a card moved out of the group leaves it.
- [x] One distillation per group; it is adjusted, paused and resumed, never stopped.
- [x] Adjusting changes the rhythm and "Prioritize reviews"; the next batch comes out at the earliest today and X days (the new X) after the last one.
- [x] Prioritizing reviews: a batch day brings N new cards minus the cards of the group due at the pass, late and unanswered ones included; reminders are never moved.
- [x] The "Distill" screen activates or adjusts, with an estimate of the last arrival that leaves out the batch days taken by the reviews already planned.
- [x] The group page follows the distillation (pause, rhythm, waiting cards, last arrival) with a single settings button.
- [x] A paused distillation, and every distillation during the global pause, introduces nothing; the reminders go on and no due date moves. Resuming brings a single batch at most; the global pause leaves each distillation's own pause alone.
- [x] A missed 4am wake-up runs the pass at restart, or at the opening of the app.

## Test strategy

- The rhythm (`DistillationRhythm`) is tested as pure functions: batch owed, new cards with and without "Prioritize reviews", next introduction day, and the forecast of arrivals: batches until the queue is empty, places taken by the reviews planned on a batch day (late ones today, not a reminder of less than a day already answered), a batch day fully taken, a forecast bounded in time.
- The progress of a distillation is tested on its last arrival, slipping with the reviews, and on no arrival while paused.
- The two examples of "Prioritize reviews" are replayed on an in-memory database, with late and unanswered cards counted and reminders left in place.
- The service is tested on an in-memory database filled through the services, moving a fixed clock across days: activation, first batch, next days, 4am boundary, a week without pass (one batch, rhythm restarting from it), a batch short of cards, an empty queue, changes of rhythm before and after the day's pass, pause, suspension.
- The "Distill" screen, the group page and Home are covered by screen tests with a capture; widget tests activate a distillation and adjust it from their screens, and check the waiting cards shown instead of the estimate during the global pause.
- The pauses are tested with the notification fakes: a paused distillation keeps its cards notified and their due dates, a pause of a week brings one batch on resume, the global pause holds every distillation and plans no wake-up for them, and leaves alone a distillation paused on its own.
- The wake-up at the start of the day is tested with the fake alarm scheduler: the planned moment, the introduction done by the wake-up, and a wake-up firing late at restart, which notifies the batch at once.
- The group page and the "Distill" screen of a paused distillation have captures; resuming from the screen is checked in the database.

## File mapping

- `lib/domain/distillation/` — the distillation, its settings, the rhythm and the queue rules.
- `lib/application/distillation/` — `DistillationService`, the progress of a distillation (`DistillationProgress`) and their providers.
- `lib/features/distillation/` — the "Distill" screen, the tile and the section of a group page.
- `lib/features/pauses/` — the global pause: its confirmation and Home's banner.
- `lib/data/repositories/distillation_repository.dart` — storage of the distillations; the queue itself is stored on the cards (`CardRepository`).
- `lib/data/repositories/pause_repository.dart` — the start of the global pause (`app_settings.paused_at`).

## Technical details

The queue is not a table: a card is in the queue of its group when it is pending, at its `queuePosition`, ties broken by creation. A card joining the end takes the position after the last pending one. Introducing a card clears its position. A distillation row is keyed by its group, and deleted with it.

A distillation is paused by the start of its pause (`pausedAt`), shown on its page; `null` means running. A distillation row keeps only two days of progress: the last day processed (`lastAdvancedDay`) and the last day a batch came out (`lastBatchDay`, empty until the first batch). The next batch day follows from the latter and the current X, which is why a change of rhythm needs no rewrite.

The estimates replay the rhythm without touching the database (`DistillationRhythm.forecast`): it counts the reviews of the group by due day once, then walks the batch days until the queue is empty or the end of the period asked for.

A pause records nothing about the days it covers: the pass simply skips a paused distillation, so the day of the last batch and the current X decide alone what the first pass after the pause owes.

The restart relies on `android_alarm_manager_plus`: it keeps every alarm it scheduled and schedules them again at boot, and Android fires at once an alarm whose moment has passed. The 4am wake-up missed while the phone was off is one of them.

The daily pass runs in a transaction and reads the distillation again inside it, because the app and a wake-up may run it at the same moment from two isolates; the day already processed makes the second pass a no-op.
