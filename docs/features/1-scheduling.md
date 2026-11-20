# Feature 1 — Review scheduling

Status: implemented (2026-11-20)

## Goal

Decide, after each answer, when a [card](../lexicon.md#card) must come back. This is the heart of spaced repetition: a successful card comes back later and later, a failed card comes back sooner. A single engine decides the interval: the fixed sequence of intervals of the [preset](../lexicon.md#preset), walked step by step, then the end of sequence chosen by the [group](../lexicon.md#group): [remanence](../lexicon.md#remanence) or [acquired](../lexicon.md#acquired).

There is no adaptive engine (FSRS or other). With two answers and parameters not fitted to the user, it would only differ from a sequence on late answers and failures, for the cost of a second engine, a conversion of the progression and a display of its memory. It is worth reconsidering only together with fitting the parameters to the user's history.

## Implementation overview

Scheduling lives entirely in the domain and works in two stages.

1. The sequence engine (`SequenceEngine`) computes the interval to wait: from where the card stands (`CardProgress`) and the answer, it reaches a [step](../lexicon.md#step) or the remanence, or reports that the card is acquired.
2. The scheduler (`ReviewScheduler`) turns that interval into a [due date](../lexicon.md#due-date), depending on whether the interval counts in days or in minutes.

A card has a single progression, whichever face is asked: the [back option](../lexicon.md#back-option) of a group changes what a display asks, never what the scheduler reads.

The [day](../lexicon.md#day) starts at 4am, through `SchedulingCalendar`. An answer given at 1am counts for the previous day, and every "same day" comparison goes through this calendar. Days are added as calendar days rather than 24-hour slices, so that a daylight saving change does not shift the slot by an hour.

The engine never reads the time: the answer moment is given to it. It does not read the database either; the caller gives the scheduler the card, its resolved preset and the end of sequence of its group (`SequenceEnd`), both read from the preset catalog.

### The step

The step is the index, in the preset sequence, of the interval currently waited. A card never answered has no step: its first correct answer waits the first interval. In the Standard sequence (1 d, 2 d, 1 wk, 1 mo, 3 mo, 6 mo), a card answered correctly three times in a row therefore waits 1 week, at its fourth step.

No screen and no notification names the step: a card only shows its next date, and its sheet shows its position on a bar of the sequence ([Feature 3](3-cards.md#card-sheet)).

If the sequence was shortened, or the card moved to a shorter preset, the engine clamps the step to the last existing step before computing. The stored step is only corrected at the next answer. `CardProgress` gives, for any card, its preset and the end of sequence of its group, the clamped step and the interval it waits, the remanence and its interval, or "new": the card sheet and the priority of the daily cap read it.

### After the last step

A success at the last step puts the card past its sequence. What follows is the end of sequence of the group, an option of the group rather than of the preset:

- **remanence** (the default) brings the card back forever at a fixed interval: 3 months, 6 months (the default) or 1 year, chosen by the group. When the last step of the preset is longer, the last step is waited instead, so that a preset with long steps never comes back sooner in remanence than in its sequence. A short preset does not shorten the remanence: Intensive (last step 1 week) comes back after 6 months.
- **acquired** stops the reminders: the card has no due date any more.

The remanence is one more step after the last one of the preset: a success in remanence stays in remanence, and a failure follows the failure behaviour like any other step ([On failure](#on-failure)).

The card only stores that it is past its sequence (`CardState.completed`, without step), never which end it reached: its group says whether it comes back. A step number past the sequence would not do. Steps are clamped to the current sequence at each computation, so such a number would be read as an ordinary step once the sequence is lengthened, and a clamped step would pass for remanence. A state stays past the sequence whatever the preset becomes.

Switching the end of a group therefore applies at once to its cards past the sequence:

- switched to acquired, they lose their due date;
- switched back to remanence, each one is due one remanence interval after its last review, at the [daily slot](../lexicon.md#daily-slot). With a 6-month remanence, a card last reviewed 3 months ago is due in 3 months. When that day has already passed, the card is due one remanence interval after the day of the switch instead, so that the cards acquired long ago do not all become due at once.

Changing the remanence interval moves no due date; it applies from the next answer.

### On failure

"Again" on a due card applies the failure behaviour of the preset (`FailureBehavior`), then waits the interval of the step reached:

- **step back** (the default) moves from step k to step k − 1, and stays at the first step; from the remanence, it goes back to the last step;
- **restart** goes back to the first step; the card stays introduced, unlike "Reset", which sends it back to the queue;
- **stay** keeps the step, so the card waits its interval again; a card in remanence stays in remanence.

The behaviour is read at each answer, from the preset in force at that moment: editing it moves no due date. A [bonus review](../lexicon.md#bonus-review) never applies it.

### Introducing a card

A new card is never scheduled by itself: it is [pending](../lexicon.md#pending) in the [queue](../lexicon.md#queue) of its group until the group's [distillation](8-distillation.md) introduces it. Introduced, it is due today at the [daily slot](../lexicon.md#daily-slot), even when that slot has already passed: the card is due at once. Resetting its progress sends it back to the end of the queue.

### Due

A card counts as [due](../lexicon.md#due) when it is active or in remanence, not suspended, and:

- its due date has passed;
- or its due date falls today (or earlier) and it has not already been reviewed today.

The second condition lets the user review in the app, in the morning, a card planned for 12:00 without waiting for the notification. It does not apply to a card just answered correctly with a 10-minute interval: reviewed today, it waits for its exact due date.

## Examples

Standard preset, 12:00 slot, remanence every 6 months:

| Situation | Answer | Result |
|---|---|---|
| Never reviewed, Tuesday 9:30pm | Correct | 1 d, Wednesday 12:00 |
| Waiting 1 d, Tuesday 9:30pm | Correct | 2 d, Thursday 12:00 |
| Waiting 1 mo, Tuesday 12:05 | Again | 1 wk, next Tuesday 12:00 |
| Never reviewed, Wednesday 1am | Correct | 1 d, Wednesday 12:00 (the answer counts for Tuesday) |
| Waiting 6 mo (last step), 10 November | Correct | Remanence, 9 May 12:00 (180 days) |
| In remanence, step back on failure | Again | 6 mo, in 180 days |

Intensive preset (10 min, 1 h, …): a first correct answer at 15:07 gives a due date at 15:17, whatever the [daily slot](../lexicon.md#daily-slot).

## Acceptance criteria

- [x] An introduced card is due today at the [daily slot](../lexicon.md#daily-slot).
- [x] Correct moves one step forward; the first correct answer waits the first interval.
- [x] Again applies the preset behaviour: one step back without going below the first, back to the start, or same step. A never-reviewed card answered Again waits the first interval.
- [x] Back to the start keeps the card introduced: it does not return to the queue.
- [x] The failure behaviour is read at the answer: a preset edited between two answers moves no due date, and the next failure follows the new behaviour.
- [x] After the last step, Correct applies the end of sequence of the group, read at the answer: remanence at the interval of the group, or at the last step when it is longer; or acquired, with no more due date.
- [x] A failure in remanence follows the failure behaviour: back to the last step, back to the first step, or still in remanence.
- [x] A card in remanence stays in remanence, with its due date, when its sequence gets shorter or longer.
- [x] Switching a group to acquired removes at once the due date of its cards past the last step. Switching it back to remanence makes each of them due one remanence interval after its last review, or after the switch when that day has passed. Changing the remanence interval moves no due date.
- [x] An interval of a day or more counts from the answer day and lands on the [daily slot](../lexicon.md#daily-slot).
- [x] An interval shorter than a day counts from the answer moment.
- [x] After a failure, the due date is the interval of the step reached: never the same day for a day-based sequence.
- [x] The day starts at 4am.
- [x] A step beyond a shortened sequence is clamped to the last step.

## Test strategy

- Each engine rule is proven by a domain unit test, without a database: moving forward, each failure behaviour, each end of sequence, each failure in remanence, the remanence interval against the last step, clamped step.
- The failure behaviours and the end of sequence are proven again through the services on stored cards, so that the step, the due date, the state and the queue position are read back from the database. This covers a preset edited between two answers, and a group switched between remanence and acquired in both directions, with a last review recent or older than the remanence interval.
- Dates are fixed in the tests (November 2026): no test reads the clock or waits.
- The day boundaries (3:59am and 4am, end of month, slot before 4am) are tested explicitly on the calendar.

## File mapping

- `lib/domain/scheduling/` — 4am calendar, sequence engine, scheduler, "due" rule and `CardProgress`.
- `lib/domain/groups/sequence_end.dart` — the end of sequence of a group and the remanence interval it gives after a preset.
- `lib/domain/presets/preset_interval.dart` — an interval and its unit; a unit of a day or more counts in days.

## Technical details

Months count 30 days (`IntervalUnit.month`) and years 365 days (`IntervalUnit.year`). A "1 month" always has the same length, and the "in 30 d" preview shown on the buttons stays true whatever the current month.

A daily slot earlier than 4am (for example 2am) belongs to the end of the scheduling day: `momentAt` places it on the next calendar date. Without this, a due date "day D at 2am" would fall on the previous evening in the user's calendar.

## Constraints

- The scheduling domain stays pure Dart: no Flutter, drift or plugin import.
